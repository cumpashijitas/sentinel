import 'package:freezed_annotation/freezed_annotation.dart';

part 'ride_group.freezed.dart';
part 'ride_group.g.dart';

/// Mirrors `public.ride_group_status` in Postgres.
enum RideGroupStatus { active, archived }

/// A group of riders — 1:1 with `public.ride_groups` (see
/// `supabase/migrations/20260827210004_ride_groups.sql`). RLS only ever
/// returns groups the caller is an active member of.
@freezed
abstract class RideGroup with _$RideGroup {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory RideGroup({
    required String id,
    required String ownerId,
    required String name,
    String? description,
    required String inviteCode,
    required RideGroupStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? pinnedNote,
  }) = _RideGroup;

  factory RideGroup.fromJson(Map<String, dynamic> json) =>
      _$RideGroupFromJson(json);
}
