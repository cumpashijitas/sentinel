import '../entities/accident_event.dart';
import '../entities/motion_sample.dart';

/// Reads/writes `accident_events`. Kept as a plain CRUD-shaped repository
/// (same spirit as `ProfileRepository`/`VehicleRepository`) rather than
/// folding the create-then-countdown-then-resolve workflow in here — that
/// orchestration belongs to `AccidentMonitorService`, which is the thing
/// that actually knows *when* to call each of these.
abstract interface class AccidentEventRepository {
  /// Inserts a new `candidate` row. [sample] is embedded verbatim as
  /// `sensor_snapshot` — the raw evidence, not just the derived numbers.
  /// [userId] is supplied by the caller (see `LiveLocationRepository` for
  /// the same pattern and why) rather than read from a Supabase singleton
  /// inside this repository.
  Future<AccidentEvent> reportCandidate({
    required String userId,
    required String? sessionId,
    required double impactMps2,
    double? gyroRadS,
    double? gForce,
    double? confidenceScore,
    double? latitude,
    double? longitude,
    required MotionSample sample,
  });

  /// Rider confirmed they're fine before the countdown ended. Only valid
  /// while the row is still `candidate` — see the RLS policy on
  /// `accident_events` for why (enforced server-side too, not just here).
  Future<void> cancel(String accidentEventId);

  /// Countdown elapsed with no response — treat the candidate as a real
  /// accident. Same `candidate`-only constraint as [cancel].
  Future<void> confirm(String accidentEventId);

  /// Every `accident_events` row belonging to [userId], any status, newest
  /// first (Fase 9: history). The `accident_events_select_self` RLS policy
  /// already allows this regardless of status — a rider's own safety
  /// record, including a `candidate` that got `cancelled` as a false
  /// alarm.
  Future<List<AccidentEvent>> fetchMine(String userId);

  /// A single accident event by id. Throws [DataException] if it doesn't
  /// exist or isn't visible to the caller — either their own (any status)
  /// or a `confirmed`/`notified`/`resolved` event for a ride session they
  /// belong to (see the RLS policies on `accident_events`).
  Future<AccidentEvent> fetchById(String accidentEventId);
}
