/// Corner radii — **two languages, not one scale**.
///
/// The design ships a single radius token (`--r: 14px`); everything else is a
/// rule. Editorial surfaces are sharp and print-like, playful chrome is soft,
/// and *"mixing them on one element is the tell of an off-system component"*.
/// They are two parallel languages, so there is no ladder to climb between
/// [editorial] and [chrome] — pick the language the element belongs to.
///
/// A radius does not flip with the mood, so this follows the same pattern as
/// `AppSpacing`, `ArtColors` and `OverlayColors`: `static const` on a class
/// that cannot be extended, implemented or instantiated, and no `of(context)`
/// accessor.
///
/// See `docs/design/03-design-system.md` — including its correction that the
/// "radius scale of 4 / 12 / 14 / 16 / 20" earlier docs listed never existed.
abstract final class AppRadii {
  /// 2 px — **editorial**. Cards, buttons, inputs, MCQ and match tiles: the
  /// sharp, print-like default.
  static const double editorial = 2;

  /// 14 px (`--r`) — **soft chrome**. Media frames, bottom sheets, icon wells,
  /// avatars, mini-game tiles.
  ///
  /// This is the token; a component that genuinely needs its own radius may sit
  /// anywhere in 12–20, which is slack around [chrome] rather than a set of
  /// stops of its own — hence no constants for the bounds.
  static const double chrome = 14;

  /// 999 px — **pill / dot**. Status dots, toggles, badges, the home indicator.
  /// Larger than any element it rounds, so the ends stay semicircular.
  static const double pill = 999;
}
