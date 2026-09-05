import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_drawer.dart';
import '../../../../app/hub_navigation.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Landing screen after login: entry points to groups, vehicles, emergency
/// contacts and the ride/accident history (Fase 9). Ride sessions and the
/// live map are reached from inside a group, not from here — see
/// `GroupDetailPage`. On narrow layouts, [AppDrawer] on this page's own
/// `Scaffold` also gives access to every other hub page (see that class's
/// doc comment).
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

    final user = ref.watch(authStateChangesProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentinel'),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      drawer: showsHubRail(context) ? null : const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hola${user?.displayName != null ? ', ${user!.displayName}' : ''} 👋',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.groups_outlined),
                  title: const Text('Grupos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/groups'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.two_wheeler_outlined),
                  title: const Text('Vehículos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/vehicles'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.emergency_outlined),
                  title: const Text('Contactos de emergencia'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/emergency-contacts'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history_outlined),
                  title: const Text('Historial'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/history'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
