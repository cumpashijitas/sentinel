import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/app_exception.dart' as core;
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  AppUser? get currentUser => _toAppUser(_remoteDataSource.currentUser);

  @override
  Stream<AppUser?> get authStateChanges => _remoteDataSource.onAuthStateChange
      .map((state) => _toAppUser(state.session?.user));

  @override
  Future<AppUser> signInWithPassword({
    required String email,
    required String password,
  }) => _guard(() async {
    final user = await _remoteDataSource.signInWithPassword(
      email: email,
      password: password,
    );
    return _toAppUser(user)!;
  });

  @override
  Future<AppUser> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
  }) => _guard(() async {
    final user = await _remoteDataSource.signUpWithPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
    return _toAppUser(user)!;
  });

  @override
  Future<void> signOut() => _guard(_remoteDataSource.signOut);

  static AppUser? _toAppUser(supabase.User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String?,
    );
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on supabase.AuthException catch (error) {
      throw core.AuthException(_messageFor(error), cause: error);
    } catch (error) {
      throw core.AuthException(
        'No se pudo completar la operación de autenticación.',
        cause: error,
      );
    }
  }

  static String _messageFor(supabase.AuthException error) {
    switch (error.code) {
      case 'invalid_credentials':
        return 'Correo o contraseña incorrectos.';
      case 'user_already_exists':
      case 'email_exists':
        return 'Ya existe una cuenta con ese correo.';
      case 'weak_password':
        return 'La contraseña es demasiado débil.';
      default:
        return error.message;
    }
  }
}
