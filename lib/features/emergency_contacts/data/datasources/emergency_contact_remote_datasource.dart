import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin seam over `SupabaseClient` for the `emergency_contacts` table —
/// see the note on `ProfileRemoteDataSource` for why this exists as its
/// own interface.
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

class SupabaseEmergencyContactRemoteDataSource
    implements EmergencyContactRemoteDataSource {
  SupabaseEmergencyContactRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _table = 'emergency_contacts';

  @override
  Future<List<Map<String, dynamic>>> fetchContacts(String ownerId) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('owner_id', ownerId)
        .order('created_at');
    return rows;
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
  }) {
    return _client
        .from(_table)
        .insert({
          'owner_id': ownerId,
          'name': name,
          'phone': phone,
          'relationship': relationship,
          'notify_push': notifyPush,
          'notify_sms': notifySms,
          'notify_whatsapp': notifyWhatsapp,
        })
        .select()
        .single();
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
  }) {
    return _client
        .from(_table)
        .update({
          'name': name,
          'phone': phone,
          'relationship': relationship,
          'notify_push': notifyPush,
          'notify_sms': notifySms,
          'notify_whatsapp': notifyWhatsapp,
        })
        .eq('id', id)
        .select()
        .single();
  }

  @override
  Future<void> deleteContact(String id) {
    return _client.from(_table).delete().eq('id', id);
  }
}
