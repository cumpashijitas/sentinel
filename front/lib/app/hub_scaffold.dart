import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_spacing.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import 'router.dart';

/// Common chrome for the five hub pages (Home/Groups/Vehicles/Emergency
/// contacts/History) — a flat panel header (Modo Oscuro Táctico: sin
/// degradado, separado del contenido por un borde técnico de 1px) con
/// título/subtítulo, más el menú de perfil/cerrar sesión. La navegación
/// principal entre hubs vive en la barra/rail de [AppShell].
class HubScaffold extends ConsumerWidget {
  const HubScaffold({
    required this.title,
    required this.body,
    this.icon,
    this.subtitle,
    this.actions,
    this.floatingActionButton,
    this.bottom,
    super.key,
  });

  final String title;
  final Widget body;
  final IconData? icon;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              topInset + AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.lg,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.panel,
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: AppTheme.accent.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Icon(icon, color: AppTheme.accent, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleLarge),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                ...?actions,
                const AccountMenuButton(),
              ],
            ),
          ),
          ?bottom,
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

enum _ProfileAction { profile, signOut }

/// The profile/sign-out avatar menu — public (not `HubScaffold`-private)
/// so a page with its own bespoke header (see `HomePage`) can still reuse
/// it instead of hand-rolling a second copy. [avatarColor]/[onAvatarColor]
/// exist for a caller that ever needs a one-off override; every header in
/// the app today is the same flat tactical panel, so the default
/// (`colorScheme.primaryContainer`/`onPrimaryContainer` — a dim orange
/// tint) already reads correctly everywhere without passing either.
class AccountMenuButton extends ConsumerWidget {
  const AccountMenuButton({this.avatarColor, this.onAvatarColor, super.key});

  final Color? avatarColor;
  final Color? onAvatarColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final source = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : (user?.email ?? '?');
    final initial = source.isEmpty ? '?' : source[0].toUpperCase();
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: PopupMenuButton<_ProfileAction>(
        tooltip: 'Cuenta',
        offset: const Offset(0, 48),
        onSelected: (action) => switch (action) {
          _ProfileAction.profile => context.push(AppRoutes.profile),
          _ProfileAction.signOut => ref
              .read(authControllerProvider.notifier)
              .signOut(),
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: _ProfileAction.profile,
            child: ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Perfil'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: _ProfileAction.signOut,
            child: ListTile(
              leading: Icon(Icons.logout),
              title: Text('Cerrar sesión'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
        child: CircleAvatar(
          radius: 18,
          backgroundColor: avatarColor ?? colorScheme.primaryContainer,
          child: Text(
            initial,
            style: TextStyle(
              color: onAvatarColor ?? colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
