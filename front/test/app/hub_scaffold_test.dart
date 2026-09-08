import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinel_v2/app/hub_scaffold.dart';
import 'package:sentinel_v2/app/router.dart' show AppRoutes;
import 'package:sentinel_v2/features/auth/domain/entities/app_user.dart';
import 'package:sentinel_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:sentinel_v2/features/auth/presentation/controllers/auth_controller.dart';

const _currentUser = AppUser(id: 'u1', email: 'rider1@sentinel.dev');

class _FakeAuthRepository implements AuthRepository {
  AppUser? userOverride = _currentUser;
  bool signedOut = false;

  @override
  AppUser? get currentUser => userOverride;

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
  Future<void> signOut() async => signedOut = true;
}

/// A page built on [HubScaffold], the exact shape every real hub page
/// (`HomePage`, `GroupsPage`, ...) has since the UI/UX redesign pass moved
/// primary navigation to `AppShell`'s bottom bar/rail and left `HubScaffold`
/// responsible only for the profile/sign-out avatar menu.
class _HubLikePage extends StatelessWidget {
  const _HubLikePage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return HubScaffold(title: title, body: Text('$title content'));
  }
}

GoRouter _testRouter() {
  return GoRouter(
    initialLocation: '/first',
    routes: [
      GoRoute(
        path: '/first',
        builder: (context, state) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => context.push(AppRoutes.home),
              child: const Text('Go to hub'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const _HubLikePage(title: 'Home page'),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) =>
            const Scaffold(body: Text('Profile page content')),
      ),
    ],
  );
}

late _FakeAuthRepository _fakeAuthRepository;

Future<void> _pumpToHub(WidgetTester tester) async {
  _fakeAuthRepository = _FakeAuthRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_fakeAuthRepository),
      ],
      child: MaterialApp.router(routerConfig: _testRouter()),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('Go to hub'));
  await tester.pumpAndSettle();
}

void main() {
  group('HubScaffold', () {
    testWidgets('shows the page title and an account menu button', (
      tester,
    ) async {
      await _pumpToHub(tester);

      expect(find.text('Home page'), findsOneWidget);
      expect(find.text('Home page content'), findsOneWidget);
      expect(find.byTooltip('Cuenta'), findsOneWidget);
    });

    testWidgets('the account menu offers "Perfil" and "Cerrar sesión"', (
      tester,
    ) async {
      await _pumpToHub(tester);

      await tester.tap(find.byTooltip('Cuenta'));
      await tester.pumpAndSettle();

      expect(find.text('Perfil'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsOneWidget);
    });

    testWidgets('"Perfil" navigates to the profile route', (tester) async {
      await _pumpToHub(tester);

      await tester.tap(find.byTooltip('Cuenta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      expect(find.text('Profile page content'), findsOneWidget);
    });

    testWidgets('"Cerrar sesión" signs out', (tester) async {
      await _pumpToHub(tester);

      await tester.tap(find.byTooltip('Cuenta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();

      expect(_fakeAuthRepository.signedOut, isTrue);
    });
  });
}
