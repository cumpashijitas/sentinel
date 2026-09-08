import 'package:freezed_annotation/freezed_annotation.dart';

part 'emergency_share.freezed.dart';
part 'emergency_share.g.dart';

/// Mirrors `public.emergency_shares.status`.
enum EmergencyShareStatus { active, ended }

/// "Compartir mi ubicación con mis contactos de emergencia" — independiente
/// de estar en un viaje de grupo (a diferencia de `RideSession`). Un solo
/// share activo por usuario a la vez; [shareToken] es la clave del link
/// público (`/share/<shareToken>`), ver `back/src/services/emergency-share.service.ts`.
@freezed
abstract class EmergencyShare with _$EmergencyShare {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory EmergencyShare({
    required String id,
    required String userId,
    required String shareToken,
    required EmergencyShareStatus status,
    required DateTime startedAt,
    DateTime? endedAt,
  }) = _EmergencyShare;

  factory EmergencyShare.fromJson(Map<String, dynamic> json) =>
      _$EmergencyShareFromJson(json);
}

/// Un share activo de *otro* rider que me tiene como contacto de emergencia
/// con cuenta propia vinculada — el camino "adentro de la app" (ver
/// `EmergencyShareRepository.fetchSharedWithMe`). No tiene `fromJson`: se
/// arma a mano desde la fila ya combinada que devuelve el backend
/// (`rider_display_name` viene de un join, no de la tabla `emergency_shares`
/// en sí).
@freezed
abstract class SharedWithMeEntry with _$SharedWithMeEntry {
  const factory SharedWithMeEntry({
    required String shareId,
    required String riderUserId,
    required String riderDisplayName,
    required DateTime startedAt,

    /// Reuses the same public `/share/<token>` screen for this in-app path
    /// instead of a second implementation — see `EmergencySharePage`.
    /// Seeing this list already proves the caller is a linked emergency
    /// contact, so handing them the token isn't a wider hole than that.
    required String shareToken,
  }) = _SharedWithMeEntry;
}
