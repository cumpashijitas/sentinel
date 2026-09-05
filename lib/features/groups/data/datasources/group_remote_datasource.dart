import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin seam over `SupabaseClient` for ride groups — table reads plus the
/// three group-management RPCs. See the note on `ProfileRemoteDataSource`
/// for why this exists as its own interface.
abstract interface class GroupRemoteDataSource {
  /// Groups the caller belongs to (RLS-filtered — no explicit owner/member
  /// filter needed here).
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

  /// Returns the joined group's id (the RPC returns a plain `uuid`).
  Future<String> joinGroupByCode(String inviteCode);

  Future<void> leaveGroup(String groupId);
}

class SupabaseGroupRemoteDataSource implements GroupRemoteDataSource {
  SupabaseGroupRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> fetchMyGroups() async {
    final rows = await _client.from('ride_groups').select().order('created_at');
    return rows;
  }

  @override
  Future<Map<String, dynamic>> fetchGroup(String groupId) {
    return _client.from('ride_groups').select().eq('id', groupId).single();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchMembers(String groupId) async {
    final rows = await _client
        .from('ride_group_members')
        .select()
        .eq('group_id', groupId)
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
  Future<Map<String, dynamic>> createGroup({
    required String name,
    String? description,
  }) async {
    final response = await _client.rpc<Map<String, dynamic>>(
      'create_ride_group',
      params: {'p_name': name, 'p_description': description},
    );
    return response;
  }

  @override
  Future<String> joinGroupByCode(String inviteCode) {
    return _client.rpc<String>(
      'join_group_by_code',
      params: {'p_invite_code': inviteCode},
    );
  }

  @override
  Future<void> leaveGroup(String groupId) {
    return _client.rpc<void>('leave_group', params: {'p_group_id': groupId});
  }
}
