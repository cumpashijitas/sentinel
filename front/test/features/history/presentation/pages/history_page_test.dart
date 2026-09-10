import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/accidents/domain/entities/accident_event.dart';
import 'package:sentinel_v2/features/accidents/presentation/controllers/accident_event_providers.dart';
import 'package:sentinel_v2/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sentinel_v2/features/emergency_shares/domain/entities/emergency_share.dart';
import 'package:sentinel_v2/features/emergency_shares/presentation/controllers/emergency_share_providers.dart';
import 'package:sentinel_v2/features/history/presentation/pages/history_page.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_history_entry.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session.dart';
import 'package:sentinel_v2/features/rides/presentation/controllers/ride_sessions_controller.dart';

import '../../support/fakes.dart';

void main() {
  late FakeRideSessionRepository fakeRideSessionRepository;
  late FakeEmergencyShareRepository fakeEmergencyShareRepository;
  late FakeAccidentEventRepository fakeAccidentEventRepository;

  Future<void> pumpHistoryPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
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
        child: const MaterialApp(home: HistoryPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    fakeRideSessionRepository = FakeRideSessionRepository();
    fakeEmergencyShareRepository = FakeEmergencyShareRepository();
    fakeAccidentEventRepository = FakeAccidentEventRepository();
  });

  group('HistoryPage', () {
    testWidgets('shows an empty state on the Viajes tab with no history', (
      tester,
    ) async {
      await pumpHistoryPage(tester);

      expect(find.text('Todavía no completaste ningún viaje.'), findsOneWidget);
    });

    testWidgets('lists finished rides on the Viajes tab', (tester) async {
      fakeRideSessionRepository.historyToReturn = [
        RideHistoryEntry(
          sessionId: 's1',
          groupId: 'g1',
          groupName: 'Los Nómadas',
          status: RideSessionStatus.finished,
          startedAt: DateTime.utc(2026, 8, 27, 8),
          endedAt: DateTime.utc(2026, 8, 27, 9, 30),
        ),
      ];

      await pumpHistoryPage(tester);

      expect(find.text('Los Nómadas'), findsWidgets);
    });

    testWidgets(
      // Pedido explícito en vivo: "las rutas con sus grupos, sus rutas
      // individuales" — un share terminado (un "viaje individual") debe
      // aparecer mezclado con los viajes de grupo en la misma pestaña.
      'lists ended individual shares alongside group rides on the Viajes tab',
      (tester) async {
        fakeEmergencyShareRepository.historyToReturn = [
          EmergencyShare(
            id: 'sh1',
            userId: 'u1',
            shareToken: 'tok1',
            status: EmergencyShareStatus.ended,
            startedAt: DateTime.utc(2026, 8, 27, 8),
            endedAt: DateTime.utc(2026, 8, 27, 8, 30),
          ),
        ];

        await pumpHistoryPage(tester);

        expect(find.text('Viaje individual'), findsOneWidget);
      },
    );

    testWidgets('lists accidents on the Accidentes tab', (tester) async {
      fakeAccidentEventRepository.historyToReturn = [
        AccidentEvent(
          id: 'a1',
          userId: 'u1',
          impactMps2: 30,
          status: AccidentEventStatus.confirmed,
          occurredAt: DateTime.utc(2026, 8, 27),
        ),
      ];

      await pumpHistoryPage(tester);
      await tester.tap(find.text('Accidentes'));
      await tester.pumpAndSettle();

      expect(find.text('Confirmado'), findsOneWidget);
    });

    testWidgets('shows computed totals on the Estadísticas tab', (
      tester,
    ) async {
      fakeRideSessionRepository.historyToReturn = [
        RideHistoryEntry(
          sessionId: 's1',
          groupId: 'g1',
          groupName: 'Los Nómadas',
          status: RideSessionStatus.finished,
          startedAt: DateTime.utc(2026, 8, 27, 8),
          endedAt: DateTime.utc(2026, 8, 27, 9, 30),
        ),
      ];

      await pumpHistoryPage(tester);
      await tester.tap(find.text('Estadísticas'));
      await tester.pumpAndSettle();

      expect(find.text('Viajes de grupo'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets(
      // Las tiles de rutas individuales solo aparecen cuando hay al menos
      // una — evita mostrarle dos ceros a alguien que nunca las usó.
      'shows individual-route stats only when there is at least one',
      (tester) async {
        await pumpHistoryPage(tester);
        await tester.tap(find.text('Estadísticas'));
        await tester.pumpAndSettle();

        expect(find.text('Rutas individuales'), findsNothing);

        fakeEmergencyShareRepository.historyToReturn = [
          EmergencyShare(
            id: 'sh1',
            userId: 'u1',
            shareToken: 'tok1',
            status: EmergencyShareStatus.ended,
            startedAt: DateTime.utc(2026, 8, 27, 8),
            endedAt: DateTime.utc(2026, 8, 27, 8, 45),
          ),
        ];

        await pumpHistoryPage(tester);
        await tester.tap(find.text('Estadísticas'));
        await tester.pumpAndSettle();

        expect(find.text('Rutas individuales'), findsOneWidget);
        expect(find.text('Tiempo total solo'), findsOneWidget);
      },
    );
  });
}
