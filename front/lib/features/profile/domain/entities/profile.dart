import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// A Sentinel account's public profile — 1:1 with `public.profiles` in
/// Postgres (see `supabase/migrations/20260827210001_profiles.sql`).
///
/// Field names map to the table's snake_case columns automatically via
/// [FieldRename.snake]; the row itself is created server-side by the
/// `on_auth_user_created` trigger, never by the client.
@freezed
abstract class Profile with _$Profile {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Profile({
    required String id,
    required String displayName,
    String? phone,
    String? avatarUrl,
    // Fase 8 (extensión WhatsApp, `20260829000001_whatsapp_alerts.sql`):
    // consentimiento explícito para que dispatch-accident-alerts le escriba
    // por WhatsApp a este usuario cuando un compañero de sesión confirma un
    // accidente. Separado de `phone` (que ya es visible entre compañeros de
    // grupo desde la Fase 1) — ver docs/alerts.md.
    required bool whatsappAlertsOptIn,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
