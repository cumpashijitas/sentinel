import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../groups/domain/entities/group_member.dart';
import '../../../groups/presentation/controllers/groups_controller.dart';
import '../../domain/entities/ride_session.dart';
import '../../domain/entities/ride_session_participant.dart';
import '../controllers/ride_sessions_controller.dart';

class RideSessionPage extends ConsumerWidget {
  const RideSessionPage({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(rideSessionActionsControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.toString())));
      }
    });

    final sessionAsync = ref.watch(rideSessionProvider(sessionId));
    final participantsAsync = ref.watch(rideParticipantsProvider(sessionId));
    final currentUserId = ref.watch(authStateChangesProvider).value?.id;
    final isFinishing = ref.watch(
      rideSessionActionsControllerProvider.select((s) => s.isLoading),
    );

    return Scaffold(
      body: Column(
        children: [
          SectionHeader(
            icon: Icons.pedal_bike_rounded,
            title: sessionAsync.when(
              data: (session) => session.name ?? 'Viaje',
              loading: () => 'Viaje',
              error: (_, _) => 'Viaje',
            ),
          ),
          Expanded(
            child: sessionAsync.when(
              data: (session) => _RideSessionBody(
                session: session,
                participantsAsync: participantsAsync,
                currentUserId: currentUserId,
                isFinishing: isFinishing,
                onFinish: () => _confirmFinish(context, ref, session),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(error.toString(), textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmFinish(
    BuildContext context,
    WidgetRef ref,
    RideSession session,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar viaje'),
        content: const Text(
          '¿Finalizar este viaje para todos los integrantes?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref
          .read(rideSessionActionsControllerProvider.notifier)
          .finish(sessionId: session.id, groupId: session.groupId);
    }
  }
}

class _RideSessionBody extends ConsumerWidget {
  const _RideSessionBody({
    required this.session,
    required this.participantsAsync,
    required this.currentUserId,
    required this.isFinishing,
    required this.onFinish,
  });

  final RideSession session;
  final AsyncValue<List<RideSessionParticipant>> participantsAsync;
  final String? currentUserId;
  final bool isFinishing;
  final VoidCallback onFinish;

  static final _timeFormat = DateFormat.Hm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(groupMembersProvider(session.groupId));
    final currentMember = membersAsync.value?.cast<GroupMember?>().firstWhere(
      (m) => m?.userId == currentUserId,
      orElse: () => null,
    );
    final isAdmin =
        currentMember?.role == GroupMemberRole.owner ||
        currentMember?.role == GroupMemberRole.admin;
    final isActive =
        session.status == RideSessionStatus.waiting ||
        session.status == RideSessionStatus.active;

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
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pedal_bike_rounded,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _statusChip(context, session.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Iniciado: ${_timeFormat.format(session.startedAt.toLocal())}',
                ),
                if (session.endedAt != null)
                  Text(
                    'Finalizado: ${_timeFormat.format(session.endedAt!.toLocal())}',
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Participantes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        switch (participantsAsync) {
          AsyncData(:final value) =>
            value.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Sin participantes.'),
                  )
                : Column(
                    children: value
                        .map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _ParticipantTile(participant: p),
                          ),
                        )
                        .toList(),
                  ),
          AsyncError(:final error) => Text(error.toString()),
          _ => const Center(child: CircularProgressIndicator()),
        },
        const SizedBox(height: AppSpacing.lg),
        if (isActive)
          OutlinedButton.icon(
            onPressed: () => context.push('/rides/${session.id}/map'),
            icon: const Icon(Icons.map_outlined),
            label: const Text('Ver mapa'),
          ),
        const SizedBox(height: AppSpacing.sm),
        if (isActive && isAdmin)
          FilledButton.icon(
            onPressed: isFinishing ? null : onFinish,
            icon: const Icon(Icons.flag_outlined),
            label: const Text('Finalizar viaje'),
          ),
      ],
    );
  }

  static Widget _statusChip(BuildContext context, RideSessionStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      RideSessionStatus.waiting => ('Esperando para iniciar', colorScheme.secondary),
      RideSessionStatus.active => ('En curso', colorScheme.tertiary),
      RideSessionStatus.finished => ('Finalizado', colorScheme.primary),
      RideSessionStatus.cancelled => ('Cancelado', colorScheme.outline),
    };
    return StatusChip(label: label, color: color);
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({required this.participant});

  final RideSessionParticipant participant;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = participant.status == RideParticipantStatus.active;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: participant.avatarUrl != null
              ? NetworkImage(participant.avatarUrl!)
              : null,
          child: participant.avatarUrl == null
              ? const Icon(Icons.person_outline)
              : null,
        ),
        title: Text(participant.displayName),
        trailing: StatusChip(
          label: isActive ? 'En viaje' : 'Salió',
          color: isActive ? colorScheme.tertiary : colorScheme.outline,
        ),
      ),
    );
  }
}
