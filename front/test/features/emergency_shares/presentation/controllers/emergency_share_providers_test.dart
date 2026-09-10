import 'dart:async';

import 'package:flutter/foundation.dart';
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
  final upsertedFixes = <LocationFix>[];
  final recordedFixes = <LocationFix>[];

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
  }) async {
    upsertedFixes.add(fix);
  }

  @override
  Future<void> recordHistory({
    required String shareId,
    required LocationFix fix,
  }) async {
    recordedFixes.add(fix);
  }

  @override
  Future<List<LocationFix>> fetchMyRoute(String shareId) =>
      throw UnimplementedError();

  @override
  Future<List<SharedWithMeEntry>> fetchSharedWithMe() =>
      throw UnimplementedError();

  @override
  Future<List<EmergencyShare>> fetchHistory() => throw UnimplementedError();
}

/// A controllable device stream — used by the "Web" test below to emit
/// fixes close enough together that `LocationSamplingPolicy`'s defaults
/// (20s / 25m / 35°) would only record the first one.
class _StreamingLocationTracker implements LocationTracker {
  final _controller = StreamController<LocationFix>.broadcast();

  void emit(LocationFix fix) => _controller.add(fix);

  @override
  Future<bool> ensurePermission() async => true;

  @override
  Future<bool> ensureBackgroundPermission() async => true;

  @override
  Stream<LocationFix> watchPosition() => _controller.stream;

  @override
  Future<LocationFix?> getCurrentFix() async => null;
}

LocationFix _fix({double lat = -17.3935, DateTime? recordedAt}) => LocationFix(
  latitude: lat,
  longitude: -66.1570,
  recordedAt: recordedAt ?? DateTime.utc(2026, 8, 27),
);

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

  group('EmergencyShareTrackingController on Web (non-Android)', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.iOS);
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test(
      // Pedido explícito en vivo: la ruta de un "viaje individual" se
      // dibuja igual que la de un viaje de grupo — para eso hace falta
      // grabar `emergency_share_location_history` con el mismo criterio de
      // muestreo (`LocationSamplingPolicy`) que ya usa `LocationRepositoryImpl`
      // para `location_history`, no solo actualizar la posición actual.
      'samples fixes into recordHistory the same way a group ride does',
      () async {
        final tracker = _StreamingLocationTracker();
        final repository = _FakeEmergencyShareRepository();
        final container = ProviderContainer(
          overrides: [
            emergencyLocationTrackerProvider.overrideWithValue(tracker),
            emergencyShareRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(emergencyShareTrackingControllerProvider.notifier)
            .start('share1');

        final t0 = DateTime.utc(2026, 8, 27, 12);
        tracker.emit(_fix(recordedAt: t0));
        // Apenas se mueve unos metros, bien dentro de la ventana de
        // muestreo — no debería generar una segunda fila de historial.
        tracker.emit(_fix(lat: -17.3936, recordedAt: t0.add(const Duration(seconds: 1))));
        await Future<void>.delayed(Duration.zero);

        expect(repository.upsertedFixes, hasLength(2));
        expect(repository.recordedFixes, hasLength(1));
      },
    );
  });
}
