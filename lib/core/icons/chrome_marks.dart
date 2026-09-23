import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The design's `LockMark`: one lock for every piece of chrome, drawn in a
/// 13×15 box at stroke 1.4, so a stroke weight can never drift between
/// screens. Not the catalogue's 20-box lock, which `AppIcon.lock` carries.
class LockMark extends StatelessWidget {
  /// Creates a [LockMark].
  const LockMark({
    this.size = _designSize,
    this.color,
    this.semanticLabel,
    super.key,
  });

  /// The design's `size = 14` default; the Path passes 13.
  static const double _designSize = 14;

  /// The box's own proportions: `height={size * 15 / 13}`.
  static const double _aspect = 15 / 13;

  /// The mark's width. Its height follows the design's own ratio.
  final double size;

  /// The ink, or the mood's muted ink — the design's `var(--ink-mute)`.
  final Color? color;

  /// Read out in place of the drawing, or nothing when a label beside it
  /// already says what it is.
  final String? semanticLabel;

  /// The markup as `flavor-wheel.jsx` draws it, colour left to `currentColor`.
  static const String _markup = '''
<svg viewBox="0 0 13 15" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="1" y="6" width="11" height="8" rx="1.5" fill="none" stroke="currentColor" stroke-width="1.4"/>
  <path d="M3.5 6V4a3 3 0 0 1 6 0v2" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/>
</svg>''';

  @override
  Widget build(BuildContext context) => SvgPicture.string(
    _markup,
    width: size,
    height: size * _aspect,
    theme: SvgTheme(currentColor: color ?? context.mood.inkMute),
    semanticsLabel: semanticLabel,
    excludeFromSemantics: semanticLabel == null,
  );
}

/// The design's `BrewCup`: the Coffee Challenge's own cup, with its steam,
/// drawn in a 24 box at stroke 1.6. Distinct from the Today tab's cup.
class BrewCupMark extends StatelessWidget {
  /// Creates a [BrewCupMark].
  const BrewCupMark({required this.size, required this.color, super.key});

  /// The box's side.
  final double size;

  /// The ink for cup and steam alike.
  final Color color;

  /// The markup as `brew-challenge.jsx` draws it: the steam at
  /// `stroke * 0.72` and `opacity 0.85`, the cup at the family's 1.6.
  static const String _markup = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g stroke="currentColor" stroke-width="1.152" stroke-linecap="round" opacity="0.85">
    <path d="M9 5.2 Q7.6 3.6 9 2"/>
    <path d="M13.4 5.2 Q12 3.6 13.4 2"/>
  </g>
  <path d="M4.6 8.4 H17.2 l-0.9 8.1 A2.4 2.4 0 0 1 13.9 18.6 H7.9 A2.4 2.4 0 0 1 5.5 16.5 Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/>
  <path d="M17.2 9.6 a2.9 2.9 0 0 1 0 5.4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
</svg>''';

  @override
  Widget build(BuildContext context) => SvgPicture.string(
    _markup,
    width: size,
    height: size,
    theme: SvgTheme(currentColor: color),
    excludeFromSemantics: true,
  );
}

/// The design's open book on the Dictionary entry: drawn once, in the
/// header's own `DictHeaderButton`, at 22 and stroke 1.6 in the accent.
class OpenBookMark extends StatelessWidget {
  /// Creates an [OpenBookMark].
  const OpenBookMark({required this.color, this.size = _designSize, super.key});

  /// `<svg width="22" height="22">`.
  static const double _designSize = 22;

  /// The box's side.
  final double size;

  /// The ink — the design's `var(--accent)`.
  final Color color;

  static const String _markup = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 6.6C10.4 5.4 8.3 5.1 6.2 5.3A1 1 0 0 0 5 6.3v10.2a1 1 0 0 0 1.1 1c1.9-.2 3.9.1 5.4 1.2M12 6.6c1.6-1.2 3.7-1.5 5.8-1.3a1 1 0 0 1 1.1 1v10.2a1 1 0 0 1-1.1 1c-1.9-.2-3.9.1-5.4 1.2M12 6.6V19" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

  @override
  Widget build(BuildContext context) => SvgPicture.string(
    _markup,
    width: size,
    height: size,
    theme: SvgTheme(currentColor: color),
    excludeFromSemantics: true,
  );
}

/// The design's bookmark on the Saved entry: `SavedHeaderButton`'s own, at
/// 20 and stroke 1.6 in the accent — not the catalogue's 1.5 mark.
class SavedBookmarkMark extends StatelessWidget {
  /// Creates a [SavedBookmarkMark].
  const SavedBookmarkMark({
    required this.color,
    this.size = _designSize,
    super.key,
  });

  /// `<svg width="20" height="20">`.
  static const double _designSize = 20;

  /// The box's side.
  final double size;

  /// The ink — the design's `var(--accent)`.
  final Color color;

  static const String _markup = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M7 4.8A1 1 0 0 1 8 3.8h8a1 1 0 0 1 1 1V20l-5-3.6L7 20V4.8Z" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

  @override
  Widget build(BuildContext context) => SvgPicture.string(
    _markup,
    width: size,
    height: size,
    theme: SvgTheme(currentColor: color),
    excludeFromSemantics: true,
  );
}
