import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin seam over `SupabaseClient` for the `device_push_tokens` table —
/// see the note on `ProfileRemoteDataSource` for why this exists as its
/// own interface.
abstract interface class DevicePushTokenRemoteDataSource {
  /// Upserts on the table's `token` UNIQUE constraint (see
  /// [DevicePushTokenRepository.registerToken]).
  Future<Map<String, dynamic>> upsertToken(Map<String, dynamic> row);

  Future<void> deleteToken(String token);
}

class SupabaseDevicePushTokenRemoteDataSource
    implements DevicePushTokenRemoteDataSource {
  SupabaseDevicePushTokenRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _table = 'device_push_tokens';

  @override
  Future<Map<String, dynamic>> upsertToken(Map<String, dynamic> row) {
    return _client
        .from(_table)
        .upsert(row, onConflict: 'token')
        .select()
        .single();
  }

  @override
  Future<void> deleteToken(String token) {
    return _client.from(_table).delete().eq('token', token);
  }
}
