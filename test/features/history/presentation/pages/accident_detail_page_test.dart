import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/accidents/domain/entities/accident_event.dart';
import 'package:sentinel_v2/features/accidents/presentation/controllers/accident_event_providers.dart';
import 'package:sentinel_v2/features/history/presentation/pages/accident_detail_page.dart';

import '../../support/fakes.dart';

void main() {
  late FakeAccidentEventRepository fakeAccidentEventRepository;

  Future<void> pumpDetailPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accidentEventRepositoryProvider.overrideWithValue(
            fakeAccidentEventRepository,
          ),
        ],
        child: const MaterialApp(home: AccidentDetailPage(accidentId: 'a1')),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    fakeAccidentEventRepository = FakeAccidentEventRepository();
  });

  group('AccidentDetailPage', () {
    testWidgets('shows the confirmed status and impact reading', (
      tester,
    ) async {
      fakeAccidentEventRepository.byIdToReturn = AccidentEvent(
        id: 'a1',
        userId: 'u1',
        impactMps2: 42,
        status: AccidentEventStatus.confirmed,
        occurredAt: DateTime.utc(2026, 8, 27, 15),
      );

      await pumpDetailPage(tester);

      expect(find.text('Confirmado'), findsOneWidget);
      expect(find.text('42.0 m/s²'), findsOneWidget);
    });

    testWidgets('shows a "ver viaje" button only when a session is attached', (
      tester,
    ) async {
      fakeAccidentEventRepository.byIdToReturn = AccidentEvent(
        id: 'a1',
        sessionId: 's1',
        userId: 'u1',
        impactMps2: 42,
        status: AccidentEventStatus.notified,
        occurredAt: DateTime.utc(2026, 8, 27, 15),
      );

      await pumpDetailPage(tester);

      expect(find.widgetWithText(OutlinedButton, 'Ver viaje'), findsOneWidget);
    });

    testWidgets('hides the "ver viaje" button without a session', (
      tester,
    ) async {
      fakeAccidentEventRepository.byIdToReturn = AccidentEvent(
        id: 'a1',
        userId: 'u1',
        impactMps2: 42,
        status: AccidentEventStatus.cancelled,
        occurredAt: DateTime.utc(2026, 8, 27, 15),
      );

      await pumpDetailPage(tester);

      expect(find.widgetWithText(OutlinedButton, 'Ver viaje'), findsNothing);
    });
  });
}
