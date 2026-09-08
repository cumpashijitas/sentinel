import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Etiqueta técnica de estado — "En curso", "Confirmado", "Notificado",
/// etc. Modo Oscuro Táctico: rectangular con radio contenido y un borde de
/// 1px del color de estado en vez de una píldora rellena — lee como una
/// etiqueta de panel de instrumentos, no como un adorno decorativo.
/// Consistente en toda la app: rides, grupos, historial de accidentes.
class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    required this.color,
    this.icon,
    super.key,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
