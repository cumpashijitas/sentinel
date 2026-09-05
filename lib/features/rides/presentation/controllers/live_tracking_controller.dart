import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/platform/platform_capabilities.dart';
import '../../../../core/services/supabase_providers.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/datasources/android_background_location_service.dart';
import '../../data/datasources/geolocator_location_tracker.dart';
import '../../data/datasources/live_location_remote_datasource.dart';
import '../../data/repositories/live_location_repository_impl.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/entities/location_fix.dart';
import '../../domain/entities/member_location.dart';
import '../../domain/repositories/background_location_service.dart';
import '../../domain/repositories/live_location_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/location_tracker.dart';
import '../../domain/services/member_tracking_service.dart';
import 'ride_sessions_controller.dart';

part 'live_tracking_controller.g.dart';

@Riverpod(keepAlive: true)
LocationTracker locationTracker(Ref ref) => const GeolocatorLocationTracker();

@riverpod
LiveLocationRemoteDataSource liveLocationRemoteDataSource(Ref ref) {
  return SupabaseLiveLocationRemoteDataSource(
    ref.watch(supabaseClientProvider),
  );
}

@Riverpod(keepAlive: true)
LiveLocationRepository liveLocationRepository(Ref ref) {
  return LiveLocationRepositoryImpl(
    ref.watch(liveLocationRemoteDataSourceProvider),
  );
}

@Riverpod(keepAlive: true)
LocationRepository locationRepository(Ref ref) {
  return LocationRepositoryImpl(
    tracker: ref.watch(locationTrackerProvider),
    liveLocationRepository: ref.watch(liveLocationRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
}

/// Android-only remote control for `RideBackgroundService` — see
/// [BackgroundLocationService]'s doc comment for why this is a sibling of
/// [locationRepositoryProvider] rather than another implementation of the
/// same interface. Never read on Web; `LiveTrackingController` branches on
/// `PlatformCapabilities.isAndroid` before touching this provider.
@Riverpod(keepAlive: true)
BackgroundLocationService backgroundLocationService(Ref ref) {
  return AndroidBackgroundLocationService(
    tracker: ref.watch(locationTrackerProvider),
  );
}

/// The ride-map screen's live roster: every active participant, their last
/// known position, and a status computed by [MemberTrackingService].
///
/// Deliberately **not** `keepAlive` — when the map screen is closed and
/// nothing watches this anymore, Riverpod disposes it, which cancels both
/// the Realtime subscription (see `LiveLocationRepositoryImpl.watchSessionLocations`,
/// whose underlying channel is released when its last listener cancels)
/// and the periodic ticker below. That's what satisfies "cancel
/// subscriptions correctly on exit" — no manual `StreamSubscription`
/// bookkeeping needed in the widget itself.
///
/// The periodic ticker exists because a status can change purely from
/// *time passing* (active → stale → offline) even when no new location
/// event arrives — without it, a rider who simply stopped sending updates
/// would appear "active" forever.
@riverpod
Stream<List<MemberLocation>> sessionMemberLocations(
  Ref ref,
  String sessionId,
) async* {
  final participants = await ref.watch(
    rideParticipantsProvider(sessionId).future,
  );
  final liveLocationRepo = ref.watch(liveLocationRepositoryProvider);
  const trackingService = MemberTrackingService();

  var latestFixes = const <String, LocationFix>{};
  final controller = StreamController<List<MemberLocation>>();
  ref.onDispose(controller.close);

  List<MemberLocation> recompute() => trackingService.computeStatuses(
    participants: participants,
    fixesByUserId: latestFixes,
    now: DateTime.now(),
  );

  final locationSubscription = liveLocationRepo
      .watchSessionLocations(sessionId)
      .listen(
        (fixes) {
          latestFixes = fixes;
          if (!controller.isClosed) controller.add(recompute());
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!controller.isClosed) controller.addError(error, stackTrace);
        },
      );
  ref.onDispose(locationSubscription.cancel);

  final ticker = Timer.periodic(const Duration(seconds: 10), (_) {
    if (!controller.isClosed) controller.add(recompute());
  });
  ref.onDispose(ticker.cancel);

  yield* controller.stream;
}

/// Drives "share my location for this ride" (start/stop). Same shape as
/// the other `*Controller`s: `state` is only the action's own
/// loading/error/success.
///
/// **Platform split (Fase 6)**: on Android, sharing is always delegated to
/// [BackgroundLocationService] (`RideBackgroundService`) — never to
/// [LocationRepository] directly, even while the app is in the
/// foreground. This is deliberate, not an oversight: it means there is
/// only ever *one* place doing the actual tracking on Android, by
/// construction, so there's no risk of the foreground path and the
/// background service both watching the device at once after, say, the
/// app is reopened while the service is still running (the "avoid a
/// duplicate subscription" risk flagged at the end of the Fase 5 report).
/// On Web — which has no background service — [LocationRepository] is
/// still exactly the Fase 5 path, since it's the only one that exists
/// there.
@riverpod
class LiveTrackingController extends _$LiveTrackingController {
  @override
  FutureOr<void> build() {
    // Safety net for the Web path: if this controller is torn down
    // (leaving the map screen) while still sharing via
    // [LocationRepository], make sure the device stops being watched
    // instead of silently continuing — Web keeps the browser's location
    // indicator lit until the underlying `getPositionStream` subscription
    // is cancelled. On Android this repository is never the one sharing
    // (see the class doc comment above), so `repo.isSharing` here is
    // always false and this is a no-op — RideBackgroundService manages its
    // own lifecycle independently of this controller/provider.
    //
    // The repository is read here (during `build`), not inside the
    // `onDispose` callback itself — Riverpod forbids `ref.read` while a
    // dispose callback is running, since other providers may already be
    // torn down by then. `locationRepositoryProvider` is `keepAlive`, so
    // this is the same instance `start`/`stop` use.
    final repo = ref.read(locationRepositoryProvider);
    ref.onDispose(() {
      if (repo.isSharing) unawaited(repo.stopSharing());
    });
  }

  /// Public read of the notifier's own `state`, for callers that hold a
  /// [LiveTrackingController] reference directly (rather than a `ref`) and
  /// may no longer have a safely-usable `ref` of their own — e.g. a widget
  /// checking the outcome of [start]/[stop] after an `await`, when it may
  /// have been disposed in the meantime. `state` itself is protected, so
  /// this getter is the sanctioned way out to callers outside this class.
  AsyncValue<void> get lastResult => state;

  Future<void> start(String sessionId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => PlatformCapabilities.isAndroid
          ? ref.read(backgroundLocationServiceProvider).start(sessionId)
          : ref.read(locationRepositoryProvider).startSharing(sessionId),
    );
  }

  Future<void> stop() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => PlatformCapabilities.isAndroid
          ? ref.read(backgroundLocationServiceProvider).stop()
          : ref.read(locationRepositoryProvider).stopSharing(),
    );
  }
}
