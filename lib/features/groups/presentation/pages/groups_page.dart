import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_drawer.dart';
import '../../../../app/hub_navigation.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../domain/entities/ride_group.dart';
import '../controllers/groups_controller.dart';

/// On narrow layouts, [AppDrawer] on this page's `Scaffold` replaces the
/// back arrow — see that class's doc comment.
class GroupsPage extends ConsumerWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(groupActionsControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.toString())));
      }
    });

    final groupsAsync = ref.watch(myGroupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Grupos')),
      drawer: showsHubRail(context) ? null : const AppDrawer(),
      body: ResponsiveContent(
        child: switch (groupsAsync) {
          AsyncData(:final value) =>
            value.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: value.length,
                    itemBuilder: (context, index) =>
                        _GroupTile(group: value[index]),
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
      floatingActionButton: FloatingActionButton(
        tooltip: 'Crear o unirse a un grupo',
        onPressed: () => showGroupActionsSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Todavía no perteneces a ningún grupo.\nCrea uno o únete con un código.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group});

  final RideGroup group;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.groups_outlined)),
      title: Text(group.name),
      subtitle: group.description == null ? null : Text(group.description!),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/groups/${group.id}'),
    );
  }
}

/// Opens a small menu offering "create" or "join by code".
Future<void> showGroupActionsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Crear grupo'),
            onTap: () {
              Navigator.of(context).pop();
              showCreateGroupSheet(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.key_outlined),
            title: const Text('Unirse con código'),
            onTap: () {
              Navigator.of(context).pop();
              showJoinGroupSheet(context);
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> showCreateGroupSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _CreateGroupSheet(),
  );
}

Future<void> showJoinGroupSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _JoinGroupSheet(),
  );
}

class _CreateGroupSheet extends ConsumerStatefulWidget {
  const _CreateGroupSheet();

  @override
  ConsumerState<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends ConsumerState<_CreateGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final description = _descriptionController.text.trim();
    final created = await ref
        .read(groupActionsControllerProvider.notifier)
        .create(
          name: _nameController.text.trim(),
          description: description.isEmpty ? null : description,
        );

    if (!mounted || created == null) return;
    Navigator.of(context).pop();
    unawaited(context.push('/groups/${created.id}'));
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(
      groupActionsControllerProvider.select((s) => s.isLoading),
    );

    return _FormSheetScaffold(
      title: 'Crear grupo',
      formKey: _formKey,
      isSaving: isSaving,
      onSubmit: _submit,
      fields: [
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
      ],
    );
  }
}

class _JoinGroupSheet extends ConsumerStatefulWidget {
  const _JoinGroupSheet();

  @override
  ConsumerState<_JoinGroupSheet> createState() => _JoinGroupSheetState();
}

class _JoinGroupSheetState extends ConsumerState<_JoinGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final groupId = await ref
        .read(groupActionsControllerProvider.notifier)
        .joinByCode(_codeController.text.trim());

    if (!mounted || groupId == null) return;
    Navigator.of(context).pop();
    unawaited(context.push('/groups/$groupId'));
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(
      groupActionsControllerProvider.select((s) => s.isLoading),
    );

    return _FormSheetScaffold(
      title: 'Unirse a un grupo',
      formKey: _formKey,
      isSaving: isSaving,
      onSubmit: _submit,
      fields: [
        AppTextField(
          label: 'Código de invitación',
          controller: _codeController,
          enabled: !isSaving,
          textInputAction: TextInputAction.done,
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'Ingresa el código de invitación.'
              : null,
        ),
      ],
    );
  }
}

/// Shared chrome for the two forms above: title, fields, submit button,
/// keyboard-safe padding.
class _FormSheetScaffold extends StatelessWidget {
  const _FormSheetScaffold({
    required this.title,
    required this.formKey,
    required this.isSaving,
    required this.onSubmit,
    required this.fields,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final bool isSaving;
  final VoidCallback onSubmit;
  final List<Widget> fields;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...fields,
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Continuar',
                isLoading: isSaving,
                onPressed: onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
