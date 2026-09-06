import '../../../../core/network/api_client.dart';

/// Thin seam over [ApiClient] for the `profiles` table.
///
/// Was `SupabaseProfileRemoteDataSource` calling `supabase.from(...)`
/// directly — now calls `back/`'s `/profile` routes instead (see
/// `back/src/routes/profile.routes.ts`, which replicates the
/// `profiles_select_own`/`profiles_select_group_members`/
/// `profiles_update_own` RLS policies this table used to enforce).
abstract interface class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> fetchProfile(String userId);

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String displayName,
    String? phone,
    required bool whatsappAlertsOptIn,
  });
}

class HttpProfileRemoteDataSource implements ProfileRemoteDataSource {
  HttpProfileRemoteDataSource(this._api);

  final ApiClient _api;

  @override
  Future<Map<String, dynamic>> fetchProfile(String userId) async {
    final response = await _api.get('/profile/$userId');
    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String displayName,
    String? phone,
    required bool whatsappAlertsOptIn,
  }) async {
    final response = await _api.put(
      '/profile/$userId',
      body: {
        'display_name': displayName,
        'phone': phone,
        'whatsapp_alerts_opt_in': whatsappAlertsOptIn,
      },
    );
    return response as Map<String, dynamic>;
  }
}
