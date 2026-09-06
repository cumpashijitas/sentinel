import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/emergency_contacts/domain/entities/emergency_contact.dart';

void main() {
  group('EmergencyContact', () {
    test('fromJson maps snake_case Postgres columns', () {
      final contact = EmergencyContact.fromJson({
        'id': 'c1',
        'owner_id': 'u1',
        'contact_user_id': 'u2',
        'name': 'Bruno Rider',
        'phone': '+591 700 00002',
        'relationship': 'Compañero de ruta',
        'notify_push': true,
        'notify_sms': true,
        'notify_whatsapp': true,
        'created_at': '2026-08-27T12:00:00.000Z',
        'updated_at': '2026-08-27T12:00:00.000Z',
      });

      expect(contact.id, 'c1');
      expect(contact.ownerId, 'u1');
      expect(contact.contactUserId, 'u2');
      expect(contact.name, 'Bruno Rider');
      expect(contact.notifyPush, isTrue);
      expect(contact.notifySms, isTrue);
      expect(contact.notifyWhatsapp, isTrue);
    });

    test('toJson/fromJson round-trip preserves equality', () {
      final contact = EmergencyContact(
        id: 'c1',
        ownerId: 'u1',
        name: 'María Rider',
        phone: '+591 700 09999',
        notifyPush: false,
        notifySms: true,
        notifyWhatsapp: false,
        createdAt: DateTime.utc(2026, 8, 27),
        updatedAt: DateTime.utc(2026, 8, 27),
      );

      final roundTripped = EmergencyContact.fromJson(contact.toJson());

      expect(roundTripped, equals(contact));
    });
  });
}
