import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/session_store.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_controller.g.dart';

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return SessionStoreAuthRemoteDataSource(ref.watch(sessionStoreProvider));
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
}

/// Emits the signed-in [AppUser] (or `null`) whenever the Supabase session
/// changes. This is what [router.dart]'s redirect logic listens to.
@Riverpod(keepAlive: true)
Stream<AppUser?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

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
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signInWithPassword(email: email, password: password);
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signUpWithPassword(
            email: email,
            password: password,
            displayName: displayName,
          );
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
  }
}
