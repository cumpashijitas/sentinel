import 'package:geolocator/geolocator.dart';

import '../../domain/entities/location_fix.dart';
import '../../domain/repositories/location_tracker.dart';

/// The one and only place `package:geolocator` is imported in this app —
/// see [LocationTracker]'s doc comment for the platform story.
///
/// Foreground-only: uses `Geolocator.getPositionStream`, which on Android
/// stops delivering updates once the app is fully backgrounded/killed (no
/// foreground service is started here — that's `BackgroundRideService`,
/// Fase 6) and on Web depends entirely on the browser tab staying open and
/// the page holding the `geolocation` permission for that origin.
///
/// `batteryLevel` on the resulting [LocationFix] is always `null` — reading
/// it would need an extra plugin (`battery_plus`) this app doesn't
/// otherwise depend on; not worth adding for one optional field yet.
class GeolocatorLocationTracker implements LocationTracker {
  const GeolocatorLocationTracker();

  @override
  Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> ensureBackgroundPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.always) {
      // On Android, requesting from `whileInUse`/`denied` surfaces the
      // OS's own "Allow all the time" dialog (or sends the user to
      // Settings on API levels that require it) — there is no separate,
      // lower-level API call needed here beyond asking again.
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always;
  }

  @override
  Stream<LocationFix> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).map(_toFix);
  }

  @override
  Future<LocationFix?> getCurrentFix() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      // Nunca pide permiso acá — solo consulta el que ya exista. El pedido
      // explícito vive en [ensurePermission], disparado por una acción
      // concreta del usuario (ver `HomePage`, que ahora lo pide apenas
      // entra a la app — no el mapa, "que no debe suponer nada").
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return null;
      }

      // ANR real, reportado en vivo — y todavía después de sacar el pedido
      // de permiso de arriba: `Geolocator.getCurrentPosition()` (pedirle al
      // GPS un fix fresco, en el momento) puede bloquear el hilo principal
      // de Android en ciertos dispositivos/versiones del plugin — un
      // problema conocido del lado nativo, que un `.timeout()` de Dart por
      // fuera NO puede destrabar (el bloqueo no está en el código Dart que
      // ese timeout corta, sigue atascado del otro lado del canal nativo).
      // `getLastKnownPosition()` es una lectura instantánea de la última
      // posición que el sistema operativo ya tiene guardada — no dispara
      // ningún pedido activo al GPS, así que no tiene ninguna vía por la
      // que quedarse colgada. Puede devolver `null` si el dispositivo
      // todavía no tiene ninguna posición guardada (recién instalado, GPS
      // nunca usado) — ahí sí no hay nada que mostrar, y está bien: el
      // mapa igual se termina centrando solo con el primer fix real que
      // llegue por `watchPosition`/`fitBounds`.
      final position = await Geolocator.getLastKnownPosition()
          .timeout(const Duration(seconds: 3));
      return position == null ? null : _toFix(position);
    } on Object {
      // Cualquier falla se traduce a `null` — ver el contrato de
      // `getCurrentFix` en `LocationTracker`.
      return null;
    }
  }

  LocationFix _toFix(Position position) => LocationFix(
    latitude: position.latitude,
    longitude: position.longitude,
    accuracy: position.accuracy,
    speed: position.speed,
    heading: position.heading,
    // `.toUtc()` is not optional here: `position.timestamp` is not
    // guaranteed UTC across every platform/plugin implementation (the web
    // implementation in particular has been observed to hand back a local
    // DateTime), and `LocationFix.toJson()` serializes via
    // `DateTime.toIso8601String()`, which omits the timezone offset
    // entirely for a non-UTC DateTime. Postgres then has no way to know
    // that string wasn't already UTC and stores it verbatim — silently
    // shifting every recorded fix by the device's UTC offset (confirmed
    // via a real E2E run: a fix written from a UTC-4 browser landed in
    // `location_history`/`live_locations` four hours "in the past",
    // enough to make `MemberTrackingService` misclassify a rider who just
    // sent a fix as `offline`). Normalizing to UTC at the one point a raw
    // platform `DateTime` enters the domain avoids the whole class of bug.
    recordedAt: position.timestamp.toUtc(),
  );
}
