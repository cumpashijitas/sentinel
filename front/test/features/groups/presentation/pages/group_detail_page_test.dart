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
import 'package:sentinel_v2/features/groups/presentation/pages/group_detail_page.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_history_entry.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session_participant.dart';
import 'package:sentinel_v2/features/rides/domain/repositories/ride_session_repository.dart';
import 'package:sentinel_v2/features/rides/presentation/controllers/ride_sessions_controller.dart';

AppUser _user(String id) => AppUser(id: id, email: '$id@sentinel.dev');

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.currentUser);

  @override
  final AppUser? currentUser;

  @override
  Stream<AppUser?> get authStateChanges =>
      Stream.value(currentUser).asBroadcastStream();

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

final _group = RideGroup(
  id: 'g1',
  ownerId: 'u1',
  name: 'Ruta de los Domingos',
  description: 'Salida grupal.',
  inviteCode: 'SUNDAY01',
  status: RideGroupStatus.active,
  createdAt: DateTime.utc(2026, 8, 27),
  updatedAt: DateTime.utc(2026, 8, 27),
);

final _members = [
  GroupMember(
    groupId: 'g1',
    userId: 'u1',
    role: GroupMemberRole.owner,
    status: GroupMemberStatus.active,
    joinedAt: DateTime.utc(2026, 8, 27),
    displayName: 'Ana Rider',
  ),
  GroupMember(
    groupId: 'g1',
    userId: 'u2',
    role: GroupMemberRole.member,
    status: GroupMemberStatus.active,
    joinedAt: DateTime.utc(2026, 8, 27),
    displayName: 'Bruno Rider',
  ),
];

class _FakeGroupRepository implements GroupRepository {
  String? lastLeftGroupId;
  RideGroup group = _group;
  List<GroupMember> members = List.of(_members);

  @override
  Future<List<RideGroup>> fetchMyGroups(String userId) async => [group];

  @override
  Future<RideGroup> fetchGroup(String groupId) async => group;

  @override
  Future<List<GroupMember>> fetchMembers(String groupId) async => members;

  @override
  Future<RideGroup> createGroup({required String name, String? description}) =>
      throw UnimplementedError();

  @override
  Future<RideGroup> updateGroup({
    required String groupId,
    required String name,
    String? description,
  }) async {
    group = group.copyWith(name: name, description: description);
    return group;
  }

  @override
  Future<String> joinGroupByCode(String inviteCode) =>
      throw UnimplementedError();

  @override
  Future<void> leaveGroup(String groupId) async {
    lastLeftGroupId = groupId;
  }

  @override
  Future<void> setMemberRole({
    required String groupId,
    required String targetUserId,
    required GroupMemberRole role,
  }) async {
    members = [
      for (final m in members)
        if (m.userId == targetUserId) m.copyWith(role: role) else m,
    ];
  }

  @override
  Future<void> removeMember({
    required String groupId,
    required String targetUserId,
  }) async {
    members = members.where((m) => m.userId != targetUserId).toList();
  }

  @override
  Future<RideGroup> setPinnedNote({required String groupId, String? note}) async {
    group = group.copyWith(pinnedNote: note);
    return group;
  }
}

/// GroupDetailPage also shows the group's active-ride status
/// (`_RideSessionCard`). [activeSession] is `null` unless a test sets it.
class _FakeRideSessionRepository implements RideSessionRepository {
  RideSession? activeSession;
  String? lastStartedGroupId;
  String? lastFinishedId;

  @override
  Future<RideSession?> fetchActiveSession(String groupId) async =>
      activeSession;

  @override
  Future<RideSession> fetchSession(String sessionId) =>
      throw UnimplementedError();

  @override
  Future<List<RideSessionParticipant>> fetchParticipants(String sessionId) =>
      throw UnimplementedError();

  @override
  Future<RideSession> startSession({
    required String groupId,
    String? name,
  }) async {
    lastStartedGroupId = groupId;
    activeSession = RideSession(
      id: 's1',
      groupId: groupId,
      startedBy: 'u1',
      status: RideSessionStatus.active,
      startedAt: DateTime.utc(2026, 8, 27),
      createdAt: DateTime.utc(2026, 8, 27),
    );
    return activeSession!;
  }

  @override
  Future<RideSession> finishSession(String sessionId) async {
    lastFinishedId = sessionId;
    activeSession = activeSession?.copyWith(status: RideSessionStatus.finished);
    return activeSession!;
  }

  @override
  Future<List<RideHistoryEntry>> fetchHistory(String userId) =>
      throw UnimplementedError();
}

