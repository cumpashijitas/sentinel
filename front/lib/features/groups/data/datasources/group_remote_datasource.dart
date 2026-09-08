import '../../../../core/network/api_client.dart';

/// Thin seam over [ApiClient] for ride groups — table reads plus the three
/// group-management operations. See the note on `ProfileRemoteDataSource`
/// for why this exists as its own interface.
///
/// Was `SupabaseGroupRemoteDataSource` calling `supabase.rpc(...)` directly
/// — `create_ride_group`/`join_group_by_code`/`leave_group` moved to
/// `back/src/services/group.service.ts` (see docs/architecture.md); this
/// implementation calls that backend over HTTP instead. The interface and
/// every caller above it (`GroupRepositoryImpl`) are unchanged.
abstract interface class GroupRemoteDataSource {
  /// Groups the caller belongs to.
  Future<List<Map<String, dynamic>>> fetchMyGroups();

  Future<Map<String, dynamic>> fetchGroup(String groupId);

  /// Raw `ride_group_members` rows for [groupId] — no profile data
  /// attached; see `fetchProfiles`.
  Future<List<Map<String, dynamic>>> fetchMembers(String groupId);

  /// `profiles` rows for the given ids, used to attach display
  /// name/avatar to a member roster fetched via [fetchMembers].
  Future<List<Map<String, dynamic>>> fetchProfiles(List<String> userIds);

  Future<Map<String, dynamic>> createGroup({
    required String name,
    String? description,
  });

  Future<Map<String, dynamic>> updateGroup({
    required String groupId,
    required String name,
    String? description,
  });

  /// Returns the joined group's id.
  Future<String> joinGroupByCode(String inviteCode);

  Future<void> leaveGroup(String groupId);

  Future<Map<String, dynamic>> setMemberRole({
    required String groupId,
    required String targetUserId,
    required String role,
  });

  Future<void> removeMember({
    required String groupId,
    required String targetUserId,
  });

  Future<Map<String, dynamic>> setPinnedNote({
    required String groupId,
    String? note,
  });
}

class HttpGroupRemoteDataSource implements GroupRemoteDataSource {
  HttpGroupRemoteDataSource(this._api);

  final ApiClient _api;

  @override
  Future<List<Map<String, dynamic>>> fetchMyGroups() async {
    final response = await _api.get('/groups');
    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> fetchGroup(String groupId) async {
    final response = await _api.get('/groups/$groupId');
    return response as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchMembers(String groupId) async {
    final response = await _api.get('/groups/$groupId/members');
    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchProfiles(List<String> userIds) async {
    if (userIds.isEmpty) return const [];
    final response = await _api.get('/profiles', query: {'ids': userIds.join(',')});
    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> createGroup({
    required String name,
    String? description,
  }) async {
    final response = await _api.post(
      '/groups',
      body: {'name': name, 'description': description},
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateGroup({
    required String groupId,
    required String name,
    String? description,
  }) async {
    final response = await _api.patch(
      '/groups/$groupId',
      body: {'name': name, 'description': description},
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<String> joinGroupByCode(String inviteCode) async {
    final response = await _api.post(
      '/groups/join',
      body: {'invite_code': inviteCode},
    );
    return (response as Map<String, dynamic>)['group_id'] as String;
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    await _api.post('/groups/$groupId/leave');
  }

  @override
  Future<Map<String, dynamic>> setMemberRole({
    required String groupId,
    required String targetUserId,
    required String role,
  }) async {
    final response = await _api.patch(
      '/groups/$groupId/members/$targetUserId/role',
      body: {'role': role},
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<void> removeMember({
    required String groupId,
    required String targetUserId,
  }) async {
    await _api.delete('/groups/$groupId/members/$targetUserId');
  }

  @override
  Future<Map<String, dynamic>> setPinnedNote({
    required String groupId,
    String? note,
  }) async {
    final response = await _api.patch(
      '/groups/$groupId/note',
      body: {'note': note},
    );
    return response as Map<String, dynamic>;
  }
}
