import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import 'hub_navigation.dart';

/// Persistent navigation around the app's five "hub" screens — a bottom
/// [NavigationBar] on phone-width layouts, a side [NavigationRail] once the
/// window is wide enough ([showsHubRail]). Replaces the old split between
/// a Web-only [AdaptiveShell] (`NavigationRail`) and a mobile-only
/// [AppDrawer] (a hamburger menu) from the UI/UX redesign pass: a bottom
/// tab bar is the native, one-tap pattern phones actually use — a drawer
/// buried behind an AppBar icon never earned its keep as this app's
/// primary way to switch sections.
///
/// [child] is whatever the currently-matched hub route already renders —
/// a full page with its own `Scaffold`/`AppBar` (see `HubScaffold`). This
/// shell doesn't strip or replace that chrome, it just wraps it with one
/// more layer: nesting a `Scaffold` inside another `Scaffold`'s body is
/// exactly how Flutter expects "page chrome" and "app chrome" to compose.
class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = hubDestinations.indexWhere(
      (d) => location == d.path || location.startsWith('${d.path}/'),
    );

    if (showsHubRail(context)) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex == -1 ? null : selectedIndex,
              onDestinationSelected: (index) =>
                  context.go(hubDestinations[index].path),
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final d in hubDestinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      // Modo Oscuro Táctico: barra acoplada al borde, separada del
      // contenido por un borde técnico de 1px arriba — no la "píldora"
      // flotante con sombra pesada de la pasada de diseño anterior. Menos
      // "app amigable", más panel de instrumentos.
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: selectedIndex == -1 ? 0 : selectedIndex,
            onDestinationSelected: (index) =>
                context.go(hubDestinations[index].path),
            destinations: [
              for (final d in hubDestinations)
                NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: d.label,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
