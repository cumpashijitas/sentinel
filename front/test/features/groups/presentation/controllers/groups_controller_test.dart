import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/auth/domain/entities/app_user.dart';
import 'package:sentinel_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:sentinel_v2/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sentinel_v2/features/groups/domain/entities/group_member.dart';
import 'package:sentinel_v2/features/groups/domain/entities/ride_group.dart';
import 'package:sentinel_v2/features/groups/domain/repositories/group_repository.dart';
import 'package:sentinel_v2/features/groups/presentation/controllers/groups_controller.dart';

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

RideGroup _group({String id = 'g1', String name = 'Ruta de los Domingos'}) =>
    RideGroup(
      id: id,
      ownerId: 'u1',
      name: name,
      inviteCode: 'SUNDAY01',
      status: RideGroupStatus.active,
      createdAt: DateTime.utc(2026, 8, 27),
      updatedAt: DateTime.utc(2026, 8, 27),
    );

class _FakeGroupRepository implements GroupRepository {
  List<RideGroup> groups = [];
  Object? errorToThrow;
  String? lastLeftGroupId;

  @override
  Future<List<RideGroup>> fetchMyGroups(String userId) async => groups;

  @override
  Future<RideGroup> fetchGroup(String groupId) async =>
      groups.firstWhere((g) => g.id == groupId);

  @override
  Future<List<GroupMember>> fetchMembers(String groupId) async => const [];

  @override
  Future<RideGroup> createGroup({
    required String name,
    String? description,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    final created = _group(id: 'g${groups.length + 1}', name: name);
    groups = [...groups, created];
    return created;
  }

  @override
  Future<RideGroup> updateGroup({
    required String groupId,
    required String name,
    String? description,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    final updated = groups
        .firstWhere((g) => g.id == groupId)
        .copyWith(name: name, description: description);
    groups = [
      for (final g in groups) if (g.id == groupId) updated else g,
    ];
    return updated;
  }

  @override
  Future<String> joinGroupByCode(String inviteCode) async {
    final error = errorToThrow;
    if (error != null) throw error;
    final joined = _group(id: 'joined-group');
    groups = [...groups, joined];
    return joined.id;
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    lastLeftGroupId = groupId;
    groups = groups.where((g) => g.id != groupId).toList();
  }

  @override
  Future<void> setMemberRole({
    required String groupId,
    required String targetUserId,
    required GroupMemberRole role,
  }) => throw UnimplementedError();

  @override
  Future<void> removeMember({
    required String groupId,
    required String targetUserId,
  }) => throw UnimplementedError();

  @override
  Future<RideGroup> setPinnedNote({required String groupId, String? note}) =>
      throw UnimplementedError();
}

void main() {
  late _FakeAuthRepository fakeAuthRepository;
  late _FakeGroupRepository fakeGroupRepository;
  late ProviderContainer container;

  setUp(() {
    fakeAuthRepository = _FakeAuthRepository();
    fakeGroupRepository = _FakeGroupRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        groupRepositoryProvider.overrideWithValue(fakeGroupRepository),
      ],
    );
    addTearDown(container.dispose);

    // See docs/architecture.md: a bare ProviderContainer needs an active
    // listener to keep an async provider alive across an `await`.
    container.listen(myGroupsProvider, (_, _) {});
  });

  group('GroupActionsController.create', () {
    test('returns the created group and refreshes myGroupsProvider', () async {
      await container.read(myGroupsProvider.future);

      final created = await container
          .read(groupActionsControllerProvider.notifier)
          .create(name: 'Ruta de los Domingos');

      expect(created?.name, 'Ruta de los Domingos');
      final groups = await container.read(myGroupsProvider.future);
      expect(groups, hasLength(1));
    });

    test('returns null and sets an error on failure', () async {
      fakeGroupRepository.errorToThrow = Exception('boom');

      final created = await container
          .read(groupActionsControllerProvider.notifier)
          .create(name: 'Ruta de los Domingos');

      expect(created, isNull);
      expect(container.read(groupActionsControllerProvider).hasError, isTrue);
    });
  });

  group('GroupActionsController.joinByCode', () {
    test(
      'returns the joined group id and refreshes myGroupsProvider',
      () async {
        await container.read(myGroupsProvider.future);

        final groupId = await container
            .read(groupActionsControllerProvider.notifier)
            .joinByCode('SUNDAY01');

        expect(groupId, 'joined-group');
        final groups = await container.read(myGroupsProvider.future);
        expect(groups.map((g) => g.id), contains('joined-group'));
      },
    );
  });

  group('GroupActionsController.leave', () {
    test('removes the group and refreshes myGroupsProvider', () async {
      fakeGroupRepository.groups = [_group()];
      await container.read(myGroupsProvider.future);

      await container.read(groupActionsControllerProvider.notifier).leave('g1');

      expect(fakeGroupRepository.lastLeftGroupId, 'g1');
      final groups = await container.read(myGroupsProvider.future);
      expect(groups, isEmpty);
    });
  });
}
