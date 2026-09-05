import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin seam over `SupabaseClient` for the `accident_events` table — see
/// the note on `ProfileRemoteDataSource` for why this exists as its own
/// interface.
abstract interface class AccidentEventRemoteDataSource {
  Future<Map<String, dynamic>> insertCandidate(Map<String, dynamic> row);

  Future<void> updateStatus({required String id, required String status});

  Future<List<Map<String, dynamic>>> fetchMine(String userId);

  Future<Map<String, dynamic>> fetchById(String id);
}

class SupabaseAccidentEventRemoteDataSource
    implements AccidentEventRemoteDataSource {
  SupabaseAccidentEventRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _table = 'accident_events';

  @override
  Future<Map<String, dynamic>> insertCandidate(Map<String, dynamic> row) {
    return _client.from(_table).insert(row).select().single();
  }

  @override
  Future<void> updateStatus({required String id, required String status}) {
    final now = DateTime.now().toUtc().toIso8601String();
    return _client
        .from(_table)
        .update({
          'status': status,
          if (status == 'confirmed') 'confirmed_at': now,
          if (status == 'cancelled') 'cancelled_at': now,
        })
        .eq('id', id);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchMine(String userId) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('occurred_at', ascending: false);
    return rows;
  }

  @override
  Future<Map<String, dynamic>> fetchById(String id) {
    return _client.from(_table).select().eq('id', id).single();
  }
}