void main() {
  late _FakeGroupRepository fakeGroupRepository;
  late _FakeRideSessionRepository fakeRideSessionRepository;

  Future<void> pumpDetailPage(
    WidgetTester tester, {
    required String asUser,
  }) async {
    // GroupDetailPage calls `context.pop()`/`context.push()` (go_router),
    // which needs a real GoRouter ancestor — same reason as GroupsPage's
    // test. `/groups/g1` as the only history entry means `context.canPop()`
    // is false, so the guarded pop-after-leave is a safe no-op here.
    final router = GoRouter(
      initialLocation: '/groups/g1',
      routes: [
        GoRoute(
          path: '/groups/:id',
          builder: (context, state) =>
              GroupDetailPage(groupId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/rides/:id',
          builder: (context, state) => Scaffold(
            body: Text('route: /rides/${state.pathParameters['id']}'),
          ),
        ),
        GoRoute(
          path: '/rides/:id/map',
          builder: (context, state) => Scaffold(
            body: Text('route: /rides/${state.pathParameters['id']}/map'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(_user(asUser)),
          ),
          groupRepositoryProvider.overrideWithValue(fakeGroupRepository),
          rideSessionRepositoryProvider.overrideWithValue(
            fakeRideSessionRepository,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    fakeGroupRepository = _FakeGroupRepository();
    fakeRideSessionRepository = _FakeRideSessionRepository();
  });

  group('GroupDetailPage', () {
    testWidgets('shows the group, its invite code and its roster', (
      tester,
    ) async {
      await pumpDetailPage(tester, asUser: 'u2');

      // El título aparece tanto en el header (SectionHeader) como en el
      // cuerpo de la pantalla.
      expect(find.text('Ruta de los Domingos'), findsWidgets);
      expect(find.text('SUNDAY01'), findsOneWidget);
      expect(find.text('Ana Rider'), findsOneWidget);
      expect(find.text('Bruno Rider'), findsOneWidget);
      expect(find.text('Propietario'), findsOneWidget);
      expect(find.text('Miembro'), findsOneWidget);
    });

    testWidgets(
      // Bug real reportado en vivo: editar usaba el mismo controlador que
      // "salir del grupo", cuyo listener saca al usuario de la pantalla en
      // cuanto ve loading→data — guardar una edición disparaba ese mismo
      // listener y competía con el propio cierre del sheet, dejando la
      // edición "trabada" sin guardar nada visible. Un controlador
      // separado (`groupEditControllerProvider`) corta esa interferencia.
      'editing the group updates its name without leaving the page',
      (tester) async {
        await pumpDetailPage(tester, asUser: 'u1');

        await tester.tap(find.byTooltip('Editar grupo'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nombre'),
          'Ruta Renombrada',
        );
        await tester.tap(find.widgetWithText(ElevatedButton, 'Guardar'));
        await tester.pumpAndSettle();

        // El sheet se cerró solo (no quedó "trabado") y el título del
        // header ya refleja el nuevo nombre — seguimos en GroupDetailPage,
        // no nos sacó de la pantalla.
        expect(find.text('Editar grupo'), findsNothing);
        expect(find.text('Ruta Renombrada'), findsWidgets);
        expect(find.text('SUNDAY01'), findsOneWidget);
      },
    );

    testWidgets('shows a leave button for a non-owner member', (tester) async {
      await pumpDetailPage(tester, asUser: 'u2');

      expect(
        find.widgetWithText(OutlinedButton, 'Salir del grupo'),
        findsOneWidget,
      );
    });

    testWidgets('hides the leave button for the owner', (tester) async {
      await pumpDetailPage(tester, asUser: 'u1');

      expect(
        find.widgetWithText(OutlinedButton, 'Salir del grupo'),
        findsNothing,
      );
      // El "no hay viaje activo" del admin ahora reusa `EmptyState`, más
      // alto que la fila compacta que tenía antes — en la lista de
      // `ListView` de esta pantalla eso empuja este texto fuera del rango
      // que el sliver construye sin haber hecho scroll. Un usuario real
      // simplemente baja para verlo, así que el test hace lo mismo en vez
      // de asumir que todo cabe sin scroll.
      await tester.scrollUntilVisible(
        find.textContaining('no puedes abandonar'),
        200,
      );
      expect(find.textContaining('no puedes abandonar'), findsOneWidget);
    });

    testWidgets('leaving calls the repository after confirmation', (
      tester,
    ) async {
      await pumpDetailPage(tester, asUser: 'u2');

      await tester.tap(find.widgetWithText(OutlinedButton, 'Salir del grupo'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Salir'));
      await tester.pumpAndSettle();

      expect(fakeGroupRepository.lastLeftGroupId, 'g1');
    });

    testWidgets(
      'shows "start a ride" for an admin when there is no active session',
      (tester) async {
        await pumpDetailPage(tester, asUser: 'u1');

        expect(find.text('No hay ningún viaje activo.'), findsOneWidget);
        expect(
          find.widgetWithText(FilledButton, 'Iniciar viaje'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'hides the start button for a non-admin when there is no active session',
      (tester) async {
        await pumpDetailPage(tester, asUser: 'u2');

        expect(find.text('No hay ningún viaje activo.'), findsOneWidget);
        expect(
          find.widgetWithText(FilledButton, 'Iniciar viaje'),
          findsNothing,
        );
      },
    );

    testWidgets('starting a ride navigates straight to its map', (
      tester,
    ) async {
      await pumpDetailPage(tester, asUser: 'u1');

      await tester.tap(find.widgetWithText(FilledButton, 'Iniciar viaje'));
      await tester.pumpAndSettle();

      expect(fakeRideSessionRepository.lastStartedGroupId, 'g1');
      expect(find.text('route: /rides/s1/map'), findsOneWidget);
    });

    testWidgets('shows "open the active ride" when a session is active', (
      tester,
    ) async {
      fakeRideSessionRepository.activeSession = RideSession(
        id: 's1',
        groupId: 'g1',
        startedBy: 'u1',
        status: RideSessionStatus.active,
        startedAt: DateTime.utc(2026, 8, 27),
        createdAt: DateTime.utc(2026, 8, 27),
      );

      await pumpDetailPage(tester, asUser: 'u2');

      expect(find.text('Ver mapa'), findsOneWidget);

      await tester.tap(find.text('Ver mapa'));
      await tester.pumpAndSettle();

      expect(find.text('route: /rides/s1/map'), findsOneWidget);
    });

    testWidgets(
      // Antes no existía ninguna forma de delegar permisos — el único
      // rol posible después de crear el grupo era "member" para siempre.
      'the owner can promote a member to admin',
      (tester) async {
        await pumpDetailPage(tester, asUser: 'u1');

        await tester.scrollUntilVisible(find.text('Bruno Rider'), 200);
        await tester.tap(
          find.descendant(
            of: find.ancestor(
              of: find.text('Bruno Rider'),
              matching: find.byType(Row),
            ),
            matching: find.byIcon(Icons.more_vert),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Hacer admin'));
        await tester.pumpAndSettle();

        expect(fakeGroupRepository.members[1].role, GroupMemberRole.admin);
        expect(find.text('Admin'), findsOneWidget);
      },
    );

    testWidgets(
      // Antes tampoco existía forma de sacar a alguien del grupo — solo
      // podía irse por su cuenta.
      'the owner can remove a member after confirming',
      (tester) async {
        await pumpDetailPage(tester, asUser: 'u1');

        await tester.scrollUntilVisible(find.text('Bruno Rider'), 200);
        await tester.tap(
          find.descendant(
            of: find.ancestor(
              of: find.text('Bruno Rider'),
              matching: find.byType(Row),
            ),
            matching: find.byIcon(Icons.more_vert),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Expulsar del grupo'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'Expulsar'));
        await tester.pumpAndSettle();

        expect(fakeGroupRepository.members, hasLength(1));
        expect(find.text('Bruno Rider'), findsNothing);
      },
    );

    testWidgets(
      // Antes, terminar un viaje solo se podía hacer entrando al mapa y
      // después al detalle del viaje — dos pasos de más para algo que
      // pasa justo desde esta pantalla.
      'an admin can finish an active ride directly from the group screen',
      (tester) async {
        fakeRideSessionRepository.activeSession = RideSession(
          id: 's1',
          groupId: 'g1',
          startedBy: 'u1',
          status: RideSessionStatus.active,
          startedAt: DateTime.utc(2026, 8, 27),
          createdAt: DateTime.utc(2026, 8, 27),
        );

        await pumpDetailPage(tester, asUser: 'u1');

        await tester.tap(find.widgetWithText(OutlinedButton, 'Finalizar viaje'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'Finalizar'));
        await tester.pumpAndSettle();

        expect(fakeRideSessionRepository.lastFinishedId, 's1');
      },
    );

    testWidgets(
      // Antes no había forma de avisarle algo a todo el grupo desde
      // adentro de la app.
      'an admin can set and then clear the group note',
      (tester) async {
        await pumpDetailPage(tester, asUser: 'u1');

        expect(find.text('Sin avisos por ahora.'), findsOneWidget);

        await tester.tap(find.byTooltip('Fijar aviso'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Aviso (visible para todo el grupo)'),
          'Salida el sábado a las 9am',
        );
        await tester.tap(find.widgetWithText(ElevatedButton, 'Guardar'));
        await tester.pumpAndSettle();

        expect(find.text('Salida el sábado a las 9am'), findsOneWidget);

        await tester.tap(find.byTooltip('Editar aviso'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'Quitar aviso'));
        await tester.pumpAndSettle();

        expect(find.text('Sin avisos por ahora.'), findsOneWidget);
      },
    );
  });
}
