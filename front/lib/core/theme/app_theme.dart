import 'package:flutter/material.dart';

import 'app_spacing.dart';

/// Sentinel's design system — Modo Oscuro Táctico.
///
/// Reemplaza el `ColorScheme.fromSeed` anterior (dos semillas de color,
/// superficies "ablandadas" con un delta de lightness) por una paleta
/// **fija**, pensada como panel de instrumentos: fondo carbón profundo,
/// paneles apenas un tono más claros, separación por borde técnico de 1px
/// en vez de sombra, y un único acento saturado (naranja de seguridad)
/// reservado estrictamente para lo que está activo o es una acción
/// primaria — todo lo demás se queda deliberadamente sobrio para que ese
/// acento (y el rojo aislado de S.O.S.) sigan leyéndose como lo único
/// urgente en pantalla.
///
/// La app es oscura siempre — no hay variante clara — porque el objetivo
/// es legibilidad técnica a la intemperie (sol directo, casco, guantes),
/// no preferencia estética; ver `app.dart` (`themeMode: ThemeMode.dark`).
abstract final class AppTheme {
  // === Paleta fija — cada valor es el hex exacto de la especificación ===

  /// Fondo principal de la app.
  static const carbon = Color(0xFF121418);

  /// Tarjetas y contenedores secundarios — un tono por encima de [carbon]
  /// para separar datos sin recurrir a sombra.
  static const panel = Color(0xFF1A1D24);

  /// Borde técnico de 1px que reemplaza sombras/bordes gruesos en toda
  /// tarjeta, input y separador.
  static const border = Color(0xFF2C323D);

  /// Texto secundario — blanco suave, alto contraste sobre [carbon]/[panel]
  /// pensado para lectura en exteriores.
  static const textSecondary = Color(0xFFE2E8F0);

  /// Texto terciario/deshabilitado — una utilidad más allá de la
  /// especificación (que solo nombra un tono de texto secundario), para
  /// etiquetas de menor jerarquía sin caer a opacidad sobre blanco.
  static const textMuted = Color(0xFF8B93A5);

  /// Naranja de seguridad — el único acento saturado del tablero.
  /// Estrictamente para: estados activos, CTAs primarias, indicador de
  /// ruta en curso. Nunca decorativo.
  static const accent = Color(0xFFFF5722);

  /// Rojo de alta visibilidad, exclusivo del componente S.O.S. aislado —
  /// no se usa en ningún otro lugar del tablero para que mantenga su
  /// significado de "esto es la emergencia".
  static const sos = Color(0xFFD32F2F);

  /// Fuente monoespaciada para telemetría — velocidad, coordenadas de
  /// ruta, códigos de invitación, marcas de tiempo. `'monospace'` es una
  /// familia genérica que Flutter resuelve al monoespaciado real de cada
  /// plataforma (Roboto Mono/Droid Sans Mono en Android, Menlo/Courier en
  /// iOS/macOS, la pila monospace del navegador en Web) sin necesitar
  /// empaquetar una fuente propia.
  static TextStyle telemetryStyle({
    required Color color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w700,
  }) => TextStyle(
    fontFamily: 'monospace',
    fontFeatures: const [FontFeature.tabularFigures()],
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: 0.2,
  );

  static ThemeData get dark => _buildTheme();

  /// Mantenido solo porque `MaterialApp.router` exige un `theme` además de
  /// `darkTheme` — con `themeMode: ThemeMode.dark` (`app.dart`) nunca se
  /// usa en la práctica. Apunta al mismo tema táctico: no existe una
  /// variante clara de este sistema.
  static ThemeData get light => _buildTheme();

  static ThemeData _buildTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: accent,
      onPrimary: carbon,
      primaryContainer: Color(0xFF4A2415),
      onPrimaryContainer: Color(0xFFFFCCBC),
      secondary: Color(0xFF3A4150),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF232833),
      onSecondaryContainer: textSecondary,
      tertiary: accent,
      onTertiary: carbon,
      tertiaryContainer: Color(0xFF4A2415),
      onTertiaryContainer: Color(0xFFFFCCBC),
      error: sos,
      onError: Colors.white,
      errorContainer: Color(0xFF4A1515),
      onErrorContainer: Color(0xFFFFCDD2),
      surface: carbon,
      onSurface: Colors.white,
      onSurfaceVariant: textSecondary,
      surfaceContainerLowest: carbon,
      surfaceContainerLow: Color(0xFF16181E),
      surfaceContainer: panel,
      surfaceContainerHigh: Color(0xFF20242C),
      surfaceContainerHighest: Color(0xFF262B34),
      surfaceDim: carbon,
      surfaceBright: Color(0xFF2C323D),
      outline: border,
      outlineVariant: Color(0xFF20242C),
      inverseSurface: textSecondary,
      onInverseSurface: carbon,
      inversePrimary: accent,
      scrim: Colors.black,
      shadow: Colors.black,
    );

    // Escala de datos estándar de interfaz: 14px texto secundario, 16px
    // texto base, 20-24px como máximo para títulos de sección críticos —
    // ninguna talla por encima de eso, ni siquiera en headline.
    const textTheme = TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: textSecondary),
      bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
      bodySmall: TextStyle(fontSize: 12, color: textMuted),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textMuted,
      ),
    );

    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      side: const BorderSide(color: border),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: sos, width: 1.5),
        ),
        filled: true,
        fillColor: panel,
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      // Botones: formato rectangular de esquinas sutiles, ancho fluido
      // (el padre decide el ancho — `Size.fromHeight` solo fija un alto
      // ergonómico estándar), naranja estrictamente en la variante
      // primaria (Elevated/Filled) — nunca en Outlined/Text.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: border,
          disabledForegroundColor: textMuted,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: textTheme.labelLarge,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          side: const BorderSide(color: border),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge,
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
        ),
      ),
      // Tarjetas: fondo `panel`, borde técnico de 1px, radio 8px, cero
      // elevación/sombra — la separación de datos la hace el borde, no la
      // sombra.
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: cardShape,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        textColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        space: AppSpacing.xl,
        thickness: 1,
      ),
      // Chips/StatusChip: etiqueta técnica rectangular, no píldora — ver
      // `StatusChip`.
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        side: const BorderSide(color: border),
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colorScheme.primary
              : textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(border),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        extendedTextStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: const BorderSide(color: border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.16),
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : textMuted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.16),
        selectedIconTheme: const IconThemeData(color: accent),
        unselectedIconTheme: const IconThemeData(color: textMuted),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: accent,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: textMuted,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        indicatorColor: colorScheme.primary,
        labelColor: colorScheme.primary,
        unselectedLabelColor: textMuted,
        labelStyle: textTheme.titleSmall,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: border),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.md),
          ),
          side: BorderSide(color: border),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: const BorderSide(color: border),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: const BorderSide(color: border),
        ),
      ),
    );
  }
}
