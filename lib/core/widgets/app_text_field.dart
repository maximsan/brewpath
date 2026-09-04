import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// The design's single-line text field: a filled well on a hairline that takes
/// the accent while focused.
///
/// Shared rather than private to one screen because the design has one of
/// these and uses it in two places — the onboarding name step and the Settings
/// name sheet (#406).
///
/// Deliberately not a Material `TextField` with an `InputDecoration`: the
/// design has no floating label, no helper row and no underline, and every one
/// of those is something `InputDecoration` draws by default and has to be
/// switched off.
class AppTextField extends StatefulWidget {
  /// Creates an [AppTextField].
  const AppTextField({
    required this.onChanged,
    this.placeholder,
    this.semanticsLabel,
    this.maxLength,
    this.autofocus = false,
    this.enabled = true,
    this.onSubmitted,
    super.key,
  });

  /// Called on every keystroke with the raw text.
  final ValueChanged<String> onChanged;

  /// The empty-field prompt.
  final String? placeholder;

  /// What a screen reader calls the field. Falls back to [placeholder], which
  /// is what the design labels it with.
  final String? semanticsLabel;

  /// Hard cap on typed characters, or null for none.
  final int? maxLength;

  /// Whether to take focus on mount.
  final bool autofocus;

  /// Whether the field accepts input.
  final bool enabled;

  /// Called when the learner submits from the keyboard.
  final VoidCallback? onSubmitted;

  /// The design's `border-radius: 12` — its own value, sitting inside the
  /// slack `AppRadii.chrome` documents rather than taking that stop.
  static const double _radius = 12;

  /// The design's `padding: 13px 16px`. The horizontal half is a spacing stop;
  /// the vertical is not, so it comes from the register with its reason.
  static final double _verticalPadding =
      OffTokens.textFieldVerticalPadding.value;

  /// The design's `transition: border-color 140ms ease`.
  static const Duration _focusFade = Duration(milliseconds: 140);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()..addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final border = _focus.hasFocus ? mood.accent : mood.rule;

    final decoration = BoxDecoration(
      color: mood.surface,
      border: Border.all(color: border),
      borderRadius: BorderRadius.circular(AppTextField._radius),
    );

    final field = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppTextField._verticalPadding,
      ),
      child: TextField(
        focusNode: _focus,
        autofocus: widget.autofocus,
        enabled: widget.enabled,
        maxLength: widget.maxLength,
        // Not in the design, which is a web `<input>` and has no say in a
        // phone keyboard. A first-name field that opens lower-case makes the
        // learner reach for shift on the one word the app will greet them by.
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        style: AppText.body(mood: mood),
        // Everything Material would draw around the text is off: the design
        // draws the well itself, and the counter a `maxLength` normally adds
        // is a second line under a field that has no second line.
        //
        // The placeholder goes in as a `hint` **widget** rather than
        // `hintText` so its semantics can be excluded. Left in, the hint
        // contributes its own label to the field node beside the one below,
        // and a reader reads the name twice.
        decoration: const InputDecoration.collapsed(hintText: null).copyWith(
          counterText: '',
          hint: widget.placeholder == null
              ? null
              : ExcludeSemantics(
                  child: Text(
                    widget.placeholder!,
                    style: AppText.body(mood: mood, color: mood.inkMute),
                  ),
                ),
        ),
        onChanged: widget.onChanged,
        onSubmitted: (_) => widget.onSubmitted?.call(),
      ),
    );

    // `MergeSemantics`, not a bare `Semantics` wrapper: a `TextField` is its
    // own semantics boundary, so wrapping one adds a *second* `isTextField`
    // node carrying the same label — a reader then announces the field twice
    // and lands on a node it cannot type into. Merged, the name and the
    // editable node are one node, which is what they are.
    return MergeSemantics(
      child: Semantics(
        label: widget.semanticsLabel ?? widget.placeholder,
        child: MediaQuery.disableAnimationsOf(context)
            ? DecoratedBox(decoration: decoration, child: field)
            : AnimatedContainer(
                duration: AppTextField._focusFade,
                decoration: decoration,
                child: field,
              ),
      ),
    );
  }
}
