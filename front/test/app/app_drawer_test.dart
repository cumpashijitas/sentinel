import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinel_v2/app/app_drawer.dart';
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

/// A page with a drawer, reached via `push` from a first screen — the
/// exact shape every real hub page (`HomePage`, `GroupsPage`, ...) has:
/// `Navigator.canPop` is true, but the `Scaffold` also has a non-null
/// `drawer`.
class _HubLikePage extends StatelessWidget {
  const _HubLikePage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const AppDrawer(),
      body: Text('$title content'),
    );
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
        path: AppRoutes.groups,
        builder: (context, state) => const _HubLikePage(title: 'Groups page'),
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
  group('AppDrawer', () {
    testWidgets(
      'a hub page reached via push shows a drawer button, not a back arrow',
      (tester) async {
        await _pumpToHub(tester);

        expect(find.byIcon(Icons.arrow_back), findsNothing);
        expect(find.byTooltip('Open navigation menu'), findsOneWidget);
      },
    );

    testWidgets('lists the five hub destinations plus profile and sign out', (
      tester,
    ) async {
      await _pumpToHub(tester);

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      for (final label in [
        'Inicio',
        'Grupos',
        'Vehículos',
        'Contactos',
        'Historial',
        'Perfil',
        'Cerrar sesión',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('tapping a destination closes the drawer and navigates', (
      tester,
    ) async {
      await _pumpToHub(tester);

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Grupos'));
      await tester.pumpAndSettle();

      expect(find.text('Groups page content'), findsOneWidget);
      // The drawer closed rather than staying open over the new page.
      expect(find.text('Cerrar sesión'), findsNothing);
    });

    testWidgets('tapping "Cerrar sesión" signs out', (tester) async {
      await _pumpToHub(tester);

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();

      expect(_fakeAuthRepository.signedOut, isTrue);
    });
  });
}
