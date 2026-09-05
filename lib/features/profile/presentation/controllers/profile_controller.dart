import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/supabase_providers.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_controller.g.dart';

@riverpod
ProfileRemoteDataSource profileRemoteDataSource(Ref ref) {
  return SupabaseProfileRemoteDataSource(ref.watch(supabaseClientProvider));
}

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider));
}

/// The signed-in user's own profile. Re-fetched whenever the auth session
/// changes, and invalidated by [ProfileController.save] after a
/// successful edit so the read side reflects the write immediately.
///
/// Awaits `authStateChangesProvider.future` (not `.value`) so this
/// correctly waits for the *first* auth event instead of racing it — a
/// freshly-watched stream provider has no cached `.value` yet on its very
/// first read.
@riverpod
Future<Profile> currentProfile(Ref ref) async {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) {
    throw StateError('currentProfileProvider requires an authenticated user');
  }
  return ref.watch(profileRepositoryProvider).fetchProfile(user.id);
}

/// Drives saving edits to the current user's profile from the presentation
/// layer. Like [AuthController], the state only tracks the *save action*
/// (loading/error/success), not the profile data itself — read that from
/// [currentProfileProvider].
@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<void> build() {}

  Future<void> save({
    required String displayName,
    String? phone,
    required bool whatsappAlertsOptIn,
  }) async {
    // Imperative action, not a reactive rebuild: read the repository's
    // synchronous `currentUser` snapshot rather than
    // `authStateChangesProvider`'s cached stream value, which may not have
    // emitted yet if nothing has watched it before this call.
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      state = AsyncError(
        StateError('cannot save a profile without an authenticated user'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(profileRepositoryProvider)
          .updateProfile(
            userId: user.id,
            displayName: displayName,
            phone: phone,
            whatsappAlertsOptIn: whatsappAlertsOptIn,
          );
      ref.invalidate(currentProfileProvider);
    });
  }
}
