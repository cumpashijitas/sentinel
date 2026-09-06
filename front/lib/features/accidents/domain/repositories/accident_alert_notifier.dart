/// Device-level alert shown while an accident candidate's countdown is
/// running — the "Estoy bien" prompt. Its own interface (not folded into
/// [AccidentMonitorService]) for the same reason [MotionTracker] and
/// [LocationTracker] are separate from the things that orchestrate them:
/// isolates the one plugin (`flutter_local_notifications`) this touches,
/// and lets `AccidentMonitorServiceImpl` be unit-tested with a fake instead
/// of a real notification.
///
/// Android-only — see `PlatformCapabilities.supportsDeviceNotifications`.
abstract interface class AccidentAlertNotifier {
  /// Must be called once per engine lifetime before [showAlert]. Wires up
  /// the plugin's own callback so tapping "Estoy bien" invokes
  /// [onConfirmedOk] with the `accidentEventId` that alert was for.
  Future<void> initialize({
    required void Function(String accidentEventId) onConfirmedOk,
  });

  /// Shows (or replaces, if one is already up) the countdown alert for
  /// [accidentEventId].
  Future<void> showAlert({
    required String accidentEventId,
    required Duration countdown,
  });

  /// Dismisses the alert — called once the candidate is resolved
  /// (cancelled or confirmed) either way, so a stale "Estoy bien" button
  /// never lingers for an event that's no longer waiting on the rider.
  Future<void> dismissAlert();
}
