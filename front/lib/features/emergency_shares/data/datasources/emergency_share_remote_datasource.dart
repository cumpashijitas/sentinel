import '../../../../core/network/api_client.dart';

/// Thin seam over [ApiClient] for `back/`'s `/emergency-shares/*` routes —
/// see the note on `ProfileRemoteDataSource` for why this exists as its
/// own interface.
abstract interface class EmergencyShareRemoteDataSource {
  Future<Map<String, dynamic>?> fetchActiveShare();

  Future<Map<String, dynamic>> startShare();

  Future<void> stopShare();

  Future<void> upsertLocation({
    required String shareId,
    required Map<String, dynamic> fixJson,
  });

  Future<void> recordHistory({
    required String shareId,
    required Map<String, dynamic> fixJson,
  });

  Future<List<Map<String, dynamic>>> fetchHistory(String shareId);

  Future<List<Map<String, dynamic>>> fetchSharedWithMe();

  /// Todos los shares del usuario, pasados y presentes — para "perfil de
  /// usuario" (rutas individuales). Distinto de [fetchHistory], que trae el
  /// recorrido (lat/lng) de UN share, no la lista de shares en sí.
  Future<List<Map<String, dynamic>>> fetchSharesHistory();
}

class HttpEmergencyShareRemoteDataSource
    implements EmergencyShareRemoteDataSource {
  HttpEmergencyShareRemoteDataSource(this._api);

  final ApiClient _api;

  @override
  Future<Map<String, dynamic>?> fetchActiveShare() async {
    final response = await _api.get('/emergency-shares/active');
    return response as Map<String, dynamic>?;
  }

  @override
  Future<Map<String, dynamic>> startShare() async {
    final response = await _api.post('/emergency-shares/start');
    return response as Map<String, dynamic>;
  }

  @override
  Future<void> stopShare() async {
    await _api.post('/emergency-shares/stop');
  }

  @override
  Future<void> upsertLocation({
    required String shareId,
    required Map<String, dynamic> fixJson,
  }) async {
    await _api.post('/emergency-shares/$shareId/location', body: fixJson);
  }

  @override
  Future<void> recordHistory({
    required String shareId,
    required Map<String, dynamic> fixJson,
  }) async {
    await _api.post(
      '/emergency-shares/$shareId/location/history',
      body: fixJson,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchHistory(String shareId) async {
    final response = await _api.get('/emergency-shares/$shareId/location/history');
    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSharedWithMe() async {
    final response = await _api.get('/emergency-shares/shared-with-me');
    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSharesHistory() async {
    final response = await _api.get('/emergency-shares/history');
    return (response as List).cast<Map<String, dynamic>>();
  }
}
