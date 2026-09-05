// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_tracking_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(locationTracker)
final locationTrackerProvider = LocationTrackerProvider._();

final class LocationTrackerProvider
    extends
        $FunctionalProvider<LocationTracker, LocationTracker, LocationTracker>
    with $Provider<LocationTracker> {
  LocationTrackerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationTrackerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationTrackerHash();

  @$internal
  @override
  $ProviderElement<LocationTracker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocationTracker create(Ref ref) {
    return locationTracker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationTracker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationTracker>(value),
    );
  }
}

String _$locationTrackerHash() => r'5bb096539a74ce3547296b1c9c8e473abc8cae69';

@ProviderFor(liveLocationRemoteDataSource)
final liveLocationRemoteDataSourceProvider =
    LiveLocationRemoteDataSourceProvider._();

final class LiveLocationRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          LiveLocationRemoteDataSource,
          LiveLocationRemoteDataSource,
          LiveLocationRemoteDataSource
        >
    with $Provider<LiveLocationRemoteDataSource> {
  LiveLocationRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveLocationRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveLocationRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<LiveLocationRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LiveLocationRemoteDataSource create(Ref ref) {
    return liveLocationRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveLocationRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveLocationRemoteDataSource>(value),
    );
  }
}

String _$liveLocationRemoteDataSourceHash() =>
    r'b1f99978b9e0019fade42671caf07c8b579e8d5c';

@ProviderFor(liveLocationRepository)
final liveLocationRepositoryProvider = LiveLocationRepositoryProvider._();

final class LiveLocationRepositoryProvider
    extends
        $FunctionalProvider<
          LiveLocationRepository,
          LiveLocationRepository,
          LiveLocationRepository
        >
    with $Provider<LiveLocationRepository> {
  LiveLocationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveLocationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveLocationRepositoryHash();

  @$internal
  @override
  $ProviderElement<LiveLocationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LiveLocationRepository create(Ref ref) {
    return liveLocationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveLocationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveLocationRepository>(value),
    );
  }
}

String _$liveLocationRepositoryHash() =>
    r'05c1cbb3f8dae3425d323e15731c79745f62965d';

@ProviderFor(locationRepository)
final locationRepositoryProvider = LocationRepositoryProvider._();

final class LocationRepositoryProvider
    extends
        $FunctionalProvider<
          LocationRepository,
          LocationRepository,
          LocationRepository
        >
    with $Provider<LocationRepository> {
  LocationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationRepositoryHash();

  @$internal
  @override
  $ProviderElement<LocationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocationRepository create(Ref ref) {
    return locationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationRepository>(value),
    );
  }
}

String _$locationRepositoryHash() =>
    r'7ee5ab98445912f52d99bb28721ff815fb3626d4';

/// Android-only remote control for `RideBackgroundService` — see
/// [BackgroundLocationService]'s doc comment for why this is a sibling of
/// [locationRepositoryProvider] rather than another implementation of the
/// same interface. Never read on Web; `LiveTrackingController` branches on
/// `PlatformCapabilities.isAndroid` before touching this provider.

@ProviderFor(backgroundLocationService)
final backgroundLocationServiceProvider = BackgroundLocationServiceProvider._();

/// Android-only remote control for `RideBackgroundService` — see
/// [BackgroundLocationService]'s doc comment for why this is a sibling of
/// [locationRepositoryProvider] rather than another implementation of the
/// same interface. Never read on Web; `LiveTrackingController` branches on
/// `PlatformCapabilities.isAndroid` before touching this provider.

final class BackgroundLocationServiceProvider
    extends
        $FunctionalProvider<
          BackgroundLocationService,
          BackgroundLocationService,
          BackgroundLocationService
        >
    with $Provider<BackgroundLocationService> {
  /// Android-only remote control for `RideBackgroundService` — see
  /// [BackgroundLocationService]'s doc comment for why this is a sibling of
  /// [locationRepositoryProvider] rather than another implementation of the
  /// same interface. Never read on Web; `LiveTrackingController` branches on
  /// `PlatformCapabilities.isAndroid` before touching this provider.
  BackgroundLocationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backgroundLocationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backgroundLocationServiceHash();

  @$internal
  @override
  $ProviderElement<BackgroundLocationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BackgroundLocationService create(Ref ref) {
    return backgroundLocationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackgroundLocationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackgroundLocationService>(value),
    );
  }
}

String _$backgroundLocationServiceHash() =>
    r'3a423c34f7e7ad61cfdcb3461f89f6a33636e138';

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

@ProviderFor(sessionMemberLocations)
final sessionMemberLocationsProvider = SessionMemberLocationsFamily._();

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

final class SessionMemberLocationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MemberLocation>>,
          List<MemberLocation>,
          Stream<List<MemberLocation>>
        >
    with
        $FutureModifier<List<MemberLocation>>,
        $StreamProvider<List<MemberLocation>> {
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
  SessionMemberLocationsProvider._({
    required SessionMemberLocationsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'sessionMemberLocationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionMemberLocationsHash();

  @override
  String toString() {
    return r'sessionMemberLocationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<MemberLocation>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MemberLocation>> create(Ref ref) {
    final argument = this.argument as String;
    return sessionMemberLocations(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionMemberLocationsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionMemberLocationsHash() =>
    r'cc61aab76d773e01205ffd6bb7aa52281facbfed';

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

final class SessionMemberLocationsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<MemberLocation>>, String> {
  SessionMemberLocationsFamily._()
    : super(
        retry: null,
        name: r'sessionMemberLocationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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

  SessionMemberLocationsProvider call(String sessionId) =>
      SessionMemberLocationsProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionMemberLocationsProvider';
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

@ProviderFor(LiveTrackingController)
final liveTrackingControllerProvider = LiveTrackingControllerProvider._();

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
final class LiveTrackingControllerProvider
    extends $AsyncNotifierProvider<LiveTrackingController, void> {
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
  LiveTrackingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveTrackingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveTrackingControllerHash();

  @$internal
  @override
  LiveTrackingController create() => LiveTrackingController();
}

String _$liveTrackingControllerHash() =>
    r'53d8de5a46122378c561643800e54bc9d9421163';

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

abstract class _$LiveTrackingController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
