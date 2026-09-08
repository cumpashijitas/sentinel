import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/datasources/vehicle_remote_datasource.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';

part 'vehicles_controller.g.dart';

@riverpod
VehicleRemoteDataSource vehicleRemoteDataSource(Ref ref) {
  return HttpVehicleRemoteDataSource(ref.watch(apiClientProvider));
}

@Riverpod(keepAlive: true)
VehicleRepository vehicleRepository(Ref ref) {
  return VehicleRepositoryImpl(ref.watch(vehicleRemoteDataSourceProvider));
}

/// The signed-in user's own vehicles. Invalidated by
/// [VehicleFormController] after any successful create/update/delete.
@riverpod
Future<List<Vehicle>> vehicles(Ref ref) async {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) return const [];
  return ref.watch(vehicleRepositoryProvider).fetchVehicles(user.id);
}

/// Drives create/update/delete for a single vehicle. Same shape as
/// [ProfileController]: the state is only the *action's* outcome
/// (loading/error/success), not the list itself — read that from
/// [vehiclesProvider].
@riverpod
class VehicleFormController extends _$VehicleFormController {
  @override
  FutureOr<void> build() {}

  Future<void> create({
    required String brand,
    required String model,
    int? year,
    String? plate,
    String? color,
  }) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      state = AsyncError(
        StateError('cannot create a vehicle without an authenticated user'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(vehicleRepositoryProvider)
          .createVehicle(
            ownerId: user.id,
            brand: brand,
            model: model,
            year: year,
            plate: plate,
            color: color,
          );
      ref.invalidate(vehiclesProvider);
    });
  }

  // Named `updateVehicle` rather than `update` — `AsyncNotifier` already
  // exposes an inherited `update(cb)` helper with an incompatible
  // signature, and reusing that name here would silently override it.
  Future<void> updateVehicle({
    required String id,
    required String brand,
    required String model,
    int? year,
    String? plate,
    String? color,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(vehicleRepositoryProvider)
          .updateVehicle(
            id: id,
            brand: brand,
            model: model,
            year: year,
            plate: plate,
            color: color,
          );
      ref.invalidate(vehiclesProvider);
    });
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(vehicleRepositoryProvider).deleteVehicle(id);
      ref.invalidate(vehiclesProvider);
    });
  }
}
