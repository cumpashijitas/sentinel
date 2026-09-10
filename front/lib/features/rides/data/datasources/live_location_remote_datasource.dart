import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/network/api_client.dart';

/// Thin seam over [ApiClient] + a WebSocket for `live_locations`/
/// `location_history`. See the note on `ProfileRemoteDataSource` for why
/// this exists as its own interface.
///
/// Was `SupabaseLiveLocationRemoteDataSource`, reading via a Supabase
/// Realtime `postgres_changes` subscription the front opened directly
/// against Supabase. The front holds no Supabase credential anymore (see
/// docs/architecture.md), so reads now go through `back/`'s own WebSocket
/// relay instead (`back/src/ws/location-hub.ts`) — same idea (push new
/// positions to everyone watching a session), just relayed by this backend
/// instead of by Supabase directly. **Writes** ([upsertMyLocation],
/// [recordHistory]) already went through the backend as of the previous
/// migration step and are unchanged here.
abstract interface class LiveLocationRemoteDataSource {
  /// The current snapshot of every row for [sessionId] — used to seed
  /// state before the live stream starts delivering changes.
  Future<List<Map<String, dynamic>>> fetchCurrentLocations(String sessionId);

  /// Emits every row the hub pushes for [sessionId] after the initial
  /// snapshot. The underlying WebSocket is opened when the returned stream
  /// gets its first listener and closed when the last one cancels — never
  /// call this and ignore the result without also cancelling the
  /// subscription, or the socket leaks for the lifetime of the app.
  Stream<Map<String, dynamic>> watchLocationChanges(String sessionId);

  Future<void> upsertMyLocation({
    required String sessionId,
    required String userId,
    required Map<String, dynamic> fixJson,
  });

  Future<void> recordHistory({
    required String sessionId,
    required String userId,
    required Map<String, dynamic> fixJson,
  });

  /// El camino recorrido durante [sessionId] — pedido explícito en vivo
  /// ("ver la ruta en el mapa"). Filas ya ordenadas por hora, ver
  /// `ride.service.ts::fetchLocationHistory`.
  Future<List<Map<String, dynamic>>> fetchHistory(String sessionId);
}

class HttpLiveLocationRemoteDataSource implements LiveLocationRemoteDataSource {
  HttpLiveLocationRemoteDataSource(this._api);

  final ApiClient _api;

  Uri _wsUri(String sessionId) {
    final http = Uri.parse(_api.baseUrl);
    final wsScheme = http.scheme == 'https' ? 'wss' : 'ws';
    final token = _api.sessionStore.accessToken ?? '';
    return http.replace(
      scheme: wsScheme,
      path: '/ws/sessions/$sessionId/locations',
      queryParameters: {'token': token},
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchCurrentLocations(
    String sessionId,
  ) async {
    // A short-lived connection just for the hub's first message (always a
    // `snapshot`, see location-hub.ts's `onConnect`) — kept separate from
    // [watchLocationChanges]'s long-lived one so this method's Future-based
    // contract (matching the old Supabase `SELECT`) doesn't change shape.
    final channel = WebSocketChannel.connect(_wsUri(sessionId));
    try {
      final raw = await channel.stream.first.timeout(const Duration(seconds: 10));
      final message = jsonDecode(raw as String) as Map<String, dynamic>;
      final rows = message['rows'] as List? ?? const [];
      return rows.cast<Map<String, dynamic>>();
    } finally {
      unawaited(channel.sink.close());
    }
  }

  @override
  Stream<Map<String, dynamic>> watchLocationChanges(String sessionId) {
    late final StreamController<Map<String, dynamic>> controller;
    WebSocketChannel? channel;
    StreamSubscription<dynamic>? subscription;
    Timer? reconnectTimer;
    var backoff = _initialReconnectDelay;
    var disposed = false;

    // Bug real para el caso de uso de esta app (compartir ubicación
    // manejando moto): antes, CUALQUIER corte de este WebSocket — un
    // túnel, un cambio de torre celular, el backend reiniciándose —
    // llegaba acá como un error fatal (`controller.addError`), que
    // `sessionMemberLocationsProvider` convertía en `AsyncError` y
    // `RideMapPage` mostraba como pantalla de error en vez del mapa. Sin
    // ningún reintento, los dos dejaban de verse hasta cerrar y volver a
    // abrir la pantalla — justo el peor momento, en movimiento. Ahora
    // reconecta solo, en silencio, con backoff creciente (2s→4s→…→15s,
    // tope) — el error nunca llega al stream público.
    // Declaradas como variables (no como function declarations planas)
    // porque se necesitan mutuamente: `connect` programa un reintento vía
    // `scheduleReconnect`, y `scheduleReconnect` vuelve a llamar a
    // `connect` — Dart no permite que una function declaration comun
    // referencie otra declarada más abajo en el mismo bloque.
    late final void Function() connect;
    late final void Function() scheduleReconnect;

    connect = () {
      if (disposed) return;
      try {
        final ch = WebSocketChannel.connect(_wsUri(sessionId));
        channel = ch;
        subscription = ch.stream.listen(
          (raw) {
            backoff = _initialReconnectDelay;
            final message = jsonDecode(raw as String) as Map<String, dynamic>;
            // The snapshot this connection also receives on open is
            // ignored here — [fetchCurrentLocations] already covers the
            // initial read via its own short-lived connection.
            if (message['type'] == 'update') {
              controller.add(message['row'] as Map<String, dynamic>);
            }
          },
          onError: (Object _, StackTrace _) => scheduleReconnect(),
          onDone: scheduleReconnect,
          cancelOnError: true,
        );
      } on Object {
        scheduleReconnect();
      }
    };

    scheduleReconnect = () {
      if (disposed) return;
      reconnectTimer?.cancel();
      reconnectTimer = Timer(backoff, connect);
      backoff = backoff * 2 > _maxReconnectDelay ? _maxReconnectDelay : backoff * 2;
    };

    controller = StreamController<Map<String, dynamic>>.broadcast(
      onListen: connect,
      onCancel: () {
        disposed = true;
        reconnectTimer?.cancel();
        unawaited(subscription?.cancel());
        unawaited(channel?.sink.close());
        unawaited(controller.close());
      },
    );

    return controller.stream;
  }

  static const _initialReconnectDelay = Duration(seconds: 2);
  static const _maxReconnectDelay = Duration(seconds: 15);

  @override
  Future<void> upsertMyLocation({
    required String sessionId,
    required String userId,
    required Map<String, dynamic> fixJson,
  }) async {
    await _api.post('/sessions/$sessionId/location', body: fixJson);
  }

  @override
  Future<void> recordHistory({
    required String sessionId,
    required String userId,
    required Map<String, dynamic> fixJson,
  }) async {
    // `location_history` has no `battery_level` column (that's tracked only
    // on the current-position row in `live_locations`).
    final row = Map<String, dynamic>.of(fixJson)..remove('battery_level');
    await _api.post('/sessions/$sessionId/location/history', body: row);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchHistory(String sessionId) async {
    final response = await _api.get('/sessions/$sessionId/location/history');
    return (response as List).cast<Map<String, dynamic>>();
  }
}
