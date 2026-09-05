import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../rides/domain/entities/ride_session.dart';
import '../../../rides/presentation/controllers/ride_sessions_controller.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/ride_group.dart';
import '../controllers/groups_controller.dart';

class GroupDetailPage extends ConsumerWidget {
  const GroupDetailPage({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(groupActionsControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.toString())));
      } else if ((previous?.isLoading ?? false) && next.hasValue) {
        // A successful leave() clears this page's own group from
        // myGroupsProvider; back out to the list rather than showing a
        // group the user no longer belongs to.
        if (context.canPop()) context.pop();
      }
    });

    final groupAsync = ref.watch(groupDetailProvider(groupId));
    final membersAsync = ref.watch(groupMembersProvider(groupId));
    final currentUserId = ref.watch(authStateChangesProvider).value?.id;
    final isLeaving = ref.watch(
      groupActionsControllerProvider.select((s) => s.isLoading),
    );

    return Scaffold(
      appBar: AppBar(
        title: groupAsync.when(
          data: (group) => Text(group.name),
          loading: () => const Text('Grupo'),
          error: (_, _) => const Text('Grupo'),
        ),
      ),
      body: groupAsync.when(
        data: (group) => _GroupDetailBody(
          group: group,
          membersAsync: membersAsync,
          currentUserId: currentUserId,
          isLeaving: isLeaving,
          onLeave: () => _confirmLeave(context, ref, group),
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

  Future<void> _confirmLeave(
    BuildContext context,
    WidgetRef ref,
    RideGroup group,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandonar grupo'),
        content: Text('¿Salir de "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(groupActionsControllerProvider.notifier).leave(group.id);
    }
  }
}

class _GroupDetailBody extends StatelessWidget {
  const _GroupDetailBody({
    required this.group,
    required this.membersAsync,
    required this.currentUserId,
    required this.isLeaving,
    required this.onLeave,
  });

  final RideGroup group;
  final AsyncValue<List<GroupMember>> membersAsync;
  final String? currentUserId;
  final bool isLeaving;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final currentMember = membersAsync.value?.cast<GroupMember?>().firstWhere(
      (m) => m?.userId == currentUserId,
      orElse: () => null,
    );
    final isOwner = currentMember?.role == GroupMemberRole.owner;
    final isAdmin = isOwner || currentMember?.role == GroupMemberRole.admin;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (group.description != null) ...[
          Text(group.description!),
          const SizedBox(height: 16),
        ],
        _RideSessionCard(groupId: group.id, isAdmin: isAdmin),
        const SizedBox(height: 16),
        _InviteCodeCard(inviteCode: group.inviteCode),
        const SizedBox(height: 24),
        Text('Integrantes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        switch (membersAsync) {
          AsyncData(:final value) => Column(
            children: value.map((m) => _MemberTile(member: m)).toList(),
          ),
          AsyncError(:final error) => Text(error.toString()),
          _ => const Center(child: CircularProgressIndicator()),
        },
        const SizedBox(height: 24),
        if (isOwner)
          Text(
            'Eres el propietario: no puedes abandonar el grupo. Transfiere '
            'la propiedad o archívalo primero.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          )
        else
          OutlinedButton.icon(
            onPressed: isLeaving ? null : onLeave,
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Salir del grupo'),
          ),
      ],
    );
  }
}

class _RideSessionCard extends ConsumerWidget {
  const _RideSessionCard({required this.groupId, required this.isAdmin});

  final String groupId;
  final bool isAdmin;

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

    final sessionAsync = ref.watch(activeSessionProvider(groupId));
    final isStarting = ref.watch(
      rideSessionActionsControllerProvider.select((s) => s.isLoading),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: switch (sessionAsync) {
          AsyncData(value: final session?) => _ActiveSessionRow(
            session: session,
          ),
          AsyncData() => _NoActiveSessionRow(
            isAdmin: isAdmin,
            isStarting: isStarting,
            onStart: () async {
              final started = await ref
                  .read(rideSessionActionsControllerProvider.notifier)
                  .start(groupId: groupId);
              if (started == null || !context.mounted) return;
              unawaited(context.push('/rides/${started.id}'));
            },
          ),
          AsyncError(:final error) => Text(error.toString()),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _ActiveSessionRow extends StatelessWidget {
  const _ActiveSessionRow({required this.session});

  final RideSession session;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.pedal_bike_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.name ?? 'Viaje en curso',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                session.status == RideSessionStatus.waiting
                    ? 'Esperando para iniciar'
                    : 'En curso',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        FilledButton(
          onPressed: () => context.push('/rides/${session.id}'),
          child: const Text('Ver viaje'),
        ),
      ],
    );
  }
}

class _NoActiveSessionRow extends StatelessWidget {
  const _NoActiveSessionRow({
    required this.isAdmin,
    required this.isStarting,
    required this.onStart,
  });

  final bool isAdmin;
  final bool isStarting;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return Text(
        'No hay ningún viaje activo.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return Row(
      children: [
        Expanded(
          child: Text(
            'No hay ningún viaje activo.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        FilledButton.icon(
          onPressed: isStarting ? null : onStart,
          icon: const Icon(Icons.play_arrow_outlined),
          label: const Text('Iniciar viaje'),
        ),
      ],
    );
  }
}

class _InviteCodeCard extends StatelessWidget {
  const _InviteCodeCard({required this.inviteCode});

  final String inviteCode;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.key_outlined),
        title: const Text('Código de invitación'),
        subtitle: Text(
          inviteCode,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(letterSpacing: 2),
        ),
        trailing: IconButton(
          tooltip: 'Copiar código',
          icon: const Icon(Icons.copy_outlined),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: inviteCode));
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Código copiado.')),
                );
            }
          },
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});

  final GroupMember member;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: member.avatarUrl != null
            ? NetworkImage(member.avatarUrl!)
            : null,
        child: member.avatarUrl == null
            ? const Icon(Icons.person_outline)
            : null,
      ),
      title: Text(member.displayName),
      trailing: Text(_roleLabel(member.role)),
    );
  }

  static String _roleLabel(GroupMemberRole role) => switch (role) {
    GroupMemberRole.owner => 'Propietario',
    GroupMemberRole.admin => 'Admin',
    GroupMemberRole.member => 'Miembro',
  };
}
