// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_share_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(emergencyShareRemoteDataSource)
final emergencyShareRemoteDataSourceProvider =
    EmergencyShareRemoteDataSourceProvider._();

final class EmergencyShareRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          EmergencyShareRemoteDataSource,
          EmergencyShareRemoteDataSource,
          EmergencyShareRemoteDataSource
        >
    with $Provider<EmergencyShareRemoteDataSource> {
  EmergencyShareRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emergencyShareRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emergencyShareRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<EmergencyShareRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EmergencyShareRemoteDataSource create(Ref ref) {
    return emergencyShareRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmergencyShareRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmergencyShareRemoteDataSource>(
        value,
      ),
    );
  }
}

String _$emergencyShareRemoteDataSourceHash() =>
    r'9a70cd9fec090ff299c36ffd88bf738b0f3f3460';

@ProviderFor(emergencyShareRepository)
final emergencyShareRepositoryProvider = EmergencyShareRepositoryProvider._();

final class EmergencyShareRepositoryProvider
    extends
        $FunctionalProvider<
          EmergencyShareRepository,
          EmergencyShareRepository,
          EmergencyShareRepository
        >
    with $Provider<EmergencyShareRepository> {
  EmergencyShareRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emergencyShareRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emergencyShareRepositoryHash();

  @$internal
  @override
  $ProviderElement<EmergencyShareRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EmergencyShareRepository create(Ref ref) {
    return emergencyShareRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmergencyShareRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmergencyShareRepository>(value),
    );
  }
}

String _$emergencyShareRepositoryHash() =>
    r'fb2f20bd92c35f25f282ad550b5f310b54c8fa3a';

/// The caller's own active share, or `null`. Invalidated by
/// [EmergencyShareActionsController] after start/stop.

@ProviderFor(activeShare)
final activeShareProvider = ActiveShareProvider._();

/// The caller's own active share, or `null`. Invalidated by
/// [EmergencyShareActionsController] after start/stop.

final class ActiveShareProvider
    extends
        $FunctionalProvider<
          AsyncValue<EmergencyShare?>,
          EmergencyShare?,
          FutureOr<EmergencyShare?>
        >
    with $FutureModifier<EmergencyShare?>, $FutureProvider<EmergencyShare?> {
  /// The caller's own active share, or `null`. Invalidated by
  /// [EmergencyShareActionsController] after start/stop.
  ActiveShareProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeShareProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeShareHash();

  @$internal
  @override
  $FutureProviderElement<EmergencyShare?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EmergencyShare?> create(Ref ref) {
    return activeShare(ref);
  }
}

String _$activeShareHash() => r'5a355c663a1975b5d259a8b88df8d9db2464f18e';

/// Riders currently sharing with the caller (in-app path) — see
/// `EmergencyShareRepository.fetchSharedWithMe`.

@ProviderFor(sharedWithMe)
final sharedWithMeProvider = SharedWithMeProvider._();

/// Riders currently sharing with the caller (in-app path) — see
/// `EmergencyShareRepository.fetchSharedWithMe`.

final class SharedWithMeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SharedWithMeEntry>>,
          List<SharedWithMeEntry>,
          FutureOr<List<SharedWithMeEntry>>
        >
    with
        $FutureModifier<List<SharedWithMeEntry>>,
        $FutureProvider<List<SharedWithMeEntry>> {
  /// Riders currently sharing with the caller (in-app path) — see
  /// `EmergencyShareRepository.fetchSharedWithMe`.
  SharedWithMeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedWithMeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedWithMeHash();

  @$internal
  @override
  $FutureProviderElement<List<SharedWithMeEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SharedWithMeEntry>> create(Ref ref) {
    return sharedWithMe(ref);
  }
}

String _$sharedWithMeHash() => r'94c5da80a1d4df3019bb4dc64fb34735d44c2146';

@ProviderFor(emergencyLocationTracker)
final emergencyLocationTrackerProvider = EmergencyLocationTrackerProvider._();

