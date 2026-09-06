import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'hub_navigation.dart';

/// Persistent side navigation around the app's five "hub" screens — Fase
/// 10's Web dashboard. Only ever built on Web: `router.dart` is the single
/// place that decides whether this shell exists at all
/// (`PlatformCapabilities.isWeb`), per this repo's convention of keeping a
/// `kIsWeb`-shaped branch in one adapter instead of scattered through the
/// app (see `docs/architecture.md`, "Plataforma"). Nothing Android-facing
/// changes: this widget is never even constructed there.
///
/// [child] is whatever the currently-matched hub route already renders —
/// a full page with its own `Scaffold`/`AppBar`. This shell doesn't strip
/// or replace that chrome, it just places a [NavigationRail] next to it;
/// each page keeps owning its own app bar actions (profile, sign out,
/// per-page FAB, ...) exactly as it does on Android.
///
/// Below [hubRailBreakpoint] this is a no-op passthrough — each hub page
/// shows [AppDrawer] instead in that case (a `Scaffold`-level concern, set
/// on the page itself, not here; see that class's doc comment).
class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!showsHubRail(context)) return child;

    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = hubDestinations.indexWhere(
      (d) => location == d.path || location.startsWith('${d.path}/'),
    );

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
}
