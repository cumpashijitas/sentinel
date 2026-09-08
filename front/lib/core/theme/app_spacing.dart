/// Design tokens shared by every screen — spacing and corner radii. Having
/// one small vocabulary here (instead of each page picking its own `16`,
/// `12`, `20`...) is what makes a redesign pass actually read as one
/// coherent system instead of a pile of individually-nice screens.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}

/// Radio de esquina — Modo Oscuro Táctico: un radio contenido y consistente
/// (6-8px) en todos los contenedores, nunca las curvas pronunciadas de un
/// diseño "amigable". [pill] se conserva solo para el indicador de estado
/// circular de [StatusChip]-like widgets que de verdad necesitan una
/// forma redonda, no como default.
abstract final class AppRadius {
  static const sm = 6.0;
  static const md = 8.0;
  static const lg = 8.0;
  static const xl = 8.0;
  static const pill = 999.0;
}
