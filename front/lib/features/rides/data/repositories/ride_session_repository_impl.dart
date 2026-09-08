import '../../../../core/errors/app_exception.dart';
import '../../../../core/extensions/nullable_extensions.dart';
import '../../domain/entities/ride_history_entry.dart';
import '../../domain/entities/ride_session.dart';
import '../../domain/entities/ride_session_participant.dart';
import '../../domain/repositories/ride_session_repository.dart';
import '../datasources/ride_session_remote_datasource.dart';

class RideSessionRepositoryImpl implements RideSessionRepository {
  RideSessionRepositoryImpl(this._remoteDataSource);

  final RideSessionRemoteDataSource _remoteDataSource;

  @override
  Future<RideSession?> fetchActiveSession(String groupId) => _guard(() async {
    final row = await _remoteDataSource.fetchActiveSession(groupId);
    return row == null ? null : RideSession.fromJson(row);
  });

  @override
  Future<RideSession> fetchSession(String sessionId) => _guard(() async {
    final row = await _remoteDataSource.fetchSession(sessionId);
    return RideSession.fromJson(row);
  });

  @override
  Future<List<RideSessionParticipant>> fetchParticipants(
    String sessionId,
  ) => _guard(() async {
    final memberRows = await _remoteDataSource.fetchParticipants(sessionId);
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
          return RideSessionParticipant(
            sessionId: row['session_id'] as String,
            userId: userId,
            status: RideParticipantStatus.values.byName(
              row['status'] as String,
            ),
            joinedAt: DateTime.parse(row['joined_at'] as String),
            leftAt: (row['left_at'] as String?).let(DateTime.parse),
            lastSeenAt: (row['last_seen_at'] as String?).let(DateTime.parse),
            // Falls back to a placeholder rather than throwing — see the
            // matching comment in GroupRepositoryImpl.fetchMembers.
            displayName: profile?['display_name'] as String? ?? 'Motociclista',
            avatarUrl: profile?['avatar_url'] as String?,
          );
        })
        .toList(growable: false);
  });

  @override
  Future<RideSession> startSession({required String groupId, String? name}) =>
      _guard(() async {
        final row = await _remoteDataSource.startSession(
          groupId: groupId,
          name: name,
        );
        return RideSession.fromJson(row);
      });

  @override
  Future<RideSession> finishSession(String sessionId) => _guard(() async {
    final row = await _remoteDataSource.finishSession(sessionId);
    return RideSession.fromJson(row);
  });

  @override
  Future<List<RideHistoryEntry>> fetchHistory(String userId) =>
      _guard(() async {
        final rows = await _remoteDataSource.fetchHistoryRows(userId);
        final entries = rows
            .map((row) => row['ride_sessions'] as Map<String, dynamic>?)
            // A member row whose session RLS no longer surfaces (e.g. the
            // caller has since left the group) embeds as null rather than
            // failing the whole query — skip it instead of throwing.
            .whereType<Map<String, dynamic>>()
            .where((session) => session['status'] == 'finished')
            .map((session) {
              final group = session['ride_groups'] as Map<String, dynamic>?;
              return RideHistoryEntry(
                sessionId: session['id'] as String,
                groupId: session['group_id'] as String,
                groupName: group?['name'] as String? ?? 'Grupo',
                name: session['name'] as String?,
                status: RideSessionStatus.values.byName(
                  session['status'] as String,
                ),
                startedAt: DateTime.parse(session['started_at'] as String),
                endedAt: (session['ended_at'] as String?).let(DateTime.parse),
              );
            })
            .toList();
        entries.sort((a, b) => b.startedAt.compareTo(a.startedAt));
        return entries;
      });

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (error) {
      throw DataException(_messageFor(error), cause: error);
    } catch (error) {
      throw DataException(
        'No se pudo completar la operación sobre el viaje.',
        cause: error,
      );
    }
  }

  static String _messageFor(ApiException error) {
    // Domain errors raised by back/src/services/ride.service.ts — same
    // message strings the old SQL RPC functions used to raise. Checked
    // before the generic statusCode fallback below so these keep their
    // specific wording instead of collapsing into "no tienes permiso".
    final message = error.message;
    if (message ==
            'only the group owner or an admin can start a ride session' ||
        message ==
            'only the group owner or an admin can finish this ride session') {
      return 'Solo el propietario o un admin del grupo puede hacer esto.';
    }
    if (message == 'this group already has an active ride session') {
      return 'Este grupo ya tiene un viaje en curso.';
    }
    if (message == 'ride session not found') {
      return 'Viaje no encontrado.';
    }
    if (message.startsWith('this ride session is already ')) {
      return 'Este viaje ya no está activo.';
    }

    switch (error.statusCode) {
      case 403:
        return 'No tienes permiso para realizar esta acción.';
      case 404:
        return 'Viaje no encontrado.';
      default:
        return message;
    }
  }
}
