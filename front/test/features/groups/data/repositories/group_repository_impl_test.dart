import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/errors/app_exception.dart';
import 'package:sentinel_v2/features/groups/data/datasources/group_remote_datasource.dart';
import 'package:sentinel_v2/features/groups/data/repositories/group_repository_impl.dart';
import 'package:sentinel_v2/features/groups/domain/entities/group_member.dart';

Map<String, dynamic> _groupRow({String id = 'g1'}) => {
  'id': id,
  'owner_id': 'u1',
  'name': 'Ruta de los Domingos',
  'description': null,
  'invite_code': 'SUNDAY01',
  'status': 'active',
  'created_at': '2026-08-27T12:00:00.000Z',
  'updated_at': '2026-08-27T12:00:00.000Z',
};

Map<String, dynamic> _memberRow({
  String userId = 'u1',
  String role = 'owner',
}) => {
  'group_id': 'g1',
  'user_id': userId,
  'role': role,
  'status': 'active',
  'joined_at': '2026-08-27T12:00:00.000Z',
  'left_at': null,
};

Map<String, dynamic> _profileRow({
  String id = 'u1',
  String displayName = 'Ana Rider',
}) => {'id': id, 'display_name': displayName, 'avatar_url': null};

class _FakeGroupRemoteDataSource implements GroupRemoteDataSource {
  List<Map<String, dynamic>> myGroupsToReturn = [];
  Map<String, dynamic>? groupToReturn;
  List<Map<String, dynamic>> membersToReturn = [];
  List<Map<String, dynamic>> profilesToReturn = [];
  String? groupIdToReturn;
  Object? errorToThrow;

  @override
  Future<List<Map<String, dynamic>>> fetchMyGroups() async {
    final error = errorToThrow;
    if (error != null) throw error;
    return myGroupsToReturn;
  }

  @override
  Future<Map<String, dynamic>> fetchGroup(String groupId) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return groupToReturn!;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchMembers(String groupId) async =>
      membersToReturn;

  @override
  Future<List<Map<String, dynamic>>> fetchProfiles(
    List<String> userIds,
  ) async => profilesToReturn.where((p) => userIds.contains(p['id'])).toList();

  @override
  Future<Map<String, dynamic>> createGroup({
    required String name,
    String? description,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return groupToReturn!;
  }

  @override
  Future<Map<String, dynamic>> updateGroup({
    required String groupId,
    required String name,
    String? description,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return groupToReturn!;
  }

  @override
  Future<String> joinGroupByCode(String inviteCode) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return groupIdToReturn!;
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    final error = errorToThrow;
    if (error != null) throw error;
  }

  @override
  Future<Map<String, dynamic>> setMemberRole({
    required String groupId,
    required String targetUserId,
    required String role,
  }) => throw UnimplementedError();

  @override
  Future<void> removeMember({
    required String groupId,
    required String targetUserId,
  }) => throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> setPinnedNote({
    required String groupId,
    String? note,
  }) => throw UnimplementedError();
}

void main() {
  late _FakeGroupRemoteDataSource dataSource;
  late GroupRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeGroupRemoteDataSource();
    repository = GroupRepositoryImpl(dataSource);
  });

  group('GroupRepositoryImpl', () {
    test('fetchMyGroups maps every row to a RideGroup', () async {
      dataSource.myGroupsToReturn = [_groupRow()];

      final groups = await repository.fetchMyGroups('u1');

      expect(groups, hasLength(1));
      expect(groups.single.name, 'Ruta de los Domingos');
    });

    test('fetchMembers merges membership rows with profile data', () async {
      dataSource.membersToReturn = [
        _memberRow(),
        _memberRow(userId: 'u2', role: 'member'),
      ];
      dataSource.profilesToReturn = [
        _profileRow(),
        _profileRow(id: 'u2', displayName: 'Bruno Rider'),
      ];

      final members = await repository.fetchMembers('g1');

      expect(members, hasLength(2));
      expect(members[0].displayName, 'Ana Rider');
      expect(members[0].role, GroupMemberRole.owner);
      expect(members[1].displayName, 'Bruno Rider');
      expect(members[1].role, GroupMemberRole.member);
    });

    test(
      'fetchMembers falls back to a placeholder name for a missing profile',
      () async {
        dataSource.membersToReturn = [_memberRow(userId: 'u9')];
        dataSource.profilesToReturn = []; // no matching profile row

        final members = await repository.fetchMembers('g1');

        expect(members.single.displayName, 'Motociclista');
      },
    );

    test('createGroup returns the created RideGroup', () async {
      dataSource.groupToReturn = _groupRow();

      final group = await repository.createGroup(name: 'Ruta de los Domingos');

      expect(group.name, 'Ruta de los Domingos');
    });

    test('joinGroupByCode returns the joined group id', () async {
      dataSource.groupIdToReturn = 'g1';

      final groupId = await repository.joinGroupByCode('SUNDAY01');

      expect(groupId, 'g1');
    });

    test(
      'translates the RPC "invalid invite code" message to Spanish',
      () async {
        dataSource.errorToThrow = const ApiException(
          'invalid invite code',
          statusCode: 404,
        );

        await expectLater(
          () => repository.joinGroupByCode('NOTREAL1'),
          throwsA(
            isA<DataException>().having(
              (e) => e.message,
              'message',
              'El código de invitación no es válido.',
            ),
          ),
        );
      },
    );

    test(
      'translates the RPC "owner cannot leave" message to Spanish',
      () async {
        dataSource.errorToThrow = const ApiException(
          'the group owner cannot leave; transfer ownership or archive the group first',
          statusCode: 409,
        );

        await expectLater(
          () => repository.leaveGroup('g1'),
          throwsA(
            isA<DataException>().having(
              (e) => e.message,
              'message',
              'El propietario no puede abandonar el grupo. Transfiere la propiedad o archívalo primero.',
            ),
          ),
        );
      },
    );

    test('passes through an unrecognized error message as-is', () async {
      dataSource.errorToThrow = const ApiException('some unexpected database error');

      await expectLater(
        () => repository.leaveGroup('g1'),
        throwsA(
          isA<DataException>().having(
            (e) => e.message,
            'message',
            'some unexpected database error',
          ),
        ),
      );
    });
  });
}
