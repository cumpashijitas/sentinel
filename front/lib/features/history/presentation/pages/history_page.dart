import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/hub_scaffold.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../../shared/widgets/timeline_tile.dart';
import '../../../accidents/domain/entities/accident_event.dart';
import '../../../rides/domain/entities/ride_history_entry.dart';
import '../../domain/entities/ride_statistics.dart';
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

class _RideHistoryTab extends ConsumerWidget {
  const _RideHistoryTab();

  static final _dateFormat = DateFormat.yMMMd().add_Hm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(rideHistoryProvider);

    return switch (ridesAsync) {
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
                itemBuilder: (context, index) => _RideHistoryTile(
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

class _RideHistoryTile extends StatelessWidget {
  const _RideHistoryTile({
    required this.entry,
    required this.dateFormat,
    required this.isFirst,
    required this.isLast,
  });

  final RideHistoryEntry entry;
  final DateFormat dateFormat;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final duration = entry.duration;
    final colorScheme = Theme.of(context).colorScheme;
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      color: colorScheme.primary,
      icon: Icons.pedal_bike_rounded,
      onTap: () => context.push('/rides/${entry.sessionId}'),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          title: Text(
            entry.name?.trim().isNotEmpty ?? false
                ? entry.name!
                : entry.groupName,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: Text(
            [
              entry.groupName,
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
          label: 'Viajes completados',
          value: '${stats.totalRides}',
        ),
        _StatTile(
          icon: Icons.timer_rounded,
          label: 'Tiempo total en ruta',
          value: hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m',
        ),
        _StatTile(
          icon: Icons.warning_amber_rounded,
          label: 'Accidentes confirmados',
          value: '${stats.totalAccidents}',
          color: Theme.of(context).colorScheme.tertiary,
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
