import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The full-width primary CTA — the design's `.btn-primary`: accent fill,
/// accent-ink text, [AppRadii.chrome] corners (ADR-0009).
///
/// The shape repeats `AppTheme`'s because a themeless `MaterialApp` would
/// otherwise render Material's pill; disabled takes a muted fill, since the
/// design's 35% fade is invisible on dark roast.
class PrimaryButton extends StatelessWidget {
  /// Creates a [PrimaryButton].
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.leadingMark,
    this.leadingMarkSize,
    this.trailingMark,
    this.semanticsLabel,
    super.key,
  }) : _isDestructive = false;

  /// The same CTA in berry, for a confirm that throws something away — the
  /// design's `danger` override, `background: var(--berry)` under the accent's
  /// ink. It carries no mark: a destructive confirm is words alone.
  const PrimaryButton.destructive({
    required this.label,
    required this.onPressed,
    this.semanticsLabel,
    super.key,
  }) : leadingMark = null,
       leadingMarkSize = null,
       trailingMark = null,
       _isDestructive = true;

  /// The design's fixed CTA height. Public because the sticky action bar
  /// reserves room for a button before one has been laid out, and a second
  /// copy of the number is a second thing to keep in step.
  static const double height = 52;

  /// Text shown on the button.
  final String label;

  /// Tap handler; `null` disables the button.
  final VoidCallback? onPressed;

  /// A mark after the label, for an action whose *gesture* is worth drawing —
  /// the module ending's *Turn it over* carries the flip glyph, because the
  /// button is the ceremony's beat rather than a way onward.
  ///
  /// Decoration, not a second affordance: it is inside the button and
  /// excluded from semantics, so the label remains the whole announcement.
  final AppIcon? trailingMark;

  /// A mark before the label, for an action that has to say what it costs
  /// before it says what it does — the lock on *Unlock Foundations*. Excluded
  /// from semantics like [trailingMark].
  final AppIcon? leadingMark;

  /// The leading mark's size, when the design draws it smaller than a
  /// control-step mark — the CTA's `<LockMark size={12}/>`.
  final double? leadingMarkSize;

  /// What a screen reader is told instead of [label] — the lesson the button
  /// opens, where the visible words alone would not say which.
  final String? semanticsLabel;

  /// Whether this is the berry variant.
  final bool _isDestructive;

  /// The mark's size beside a control-step label.
  static const double _markSize = 18;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final enabled = onPressed != null;
    final background = !enabled
        ? mood.surface2
        : _isDestructive
        ? mood.berry
        : mood.accent;
    final foreground = enabled ? mood.accentInk : mood.inkMute;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: mood.surface2,
          disabledForegroundColor: mood.inkMute,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadii.chrome)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingMark != null) ...[
              ExcludeSemantics(
                child: IconMark(
                  leadingMark!,
                  size: leadingMarkSize ?? _markSize,
                  color: foreground,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: Text(
                label,
                semanticsLabel: semanticsLabel,
                style: AppText.body(
                  mood: mood,
                  color: foreground,
                  face: AppFace.control,
                ),
              ),
            ),
            if (trailingMark != null) ...[
              const SizedBox(width: AppSpacing.xs),
              ExcludeSemantics(
                child: IconMark(
                  trailingMark!,
                  size: _markSize,
                  color: foreground,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
