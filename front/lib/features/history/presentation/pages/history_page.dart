import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/hub_scaffold.dart';
import '../../../../app/router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../../shared/widgets/timeline_tile.dart';
import '../../../accidents/domain/entities/accident_event.dart';
import '../../domain/entities/ride_statistics.dart';
import '../../domain/entities/route_history_entry.dart';
import '../controllers/history_controller.dart';

/// Fase 9: three tabs over data the user already produced elsewhere in the
/// app — completed rides, past accident events, and a few numbers derived
/// from both. Nothing here writes anything; it's read-only, same spirit as
/// `RideSessionPage` showing history rather than driving it.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      child: HubScaffold(
        title: 'Historial',
        icon: Icons.history_rounded,
        bottom: TabBar(
          tabs: [
            Tab(text: 'Viajes'),
            Tab(text: 'Accidentes'),
            Tab(text: 'Estadísticas'),
          ],
        ),
        body: ResponsiveContent(
          child: TabBarView(
            children: [
              _RideHistoryTab(),
              _AccidentHistoryTab(),
              _StatisticsTab(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Viajes de grupo y rutas individuales, mezclados en un solo feed
/// cronológico — pedido explícito en vivo ("las rutas con sus grupos, sus
/// rutas individuales"), mismo espíritu que Strava no separando actividades
/// solas de las de grupo. Ver [RouteHistoryEntry]/[routeHistoryProvider].
class _RideHistoryTab extends ConsumerWidget {
  const _RideHistoryTab();

  static final _dateFormat = DateFormat.yMMMd().add_Hm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(routeHistoryProvider);

    return switch (routesAsync) {
      AsyncData(:final value) =>
        value.isEmpty
            ? const EmptyState(
                icon: Icons.pedal_bike_outlined,
                message: 'Todavía no completaste ningún viaje.',
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xxxl,
                ),
                itemCount: value.length,
                itemBuilder: (context, index) => _RouteHistoryTile(
                  entry: value[index],
                  dateFormat: _dateFormat,
                  isFirst: index == 0,
                  isLast: index == value.length - 1,
                ),
              ),
      AsyncError(:final error) => _ErrorState(error: error),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _RouteHistoryTile extends StatelessWidget {
  const _RouteHistoryTile({
    required this.entry,
    required this.dateFormat,
    required this.isFirst,
    required this.isLast,
  });

  final RouteHistoryEntry entry;
  final DateFormat dateFormat;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final duration = entry.duration;
    final colorScheme = Theme.of(context).colorScheme;
    final ride = entry.ride;
    final share = entry.share;

    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      color: entry.isGroup ? colorScheme.primary : colorScheme.tertiary,
      icon: entry.isGroup
          ? Icons.pedal_bike_rounded
          : Icons.share_location_rounded,
      onTap: () => context.push(
        ride != null
            ? '/rides/${ride.sessionId}'
            : AppRoutes.publicSharePath(share!.shareToken),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          title: Text(
            ride != null
                ? (ride.name?.trim().isNotEmpty ?? false
                      ? ride.name!
                      : ride.groupName)
                : 'Viaje individual',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: Text(
            [
              if (ride != null) ride.groupName,
              dateFormat.format(entry.startedAt.toLocal()),
              if (duration != null) _formatDuration(duration),
            ].join(' · '),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}

class _AccidentHistoryTab extends ConsumerWidget {
  const _AccidentHistoryTab();

  static final _dateFormat = DateFormat.yMMMd().add_Hm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accidentsAsync = ref.watch(accidentHistoryProvider);

    return switch (accidentsAsync) {
      AsyncData(:final value) =>
        value.isEmpty
            ? const EmptyState(
                icon: Icons.shield_outlined,
                message: 'No hay eventos de accidente registrados.',
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xxxl,
                ),
                itemCount: value.length,
                itemBuilder: (context, index) => _AccidentHistoryTile(
                  event: value[index],
                  dateFormat: _dateFormat,
                  isFirst: index == 0,
                  isLast: index == value.length - 1,
                ),
              ),
      AsyncError(:final error) => _ErrorState(error: error),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _AccidentHistoryTile extends StatelessWidget {
  const _AccidentHistoryTile({
    required this.event,
    required this.dateFormat,
    required this.isFirst,
    required this.isLast,
  });

  final AccidentEvent event;
  final DateFormat dateFormat;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _statusLabelAndColor(context, event.status);
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      color: color,
      icon: Icons.warning_amber_rounded,
      onTap: () => context.push('/accidents/${event.id}'),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          title: Text(dateFormat.format(event.occurredAt.toLocal())),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(label: label, color: color),
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }

  static (String, Color) _statusLabelAndColor(
    BuildContext context,
    AccidentEventStatus status,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return switch (status) {
      AccidentEventStatus.candidate => ('Evaluando', scheme.secondary),
      AccidentEventStatus.cancelled => ('Falsa alarma', scheme.outline),
      AccidentEventStatus.confirmed => ('Confirmado', scheme.error),
      AccidentEventStatus.notified => ('Notificado', scheme.error),
      AccidentEventStatus.resolved => ('Resuelto', scheme.primary),
    };
  }
}

class _StatisticsTab extends ConsumerWidget {
  const _StatisticsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(rideStatisticsProvider);

    return switch (statsAsync) {
      AsyncData(:final value) => _StatisticsBody(stats: value),
      AsyncError(:final error) => _ErrorState(error: error),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _StatisticsBody extends StatelessWidget {
  const _StatisticsBody({required this.stats});

  final RideStatistics stats;

  @override
  Widget build(BuildContext context) {
    final hours = stats.totalRideDuration.inHours;
    final minutes = stats.totalRideDuration.inMinutes.remainder(60);
    final individualHours = stats.totalIndividualRideDuration.inHours;
    final individualMinutes = stats.totalIndividualRideDuration.inMinutes
        .remainder(60);

    return GridView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.1,
      ),
      children: [
        _StatTile(
          icon: Icons.pedal_bike_rounded,
          label: 'Viajes de grupo',
          value: '${stats.totalRides}',
        ),
        _StatTile(
          icon: Icons.timer_rounded,
          label: 'Tiempo total en grupo',
          value: hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m',
        ),
        // Solo aparecen si el rider alguna vez compartió un "viaje
        // individual" — no tiene sentido mostrar dos ceros a alguien que
        // nunca usó esa función.
        if (stats.totalIndividualRides > 0) ...[
          _StatTile(
            icon: Icons.share_location_rounded,
            label: 'Rutas individuales',
            value: '${stats.totalIndividualRides}',
            color: Theme.of(context).colorScheme.tertiary,
          ),
          _StatTile(
            icon: Icons.timer_outlined,
            label: 'Tiempo total solo',
            value: individualHours > 0
                ? '${individualHours}h ${individualMinutes}m'
                : '${individualMinutes}m',
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ],
        _StatTile(
          icon: Icons.warning_amber_rounded,
          label: 'Accidentes confirmados',
          value: '${stats.totalAccidents}',
          color: Theme.of(context).colorScheme.error,
        ),
        if (stats.lastRideAt != null)
          _StatTile(
            icon: Icons.event_rounded,
            label: 'Último viaje',
            value: DateFormat.yMMMd().format(stats.lastRideAt!.toLocal()),
          ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: tint, size: 26),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(error.toString(), textAlign: TextAlign.center),
      ),
    );
  }
}
