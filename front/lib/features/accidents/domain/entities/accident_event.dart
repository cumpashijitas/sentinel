import 'package:freezed_annotation/freezed_annotation.dart';

part 'accident_event.freezed.dart';
part 'accident_event.g.dart';

/// Mirrors `public.accident_event_status`. See the migration
/// (`20260827210007_accident_events.sql`) for the full lifecycle — this
/// phase (Fase 7) only ever produces `candidate`, and transitions it to
/// `cancelled` (rider confirmed they're fine before the countdown ended)
/// or `confirmed` (countdown elapsed with no response) itself, both purely
/// client + RLS. `notified`/`resolved` belong to Fase 8 (alerts/Edge
/// Function/push) — nothing in this phase produces them.
enum AccidentEventStatus { candidate, cancelled, confirmed, notified, resolved }

/// A possible-accident record — 1:1 with `public.accident_events`.
@freezed
abstract class AccidentEvent with _$AccidentEvent {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AccidentEvent({
    required String id,
    String? sessionId,
    required String userId,
    double? latitude,
    double? longitude,
    required double impactMps2,
    double? gyroRadS,
    double? speedKmh,
    double? gForce,
    double? confidenceScore,
    required AccidentEventStatus status,
    required DateTime occurredAt,
  }) = _AccidentEvent;

  factory AccidentEvent.fromJson(Map<String, dynamic> json) =>
      _$AccidentEventFromJson(json);
}
