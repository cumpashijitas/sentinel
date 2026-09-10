import '../../../rides/domain/entities/location_fix.dart';
import '../entities/emergency_share.dart';

/// Backend-agnostic contract for "compartir mi ubicación con mis contactos
/// de emergencia" — the authenticated half (starting/stopping a share,
/// pushing your own fixes, seeing who shares *with* you). The public-link
/// viewing half is a separate, unauthenticated contract — see
/// `PublicEmergencyShareRepository`.
abstract interface class EmergencyShareRepository {
  /// The caller's own active share, or `null` if not currently sharing.
  Future<EmergencyShare?> fetchActiveShare();

  /// Starts a new share, ending any previous active one first (only one
  /// active share per user — see the backend service).
  Future<EmergencyShare> startShare();

  Future<void> stopShare();

  Future<void> upsertMyLocation({
    required String shareId,
    required LocationFix fix,
  });

  /// Camino recorrido de un "viaje individual" — pedido explícito en vivo,
  /// mismo patrón que `LiveLocationRepository.recordHistory` para un viaje
  /// de grupo (se llama solo cuando `LocationSamplingPolicy` decide que el
  /// fix es significativo, no en cada actualización de GPS).
  Future<void> recordHistory({required String shareId, required LocationFix fix});

  /// La ruta recorrida en este share (dueño viéndose a sí mismo) — estilo
  /// Strava, igual que `LiveLocationRepository.fetchHistory` para un viaje
  /// de grupo.
  Future<List<LocationFix>> fetchMyRoute(String shareId);

  /// Every rider who has the caller as an emergency contact (with their own
  /// Sentinel account linked) and is sharing right now.
  Future<List<SharedWithMeEntry>> fetchSharedWithMe();
}
