import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
      appBar: AppBar(
        title: sessionAsync.when(
          data: (session) => Text(session.name ?? 'Viaje'),
          loading: () => const Text('Viaje'),
          error: (_, _) => const Text('Viaje'),
        ),
      ),
      body: sessionAsync.when(
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pedal_bike_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _statusLabel(session.status),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
        const SizedBox(height: 24),
        Text('Participantes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        switch (participantsAsync) {
          AsyncData(:final value) =>
            value.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Sin participantes.'),
                  )
                : Column(
                    children: value
                        .map((p) => _ParticipantTile(participant: p))
                        .toList(),
                  ),
          AsyncError(:final error) => Text(error.toString()),
          _ => const Center(child: CircularProgressIndicator()),
        },
        const SizedBox(height: 16),
        if (isActive)
          OutlinedButton.icon(
            onPressed: () => context.push('/rides/${session.id}/map'),
            icon: const Icon(Icons.map_outlined),
            label: const Text('Ver mapa'),
          ),
        const SizedBox(height: 8),
        if (isActive && isAdmin)
          FilledButton.icon(
            onPressed: isFinishing ? null : onFinish,
            icon: const Icon(Icons.flag_outlined),
            label: const Text('Finalizar viaje'),
          ),
      ],
    );
  }

  static String _statusLabel(RideSessionStatus status) => switch (status) {
    RideSessionStatus.waiting => 'Esperando para iniciar',
    RideSessionStatus.active => 'En curso',
    RideSessionStatus.finished => 'Finalizado',
    RideSessionStatus.cancelled => 'Cancelado',
  };
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({required this.participant});

  final RideSessionParticipant participant;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: participant.avatarUrl != null
            ? NetworkImage(participant.avatarUrl!)
            : null,
        child: participant.avatarUrl == null
            ? const Icon(Icons.person_outline)
            : null,
      ),
      title: Text(participant.displayName),
      trailing: Text(
        participant.status == RideParticipantStatus.active
            ? 'En viaje'
            : 'Salió',
      ),
    );
  }
}
