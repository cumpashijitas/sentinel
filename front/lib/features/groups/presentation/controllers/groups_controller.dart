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
