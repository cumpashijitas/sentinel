import '../entities/location_fix.dart';

/// Backend-agnostic contract for the multiplayer side of location sharing:
/// reading everyone's current position for a session, and writing the
/// caller's own.
///
/// Only [LocationRepository] is expected to call the two write methods —
/// see its doc comment for why raw device fixes don't come straight here.
abstract interface class LiveLocationRepository {
  /// Realtime view of every active participant's current position for
  /// [sessionId], keyed by user id. Emits a new snapshot on every
  /// insert/update to that session's `live_locations` rows (RLS already
  /// limits this to session members — see `docs/database.md` and
  /// `docs/realtime.md`). The stream stays open until the caller cancels
  /// its subscription; there is no separate "unsubscribe" method here —
  /// cancelling the `StreamSubscription` releases the underlying Realtime
  /// channel (see `LiveLocationRepositoryImpl`).
  Stream<Map<String, LocationFix>> watchSessionLocations(String sessionId);

  /// Upserts [userId]'s current position for [sessionId] — one row per
  /// session+user (`live_locations`' composite primary key), so this is
  /// always a full replace of "where am I right now", never a growing
  /// list. [userId] must be the caller's own id; RLS rejects anything
  /// else regardless of what's sent, but the caller (always
  /// `LocationRepositoryImpl`, which knows the signed-in user via
  /// `AuthRepository`) still has to supply it — this repository has no
  /// notion of "who's signed in" of its own.
  Future<void> upsertMyLocation({
    required String sessionId,
    required String userId,
    required LocationFix fix,
  });

  /// Appends one row to `location_history` for [userId]. Callers must
  /// apply their own sampling before calling this — see
  /// `LocationSamplingPolicy` — this method itself has no throttling of
  /// its own and will happily write one row per call.
  Future<void> recordHistory({
    required String sessionId,
    required String userId,
    required LocationFix fix,
  });

  /// El camino recorrido por todo el grupo durante [sessionId], combinado
  /// y ordenado por hora — pedido explícito en vivo ("ver la ruta
  /// recorrida en el mapa, estilo Strava"). Cualquier integrante activo
  /// del viaje puede pedirlo, no solo quien está compartiendo ahora mismo.
  Future<List<LocationFix>> fetchHistory(String sessionId);
}
