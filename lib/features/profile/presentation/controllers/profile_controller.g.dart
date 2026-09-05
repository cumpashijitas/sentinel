// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileRemoteDataSource)
final profileRemoteDataSourceProvider = ProfileRemoteDataSourceProvider._();

final class ProfileRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          ProfileRemoteDataSource,
          ProfileRemoteDataSource,
          ProfileRemoteDataSource
        >
    with $Provider<ProfileRemoteDataSource> {
  ProfileRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ProfileRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRemoteDataSource create(Ref ref) {
    return profileRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRemoteDataSource>(value),
    );
  }
}

String _$profileRemoteDataSourceHash() =>
    r'1fa8f20b8d1050786ed1036ee1271f8dbf4b5fc3';

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'17bdafc04020b97cc3bd1fb88151b92b05f8aa70';

/// The signed-in user's own profile. Re-fetched whenever the auth session
/// changes, and invalidated by [ProfileController.save] after a
/// successful edit so the read side reflects the write immediately.
///
/// Awaits `authStateChangesProvider.future` (not `.value`) so this
/// correctly waits for the *first* auth event instead of racing it — a
/// freshly-watched stream provider has no cached `.value` yet on its very
/// first read.

@ProviderFor(currentProfile)
final currentProfileProvider = CurrentProfileProvider._();

/// The signed-in user's own profile. Re-fetched whenever the auth session
/// changes, and invalidated by [ProfileController.save] after a
/// successful edit so the read side reflects the write immediately.
///
/// Awaits `authStateChangesProvider.future` (not `.value`) so this
/// correctly waits for the *first* auth event instead of racing it — a
/// freshly-watched stream provider has no cached `.value` yet on its very
/// first read.

final class CurrentProfileProvider
    extends $FunctionalProvider<AsyncValue<Profile>, Profile, FutureOr<Profile>>
    with $FutureModifier<Profile>, $FutureProvider<Profile> {
  /// The signed-in user's own profile. Re-fetched whenever the auth session
  /// changes, and invalidated by [ProfileController.save] after a
  /// successful edit so the read side reflects the write immediately.
  ///
  /// Awaits `authStateChangesProvider.future` (not `.value`) so this
  /// correctly waits for the *first* auth event instead of racing it — a
  /// freshly-watched stream provider has no cached `.value` yet on its very
  /// first read.
  CurrentProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentProfileHash();

  @$internal
  @override
  $FutureProviderElement<Profile> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Profile> create(Ref ref) {
    return currentProfile(ref);
  }
}

String _$currentProfileHash() => r'b6014046e6094ab3529251cb3f2930442621290f';

/// Drives saving edits to the current user's profile from the presentation
/// layer. Like [AuthController], the state only tracks the *save action*
/// (loading/error/success), not the profile data itself — read that from
/// [currentProfileProvider].

@ProviderFor(ProfileController)
final profileControllerProvider = ProfileControllerProvider._();

/// Drives saving edits to the current user's profile from the presentation
/// layer. Like [AuthController], the state only tracks the *save action*
/// (loading/error/success), not the profile data itself — read that from
/// [currentProfileProvider].
final class ProfileControllerProvider
    extends $AsyncNotifierProvider<ProfileController, void> {
  /// Drives saving edits to the current user's profile from the presentation
  /// layer. Like [AuthController], the state only tracks the *save action*
  /// (loading/error/success), not the profile data itself — read that from
  /// [currentProfileProvider].
  ProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileControllerHash();

  @$internal
  @override
  ProfileController create() => ProfileController();
}

String _$profileControllerHash() => r'74bf3f7aaa635bb9bb426dc2fbd154dd21ecee02';

/// Drives saving edits to the current user's profile from the presentation
/// layer. Like [AuthController], the state only tracks the *save action*
/// (loading/error/success), not the profile data itself — read that from
/// [currentProfileProvider].

abstract class _$ProfileController extends $AsyncNotifier<void> {
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
