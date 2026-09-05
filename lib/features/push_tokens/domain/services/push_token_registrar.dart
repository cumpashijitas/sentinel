import 'dart:async';

import '../entities/device_push_token.dart';
import '../repositories/device_push_token_repository.dart';
import '../repositories/push_token_source.dart';

/// Keeps `device_push_tokens` in sync with "who is signed in on this
/// device" and "what this device's current push token is".
///
/// Pure orchestration over [DevicePushTokenRepository] and
/// [PushTokenSource] — no Riverpod, no Supabase, no `firebase_messaging` —
/// so it's fully unit-testable with fakes for both, the same shape as
/// `MemberTrackingService`/`AccidentDetectionService`. The Riverpod wiring
/// (`push_token_providers.dart`) only decides *when* [onUserChanged] gets
/// called; all the actual policy lives here.
class PushTokenRegistrar {
  PushTokenRegistrar({required this.repository, required this.source});

  final DevicePushTokenRepository repository;
  final PushTokenSource source;

  StreamSubscription<String>? _refreshSubscription;
  String? _userId;

  /// Call whenever the signed-in user changes, including to `null` on
  /// sign-out. Re-entrant-safe: an in-flight registration for the previous
  /// user is superseded, never mixed with the new one, because
  /// [_refreshSubscription] is torn down and [_userId] reassigned before
  /// anything async runs.
  ///
  /// No sign-out cleanup by design: a stale row just means a device that no
  /// longer has an active session may still receive a push it can't act on
  /// — `dispatch-accident-alerts` already treats delivery as best-effort
  /// (`docs/alerts.md`), and `last_seen_at` only ever advances on a fresh
  /// [getToken]/[onTokenRefresh] call, so a row for a signed-out device
  /// simply goes stale rather than actively misleading anyone.
  Future<void> onUserChanged(String? userId) async {
    await _refreshSubscription?.cancel();
    _refreshSubscription = null;
    _userId = userId;
    if (userId == null) return;

    _refreshSubscription = source.onTokenRefresh.listen(_register);

    final token = await source.getToken();
    if (token != null) await _register(token);
  }

  Future<void> _register(String token) async {
    final userId = _userId;
    if (userId == null) return;
    await repository.registerToken(
      userId: userId,
      platform: DevicePushTokenPlatform.android,
      token: token,
    );
  }

  /// Releases the [onTokenRefresh] subscription. Call once, when whatever
  /// owns this registrar is itself disposed (app shutdown).
  void dispose() {
    unawaited(_refreshSubscription?.cancel());
  }
}
