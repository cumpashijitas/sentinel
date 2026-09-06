import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import 'hub_navigation.dart';
import 'router.dart';

/// Replaces the back arrow on each of the five hub pages with a hamburger
/// menu, wired as `Scaffold(drawer: const AppDrawer())` directly on each
/// page (`HomePage`, `GroupsPage`, `VehiclesPage`,
/// `EmergencyContactsPage`, `HistoryPage`) — never on a detail page
/// (`GroupDetailPage`, `RideSessionPage`, ...), where a back arrow is
/// still the right affordance for a genuine drill-down.
///
/// A `Scaffold` with a non-null `drawer` always gets a drawer button as
/// its `AppBar`'s leading widget instead of a back button, regardless of
/// whether the route could pop — see `AppBar`'s own `_AppBarState.build`
/// in the framework, which checks `hasDrawer` before `canPop`. That's the
/// entire mechanism here: each hub page just needs a non-null `drawer`,
/// nothing else about it changes.
///
/// Only wired in when `AdaptiveShell`'s own `NavigationRail` isn't already
/// showing (`showsHubRail`) — a narrow/mobile layout gets one persistent-
/// navigation affordance, never both at once. This is also, incidentally,
/// the only way to sign out (or reach Profile) from anywhere other than
/// `HomePage` today — those four other hub pages had no such path before.
///
/// Lives in `app/`, not `shared/widgets/`, because it needs `AppRoutes`
/// and `authControllerProvider` — `shared/` deliberately stays free of
/// both `app/` and feature imports (see `docs/architecture.md`). The five
/// hub *pages* importing this one `app/` file is the one deliberate
/// exception to "app/ depends on features/, never the other way around".
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final user = ref.watch(authStateChangesProvider).value;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sentinel',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (user?.email != null)
                    Text(
                      user!.email,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            for (final d in hubDestinations)
              ListTile(
                leading: Icon(location == d.path ? d.selectedIcon : d.icon),
                title: Text(d.label),
                selected: location == d.path,
                onTap: () {
                  Navigator.of(context).pop();
                  if (location != d.path) context.go(d.path);
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.profile);
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                // The drawer closes (and this widget unmounts) right
                // after this tap, well before signOut()'s await
                // resolves — nothing here could keep authControllerProvider
                // alive or show a failure even if it tried. Relies
                // entirely on that provider being `keepAlive` (see its
                // own doc comment) to even complete without throwing.
                Navigator.of(context).pop();
                ref.read(authControllerProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
