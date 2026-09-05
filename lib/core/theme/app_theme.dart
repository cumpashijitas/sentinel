import 'package:flutter/material.dart';

/// Sentinel's Material 3 theme.
///
/// A single seed color drives both light and dark color schemes so the app
/// stays visually consistent without hand-tuning every color.
abstract final class AppTheme {
  static const _seedColor = Color(0xFF1B6FD1);

  /// How far every `surface*` tone gets pulled away from
  /// `ColorScheme.fromSeed`'s default extreme — light mode's surface
  /// starts at HSL lightness ≈0.99 (near-white), dark mode's at ≈0.08
  /// (near-black). Users found both too harsh; this softens both by the
  /// same magnitude (light gets darker, dark gets lighter — see
  /// [_buildTheme]) without touching `primary`/`secondary`/`tertiary`/
  /// `error` or their `on*` counterparts at all, so the seed blue is
  /// exactly what `ColorScheme.fromSeed` would have produced on its own.
  /// Tune this one number if the balance ever needs to shift again.
  static const _surfaceSoftening = 0.09;

  static ThemeData get light => _buildTheme(Brightness.light);

  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final seeded = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );
    final colorScheme = _softenSurfaces(
      seeded,
      brightness == Brightness.light ? -_surfaceSoftening : _surfaceSoftening,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// `ColorScheme.fromSeed` spaces its eight `surface*` tones at fixed
  /// steps of one tonal palette — shifting all of them by the same
  /// [lightnessDelta] softens the whole range uniformly (preserves which
  /// one is lightest/darkest and by roughly how much) instead of
  /// flattening it or inverting the order a per-token hand-pick could
  /// risk.
  static ColorScheme _softenSurfaces(
    ColorScheme scheme,
    double lightnessDelta,
  ) {
    Color shift(Color color) {
      final hsl = HSLColor.fromColor(color);
      return hsl
          .withLightness((hsl.lightness + lightnessDelta).clamp(0.0, 1.0))
          .toColor();
    }

    return scheme.copyWith(
      surfaceDim: shift(scheme.surfaceDim),
      surface: shift(scheme.surface),
      surfaceBright: shift(scheme.surfaceBright),
      surfaceContainerLowest: shift(scheme.surfaceContainerLowest),
      surfaceContainerLow: shift(scheme.surfaceContainerLow),
      surfaceContainer: shift(scheme.surfaceContainer),
      surfaceContainerHigh: shift(scheme.surfaceContainerHigh),
      surfaceContainerHighest: shift(scheme.surfaceContainerHighest),
    );
  }
}
