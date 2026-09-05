import '../entities/emergency_contact.dart';

/// Backend-agnostic contract for a rider's own emergency contact list.
///
/// Every method is implicitly scoped to the caller — RLS rejects any row
/// that isn't owned by the caller (see `emergency_contacts_*` policies in
/// `supabase/migrations/20260827210003_emergency_contacts.sql`); being
/// listed as someone's `contactUserId` does **not** grant read access to
/// their contact list.
abstract interface class EmergencyContactRepository {
  /// Throws [DataException] on failure. Returns an empty list if the owner
  /// has no contacts yet.
  Future<List<EmergencyContact>> fetchContacts(String ownerId);

  Future<EmergencyContact> createContact({
    required String ownerId,
    required String name,
    required String phone,
    String? relationship,
    required bool notifyPush,
    required bool notifySms,
    required bool notifyWhatsapp,
  });

  Future<EmergencyContact> updateContact({
    required String id,
    required String name,
    required String phone,
    String? relationship,
    required bool notifyPush,
    required bool notifySms,
    required bool notifyWhatsapp,
  });

  /// Throws [DataException] if [id] doesn't exist or isn't owned by the
  /// caller (rejected by RLS).
  Future<void> deleteContact(String id);
}
