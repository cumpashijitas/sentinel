import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinel_v2/features/auth/domain/entities/app_user.dart';
import 'package:sentinel_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:sentinel_v2/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sentinel_v2/features/groups/domain/entities/group_member.dart';
import 'package:sentinel_v2/features/groups/domain/entities/ride_group.dart';
import 'package:sentinel_v2/features/groups/domain/repositories/group_repository.dart';
import 'package:sentinel_v2/features/groups/presentation/controllers/groups_controller.dart';
import 'package:sentinel_v2/features/groups/presentation/pages/groups_page.dart';

const _currentUser = AppUser(id: 'u1', email: 'rider1@sentinel.dev');

class _FakeAuthRepository implements AuthRepository {
  @override
  AppUser? currentUser = _currentUser;

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

RideGroup _group({String id = 'g1', String name = 'Ruta de los Domingos'}) =>
    RideGroup(
      id: id,
      ownerId: 'u1',
      name: name,
      inviteCode: 'SUNDAY01',
      status: RideGroupStatus.active,
      createdAt: DateTime.utc(2026, 8, 27),
      updatedAt: DateTime.utc(2026, 8, 27),
    );

class _FakeGroupRepository implements GroupRepository {
  List<RideGroup> groups = [];
  String? lastJoinedCode;

  @override
  Future<List<RideGroup>> fetchMyGroups(String userId) async => groups;

  @override
  Future<RideGroup> fetchGroup(String groupId) async =>
      groups.firstWhere((g) => g.id == groupId);

  @override
  Future<List<GroupMember>> fetchMembers(String groupId) async => const [];

  @override
  Future<RideGroup> createGroup({
    required String name,
    String? description,
  }) async {
    final created = _group(id: 'g${groups.length + 1}', name: name);
    groups = [...groups, created];
    return created;
  }

  @override
  Future<String> joinGroupByCode(String inviteCode) async {
    lastJoinedCode = inviteCode;
    final joined = _group(id: 'joined-group', name: 'Grupo unido');
    groups = [...groups, joined];
    return joined.id;
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    groups = groups.where((g) => g.id != groupId).toList();
  }
}

void main() {
  late _FakeGroupRepository fakeGroupRepository;

  Future<void> pumpGroupsPage(WidgetTester tester) async {
    // GroupsPage navigates via `context.push` from go_router, which needs
    // a real GoRouter ancestor (a plain Navigator/onGenerateRoute won't
    // satisfy `GoRouter.of(context)`). The detail route itself isn't under
    // test here — a stub page is enough to prove navigation happened.
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const GroupsPage()),
        GoRoute(
          path: '/groups/:id',
          builder: (context, state) => Scaffold(
            body: Text('route: /groups/${state.pathParameters['id']}'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          groupRepositoryProvider.overrideWithValue(fakeGroupRepository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    fakeGroupRepository = _FakeGroupRepository();
  });

  group('GroupsPage', () {
    testWidgets('shows an empty state when there are no groups', (
      tester,
    ) async {
      await pumpGroupsPage(tester);

      expect(
        find.text(
          'Todavía no perteneces a ningún grupo.\nCrea uno o únete con un código.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('lists existing groups', (tester) async {
      fakeGroupRepository.groups = [_group()];

      await pumpGroupsPage(tester);

      expect(find.text('Ruta de los Domingos'), findsOneWidget);
    });

    testWidgets('creates a group through the form sheet and navigates to it', (
      tester,
    ) async {
      await pumpGroupsPage(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Crear grupo'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'),
        'Ruta Nocturna',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
      await tester.pumpAndSettle();

      expect(find.text('route: /groups/g1'), findsOneWidget);
    });

    testWidgets('requires a name before creating a group', (tester) async {
      await pumpGroupsPage(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Crear grupo'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
      await tester.pumpAndSettle();

      expect(find.text('Ingresa un nombre.'), findsOneWidget);
      expect(fakeGroupRepository.groups, isEmpty);
    });

    testWidgets('joins a group by code and navigates to it', (tester) async {
      await pumpGroupsPage(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unirse con código'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Código de invitación'),
        'SUNDAY01',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
      await tester.pumpAndSettle();

      expect(fakeGroupRepository.lastJoinedCode, 'SUNDAY01');
      expect(find.text('route: /groups/joined-group'), findsOneWidget);
    });
  });
}
