import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/section_header.dart';
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
      body: Column(
        children: [
          SectionHeader(
            icon: Icons.groups_rounded,
            title: groupAsync.when(
              data: (group) => group.name,
              loading: () => 'Grupo',
              error: (_, _) => 'Grupo',
            ),
            trailing: groupAsync.maybeWhen(
              data: (group) => IconButton(
                tooltip: 'Editar grupo',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => showEditGroupSheet(context, group),
              ),
              orElse: () => null,
            ),
          ),
          Expanded(
            child: groupAsync.when(
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
          ),
        ],
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

/// Un contenedor de tarjeta escrito a mano, sin pasar por `CardTheme` — el
/// mismo look (fondo `AppTheme.panel`, borde técnico de 1px, radio 8) pero
/// con cada valor puesto explícito acá, no heredado de ningún lado. Se
/// reescribió la pantalla completa de grupo con este tipo de bloque en
/// vez de `Card`/`ListTile`/`EmptyState` porque, en un navegador real
/// (nunca en las pruebas automatizadas), la tarjeta del viaje activo se
/// veía sin texto ni botón sin ningún error en consola ni en la terminal
/// de Flutter — no se pudo aislar la causa exacta a tiempo, así que se
/// optó por sacar del medio toda dependencia compartida en este tramo de
/// la pantalla en vez de seguir reparando encima de ella.
class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (group.description != null) ...[
          const Text(
            'Descripción',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            group.description!,
            style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (group.pinnedNote != null || isAdmin) ...[
          _PinnedNotePanel(group: group, isAdmin: isAdmin),
          const SizedBox(height: AppSpacing.lg),
        ],
        _RideSessionCard(groupId: group.id, isAdmin: isAdmin),
        const SizedBox(height: AppSpacing.lg),
        _InviteCodeCard(inviteCode: group.inviteCode),
        const SizedBox(height: AppSpacing.xl),
        const Text(
          'Integrantes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        switch (membersAsync) {
          AsyncData(:final value) => Column(
            children: value
                .map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _MemberTile(
                      groupId: group.id,
                      member: m,
                      canManage: isAdmin,
                      isSelf: m.userId == currentUserId,
                      isOwnerRow: m.role == GroupMemberRole.owner,
                    ),
                  ),
                )
                .toList(),
          ),
          AsyncError(:final error) => Text(error.toString()),
          _ => const Center(child: CircularProgressIndicator()),
        },
        const SizedBox(height: AppSpacing.xl),
        if (isOwner)
          const Text(
            'Eres el propietario: no puedes abandonar el grupo. Transfiere '
            'la propiedad o archívalo primero.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
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

    Future<void> onStart() async {
      final started = await ref
          .read(rideSessionActionsControllerProvider.notifier)
          .start(groupId: groupId);
      if (started == null || !context.mounted) return;
      unawaited(context.push('/rides/${started.id}/map'));
    }

    Future<void> onFinish(RideSession session) async {
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
            .finish(sessionId: session.id, groupId: groupId);
      }
    }

    return switch (sessionAsync) {
      AsyncData(value: final session?) => _ActiveSessionPanel(
        session: session,
        isAdmin: isAdmin,
        onFinish: () => onFinish(session),
      ),
      AsyncData() when !isAdmin => const _Panel(
        child: Text(
          'No hay ningún viaje activo.',
          style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
        ),
      ),
      AsyncData() => _NoActiveSessionPanel(
        isStarting: isStarting,
        onStart: onStart,
      ),
      AsyncError(:final error) => _Panel(
        child: Text(
          error.toString(),
          style: const TextStyle(fontSize: 14, color: AppTheme.sos),
        ),
      ),
      _ => const _Panel(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

/// Estado "sin viaje activo, sos admin" — escrito a mano, sin
/// `EmptyState`: icono, mensaje y botón en un `Column` plano.
class _NoActiveSessionPanel extends StatelessWidget {
  const _NoActiveSessionPanel({
    required this.isStarting,
    required this.onStart,
  });

  final bool isStarting;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.5)),
            ),
            child: const Icon(
              Icons.pedal_bike_outlined,
              size: 28,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'No hay ningún viaje activo.',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isStarting ? null : onStart,
              child: Text(isStarting ? 'Iniciando…' : 'Iniciar viaje'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Viaje activo — icono, nombre, estado y botón "Ver mapa", todo en un
/// `Column`/`Row` liso, sin `ListTile`.
class _ActiveSessionPanel extends StatelessWidget {
  const _ActiveSessionPanel({
    required this.session,
    required this.isAdmin,
    required this.onFinish,
  });

  final RideSession session;
  final bool isAdmin;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final statusLabel = session.status == RideSessionStatus.waiting
        ? 'Esperando'
        : 'En curso';

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.5),
                  ),
                ),
                child: const Icon(
                  Icons.pedal_bike_rounded,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  session.name ?? 'Viaje en curso',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.6)),
            ),
            child: Text(
              statusLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.accent,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.push('/rides/${session.id}/map'),
              child: const Text('Ver mapa'),
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onFinish,
                child: const Text('Finalizar viaje'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Aviso fijado del grupo — un solo texto visible para todos, editable
/// por cualquier admin. Si no hay aviso y quien mira no es admin, este
/// panel ni se construye (ver `_GroupDetailBody`).
class _PinnedNotePanel extends StatelessWidget {
  const _PinnedNotePanel({required this.group, required this.isAdmin});

  final RideGroup group;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final note = group.pinnedNote;
    return _Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.campaign_outlined, color: AppTheme.accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aviso del grupo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note ?? 'Sin avisos por ahora.',
                  style: TextStyle(
                    fontSize: 16,
                    color: note == null ? AppTheme.textMuted : Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (isAdmin)
            IconButton(
              tooltip: note == null ? 'Fijar aviso' : 'Editar aviso',
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => showEditNoteSheet(context, group),
            ),
        ],
      ),
    );
  }
}

