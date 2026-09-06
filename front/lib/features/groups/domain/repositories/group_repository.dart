import '../entities/group_member.dart';
import '../entities/ride_group.dart';

/// Backend-agnostic contract for ride groups.
///
/// Mutations here are backed by Postgres RPCs
/// (`create_ride_group`/`join_group_by_code`/`leave_group`), not plain
/// table inserts/updates — `ride_groups`/`ride_group_members` have no
/// direct client INSERT policy by design (see `docs/database.md`), so the
/// domain rules (unique invite code, no duplicate membership, owner can't
/// leave) are enforced once, server-side, instead of re-implemented here.
abstract interface class GroupRepository {
  /// Groups the caller is an active member of. RLS does the filtering, so
  /// [userId] isn't sent as a query parameter — it only documents whose
  /// groups these are.
  Future<List<RideGroup>> fetchMyGroups(String userId);

  /// Throws [DataException] if [groupId] doesn't exist or the caller isn't
  /// an active member (rejected by RLS).
  Future<RideGroup> fetchGroup(String groupId);

  /// Active members of [groupId], with display name/avatar attached.
  Future<List<GroupMember>> fetchMembers(String groupId);

  /// Creates a group and enrolls the caller as its owner, atomically.
  Future<RideGroup> createGroup({required String name, String? description});

  /// Joins (or reactivates membership in) the group matching
  /// [inviteCode]. Returns the joined group's id. Throws [DataException]
  /// with a user-facing message for an invalid/inactive code.
  Future<String> joinGroupByCode(String inviteCode);

  /// The caller leaves [groupId]. Throws [DataException] if they aren't an
  /// active member, or if they're the group's owner (a group must always
  /// have one).
  Future<void> leaveGroup(String groupId);
}
