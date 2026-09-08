import '../../../../core/network/api_client.dart';

/// Thin seam over [ApiClient] for the `emergency_contacts` table — see the
/// note on `ProfileRemoteDataSource` for why this exists as its own
/// interface.
///
/// Was `SupabaseEmergencyContactRemoteDataSource` calling
/// `supabase.from(...)` directly — now calls `back/`'s
/// `/emergency-contacts` routes instead (see
/// `back/src/routes/emergency-contacts.routes.ts`).
abstract interface class EmergencyContactRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchContacts(String ownerId);

  Future<Map<String, dynamic>> createContact({
    required String ownerId,
    required String name,
    required String phone,
    String? relationship,
    required bool notifyPush,
    required bool notifySms,
    required bool notifyWhatsapp,
  });

  Future<Map<String, dynamic>> updateContact({
    required String id,
    required String name,
    required String phone,
    String? relationship,
    required bool notifyPush,
    required bool notifySms,
    required bool notifyWhatsapp,
  });

  Future<void> deleteContact(String id);
}

class HttpEmergencyContactRemoteDataSource
    implements EmergencyContactRemoteDataSource {
  HttpEmergencyContactRemoteDataSource(this._api);

  final ApiClient _api;

  @override
  Future<List<Map<String, dynamic>>> fetchContacts(String ownerId) async {
    final response = await _api.get('/emergency-contacts');
    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> createContact({
    required String ownerId,
    required String name,
    required String phone,
    String? relationship,
    required bool notifyPush,
    required bool notifySms,
    required bool notifyWhatsapp,
  }) async {
    final response = await _api.post(
      '/emergency-contacts',
      body: {
        'name': name,
        'phone': phone,
        'relationship': relationship,
        'notify_push': notifyPush,
        'notify_sms': notifySms,
        'notify_whatsapp': notifyWhatsapp,
      },
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateContact({
    required String id,
    required String name,
    required String phone,
    String? relationship,
    required bool notifyPush,
    required bool notifySms,
    required bool notifyWhatsapp,
  }) async {
    final response = await _api.put(
      '/emergency-contacts/$id',
      body: {
        'name': name,
        'phone': phone,
        'relationship': relationship,
        'notify_push': notifyPush,
        'notify_sms': notifySms,
        'notify_whatsapp': notifyWhatsapp,
      },
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<void> deleteContact(String id) async {
    await _api.delete('/emergency-contacts/$id');
  }
}
