import 'package:flutter/material.dart';

import 'router.dart';

/// The five top-level sections the app switches between via persistent
/// chrome — a [NavigationRail] on wide layouts (`AdaptiveShell`, Fase 10)
/// or a [Drawer] on narrow ones (`AppDrawer`). Defined once, here, so the
/// rail and the drawer can never drift apart from each other.
typedef HubDestination = ({
  IconData icon,
  IconData selectedIcon,
  String label,
  String path,
});

const hubDestinations = <HubDestination>[
  (
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: 'Inicio',
    path: AppRoutes.home,
  ),
  (
    icon: Icons.groups_outlined,
    selectedIcon: Icons.groups,
    label: 'Grupos',
    path: AppRoutes.groups,
  ),
  (
    icon: Icons.two_wheeler_outlined,
    selectedIcon: Icons.two_wheeler,
    label: 'Vehículos',
    path: AppRoutes.vehicles,
  ),
  (
    icon: Icons.emergency_outlined,
    selectedIcon: Icons.emergency,
    label: 'Contactos',
    path: AppRoutes.emergencyContacts,
  ),
  (
    icon: Icons.history_outlined,
    selectedIcon: Icons.history,
    label: 'Historial',
    path: AppRoutes.history,
  ),
];

/// Below this width, a hub page shows [AppDrawer] instead of a back
/// arrow (see its doc comment for why); at/above it, `AdaptiveShell`
/// shows a persistent [NavigationRail] instead — the two are mutually
/// exclusive, one number decides which. Same order of magnitude as
/// Material's "medium" breakpoint, deliberately just one number rather
/// than the full M3 breakpoint system until a second one actually earns
/// its complexity.
const hubRailBreakpoint = 840.0;

bool showsHubRail(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= hubRailBreakpoint;
