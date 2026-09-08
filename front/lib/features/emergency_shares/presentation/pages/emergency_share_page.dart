import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../maps/domain/entities/map_coordinate.dart';
import '../../../maps/domain/entities/map_marker.dart';
import '../../../maps/domain/entities/map_viewport.dart';
import '../../../maps/domain/repositories/map_controller.dart' as domain;
import '../../../maps/presentation/controllers/map_providers.dart';
import '../../../rides/domain/entities/location_fix.dart';
import '../../domain/entities/emergency_share.dart';
import '../controllers/emergency_share_providers.dart';

/// "Compartir mi ubicación" — independiente de estar en un viaje de grupo,
/// y **no limitado a tus contactos de emergencia**: el link público que
/// genera funciona para cualquiera que lo abra, tenga o no cuenta, sea o
/// no un contacto de emergencia registrado — así lo verifica `back/`
/// (`fetchByToken` solo pide conocer el token, ver
/// `emergency-share.service.ts`). Lo de "emergencia" es el motivo por el
/// que existe la función, no una restricción de a quién se lo mandás.
/// Muestra el toggle de encendido/apagado, el link mientras está activo, y
/// quién más te comparte a vos (camino "adentro de la app", solo para
/// quienes además figuran como tus contactos de emergencia registrados).
class EmergencySharePage extends ConsumerWidget {
  const EmergencySharePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(emergencyShareActionsControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.toString())));
      }
    });

    final activeShareAsync = ref.watch(activeShareProvider);
    final isBusy = ref.watch(
      emergencyShareActionsControllerProvider.select((s) => s.isLoading),
    );

    return Scaffold(
      body: Column(
        children: [
          const SectionHeader(
            icon: Icons.share_location_rounded,
            accentColor: AppTheme.sos,
            title: 'Compartir ubicación',
          ),
          Expanded(child: _EmergencyShareBody(
            activeShareAsync: activeShareAsync,
            isBusy: isBusy,
            ref: ref,
          )),
        ],
      ),
    );
  }
}

class _EmergencyShareBody extends StatelessWidget {
  const _EmergencyShareBody({
    required this.activeShareAsync,
    required this.isBusy,
    required this.ref,
  });

  final AsyncValue<EmergencyShare?> activeShareAsync;
  final bool isBusy;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: switch (activeShareAsync) {
                AsyncData(:final value) => _ShareToggle(
                  share: value,
                  isBusy: isBusy,
                  onStart: () => ref
                      .read(emergencyShareActionsControllerProvider.notifier)
                      .start(),
                  onStop: () => ref
                      .read(emergencyShareActionsControllerProvider.notifier)
                      .stop(),
                ),
                AsyncError(:final error) => Text(error.toString()),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Te comparten su ubicación',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _SharedWithMeList(),
        ],
    );
  }
}

class _ShareToggle extends StatelessWidget {
  const _ShareToggle({
    required this.share,
    required this.isBusy,
    required this.onStart,
    required this.onStop,
  });

  final EmergencyShare? share;
  final bool isBusy;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final isActive = share?.status == EmergencyShareStatus.active;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isActive
                    ? colorScheme.tertiaryContainer
                    : colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive
                    ? Icons.share_location_rounded
                    : Icons.location_off_outlined,
                color: isActive
                    ? colorScheme.onTertiaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isActive ? 'Compartiendo ahora' : 'No estás compartiendo',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    isActive
                        ? 'Cualquiera con el link puede ver dónde estás, en vivo.'
                        : 'Compartí un link con quien quieras antes de salir.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isActive,
              onChanged: isBusy
                  ? null
                  : (value) => value ? onStart() : onStop(),
            ),
          ],
        ),
        if (isActive && share != null) ...[
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tu ubicación en vivo',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _SelfLiveMap(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Link para compartir',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ShareLink(shareToken: share!.shareToken),
        ],
      ],
    );
  }
}

