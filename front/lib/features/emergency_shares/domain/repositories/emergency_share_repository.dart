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

  /// Every rider who has the caller as an emergency contact (with their own
  /// Sentinel account linked) and is sharing right now.
  Future<List<SharedWithMeEntry>> fetchSharedWithMe();
}
