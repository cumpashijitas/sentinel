import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_client.dart';
import '../../../rides/data/datasources/geolocator_location_tracker.dart';
import '../../../rides/domain/entities/location_fix.dart';
import '../../../rides/domain/repositories/location_tracker.dart';
import '../../data/datasources/emergency_share_remote_datasource.dart';
import '../../data/repositories/emergency_share_repository_impl.dart';
import '../../domain/entities/emergency_share.dart';
import '../../domain/repositories/emergency_share_repository.dart';

part 'emergency_share_providers.g.dart';

@riverpod
EmergencyShareRemoteDataSource emergencyShareRemoteDataSource(Ref ref) {
  return HttpEmergencyShareRemoteDataSource(ref.watch(apiClientProvider));
}

@Riverpod(keepAlive: true)
EmergencyShareRepository emergencyShareRepository(Ref ref) {
  return EmergencyShareRepositoryImpl(
    ref.watch(emergencyShareRemoteDataSourceProvider),
  );
}

/// The caller's own active share, or `null`. Invalidated by
/// [EmergencyShareActionsController] after start/stop.
@riverpod
Future<EmergencyShare?> activeShare(Ref ref) {
  return ref.read(emergencyShareRepositoryProvider).fetchActiveShare();
}

/// Riders currently sharing with the caller (in-app path) — see
/// `EmergencyShareRepository.fetchSharedWithMe`.
@riverpod
Future<List<SharedWithMeEntry>> sharedWithMe(Ref ref) {
  return ref.read(emergencyShareRepositoryProvider).fetchSharedWithMe();
}

@Riverpod(keepAlive: true)
LocationTracker emergencyLocationTracker(Ref ref) =>
    const GeolocatorLocationTracker();

/// Drives the actual GPS push loop while a share is active — separate from
/// [EmergencyShareActionsController] (which only tracks the start/stop
/// *action* itself) the same way `LiveTrackingController` is separate from
/// `RideSessionActionsController` for group rides. No sampling/history
/// here on purpose: a share only ever needs the *current* position, there's
/// no `location_history`-equivalent table for it.
@riverpod
class EmergencyShareTrackingController
    extends _$EmergencyShareTrackingController {
  StreamSubscription<LocationFix>? _subscription;
  final _fixController = StreamController<LocationFix>.broadcast();

  /// Every fix this device sends out while sharing — separate from `state`
  /// (which only tracks the start/stop *action*, not a stream of values).
  /// `EmergencySharePage` uses this to show the rider their own live
  /// position while sharing, the same feedback a group ride's map gives —
  /// previously sharing solo was just a toggle with no visual confirmation
  /// it was actually working.
  Stream<LocationFix> get fixStream => _fixController.stream;

  @override
  FutureOr<void> build() {
    ref.onDispose(() {
      unawaited(_subscription?.cancel());
      unawaited(_fixController.close());
    });
  }

  Future<void> start(String shareId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final tracker = ref.read(emergencyLocationTrackerProvider);
      final granted = await tracker.ensurePermission();
      if (!granted) {
        throw StateError(
          'Sentinel necesita permiso de ubicación para compartir tu posición.',
        );
      }

      await _subscription?.cancel();
      final repository = ref.read(emergencyShareRepositoryProvider);
      _subscription = tracker.watchPosition().listen((fix) {
        if (!_fixController.isClosed) _fixController.add(fix);
        unawaited(
          repository
              .upsertMyLocation(shareId: shareId, fix: fix)
              .catchError((Object error, StackTrace stackTrace) {
                AppLogger.error(
                  'Failed to upsert emergency share location',
                  error: error,
                  stackTrace: stackTrace,
                );
              }),
        );
      });
    });
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    state = const AsyncData(null);
  }
}

/// Drives "start/stop sharing with my emergency contacts" from the
/// presentation layer — same shape as `RideSessionActionsController`:
/// `state` only tracks the action itself, not the resulting share (read
/// that from [activeShareProvider]).
@riverpod
class EmergencyShareActionsController
    extends _$EmergencyShareActionsController {
  @override
  FutureOr<void> build() {}

  Future<void> start() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final share = await ref.read(emergencyShareRepositoryProvider).startShare();
      await ref
          .read(emergencyShareTrackingControllerProvider.notifier)
          .start(share.id);
      ref.invalidate(activeShareProvider);
    });
  }

  Future<void> stop() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(emergencyShareTrackingControllerProvider.notifier).stop();
      await ref.read(emergencyShareRepositoryProvider).stopShare();
      ref.invalidate(activeShareProvider);
    });
  }
}
