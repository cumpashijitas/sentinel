import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/accidents/domain/entities/accident_event.dart';
import 'package:sentinel_v2/features/accidents/domain/entities/motion_sample.dart';
import 'package:sentinel_v2/features/accidents/domain/repositories/accident_event_repository.dart';
import 'package:sentinel_v2/features/accidents/presentation/controllers/accident_event_providers.dart';
import 'package:sentinel_v2/features/auth/domain/entities/app_user.dart';
import 'package:sentinel_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:sentinel_v2/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sentinel_v2/features/emergency_shares/domain/entities/emergency_share.dart';
import 'package:sentinel_v2/features/emergency_shares/domain/repositories/emergency_share_repository.dart';
import 'package:sentinel_v2/features/emergency_shares/presentation/controllers/emergency_share_providers.dart';
import 'package:sentinel_v2/features/profile/domain/entities/profile.dart';
import 'package:sentinel_v2/features/profile/domain/repositories/profile_repository.dart';
import 'package:sentinel_v2/features/profile/presentation/controllers/profile_controller.dart';
import 'package:sentinel_v2/features/profile/presentation/pages/profile_page.dart';
import 'package:sentinel_v2/features/rides/domain/entities/location_fix.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_history_entry.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session_participant.dart';
import 'package:sentinel_v2/features/rides/domain/repositories/ride_session_repository.dart';
import 'package:sentinel_v2/features/rides/presentation/controllers/ride_sessions_controller.dart';

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

/// Solo lo que necesita `rideStatisticsProvider` para la nueva tile "Tu
/// actividad" en el perfil (ver [_ProfileActivitySummary] en
/// `profile_page.dart`) — no hay nada más que probar de estos tres acá,
/// eso ya lo cubre `history_controller_test.dart`/`ride_statistics_calculator_test.dart`.
class _FakeRideSessionRepository implements RideSessionRepository {
  List<RideHistoryEntry> historyToReturn = [];

  @override
  Future<List<RideHistoryEntry>> fetchHistory(String userId) async =>
      historyToReturn;

  @override
  Future<RideSession?> fetchActiveSession(String groupId) =>
      throw UnimplementedError();

  @override
  Future<RideSession> fetchSession(String sessionId) =>
      throw UnimplementedError();

  @override
  Future<List<RideSessionParticipant>> fetchParticipants(String sessionId) =>
      throw UnimplementedError();

  @override
  Future<RideSession> startSession({required String groupId, String? name}) =>
      throw UnimplementedError();

  @override
  Future<RideSession> finishSession(String sessionId) =>
      throw UnimplementedError();
}

class _FakeEmergencyShareRepository implements EmergencyShareRepository {
  List<EmergencyShare> historyToReturn = [];

  @override
  Future<List<EmergencyShare>> fetchHistory() async => historyToReturn;

  @override
  Future<EmergencyShare?> fetchActiveShare() => throw UnimplementedError();

  @override
  Future<EmergencyShare> startShare() => throw UnimplementedError();

  @override
  Future<void> stopShare() => throw UnimplementedError();

  @override
  Future<void> upsertMyLocation({
    required String shareId,
    required LocationFix fix,
  }) => throw UnimplementedError();

  @override
  Future<void> recordHistory({
    required String shareId,
    required LocationFix fix,
  }) => throw UnimplementedError();

  @override
  Future<List<LocationFix>> fetchMyRoute(String shareId) =>
      throw UnimplementedError();

  @override
  Future<List<SharedWithMeEntry>> fetchSharedWithMe() =>
      throw UnimplementedError();
}

class _FakeAccidentEventRepository implements AccidentEventRepository {
  List<AccidentEvent> historyToReturn = [];

  @override
  Future<List<AccidentEvent>> fetchMine(String userId) async =>
      historyToReturn;

  @override
  Future<AccidentEvent> fetchById(String accidentEventId) =>
      throw UnimplementedError();

  @override
  Future<AccidentEvent> reportCandidate({
    required String userId,
    required String? sessionId,
    required double impactMps2,
    double? gyroRadS,
    double? gForce,
    double? confidenceScore,
    double? latitude,
    double? longitude,
    required MotionSample sample,
  }) => throw UnimplementedError();

  @override
  Future<void> cancel(String accidentEventId) => throw UnimplementedError();

  @override
  Future<void> confirm(String accidentEventId) => throw UnimplementedError();
}

void main() {
  late _FakeProfileRepository fakeProfileRepository;
  late _FakeRideSessionRepository fakeRideSessionRepository;
  late _FakeEmergencyShareRepository fakeEmergencyShareRepository;
  late _FakeAccidentEventRepository fakeAccidentEventRepository;

  Future<void> pumpProfilePage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
          rideSessionRepositoryProvider.overrideWithValue(
            fakeRideSessionRepository,
          ),
          emergencyShareRepositoryProvider.overrideWithValue(
            fakeEmergencyShareRepository,
          ),
          accidentEventRepositoryProvider.overrideWithValue(
            fakeAccidentEventRepository,
          ),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
  }

  setUp(() {
    fakeProfileRepository = _FakeProfileRepository();
    fakeRideSessionRepository = _FakeRideSessionRepository();
    fakeEmergencyShareRepository = _FakeEmergencyShareRepository();
    fakeAccidentEventRepository = _FakeAccidentEventRepository();
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

    testWidgets(
      // Pedido explícito en vivo: "una especie de perfil por usuario, ahí
      // se guarden las rutas con sus grupos, sus rutas individuales,
      // accidentes, estadísticas" — el perfil ahora muestra ese resumen,
      // derivado del mismo cálculo que ya usa `HistoryPage`.
      'shows an activity summary derived from ride, share and accident history',
      (tester) async {
        fakeRideSessionRepository.historyToReturn = [
          RideHistoryEntry(
            sessionId: 's1',
            groupId: 'g1',
            groupName: 'Los Nómadas',
            status: RideSessionStatus.finished,
            startedAt: DateTime.utc(2026, 8, 27, 8),
            endedAt: DateTime.utc(2026, 8, 27, 9),
          ),
        ];
        fakeEmergencyShareRepository.historyToReturn = [
          EmergencyShare(
            id: 'sh1',
            userId: 'u1',
            shareToken: 'tok1',
            status: EmergencyShareStatus.ended,
            startedAt: DateTime.utc(2026, 8, 27, 10),
            endedAt: DateTime.utc(2026, 8, 27, 10, 30),
          ),
        ];
        fakeAccidentEventRepository.historyToReturn = [
          AccidentEvent(
            id: 'a1',
            userId: 'u1',
            impactMps2: 30,
            status: AccidentEventStatus.confirmed,
            occurredAt: DateTime.utc(2026, 8, 27),
          ),
        ];

        await pumpProfilePage(tester);
        await tester.pumpAndSettle();

        expect(find.text('Tu actividad'), findsOneWidget);
        // 1 de grupo + 1 individual = 2 actividades totales.
        expect(find.text('2'), findsOneWidget);
        expect(find.text('Ver historial completo'), findsOneWidget);
      },
    );
  });
}
