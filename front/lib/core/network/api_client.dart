import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/session_store.dart';
import '../config/app_config.dart';
import '../errors/app_exception.dart';

part 'api_client.g.dart';

/// Thin HTTP client for the Sentinel backend (`back/`).
///
/// Every feature except the raw `/auth/*` calls (owned by [SessionStore],
/// see its doc comment) goes through this — see docs/architecture.md.
/// Attaches the current access token [SessionStore] holds as a Bearer
/// token on every request; that token was itself minted by `back/`
/// proxying Supabase Auth, so this client — and the front in general —
/// never touches a Supabase credential directly.
///
/// Mirrors the shape `SupabaseClient`'s `.from(...)` calls used to have —
/// `Map<String, dynamic>` / `List<dynamic>` in, out — so that swapping a
/// `Supabase*RemoteDataSource` for an `Http*RemoteDataSource` doesn't ripple
/// past the datasource layer.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.sessionStore,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String baseUrl;
  final SessionStore sessionStore;
  final http.Client _http;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$normalizedBase$normalizedPath');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: query.map((key, value) => MapEntry(key, '$value')),
    );
  }

  Map<String, String> get _headers {
    final token = sessionStore.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _http.get(_uri(path, query), headers: _headers));

  // Bug real encontrado en vivo (log de Render): `POST /sessions/:id/finish`,
  // `POST /emergency-shares/start`, `POST /groups/:id/leave` — cualquier
  // llamada sin cuerpo — mandaban antes `jsonEncode(null)`, o sea el texto
  // literal `"null"`, como body, igual con `Content-Type: application/json`
  // puesto. `body-parser` (Express) rechaza eso: en modo estricto (el
  // default) solo acepta un objeto o array como valor JSON de tope, así
  // que "null" — válido como JSON, pero no como tope estricto — tira
  // `SyntaxError: ... "null" is not valid JSON`, sin llegar nunca al
  // handler de la ruta. `_bodyOf` evita mandar ningún cuerpo cuando no hay
  // nada que mandar, en vez de mandar la palabra "null".
  String? _bodyOf(Object? body) => body == null ? null : jsonEncode(body);

  Future<dynamic> post(String path, {Object? body}) => _send(
    () => _http.post(_uri(path), headers: _headers, body: _bodyOf(body)),
  );

  Future<dynamic> put(String path, {Object? body}) => _send(
    () => _http.put(_uri(path), headers: _headers, body: _bodyOf(body)),
  );

  Future<dynamic> patch(String path, {Object? body}) => _send(
    () => _http.patch(_uri(path), headers: _headers, body: _bodyOf(body)),
  );

  Future<dynamic> delete(String path) =>
      _send(() => _http.delete(_uri(path), headers: _headers));

  Future<dynamic> _send(
    Future<http.Response> Function() request, {
    bool retryOn401 = true,
  }) async {
    final http.Response response;
    try {
      response = await request();
    } catch (error) {
      throw ApiException(
        'No se pudo conectar con el servidor. Verifica tu conexión.',
        cause: error,
      );
    }

    final status = response.statusCode;

    // The access token expired mid-session (SessionStore doesn't proactively
    // refresh on a timer — this is the one retry path that covers it):
    // mint a fresh one from the refresh token and replay the request once.
    if (status == 401 && retryOn401 && await sessionStore.refreshIfPossible()) {
      return _send(request, retryOn401: false);
    }

    final rawBody = response.body;
    final decoded = rawBody.isEmpty ? null : jsonDecode(rawBody);

    if (status >= 200 && status < 300) {
      return decoded;
    }

    final message =
        (decoded is Map && decoded['error'] is String)
            ? decoded['error'] as String
            : 'La operación falló (código $status).';
    throw ApiException(message, statusCode: status);
  }
}

/// Depends on [appConfigProvider] for `API_BASE_URL` and on [SessionStore]
/// for the bearer token — always reads the *current* token at request time
/// (never a stale one captured at provider creation).
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return ApiClient(
    baseUrl: config.apiBaseUrl,
    sessionStore: ref.watch(sessionStoreProvider),
  );
}
