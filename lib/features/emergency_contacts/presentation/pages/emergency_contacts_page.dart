import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_drawer.dart';
import '../../../../app/hub_navigation.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../domain/entities/emergency_contact.dart';
import '../controllers/emergency_contacts_controller.dart';

/// On narrow layouts, [AppDrawer] on this page's `Scaffold` replaces the
/// back arrow — see that class's doc comment.
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

    return Scaffold(
      appBar: AppBar(title: const Text('Contactos de emergencia')),
      drawer: showsHubRail(context) ? null : const AppDrawer(),
      body: ResponsiveContent(
        child: switch (contactsAsync) {
          AsyncData(:final value) =>
            value.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: value.length,
                    itemBuilder: (context, index) =>
                        _ContactTile(contact: value[index]),
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
              Icons.emergency_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Todavía no agregaste ningún contacto de emergencia.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends ConsumerWidget {
  const _ContactTile({required this.contact});

  final EmergencyContact contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitleParts = [
      contact.phone,
      if (contact.relationship != null) contact.relationship!,
    ];
    final channels = [
      if (contact.notifyPush) 'push',
      if (contact.notifySms) 'SMS',
      if (contact.notifyWhatsapp) 'WhatsApp',
    ];

    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
      title: Text(contact.name),
      subtitle: Text(
        [
          subtitleParts.join(' · '),
          if (channels.isNotEmpty) 'Alertas: ${channels.join(', ')}',
        ].join('\n'),
      ),
      isThreeLine: true,
      trailing: PopupMenuButton<_ContactAction>(
        onSelected: (action) => switch (action) {
          _ContactAction.edit => showContactFormSheet(
            context,
            contact: contact,
          ),
          _ContactAction.delete => _confirmDelete(context, ref, contact),
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: _ContactAction.edit, child: Text('Editar')),
          PopupMenuItem(value: _ContactAction.delete, child: Text('Eliminar')),
        ],
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
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ingresa el teléfono.'
                    : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Relación (opcional)',
                controller: _relationshipController,
                enabled: !isSaving,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Notificar por push'),
                value: _notifyPush,
                onChanged: isSaving
                    ? null
                    : (value) => setState(() => _notifyPush = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Notificar por SMS'),
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
