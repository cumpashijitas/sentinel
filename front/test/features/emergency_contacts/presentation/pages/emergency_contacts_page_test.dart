import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/auth/domain/entities/app_user.dart';
import 'package:sentinel_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:sentinel_v2/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sentinel_v2/features/emergency_contacts/domain/entities/emergency_contact.dart';
import 'package:sentinel_v2/features/emergency_contacts/domain/repositories/emergency_contact_repository.dart';
import 'package:sentinel_v2/features/emergency_contacts/presentation/controllers/emergency_contacts_controller.dart';
import 'package:sentinel_v2/features/emergency_contacts/presentation/pages/emergency_contacts_page.dart';

const _currentUser = AppUser(id: 'u1', email: 'rider1@sentinel.dev');

class _FakeAuthRepository implements AuthRepository {
  @override
  AppUser? currentUser = _currentUser;

  @override
  Stream<AppUser?> get authStateChanges =>
      Stream.value(_currentUser).asBroadcastStream();

  @override
  Future<AppUser> signInWithPassword({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<AppUser> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
  }) => throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();
}

EmergencyContact _contact({
  String id = 'c1',
  String name = 'María Rider',
  bool notifyPush = true,
  bool notifySms = false,
  bool notifyWhatsapp = false,
}) => EmergencyContact(
  id: id,
  ownerId: 'u1',
  name: name,
  phone: '+591 700 09999',
  notifyPush: notifyPush,
  notifySms: notifySms,
  notifyWhatsapp: notifyWhatsapp,
  createdAt: DateTime.utc(2026, 8, 27),
  updatedAt: DateTime.utc(2026, 8, 27),
);

class _FakeEmergencyContactRepository implements EmergencyContactRepository {
  List<EmergencyContact> contacts = [];

  @override
  Future<List<EmergencyContact>> fetchContacts(String ownerId) async =>
      contacts;

  @override
  Future<EmergencyContact> createContact({
    required String ownerId,
    required String name,
    required String phone,
    String? relationship,
    required bool notifyPush,
    required bool notifySms,
    required bool notifyWhatsapp,
  }) async {
    final created = _contact(
      id: 'c${contacts.length + 1}',
      name: name,
      notifyPush: notifyPush,
      notifySms: notifySms,
      notifyWhatsapp: notifyWhatsapp,
    );
    contacts = [...contacts, created];
    return created;
  }

  @override
  Future<EmergencyContact> updateContact({
    required String id,
    required String name,
    required String phone,
    String? relationship,
    required bool notifyPush,
    required bool notifySms,
    required bool notifyWhatsapp,
  }) async => throw UnimplementedError();

  @override
  Future<void> deleteContact(String id) async {
    contacts = contacts.where((c) => c.id != id).toList();
  }
}

void main() {
  late _FakeEmergencyContactRepository fakeContactRepository;

  Future<void> pumpContactsPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          emergencyContactRepositoryProvider.overrideWithValue(
            fakeContactRepository,
          ),
        ],
        child: const MaterialApp(home: EmergencyContactsPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    fakeContactRepository = _FakeEmergencyContactRepository();
  });

  group('EmergencyContactsPage', () {
    testWidgets('shows an empty state when there are no contacts', (
      tester,
    ) async {
      await pumpContactsPage(tester);

      expect(
        find.text('Todavía no agregaste ningún contacto de emergencia.'),
        findsOneWidget,
      );
    });

    testWidgets('lists existing contacts', (tester) async {
      fakeContactRepository.contacts = [_contact()];

      await pumpContactsPage(tester);

      expect(find.text('María Rider'), findsOneWidget);
    });

    testWidgets('adds a contact through the form sheet', (tester) async {
      await pumpContactsPage(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'),
        'Bruno Rider',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Teléfono'),
        '+591 700 00002',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Guardar'));
      await tester.pumpAndSettle();

      expect(find.text('Bruno Rider'), findsOneWidget);
    });

    testWidgets('enabling the WhatsApp switch is reflected on the tile', (
      tester,
    ) async {
      await pumpContactsPage(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'),
        'Bruno Rider',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Teléfono'),
        '+591 700 00002',
      );
      await tester.tap(
        find.widgetWithText(SwitchListTile, 'Notificar por WhatsApp'),
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Guardar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('WhatsApp'), findsOneWidget);
    });

    testWidgets('requires name and phone before saving', (tester) async {
      await pumpContactsPage(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(ElevatedButton, 'Guardar');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Ingresa el nombre.'), findsOneWidget);
      expect(find.text('Ingresa el teléfono.'), findsOneWidget);
      expect(fakeContactRepository.contacts, isEmpty);
    });

    testWidgets('deletes a contact after confirming', (tester) async {
      fakeContactRepository.contacts = [_contact()];
      await pumpContactsPage(tester);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Eliminar'));
      await tester.pumpAndSettle();

      expect(find.text('María Rider'), findsNothing);
      expect(
        find.text('Todavía no agregaste ningún contacto de emergencia.'),
        findsOneWidget,
      );
    });
  });
}
