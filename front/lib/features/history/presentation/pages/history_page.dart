import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/app_drawer.dart';
import '../../../../app/hub_navigation.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../accidents/domain/entities/accident_event.dart';
import '../../../rides/domain/entities/ride_history_entry.dart';
import '../../domain/entities/ride_statistics.dart';
import '../controllers/history_controller.dart';

/// Fase 9: three tabs over data the user already produced elsewhere in the
/// app — completed rides, past accident events, and a few numbers derived
/// from both. Nothing here writes anything; it's read-only, same spirit as
/// `RideSessionPage` showing history rather than driving it. On narrow
/// layouts, [AppDrawer] on this page's `Scaffold` replaces the back arrow
/// — see that class's doc comment.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historial'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Viajes'),
              Tab(text: 'Accidentes'),
              Tab(text: 'Estadísticas'),
            ],
          ),
        ),
        drawer: showsHubRail(context) ? null : const AppDrawer(),
        body: const ResponsiveContent(
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
            ? const _EmptyState(
                icon: Icons.pedal_bike_outlined,
                message: 'Todavía no completaste ningún viaje.',
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: value.length,
                itemBuilder: (context, index) => _RideHistoryTile(
                  entry: value[index],
                  dateFormat: _dateFormat,
                ),
              ),
      AsyncError(:final error) => _ErrorState(error: error),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _RideHistoryTile extends StatelessWidget {
  const _RideHistoryTile({required this.entry, required this.dateFormat});

  final RideHistoryEntry entry;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final duration = entry.duration;
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.pedal_bike_outlined)),
      title: Text(
        entry.name?.trim().isNotEmpty ?? false ? entry.name! : entry.groupName,
      ),
      subtitle: Text(
        [
          entry.groupName,
          dateFormat.format(entry.startedAt.toLocal()),
          if (duration != null) _formatDuration(duration),
        ].join(' · '),
      ),
      onTap: () => context.push('/rides/${entry.sessionId}'),
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
            ? const _EmptyState(
                icon: Icons.shield_outlined,
                message: 'No hay eventos de accidente registrados.',
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: value.length,
                itemBuilder: (context, index) => _AccidentHistoryTile(
                  event: value[index],
                  dateFormat: _dateFormat,
                ),
              ),
      AsyncError(:final error) => _ErrorState(error: error),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _AccidentHistoryTile extends StatelessWidget {
  const _AccidentHistoryTile({required this.event, required this.dateFormat});

  final AccidentEvent event;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _statusLabelAndColor(context, event.status);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(Icons.warning_amber_outlined, color: color),
      ),
      title: Text(dateFormat.format(event.occurredAt.toLocal())),
      subtitle: Text(label),
      onTap: () => context.push('/accidents/${event.id}'),
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatTile(
          icon: Icons.pedal_bike_outlined,
          label: 'Viajes completados',
          value: '${stats.totalRides}',
        ),
        _StatTile(
          icon: Icons.timer_outlined,
          label: 'Tiempo total en ruta',
          value: hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m',
        ),
        _StatTile(
          icon: Icons.warning_amber_outlined,
          label: 'Accidentes confirmados',
          value: '${stats.totalAccidents}',
        ),
        if (stats.lastRideAt != null)
          _StatTile(
            icon: Icons.event_outlined,
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
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
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
