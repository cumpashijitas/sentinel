import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/accident_event.dart';
import '../../domain/entities/motion_sample.dart';
import '../../domain/repositories/accident_event_repository.dart';
import '../datasources/accident_event_remote_datasource.dart';

class AccidentEventRepositoryImpl implements AccidentEventRepository {
  AccidentEventRepositoryImpl(this._remoteDataSource);

  final AccidentEventRemoteDataSource _remoteDataSource;

  @override
  Future<AccidentEvent> reportCandidate({
    required String userId,
    required String? sessionId,
    required double impactMps2,
    double? gyroRadS,
    double? gForce,
    double? confidenceScore,
    double? latitude,
    double? longitude,
    required MotionSample sample,
  }) => _guard(() async {
    final row = await _remoteDataSource.insertCandidate({
      'user_id': userId,
      'session_id': sessionId,
      'latitude': latitude,
      'longitude': longitude,
      'impact_mps2': impactMps2,
      'gyro_rad_s': gyroRadS,
      'g_force': gForce,
      'confidence_score': confidenceScore,
      'sensor_snapshot': sample.toJson(),
    });
    return AccidentEvent.fromJson(row);
  });

  @override
  Future<void> cancel(String accidentEventId) => _guard(
    () => _remoteDataSource.updateStatus(
      id: accidentEventId,
      status: 'cancelled',
    ),
  );

  @override
  Future<void> confirm(String accidentEventId) => _guard(
    () => _remoteDataSource.updateStatus(
      id: accidentEventId,
      status: 'confirmed',
    ),
  );

  @override
  Future<List<AccidentEvent>> fetchMine(String userId) => _guard(() async {
    final rows = await _remoteDataSource.fetchMine(userId);
    return rows.map(AccidentEvent.fromJson).toList(growable: false);
  });

  @override
  Future<AccidentEvent> fetchById(String accidentEventId) => _guard(() async {
    final row = await _remoteDataSource.fetchById(accidentEventId);
    return AccidentEvent.fromJson(row);
  });

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (error) {
      throw DataException(_messageFor(error), cause: error);
    } catch (error) {
      throw DataException(
        'No se pudo registrar el evento de accidente.',
        cause: error,
      );
    }
  }

  static String _messageFor(PostgrestException error) {
    switch (error.code) {
      case '42501':
        return 'No tienes permiso para realizar esta acción.';
      case 'PGRST116':
        return 'Evento de accidente no encontrado.';
      default:
        return error.message;
    }
  }
}
