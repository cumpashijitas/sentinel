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
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: (response) {
        if (response.actionId != _confirmActionId) return;
        final accidentEventId = response.payload;
        if (accidentEventId != null) onConfirmedOk(accidentEventId);
      },
    );
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
      actions: const [
        AndroidNotificationAction(_confirmActionId, 'Estoy bien'),
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
