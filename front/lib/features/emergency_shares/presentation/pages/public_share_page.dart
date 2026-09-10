import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../maps/domain/entities/map_coordinate.dart';
import '../../../maps/domain/entities/map_marker.dart';
import '../../../maps/domain/entities/map_route.dart';
import '../../../maps/domain/entities/map_viewport.dart';
import '../../../maps/domain/repositories/map_controller.dart' as domain;
import '../../../maps/presentation/controllers/map_providers.dart';
import '../../../rides/domain/entities/location_fix.dart';
import '../../data/datasources/public_share_remote_datasource.dart';
import '../../data/repositories/public_share_repository_impl.dart';
import '../../domain/repositories/public_share_repository.dart';

/// La pantalla del link público (`/share/<token>`) — sin login, sin
/// ProviderScope de sesión: cualquiera con el link la abre y ve la
/// ubicación en vivo de quien la compartió. Deliberadamente NO usa
/// [apiClientProvider] (ese adjunta el token de sesión de quien esté
/// logueado en *este* navegador, que puede no ser nadie, o ser una
/// persona distinta a quien mandó el link) — arma su propio
/// [PublicShareRepository] sin ninguna credencial.
class PublicSharePage extends ConsumerStatefulWidget {
  const PublicSharePage({required this.token, super.key});

  final String token;

  @override
  ConsumerState<PublicSharePage> createState() => _PublicSharePageState();
}

class _PublicSharePageState extends ConsumerState<PublicSharePage> {
  PublicShareView? _view;
  Object? _error;
  StreamSubscription<PublicShareView>? _subscription;
  domain.MapController? _mapController;

  // Ruta recorrida en este share, estilo Strava — visible aunque el rider
  // ya haya dejado de compartir (ver el doc comment de
  // `fetchHistoryByToken` en el backend).
  MapRoute? _route;

  @override
  void initState() {
    super.initState();
    final apiBaseUrl = ref.read(appConfigProvider).apiBaseUrl;
    final repository = PublicShareRepositoryImpl(
      HttpPublicShareRemoteDataSource(apiBaseUrl),
    );
    unawaited(_load(repository));
    unawaited(_fetchRoute(repository));
  }

  Future<void> _load(PublicShareRepository repository) async {
    try {
      final view = await repository.fetchByToken(widget.token);
      if (!mounted) return;
      setState(() => _view = view);
      _pushMarker(view);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
      return;
    }

    _subscription = repository.watch(widget.token).listen((view) {
      if (!mounted) return;
      setState(() => _view = view);
      _pushMarker(view);
    });
  }

  Future<void> _fetchRoute(PublicShareRepository repository) async {
    final List<LocationFix> history;
    try {
      history = await repository.fetchRoute(widget.token);
    } catch (error, stackTrace) {
      // No crítico: la ruta es un plus visual, no la razón de ser de esta
      // pantalla (ver la posición en vivo) — un fallo acá no debe tapar el
      // resto de la pantalla con un error.
      AppLogger.error(
        'Failed to fetch public share route',
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }
    if (!mounted || history.isEmpty) return;
    _route = MapRoute(
      id: widget.token,
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

  void _pushMarker(PublicShareView view) {
    final controller = _mapController;
    final fix = view.fix;
    if (controller == null || fix == null) return;
    final coordinate = MapCoordinate(
      latitude: fix.latitude,
      longitude: fix.longitude,
    );
    unawaited(
      controller.setMarkers([
        MapMarker(
          id: 'rider',
          coordinate: coordinate,
          category: MapMarkerCategory.member,
          label: view.riderDisplayName,
          headingDegrees: fix.heading,
        ),
      ]),
    );
    unawaited(controller.centerOnCoordinate(coordinate, zoom: 15));
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    final view = _view;

    return Scaffold(
      appBar: AppBar(
        title: Text(view == null ? 'Sentinel' : view.riderDisplayName),
      ),
      body: error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudo abrir este link: $error',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : view == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!view.isActive)
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.errorContainer,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: Theme.of(
                            context,
                          ).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${view.riderDisplayName} dejó de compartir su ubicación.',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(child: _buildMap(view)),
                if (view.fix == null)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Todavía no llega ninguna posición.'),
                  ),
              ],
            ),
    );
  }

  Widget _buildMap(PublicShareView view) {
    final mapService = ref.watch(mapServiceProvider);
    final tileConfig = ref.watch(mapTileConfigProvider);
    final fix = view.fix;
    final center = fix == null
        ? const MapCoordinate(latitude: 0, longitude: 0)
        : MapCoordinate(latitude: fix.latitude, longitude: fix.longitude);
    return mapService.buildMap(
      tileConfig: tileConfig,
      initialViewport: MapViewport(center: center, zoom: 14),
      onMapReady: (controller) {
        _mapController = controller;
        _pushMarker(view);
        final route = _route;
        if (route != null) {
          unawaited(controller.setRoute(route));
        }
      },
    );
  }
}
