import '../entities/vehicle.dart';

/// Backend-agnostic contract for a rider's own vehicle list.
///
/// Every method is implicitly scoped to the caller: RLS rejects any
/// `ownerId`/row that isn't the caller's own, so there is no "read someone
/// else's vehicles" path here at all (unlike profiles, vehicles are never
/// shared with group-mates).
abstract interface class VehicleRepository {
  /// Throws [DataException] on failure. Returns an empty list if the owner
  /// has no vehicles yet.
  Future<List<Vehicle>> fetchVehicles(String ownerId);

  Future<Vehicle> createVehicle({
    required String ownerId,
    required String brand,
    required String model,
    int? year,
    String? plate,
    String? color,
  });

  Future<Vehicle> updateVehicle({
    required String id,
    required String brand,
    required String model,
    int? year,
    String? plate,
    String? color,
  });

  /// Throws [DataException] if [id] doesn't exist or isn't owned by the
  /// caller (rejected by RLS).
  Future<void> deleteVehicle(String id);
}
