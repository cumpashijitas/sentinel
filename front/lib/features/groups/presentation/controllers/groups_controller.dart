import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/datasources/group_remote_datasource.dart';
import '../../data/repositories/group_repository_impl.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/ride_group.dart';
import '../../domain/repositories/group_repository.dart';

part 'groups_controller.g.dart';

@riverpod
GroupRemoteDataSource groupRemoteDataSource(Ref ref) {
  return HttpGroupRemoteDataSource(ref.watch(apiClientProvider));
}

@Riverpod(keepAlive: true)
GroupRepository groupRepository(Ref ref) {
  return GroupRepositoryImpl(ref.watch(groupRemoteDataSourceProvider));
}

/// Groups the signed-in user belongs to. Invalidated by
/// [GroupActionsController] after creating, joining, or leaving a group.
@riverpod
Future<List<RideGroup>> myGroups(Ref ref) async {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) return const [];
  return ref.watch(groupRepositoryProvider).fetchMyGroups(user.id);
}

/// A single group's details, by id.
///
/// Named `groupDetail` rather than `group` — `group` collides with
/// `package:flutter_test`'s top-level test-grouping function in any test
/// file that imports both this provider and `flutter_test`.
@riverpod
Future<RideGroup> groupDetail(Ref ref, String groupId) {
  return ref.watch(groupRepositoryProvider).fetchGroup(groupId);
}

/// The roster of a single group, by id.
@riverpod
Future<List<GroupMember>> groupMembers(Ref ref, String groupId) {
  return ref.watch(groupRepositoryProvider).fetchMembers(groupId);
}

/// Drives create/join/leave. Same shape as [ProfileController] (state is
/// only the action's own loading/error/success), but each method also
/// *returns* the value the UI needs right away — the created group, or the
/// joined group's id — so the page can navigate to it without a second
/// round trip through a provider.
@riverpod
class GroupActionsController extends _$GroupActionsController {
  @override
  FutureOr<void> build() {}

  Future<RideGroup?> create({required String name, String? description}) async {
    state = const AsyncLoading();
    RideGroup? created;
    state = await AsyncValue.guard(() async {
      created = await ref
          .read(groupRepositoryProvider)
          .createGroup(name: name, description: description);
      ref.invalidate(myGroupsProvider);
    });
    return state.hasError ? null : created;
  }

  Future<String?> joinByCode(String inviteCode) async {
    state = const AsyncLoading();
    String? groupId;
    state = await AsyncValue.guard(() async {
      groupId = await ref
          .read(groupRepositoryProvider)
          .joinGroupByCode(inviteCode);
      ref.invalidate(myGroupsProvider);
    });
    return state.hasError ? null : groupId;
  }

  Future<void> leave(String groupId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(groupRepositoryProvider).leaveGroup(groupId);
      ref.invalidate(myGroupsProvider);
      ref.invalidate(groupMembersProvider(groupId));
    });
  }
}

/// Bug real encontrado en vivo: `edit` vivía antes en
/// [GroupActionsController], compartiendo `state` con `leave` — y
/// `GroupDetailPage` tiene un `ref.listen(groupActionsControllerProvider,
/// ...)` que hace `context.pop()` en cuanto ve loading→data, escrito
/// pensando solo en "salir del grupo terminó, volvé a la lista". Guardar
/// una edición también dispara loading→data en ese mismo provider, así que
/// ese listener se activaba igual y sacaba a la persona de la pantalla
/// (o competía con el propio `Navigator.pop()` del sheet de edición) justo
/// al guardar — el "se traba y no hace nada" reportado en vivo. Un
/// controlador separado, que nadie más escucha, corta esa interferencia.
@riverpod
class GroupEditController extends _$GroupEditController {
  @override
  FutureOr<void> build() {}

  Future<RideGroup?> edit({
    required String groupId,
    required String name,
    String? description,
  }) async {
    state = const AsyncLoading();
    RideGroup? updated;
    state = await AsyncValue.guard(() async {
      updated = await ref
          .read(groupRepositoryProvider)
          .updateGroup(groupId: groupId, name: name, description: description);
      ref.invalidate(myGroupsProvider);
      ref.invalidate(groupDetailProvider(groupId));
    });
    return state.hasError ? null : updated;
  }
}

/// Asignar/quitar admin y expulsar integrantes — controlador propio, no
/// compartido con [GroupActionsController]/[GroupEditController], mismo
/// motivo que [GroupEditController]: `GroupDetailPage` escucha el `state`
/// de `GroupActionsController` para saber cuándo "salir del grupo"
/// terminó y sacar al usuario de la pantalla — una acción de member
/// management disparando ese mismo listener por accidente sería
/// exactamente el bug ya encontrado una vez.
@riverpod
class GroupMemberActionsController extends _$GroupMemberActionsController {
  @override
  FutureOr<void> build() {}

  Future<bool> setRole({
    required String groupId,
    required String targetUserId,
    required GroupMemberRole role,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(groupRepositoryProvider)
          .setMemberRole(
            groupId: groupId,
            targetUserId: targetUserId,
            role: role,
          );
      ref.invalidate(groupMembersProvider(groupId));
    });
    return !state.hasError;
  }

  Future<bool> remove({
    required String groupId,
    required String targetUserId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(groupRepositoryProvider)
          .removeMember(groupId: groupId, targetUserId: targetUserId);
      ref.invalidate(groupMembersProvider(groupId));
    });
    return !state.hasError;
  }
}

/// El aviso fijado del grupo — controlador propio por la misma razón que
/// [GroupEditController].
@riverpod
class GroupNoteController extends _$GroupNoteController {
  @override
  FutureOr<void> build() {}

  Future<RideGroup?> setNote({required String groupId, String? note}) async {
    state = const AsyncLoading();
    RideGroup? updated;
    state = await AsyncValue.guard(() async {
      updated = await ref
          .read(groupRepositoryProvider)
          .setPinnedNote(groupId: groupId, note: note);
      ref.invalidate(groupDetailProvider(groupId));
    });
    return state.hasError ? null : updated;
  }
}
