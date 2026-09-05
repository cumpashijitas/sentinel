import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/auth/domain/entities/app_user.dart';
import 'package:sentinel_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:sentinel_v2/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sentinel_v2/features/vehicles/domain/entities/vehicle.dart';
import 'package:sentinel_v2/features/vehicles/domain/repositories/vehicle_repository.dart';
import 'package:sentinel_v2/features/vehicles/presentation/controllers/vehicles_controller.dart';
import 'package:sentinel_v2/features/vehicles/presentation/pages/vehicles_page.dart';

const _currentUser = AppUser(id: 'u1', email: 'rider1@sentinel.dev');

class _FakeAuthRepository implements AuthRepository {
  @override
  AppUser? currentUser = _currentUser;

  @override
  Stream<AppUser?> get authStateChanges =>
      Stream.value(_currentUser).asBroadcastStream();

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
  }) async => throw UnimplementedError();

  @override
  Future<void> deleteVehicle(String id) async {
    vehicles = vehicles.where((v) => v.id != id).toList();
  }
}

void main() {
  late _FakeVehicleRepository fakeVehicleRepository;

  Future<void> pumpVehiclesPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          vehicleRepositoryProvider.overrideWithValue(fakeVehicleRepository),
        ],
        child: const MaterialApp(home: VehiclesPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    fakeVehicleRepository = _FakeVehicleRepository();
  });

  group('VehiclesPage', () {
    testWidgets('shows an empty state when there are no vehicles', (
      tester,
    ) async {
      await pumpVehiclesPage(tester);

      expect(
        find.text('Todavía no agregaste ningún vehículo.'),
        findsOneWidget,
      );
    });

    testWidgets('lists existing vehicles', (tester) async {
      fakeVehicleRepository.vehicles = [_vehicle()];

      await pumpVehiclesPage(tester);

      expect(find.text('Honda CB500X'), findsOneWidget);
    });

    testWidgets('adds a vehicle through the form sheet', (tester) async {
      await pumpVehiclesPage(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Marca'),
        'Yamaha',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Modelo'),
        'MT-07',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Guardar'));
      await tester.pumpAndSettle();

      expect(find.text('Yamaha MT-07'), findsOneWidget);
    });

    testWidgets('requires brand and model before saving', (tester) async {
      await pumpVehiclesPage(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Guardar'));
      await tester.pumpAndSettle();

      expect(find.text('Ingresa la marca.'), findsOneWidget);
      expect(find.text('Ingresa el modelo.'), findsOneWidget);
      expect(fakeVehicleRepository.vehicles, isEmpty);
    });

    testWidgets('deletes a vehicle after confirming', (tester) async {
      fakeVehicleRepository.vehicles = [_vehicle()];
      await pumpVehiclesPage(tester);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Eliminar'));
      await tester.pumpAndSettle();

      expect(find.text('Honda CB500X'), findsNothing);
      expect(
        find.text('Todavía no agregaste ningún vehículo.'),
        findsOneWidget,
      );
    });
  });
}
