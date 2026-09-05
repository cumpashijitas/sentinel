import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin seam over `SupabaseClient.auth`.
///
/// Keeping this as its own interface (rather than calling `GoTrueClient`
/// directly from the repository) is what lets
/// [AuthRepositoryImpl] be unit-tested with a fake, without a network
/// connection or a running Supabase instance.
abstract interface class AuthRemoteDataSource {
  User? get currentUser;

  Stream<AuthState> get onAuthStateChange;

  Future<User> signInWithPassword({
    required String email,
    required String password,
  });

  Future<User> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signOut();
}

class SupabaseAuthRemoteDataSource implements AuthRemoteDataSource {
  SupabaseAuthRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  @override
  Future<User> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthApiException(
        'El inicio de sesión no devolvió un usuario.',
      );
    }
    return user;
  }

  @override
  Future<User> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: displayName == null ? null : {'display_name': displayName},
    );
    final user = response.user;
    if (user == null) {
      throw const AuthApiException('El registro no devolvió un usuario.');
    }
    return user;
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}
