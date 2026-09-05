import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_member.freezed.dart';

/// Mirrors `public.ride_group_role`.
enum GroupMemberRole { owner, admin, member }

/// Mirrors `public.ride_group_member_status`.
enum GroupMemberStatus { invited, active, left, removed }

/// A member of a [RideGroup], with just enough profile data to render a
/// roster entry.
///
/// Deliberately not a 1:1 mirror of a single table: `ride_group_members`
/// has no direct foreign key to `profiles` (both merely reference
/// `auth.users` independently), so PostgREST can't embed one in the other
/// in a single request. [GroupRepository.fetchMembers] issues two queries
/// (membership rows, then the matching profiles) and merges them into this
/// entity — see the repository implementation for the exact join. That's
/// also why this class has no `fromJson`: it's never deserialized directly
/// from one API response.
@freezed
abstract class GroupMember with _$GroupMember {
  const factory GroupMember({
    required String groupId,
    required String userId,
    required GroupMemberRole role,
    required GroupMemberStatus status,
    required DateTime joinedAt,
    DateTime? leftAt,
    required String displayName,
    String? avatarUrl,
  }) = _GroupMember;
}
