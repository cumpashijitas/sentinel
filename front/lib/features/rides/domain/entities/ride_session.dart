import 'package:freezed_annotation/freezed_annotation.dart';

part 'ride_session.freezed.dart';
part 'ride_session.g.dart';

/// Mirrors `public.ride_session_status`.
enum RideSessionStatus { waiting, active, finished, cancelled }

/// A single group ride ("we're riding now") — 1:1 with
/// `public.ride_sessions` (see
/// `supabase/migrations/20260827210005_ride_sessions.sql`). RLS only ever
/// returns sessions for groups the caller belongs to.
@freezed
abstract class RideSession with _$RideSession {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory RideSession({
    required String id,
    required String groupId,
    required String startedBy,
    String? name,
    required RideSessionStatus status,
    required DateTime startedAt,
    DateTime? endedAt,
    required DateTime createdAt,
  }) = _RideSession;

  factory RideSession.fromJson(Map<String, dynamic> json) =>
      _$RideSessionFromJson(json);
}
