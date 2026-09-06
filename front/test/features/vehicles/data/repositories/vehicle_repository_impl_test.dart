import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/errors/app_exception.dart';
import 'package:sentinel_v2/features/vehicles/data/datasources/vehicle_remote_datasource.dart';
import 'package:sentinel_v2/features/vehicles/data/repositories/vehicle_repository_impl.dart';

Map<String, dynamic> _row({String id = 'v1', String ownerId = 'u1'}) => {
  'id': id,
  'owner_id': ownerId,
  'brand': 'Honda',
  'model': 'CB500X',
  'year': 2022,
  'plate': 'SEN-101',
  'color': 'Rojo',
  'created_at': '2026-08-27T12:00:00.000Z',
  'updated_at': '2026-08-27T12:00:00.000Z',
};

class _FakeVehicleRemoteDataSource implements VehicleRemoteDataSource {
  List<Map<String, dynamic>> rowsToReturn = [];
  Map<String, dynamic>? rowToReturn;
  Object? errorToThrow;
  String? lastDeletedId;

  @override
  Future<List<Map<String, dynamic>>> fetchVehicles(String ownerId) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return rowsToReturn;
  }

  @override
  Future<Map<String, dynamic>> createVehicle({
    required String ownerId,
    required String brand,
    required String model,
    int? year,
    String? plate,
    String? color,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return rowToReturn!;
  }

  @override
  Future<Map<String, dynamic>> updateVehicle({
    required String id,
    required String brand,
    required String model,
    int? year,
    String? plate,
    String? color,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return rowToReturn!;
  }

  @override
  Future<void> deleteVehicle(String id) async {
    lastDeletedId = id;
    final error = errorToThrow;
    if (error != null) throw error;
  }
}

void main() {
  late _FakeVehicleRemoteDataSource dataSource;
  late VehicleRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeVehicleRemoteDataSource();
    repository = VehicleRepositoryImpl(dataSource);
  });

  group('VehicleRepositoryImpl', () {
    test('fetchVehicles maps every row to a Vehicle', () async {
      dataSource.rowsToReturn = [_row(), _row(id: 'v2')];

      final vehicles = await repository.fetchVehicles('u1');

      expect(vehicles, hasLength(2));
      expect(vehicles.map((v) => v.id), ['v1', 'v2']);
    });

    test('fetchVehicles returns an empty list, not an error', () async {
      dataSource.rowsToReturn = [];

      final vehicles = await repository.fetchVehicles('u1');

      expect(vehicles, isEmpty);
    });

    test('createVehicle returns the created Vehicle', () async {
      dataSource.rowToReturn = _row();

      final vehicle = await repository.createVehicle(
        ownerId: 'u1',
        brand: 'Honda',
        model: 'CB500X',
      );

      expect(vehicle.brand, 'Honda');
    });

    test('deleteVehicle forwards the id to the datasource', () async {
      await repository.deleteVehicle('v1');

      expect(dataSource.lastDeletedId, 'v1');
    });

    test('translates a permission-denied ApiException', () async {
      dataSource.errorToThrow = const ApiException('permission denied', statusCode: 403);

      await expectLater(
        () => repository.deleteVehicle('not-mine'),
        throwsA(
          isA<DataException>().having(
            (e) => e.message,
            'message',
            'No tienes permiso para realizar esta acción.',
          ),
        ),
      );
    });
  });
}
