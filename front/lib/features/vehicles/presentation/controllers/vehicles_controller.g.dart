// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicles_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(vehicleRemoteDataSource)
final vehicleRemoteDataSourceProvider = VehicleRemoteDataSourceProvider._();

final class VehicleRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          VehicleRemoteDataSource,
          VehicleRemoteDataSource,
          VehicleRemoteDataSource
        >
    with $Provider<VehicleRemoteDataSource> {
  VehicleRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<VehicleRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VehicleRemoteDataSource create(Ref ref) {
    return vehicleRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VehicleRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VehicleRemoteDataSource>(value),
    );
  }
}

String _$vehicleRemoteDataSourceHash() =>
    r'c5aac90deea80b463403c2a96fc0db1de383fc67';

@ProviderFor(vehicleRepository)
final vehicleRepositoryProvider = VehicleRepositoryProvider._();

final class VehicleRepositoryProvider
    extends
        $FunctionalProvider<
          VehicleRepository,
          VehicleRepository,
          VehicleRepository
        >
    with $Provider<VehicleRepository> {
  VehicleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleRepositoryHash();

  @$internal
  @override
  $ProviderElement<VehicleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VehicleRepository create(Ref ref) {
    return vehicleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VehicleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VehicleRepository>(value),
    );
  }
}

String _$vehicleRepositoryHash() => r'bde3f56aaeacba9a469e98cd68c8a939f062261a';

/// The signed-in user's own vehicles. Invalidated by
/// [VehicleFormController] after any successful create/update/delete.

@ProviderFor(vehicles)
final vehiclesProvider = VehiclesProvider._();

/// The signed-in user's own vehicles. Invalidated by
/// [VehicleFormController] after any successful create/update/delete.

final class VehiclesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Vehicle>>,
          List<Vehicle>,
          FutureOr<List<Vehicle>>
        >
    with $FutureModifier<List<Vehicle>>, $FutureProvider<List<Vehicle>> {
  /// The signed-in user's own vehicles. Invalidated by
  /// [VehicleFormController] after any successful create/update/delete.
  VehiclesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehiclesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehiclesHash();

  @$internal
  @override
  $FutureProviderElement<List<Vehicle>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Vehicle>> create(Ref ref) {
    return vehicles(ref);
  }
}

String _$vehiclesHash() => r'1a6497ce14d8e14f937cdda2d2674a4bd2f52c48';

/// Drives create/update/delete for a single vehicle. Same shape as
/// [ProfileController]: the state is only the *action's* outcome
/// (loading/error/success), not the list itself — read that from
/// [vehiclesProvider].

@ProviderFor(VehicleFormController)
final vehicleFormControllerProvider = VehicleFormControllerProvider._();

/// Drives create/update/delete for a single vehicle. Same shape as
/// [ProfileController]: the state is only the *action's* outcome
/// (loading/error/success), not the list itself — read that from
/// [vehiclesProvider].
final class VehicleFormControllerProvider
    extends $AsyncNotifierProvider<VehicleFormController, void> {
  /// Drives create/update/delete for a single vehicle. Same shape as
  /// [ProfileController]: the state is only the *action's* outcome
  /// (loading/error/success), not the list itself — read that from
  /// [vehiclesProvider].
  VehicleFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleFormControllerHash();

  @$internal
  @override
  VehicleFormController create() => VehicleFormController();
}

String _$vehicleFormControllerHash() =>
    r'2ab77da0640a629d8ceb01224c6ae4dd652dd32c';

/// Drives create/update/delete for a single vehicle. Same shape as
/// [ProfileController]: the state is only the *action's* outcome
/// (loading/error/success), not the list itself — read that from
/// [vehiclesProvider].

abstract class _$VehicleFormController extends $AsyncNotifier<void> {
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
