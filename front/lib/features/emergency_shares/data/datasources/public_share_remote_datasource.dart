import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

/// Thin seam over plain HTTP/WebSocket for `back/`'s public
/// `/public/emergency-shares/:token` route and its matching WS relay —
/// **no [ApiClient], no bearer token, no Supabase credential of any
/// kind**: this is the one place in the whole front that talks to the
/// backend as a fully anonymous caller, on purpose (it's what makes the
/// shared link work without an account — see docs/architecture.md).
abstract interface class PublicShareRemoteDataSource {
  Future<Map<String, dynamic>> fetchByToken(String token);

  /// Emits every `row` the hub pushes for [token]. Mirrors
  /// `LiveLocationRemoteDataSource.watchLocationChanges`'s "open on first
  /// listen, close on last cancel" contract.
  Stream<Map<String, dynamic>> watchByToken(String token);

  Future<List<Map<String, dynamic>>> fetchHistory(String token);
}

class HttpPublicShareRemoteDataSource implements PublicShareRemoteDataSource {
  HttpPublicShareRemoteDataSource(this._baseUrl);

  final String _baseUrl;

  Uri _httpUri(String token) =>
      Uri.parse('$_baseUrl/public/emergency-shares/$token');

  Uri _wsUri(String token) {
    final http = Uri.parse(_baseUrl);
    final wsScheme = http.scheme == 'https' ? 'wss' : 'ws';
    return http.replace(
      scheme: wsScheme,
      path: '/ws/public/emergency-shares/$token/locations',
    );
  }

  @override
  Future<Map<String, dynamic>> fetchByToken(String token) async {
    final response = await http.get(_httpUri(token));
    if (response.statusCode != 200) {
      throw Exception('share not found (${response.statusCode})');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchHistory(String token) async {
    final uri = Uri.parse('$_baseUrl/public/emergency-shares/$token/history');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('share history not found (${response.statusCode})');
    }
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  @override
  Stream<Map<String, dynamic>> watchByToken(String token) {
    late final WebSocketChannel channel;
    late final StreamController<Map<String, dynamic>> controller;
    StreamSubscription<dynamic>? subscription;

    controller = StreamController<Map<String, dynamic>>.broadcast(
      onListen: () {
        channel = WebSocketChannel.connect(_wsUri(token));
        subscription = channel.stream.listen(
          (raw) {
            final message = jsonDecode(raw as String) as Map<String, dynamic>;
            final row = message['row'];
            if (row is Map<String, dynamic>) controller.add(row);
          },
          onError: controller.addError,
        );
      },
      onCancel: () {
        unawaited(subscription?.cancel());
        unawaited(channel.sink.close());
        unawaited(controller.close());
      },
    );

    return controller.stream;
  }
}
