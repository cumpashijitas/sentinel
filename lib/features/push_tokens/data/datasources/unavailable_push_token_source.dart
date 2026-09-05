import '../../domain/repositories/push_token_source.dart';

/// The only [PushTokenSource] implementation in this repo today: it never
/// produces a token.
///
/// Registering a **real** FCM token requires the `firebase_messaging`
/// package, which in turn requires a Firebase project's
/// `google-services.json` wired into `android/app/` via the
/// `com.google.gms.google-services` Gradle plugin. That plugin fails the
/// Gradle build outright — "File google-services.json is missing" — when
/// the file isn't present; it is not a soft runtime fallback, it is a hard
/// break of `flutter build apk` / `flutter run -d <android>` for every
/// contributor on this repo, not just this feature. No Firebase project
/// exists in this development environment — the same constraint already
/// documented for FCM push *delivery* in `docs/alerts.md` — so adding that
/// dependency now would trade one documented gap for a broken Android
/// build, which is a worse trade.
///
/// Everything downstream of [PushTokenSource] —
/// `DevicePushTokenRepository`, `PushTokenRegistrar` — is real, wired, and
/// tested; only this one seam is a stand-in. A real
/// `FirebaseMessagingPushTokenSource` (implementing the same interface)
/// slots in the moment a Firebase project backs this app, with no change
/// anywhere else.
class UnavailablePushTokenSource implements PushTokenSource {
  const UnavailablePushTokenSource();

  @override
  Future<String?> getToken() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();
}
