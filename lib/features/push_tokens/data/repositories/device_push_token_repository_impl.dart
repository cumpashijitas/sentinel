import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/device_push_token.dart';
import '../../domain/repositories/device_push_token_repository.dart';
import '../datasources/device_push_token_remote_datasource.dart';

class DevicePushTokenRepositoryImpl implements DevicePushTokenRepository {
  DevicePushTokenRepositoryImpl(this._remoteDataSource);

  final DevicePushTokenRemoteDataSource _remoteDataSource;

  @override
  Future<DevicePushToken> registerToken({
    required String userId,
    required DevicePushTokenPlatform platform,
    required String token,
  }) => _guard(() async {
    final row = await _remoteDataSource.upsertToken({
      'user_id': userId,
      'platform': platform.name,
      'token': token,
      'last_seen_at': DateTime.now().toUtc().toIso8601String(),
    });
    return DevicePushToken.fromJson(row);
  });

  @override
  Future<void> unregisterToken(String token) =>
      _guard(() => _remoteDataSource.deleteToken(token));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (error) {
      throw DataException(_messageFor(error), cause: error);
    } catch (error) {
      throw DataException(
        'No se pudo registrar este dispositivo para notificaciones.',
        cause: error,
      );
    }
  }

  static String _messageFor(PostgrestException error) {
    switch (error.code) {
      case '42501':
        return 'No tienes permiso para realizar esta acción.';
      case 'PGRST116':
        return 'Registro de notificaciones no encontrado.';
      default:
        return error.message;
    }
  }
}