final class EmergencyLocationTrackerProvider
    extends
        $FunctionalProvider<LocationTracker, LocationTracker, LocationTracker>
    with $Provider<LocationTracker> {
  EmergencyLocationTrackerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emergencyLocationTrackerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emergencyLocationTrackerHash();

  @$internal
  @override
  $ProviderElement<LocationTracker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocationTracker create(Ref ref) {
    return emergencyLocationTracker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationTracker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationTracker>(value),
    );
  }
}

String _$emergencyLocationTrackerHash() =>
    r'0750e36416ae1c34a388c1dcd9e4dbe5e09d0db6';

/// Drives the actual GPS push loop while a share is active — separate from
/// [EmergencyShareActionsController] (which only tracks the start/stop
/// *action* itself) the same way `LiveTrackingController` is separate from
/// `RideSessionActionsController` for group rides. No sampling/history
/// here on purpose: a share only ever needs the *current* position, there's
/// no `location_history`-equivalent table for it.

@ProviderFor(EmergencyShareTrackingController)
final emergencyShareTrackingControllerProvider =
    EmergencyShareTrackingControllerProvider._();

/// Drives the actual GPS push loop while a share is active — separate from
/// [EmergencyShareActionsController] (which only tracks the start/stop
/// *action* itself) the same way `LiveTrackingController` is separate from
/// `RideSessionActionsController` for group rides. No sampling/history
/// here on purpose: a share only ever needs the *current* position, there's
/// no `location_history`-equivalent table for it.
final class EmergencyShareTrackingControllerProvider
    extends $AsyncNotifierProvider<EmergencyShareTrackingController, void> {
  /// Drives the actual GPS push loop while a share is active — separate from
  /// [EmergencyShareActionsController] (which only tracks the start/stop
  /// *action* itself) the same way `LiveTrackingController` is separate from
  /// `RideSessionActionsController` for group rides. No sampling/history
  /// here on purpose: a share only ever needs the *current* position, there's
  /// no `location_history`-equivalent table for it.
  EmergencyShareTrackingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emergencyShareTrackingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emergencyShareTrackingControllerHash();

  @$internal
  @override
  EmergencyShareTrackingController create() =>
      EmergencyShareTrackingController();
}

String _$emergencyShareTrackingControllerHash() =>
    r'eb65e7619b168d55e6a502fe5e90ac2da546dc0c';

/// Drives the actual GPS push loop while a share is active — separate from
/// [EmergencyShareActionsController] (which only tracks the start/stop
/// *action* itself) the same way `LiveTrackingController` is separate from
/// `RideSessionActionsController` for group rides. No sampling/history
/// here on purpose: a share only ever needs the *current* position, there's
/// no `location_history`-equivalent table for it.

abstract class _$EmergencyShareTrackingController extends $AsyncNotifier<void> {
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

/// Drives "start/stop sharing with my emergency contacts" from the
/// presentation layer — same shape as `RideSessionActionsController`:
/// `state` only tracks the action itself, not the resulting share (read
/// that from [activeShareProvider]).

@ProviderFor(EmergencyShareActionsController)
final emergencyShareActionsControllerProvider =
    EmergencyShareActionsControllerProvider._();

/// Drives "start/stop sharing with my emergency contacts" from the
/// presentation layer — same shape as `RideSessionActionsController`:
/// `state` only tracks the action itself, not the resulting share (read
/// that from [activeShareProvider]).
final class EmergencyShareActionsControllerProvider
    extends $AsyncNotifierProvider<EmergencyShareActionsController, void> {
  /// Drives "start/stop sharing with my emergency contacts" from the
  /// presentation layer — same shape as `RideSessionActionsController`:
  /// `state` only tracks the action itself, not the resulting share (read
  /// that from [activeShareProvider]).
  EmergencyShareActionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emergencyShareActionsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emergencyShareActionsControllerHash();

  @$internal
  @override
  EmergencyShareActionsController create() => EmergencyShareActionsController();
}

String _$emergencyShareActionsControllerHash() =>
    r'4585f6281e332fa3fcc24dd6359f8ee76132c903';

/// Drives "start/stop sharing with my emergency contacts" from the
/// presentation layer — same shape as `RideSessionActionsController`:
/// `state` only tracks the action itself, not the resulting share (read
/// that from [activeShareProvider]).

abstract class _$EmergencyShareActionsController extends $AsyncNotifier<void> {
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
