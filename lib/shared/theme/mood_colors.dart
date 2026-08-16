import 'package:flutter/material.dart';

/// The colour half of a **mood** — the design's word for a theme.
///
/// The design ships one token system in two moods, [cupping] (light) and
/// [darkRoast] (dark), and every token below flips between them. They are held
/// here rather than on [ColorScheme] because Material's vocabulary cannot hold
/// this palette: `--bg`, `--water` and `--water-hi` have no scheme slot at all,
/// and the ones that do fit would lose their meaning in the translation
/// (`--sage` means "learned", not "secondary"; `--warn` means celebration and
/// nothing else). `ColorScheme` is still populated in
/// `AppTheme` so stock Material widgets are not unstyled, but app code reads
/// its colours from here.
///
/// Reach an instance through `context.mood` rather than
/// `Theme.of(context).extension<MoodColors>()`.
///
/// Values are transcribed 1:1 from the design bundle CSS
/// (`prototype/index.html`).
@immutable
class MoodColors extends ThemeExtension<MoodColors> {
  /// Creates a mood's colour tokens.
  const MoodColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.ink,
    required this.inkMute,
    required this.rule,
    required this.accent,
    required this.accentInk,
    required this.sage,
    required this.warn,
    required this.berry,
    required this.water,
    required this.waterHi,
  });

  /// The light mood — a bright cupping-table paper.
  static const cupping = MoodColors(
    bg: Color(0xFFF4EFE6),
    surface: Color(0xFFFBF7EE),
    surface2: Color(0xFFEFE8DA),
    ink: Color(0xFF1B1614),
    inkMute: Color(0xFF6B5F54),
    rule: Color(0xFFD8CFBF),
    accent: Color(0xFFB8533A),
    accentInk: Color(0xFFFBF7EE),
    sage: Color(0xFF5F6E55),
    warn: Color(0xFF9A5F1C),
    berry: Color(0xFFA8362A),
    water: Color(0xFF5C93B8),
    waterHi: Color(0xFFA9CFE3),
  );

  /// The dark mood — the app's default, and the only one it shipped with.
  static const darkRoast = MoodColors(
    bg: Color(0xFF1A130E),
    surface: Color(0xFF251B14),
    surface2: Color(0xFF30231A),
    ink: Color(0xFFF3E7D2),
    inkMute: Color(0xFFB59E84),
    rule: Color(0xFF44321E),
    accent: Color(0xFFE07A4F),
    accentInk: Color(0xFF1A130E),
    sage: Color(0xFF97A285),
    warn: Color(0xFFE6A35C),
    berry: Color(0xFFC75450),
    water: Color(0xFF7FB4D6),
    waterHi: Color(0xFFC2E0EF),
  );

  /// Opacity of [veil] — the design's
  /// `color-mix(in oklab, var(--bg) 38%, transparent)`.
  static const veilOpacity = 0.38;

  /// Opacity of [veilStrong] — the same mix at 82%.
  static const veilStrongOpacity = 0.82;

  /// Page canvas.
  final Color bg;

  /// Raised surface: cards, rows, sheets.
  final Color surface;

  /// Recessed fill: icon wells, card backs.
  final Color surface2;

  /// Primary text.
  final Color ink;

  /// Secondary text and every inactive icon.
  final Color inkMute;

  /// 1px hairlines — the structural grid.
  final Color rule;

  /// The one brand colour (crema orange): actions, active tab, links,
  /// current step, needs-practice.
  final Color accent;

  /// Text placed on an [accent] fill.
  final Color accentInk;

  /// Success = "learned": correct answers, learned terms, pass mark.
  /// **Never an action** — that is [accent].
  final Color sage;

  /// **Celebration only**: streak flame, win crown, completion glow,
  /// fastest answer. Never a caution state.
  final Color warn;

  /// Alert: wrong answers, cross mark, destructive.
  final Color berry;

  /// Water fill for the brew animations.
  final Color water;

  /// Highlight on a [water] fill.
  final Color waterHi;

  /// The page background pulled over the page. Derived from [bg] rather than
  /// stored, so it follows the mood — and keeps following it mid-[lerp].
  Color get veil => bg.withValues(alpha: veilOpacity);

  /// [veil] at full strength, for content that must be obscured rather than
  /// softened.
  Color get veilStrong => bg.withValues(alpha: veilStrongOpacity);

  @override
  MoodColors copyWith({
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? ink,
    Color? inkMute,
    Color? rule,
    Color? accent,
    Color? accentInk,
    Color? sage,
    Color? warn,
    Color? berry,
    Color? water,
    Color? waterHi,
  }) {
    return MoodColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      ink: ink ?? this.ink,
      inkMute: inkMute ?? this.inkMute,
      rule: rule ?? this.rule,
      accent: accent ?? this.accent,
      accentInk: accentInk ?? this.accentInk,
      sage: sage ?? this.sage,
      warn: warn ?? this.warn,
      berry: berry ?? this.berry,
      water: water ?? this.water,
      waterHi: waterHi ?? this.waterHi,
    );
  }

  @override
  MoodColors lerp(
    covariant ThemeExtension<MoodColors>? other,
    double progress,
  ) {
    if (other is! MoodColors) return this;
    return MoodColors(
      bg: Color.lerp(bg, other.bg, progress)!,
      surface: Color.lerp(surface, other.surface, progress)!,
      surface2: Color.lerp(surface2, other.surface2, progress)!,
      ink: Color.lerp(ink, other.ink, progress)!,
      inkMute: Color.lerp(inkMute, other.inkMute, progress)!,
      rule: Color.lerp(rule, other.rule, progress)!,
      accent: Color.lerp(accent, other.accent, progress)!,
      accentInk: Color.lerp(accentInk, other.accentInk, progress)!,
      sage: Color.lerp(sage, other.sage, progress)!,
      warn: Color.lerp(warn, other.warn, progress)!,
      berry: Color.lerp(berry, other.berry, progress)!,
      water: Color.lerp(water, other.water, progress)!,
      waterHi: Color.lerp(waterHi, other.waterHi, progress)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoodColors &&
        other.bg == bg &&
        other.surface == surface &&
        other.surface2 == surface2 &&
        other.ink == ink &&
        other.inkMute == inkMute &&
        other.rule == rule &&
        other.accent == accent &&
        other.accentInk == accentInk &&
        other.sage == sage &&
        other.warn == warn &&
        other.berry == berry &&
        other.water == water &&
        other.waterHi == waterHi;
  }

  @override
  int get hashCode => Object.hash(
    bg,
    surface,
    surface2,
    ink,
    inkMute,
    rule,
    accent,
    accentInk,
    sage,
    warn,
    berry,
    water,
    waterHi,
  );
}

/// Reads the ambient mood tokens.
extension MoodColorsContext on BuildContext {
  /// The current mood's colour tokens.
  ///
  /// Falls back to [MoodColors.darkRoast] — the app's default mood — when the
  /// extension is absent, so a widget pumped under a bare `MaterialApp` (as
  /// several widget tests do) renders in the shipping palette instead of
  /// throwing.
  MoodColors get mood =>
      Theme.of(this).extension<MoodColors>() ?? MoodColors.darkRoast;
}
