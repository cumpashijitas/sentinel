import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sentinel_v2/core/auth/session_store.dart';
import 'package:sentinel_v2/core/network/api_client.dart';

/// Captures every request handed to `send()` instead of actually issuing
/// it — `Client.post`/`put`/`patch`/`delete` all funnel through this in
/// `package:http`.
class _RecordingHttpClient extends http.BaseClient {
  final requests = <http.BaseRequest>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    return http.StreamedResponse(const Stream.empty(), 200);
  }
}

void main() {
  group('ApiClient', () {
    late _RecordingHttpClient httpClient;
    late ApiClient apiClient;

    setUp(() {
      httpClient = _RecordingHttpClient();
      apiClient = ApiClient(
        baseUrl: 'https://api.test',
        sessionStore: SessionStore('https://api.test'),
        httpClient: httpClient,
      );
    });

    // Bug real encontrado en vivo (log de Render): `POST /sessions/:id/
    // finish`, `POST /emergency-shares/start` y otras llamadas sin body
    // mandaban antes el texto literal "null" (de `jsonEncode(null)`) como
    // cuerpo, con `Content-Type: application/json` puesto — el
    // body-parser de Express lo rechaza (solo acepta objeto/array como
    // tope en modo estricto), y esa excepción no atrapada aparecía como
    // "Internal Server Error" del lado del front sin ninguna pista de la
    // causa real.
    test('post() without a body sends no body at all, not "null"', () async {
      await apiClient.post('/sessions/s1/finish');

      expect(httpClient.requests, hasLength(1));
      final request = httpClient.requests.single as http.Request;
      expect(request.body, isEmpty);
    });

    test('put()/patch() without a body also send no body', () async {
      await apiClient.put('/vehicles/v1');
      await apiClient.patch('/groups/g1');

      expect(httpClient.requests, hasLength(2));
      for (final req in httpClient.requests) {
        expect((req as http.Request).body, isEmpty);
      }
    });

    test('post() with a real body still encodes it as JSON', () async {
      await apiClient.post('/groups', body: {'name': 'Ruta'});

      final request = httpClient.requests.single as http.Request;
      expect(request.body, '{"name":"Ruta"}');
    });
  });
}
