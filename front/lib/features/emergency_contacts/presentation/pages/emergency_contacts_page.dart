import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/hub_scaffold.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../domain/entities/emergency_contact.dart';
import '../controllers/emergency_contacts_controller.dart';

class EmergencyContactsPage extends ConsumerWidget {
  const EmergencyContactsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(emergencyContactFormControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.toString())));
      }
    });

    final contactsAsync = ref.watch(emergencyContactsProvider);

    return HubScaffold(
      title: 'Contactos de emergencia',
      icon: Icons.emergency_rounded,
      subtitle: 'A quién avisamos si detectamos un accidente',
      body: ResponsiveContent(
        child: switch (contactsAsync) {
          AsyncData(:final value) => value.isEmpty
              ? EmptyState(
                  icon: Icons.emergency_outlined,
                  message: 'Todavía no agregaste ningún contacto de emergencia.',
                  actionLabel: 'Agregar contacto',
                  onAction: () => showContactFormSheet(context),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xxxl,
                  ),
                  itemCount: value.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _ContactTile(contact: value[index]),
                  ),
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
        tooltip: 'Agregar contacto',
        onPressed: () => showContactFormSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ContactTile extends ConsumerWidget {
  const _ContactTile({required this.contact});

  final EmergencyContact contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final subtitleParts = [
      contact.phone,
      if (contact.relationship != null) contact.relationship!,
    ];
    final channels = [
      if (contact.notifyPush) 'Push',
      if (contact.notifySms) 'SMS',
      if (contact.notifyWhatsapp) 'WhatsApp',
    ];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: colorScheme.tertiary),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.tertiaryContainer,
                      child: Icon(
                        Icons.person_rounded,
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitleParts.join(' · '),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                          if (channels.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              spacing: AppSpacing.xs,
                              children: [
                                for (final channel in channels)
                                  Chip(
                                    label: Text(channel),
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<_ContactAction>(
                      onSelected: (action) => switch (action) {
                        _ContactAction.edit => showContactFormSheet(
                          context,
                          contact: contact,
                        ),
                        _ContactAction.delete => _confirmDelete(
                          context,
                          ref,
                          contact,
                        ),
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _ContactAction.edit,
                          child: Text('Editar'),
                        ),
                        PopupMenuItem(
                          value: _ContactAction.delete,
                          child: Text('Eliminar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    EmergencyContact contact,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar contacto'),
        content: Text(
          '¿Eliminar a ${contact.name} de tus contactos de emergencia?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref
          .read(emergencyContactFormControllerProvider.notifier)
          .delete(contact.id);
    }
  }
}

enum _ContactAction { edit, delete }

/// Opens the add/edit form as a modal bottom sheet. Pass [contact] to edit
/// an existing one, or omit it to create a new one.
Future<void> showContactFormSheet(
  BuildContext context, {
  EmergencyContact? contact,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ContactFormSheet(contact: contact),
  );
}

class _ContactFormSheet extends ConsumerStatefulWidget {
  const _ContactFormSheet({this.contact});

  final EmergencyContact? contact;

  @override
  ConsumerState<_ContactFormSheet> createState() => _ContactFormSheetState();
}

class _ContactFormSheetState extends ConsumerState<_ContactFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.contact?.name,
  );
  late final _phoneController = TextEditingController(
    text: widget.contact?.phone,
  );
  late final _relationshipController = TextEditingController(
    text: widget.contact?.relationship,
  );
  late bool _notifyPush = widget.contact?.notifyPush ?? true;
  late bool _notifySms = widget.contact?.notifySms ?? false;
  late bool _notifyWhatsapp = widget.contact?.notifyWhatsapp ?? false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final relationship = _relationshipController.text.trim();
    final notifier = ref.read(emergencyContactFormControllerProvider.notifier);
    final contact = widget.contact;

    if (contact == null) {
      await notifier.create(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        relationship: relationship.isEmpty ? null : relationship,
        notifyPush: _notifyPush,
        notifySms: _notifySms,
        notifyWhatsapp: _notifyWhatsapp,
      );
    } else {
      await notifier.updateContact(
        id: contact.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        relationship: relationship.isEmpty ? null : relationship,
        notifyPush: _notifyPush,
        notifySms: _notifySms,
        notifyWhatsapp: _notifyWhatsapp,
      );
    }

    final hasError = ref.read(emergencyContactFormControllerProvider).hasError;
    if (!mounted) return;
    if (!hasError) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(
      emergencyContactFormControllerProvider.select((s) => s.isLoading),
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
              Text(
                widget.contact == null ? 'Agregar contacto' : 'Editar contacto',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Nombre',
                controller: _nameController,
                enabled: !isSaving,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ingresa el nombre.'
                    : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Teléfono',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: !isSaving,
                hintText: '+591 70000000',
                // Bug real encontrado en vivo: un número guardado sin
                // código de país (ej. "75449119") hace que Twilio y
                // WhatsApp fallen sin avisar — la alerta queda marcada
                // como enviada por dentro pero nunca llega. Exigir el
                // "+" acá corta ese problema en el origen, en vez de
                // descubrirlo recién cuando de verdad hace falta avisar.
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return 'Ingresa el teléfono.';
                  // Tolera espacios/guiones al escribir ("+591 700 00002")
                  // — solo la forma (código de país + dígitos) importa acá.
                  final digitsOnly = trimmed.replaceAll(RegExp(r'[^\d+]'), '');
                  if (!RegExp(r'^\+\d{8,15}$').hasMatch(digitsOnly)) {
                    return 'Incluye el código de país, ej: +591 70000000.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Relación (opcional)',
                controller: _relationshipController,
                enabled: !isSaving,
              ),
              const SizedBox(height: 16),
              Text(
                'Cómo avisarle',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Notificación push'),
                subtitle: const Text(
                  'Solo si esta persona también tiene la app instalada.',
                ),
                value: _notifyPush,
                onChanged: isSaving
                    ? null
                    : (value) => setState(() => _notifyPush = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mensaje de texto (SMS)'),
                subtitle: const Text(
                  'Le llega aunque no tenga la app ni internet.',
                ),
                value: _notifySms,
                onChanged: isSaving
                    ? null
                    : (value) => setState(() => _notifySms = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Notificar por WhatsApp'),
                subtitle: const Text(
                  'El contacto debe haber aceptado recibir mensajes de '
                  'este número de negocio.',
                ),
                value: _notifyWhatsapp,
                onChanged: isSaving
                    ? null
                    : (value) => setState(() => _notifyWhatsapp = value),
              ),
              const SizedBox(height: 16),
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
