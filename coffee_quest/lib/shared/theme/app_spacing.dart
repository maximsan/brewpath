/// Vertical/horizontal spacing stops shared across onboarding screens.
/// Values match the design-bundle CSS (24-px gutter, 12/14/16/24/32 stops).
abstract class AppSpacing {
  /// 4 px — hairline gaps.
  static const double xxs = 4;

  /// 8 px — tight gaps between related elements.
  static const double xs = 8;

  /// 12 px.
  static const double sm = 12;

  /// 14 px — default text/element rhythm.
  static const double base = 14;

  /// 16 px — standard content padding.
  static const double md = 16;

  /// 24 px — section spacing.
  static const double lg = 24;

  /// 32 px — large block separation.
  static const double xl = 32;

  /// 48 px — hero / major section spacing.
  static const double xxl = 48;

  /// Horizontal screen gutter used by `.px-24` in the prototype.
  static const double gutter = 24;
}
