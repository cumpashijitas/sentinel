import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../maps/domain/entities/map_coordinate.dart';
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
      appBar: AppBar(title: const Text('Mapa del viaje')),
      body: switch (membersAsync) {
        AsyncData(:final value) => _RideMapBody(
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
    required this.members,
    required this.currentUserId,
    required this.isSharing,
    required this.isBusy,
    required this.onToggleSharing,
  });

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
                        ? 'Dejar de compartir'
                        : 'Compartir mi ubicación',
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
      constraints: const BoxConstraints(maxHeight: 160),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: members.isEmpty
          ? const Center(child: Text('Sin participantes.'))
          : ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) =>
                  _MemberStatusTile(member: members[index]),
            ),
    );
  }
}

class _MemberStatusTile extends StatelessWidget {
  const _MemberStatusTile({required this.member});

  final MemberLocation member;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundImage: member.avatarUrl != null
            ? NetworkImage(member.avatarUrl!)
            : null,
        child: member.avatarUrl == null
            ? const Icon(Icons.person_outline, size: 16)
            : null,
      ),
      title: Text(member.displayName),
      subtitle: Text(_lastSeenLabel(member.fix?.recordedAt)),
      trailing: Text(memberStatusLabel(member.status)),
    );
  }

  static String _lastSeenLabel(DateTime? recordedAt) {
    if (recordedAt == null) return 'Sin datos';
    final age = DateTime.now().difference(recordedAt);
    if (age.inSeconds < 60) return 'Hace ${age.inSeconds}s';
    if (age.inMinutes < 60) return 'Hace ${age.inMinutes} min';
    return 'Hace ${age.inHours} h';
  }
}
