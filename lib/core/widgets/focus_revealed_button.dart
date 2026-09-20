import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// A control that is a hairline until it takes focus.
///
/// What a swipe's keyboard and assistive-technology equivalent looks like: the
/// surface keeps no standing control while staying operable without a pointer.
/// Never `Offstage` and never excluded from semantics — that is the whole
/// point of it.
class FocusRevealedButton extends StatefulWidget {
  /// Creates a [FocusRevealedButton].
  const FocusRevealedButton({
    required this.label,
    required this.onPressed,
    required this.ring,
    this.height = _defaultHeight,
    this.onFocusChange,
    super.key,
  });

  /// The design's `height: kbd ? 40 : 1` — the deck's pair stands at 44.
  static const double _defaultHeight = 40;
  static const double _hairline = 1;

  /// What the control says, and what it is announced as.
  final String label;

  /// Called when it is pressed.
  final VoidCallback onPressed;

  /// The ring it wears once focused, in the caller's own design value.
  final Color ring;

  /// How tall it stands when focused.
  final double height;

  /// Told when it reveals or collapses, for a row that gives it room only
  /// while it is standing — the design's `flex: kbd ? 1 : '0 0 1px'`.
  final ValueChanged<bool>? onFocusChange;

  @override
  State<FocusRevealedButton> createState() => _FocusRevealedButtonState();
}

class _FocusRevealedButtonState extends State<FocusRevealedButton> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Padding(
      padding: EdgeInsets.only(top: _hasFocus ? AppSpacing.xs : 0),
      child: SizedBox(
        // The design's `width: kbd ? '100%' : 1, height: kbd ? 40 : 1`: it
        // collapses to a point rather than to a full-width invisible strip,
        // which a finger could still land on.
        height: _hasFocus ? widget.height : FocusRevealedButton._hairline,
        width: _hasFocus ? double.infinity : FocusRevealedButton._hairline,
        child: Opacity(
          opacity: _hasFocus ? 1 : 0,
          // Without this a fully transparent subtree is dropped from the
          // semantics tree — and a control nothing announces is not a
          // keyboard equivalent, it is a control that does not exist.
          alwaysIncludeSemantics: true,
          child: OutlinedButton(
            onFocusChange: (value) {
              setState(() => _hasFocus = value);
              widget.onFocusChange?.call(value);
            },
            onPressed: widget.onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: mood.accentText,
              padding: EdgeInsets.zero,
              side: BorderSide(color: widget.ring),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
            child: Text(
              widget.label,
              style: AppText.support(color: mood.accentText),
            ),
          ),
        ),
      ),
    );
  }
}
