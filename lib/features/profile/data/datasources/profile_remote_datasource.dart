import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin seam over `SupabaseClient` for the `profiles` table.
///
/// Kept as its own interface (rather than calling `.from('profiles')`
/// directly from the repository) for the same reason as
/// `AuthRemoteDataSource`: it lets [ProfileRepositoryImpl] be unit-tested
/// with a fake, without a network connection or a running Supabase
/// instance.
abstract interface class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> fetchProfile(String userId);

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String displayName,
    String? phone,
    required bool whatsappAlertsOptIn,
  });
}

class SupabaseProfileRemoteDataSource implements ProfileRemoteDataSource {
  SupabaseProfileRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _table = 'profiles';

  @override
  Future<Map<String, dynamic>> fetchProfile(String userId) {
    return _client.from(_table).select().eq('id', userId).single();
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String displayName,
    String? phone,
    required bool whatsappAlertsOptIn,
  }) {
    return _client
        .from(_table)
        .update({
          'display_name': displayName,
          'phone': phone,
          'whatsapp_alerts_opt_in': whatsappAlertsOptIn,
        })
        .eq('id', userId)
        .select()
        .single();
  }
}
