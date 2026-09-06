import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/entities/app_user.dart';
import '../config/app_config.dart';
import '../errors/app_exception.dart';

part 'session_store.g.dart';

/// The front holds no Supabase credentials of its own — see
/// docs/architecture.md. [SessionStore] is the ONLY place in `front/` that
/// ever calls `back/`'s `/auth/*` endpoints (register/login/refresh/logout,
/// `back/src/routes/auth.routes.ts`), which are themselves the only part of
/// `back/` that talks to Supabase Auth. Everything else in the app gets a
/// short-lived access token from here — via [ApiClient], see
/// `core/network/api_client.dart` — never a Supabase key.
///
/// Uses its own bare `http.Client` rather than [ApiClient]: `/auth/*` needs
/// no bearer token (that's the whole point — it's how one gets minted), and
/// [ApiClient] itself asks *this* class for the token to attach, so sharing
/// one would be circular.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final AppUser user;

  bool get isExpiringSoon =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 30)));
}

class SessionStore {
  SessionStore(this._baseUrl, {http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  static const _refreshTokenKey = 'sentinel.refresh_token';

  final String _baseUrl;
  final http.Client _http;

  AuthSession? _session;
  final _controller = StreamController<AppUser?>.broadcast();

  AppUser? get currentUser => _session?.user;
  String? get accessToken => _session?.accessToken;

  /// Emits the current user (or `null`) on every sign-in/sign-up/sign-out/
  /// refresh — what `app/router.dart`'s redirect logic listens to, same
  /// contract `AuthRepository.authStateChanges` always had.
  Stream<AppUser?> get authStateChanges => _controller.stream;

  /// Called once from `bootstrap()`, before `runApp()`: tries to resume a
  /// previous session from the refresh token persisted on-device (the
  /// access token itself is never persisted — it's short-lived and cheap
  /// to re-mint). Silently leaves the user signed out if there is none, or
  /// it's no longer valid; never throws.
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshTokenKey);
    if (refreshToken == null) return;
    try {
      final session = await _request('/auth/refresh', {
        'refresh_token': refreshToken,
      });
      await _setSession(session);
    } catch (_) {
      await prefs.remove(_refreshTokenKey);
    }
  }

  Future<AppUser> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final session = await _request('/auth/login', {
      'email': email,
      'password': password,
    });
    await _setSession(session);
    return session.user;
  }

  Future<AppUser> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final session = await _request('/auth/register', {
      'email': email,
      'password': password,
      'display_name': ?displayName,
    });
    await _setSession(session);
    return session.user;
  }

  Future<void> signOut() async {
    final token = _session?.accessToken;
    await _setSession(null);
    if (token == null) return;
    try {
      await _http.post(
        Uri.parse('$_baseUrl/auth/logout'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (_) {
      // Best-effort — the local session is already cleared either way.
    }
  }

  /// Called by [ApiClient] when a request comes back 401: tries to mint a
  /// fresh access token from the refresh token. Returns whether it worked
  /// — `false` means the session is genuinely gone (signs out as a side
  /// effect, same as an explicit [signOut]'s local half).
  Future<bool> refreshIfPossible() async {
    final refreshToken = _session?.refreshToken;
    if (refreshToken == null) return false;
    try {
      final session = await _request('/auth/refresh', {
        'refresh_token': refreshToken,
      });
      await _setSession(session);
      return true;
    } catch (_) {
      await _setSession(null);
      return false;
    }
  }

  Future<AuthSession> _request(String path, Map<String, dynamic> body) async {
    final http.Response response;
    try {
      response = await _http.post(
        Uri.parse('$_baseUrl$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (error) {
      throw ApiException(
        'No se pudo conectar con el servidor. Verifica tu conexión.',
        cause: error,
      );
    }

    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          (decoded is Map && decoded['error'] is String)
              ? decoded['error'] as String
              : 'No se pudo completar la operación de autenticación.';
      throw ApiException(message, statusCode: response.statusCode);
    }

    final map = decoded as Map<String, dynamic>;
    final userJson = map['user'] as Map<String, dynamic>;
    final metadata = userJson['user_metadata'] as Map<String, dynamic>?;
    return AuthSession(
      accessToken: map['access_token'] as String,
      refreshToken: map['refresh_token'] as String,
      expiresAt: DateTime.now().add(
        Duration(seconds: map['expires_in'] as int? ?? 3600),
      ),
      user: AppUser(
        id: userJson['id'] as String,
        email: userJson['email'] as String? ?? '',
        displayName: metadata?['display_name'] as String?,
      ),
    );
  }

  Future<void> _setSession(AuthSession? session) async {
    _session = session;
    final prefs = await SharedPreferences.getInstance();
    if (session == null) {
      await prefs.remove(_refreshTokenKey);
    } else {
      await prefs.setString(_refreshTokenKey, session.refreshToken);
    }
    _controller.add(session?.user);
  }
}

@Riverpod(keepAlive: true)
SessionStore sessionStore(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return SessionStore(config.apiBaseUrl);
}