class _InviteCodeCard extends StatelessWidget {
  const _InviteCodeCard({required this.inviteCode});

  final String inviteCode;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        children: [
          const Icon(Icons.key_outlined, color: AppTheme.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Código de invitación',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  inviteCode,
                  style: AppTheme.telemetryStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ).copyWith(letterSpacing: 3),
                ),
              ],
            ),
          ),
          IconButton(
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
        ],
      ),
    );
  }
}

enum _MemberAction { promote, demote, remove }

/// Sin las acciones de administrar (promover/degradar/expulsar) hoy no
/// existía ninguna forma de sacar a alguien del grupo ni de delegar
/// permisos — solo se podía crear el grupo y listo. `canManage` (isAdmin
/// del que mira) más las dos excepciones (no tocarse a sí mismo, no tocar
/// al propietario) definen cuándo aparece el menú.
class _MemberTile extends ConsumerWidget {
  const _MemberTile({
    required this.groupId,
    required this.member,
    required this.canManage,
    required this.isSelf,
    required this.isOwnerRow,
  });

  final String groupId;
  final GroupMember member;
  final bool canManage;
  final bool isSelf;
  final bool isOwnerRow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(groupMemberActionsControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.toString())));
      }
    });

    final roleColor = member.role == GroupMemberRole.member
        ? AppTheme.textMuted
        : AppTheme.accent;
    final showMenu = canManage && !isSelf && !isOwnerRow;

    return _Panel(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF4A2415),
            foregroundColor: Colors.white,
            backgroundImage: member.avatarUrl != null
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null
                ? const Icon(Icons.person_outline)
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              member.displayName,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: roleColor.withValues(alpha: 0.6)),
            ),
            child: Text(
              _roleLabel(member.role),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: roleColor,
              ),
            ),
          ),
          if (showMenu)
            PopupMenuButton<_MemberAction>(
              tooltip: 'Administrar integrante',
              icon: const Icon(Icons.more_vert, color: AppTheme.textMuted),
              onSelected: (action) => _handle(context, ref, action),
              itemBuilder: (context) => [
                if (member.role == GroupMemberRole.member)
                  const PopupMenuItem(
                    value: _MemberAction.promote,
                    child: Text('Hacer admin'),
                  )
                else
                  const PopupMenuItem(
                    value: _MemberAction.demote,
                    child: Text('Quitar admin'),
                  ),
                const PopupMenuItem(
                  value: _MemberAction.remove,
                  child: Text('Expulsar del grupo'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    _MemberAction action,
  ) async {
    switch (action) {
      case _MemberAction.promote:
        await ref
            .read(groupMemberActionsControllerProvider.notifier)
            .setRole(
              groupId: groupId,
              targetUserId: member.userId,
              role: GroupMemberRole.admin,
            );
      case _MemberAction.demote:
        await ref
            .read(groupMemberActionsControllerProvider.notifier)
            .setRole(
              groupId: groupId,
              targetUserId: member.userId,
              role: GroupMemberRole.member,
            );
      case _MemberAction.remove:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Expulsar integrante'),
            content: Text(
              '¿Expulsar a ${member.displayName} de este grupo?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Expulsar'),
              ),
            ],
          ),
        );
        if (confirmed ?? false) {
          await ref
              .read(groupMemberActionsControllerProvider.notifier)
              .remove(groupId: groupId, targetUserId: member.userId);
        }
    }
  }

  static String _roleLabel(GroupMemberRole role) => switch (role) {
    GroupMemberRole.owner => 'Propietario',
    GroupMemberRole.admin => 'Admin',
    GroupMemberRole.member => 'Miembro',
  };
}

