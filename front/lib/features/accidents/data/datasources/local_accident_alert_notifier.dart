import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/repositories/accident_alert_notifier.dart';

/// The one and only place `package:flutter_local_notifications` is
/// imported in this app.
///
/// Constructed in **two** places, each initializing its own instance of
/// this plugin: `rideBackgroundMain.dart`'s background engine (to actually
/// call [showAlert]/[dismissAlert] — the countdown itself lives there) and
/// `initializeAccidentAlertResponseHandling` in the main UI engine (to
/// receive the "Estoy bien" tap). This was not the original design — see
/// that function's doc comment for why a single registration in the
/// background engine, which seemed like it should work since that engine
/// stays alive for as long as `RideBackgroundService` runs (Fase 6), does
/// **not** in practice: confirmed live on-device that
/// `flutter_local_notifications` routes a tapped Android notification
/// action through the app's launcher Activity regardless of which engine
/// called `initialize`, so only a callback registered in the main engine
/// ever actually fires.
class LocalAccidentAlertNotifier implements AccidentAlertNotifier {
  static const _channelId = 'accident_alerts';
  static const _channelName = 'Alertas de posible accidente';
  static const _notificationId = 9001;
  static const _confirmActionId = 'im_ok';

  final _plugin = FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize({
    required void Function(String accidentEventId) onConfirmedOk,
  }) async {
    void handleResponse(NotificationResponse response) {
      if (response.actionId != _confirmActionId) return;
      final accidentEventId = response.payload;
      if (accidentEventId != null) onConfirmedOk(accidentEventId);
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: handleResponse,
    );

    // Bug real reportado en vivo: tocar "Estoy bien" no hacía nada y la
    // alerta se mandaba igual. `onDidReceiveNotificationResponse` de
    // arriba solo entrega el tap si el motor Flutter de la UI YA estaba
    // vivo en ese momento — exactamente lo que NO suele pasar mientras se
    // maneja (pantalla apagada, app en segundo plano: el proceso principal
    // puede haber sido cerrado por Android, y solo sigue vivo el motor
    // headless de `RideBackgroundService`). Si tocar la acción de la
    // notificación es lo que arranca el proceso principal de cero, el tap
    // que causó ese arranque ya se disparó *antes* de que este `initialize`
    // llegara a registrar el callback de arriba — se pierde en silencio.
    // `getNotificationAppLaunchDetails()` es la forma correcta de
    // recuperar ese tap "fundador" después de un arranque en frío.
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final launchResponse = launchDetails?.notificationResponse;
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      if (launchResponse != null) handleResponse(launchResponse);
    }
  }

  @override
  Future<void> showAlert({
    required String accidentEventId,
    required Duration countdown,
  }) async {
    final details = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Se muestra cuando Sentinel detecta un posible accidente y espera tu confirmación.',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      timeoutAfter: countdown.inMilliseconds,
      // Bug real encontrado en vivo, y el definitivo: `showsUserInterface`
      // por defecto viene en `false` — eso le dice a Android que este
      // botón se maneja en segundo plano, SIN abrir la app al tocarlo (para
      // eso existe `onDidReceiveBackgroundNotificationResponse`, que nunca
      // se registró acá). Con el valor por defecto, tocar "Estoy bien" no
      // hacía literalmente nada: ni abría la app, ni pasaba por ningún
      // callback. `showsUserInterface: true` hace que el toque abra/traiga
      // la app al frente igual que tocar el cuerpo de la notificación — así
      // entra por el mismo camino que ya funciona (`onDidReceiveNotification
      // Response`/`getNotificationAppLaunchDetails` en `initialize()` de
      // arriba), con sesión y `.env` ya cargados, en vez de necesitar un
      // segundo camino aparte que corra en un isolate de fondo sin nada de
      // eso disponible.
      //
      // `fullScreenIntent: true` — pedido en vivo ("que el botón sea más
      // grande"): Android no deja agrandar el botón en sí, pero sí mostrar
      // todo el aviso a pantalla completa (como una llamada entrante) en
      // vez de un banner chico — mucho más difícil de pasar por alto
      // mientras se maneja.
      fullScreenIntent: true,
      actions: const [
        AndroidNotificationAction(
          _confirmActionId,
          'Estoy bien',
          showsUserInterface: true,
        ),
      ],
    );

    await _plugin.show(
      id: _notificationId,
      title: '¿Estás bien?',
      body:
          'Sentinel detectó un posible accidente. Si no respondes en '
          '${countdown.inSeconds} segundos, se notificará a tu grupo.',
      notificationDetails: NotificationDetails(android: details),
      payload: accidentEventId,
    );
  }

  @override
  Future<void> dismissAlert() => _plugin.cancel(id: _notificationId);
}
