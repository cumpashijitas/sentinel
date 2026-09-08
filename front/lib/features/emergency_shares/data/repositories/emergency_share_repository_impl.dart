import '../../../../core/errors/app_exception.dart';
import '../../../rides/domain/entities/location_fix.dart';
import '../../domain/entities/emergency_share.dart';
import '../../domain/repositories/emergency_share_repository.dart';
import '../datasources/emergency_share_remote_datasource.dart';

class EmergencyShareRepositoryImpl implements EmergencyShareRepository {
  EmergencyShareRepositoryImpl(this._remoteDataSource);

  final EmergencyShareRemoteDataSource _remoteDataSource;

  @override
  Future<EmergencyShare?> fetchActiveShare() => _guard(() async {
    final row = await _remoteDataSource.fetchActiveShare();
    return row == null ? null : EmergencyShare.fromJson(row);
  });

  @override
  Future<EmergencyShare> startShare() => _guard(() async {
    final row = await _remoteDataSource.startShare();
    return EmergencyShare.fromJson(row);
  });

  @override
  Future<void> stopShare() => _guard(_remoteDataSource.stopShare);

  @override
  Future<void> upsertMyLocation({
    required String shareId,
    required LocationFix fix,
  }) => _guard(
    () => _remoteDataSource.upsertLocation(
      shareId: shareId,
      fixJson: fix.toJson(),
    ),
  );

  @override
  Future<List<SharedWithMeEntry>> fetchSharedWithMe() => _guard(() async {
    final rows = await _remoteDataSource.fetchSharedWithMe();
    return rows
        .map(
          (row) => SharedWithMeEntry(
            shareId: row['id'] as String,
            riderUserId: row['user_id'] as String,
            riderDisplayName: row['rider_display_name'] as String? ?? 'Motociclista',
            startedAt: DateTime.parse(row['started_at'] as String),
            shareToken: row['share_token'] as String,
          ),
        )
        .toList(growable: false);
  });

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (error) {
      throw DataException(_messageFor(error), cause: error);
    } catch (error) {
      throw DataException(
        'No se pudo completar la operación de compartir ubicación.',
        cause: error,
      );
    }
  }

  static String _messageFor(ApiException error) {
    switch (error.statusCode) {
      case 403:
        return 'No tienes permiso para realizar esta acción.';
      case 404:
        return 'No tienes un share activo.';
      default:
        return error.message;
    }
  }
}
