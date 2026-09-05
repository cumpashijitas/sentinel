import '../entities/ride_history_entry.dart';
import '../entities/ride_session.dart';
import '../entities/ride_session_participant.dart';

/// Backend-agnostic contract for ride sessions.
///
/// Like `GroupRepository`, mutations here are backed by RPCs
/// (`start_ride_session`/`finish_ride_session`), not plain table
/// inserts/updates — `ride_sessions` has no direct client INSERT/UPDATE
/// policy (see `docs/database.md`). There is deliberately no "join
/// session" method: `start_ride_session` already enrolls every
/// currently-active group member into the session atomically, so
/// participation is a side effect of the group you belong to when the
/// ride starts, not a separate action.
abstract interface class RideSessionRepository {
  /// The group's current `waiting`/`active` session, or `null` if none.
  /// At most one such session can exist per group (enforced by
  /// `start_ride_session`).
  Future<RideSession?> fetchActiveSession(String groupId);

  /// Throws [DataException] if [sessionId] doesn't exist or the caller
  /// isn't a member of its group (rejected by RLS).
  Future<RideSession> fetchSession(String sessionId);

  /// Active participants of [sessionId], with display name/avatar
  /// attached.
  Future<List<RideSessionParticipant>> fetchParticipants(String sessionId);

  /// Starts a session for [groupId] and enrolls every active group member.
  /// Owner/admin only; throws [DataException] if the group already has a
  /// `waiting`/`active` session.
  Future<RideSession> startSession({required String groupId, String? name});

  /// Finishes [sessionId] and releases its active participants.
  /// Owner/admin only.
  Future<RideSession> finishSession(String sessionId);

  /// Every `finished` session [userId] participated in, across every
  /// group, newest first (Fase 9: history). `waiting`/`active` sessions
  /// are never included (not history yet); `cancelled` is defined in the
  /// schema but no code path produces it today (see `docs/database.md`),
  /// so it's excluded here too rather than surfacing a state nothing can
  /// actually reach.
  Future<List<RideHistoryEntry>> fetchHistory(String userId);
}
