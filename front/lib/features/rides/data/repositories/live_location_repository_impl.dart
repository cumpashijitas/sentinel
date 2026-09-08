import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/location_fix.dart';
import '../../domain/repositories/live_location_repository.dart';
import '../datasources/live_location_remote_datasource.dart';

class LiveLocationRepositoryImpl implements LiveLocationRepository {
  LiveLocationRepositoryImpl(this._remoteDataSource);

  final LiveLocationRemoteDataSource _remoteDataSource;

  @override
  Stream<Map<String, LocationFix>> watchSessionLocations(
    String sessionId,
  ) async* {
    final currentRows = await _remoteDataSource.fetchCurrentLocations(
      sessionId,
    );
    var state = <String, LocationFix>{
      for (final row in currentRows)
        row['user_id'] as String: LocationFix.fromJson(row),
    };
    yield state;

    await for (final row in _remoteDataSource.watchLocationChanges(sessionId)) {
      final userId = row['user_id'] as String?;
      if (userId == null) continue; // defensive; shouldn't happen
      state = {...state, userId: LocationFix.fromJson(row)};
      yield state;
    }
  }

  @override
  Future<void> upsertMyLocation({
    required String sessionId,
    required String userId,
    required LocationFix fix,
  }) => _guard(
    () => _remoteDataSource.upsertMyLocation(
      sessionId: sessionId,
      userId: userId,
      fixJson: fix.toJson(),
    ),
  );

  @override
  Future<void> recordHistory({
    required String sessionId,
    required String userId,
    required LocationFix fix,
  }) => _guard(
    () => _remoteDataSource.recordHistory(
      sessionId: sessionId,
      userId: userId,
      fixJson: fix.toJson(),
    ),
  );

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (error) {
      throw DataException(_messageFor(error), cause: error);
    } catch (error) {
      throw DataException('No se pudo compartir tu ubicación.', cause: error);
    }
  }

  static String _messageFor(ApiException error) {
    switch (error.statusCode) {
      case 403:
        return 'No tienes permiso para compartir tu ubicación en este viaje.';
      default:
        return error.message;
    }
  }
}