/// El propio rider viéndose a sí mismo en el mapa mientras comparte —
/// antes "compartir mi ubicación" era solo un switch sin ninguna
/// confirmación visual de que de verdad estaba funcionando (a diferencia
/// del mapa de un viaje en grupo, que sí muestra a todos en vivo). Es lo
/// más parecido a "iniciar un viaje solo, sin grupo" que existe hoy: la
/// misma ubicación en vivo, solo que el destinatario es un contacto de
/// emergencia por link en vez de un roster de participantes.
class _SelfLiveMap extends ConsumerStatefulWidget {
  const _SelfLiveMap();

  @override
  ConsumerState<_SelfLiveMap> createState() => _SelfLiveMapState();
}

class _SelfLiveMapState extends ConsumerState<_SelfLiveMap> {
  domain.MapController? _mapController;
  StreamSubscription<LocationFix>? _subscription;
  bool _hasCenteredOnce = false;

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(
      emergencyShareTrackingControllerProvider.notifier,
    );
    _subscription = notifier.fixStream.listen(_onFix);
  }

  void _onFix(LocationFix fix) {
    final controller = _mapController;
    if (controller == null) return;
    final coordinate = MapCoordinate(
      latitude: fix.latitude,
      longitude: fix.longitude,
    );
    unawaited(
      controller.setMarkers([
        MapMarker(
          id: 'me',
          coordinate: coordinate,
          category: MapMarkerCategory.currentUser,
          headingDegrees: fix.heading,
        ),
      ]),
    );
    if (!_hasCenteredOnce) {
      _hasCenteredOnce = true;
      unawaited(controller.centerOnCoordinate(coordinate, zoom: 15));
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapService = ref.watch(mapServiceProvider);
    final tileConfig = ref.watch(mapTileConfigProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(
        height: 220,
        child: mapService.buildMap(
          tileConfig: tileConfig,
          initialViewport: const MapViewport(
            center: MapCoordinate(latitude: 0, longitude: 0),
            zoom: 14,
          ),
          onMapReady: (controller) => _mapController = controller,
        ),
      ),
    );
  }
}

class _ShareLink extends ConsumerWidget {
  const _ShareLink({required this.shareToken});

  final String shareToken;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // El link apunta al front, no al backend — back/ solo sirve datos
    // (JSON + WebSocket), la pantalla que lo renderiza vive en el front,
    // en la ruta pública /share/:token (ver app/router.dart).
    final webBaseUrl = ref.watch(appConfigProvider).webBaseUrl;
    final link = '$webBaseUrl/#/share/$shareToken';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              link,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          IconButton(
            tooltip: 'Copiar',
            icon: const Icon(Icons.copy_outlined),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: link));
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('Link copiado')),
                  );
              }
            },
          ),
          IconButton(
            tooltip: 'Enviar por WhatsApp',
            icon: const Icon(Icons.chat_outlined),
            onPressed: () {
              final text = Uri.encodeComponent(
                'Estoy compartiendo mi ubicación en Sentinel, sígueme acá: $link',
              );
              unawaited(launchUrl(Uri.parse('https://wa.me/?text=$text')));
            },
          ),
        ],
      ),
    );
  }
}

class _SharedWithMeList extends ConsumerWidget {
  const _SharedWithMeList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(sharedWithMeProvider);

    return switch (entriesAsync) {
      AsyncData(:final value) when value.isEmpty => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Nadie te está compartiendo su ubicación ahora mismo.'),
      ),
      AsyncData(:final value) => Column(
        children: [
          for (final entry in value)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.tertiaryContainer,
                    child: Icon(
                      Icons.two_wheeler_rounded,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                  title: Text(entry.riderDisplayName),
                  subtitle: const Text('Compartiendo ahora'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/share/${entry.shareToken}'),
                ),
              ),
            ),
        ],
      ),
      AsyncError(:final error) => Text(error.toString()),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}
