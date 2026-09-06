import 'package:freezed_annotation/freezed_annotation.dart';

part 'ride_session_participant.freezed.dart';

/// Mirrors `public.ride_session_member_status`. Named `Participant` rather
/// than `Member` in Dart to keep it visually distinct from
/// `features/groups`' `GroupMember`/`GroupMemberStatus` — the two are
/// unrelated statuses (group standing roster vs. one ride's live
/// attendance) that happen to share similar names in Postgres.
enum RideParticipantStatus { active, left }

/// A participant of a [RideSession], with just enough profile data to
/// render a roster entry.
///
/// Same reasoning as `features/groups`' `GroupMember`: `ride_session_members`
/// has no direct foreign key to `profiles` (both merely reference
/// `auth.users` independently), so this is assembled from two queries in
/// the repository rather than deserialized from one API response — hence
/// no `fromJson` here either.
@freezed
abstract class RideSessionParticipant with _$RideSessionParticipant {
  const factory RideSessionParticipant({
    required String sessionId,
    required String userId,
    required RideParticipantStatus status,
    required DateTime joinedAt,
    DateTime? leftAt,
    DateTime? lastSeenAt,
    required String displayName,
    String? avatarUrl,
  }) = _RideSessionParticipant;
}
