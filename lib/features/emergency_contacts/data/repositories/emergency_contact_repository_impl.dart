import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/emergency_contact.dart';
import '../../domain/repositories/emergency_contact_repository.dart';
import '../datasources/emergency_contact_remote_datasource.dart';

class EmergencyContactRepositoryImpl implements EmergencyContactRepository {
  EmergencyContactRepositoryImpl(this._remoteDataSource);

  final EmergencyContactRemoteDataSource _remoteDataSource;

  @override
  Future<List<EmergencyContact>> fetchContacts(String ownerId) =>
      _guard(() async {
        final rows = await _remoteDataSource.fetchContacts(ownerId);
        return rows.map(EmergencyContact.fromJson).toList(growable: false);
      });

  @override
  Future<EmergencyContact> createContact({
    required String ownerId,
    required String name,
    required String phone,
    String? relationship,
    required bool notifyPush,
    required bool notifySms,
    required bool notifyWhatsapp,
  }) => _guard(() async {
    final row = await _remoteDataSource.createContact(
      ownerId: ownerId,
      name: name,
      phone: phone,
      relationship: relationship,
      notifyPush: notifyPush,
      notifySms: notifySms,
      notifyWhatsapp: notifyWhatsapp,
    );
    return EmergencyContact.fromJson(row);
  });

  @override
  Future<EmergencyContact> updateContact({
    required String id,
    required String name,
    required String phone,
    String? relationship,
    required bool notifyPush,
    required bool notifySms,
    required bool notifyWhatsapp,
  }) => _guard(() async {
    final row = await _remoteDataSource.updateContact(
      id: id,
      name: name,
      phone: phone,
      relationship: relationship,
      notifyPush: notifyPush,
      notifySms: notifySms,
      notifyWhatsapp: notifyWhatsapp,
    );
    return EmergencyContact.fromJson(row);
  });

  @override
  Future<void> deleteContact(String id) =>
      _guard(() => _remoteDataSource.deleteContact(id));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (error) {
      throw DataException(_messageFor(error), cause: error);
    } catch (error) {
      throw DataException(
        'No se pudo completar la operación sobre el contacto.',
        cause: error,
      );
    }
  }

  static String _messageFor(PostgrestException error) {
    switch (error.code) {
      case '42501':
        return 'No tienes permiso para realizar esta acción.';
      case 'PGRST116':
        return 'Contacto no encontrado.';
      default:
        return error.message;
    }
  }
}
