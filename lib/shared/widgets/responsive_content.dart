import 'package:flutter/material.dart';

/// Centers [child] and caps its width once the viewport is wide enough —
/// Fase 10. A full-bleed `ListView` reads fine on a phone but turns into
/// an awkward wall of edge-to-edge rows on a desktop-width browser window;
/// this is the minimal fix; a real multi-column dashboard layout is a
/// larger, separate decision, not bundled in here speculatively.
///
/// Below [maxWidth] this is a no-op passthrough — same widget tree shape
/// as before Fase 10, so it never affects a phone-sized layout (Android or
/// a narrow browser window).
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    required this.child,
    this.maxWidth = 900,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width <= maxWidth) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
