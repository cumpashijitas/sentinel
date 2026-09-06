import '../../../../core/auth/session_store.dart';
import '../../domain/entities/app_user.dart';

/// Thin seam over [SessionStore]. Kept as its own interface (rather than
/// depending on [SessionStore] directly from [AuthRepositoryImpl]) for the
/// same reason as `ProfileRemoteDataSource`: it lets the repository be
/// unit-tested with a fake, without a network connection or a running
/// backend.
///
/// Was `SupabaseAuthRemoteDataSource` wrapping `SupabaseClient.auth`
/// directly — the front no longer holds any Supabase credential (see
/// docs/architecture.md), so this now wraps [SessionStore], which talks to
/// `back/`'s `/auth/*` endpoints instead.
abstract interface class AuthRemoteDataSource {
  AppUser? get currentUser;

  Stream<AppUser?> get onAuthStateChange;

  Future<AppUser> signInWithPassword({
    required String email,
    required String password,
  });

  Future<AppUser> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signOut();
}

class SessionStoreAuthRemoteDataSource implements AuthRemoteDataSource {
  SessionStoreAuthRemoteDataSource(this._sessionStore);

  final SessionStore _sessionStore;

  @override
  AppUser? get currentUser => _sessionStore.currentUser;

  @override
  Stream<AppUser?> get onAuthStateChange => _sessionStore.authStateChanges;

  @override
  Future<AppUser> signInWithPassword({
    required String email,
    required String password,
  }) => _sessionStore.signInWithPassword(email: email, password: password);

  @override
  Future<AppUser> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
  }) => _sessionStore.signUpWithPassword(
    email: email,
    password: password,
    displayName: displayName,
  );

  @override
  Future<void> signOut() => _sessionStore.signOut();
}
