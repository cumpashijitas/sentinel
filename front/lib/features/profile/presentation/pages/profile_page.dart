import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../history/domain/entities/ride_statistics.dart';
import '../../../history/presentation/controllers/history_controller.dart';
import '../../domain/entities/profile.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _whatsappAlertsOptIn = false;

  /// The form fields are pre-filled once, the first time the profile
  /// finishes loading — after that the text fields are the source of
  /// truth for what's on screen, so a background refetch (e.g. after
  /// save()) doesn't clobber whatever the user is mid-typing.
  bool _fieldsPopulated = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _populateFields(Profile profile) {
    _displayNameController.text = profile.displayName;
    _phoneController.text = profile.phone ?? '';
    _whatsappAlertsOptIn = profile.whatsappAlertsOptIn;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final phone = _phoneController.text.trim();
    await ref
        .read(profileControllerProvider.notifier)
        .save(
          displayName: _displayNameController.text.trim(),
          phone: phone.isEmpty ? null : phone,
          whatsappAlertsOptIn: _whatsappAlertsOptIn,
        );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);

    // Populate the form fields the first time the profile loads. Reading
    // `.value` directly here (rather than `ref.listen(..., fireImmediately:
    // true)`, which `WidgetRef.listen` doesn't support) means this also
    // covers the case where the data is already cached and arrives on the
    // very first build.
    final loadedProfile = profileAsync.value;
    if (loadedProfile != null && !_fieldsPopulated) {
      _fieldsPopulated = true;
      _populateFields(loadedProfile);
    }

    ref.listen(profileControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.toString())));
      } else if (previous?.isLoading ?? false) {
        if (next.hasValue) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Perfil actualizado.')),
            );
        }
      }
    });

    final isSaving = ref.watch(profileControllerProvider).isLoading;

    return Scaffold(
      body: Column(
        children: [
          const SectionHeader(icon: Icons.person_rounded, title: 'Perfil'),
          Expanded(
            child: switch (profileAsync) {
              AsyncData(:final value) => _ProfileForm(
                formKey: _formKey,
                displayNameController: _displayNameController,
                phoneController: _phoneController,
                avatarUrl: value.avatarUrl,
                whatsappAlertsOptIn: _whatsappAlertsOptIn,
                onWhatsappAlertsOptInChanged: (checked) =>
                    setState(() => _whatsappAlertsOptIn = checked),
                isSaving: isSaving,
                onSubmit: _submit,
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

class _ProfileForm extends StatelessWidget {
  const _ProfileForm({
    required this.formKey,
    required this.displayNameController,
    required this.phoneController,
    required this.avatarUrl,
    required this.whatsappAlertsOptIn,
    required this.onWhatsappAlertsOptInChanged,
    required this.isSaving,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController displayNameController;
  final TextEditingController phoneController;
  final String? avatarUrl;
  final bool whatsappAlertsOptIn;
  final ValueChanged<bool> onWhatsappAlertsOptInChanged;
  final bool isSaving;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: colorScheme.primaryContainer,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl!)
                          : null,
                      child: avatarUrl == null
                          ? Icon(
                              Icons.person_rounded,
                              size: 40,
                              color: colorScheme.onPrimaryContainer,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const _ProfileActivitySummary(),
                  const SizedBox(height: AppSpacing.xxl),
                  AppTextField(
                    label: 'Nombre',
                    controller: displayNameController,
                    textInputAction: TextInputAction.next,
                    enabled: !isSaving,
                    prefixIcon: Icons.badge_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa tu nombre.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Teléfono (opcional)',
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    enabled: !isSaving,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Card(
                    child: SwitchListTile(
                      title: const Text('Alertas de accidente por WhatsApp'),
                      subtitle: const Text(
                        'Tus compañeros de viaje podrán avisarte por WhatsApp '
                        'si confirman un accidente.',
                      ),
                      value: whatsappAlertsOptIn,
                      onChanged: isSaving
                          ? null
                          : onWhatsappAlertsOptInChanged,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: 'Guardar',
                    isLoading: isSaving,
                    onPressed: onSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pedido explícito en vivo: "una especie de perfil por usuario, ahí se
/// guarden las rutas con sus grupos, sus rutas individuales, accidentes,
/// estadísticas" — el perfil ahora muestra ese resumen de un vistazo,
/// derivado de [rideStatisticsProvider] (que ya combina viajes de grupo,
/// shares individuales y accidentes — ver `RideStatisticsCalculator`), con
/// un acceso directo al detalle completo (`HistoryPage`), en vez de
/// duplicar esas listas acá.
class _ProfileActivitySummary extends ConsumerWidget {
  const _ProfileActivitySummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(rideStatisticsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tu actividad', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.md),
            switch (statsAsync) {
              AsyncData(:final value) => _SummaryRow(stats: value),
              AsyncError(:final error) => Text(error.toString()),
              _ => const Center(child: CircularProgressIndicator()),
            },
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => context.push(AppRoutes.history),
                icon: const Icon(Icons.chevron_right_rounded),
                label: const Text('Ver historial completo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.stats});

  final RideStatistics stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryStat(
          icon: Icons.route_rounded,
          value: '${stats.totalActivities}',
          label: 'Actividades',
        ),
        _SummaryStat(
          icon: Icons.groups_rounded,
          value: '${stats.totalRides}',
          label: 'De grupo',
        ),
        _SummaryStat(
          icon: Icons.share_location_rounded,
          value: '${stats.totalIndividualRides}',
          label: 'Individuales',
        ),
        _SummaryStat(
          icon: Icons.warning_amber_rounded,
          value: '${stats.totalAccidents}',
          label: 'Accidentes',
          color: Theme.of(context).colorScheme.error,
        ),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.primary;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: tint, size: 20),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
