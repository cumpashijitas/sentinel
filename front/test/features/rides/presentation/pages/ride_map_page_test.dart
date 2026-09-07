import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/maps/domain/entities/map_coordinate.dart';
import 'package:sentinel_v2/features/maps/domain/entities/map_marker.dart';
import 'package:sentinel_v2/features/maps/domain/entities/map_route.dart';
import 'package:sentinel_v2/features/maps/domain/entities/map_tile_config.dart';
import 'package:sentinel_v2/features/maps/domain/entities/map_viewport.dart';
import 'package:sentinel_v2/features/maps/domain/repositories/map_controller.dart';
import 'package:sentinel_v2/features/maps/domain/repositories/map_service.dart';
import 'package:sentinel_v2/features/maps/presentation/controllers/map_providers.dart';
import 'package:sentinel_v2/features/rides/domain/entities/location_fix.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_history_entry.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session_participant.dart';
import 'package:sentinel_v2/features/rides/domain/repositories/background_location_service.dart';
import 'package:sentinel_v2/features/rides/domain/repositories/live_location_repository.dart';
import 'package:sentinel_v2/features/rides/domain/repositories/location_repository.dart';
import 'package:sentinel_v2/features/rides/domain/repositories/ride_session_repository.dart';
import 'package:sentinel_v2/features/rides/presentation/controllers/live_tracking_controller.dart';
import 'package:sentinel_v2/features/rides/presentation/controllers/ride_sessions_controller.dart';
import 'package:sentinel_v2/features/rides/presentation/pages/ride_map_page.dart';

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
  @override
  Future<List<RideSessionParticipant>> fetchParticipants(
    String sessionId,
  ) async => _participants;

  @override
  Future<RideSession> fetchSession(String sessionId) =>
      throw UnimplementedError();

  @override
  Future<RideSession?> fetchActiveSession(String groupId) =>
      throw UnimplementedError();

  @override
  Future<RideSession> startSession({required String groupId, String? name}) =>
      throw UnimplementedError();

  @override
  Future<RideSession> finishSession(String sessionId) =>
      throw UnimplementedError();

  @override
  Future<List<RideHistoryEntry>> fetchHistory(String userId) =>
      throw UnimplementedError();
}

class _FakeLiveLocationRepository implements LiveLocationRepository {
  final _controller = StreamController<Map<String, LocationFix>>.broadcast();

  void close() => _controller.close();

  @override
  Stream<Map<String, LocationFix>> watchSessionLocations(String sessionId) =>
      _controller.stream;

  @override
  Future<void> upsertMyLocation({
    required String sessionId,
    required String userId,
    required LocationFix fix,
  }) => throw UnimplementedError();

  @override
  Future<void> recordHistory({
    required String sessionId,
    required String userId,
    required LocationFix fix,
  }) => throw UnimplementedError();
}

class _FakeLocationRepository implements LocationRepository {
  bool _sharing = false;

  @override
  bool get isSharing => _sharing;

  @override
  Future<void> startSharing(String sessionId) async => _sharing = true;

  @override
  Future<void> stopSharing() async => _sharing = false;
}

// `flutter test`'s `defaultTargetPlatform` is Android by default, so
// `LiveTrackingController` (Fase 6) routes through `BackgroundLocationService`
// here, not `LocationRepository` — this fake is what the FAB toggle test
// below actually exercises.
class _FakeBackgroundLocationService implements BackgroundLocationService {
  bool _running = false;

  @override
  Future<void> start(String sessionId) async => _running = true;

  @override
  Future<void> stop() async => _running = false;

  @override
  Future<bool> isRunning() async => _running;
}

/// A no-op [MapController] — the map widget tests below only care about
/// the roster/FAB rendered alongside the map, never about what the map
/// engine itself does with a marker/route/camera call.
class _FakeMapController implements MapController {
  @override
  Future<void> setMarkers(List<MapMarker> markers) async {}

  @override
  Future<void> setRoute(MapRoute? route) async {}

  @override
  Future<void> moveCamera(MapViewport viewport, {bool animate = true}) async {}

  @override
  Future<void> centerOnCoordinate(MapCoordinate coordinate, {double? zoom}) async {}

  @override
  Future<void> fitBounds(
    List<MapCoordinate> coordinates, {
    double paddingPixels = 48,
  }) async {}

  @override
  void dispose() {}
}

/// Renders a plain [SizedBox] instead of an actual `MapLibreMap` platform
/// view — `flutter test` has no platform view host, and these tests don't
/// need one; they only exercise `RideMapPage`'s own layout/state, not the
/// map engine. `onMapReady` still fires synchronously so `RideMapPage`'s
/// `didUpdateWidget`-driven marker sync has a controller to call into.
class _FakeMapService implements MapService {
  @override
  Widget buildMap({
    required MapTileConfig tileConfig,
    required MapViewport initialViewport,
    required ValueChanged<MapController> onMapReady,
  }) {
    onMapReady(_FakeMapController());
    return const SizedBox.expand();
  }
}

void main() {
  Future<void> pumpMapPage(WidgetTester tester) async {
    final fakeLiveLocationRepository = _FakeLiveLocationRepository();
    addTearDown(fakeLiveLocationRepository.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          rideSessionRepositoryProvider.overrideWithValue(
            _FakeRideSessionRepository(),
          ),
          liveLocationRepositoryProvider.overrideWithValue(
            fakeLiveLocationRepository,
          ),
          locationRepositoryProvider.overrideWithValue(
            _FakeLocationRepository(),
          ),
          backgroundLocationServiceProvider.overrideWithValue(
            _FakeBackgroundLocationService(),
          ),
          // Avoids depending on appConfigProvider (never overridden in a
          // bare widget test — see docs/architecture.md) and avoids
          // pumping a real flutter_map/TileLayer widget that would try to
          // fetch real tiles over the network, which `flutter test` has
          // no business doing.
          mapServiceProvider.overrideWithValue(_FakeMapService()),
          mapTileConfigProvider.overrideWithValue(
            const MapTileConfig(
              tilesUrl: 'https://example.test/{z}/{x}/{y}.png',
              attribution: '© Test',
              offlineAllowed: false,
              providerName: 'test',
            ),
          ),
        ],
        child: const MaterialApp(home: RideMapPage(sessionId: 's1')),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('RideMapPage', () {
    testWidgets('shows the roster with each participant and status', (
      tester,
    ) async {
      await pumpMapPage(tester);

      expect(find.text('Ana Rider'), findsOneWidget);
    });

    testWidgets('starts with sharing off, toggling flips the FAB label', (
      tester,
    ) async {
      await pumpMapPage(tester);

      expect(find.text('Compartir mi ubicación'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Dejar de compartir'), findsOneWidget);
    });
  });
}
