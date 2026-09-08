import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// One row of a vertical timeline — a dot on a connecting line, then
/// content to its right. Used by [HistoryPage]'s Viajes/Accidentes tabs
/// instead of a plain stack of `Card`s, so "this is a sequence of things
/// that happened over time" reads from the shape of the list, not just
/// its content.
class TimelineTile extends StatelessWidget {
  const TimelineTile({
    required this.isFirst,
    required this.isLast,
    required this.color,
    required this.icon,
    required this.child,
    this.onTap,
    super.key,
  });

  final bool isFirst;
  final bool isLast;
  final Color color;
  final IconData icon;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(context).colorScheme.outlineVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              SizedBox(
                height: 6,
                child: isFirst ? null : VerticalDivider(width: 2, color: lineColor, thickness: 2),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Expanded(
                child: isLast
                    ? const SizedBox.shrink()
                    : VerticalDivider(width: 2, color: lineColor, thickness: 2),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
