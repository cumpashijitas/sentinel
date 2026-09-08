import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/auth/domain/entities/app_user.dart';
import 'package:sentinel_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:sentinel_v2/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sentinel_v2/features/profile/domain/entities/profile.dart';
import 'package:sentinel_v2/features/profile/domain/repositories/profile_repository.dart';
import 'package:sentinel_v2/features/profile/presentation/controllers/profile_controller.dart';

const _currentUser = AppUser(id: 'u1', email: 'rider1@sentinel.dev');

class _FakeAuthRepository implements AuthRepository {
  AppUser? userOverride = _currentUser;

  @override
  AppUser? get currentUser => userOverride;

  // Broadcast, like the real `GoTrueClient.onAuthStateChange` this stands
  // in for: authStateChangesProvider is keepAlive and can end up
  // (re)watched more than once (e.g. via `.future`), and a
  // single-subscription stream only tolerates one listener.
  @override
  Stream<AppUser?> get authStateChanges =>
      Stream.value(userOverride).asBroadcastStream();

  @override
  Future<AppUser> signInWithPassword({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<AppUser> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
  }) => throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();
}

class _FakeProfileRepository implements ProfileRepository {
  Object? errorToThrow;
  String? lastSavedDisplayName;
  String? lastSavedPhone;
  bool lastSavedWhatsappAlertsOptIn = false;

  @override
  Future<Profile> fetchProfile(String userId) async => Profile(
    id: userId,
    displayName: lastSavedDisplayName ?? 'Ana Rider',
    phone: lastSavedPhone,
    whatsappAlertsOptIn: lastSavedWhatsappAlertsOptIn,
    createdAt: DateTime.utc(2026, 8, 27),
    updatedAt: DateTime.utc(2026, 8, 27),
  );

  @override
  Future<Profile> updateProfile({
    required String userId,
    required String displayName,
    String? phone,
    required bool whatsappAlertsOptIn,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    lastSavedDisplayName = displayName;
    lastSavedPhone = phone;
    lastSavedWhatsappAlertsOptIn = whatsappAlertsOptIn;
    return fetchProfile(userId);
  }
}

void main() {
  late _FakeAuthRepository fakeAuthRepository;
  late _FakeProfileRepository fakeProfileRepository;
  late ProviderContainer container;

  setUp(() {
    fakeAuthRepository = _FakeAuthRepository();
    fakeProfileRepository = _FakeProfileRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
      ],
    );
    addTearDown(container.dispose);

    // currentProfileProvider (and the authStateChangesProvider it awaits
    // via `.future`) needs an active listener to stay alive across the
    // `await` in a bare ProviderContainer test — in the real app this is
    // provided implicitly by ProfilePage's widget tree watching it. Without
    // this, `container.read(someProvider.future)` can hang indefinitely.
    container.listen(currentProfileProvider, (_, _) {});
  });

  group('ProfileController.save', () {
    test('goes through loading then data, and calls the repository', () async {
      final states = <AsyncValue<void>>[];
      container.listen(
        profileControllerProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      await container
          .read(profileControllerProvider.notifier)
          .save(
            displayName: 'Ana R.',
            phone: '+591 700 09999',
            whatsappAlertsOptIn: true,
          );

      expect(fakeProfileRepository.lastSavedDisplayName, 'Ana R.');
      expect(fakeProfileRepository.lastSavedPhone, '+591 700 09999');
      expect(fakeProfileRepository.lastSavedWhatsappAlertsOptIn, isTrue);
      expect(
        states.map((s) => s.isLoading),
        containsAllInOrder([false, true, false]),
      );
      expect(states.last.hasError, isFalse);
    });

    test(
      'invalidates currentProfileProvider after a successful save',
      () async {
        // Prime the cache with the pre-save value.
        await container.read(currentProfileProvider.future);

        await container
            .read(profileControllerProvider.notifier)
            .save(displayName: 'Nuevo Nombre', whatsappAlertsOptIn: false);

        final refreshed = await container.read(currentProfileProvider.future);
        expect(refreshed.displayName, 'Nuevo Nombre');
      },
    );

    test('surfaces a repository failure as AsyncError', () async {
      fakeProfileRepository.errorToThrow = Exception('boom');

      await container
          .read(profileControllerProvider.notifier)
          .save(displayName: 'Ana R.', whatsappAlertsOptIn: false);

      final state = container.read(profileControllerProvider);
      expect(state.hasError, isTrue);
    });

    test('fails fast when there is no authenticated user, without calling the repository', () async {
      fakeAuthRepository.userOverride = null;

      await container
          .read(profileControllerProvider.notifier)
          .save(displayName: 'Ana R.', whatsappAlertsOptIn: false);

      expect(fakeProfileRepository.lastSavedDisplayName, isNull);
      expect(container.read(profileControllerProvider).hasError, isTrue);
    });
  });
}
