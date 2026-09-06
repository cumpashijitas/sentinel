import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/errors/app_exception.dart';
import 'package:sentinel_v2/features/emergency_contacts/data/datasources/emergency_contact_remote_datasource.dart';
import 'package:sentinel_v2/features/emergency_contacts/data/repositories/emergency_contact_repository_impl.dart';

Map<String, dynamic> _row({String id = 'c1'}) => {
  'id': id,
  'owner_id': 'u1',
  'contact_user_id': null,
  'name': 'María Rider',
  'phone': '+591 700 09999',
  'relationship': 'Familiar',
  'notify_push': true,
  'notify_sms': false,
  'notify_whatsapp': false,
  'created_at': '2026-08-27T12:00:00.000Z',
  'updated_at': '2026-08-27T12:00:00.000Z',
};

class _FakeEmergencyContactRemoteDataSource
    implements EmergencyContactRemoteDataSource {
  List<Map<String, dynamic>> rowsToReturn = [];
  Map<String, dynamic>? rowToReturn;
  Object? errorToThrow;
  String? lastDeletedId;

  @override
  Future<List<Map<String, dynamic>>> fetchContacts(String ownerId) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return rowsToReturn;
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
    final error = errorToThrow;
    if (error != null) throw error;
    return rowToReturn!;
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
    final error = errorToThrow;
    if (error != null) throw error;
    return rowToReturn!;
  }

  @override
  Future<void> deleteContact(String id) async {
    lastDeletedId = id;
    final error = errorToThrow;
    if (error != null) throw error;
  }
}

void main() {
  late _FakeEmergencyContactRemoteDataSource dataSource;
  late EmergencyContactRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeEmergencyContactRemoteDataSource();
    repository = EmergencyContactRepositoryImpl(dataSource);
  });

  group('EmergencyContactRepositoryImpl', () {
    test('fetchContacts maps every row to an EmergencyContact', () async {
      dataSource.rowsToReturn = [_row(), _row(id: 'c2')];

      final contacts = await repository.fetchContacts('u1');

      expect(contacts, hasLength(2));
      expect(contacts.map((c) => c.id), ['c1', 'c2']);
    });

    test('createContact returns the created contact', () async {
      dataSource.rowToReturn = _row();

      final contact = await repository.createContact(
        ownerId: 'u1',
        name: 'María Rider',
        phone: '+591 700 09999',
        notifyPush: true,
        notifySms: false,
        notifyWhatsapp: false,
      );

      expect(contact.name, 'María Rider');
    });

    test('deleteContact forwards the id to the datasource', () async {
      await repository.deleteContact('c1');

      expect(dataSource.lastDeletedId, 'c1');
    });

    test('translates a permission-denied ApiException', () async {
      dataSource.errorToThrow = const ApiException('permission denied', statusCode: 403);

      await expectLater(
        () => repository.deleteContact('not-mine'),
        throwsA(
          isA<DataException>().having(
            (e) => e.message,
            'message',
            'No tienes permiso para realizar esta acción.',
          ),
        ),
      );
    });
  });
}
