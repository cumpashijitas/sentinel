import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/auth/domain/entities/app_user.dart';
import 'package:sentinel_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:sentinel_v2/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sentinel_v2/features/groups/domain/entities/group_member.dart';
import 'package:sentinel_v2/features/groups/domain/entities/ride_group.dart';
import 'package:sentinel_v2/features/groups/domain/repositories/group_repository.dart';
import 'package:sentinel_v2/features/groups/presentation/controllers/groups_controller.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_history_entry.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session_participant.dart';
import 'package:sentinel_v2/features/rides/domain/repositories/ride_session_repository.dart';
import 'package:sentinel_v2/features/rides/presentation/controllers/ride_sessions_controller.dart';
import 'package:sentinel_v2/features/rides/presentation/pages/ride_session_page.dart';

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
  @override
  Future<List<RideGroup>> fetchMyGroups(String userId) =>
      throw UnimplementedError();

  @override
  Future<RideGroup> fetchGroup(String groupId) => throw UnimplementedError();

  @override
  Future<List<GroupMember>> fetchMembers(String groupId) async => _members;

  @override
  Future<RideGroup> createGroup({required String name, String? description}) =>
      throw UnimplementedError();

  @override
  Future<RideGroup> updateGroup({
    required String groupId,
    required String name,
    String? description,
  }) => throw UnimplementedError();

  @override
  Future<String> joinGroupByCode(String inviteCode) =>
      throw UnimplementedError();

  @override
  Future<void> leaveGroup(String groupId) => throw UnimplementedError();

  @override
  Future<void> setMemberRole({
    required String groupId,
    required String targetUserId,
    required GroupMemberRole role,
  }) => throw UnimplementedError();

  @override
  Future<void> removeMember({
    required String groupId,
    required String targetUserId,
  }) => throw UnimplementedError();

  @override
  Future<RideGroup> setPinnedNote({required String groupId, String? note}) =>
      throw UnimplementedError();
}

final _session = RideSession(
  id: 's1',
  groupId: 'g1',
  startedBy: 'u1',
  name: 'Salida domingo',
  status: RideSessionStatus.active,
  startedAt: DateTime.utc(2026, 8, 27, 10),
  createdAt: DateTime.utc(2026, 8, 27, 10),
);

final _participants = [
  RideSessionParticipant(
    sessionId: 's1',
    userId: 'u1',
    status: RideParticipantStatus.active,
    joinedAt: DateTime.utc(2026, 8, 27),
    displayName: 'Ana Rider',
  ),
];

class _FakeRideSessionRepository implements RideSessionRepository {
  RideSession session = _session;
  String? lastFinishedId;

  @override
  Future<RideSession?> fetchActiveSession(String groupId) async => session;

  @override
  Future<RideSession> fetchSession(String sessionId) async => session;

  @override
  Future<List<RideSessionParticipant>> fetchParticipants(
    String sessionId,
  ) async => _participants;

  @override
  Future<RideSession> startSession({required String groupId, String? name}) =>
      throw UnimplementedError();

  @override
  Future<RideSession> finishSession(String sessionId) async {
    lastFinishedId = sessionId;
    session = session.copyWith(status: RideSessionStatus.finished);
    return session;
  }

  @override
  Future<List<RideHistoryEntry>> fetchHistory(String userId) =>
      throw UnimplementedError();
}

void main() {
  late _FakeRideSessionRepository fakeRideSessionRepository;

  Future<void> pumpSessionPage(
    WidgetTester tester, {
    required String asUser,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(_user(asUser)),
          ),
          groupRepositoryProvider.overrideWithValue(_FakeGroupRepository()),
          rideSessionRepositoryProvider.overrideWithValue(
            fakeRideSessionRepository,
          ),
        ],
        child: const MaterialApp(home: RideSessionPage(sessionId: 's1')),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    fakeRideSessionRepository = _FakeRideSessionRepository();
  });

  group('RideSessionPage', () {
    testWidgets('shows the session name, status and participants', (
      tester,
    ) async {
      await pumpSessionPage(tester, asUser: 'u2');

      // El título aparece tanto en el header (SectionHeader) como en el
      // cuerpo de la pantalla.
      expect(find.text('Salida domingo'), findsWidgets);
      expect(find.text('En curso'), findsOneWidget);
      expect(find.text('Ana Rider'), findsOneWidget);
    });

    testWidgets('shows a finish button for the group owner/admin', (
      tester,
    ) async {
      await pumpSessionPage(tester, asUser: 'u1');

      expect(
        find.widgetWithText(FilledButton, 'Finalizar viaje'),
        findsOneWidget,
      );
    });

    testWidgets('hides the finish button for a plain member', (tester) async {
      await pumpSessionPage(tester, asUser: 'u2');

      expect(
        find.widgetWithText(FilledButton, 'Finalizar viaje'),
        findsNothing,
      );
    });

    testWidgets('finishing calls the repository after confirmation', (
      tester,
    ) async {
      await pumpSessionPage(tester, asUser: 'u1');

      await tester.tap(find.widgetWithText(FilledButton, 'Finalizar viaje'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Finalizar'));
      await tester.pumpAndSettle();

      expect(fakeRideSessionRepository.lastFinishedId, 's1');
    });
  });
}
