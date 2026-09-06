import '../entities/app_user.dart';

/// Backend-agnostic contract for authentication.
///
/// The presentation layer (and tests) depend only on this interface; the
/// concrete implementation talks to Supabase Auth behind it.
abstract interface class AuthRepository {
  /// The currently signed-in user, or `null` if there is no active session.
  AppUser? get currentUser;

  /// Emits the current user (or `null`) whenever the session changes:
  /// sign-in, sign-out, token refresh, or initial restore.
  Stream<AppUser?> get authStateChanges;

  /// Signs in with email/password. Throws [AuthException] on failure.
  Future<AppUser> signInWithPassword({
    required String email,
    required String password,
  });

  /// Creates a new account with email/password. Throws [AuthException] on
  /// failure (e.g. email already registered, weak password).
  Future<AppUser> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Signs out the current user, if any.
  Future<void> signOut();
}
