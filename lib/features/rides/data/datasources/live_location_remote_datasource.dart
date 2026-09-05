import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin seam over `SupabaseClient` for `live_locations`/`location_history`
/// — table reads/writes plus the Realtime subscription. See the note on
/// `ProfileRemoteDataSource` for why this exists as its own interface.
abstract interface class LiveLocationRemoteDataSource {
  /// The current snapshot of every row for [sessionId] — used to seed
  /// state before the Realtime stream starts delivering changes.
  Future<List<Map<String, dynamic>>> fetchCurrentLocations(String sessionId);

  /// Emits the changed row (`newRecord`) for every insert/update to
  /// `live_locations` scoped to [sessionId]. The underlying Realtime
  /// channel is created when the returned stream gets its first listener
  /// and torn down when the last one cancels — never call this and ignore
  /// the result without also cancelling the subscription, or the channel
  /// leaks for the lifetime of the app.
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
}

class SupabaseLiveLocationRemoteDataSource
    implements LiveLocationRemoteDataSource {
  SupabaseLiveLocationRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> fetchCurrentLocations(
    String sessionId,
  ) async {
    final rows = await _client
        .from('live_locations')
        .select()
        .eq('session_id', sessionId);
    return rows;
  }

  @override
  Stream<Map<String, dynamic>> watchLocationChanges(String sessionId) {
    late final RealtimeChannel channel;
    late final StreamController<Map<String, dynamic>> controller;

    void forward(PostgresChangePayload payload) =>
        controller.add(payload.newRecord);

    controller = StreamController<Map<String, dynamic>>.broadcast(
      onListen: () {
        channel = _client
            .channel('live_locations:$sessionId')
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'live_locations',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'session_id',
                value: sessionId,
              ),
              callback: forward,
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.update,
              schema: 'public',
              table: 'live_locations',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'session_id',
                value: sessionId,
              ),
              callback: forward,
            )
            .subscribe();
      },
      onCancel: () {
        // Releases the channel as soon as the last listener goes away —
        // e.g. leaving the ride-map screen — so a stale subscription never
        // outlives the page that opened it. Closing the controller too:
        // a fresh one is created next call, this instance has no more use.
        unawaited(_client.removeChannel(channel));
        unawaited(controller.close());
      },
    );

    return controller.stream;
  }

  @override
  Future<void> upsertMyLocation({
    required String sessionId,
    required String userId,
    required Map<String, dynamic> fixJson,
  }) {
    return _client.from('live_locations').upsert({
      'session_id': sessionId,
      'user_id': userId,
      ...fixJson,
    }, onConflict: 'session_id,user_id');
  }

  @override
  Future<void> recordHistory({
    required String sessionId,
    required String userId,
    required Map<String, dynamic> fixJson,
  }) {
    // `location_history` has no `battery_level` column (that's tracked only
    // on the current-position row in `live_locations`) — PostgREST rejects
    // an insert payload containing a key with no matching column, so it
    // must be stripped from `LocationFix.toJson()`'s output before this
    // insert, not just omitted from the table.
    final row = Map<String, dynamic>.of(fixJson)..remove('battery_level');
    return _client.from('location_history').insert({
      'session_id': sessionId,
      'user_id': userId,
      ...row,
    });
  }
}
