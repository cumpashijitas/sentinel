import '../entities/device_push_token.dart';

/// Backend-agnostic contract for `device_push_tokens` — the table
/// `dispatch-accident-alerts` (Fase 8) reads to know where to send a push
/// alert. See the RLS policies in
/// `supabase/migrations/20260827210008_push_tokens_and_alerts.sql`: every
/// operation here is implicitly self-scoped, same as
/// `EmergencyContactRepository`.
abstract interface class DevicePushTokenRepository {
  /// Registers (or re-registers) [token] as belonging to [userId] on
  /// [platform]. An upsert on the table's `token` UNIQUE constraint — safe
  /// to call every time the app obtains a token, including an unchanged one
  /// (bumps `last_seen_at`) or one that moved to a different account on the
  /// same device (re-points `user_id`).
  Future<DevicePushToken> registerToken({
    required String userId,
    required DevicePushTokenPlatform platform,
    required String token,
  });

  /// Removes [token] — e.g. `firebase_messaging` reporting the token was
  /// invalidated. Throws [DataException] if [token] doesn't exist or isn't
  /// owned by the caller (rejected by RLS).
  Future<void> unregisterToken(String token);
}
