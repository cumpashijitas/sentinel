import '../../../../core/network/api_client.dart';

/// Thin seam over [ApiClient] for ride sessions — table reads plus the two
/// session-management operations. See the note on `ProfileRemoteDataSource`
/// for why this exists as its own interface.
///
/// Was `SupabaseRideSessionRemoteDataSource` calling `supabase.rpc(...)`
/// directly — `start_ride_session`/`finish_ride_session` moved to
/// `back/src/services/ride.service.ts` (see docs/architecture.md); this
/// implementation calls that backend over HTTP instead. The interface and
/// every caller above it (`RideSessionRepositoryImpl`) are unchanged.
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

  /// Rows shaped like `{session_id, ride_sessions: {...*, ride_groups: {name}}}`
  /// for every session [userId] has ever participated in — see
  /// [RideSessionRepositoryImpl.fetchHistory] for why filtering/sorting by
  /// the embedded session's fields happens in Dart rather than here.
  Future<List<Map<String, dynamic>>> fetchHistoryRows(String userId);
}

class HttpRideSessionRemoteDataSource implements RideSessionRemoteDataSource {
  HttpRideSessionRemoteDataSource(this._api);

  final ApiClient _api;

  @override
  Future<Map<String, dynamic>?> fetchActiveSession(String groupId) async {
    final response = await _api.get('/groups/$groupId/sessions/active');
    return response as Map<String, dynamic>?;
  }

  @override
  Future<Map<String, dynamic>> fetchSession(String sessionId) async {
    final response = await _api.get('/sessions/$sessionId');
    return response as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchParticipants(String sessionId) async {
    final response = await _api.get('/sessions/$sessionId/participants');
    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchProfiles(List<String> userIds) async {
    if (userIds.isEmpty) return const [];
    final response = await _api.get('/profiles', query: {'ids': userIds.join(',')});
    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> startSession({
    required String groupId,
    String? name,
  }) async {
    final response = await _api.post(
      '/groups/$groupId/sessions/start',
      body: {'name': name},
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> finishSession(String sessionId) async {
    final response = await _api.post('/sessions/$sessionId/finish');
    return response as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchHistoryRows(String userId) async {
    final response = await _api.get('/rides/history');
    return (response as List).cast<Map<String, dynamic>>();
  }
}
