// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRemoteDataSource)
final authRemoteDataSourceProvider = AuthRemoteDataSourceProvider._();

final class AuthRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          AuthRemoteDataSource,
          AuthRemoteDataSource,
          AuthRemoteDataSource
        >
    with $Provider<AuthRemoteDataSource> {
  AuthRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AuthRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthRemoteDataSource create(Ref ref) {
    return authRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRemoteDataSource>(value),
    );
  }
}

String _$authRemoteDataSourceHash() =>
    r'7260cca60747a3f975127710b55f07d5db4defda';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'30cfea8a2e8fac262468c7bccf4f2d3f1bf711ad';

/// Emits the signed-in [AppUser] (or `null`) whenever the Supabase session
/// changes. This is what [router.dart]'s redirect logic listens to.

@ProviderFor(authStateChanges)
final authStateChangesProvider = AuthStateChangesProvider._();

/// Emits the signed-in [AppUser] (or `null`) whenever the Supabase session
/// changes. This is what [router.dart]'s redirect logic listens to.

final class AuthStateChangesProvider
    extends
        $FunctionalProvider<AsyncValue<AppUser?>, AppUser?, Stream<AppUser?>>
    with $FutureModifier<AppUser?>, $StreamProvider<AppUser?> {
  /// Emits the signed-in [AppUser] (or `null`) whenever the Supabase session
  /// changes. This is what [router.dart]'s redirect logic listens to.
  AuthStateChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateChangesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateChangesHash();

  @$internal
  @override
  $StreamProviderElement<AppUser?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppUser?> create(Ref ref) {
    return authStateChanges(ref);
  }
}

String _$authStateChangesHash() => r'4b9b8b4440f556333925dba88bb26bd5e2b59c67';

/// Drives sign-in/sign-up/sign-out actions from the presentation layer.
///
/// The state is `AsyncValue<void>` — it only tracks whether the *action* is
/// loading/failed, not the resulting user; pages should read the resulting
/// session from [authStateChangesProvider] via the router redirect.
///
/// `keepAlive: true`, like its sibling providers above: `signIn`/`signUp`
/// are always called from a page that also `ref.watch`/`ref.listen`s this
/// same provider for its own loading/error UI (`LoginPage`/
/// `RegisterPage`), which incidentally keeps it alive across the
/// `await` — but `signOut()` (Fase "menú lateral": `HomePage`'s AppBar
/// icon, and now `AppDrawer`, reachable from every hub page) never had
/// such a watcher. Left as plain `@riverpod` (autoDispose), a signOut()
/// call from a widget that watches nothing else on this provider could
/// have this notifier disposed mid-`await` — the same "nothing keeps an
/// autoDispose provider alive across an await" trap
/// `docs/architecture.md` already documents for `.future` reads, here on
/// the write side (`state = ...` inside [signOut] throwing on a disposed
/// notifier instead). `keepAlive` removes the trap for every caller,
/// present and future, rather than requiring each one to remember to
/// `ref.listen` it defensively.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Drives sign-in/sign-up/sign-out actions from the presentation layer.
///
/// The state is `AsyncValue<void>` — it only tracks whether the *action* is
/// loading/failed, not the resulting user; pages should read the resulting
/// session from [authStateChangesProvider] via the router redirect.
///
/// `keepAlive: true`, like its sibling providers above: `signIn`/`signUp`
/// are always called from a page that also `ref.watch`/`ref.listen`s this
/// same provider for its own loading/error UI (`LoginPage`/
/// `RegisterPage`), which incidentally keeps it alive across the
/// `await` — but `signOut()` (Fase "menú lateral": `HomePage`'s AppBar
/// icon, and now `AppDrawer`, reachable from every hub page) never had
/// such a watcher. Left as plain `@riverpod` (autoDispose), a signOut()
/// call from a widget that watches nothing else on this provider could
/// have this notifier disposed mid-`await` — the same "nothing keeps an
/// autoDispose provider alive across an await" trap
/// `docs/architecture.md` already documents for `.future` reads, here on
/// the write side (`state = ...` inside [signOut] throwing on a disposed
/// notifier instead). `keepAlive` removes the trap for every caller,
/// present and future, rather than requiring each one to remember to
/// `ref.listen` it defensively.
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, void> {
  /// Drives sign-in/sign-up/sign-out actions from the presentation layer.
  ///
  /// The state is `AsyncValue<void>` — it only tracks whether the *action* is
  /// loading/failed, not the resulting user; pages should read the resulting
  /// session from [authStateChangesProvider] via the router redirect.
  ///
  /// `keepAlive: true`, like its sibling providers above: `signIn`/`signUp`
  /// are always called from a page that also `ref.watch`/`ref.listen`s this
  /// same provider for its own loading/error UI (`LoginPage`/
  /// `RegisterPage`), which incidentally keeps it alive across the
  /// `await` — but `signOut()` (Fase "menú lateral": `HomePage`'s AppBar
  /// icon, and now `AppDrawer`, reachable from every hub page) never had
  /// such a watcher. Left as plain `@riverpod` (autoDispose), a signOut()
  /// call from a widget that watches nothing else on this provider could
  /// have this notifier disposed mid-`await` — the same "nothing keeps an
  /// autoDispose provider alive across an await" trap
  /// `docs/architecture.md` already documents for `.future` reads, here on
  /// the write side (`state = ...` inside [signOut] throwing on a disposed
  /// notifier instead). `keepAlive` removes the trap for every caller,
  /// present and future, rather than requiring each one to remember to
  /// `ref.listen` it defensively.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'8f1c6ee60f05aebcca2b66766c39764406ab6642';

/// Drives sign-in/sign-up/sign-out actions from the presentation layer.
///
/// The state is `AsyncValue<void>` — it only tracks whether the *action* is
/// loading/failed, not the resulting user; pages should read the resulting
/// session from [authStateChangesProvider] via the router redirect.
///
/// `keepAlive: true`, like its sibling providers above: `signIn`/`signUp`
/// are always called from a page that also `ref.watch`/`ref.listen`s this
/// same provider for its own loading/error UI (`LoginPage`/
/// `RegisterPage`), which incidentally keeps it alive across the
/// `await` — but `signOut()` (Fase "menú lateral": `HomePage`'s AppBar
/// icon, and now `AppDrawer`, reachable from every hub page) never had
/// such a watcher. Left as plain `@riverpod` (autoDispose), a signOut()
/// call from a widget that watches nothing else on this provider could
/// have this notifier disposed mid-`await` — the same "nothing keeps an
/// autoDispose provider alive across an await" trap
/// `docs/architecture.md` already documents for `.future` reads, here on
/// the write side (`state = ...` inside [signOut] throwing on a disposed
/// notifier instead). `keepAlive` removes the trap for every caller,
/// present and future, rather than requiring each one to remember to
/// `ref.listen` it defensively.

abstract class _$AuthController extends $AsyncNotifier<void> {
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
