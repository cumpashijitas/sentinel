import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_fix.freezed.dart';
part 'location_fix.g.dart';

/// A single position reading — either straight from the device
/// ([LocationTracker]) or read back from `live_locations`/
/// `location_history` ([LiveLocationRepository]). Deliberately carries no
/// identity (`userId`/`sessionId`); callers that need to know *whose* fix
/// this is keep that alongside it (see `LiveLocationRepository`, which
/// returns `Map<String, LocationFix>` keyed by user id).
@freezed
abstract class LocationFix with _$LocationFix {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory LocationFix({
    required double latitude,
    required double longitude,
    double? accuracy,
    double? speed,
    double? heading,
    int? batteryLevel,
    required DateTime recordedAt,
  }) = _LocationFix;

  factory LocationFix.fromJson(Map<String, dynamic> json) =>
      _$LocationFixFromJson(json);
}
