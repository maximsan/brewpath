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
        height: _hasFocus ? widget.height : FocusRevealedButton._hairline,
        width: double.infinity,
        child: Opacity(
          opacity: _hasFocus ? 1 : 0,
          child: OutlinedButton(
            onFocusChange: (value) => setState(() => _hasFocus = value),
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
