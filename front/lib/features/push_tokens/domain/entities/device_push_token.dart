import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_push_token.freezed.dart';
part 'device_push_token.g.dart';

/// Mirrors `public.device_platform`. Only `android` is ever written by this
/// app today — see [DevicePushTokenRepository] and `PushTokenSource` for
/// why — but the column (and this enum) also covers a future Web Push
/// registration without a schema change.
enum DevicePushTokenPlatform { android, web }

/// A device registered to receive push alerts for its owner — 1:1 with
/// `public.device_push_tokens` (see
/// `supabase/migrations/20260827210008_push_tokens_and_alerts.sql`).
/// `dispatch-accident-alerts` (Fase 8, `docs/alerts.md`) reads this table
/// with `service_role` to resolve where to send a push; nothing in the
/// Flutter app ever reads it back.
@freezed
abstract class DevicePushToken with _$DevicePushToken {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory DevicePushToken({
    required String id,
    required String userId,
    required DevicePushTokenPlatform platform,
    required String token,
    required bool enabled,
    required DateTime lastSeenAt,
    required DateTime createdAt,
  }) = _DevicePushToken;

  factory DevicePushToken.fromJson(Map<String, dynamic> json) =>
      _$DevicePushTokenFromJson(json);
}
