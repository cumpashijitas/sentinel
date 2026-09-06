import '../../../../core/errors/app_exception.dart';
import '../../../../core/extensions/nullable_extensions.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/ride_group.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/group_remote_datasource.dart';

class GroupRepositoryImpl implements GroupRepository {
  GroupRepositoryImpl(this._remoteDataSource);

  final GroupRemoteDataSource _remoteDataSource;

  @override
  Future<List<RideGroup>> fetchMyGroups(String userId) => _guard(() async {
    final rows = await _remoteDataSource.fetchMyGroups();
    return rows.map(RideGroup.fromJson).toList(growable: false);
  });

  @override
  Future<RideGroup> fetchGroup(String groupId) => _guard(() async {
    final row = await _remoteDataSource.fetchGroup(groupId);
    return RideGroup.fromJson(row);
  });

  @override
  Future<List<GroupMember>> fetchMembers(String groupId) => _guard(() async {
    final memberRows = await _remoteDataSource.fetchMembers(groupId);
    final userIds = memberRows
        .map((row) => row['user_id'] as String)
        .toList(growable: false);
    final profileRows = await _remoteDataSource.fetchProfiles(userIds);
    final profilesById = {
      for (final row in profileRows) row['id'] as String: row,
    };

    return memberRows
        .map((row) {
          final userId = row['user_id'] as String;
          final profile = profilesById[userId];
          return GroupMember(
            groupId: row['group_id'] as String,
            userId: userId,
            role: GroupMemberRole.values.byName(row['role'] as String),
            status: GroupMemberStatus.values.byName(row['status'] as String),
            joinedAt: DateTime.parse(row['joined_at'] as String),
            leftAt: (row['left_at'] as String?).let(DateTime.parse),
            // Falls back to a placeholder rather than throwing: a profile row
            // should always exist (created by the on_auth_user_created
            // trigger), but a roster is more useful degraded than blank on an
            // unexpected gap.
            displayName: profile?['display_name'] as String? ?? 'Motociclista',
            avatarUrl: profile?['avatar_url'] as String?,
          );
        })
        .toList(growable: false);
  });

  @override
  Future<RideGroup> createGroup({required String name, String? description}) =>
      _guard(() async {
        final row = await _remoteDataSource.createGroup(
          name: name,
          description: description,
        );
        return RideGroup.fromJson(row);
      });

  @override
  Future<String> joinGroupByCode(String inviteCode) =>
      _guard(() => _remoteDataSource.joinGroupByCode(inviteCode));

  @override
  Future<void> leaveGroup(String groupId) =>
      _guard(() => _remoteDataSource.leaveGroup(groupId));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (error) {
      throw DataException(_messageFor(error), cause: error);
    } catch (error) {
      throw DataException(
        'No se pudo completar la operación sobre el grupo.',
        cause: error,
      );
    }
  }

  static String _messageFor(ApiException error) {
    // Domain errors raised by back/src/services/group.service.ts — same
    // message strings the old SQL RPC functions (create_ride_group /
    // join_group_by_code / leave_group) used to raise, kept unchanged on
    // purpose so this translation didn't need to move. Checked *before*
    // the generic statusCode fallback below: some of these (e.g. "invalid
    // invite code") share a statusCode with unrelated cases (plain "group
    // not found"), so the specific message must win first.
    switch (error.message) {
      case 'group name is required':
        return 'Ingresa un nombre para el grupo.';
      case 'invalid invite code':
        return 'El código de invitación no es válido.';
      case 'this group is not accepting new members':
        return 'Este grupo ya no acepta nuevos integrantes.';
      case 'you are not an active member of this group':
        return 'No eres integrante activo de este grupo.';
      case 'the group owner cannot leave; transfer ownership or archive the group first':
        return 'El propietario no puede abandonar el grupo. Transfiere la propiedad o archívalo primero.';
    }

    switch (error.statusCode) {
      case 403:
        return 'No tienes permiso para realizar esta acción.';
      case 404:
        return 'Grupo no encontrado.';
      default:
        return error.message;
    }
  }
}
