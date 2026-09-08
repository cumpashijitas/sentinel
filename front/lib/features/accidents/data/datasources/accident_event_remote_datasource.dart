import '../../../../core/network/api_client.dart';

/// Thin seam over [ApiClient] for the `accident_events` table — see the
/// note on `ProfileRemoteDataSource` for why this exists as its own
/// interface.
///
/// Was `SupabaseAccidentEventRemoteDataSource` calling `supabase.from(...)`
/// directly — now calls `back/`'s `/accidents` routes instead (see
/// `back/src/services/accident.service.ts`, which also replicates the
/// RLS invariants this table used to enforce, e.g. a status update only
/// applying while the row is still `candidate`).
abstract interface class AccidentEventRemoteDataSource {
  Future<Map<String, dynamic>> insertCandidate(Map<String, dynamic> row);

  Future<void> updateStatus({required String id, required String status});

  Future<List<Map<String, dynamic>>> fetchMine(String userId);

  Future<Map<String, dynamic>> fetchById(String id);
}

class HttpAccidentEventRemoteDataSource
    implements AccidentEventRemoteDataSource {
  HttpAccidentEventRemoteDataSource(this._api);

  final ApiClient _api;

  @override
  Future<Map<String, dynamic>> insertCandidate(Map<String, dynamic> row) async {
    final response = await _api.post('/accidents', body: row);
    return response as Map<String, dynamic>;
  }

  @override
  Future<void> updateStatus({required String id, required String status}) async {
    await _api.patch('/accidents/$id', body: {'status': status});
  }

  @override
  Future<List<Map<String, dynamic>>> fetchMine(String userId) async {
    final response = await _api.get('/accidents');
    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> fetchById(String id) async {
    final response = await _api.get('/accidents/$id');
    return response as Map<String, dynamic>;
  }
}
