import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/hub_scaffold.dart';
import '../../../../app/router.dart' show AppRoutes;
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../emergency_contacts/presentation/controllers/emergency_contacts_controller.dart';
import '../../../groups/presentation/controllers/groups_controller.dart';
import '../../../rides/presentation/controllers/live_tracking_controller.dart';
import '../../../vehicles/presentation/controllers/vehicles_controller.dart';

/// Landing screen — Modo Oscuro Táctico. Panel plano (mismo header que
/// cualquier hub, ver [HubScaffold]) seguido de dos bloques con jerarquía
/// deliberadamente distinta:
///
/// 1. [_SosPanel] — aislado estructuralmente en su propia sección, fondo
///    rojo de alta visibilidad, nada más comparte esa fila. Es la acción
///    manual de emergencia que existe hoy en la app (compartir ubicación
///    en vivo con quien sea, no solo contactos registrados).
/// 2. Una grilla compacta de "elementos guardados" — grupos, vehículos,
///    contactos — densidad de información en vez de una tarjeta grande
///    por cada cosa. Los números son datos, así que van en monoespaciada.
///
/// Deliberadamente NO repite Grupos/Vehículos/Contactos/Historial como
/// atajos de navegación separados — [AppShell] ya los tiene en la barra
/// inferior; esta grilla son *contadores* que además llevan a cada
/// sección al tocarlos, no una segunda ruta de navegación duplicada (bug
/// real ya corregido en una pasada anterior).
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps authControllerProvider (autoDispose) alive across signOut()'s
    // await below, and surfaces a failure — neither happened before: with
    // nothing watching/listening to it, the provider could be disposed
    // mid-signOut (the same "nothing keeps an autoDispose provider alive
    // across an await" trap docs/architecture.md already documents for
    // reads, here on the write side), and a failure had nowhere to show.
    ref.listen(authControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.toString())));
      }
    });

    // Pedido explícito en vivo: el permiso de ubicación se pide acá, apenas
    // se entra a la app — no en el mapa, que ya no debe "suponer" nada al
    // respecto. Resultado ignorado a propósito (mismo patrón que
    // `pushTokenRegistrationProvider` en `app.dart`): solo importa que el
    // diálogo del sistema aparezca una vez por sesión, `keepAlive` en el
    // provider evita que se repita en cada rebuild.
    ref.watch(locationPermissionOnEntryProvider);

    final user = ref.watch(authStateChangesProvider).value;
    final firstName = user?.displayName?.trim().split(' ').first;
    final groupsCount = ref.watch(myGroupsProvider).value?.length;
    final vehiclesCount = ref.watch(vehiclesProvider).value?.length;
    final contactsCount = ref.watch(emergencyContactsProvider).value?.length;

    return HubScaffold(
      title: firstName == null || firstName.isEmpty
          ? 'Panel'
          : 'Panel — $firstName',
      icon: Icons.dashboard_outlined,
      subtitle: 'Así está tu red de seguridad hoy',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SosPanel(onTap: () => context.push(AppRoutes.emergencyShare)),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'GUARDADOS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 0.95,
            children: [
              _MetricTile(
                icon: Icons.groups_outlined,
                label: 'Grupos',
                value: groupsCount,
                onTap: () => context.push(AppRoutes.groups),
              ),
              _MetricTile(
                icon: Icons.two_wheeler_outlined,
                label: 'Vehículos',
                value: vehiclesCount,
                onTap: () => context.push(AppRoutes.vehicles),
              ),
              _MetricTile(
                icon: Icons.contact_phone_outlined,
                label: 'Contactos',
                value: contactsCount,
                onTap: () => context.push(AppRoutes.emergencyContacts),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Componente de emergencia aislado — spec: fondo rojo de alta
/// visibilidad, tipografía semibold, sección propia sin compartir fila
/// con ningún otro control del tablero. Es un `Card` más ancho y sin
/// borde técnico gris (el rojo ya es su propio límite visual) para que
/// nada lo confunda con una tarjeta de datos cualquiera.
class _SosPanel extends StatelessWidget {
  const _SosPanel({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.sos,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.share_location_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'S.O.S. — Compartir ubicación',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Compartí un link en vivo con quien quieras antes de salir',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

/// Una celda de la grilla de "guardados" — icono, número (monoespaciado,
/// es un dato) y etiqueta. `value == null` mientras el conteo todavía
/// carga: muestra un guion en vez de parpadear un cero incorrecto.
class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.textMuted, size: 20),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value == null ? '—' : '$value',
                style: AppTheme.telemetryStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
