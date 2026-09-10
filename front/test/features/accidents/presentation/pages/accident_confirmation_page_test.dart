import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinel_v2/features/accidents/domain/entities/accident_event.dart';
import 'package:sentinel_v2/features/accidents/domain/entities/motion_sample.dart';
import 'package:sentinel_v2/features/accidents/domain/repositories/accident_event_repository.dart';
import 'package:sentinel_v2/features/accidents/presentation/controllers/accident_event_providers.dart';
import 'package:sentinel_v2/features/accidents/presentation/pages/accident_confirmation_page.dart';

class _FakeAccidentEventRepository implements AccidentEventRepository {
  String? lastCancelledId;
  String? lastConfirmedId;
  Object? errorToThrow;

  @override
  Future<void> cancel(String accidentEventId) async {
    final error = errorToThrow;
    if (error != null) throw error;
    lastCancelledId = accidentEventId;
  }

  @override
  Future<void> confirm(String accidentEventId) async {
    final error = errorToThrow;
    if (error != null) throw error;
    lastConfirmedId = accidentEventId;
  }

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
  Future<List<AccidentEvent>> fetchMine(String userId) =>
      throw UnimplementedError();

  @override
  Future<AccidentEvent> fetchById(String accidentEventId) =>
      throw UnimplementedError();
}

void main() {
  late _FakeAccidentEventRepository fakeRepository;

  Future<void> pumpPage(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/accidents/a1/confirm',
      routes: [
        GoRoute(
          path: '/accidents/:id/confirm',
          builder: (context, state) => AccidentConfirmationPage(
            accidentEventId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('home')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accidentEventRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    fakeRepository = _FakeAccidentEventRepository();
  });

  group('AccidentConfirmationPage', () {
    testWidgets('shows both actions and asks the question up front', (
      tester,
    ) async {
      await pumpPage(tester);

      expect(find.text('¿Estás bien?'), findsOneWidget);
      expect(find.text('SÍ, ESTOY BIEN'), findsOneWidget);
      expect(find.text('NECESITO AYUDA — AVISAR AHORA'), findsOneWidget);
    });

    testWidgets('"Sí, estoy bien" cancels the event and shows the result', (
      tester,
    ) async {
      await pumpPage(tester);

      await tester.tap(find.text('SÍ, ESTOY BIEN'));
      await tester.pumpAndSettle();

      expect(fakeRepository.lastCancelledId, 'a1');
      expect(fakeRepository.lastConfirmedId, isNull);
      expect(find.text('Aviso cancelado'), findsOneWidget);
    });

    testWidgets(
      '"Necesito ayuda" confirms immediately, without waiting for a countdown',
      (tester) async {
        await pumpPage(tester);

        await tester.tap(find.text('NECESITO AYUDA — AVISAR AHORA'));
        await tester.pumpAndSettle();

        expect(fakeRepository.lastConfirmedId, 'a1');
        expect(fakeRepository.lastCancelledId, isNull);
        expect(find.text('Alerta enviada'), findsOneWidget);
      },
    );

    testWidgets('shows the error and stays on the question if it fails', (
      tester,
    ) async {
      fakeRepository.errorToThrow = Exception('sin conexión');
      await pumpPage(tester);

      await tester.tap(find.text('SÍ, ESTOY BIEN'));
      await tester.pumpAndSettle();

      expect(find.textContaining('sin conexión'), findsOneWidget);
      expect(find.text('¿Estás bien?'), findsOneWidget);
    });
  });
}
