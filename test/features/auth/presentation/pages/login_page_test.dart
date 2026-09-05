import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/auth/domain/entities/app_user.dart';
import 'package:sentinel_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:sentinel_v2/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sentinel_v2/features/auth/presentation/pages/login_page.dart';

class _FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  String? lastEmail;
  String? lastPassword;
  Object? errorToThrow;

  @override
  AppUser? currentUser;

  @override
  Stream<AppUser?> get authStateChanges => _controller.stream;

  @override
  Future<AppUser> signInWithPassword({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    lastPassword = password;
    final error = errorToThrow;
    if (error != null) throw error;
    const user = AppUser(id: 'u1', email: 'rider@sentinel.app');
    currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<AppUser> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
  }) => throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();
}

void main() {
  late _FakeAuthRepository fakeRepository;

  Future<void> pumpLoginPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepository)],
        child: const MaterialApp(home: LoginPage()),
      ),
    );
  }

  setUp(() {
    fakeRepository = _FakeAuthRepository();
  });

  group('LoginPage', () {
    testWidgets('renders the email/password fields and submit button', (
      tester,
    ) async {
      await pumpLoginPage(tester);

      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Iniciar sesión'),
        findsOneWidget,
      );
    });

    testWidgets('shows validation errors and does not sign in when empty', (
      tester,
    ) async {
      await pumpLoginPage(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar sesión'));
      await tester.pumpAndSettle();

      expect(find.text('Ingresa tu correo electrónico.'), findsOneWidget);
      expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
      expect(fakeRepository.lastEmail, isNull);
    });

    testWidgets('submits valid credentials to the auth repository', (
      tester,
    ) async {
      await pumpLoginPage(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo electrónico'),
        'rider@sentinel.app',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        'super-secret',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar sesión'));
      await tester.pumpAndSettle();

      expect(fakeRepository.lastEmail, 'rider@sentinel.app');
      expect(fakeRepository.lastPassword, 'super-secret');
    });
  });
}
