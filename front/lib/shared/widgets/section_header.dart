import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// Encabezado de panel — reemplaza el antiguo `GradientHeader` (una banda
/// con degradado de dos colores) en cada pantalla de detalle empujada
/// (grupo, viaje, accidente, perfil, compartir ubicación).
///
/// Modo Oscuro Táctico: el punto ya no es un color vistoso arriba de la
/// pantalla — es un panel plano (`AppTheme.panel`) separado del contenido
/// por un borde técnico de 1px, exactamente como cualquier otra tarjeta
/// del tablero. El acento naranja se reserva para el icono, no para todo
/// el fondo — así el color urgente sigue siendo urgente.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.subtitle,
    this.icon,
    this.accentColor = AppTheme.accent,
    this.trailing,
    this.showBackButton = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  /// Color del recuadro del icono — naranja por defecto (acción/estado
  /// normal). Las pantallas de accidente/emergencia pasan `AppTheme.sos`
  /// para que el icono del panel avise lo mismo que el resto de esa
  /// pantalla, sin que el panel entero se vuelva rojo.
  final Color accentColor;
  final Widget? trailing;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.sm,
        topInset + AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.panel,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
            )
          else
            const SizedBox(width: AppSpacing.md),
          if (icon != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: accentColor.withValues(alpha: 0.5)),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
