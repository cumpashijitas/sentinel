import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Profile> fetchProfile(String userId) => _guard(() async {
    final row = await _remoteDataSource.fetchProfile(userId);
    return Profile.fromJson(row);
  });

  @override
  Future<Profile> updateProfile({
    required String userId,
    required String displayName,
    String? phone,
    required bool whatsappAlertsOptIn,
  }) => _guard(() async {
    final row = await _remoteDataSource.updateProfile(
      userId: userId,
      displayName: displayName,
      phone: phone,
      whatsappAlertsOptIn: whatsappAlertsOptIn,
    );
    return Profile.fromJson(row);
  });

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (error) {
      throw DataException(_messageFor(error), cause: error);
    } catch (error) {
      throw DataException(
        'No se pudo completar la operación sobre el perfil.',
        cause: error,
      );
    }
  }

  static String _messageFor(ApiException error) {
    switch (error.statusCode) {
      case 403:
        return 'No tienes permiso para realizar esta acción.';
      case 404:
        return 'Perfil no encontrado.';
      default:
        return error.message;
    }
  }
}
