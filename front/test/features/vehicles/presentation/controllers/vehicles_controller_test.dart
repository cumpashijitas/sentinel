import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/auth/domain/entities/app_user.dart';
import 'package:sentinel_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:sentinel_v2/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sentinel_v2/features/vehicles/domain/entities/vehicle.dart';
import 'package:sentinel_v2/features/vehicles/domain/repositories/vehicle_repository.dart';
import 'package:sentinel_v2/features/vehicles/presentation/controllers/vehicles_controller.dart';

const _currentUser = AppUser(id: 'u1', email: 'rider1@sentinel.dev');

class _FakeAuthRepository implements AuthRepository {
  AppUser? userOverride = _currentUser;

  @override
  AppUser? get currentUser => userOverride;

  // Broadcast, like the real `GoTrueClient.onAuthStateChange` — see the
  // note in the profile feature's equivalent fake.
  @override
  Stream<AppUser?> get authStateChanges =>
      Stream.value(userOverride).asBroadcastStream();

  @override
  Future<AppUser> signInWithPassword({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<AppUser> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
  }) => throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();
}

Vehicle _vehicle({
  String id = 'v1',
  String brand = 'Honda',
  String model = 'CB500X',
}) => Vehicle(
  id: id,
  ownerId: 'u1',
  brand: brand,
  model: model,
  createdAt: DateTime.utc(2026, 8, 27),
  updatedAt: DateTime.utc(2026, 8, 27),
);

class _FakeVehicleRepository implements VehicleRepository {
  List<Vehicle> vehicles = [];
  Object? errorToThrow;
  String? lastDeletedId;

  @override
  Future<List<Vehicle>> fetchVehicles(String ownerId) async => vehicles;

  @override
  Future<Vehicle> createVehicle({
    required String ownerId,
    required String brand,
    required String model,
    int? year,
    String? plate,
    String? color,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    final created = _vehicle(
      id: 'v${vehicles.length + 1}',
      brand: brand,
      model: model,
    );
    vehicles = [...vehicles, created];
    return created;
  }

  @override
  Future<Vehicle> updateVehicle({
    required String id,
    required String brand,
    required String model,
    int? year,
    String? plate,
    String? color,
  }) async {
    final updated = _vehicle(id: id, brand: brand, model: model);
    vehicles = [
      for (final v in vehicles)
        if (v.id == id) updated else v,
    ];
    return updated;
  }

  @override
  Future<void> deleteVehicle(String id) async {
    lastDeletedId = id;
    vehicles = vehicles.where((v) => v.id != id).toList();
  }
}

void main() {
  late _FakeAuthRepository fakeAuthRepository;
  late _FakeVehicleRepository fakeVehicleRepository;
  late ProviderContainer container;

  setUp(() {
    fakeAuthRepository = _FakeAuthRepository();
    fakeVehicleRepository = _FakeVehicleRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        vehicleRepositoryProvider.overrideWithValue(fakeVehicleRepository),
      ],
    );
    addTearDown(container.dispose);

    // See docs/architecture.md: a bare ProviderContainer needs an active
    // listener to keep an async provider alive across an `await`.
    container.listen(vehiclesProvider, (_, _) {});
  });

  group('vehiclesProvider', () {
    test('returns an empty list for a user with no vehicles', () async {
      final vehicles = await container.read(vehiclesProvider.future);
      expect(vehicles, isEmpty);
    });

    test('returns an empty list when there is no authenticated user', () async {
      fakeAuthRepository.userOverride = null;
      final vehicles = await container.read(vehiclesProvider.future);
      expect(vehicles, isEmpty);
    });
  });

  group('VehicleFormController', () {
    test('create() adds a vehicle and refreshes vehiclesProvider', () async {
      await container.read(vehiclesProvider.future); // prime the cache

      await container
          .read(vehicleFormControllerProvider.notifier)
          .create(brand: 'Honda', model: 'CB500X');

      final vehicles = await container.read(vehiclesProvider.future);
      expect(vehicles, hasLength(1));
      expect(vehicles.single.brand, 'Honda');
    });

    test('updateVehicle() edits and refreshes vehiclesProvider', () async {
      fakeVehicleRepository.vehicles = [_vehicle()];
      await container.read(vehiclesProvider.future);

      await container
          .read(vehicleFormControllerProvider.notifier)
          .updateVehicle(id: 'v1', brand: 'Yamaha', model: 'MT-07');

      final vehicles = await container.read(vehiclesProvider.future);
      expect(vehicles.single.brand, 'Yamaha');
    });

    test(
      'delete() removes the vehicle and refreshes vehiclesProvider',
      () async {
        fakeVehicleRepository.vehicles = [_vehicle()];
        await container.read(vehiclesProvider.future);

        await container
            .read(vehicleFormControllerProvider.notifier)
            .delete('v1');

        expect(fakeVehicleRepository.lastDeletedId, 'v1');
        final vehicles = await container.read(vehiclesProvider.future);
        expect(vehicles, isEmpty);
      },
    );

    test('create() fails fast without an authenticated user', () async {
      fakeAuthRepository.userOverride = null;

      await container
          .read(vehicleFormControllerProvider.notifier)
          .create(brand: 'Honda', model: 'CB500X');

      expect(container.read(vehicleFormControllerProvider).hasError, isTrue);
      expect(fakeVehicleRepository.vehicles, isEmpty);
    });
  });
}
