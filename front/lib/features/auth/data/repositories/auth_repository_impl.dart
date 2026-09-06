import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  AppUser? get currentUser => _remoteDataSource.currentUser;

  @override
  Stream<AppUser?> get authStateChanges =>
      _remoteDataSource.onAuthStateChange;

  @override
  Future<AppUser> signInWithPassword({
    required String email,
    required String password,
  }) => _guard(
    () => _remoteDataSource.signInWithPassword(email: email, password: password),
  );

  @override
  Future<AppUser> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
  }) => _guard(
    () => _remoteDataSource.signUpWithPassword(
      email: email,
      password: password,
      displayName: displayName,
    ),
  );

  @override
  Future<void> signOut() => _guard(_remoteDataSource.signOut);

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (error) {
      throw AuthException(_messageFor(error), cause: error);
    } catch (error) {
      throw AuthException(
        'No se pudo completar la operación de autenticación.',
        cause: error,
      );
    }
  }

  /// `back/`'s `/auth/*` routes forward Supabase Auth's own error, prefixed
  /// with its error code as `"<code>: <message>"` when Supabase gives one
  /// (`auth.routes.ts`) — match on that prefix the same way this used to
  /// match on `AuthException.code` directly against Supabase.
  static String _messageFor(ApiException error) {
    final message = error.message;
    if (message.startsWith('invalid_credentials') ||
        message.startsWith('invalid_grant')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (message.startsWith('user_already_exists') ||
        message.startsWith('email_exists')) {
      return 'Ya existe una cuenta con ese correo.';
    }
    if (message.startsWith('weak_password')) {
      return 'La contraseña es demasiado débil.';
    }
    if (message.startsWith('signup_needs_confirmation')) {
      return 'Revisa tu correo para confirmar la cuenta antes de iniciar sesión.';
    }
    return message;
  }
}
