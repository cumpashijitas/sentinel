// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_contacts_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(emergencyContactRemoteDataSource)
final emergencyContactRemoteDataSourceProvider =
    EmergencyContactRemoteDataSourceProvider._();

final class EmergencyContactRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          EmergencyContactRemoteDataSource,
          EmergencyContactRemoteDataSource,
          EmergencyContactRemoteDataSource
        >
    with $Provider<EmergencyContactRemoteDataSource> {
  EmergencyContactRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emergencyContactRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emergencyContactRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<EmergencyContactRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EmergencyContactRemoteDataSource create(Ref ref) {
    return emergencyContactRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmergencyContactRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmergencyContactRemoteDataSource>(
        value,
      ),
    );
  }
}

String _$emergencyContactRemoteDataSourceHash() =>
    r'bdb1f9a9e446c733c05b150e4f3dc493bf2095b1';

@ProviderFor(emergencyContactRepository)
final emergencyContactRepositoryProvider =
    EmergencyContactRepositoryProvider._();

final class EmergencyContactRepositoryProvider
    extends
        $FunctionalProvider<
          EmergencyContactRepository,
          EmergencyContactRepository,
          EmergencyContactRepository
        >
    with $Provider<EmergencyContactRepository> {
  EmergencyContactRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emergencyContactRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emergencyContactRepositoryHash();

  @$internal
  @override
  $ProviderElement<EmergencyContactRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EmergencyContactRepository create(Ref ref) {
    return emergencyContactRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmergencyContactRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmergencyContactRepository>(value),
    );
  }
}

String _$emergencyContactRepositoryHash() =>
    r'751d2f6ece88c1a73e268e0664a747b4491ad1e9';

/// The signed-in user's own emergency contacts. Invalidated by
/// [EmergencyContactFormController] after any successful
/// create/update/delete.

@ProviderFor(emergencyContacts)
final emergencyContactsProvider = EmergencyContactsProvider._();

/// The signed-in user's own emergency contacts. Invalidated by
/// [EmergencyContactFormController] after any successful
/// create/update/delete.

final class EmergencyContactsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EmergencyContact>>,
          List<EmergencyContact>,
          FutureOr<List<EmergencyContact>>
        >
    with
        $FutureModifier<List<EmergencyContact>>,
        $FutureProvider<List<EmergencyContact>> {
  /// The signed-in user's own emergency contacts. Invalidated by
  /// [EmergencyContactFormController] after any successful
  /// create/update/delete.
  EmergencyContactsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emergencyContactsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emergencyContactsHash();

  @$internal
  @override
  $FutureProviderElement<List<EmergencyContact>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EmergencyContact>> create(Ref ref) {
    return emergencyContacts(ref);
  }
}

String _$emergencyContactsHash() => r'2ed0aba7f7e26e87679a44481a777f0257653f84';

/// Drives create/update/delete for a single emergency contact. Same shape
/// as [VehicleFormController]: the state is only the *action's* outcome,
/// not the list — read that from [emergencyContactsProvider].

@ProviderFor(EmergencyContactFormController)
final emergencyContactFormControllerProvider =
    EmergencyContactFormControllerProvider._();

/// Drives create/update/delete for a single emergency contact. Same shape
/// as [VehicleFormController]: the state is only the *action's* outcome,
/// not the list — read that from [emergencyContactsProvider].
final class EmergencyContactFormControllerProvider
    extends $AsyncNotifierProvider<EmergencyContactFormController, void> {
  /// Drives create/update/delete for a single emergency contact. Same shape
  /// as [VehicleFormController]: the state is only the *action's* outcome,
  /// not the list — read that from [emergencyContactsProvider].
  EmergencyContactFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emergencyContactFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emergencyContactFormControllerHash();

  @$internal
  @override
  EmergencyContactFormController create() => EmergencyContactFormController();
}

String _$emergencyContactFormControllerHash() =>
    r'e8ee67bd96999cfd7cc9af282a4cb603a70da804';

/// Drives create/update/delete for a single emergency contact. Same shape
/// as [VehicleFormController]: the state is only the *action's* outcome,
/// not the list — read that from [emergencyContactsProvider].

abstract class _$EmergencyContactFormController extends $AsyncNotifier<void> {
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
