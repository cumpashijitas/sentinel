import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../maps/domain/entities/map_coordinate.dart';
import '../../../maps/domain/entities/map_route.dart';
import '../../../maps/domain/entities/map_viewport.dart';
import '../../../maps/domain/repositories/map_controller.dart';
import '../../../maps/presentation/controllers/map_providers.dart';
import '../../domain/entities/member_location.dart';
import '../controllers/live_tracking_controller.dart';
import '../utils/member_map_markers.dart';

class RideMapPage extends ConsumerStatefulWidget {
  const RideMapPage({required this.sessionId, super.key});

  final String sessionId;

  @override
  ConsumerState<RideMapPage> createState() => _RideMapPageState();
}

class _RideMapPageState extends ConsumerState<RideMapPage> {
  // Explicit, per-screen consent (see docs/security.md): sharing always
  // starts OFF when this screen opens — the user must tap to opt in, every
  // time, rather than it resuming automatically.
  bool _isSharing = false;

  // Captured once in initState rather than read on demand: by the time a
  // widget is torn down its BuildContext may already be unmounted, and
  // Riverpod forbids `ref.read`/`ref.watch` at that point ("Using ref when
  // a widget is about to or has been unmounted is unsafe"). Saving the
  // notifier reference up front is the pattern Riverpod itself recommends.
  //
  // There is deliberately no `dispose()` override here calling
  // `_controller.stop()` as a "belt-and-suspenders" measure: doing so is
  // actually unsafe, not just redundant — `stop()` assigns `state = ...`,
  // and by the time this widget disposes, `liveTrackingControllerProvider`
  // (not `keepAlive`) may already be mid-disposal itself, which throws.
  // `LiveTrackingController.build()`'s own `ref.onDispose` already stops
  // sharing on teardown, and does so safely by calling the repository
  // directly instead of going through `state=`.
  late final LiveTrackingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(liveTrackingControllerProvider.notifier);
  }

  Future<void> _toggleSharing() async {
    final notifier = _controller;
    if (_isSharing) {
      await notifier.stop();
    } else {
      await notifier.start(widget.sessionId);
    }
    // Read via the notifier's own `lastResult` rather than
    // `ref.read(provider)` — the widget may have been disposed while
    // awaiting above (e.g. the user navigated away mid-request), and by
    // then `ref` itself is unsafe to use. `lastResult` stays readable
    // regardless of this widget's mount status.
    final error = notifier.lastResult.error;
    if (!mounted) return;
    if (error == null) {
      setState(() => _isSharing = !_isSharing);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(
      sessionMemberLocationsProvider(widget.sessionId),
    );
    final isBusy = ref.watch(
      liveTrackingControllerProvider.select((s) => s.isLoading),
    );
    final currentUserId = ref.watch(authStateChangesProvider).value?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa del viaje'),
        actions: [
          // El detalle del viaje (roster, finalizar) quedó "huérfano" al
          // hacer que "Iniciar viaje"/"Ver mapa" traigan directo acá — este
          // botón es el único camino de vuelta a esa pantalla ahora.
          IconButton(
            tooltip: 'Detalles del viaje',
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.push('/rides/${widget.sessionId}'),
          ),
        ],
      ),
      body: switch (membersAsync) {
        AsyncData(:final value) => _RideMapBody(
          sessionId: widget.sessionId,
          members: value,
          currentUserId: currentUserId,
          isSharing: _isSharing,
          isBusy: isBusy,
          onToggleSharing: _toggleSharing,
        ),
        AsyncError(:final error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(error.toString(), textAlign: TextAlign.center),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _RideMapBody extends ConsumerStatefulWidget {
  const _RideMapBody({
    required this.sessionId,
    required this.members,
    required this.currentUserId,
    required this.isSharing,
    required this.isBusy,
    required this.onToggleSharing,
  });

  final String sessionId;
  final List<MemberLocation> members;
  final String? currentUserId;
  final bool isSharing;
  final bool isBusy;
  final VoidCallback onToggleSharing;

  @override
  ConsumerState<_RideMapBody> createState() => _RideMapBodyState();
}

class _RideMapBodyState extends ConsumerState<_RideMapBody> {
  // Set once the map's style has loaded (`MapService.buildMap`'s
  // `onMapReady`) and never rebuilt — every roster update after that
  // pushes new markers through this same controller instead of tearing
  // down and recreating the map widget. This is the mechanism behind "no
  // reconstruir todo el widget MapLibre en cada actualización GPS".
  MapController? _mapController;

  // Bug real encontrado en vivo: la cámara solo se posiciona una vez, al
  // construir el mapa (`initialViewport`) — y en ese momento nadie tiene
  // fix todavía casi nunca (el GPS tarda unos segundos en dar la primera
  // posición después de tocar "compartir"), así que arranca en (0,0), en
  // medio del océano, y se queda ahí para siempre: `setMarkers` agrega el
  // pin en las coordenadas reales, pero ninguna llamada mueve la cámara
  // después del build inicial. Esta bandera dispara UN solo `fitBounds`
  // apenas aparece el primer fix real — no en cada actualización después,
  // para no arrancarle la cámara de las manos a alguien que ya la movió a
  // propósito mientras mira el mapa.
  bool _hasCenteredOnRealData = false;

  // Segundo bug real, más común que el anterior: si NADIE del grupo tocó
  // todavía "Compartir en el viaje" (el caso normal al abrir el mapa por
  // primera vez), `widget.members` nunca tiene un solo fix, así que
  // `_maybeCenterOnRealData` nunca dispara y el mapa se queda para
  // siempre en (0,0) — un océano azul sin nada reconocible, que se lee
  // exactamente igual que "el mapa no carga" aunque los tiles sí están
  // llegando. Pedir la posición del propio dispositivo (sin esperar a
  // que nadie más comparta) y centrar ahí apenas esté disponible cubre
  // ese caso — funciona igual en Web y en la app, vía el mismo
  // `LocationTracker` que ya usa el resto de la feature (nunca
  // `Geolocator` directo desde una página — ver su doc comment). Es un
  // `Future` de GPS corriendo en paralelo a `onMapReady` (el mapa puede
  // quedar listo antes o después de que el GPS responda) — se guarda acá
  // y ambos lados (`onMapReady` y la respuesta del GPS, lo que llegue
  // último) consultan/aplican lo que ya está disponible.
  MapCoordinate? _deviceCenter;

  // Ruta recorrida en este viaje (todos los miembros combinados — ver el
  // doc comment de `fetchLocationHistory` en el backend), estilo Strava.
  // Igual que `_deviceCenter` arriba: es un `Future` que corre en paralelo
  // a `onMapReady`, así que se guarda acá y se aplica desde el que llegue
  // último de los dos.
  MapRoute? _route;

  @override
  void initState() {
    super.initState();
    unawaited(_centerOnDeviceLocation());
    unawaited(_fetchRoute());
  }

  Future<void> _centerOnDeviceLocation() async {
    final fix = await ref.read(locationTrackerProvider).getCurrentFix();
    if (fix == null || !mounted || _hasCenteredOnRealData) return;
    _deviceCenter = MapCoordinate(
      latitude: fix.latitude,
      longitude: fix.longitude,
    );
    final controller = _mapController;
    if (controller != null) {
      unawaited(controller.centerOnCoordinate(_deviceCenter!, zoom: 14));
    }
  }

  Future<void> _fetchRoute() async {
    final history = await ref
        .read(liveLocationRepositoryProvider)
        .fetchHistory(widget.sessionId);
    if (!mounted || history.isEmpty) return;
    _route = MapRoute(
      id: widget.sessionId,
      points: history
          .map(
            (fix) => MapCoordinate(
              latitude: fix.latitude,
              longitude: fix.longitude,
            ),
          )
          .toList(growable: false),
    );
    final controller = _mapController;
    if (controller != null) {
      unawaited(controller.setRoute(_route));
    }
  }

  @override
  void didUpdateWidget(_RideMapBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.members != oldWidget.members) _pushMarkers();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _pushMarkers() {
    final controller = _mapController;
    if (controller == null) return;
    unawaited(
      controller.setMarkers(
        buildMemberMapMarkers(
          widget.members,
          currentUserId: widget.currentUserId,
        ),
      ),
    );
    _maybeCenterOnRealData(controller);
  }

  void _maybeCenterOnRealData(MapController controller) {
    if (_hasCenteredOnRealData) return;
    final coordinates = widget.members
        .where((member) => member.fix != null)
        .map(
          (member) => MapCoordinate(
            latitude: member.fix!.latitude,
            longitude: member.fix!.longitude,
          ),
        )
        .toList(growable: false);
    if (coordinates.isEmpty) return;
    // Un fix real de otro miembro siempre gana sobre el centrado en la
    // posición propia — ver el fixed del propio dispositivo más abajo.
    _hasCenteredOnRealData = true;
    unawaited(controller.fitBounds(coordinates));
  }

  @override
  Widget build(BuildContext context) {
    final mapService = ref.watch(mapServiceProvider);
    final tileConfig = ref.watch(mapTileConfigProvider);
    final withFix = widget.members.where((m) => m.fix != null).toList();
    final initialCenter = withFix.isEmpty
        ? const MapCoordinate(latitude: 0, longitude: 0)
        : MapCoordinate(
            latitude: withFix.first.fix!.latitude,
            longitude: withFix.first.fix!.longitude,
          );

    return Column(
      children: [
        Expanded(
          // The share/stop button used to be the Scaffold's own
          // `floatingActionButton` — which floats relative to the whole
          // screen, with no idea `_MemberStatusList` below is also
          // claiming space at the bottom, so it sat on top of the
          // roster's first rows. Anchoring it inside this `Stack`
          // instead scopes it to the map's own area, which ends exactly
          // where the roster begins.
          child: Stack(
            children: [
              mapService.buildMap(
                tileConfig: tileConfig,
                initialViewport: MapViewport(center: initialCenter, zoom: 14),
                onMapReady: (controller) {
                  _mapController = controller;
                  _pushMarkers();
                  final deviceCenter = _deviceCenter;
                  if (deviceCenter != null && !_hasCenteredOnRealData) {
                    unawaited(
                      controller.centerOnCoordinate(deviceCenter, zoom: 14),
                    );
                  }
                  final route = _route;
                  if (route != null) {
                    unawaited(controller.setRoute(route));
                  }
                },
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.extended(
                  onPressed: widget.isBusy ? null : widget.onToggleSharing,
                  icon: Icon(
                    widget.isSharing ? Icons.location_off : Icons.my_location,
                  ),
                  label: Text(
                    widget.isSharing
                        ? 'Dejar de compartir en el viaje'
                        : 'Compartir en el viaje',
                  ),
                ),
              ),
            ],
          ),
        ),
        _MemberStatusList(members: widget.members),
      ],
    );
  }
}

class _MemberStatusList extends StatelessWidget {
  const _MemberStatusList({required this.members});

  final List<MemberLocation> members;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: members.isEmpty
          ? const Center(child: Text('Sin participantes.'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              itemCount: members.length,
              itemBuilder: (context, index) =>
                  _MemberStatusTile(member: members[index]),
            ),
    );
  }
}

/// Reescrito con `Row`/`Column` liso — sin `ListTile`, sin `StatusChip` —
/// mismo motivo que `group_detail_page.dart`: sacar del medio toda
/// dependencia compartida en las pantallas donde el contenido dejó de
/// pintarse en un navegador real sin ningún error visible.
class _MemberStatusTile extends StatelessWidget {
  const _MemberStatusTile({required this.member});

  final MemberLocation member;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(member.status);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF4A2415),
            foregroundColor: Colors.white,
            backgroundImage: member.avatarUrl != null
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null
                ? const Icon(Icons.person_outline, size: 16)
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  member.displayName,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  _lastSeenLabel(member.fix?.recordedAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
                // Telemetría (velocidad + coordenadas) en fuente
                // monoespaciada, como cualquier otro dato numérico del
                // tablero — solo cuando hay un fix real.
                if (member.fix != null)
                  Text(
                    '${_speedLabel(member.fix!.speed)} · '
                    '${member.fix!.latitude.toStringAsFixed(4)}, '
                    '${member.fix!.longitude.toStringAsFixed(4)}',
                    style: AppTheme.telemetryStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: statusColor.withValues(alpha: 0.6)),
            ),
            child: Text(
              memberStatusLabel(member.status),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _speedLabel(double? metersPerSecond) {
    if (metersPerSecond == null) return '-- km/h';
    final kmh = (metersPerSecond * 3.6).round();
    return '$kmh km/h';
  }

  static Color _statusColor(MemberTrackingStatus status) => switch (status) {
    MemberTrackingStatus.active => AppTheme.accent,
    MemberTrackingStatus.stale => AppTheme.textSecondary,
    MemberTrackingStatus.lagging => AppTheme.textSecondary,
    MemberTrackingStatus.offline => AppTheme.textMuted,
    MemberTrackingStatus.possibleIncident => AppTheme.sos,
  };

  static String _lastSeenLabel(DateTime? recordedAt) {
    if (recordedAt == null) return 'Sin datos';
    final age = DateTime.now().difference(recordedAt);
    if (age.inSeconds < 60) return 'Hace ${age.inSeconds}s';
    if (age.inMinutes < 60) return 'Hace ${age.inMinutes} min';
    return 'Hace ${age.inHours} h';
  }
}
