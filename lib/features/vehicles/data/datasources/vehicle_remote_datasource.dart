import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin seam over `SupabaseClient` for the `vehicles` table — see the note
/// on `ProfileRemoteDataSource` for why this exists as its own interface.
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

class SupabaseVehicleRemoteDataSource implements VehicleRemoteDataSource {
  SupabaseVehicleRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _table = 'vehicles';

  @override
  Future<List<Map<String, dynamic>>> fetchVehicles(String ownerId) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('owner_id', ownerId)
        .order('created_at');
    return rows;
  }

  @override
  Future<Map<String, dynamic>> createVehicle({
    required String ownerId,
    required String brand,
    required String model,
    int? year,
    String? plate,
    String? color,
  }) {
    return _client
        .from(_table)
        .insert({
          'owner_id': ownerId,
          'brand': brand,
          'model': model,
          'year': year,
          'plate': plate,
          'color': color,
        })
        .select()
        .single();
  }

  @override
  Future<Map<String, dynamic>> updateVehicle({
    required String id,
    required String brand,
    required String model,
    int? year,
    String? plate,
    String? color,
  }) {
    return _client
        .from(_table)
        .update({
          'brand': brand,
          'model': model,
          'year': year,
          'plate': plate,
          'color': color,
        })
        .eq('id', id)
        .select()
        .single();
  }

  @override
  Future<void> deleteVehicle(String id) {
    return _client.from(_table).delete().eq('id', id);
  }
}
