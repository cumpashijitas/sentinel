import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/datasources/emergency_contact_remote_datasource.dart';
import '../../data/repositories/emergency_contact_repository_impl.dart';
import '../../domain/entities/emergency_contact.dart';
import '../../domain/repositories/emergency_contact_repository.dart';

part 'emergency_contacts_controller.g.dart';

@riverpod
EmergencyContactRemoteDataSource emergencyContactRemoteDataSource(Ref ref) {
  return HttpEmergencyContactRemoteDataSource(ref.watch(apiClientProvider));
}

@Riverpod(keepAlive: true)
EmergencyContactRepository emergencyContactRepository(Ref ref) {
  return EmergencyContactRepositoryImpl(
    ref.watch(emergencyContactRemoteDataSourceProvider),
  );
}

/// The signed-in user's own emergency contacts. Invalidated by
/// [EmergencyContactFormController] after any successful
/// create/update/delete.
@riverpod
Future<List<EmergencyContact>> emergencyContacts(Ref ref) async {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) return const [];
  return ref.watch(emergencyContactRepositoryProvider).fetchContacts(user.id);
}

/// Drives create/update/delete for a single emergency contact. Same shape
/// as [VehicleFormController]: the state is only the *action's* outcome,
/// not the list — read that from [emergencyContactsProvider].
@riverpod
class EmergencyContactFormController extends _$EmergencyContactFormController {
  @override
  FutureOr<void> build() {}

  Future<void> create({
    required String name,
    required String phone,
    String? relationship,
    required bool notifyPush,
    required bool notifySms,
    required bool notifyWhatsapp,
  }) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      state = AsyncError(
        StateError('cannot create a contact without an authenticated user'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(emergencyContactRepositoryProvider)
          .createContact(
            ownerId: user.id,
            name: name,
            phone: phone,
            relationship: relationship,
            notifyPush: notifyPush,
            notifySms: notifySms,
            notifyWhatsapp: notifyWhatsapp,
          );
      ref.invalidate(emergencyContactsProvider);
    });
  }

  Future<void> updateContact({
    required String id,
    required String name,
    required String phone,
    String? relationship,
    required bool notifyPush,
    required bool notifySms,
    required bool notifyWhatsapp,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(emergencyContactRepositoryProvider)
          .updateContact(
            id: id,
            name: name,
            phone: phone,
            relationship: relationship,
            notifyPush: notifyPush,
            notifySms: notifySms,
            notifyWhatsapp: notifyWhatsapp,
          );
      ref.invalidate(emergencyContactsProvider);
    });
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(emergencyContactRepositoryProvider).deleteContact(id);
      ref.invalidate(emergencyContactsProvider);
    });
  }
}
