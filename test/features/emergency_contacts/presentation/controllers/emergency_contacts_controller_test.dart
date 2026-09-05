import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/auth/domain/entities/app_user.dart';
import 'package:sentinel_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:sentinel_v2/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sentinel_v2/features/emergency_contacts/domain/entities/emergency_contact.dart';
import 'package:sentinel_v2/features/emergency_contacts/domain/repositories/emergency_contact_repository.dart';
import 'package:sentinel_v2/features/emergency_contacts/presentation/controllers/emergency_contacts_controller.dart';

const _currentUser = AppUser(id: 'u1', email: 'rider1@sentinel.dev');

class _FakeAuthRepository implements AuthRepository {
  AppUser? userOverride = _currentUser;

  @override
  AppUser? get currentUser => userOverride;

  @override
  Stream<AppUser?> get authStateChanges =>
      Stream.value(userOverride).asBroadcastStream();

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

EmergencyContact _contact({String id = 'c1', String name = 'María Rider'}) =>
    EmergencyContact(
      id: id,
      ownerId: 'u1',
      name: name,
      phone: '+591 700 09999',
      notifyPush: true,
      notifySms: false,
      notifyWhatsapp: false,
      createdAt: DateTime.utc(2026, 8, 27),
      updatedAt: DateTime.utc(2026, 8, 27),
    );

class _FakeEmergencyContactRepository implements EmergencyContactRepository {
  List<EmergencyContact> contacts = [];
  Object? errorToThrow;
  String? lastDeletedId;

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
    final error = errorToThrow;
    if (error != null) throw error;
    final created = _contact(id: 'c${contacts.length + 1}', name: name);
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
  }) async {
    final updated = _contact(id: id, name: name);
    contacts = [
      for (final c in contacts)
        if (c.id == id) updated else c,
    ];
    return updated;
  }

  @override
  Future<void> deleteContact(String id) async {
    lastDeletedId = id;
    contacts = contacts.where((c) => c.id != id).toList();
  }
}

void main() {
  late _FakeAuthRepository fakeAuthRepository;
  late _FakeEmergencyContactRepository fakeContactRepository;
  late ProviderContainer container;

  setUp(() {
    fakeAuthRepository = _FakeAuthRepository();
    fakeContactRepository = _FakeEmergencyContactRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        emergencyContactRepositoryProvider.overrideWithValue(
          fakeContactRepository,
        ),
      ],
    );
    addTearDown(container.dispose);

    // See docs/architecture.md: a bare ProviderContainer needs an active
    // listener to keep an async provider alive across an `await`.
    container.listen(emergencyContactsProvider, (_, _) {});
  });

  group('emergencyContactsProvider', () {
    test('returns an empty list for a user with no contacts', () async {
      final contacts = await container.read(emergencyContactsProvider.future);
      expect(contacts, isEmpty);
    });
  });

  group('EmergencyContactFormController', () {
    test('create() adds a contact and refreshes the list', () async {
      await container.read(emergencyContactsProvider.future);

      await container
          .read(emergencyContactFormControllerProvider.notifier)
          .create(
            name: 'María Rider',
            phone: '+591 700 09999',
            notifyPush: true,
            notifySms: false,
            notifyWhatsapp: false,
          );

      final contacts = await container.read(emergencyContactsProvider.future);
      expect(contacts, hasLength(1));
      expect(contacts.single.name, 'María Rider');
    });

    test('updateContact() edits and refreshes the list', () async {
      fakeContactRepository.contacts = [_contact()];
      await container.read(emergencyContactsProvider.future);

      await container
          .read(emergencyContactFormControllerProvider.notifier)
          .updateContact(
            id: 'c1',
            name: 'Nuevo Nombre',
            phone: '+591 700 09999',
            notifyPush: true,
            notifySms: true,
            notifyWhatsapp: true,
          );

      final contacts = await container.read(emergencyContactsProvider.future);
      expect(contacts.single.name, 'Nuevo Nombre');
    });

    test('delete() removes the contact and refreshes the list', () async {
      fakeContactRepository.contacts = [_contact()];
      await container.read(emergencyContactsProvider.future);

      await container
          .read(emergencyContactFormControllerProvider.notifier)
          .delete('c1');

      expect(fakeContactRepository.lastDeletedId, 'c1');
      final contacts = await container.read(emergencyContactsProvider.future);
      expect(contacts, isEmpty);
    });

    test('create() fails fast without an authenticated user', () async {
      fakeAuthRepository.userOverride = null;

      await container
          .read(emergencyContactFormControllerProvider.notifier)
          .create(
            name: 'María Rider',
            phone: '+591 700 09999',
            notifyPush: true,
            notifySms: false,
            notifyWhatsapp: false,
          );

      expect(
        container.read(emergencyContactFormControllerProvider).hasError,
        isTrue,
      );
      expect(fakeContactRepository.contacts, isEmpty);
    });
  });
}
