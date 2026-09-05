import 'package:freezed_annotation/freezed_annotation.dart';

part 'emergency_contact.freezed.dart';
part 'emergency_contact.g.dart';

/// A contact to alert on a confirmed accident — 1:1 with
/// `public.emergency_contacts` (see
/// `supabase/migrations/20260827210003_emergency_contacts.sql`). Strictly
/// private: only the owner ever sees or edits their own contacts.
///
/// [contactUserId] is an optional link to another Sentinel account (so the
/// contact can also be reached by push, not only SMS) — never required.
@freezed
abstract class EmergencyContact with _$EmergencyContact {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory EmergencyContact({
    required String id,
    required String ownerId,
    String? contactUserId,
    required String name,
    required String phone,
    String? relationship,
    required bool notifyPush,
    required bool notifySms,
    // Fase 8 (extensión WhatsApp, `20260829000001_whatsapp_alerts.sql`):
    // mismo patrón que notifyPush/notifySms — una preferencia por contacto,
    // declarada por el dueño de la lista, respetada de forma literal e
    // independiente (nunca se infiere de notifyPush/notifySms). Ver
    // docs/alerts.md.
    required bool notifyWhatsapp,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _EmergencyContact;

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactFromJson(json);
}
