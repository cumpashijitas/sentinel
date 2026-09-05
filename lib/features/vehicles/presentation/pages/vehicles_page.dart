import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_drawer.dart';
import '../../../../app/hub_navigation.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../domain/entities/vehicle.dart';
import '../controllers/vehicles_controller.dart';

/// On narrow layouts, [AppDrawer] on this page's `Scaffold` replaces the
/// back arrow — see that class's doc comment.
class VehiclesPage extends ConsumerWidget {
  const VehiclesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(vehicleFormControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.toString())));
      }
    });

    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Vehículos')),
      drawer: showsHubRail(context) ? null : const AppDrawer(),
      body: ResponsiveContent(
        child: switch (vehiclesAsync) {
          AsyncData(:final value) =>
            value.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: value.length,
                    itemBuilder: (context, index) =>
                        _VehicleTile(vehicle: value[index]),
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
        tooltip: 'Agregar vehículo',
        onPressed: () => showVehicleFormSheet(context),
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
              Icons.two_wheeler_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Todavía no agregaste ningún vehículo.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleTile extends ConsumerWidget {
  const _VehicleTile({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitleParts = [
      if (vehicle.year != null) '${vehicle.year}',
      if (vehicle.color != null) vehicle.color!,
      if (vehicle.plate != null) vehicle.plate!,
    ];

    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.two_wheeler_outlined)),
      title: Text('${vehicle.brand} ${vehicle.model}'),
      subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join(' · ')),
      trailing: PopupMenuButton<_VehicleAction>(
        onSelected: (action) => switch (action) {
          _VehicleAction.edit => showVehicleFormSheet(
            context,
            vehicle: vehicle,
          ),
          _VehicleAction.delete => _confirmDelete(context, ref, vehicle),
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: _VehicleAction.edit, child: Text('Editar')),
          PopupMenuItem(value: _VehicleAction.delete, child: Text('Eliminar')),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Vehicle vehicle,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar vehículo'),
        content: Text(
          '¿Eliminar ${vehicle.brand} ${vehicle.model}? Esta acción no se puede deshacer.',
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
      await ref.read(vehicleFormControllerProvider.notifier).delete(vehicle.id);
    }
  }
}

enum _VehicleAction { edit, delete }

/// Opens the add/edit form as a modal bottom sheet. Pass [vehicle] to edit
/// an existing one, or omit it to create a new one.
Future<void> showVehicleFormSheet(BuildContext context, {Vehicle? vehicle}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _VehicleFormSheet(vehicle: vehicle),
  );
}

class _VehicleFormSheet extends ConsumerStatefulWidget {
  const _VehicleFormSheet({this.vehicle});

  final Vehicle? vehicle;

  @override
  ConsumerState<_VehicleFormSheet> createState() => _VehicleFormSheetState();
}

class _VehicleFormSheetState extends ConsumerState<_VehicleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _brandController = TextEditingController(
    text: widget.vehicle?.brand,
  );
  late final _modelController = TextEditingController(
    text: widget.vehicle?.model,
  );
  late final _yearController = TextEditingController(
    text: widget.vehicle?.year?.toString(),
  );
  late final _plateController = TextEditingController(
    text: widget.vehicle?.plate,
  );
  late final _colorController = TextEditingController(
    text: widget.vehicle?.color,
  );

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final year = _yearController.text.trim();
    final plate = _plateController.text.trim();
    final color = _colorController.text.trim();
    final notifier = ref.read(vehicleFormControllerProvider.notifier);
    final vehicle = widget.vehicle;

    if (vehicle == null) {
      await notifier.create(
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: year.isEmpty ? null : int.tryParse(year),
        plate: plate.isEmpty ? null : plate,
        color: color.isEmpty ? null : color,
      );
    } else {
      await notifier.updateVehicle(
        id: vehicle.id,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: year.isEmpty ? null : int.tryParse(year),
        plate: plate.isEmpty ? null : plate,
        color: color.isEmpty ? null : color,
      );
    }

    final hasError = ref.read(vehicleFormControllerProvider).hasError;
    if (!mounted) return;
    if (!hasError) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(
      vehicleFormControllerProvider.select((s) => s.isLoading),
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
                widget.vehicle == null ? 'Agregar vehículo' : 'Editar vehículo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Marca',
                controller: _brandController,
                enabled: !isSaving,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ingresa la marca.'
                    : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Modelo',
                controller: _modelController,
                enabled: !isSaving,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ingresa el modelo.'
                    : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Año (opcional)',
                controller: _yearController,
                keyboardType: TextInputType.number,
                enabled: !isSaving,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final year = int.tryParse(value.trim());
                  final currentYear = DateTime.now().year;
                  if (year == null || year < 1900 || year > currentYear + 1) {
                    return 'Ingresa un año válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Placa (opcional)',
                controller: _plateController,
                enabled: !isSaving,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Color (opcional)',
                controller: _colorController,
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
