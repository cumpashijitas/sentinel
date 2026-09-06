import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// The authenticated Sentinel user, as seen by the rest of the app.
///
/// This is intentionally a thin projection of Supabase's `User` — feature
/// code should depend on this, not on `package:supabase_flutter` types, so
/// the auth backend stays swappable behind [AuthRepository].
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    String? displayName,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
