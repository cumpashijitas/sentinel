import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('is a single fixed dark theme — Modo Oscuro Táctico', () {
      expect(AppTheme.dark.brightness, Brightness.dark);
      // No existe una variante clara del sistema — `light` apunta al
      // mismo tema táctico (ver app.dart: `themeMode: ThemeMode.dark`).
      expect(AppTheme.light.brightness, Brightness.dark);
    });

    test('the scaffold background is the exact carbon spec color', () {
      expect(AppTheme.dark.scaffoldBackgroundColor, AppTheme.carbon);
      expect(AppTheme.carbon, const Color(0xFF121418));
    });

    test('cards sit on the panel color with a 1px technical border', () {
      final cardTheme = AppTheme.dark.cardTheme;
      expect(cardTheme.color, AppTheme.panel);
      expect(AppTheme.panel, const Color(0xFF1A1D24));
      expect(cardTheme.elevation, 0);

      final shape = cardTheme.shape as RoundedRectangleBorder?;
      expect(shape?.side.color, AppTheme.border);
      expect(shape?.side.width, 1);
      expect(AppTheme.border, const Color(0xFF2C323D));
    });

    test('card corners stay within the 6-8px spec range', () {
      final shape = AppTheme.dark.cardTheme.shape as RoundedRectangleBorder?;
      final radius = (shape?.borderRadius as BorderRadius?)?.topLeft.x;
      expect(radius, isNotNull);
      expect(radius, inInclusiveRange(6.0, 8.0));
    });

    test(
      'the accent color drives primary buttons and nothing but active/CTA '
      'elements',
      () {
        final colorScheme = AppTheme.dark.colorScheme;
        expect(colorScheme.primary, AppTheme.accent);
        expect(AppTheme.accent, const Color(0xFFFF5722));

        final elevatedStyle = AppTheme.dark.elevatedButtonTheme.style;
        expect(
          elevatedStyle?.backgroundColor?.resolve({}),
          AppTheme.accent,
        );
      },
    );

    test('S.O.S. red is isolated from every other role in the scheme', () {
      final colorScheme = AppTheme.dark.colorScheme;
      expect(colorScheme.error, AppTheme.sos);
      expect(AppTheme.sos, const Color(0xFFD32F2F));
      // El rojo de emergencia nunca debe coincidir con el acento naranja
      // de uso general — si algún día colisionan, el aislamiento visual
      // del panel S.O.S. deja de significar algo.
      expect(AppTheme.sos, isNot(AppTheme.accent));
    });

    test('secondary text is the exact soft-white spec color', () {
      expect(AppTheme.dark.colorScheme.onSurfaceVariant, AppTheme.textSecondary);
      expect(AppTheme.textSecondary, const Color(0xFFE2E8F0));
    });

    test('body/title text sizes stay within the spec scale (14/16/20-24)', () {
      final textTheme = AppTheme.dark.textTheme;
      expect(textTheme.bodyMedium?.fontSize, 14); // texto secundario
      expect(textTheme.bodyLarge?.fontSize, 16); // texto base
      expect(textTheme.titleLarge?.fontSize, 20); // título de sección
      expect(textTheme.headlineSmall?.fontSize, lessThanOrEqualTo(24));
    });

    test('telemetryStyle renders in a monospaced family with tabular figures', () {
      final style = AppTheme.telemetryStyle(color: Colors.white);
      expect(style.fontFamily, 'monospace');
      expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
    });
  });
}
