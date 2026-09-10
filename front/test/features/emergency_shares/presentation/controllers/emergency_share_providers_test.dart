import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/emergency_shares/domain/entities/emergency_share.dart';
import 'package:sentinel_v2/features/emergency_shares/domain/repositories/emergency_share_repository.dart';
import 'package:sentinel_v2/features/emergency_shares/presentation/controllers/emergency_share_providers.dart';
import 'package:sentinel_v2/features/rides/domain/entities/location_fix.dart';
import 'package:sentinel_v2/features/rides/domain/repositories/background_location_service.dart';
import 'package:sentinel_v2/features/rides/domain/repositories/location_tracker.dart';
import 'package:sentinel_v2/features/rides/presentation/controllers/live_tracking_controller.dart'
    show backgroundLocationServiceProvider;

/// `ensurePermission()` resolves whenever the test tells it to — this is
/// what lets the test simulate the real-world race: the user leaves the
/// screen *while* the OS permission dialog is still up, i.e. mid-`await`.
class _FakeLocationTracker implements LocationTracker {
  final permissionCompleter = Completer<bool>();

  @override
  Future<bool> ensurePermission() => permissionCompleter.future;

  @override
  Future<bool> ensureBackgroundPermission() async => true;

  @override
  Stream<LocationFix> watchPosition() => const Stream.empty();

  @override
  Future<LocationFix?> getCurrentFix() async => null;
}

class _AlwaysGrantedLocationTracker implements LocationTracker {
  @override
  Future<bool> ensurePermission() async => true;

  @override
  Future<bool> ensureBackgroundPermission() async => true;

  @override
  Stream<LocationFix> watchPosition() => const Stream.empty();

  @override
  Future<LocationFix?> getCurrentFix() async => null;
}

class _FakeBackgroundLocationService implements BackgroundLocationService {
  bool running = false;
  String? lastTrackingId;
  BackgroundTrackingKind? lastKind;

  @override
  Future<void> start({
    required String trackingId,
    required BackgroundTrackingKind kind,
  }) async {
    lastTrackingId = trackingId;
    lastKind = kind;
    running = true;
  }

  @override
  Future<void> stop() async => running = false;

  @override
  Future<bool> isRunning() async => running;
}

class _FakeEmergencyShareRepository implements EmergencyShareRepository {
  @override
  Future<EmergencyShare?> fetchActiveShare() async => null;

  @override
  Future<EmergencyShare> startShare() => throw UnimplementedError();

  @override
  Future<void> stopShare() => throw UnimplementedError();

  @override
  Future<void> upsertMyLocation({
    required String shareId,
    required LocationFix fix,
  }) async {}

  @override
  Future<List<SharedWithMeEntry>> fetchSharedWithMe() =>
      throw UnimplementedError();
}

void main() {
  group('EmergencyShareTrackingController', () {
    test(
      // Bug real encontrado en vivo: "Cannot use the Ref of
      // emergencyShareTrackingControllerProvider after it has been
      // disposed" — pasaba porque `start()` seguía tocando `ref`/`state`
      // después de un `await` (`ensurePermission()`, que espera al
      // usuario) sin comprobar si el provider seguía vivo. Este test
      // reproduce exactamente esa carrera: dispone el contenedor *durante*
      // ese `await`, y confirma que completar el permiso después no
      // revienta nada.
      "start() surviving disposal mid-await doesn't throw",
      () async {
        final tracker = _FakeLocationTracker();
        final container = ProviderContainer(
          overrides: [
            emergencyLocationTrackerProvider.overrideWithValue(tracker),
            emergencyShareRepositoryProvider.overrideWithValue(
              _FakeEmergencyShareRepository(),
            ),
          ],
        );
        // Sin `addTearDown(container.dispose)`: el propio test dispone el
        // contenedor a propósito, a mitad del `await` — disponerlo dos
        // veces al final del test no es necesario ni seguro.

        final notifier = container.read(
          emergencyShareTrackingControllerProvider.notifier,
        );
        final future = notifier.start('share1');

        // El usuario se va de la pantalla mientras el diálogo de permiso
        // sigue pendiente — nada sigue mirando este provider `autoDispose`,
        // así que Riverpod lo tira abajo ahora mismo.
        container.dispose();

        // Completar el permiso DESPUÉS de la disposición es exactamente la
        // carrera real — antes del fix, esto tiraba una excepción no
        // capturada por seguir usando `ref`.
        tracker.permissionCompleter.complete(true);

        await expectLater(future, completes);
      },
    );

    test(
      // Pedido explícito en vivo: "compartir ubicación" fuera de un grupo
      // debería sobrevivir la pantalla apagada igual que un viaje de
      // grupo — para eso, en Android, tiene que delegar al mismo servicio
      // en segundo plano (generalizado con `BackgroundTrackingKind.share`)
      // en vez de mirar el GPS solo en el motor de la UI. `flutter test`
      // corre con `TargetPlatform.android` por defecto, así que este test
      // no necesita ningún override de plataforma.
      'on Android, start() delegates to BackgroundLocationService with '
      'kind.share instead of watching the GPS locally',
      () async {
        final backgroundService = _FakeBackgroundLocationService();
        final container = ProviderContainer(
          overrides: [
            emergencyLocationTrackerProvider.overrideWithValue(
              _AlwaysGrantedLocationTracker(),
            ),
            emergencyShareRepositoryProvider.overrideWithValue(
              _FakeEmergencyShareRepository(),
            ),
            backgroundLocationServiceProvider.overrideWithValue(
              backgroundService,
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(emergencyShareTrackingControllerProvider.notifier)
            .start('share1');

        expect(backgroundService.running, isTrue);
        expect(backgroundService.lastTrackingId, 'share1');
        expect(backgroundService.lastKind, BackgroundTrackingKind.share);

        await container
            .read(emergencyShareTrackingControllerProvider.notifier)
            .stop();

        expect(backgroundService.running, isFalse);
      },
    );
  });
}
