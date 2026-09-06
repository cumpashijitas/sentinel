import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_datasource.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl(this._remoteDataSource);

  final VehicleRemoteDataSource _remoteDataSource;

  @override
  Future<List<Vehicle>> fetchVehicles(String ownerId) => _guard(() async {
    final rows = await _remoteDataSource.fetchVehicles(ownerId);
    return rows.map(Vehicle.fromJson).toList(growable: false);
  });

  @override
  Future<Vehicle> createVehicle({
    required String ownerId,
    required String brand,
    required String model,
    int? year,
    String? plate,
    String? color,
  }) => _guard(() async {
    final row = await _remoteDataSource.createVehicle(
      ownerId: ownerId,
      brand: brand,
      model: model,
      year: year,
      plate: plate,
      color: color,
    );
    return Vehicle.fromJson(row);
  });

  @override
  Future<Vehicle> updateVehicle({
    required String id,
    required String brand,
    required String model,
    int? year,
    String? plate,
    String? color,
  }) => _guard(() async {
    final row = await _remoteDataSource.updateVehicle(
      id: id,
      brand: brand,
      model: model,
      year: year,
      plate: plate,
      color: color,
    );
    return Vehicle.fromJson(row);
  });

  @override
  Future<void> deleteVehicle(String id) =>
      _guard(() => _remoteDataSource.deleteVehicle(id));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (error) {
      throw DataException(_messageFor(error), cause: error);
    } catch (error) {
      throw DataException(
        'No se pudo completar la operación sobre el vehículo.',
        cause: error,
      );
    }
  }

  static String _messageFor(ApiException error) {
    if (error.message == 'invalid year') return 'El año ingresado no es válido.';
    switch (error.statusCode) {
      case 403:
        return 'No tienes permiso para realizar esta acción.';
      case 404:
        return 'Vehículo no encontrado.';
      default:
        return error.message;
    }
  }
}
