import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/hub_scaffold.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../domain/entities/ride_group.dart';
import '../controllers/groups_controller.dart';

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

    return HubScaffold(
      title: 'Grupos',
      icon: Icons.groups_rounded,
      body: ResponsiveContent(
        child: switch (groupsAsync) {
          AsyncData(:final value) => value.isEmpty
              ? EmptyState(
                  icon: Icons.groups_outlined,
                  message:
                      'Todavía no perteneces a ningún grupo.\nCrea uno o únete con un código.',
                  actionLabel: 'Crear o unirse',
                  onAction: () => showGroupActionsSheet(context),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xxxl,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.92,
                      ),
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

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group});

  final RideGroup group;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/groups/${group.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 64,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              color: colorScheme.primaryContainer,
              child: Icon(
                Icons.groups_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 30,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (group.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        group.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un solo bottom sheet con un selector Crear/Unirse arriba — antes eran
/// dos taps y dos sheets distintos (uno para elegir, otro para el
/// formulario), lo que hacía que "crear un grupo" y "unirse a uno" se
/// sintieran como flujos distintos e inconsistentes con cómo funciona
/// "agregar" en Vehículos (un solo tap ahí). Ahora "+" siempre abre esto
/// mismo, con "Crear grupo" preseleccionado.
Future<void> showGroupActionsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _GroupActionsSheet(),
  );
}

enum _GroupSheetMode { create, join }

class _GroupActionsSheet extends ConsumerStatefulWidget {
  const _GroupActionsSheet();

  @override
  ConsumerState<_GroupActionsSheet> createState() =>
      _GroupActionsSheetState();
}

class _GroupActionsSheetState extends ConsumerState<_GroupActionsSheet> {
  _GroupSheetMode _mode = _GroupSheetMode.create;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final notifier = ref.read(groupActionsControllerProvider.notifier);
    final String? destinationGroupId;
    if (_mode == _GroupSheetMode.create) {
      final description = _descriptionController.text.trim();
      final created = await notifier.create(
        name: _nameController.text.trim(),
        description: description.isEmpty ? null : description,
      );
      destinationGroupId = created?.id;
    } else {
      destinationGroupId = await notifier.joinByCode(
        _codeController.text.trim(),
      );
    }

    if (!mounted || destinationGroupId == null) return;
    Navigator.of(context).pop();
    unawaited(context.push('/groups/$destinationGroupId'));
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(
      groupActionsControllerProvider.select((s) => s.isLoading),
    );
    final isCreate = _mode == _GroupSheetMode.create;

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
              SegmentedButton<_GroupSheetMode>(
                segments: const [
                  ButtonSegment(
                    value: _GroupSheetMode.create,
                    label: Text('Crear grupo'),
                    icon: Icon(Icons.add_circle_outline),
                  ),
                  ButtonSegment(
                    value: _GroupSheetMode.join,
                    label: Text('Unirse con código'),
                    icon: Icon(Icons.key_outlined),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: isSaving
                    ? null
                    : (selection) => setState(() => _mode = selection.first),
              ),
              const SizedBox(height: 20),
              if (isCreate) ...[
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
              ] else
                AppTextField(
                  label: 'Código de invitación',
                  controller: _codeController,
                  enabled: !isSaving,
                  textInputAction: TextInputAction.done,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Ingresa el código de invitación.'
                      : null,
                ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Continuar',
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
