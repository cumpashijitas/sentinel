import '../../../../core/network/api_client.dart';

/// Thin seam over [ApiClient] for the `vehicles` table — see the note on
/// `ProfileRemoteDataSource` for why this exists as its own interface.
///
/// Was `SupabaseVehicleRemoteDataSource` calling `supabase.from(...)`
/// directly — now calls `back/`'s `/vehicles` routes instead (see
/// `back/src/routes/vehicles.routes.ts`).
abstract interface class VehicleRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchVehicles(String ownerId);

  Future<Map<String, dynamic>> createVehicle({
    required String ownerId,
    required String brand,
    required String model,
    int? year,
    String? plate,
    String? color,
  });

  Future<Map<String, dynamic>> updateVehicle({
    required String id,
    required String brand,
    required String model,
    int? year,
    String? plate,
    String? color,
  });

  Future<void> deleteVehicle(String id);
}

class HttpVehicleRemoteDataSource implements VehicleRemoteDataSource {
  HttpVehicleRemoteDataSource(this._api);

  final ApiClient _api;

  @override
  Future<List<Map<String, dynamic>>> fetchVehicles(String ownerId) async {
    final response = await _api.get('/vehicles');
    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> createVehicle({
    required String ownerId,
    required String brand,
    required String model,
    int? year,
    String? plate,
    String? color,
  }) async {
    final response = await _api.post(
      '/vehicles',
      body: {'brand': brand, 'model': model, 'year': year, 'plate': plate, 'color': color},
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateVehicle({
    required String id,
    required String brand,
    required String model,
    int? year,
    String? plate,
    String? color,
  }) async {
    final response = await _api.put(
      '/vehicles/$id',
      body: {'brand': brand, 'model': model, 'year': year, 'plate': plate, 'color': color},
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<void> deleteVehicle(String id) async {
    await _api.delete('/vehicles/$id');
  }
}
