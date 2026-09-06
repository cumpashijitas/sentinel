import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/theme/app_theme.dart';

double _lightnessOf(Color color) => HSLColor.fromColor(color).lightness;
double _hueOf(Color color) => HSLColor.fromColor(color).hue;

void main() {
  group('AppTheme', () {
    test('light theme is Brightness.light, dark theme is Brightness.dark', () {
      expect(AppTheme.light.brightness, Brightness.light);
      expect(AppTheme.dark.brightness, Brightness.dark);
    });

    test(
      'light surface is softened below Material 3\'s near-white default',
      () {
        final lightness = _lightnessOf(AppTheme.light.colorScheme.surface);
        // Plain ColorScheme.fromSeed puts this at ~0.99; still clearly a
        // light theme, just not paper-white.
        expect(lightness, lessThan(0.95));
        expect(lightness, greaterThan(0.80));
      },
    );

    test('dark surface is softened above Material 3\'s near-black default', () {
      final lightness = _lightnessOf(AppTheme.dark.colorScheme.surface);
      // Plain ColorScheme.fromSeed puts this at ~0.08; still clearly a
      // dark theme, just not near-black.
      expect(lightness, greaterThan(0.12));
      expect(lightness, lessThan(0.30));
    });

    test('the surface tonal hierarchy stays ordered after softening', () {
      final light = AppTheme.light.colorScheme;
      expect(
        _lightnessOf(light.surfaceContainerLowest),
        greaterThan(_lightnessOf(light.surfaceContainerLow)),
      );
      expect(
        _lightnessOf(light.surfaceContainerLow),
        greaterThan(_lightnessOf(light.surfaceContainer)),
      );
      expect(
        _lightnessOf(light.surfaceContainer),
        greaterThan(_lightnessOf(light.surfaceContainerHigh)),
      );
      expect(
        _lightnessOf(light.surfaceContainerHigh),
        greaterThan(_lightnessOf(light.surfaceContainerHighest)),
      );

      final dark = AppTheme.dark.colorScheme;
      expect(
        _lightnessOf(dark.surfaceContainerLowest),
        lessThan(_lightnessOf(dark.surfaceContainerLow)),
      );
      expect(
        _lightnessOf(dark.surfaceContainerLow),
        lessThan(_lightnessOf(dark.surfaceContainer)),
      );
      expect(
        _lightnessOf(dark.surfaceContainer),
        lessThan(_lightnessOf(dark.surfaceContainerHigh)),
      );
      expect(
        _lightnessOf(dark.surfaceContainerHigh),
        lessThan(_lightnessOf(dark.surfaceContainerHighest)),
      );
    });

    test('the primary color stays blue in both themes (seed untouched)', () {
      // Surface softening must never touch primary/secondary/tertiary —
      // only `ColorScheme.fromSeed`'s own hue for the 0x1B6FD1 seed
      // decides this, unrelated to the softening delta.
      for (final hue in [
        _hueOf(AppTheme.light.colorScheme.primary),
        _hueOf(AppTheme.dark.colorScheme.primary),
      ]) {
        expect(hue, inInclusiveRange(200, 250));
      }
    });
  });
}
