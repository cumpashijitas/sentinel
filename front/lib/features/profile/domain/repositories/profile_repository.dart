import '../entities/profile.dart';

/// Backend-agnostic contract for reading/editing a Sentinel profile.
///
/// [fetchProfile] is deliberately generic over `userId` rather than only
/// "the current user" — group-membership RLS also lets a caller read a
/// fellow group member's profile (see the `profiles_select_group_members`
/// policy), which the member-tracking UI in a later phase will need. Only
/// [updateProfile] is implicitly self-only: RLS rejects any `userId` other
/// than the caller's own, so passing another id there always fails.
abstract interface class ProfileRepository {
  /// Throws [ProfileException] if [userId] has no profile visible to the
  /// caller (their own, or a fellow active group member's).
  Future<Profile> fetchProfile(String userId);

  /// Updates the caller's own profile. Throws [ProfileException] if
  /// [userId] is not the caller (rejected by RLS) or the update fails.
  Future<Profile> updateProfile({
    required String userId,
    required String displayName,
    String? phone,
    required bool whatsappAlertsOptIn,
  });
}
