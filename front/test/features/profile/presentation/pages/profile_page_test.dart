import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/auth/domain/entities/app_user.dart';
import 'package:sentinel_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:sentinel_v2/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sentinel_v2/features/profile/domain/entities/profile.dart';
import 'package:sentinel_v2/features/profile/domain/repositories/profile_repository.dart';
import 'package:sentinel_v2/features/profile/presentation/controllers/profile_controller.dart';
import 'package:sentinel_v2/features/profile/presentation/pages/profile_page.dart';

const _currentUser = AppUser(id: 'u1', email: 'rider1@sentinel.dev');

class _FakeAuthRepository implements AuthRepository {
  @override
  AppUser? currentUser = _currentUser;

  // Broadcast, like the real `GoTrueClient.onAuthStateChange` — see the
  // note in profile_controller_test.dart's fake.
  @override
  Stream<AppUser?> get authStateChanges =>
      Stream.value(_currentUser).asBroadcastStream();

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
  Profile? profile = Profile(
    id: 'u1',
    displayName: 'Ana Rider',
    phone: '+591 700 00001',
    whatsappAlertsOptIn: false,
    createdAt: DateTime.utc(2026, 8, 27),
    updatedAt: DateTime.utc(2026, 8, 27),
  );
  String? lastSavedDisplayName;
  String? lastSavedPhone;
  bool? lastSavedWhatsappAlertsOptIn;

  @override
  Future<Profile> fetchProfile(String userId) async => profile!;

  @override
  Future<Profile> updateProfile({
    required String userId,
    required String displayName,
    String? phone,
    required bool whatsappAlertsOptIn,
  }) async {
    lastSavedDisplayName = displayName;
    lastSavedPhone = phone;
    lastSavedWhatsappAlertsOptIn = whatsappAlertsOptIn;
    profile = profile!.copyWith(
      displayName: displayName,
      phone: phone,
      whatsappAlertsOptIn: whatsappAlertsOptIn,
    );
    return profile!;
  }
}

void main() {
  late _FakeProfileRepository fakeProfileRepository;

  Future<void> pumpProfilePage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
  }

  setUp(() {
    fakeProfileRepository = _FakeProfileRepository();
  });

  group('ProfilePage', () {
    testWidgets('pre-fills the form with the loaded profile', (tester) async {
      await pumpProfilePage(tester);
      await tester.pumpAndSettle();

      expect(find.text('Ana Rider'), findsOneWidget);
      expect(find.text('+591 700 00001'), findsOneWidget);
    });

    testWidgets('shows a validation error when the name is cleared', (
      tester,
    ) async {
      await pumpProfilePage(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), '');
      final saveButton = find.widgetWithText(ElevatedButton, 'Guardar');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Ingresa tu nombre.'), findsOneWidget);
      expect(fakeProfileRepository.lastSavedDisplayName, isNull);
    });

    testWidgets('saves edited fields through the repository', (tester) async {
      await pumpProfilePage(tester);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'),
        'Ana R.',
      );
      final saveButton = find.widgetWithText(ElevatedButton, 'Guardar');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(fakeProfileRepository.lastSavedDisplayName, 'Ana R.');
      expect(fakeProfileRepository.lastSavedPhone, '+591 700 00001');
      expect(fakeProfileRepository.lastSavedWhatsappAlertsOptIn, isFalse);
      expect(find.text('Perfil actualizado.'), findsOneWidget);
    });

    testWidgets('toggling the WhatsApp switch saves the new value', (
      tester,
    ) async {
      await pumpProfilePage(tester);
      await tester.pumpAndSettle();

      final switchTile = find.widgetWithText(
        SwitchListTile,
        'Alertas de accidente por WhatsApp',
      );
      await tester.ensureVisible(switchTile);
      await tester.tap(switchTile);
      final saveButton = find.widgetWithText(ElevatedButton, 'Guardar');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(fakeProfileRepository.lastSavedWhatsappAlertsOptIn, isTrue);
    });
  });
}
