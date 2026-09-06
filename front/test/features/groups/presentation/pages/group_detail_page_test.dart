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

  @override
  Future<List<RideGroup>> fetchMyGroups(String userId) async => [_group];

  @override
  Future<RideGroup> fetchGroup(String groupId) async => _group;

  @override
  Future<List<GroupMember>> fetchMembers(String groupId) async => _members;

  @override
  Future<RideGroup> createGroup({required String name, String? description}) =>
      throw UnimplementedError();

  @override
  Future<String> joinGroupByCode(String inviteCode) =>
      throw UnimplementedError();

  @override
  Future<void> leaveGroup(String groupId) async {
    lastLeftGroupId = groupId;
  }
}

/// GroupDetailPage also shows the group's active-ride status
/// (`_RideSessionCard`). [activeSession] is `null` unless a test sets it.
class _FakeRideSessionRepository implements RideSessionRepository {
  RideSession? activeSession;
  String? lastStartedGroupId;

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
  Future<RideSession> finishSession(String sessionId) =>
      throw UnimplementedError();

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

      expect(find.text('Ruta de los Domingos'), findsWidgets);
      expect(find.text('SUNDAY01'), findsOneWidget);
      expect(find.text('Ana Rider'), findsOneWidget);
      expect(find.text('Bruno Rider'), findsOneWidget);
      expect(find.text('Propietario'), findsOneWidget);
      expect(find.text('Miembro'), findsOneWidget);
    });

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

    testWidgets('starting a ride navigates to its session page', (
      tester,
    ) async {
      await pumpDetailPage(tester, asUser: 'u1');

      await tester.tap(find.widgetWithText(FilledButton, 'Iniciar viaje'));
      await tester.pumpAndSettle();

      expect(fakeRideSessionRepository.lastStartedGroupId, 'g1');
      expect(find.text('route: /rides/s1'), findsOneWidget);
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

      expect(find.text('Ver viaje'), findsOneWidget);

      await tester.tap(find.text('Ver viaje'));
      await tester.pumpAndSettle();

      expect(find.text('route: /rides/s1'), findsOneWidget);
    });
  });
}
