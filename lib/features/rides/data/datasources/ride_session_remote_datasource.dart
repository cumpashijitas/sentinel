import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin seam over `SupabaseClient` for ride sessions — table reads plus
/// the two session-management RPCs. See the note on
/// `ProfileRemoteDataSource` for why this exists as its own interface.
abstract interface class RideSessionRemoteDataSource {
  Future<Map<String, dynamic>?> fetchActiveSession(String groupId);

  Future<Map<String, dynamic>> fetchSession(String sessionId);

  /// Raw `ride_session_members` rows for [sessionId] — no profile data
  /// attached; see `fetchProfiles`.
  Future<List<Map<String, dynamic>>> fetchParticipants(String sessionId);

  /// `profiles` rows for the given ids, used to attach display
  /// name/avatar to a roster fetched via [fetchParticipants].
  Future<List<Map<String, dynamic>>> fetchProfiles(List<String> userIds);

  Future<Map<String, dynamic>> startSession({
    required String groupId,
    String? name,
  });

  Future<Map<String, dynamic>> finishSession(String sessionId);

  /// Raw `ride_session_members` rows for [userId] across every group,
  /// each with its `ride_sessions` (and that session's `ride_groups`)
  /// embedded via PostgREST's nested-select — see
  /// [RideSessionRepositoryImpl.fetchHistory] for why filtering/sorting by
  /// the embedded session's fields happens in Dart rather than here.
  Future<List<Map<String, dynamic>>> fetchHistoryRows(String userId);
}

class SupabaseRideSessionRemoteDataSource
    implements RideSessionRemoteDataSource {
  SupabaseRideSessionRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>?> fetchActiveSession(String groupId) {
    return _client
        .from('ride_sessions')
        .select()
        .eq('group_id', groupId)
        .inFilter('status', ['waiting', 'active'])
        .maybeSingle();
  }

  @override
  Future<Map<String, dynamic>> fetchSession(String sessionId) {
    return _client.from('ride_sessions').select().eq('id', sessionId).single();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchParticipants(String sessionId) async {
    final rows = await _client
        .from('ride_session_members')
        .select()
        .eq('session_id', sessionId)
        .eq('status', 'active')
        .order('joined_at');
    return rows;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchProfiles(List<String> userIds) async {
    if (userIds.isEmpty) return const [];
    final rows = await _client
        .from('profiles')
        .select()
        .inFilter('id', userIds);
    return rows;
  }

  @override
  Future<Map<String, dynamic>> startSession({
    required String groupId,
    String? name,
  }) async {
    return _client.rpc<Map<String, dynamic>>(
      'start_ride_session',
      params: {'p_group_id': groupId, 'p_name': name},
    );
  }

  @override
  Future<Map<String, dynamic>> finishSession(String sessionId) async {
    return _client.rpc<Map<String, dynamic>>(
      'finish_ride_session',
      params: {'p_session_id': sessionId},
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchHistoryRows(String userId) async {
    final rows = await _client
        .from('ride_session_members')
        .select('session_id, ride_sessions(*, ride_groups(name))')
        .eq('user_id', userId);
    return rows;
  }
}