/// Editar nombre/descripción de un grupo ya creado — antes no existía
/// ninguna forma de hacer esto una vez creado el grupo.
Future<void> showEditGroupSheet(BuildContext context, RideGroup group) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _EditGroupSheet(group: group),
  );
}

/// Fijar/editar/borrar el aviso del grupo — antes no existía ninguna
/// forma de avisarle algo a todo el grupo desde adentro de la app.
Future<void> showEditNoteSheet(BuildContext context, RideGroup group) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _EditNoteSheet(group: group),
  );
}

class _EditNoteSheet extends ConsumerStatefulWidget {
  const _EditNoteSheet({required this.group});

  final RideGroup group;

  @override
  ConsumerState<_EditNoteSheet> createState() => _EditNoteSheetState();
}

class _EditNoteSheetState extends ConsumerState<_EditNoteSheet> {
  late final _noteController = TextEditingController(
    text: widget.group.pinnedNote,
  );

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final note = _noteController.text.trim();
    final updated = await ref
        .read(groupNoteControllerProvider.notifier)
        .setNote(groupId: widget.group.id, note: note.isEmpty ? null : note);
    if (!mounted || updated == null) return;
    Navigator.of(context).pop();
  }

  Future<void> _clear() async {
    final updated = await ref
        .read(groupNoteControllerProvider.notifier)
        .setNote(groupId: widget.group.id);
    if (!mounted || updated == null) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(groupNoteControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.toString())));
      }
    });

    final isSaving = ref.watch(
      groupNoteControllerProvider.select((s) => s.isLoading),
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Aviso del grupo', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Aviso (visible para todo el grupo)',
              controller: _noteController,
              enabled: !isSaving,
              hintText: 'Ej: la salida del sábado se pospone a las 9am',
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Guardar', isLoading: isSaving, onPressed: _save),
            if (widget.group.pinnedNote != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: isSaving ? null : _clear,
                child: const Text('Quitar aviso'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EditGroupSheet extends ConsumerStatefulWidget {
  const _EditGroupSheet({required this.group});

  final RideGroup group;

  @override
  ConsumerState<_EditGroupSheet> createState() => _EditGroupSheetState();
}

class _EditGroupSheetState extends ConsumerState<_EditGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.group.name);
  late final _descriptionController = TextEditingController(
    text: widget.group.description,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final description = _descriptionController.text.trim();
    final updated = await ref
        .read(groupEditControllerProvider.notifier)
        .edit(
          groupId: widget.group.id,
          name: _nameController.text.trim(),
          description: description.isEmpty ? null : description,
        );

    if (!mounted || updated == null) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(groupEditControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.toString())));
      }
    });

    final isSaving = ref.watch(
      groupEditControllerProvider.select((s) => s.isLoading),
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Editar grupo', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Nombre',
                controller: _nameController,
                enabled: !isSaving,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ingresa un nombre.'
                    : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Descripción (opcional)',
                controller: _descriptionController,
                enabled: !isSaving,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Guardar',
                isLoading: isSaving,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
