/// Where this device's push token comes from — the seam between
/// [PushTokenRegistrar] (pure orchestration, fully tested) and whatever SDK
/// actually talks to a push provider.
///
/// The only implementation in this repo today is `UnavailablePushTokenSource`
/// — see its doc comment for exactly why `firebase_messaging` isn't wired
/// up yet. A real `FirebaseMessagingPushTokenSource` slots in here later
/// without touching [PushTokenRegistrar] or `DevicePushTokenRepository` at
/// all.
abstract interface class PushTokenSource {
  /// The current token, or `null` if none is available yet (no provider
  /// configured, permission not granted, no network, ...). Never throws for
  /// "not available" — only for a genuine unexpected failure.
  Future<String?> getToken();

  /// Emits a new token whenever the provider rotates it (FCM does this
  /// periodically, and always after an app reinstall/data clear). Callers
  /// must re-register on every event, not just the first.
  Stream<String> get onTokenRefresh;
}
