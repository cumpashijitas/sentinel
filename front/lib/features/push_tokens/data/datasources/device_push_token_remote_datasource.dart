import '../../../../core/network/api_client.dart';

/// Thin seam over [ApiClient] for the `device_push_tokens` table — see the
/// note on `ProfileRemoteDataSource` for why this exists as its own
/// interface.
///
/// Was `SupabaseDevicePushTokenRemoteDataSource` calling
/// `supabase.from(...)` directly — now calls `back/`'s `/push-tokens`
/// routes instead (see `back/src/routes/push-tokens.routes.ts`). `user_id`/
/// `last_seen_at` in [row] are dropped rather than sent: the backend
/// derives the owner from the JWT and stamps the timestamp itself.
abstract interface class DevicePushTokenRemoteDataSource {
  /// Upserts on the table's `token` UNIQUE constraint (see
  /// [DevicePushTokenRepository.registerToken]).
  Future<Map<String, dynamic>> upsertToken(Map<String, dynamic> row);

  Future<void> deleteToken(String token);
}

class HttpDevicePushTokenRemoteDataSource
    implements DevicePushTokenRemoteDataSource {
  HttpDevicePushTokenRemoteDataSource(this._api);

  final ApiClient _api;

  @override
  Future<Map<String, dynamic>> upsertToken(Map<String, dynamic> row) async {
    final response = await _api.post(
      '/push-tokens',
      body: {'platform': row['platform'], 'token': row['token']},
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<void> deleteToken(String token) async {
    await _api.delete('/push-tokens/$token');
  }
}
