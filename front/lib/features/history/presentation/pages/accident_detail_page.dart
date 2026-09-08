import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../accidents/domain/entities/accident_event.dart';
import '../controllers/history_controller.dart';

/// Read-only detail for a single `accident_events` row — reached either
/// from the "Accidentes" tab of [HistoryPage] or a direct `/accidents/:id`
/// link (e.g. a future push notification's deep link). No medical
/// information is shown here, only what `accident_events` actually stores
/// (see `docs/database.md`) — the payload/columns were already scoped down
/// to the minimum in Fase 8's alert dispatch (`docs/alerts.md`).
class AccidentDetailPage extends ConsumerWidget {
  const AccidentDetailPage({required this.accidentId, super.key});

  final String accidentId;

  static final _dateFormat = DateFormat.yMMMMd().add_Hms();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(accidentDetailProvider(accidentId));

    return Scaffold(
      body: Column(
        children: [
          const SectionHeader(
            icon: Icons.warning_amber_rounded,
            accentColor: AppTheme.sos,
            title: 'Accidente',
          ),
          Expanded(
            child: switch (eventAsync) {
              AsyncData(:final value) => _AccidentDetailBody(
                event: value,
                dateFormat: _dateFormat,
              ),
              AsyncError(:final error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(error.toString(), textAlign: TextAlign.center),
                ),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}

class _AccidentDetailBody extends StatelessWidget {
  const _AccidentDetailBody({required this.event, required this.dateFormat});

  final AccidentEvent event;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final hasLocation = event.latitude != null && event.longitude != null;

    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusChip(
                  label: _statusLabel(event.status),
                  color: colorScheme.error,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(dateFormat.format(event.occurredAt.toLocal())),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _DetailTile(
          icon: Icons.speed_outlined,
          label: 'Impacto registrado',
          value: '${event.impactMps2.toStringAsFixed(1)} m/s²',
        ),
        if (event.gForce != null)
          _DetailTile(
            icon: Icons.compress_outlined,
            label: 'Fuerza G',
            value: event.gForce!.toStringAsFixed(1),
          ),
        if (event.speedKmh != null)
          _DetailTile(
            icon: Icons.speed_outlined,
            label: 'Velocidad previa',
            value: '${event.speedKmh!.toStringAsFixed(0)} km/h',
          ),
        if (event.confidenceScore != null)
          _DetailTile(
            icon: Icons.percent_outlined,
            label: 'Confianza de la detección',
            value: '${(event.confidenceScore! * 100).round()}%',
          ),
        if (hasLocation)
          _DetailTile(
            icon: Icons.place_outlined,
            label: 'Ubicación',
            value:
                '${event.latitude!.toStringAsFixed(5)}, '
                '${event.longitude!.toStringAsFixed(5)}',
          ),
        if (event.sessionId != null) ...[
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => context.push('/rides/${event.sessionId}'),
            icon: const Icon(Icons.pedal_bike_outlined),
            label: const Text('Ver viaje'),
          ),
        ],
      ],
    );
  }

  static String _statusLabel(AccidentEventStatus status) => switch (status) {
    AccidentEventStatus.candidate => 'Evaluando',
    AccidentEventStatus.cancelled => 'Falsa alarma — marcado como "Estoy bien"',
    AccidentEventStatus.confirmed => 'Confirmado',
    AccidentEventStatus.notified => 'Confirmado — grupo y contactos avisados',
    AccidentEventStatus.resolved => 'Resuelto',
  };
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
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
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
