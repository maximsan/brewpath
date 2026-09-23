import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/icons/outward_mark.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The one row the whole settings surface renders through.
///
/// Seven trailing variants, one implementation: *"Settings, About, Account and
/// sync, Help and support and Purchases all render through this"*. It has no
/// icon slot — the design draws no leading glyph (#378) — and its own bottom
/// hairline is the rule, so a list of these needs no separators.
class SettingsNavRow extends StatelessWidget {
  /// Creates a settings row.
  const SettingsNavRow({
    required this.label,
    this.sub,
    this.value,
    this.onTap,
    this.toggleValue,
    this.onToggle,
    this.isDestructive = false,
    this.isDimmed = false,
    this.isExternal = false,
    super.key,
  }) : assert(
         toggleValue == null || onToggle != null,
         'a switch nobody listens to is a control that lies',
       );

  /// The platform's minimum tap target, which is also the design's `minHeight`.
  static const double minHeight = 44;

  /// Vertical padding either side of the label.
  static const double _verticalPadding = AppSpacing.md;

  /// How far the value sits from the affordance beside it.
  static const double _trailingGap = AppSpacing.xs;

  /// Opacity of a row that is present but inactive.
  static const double _dimmedOpacity = 0.55;

  /// What the row is called.
  final String label;

  /// A second line under the label, where one word is not enough.
  final String? sub;

  /// The current setting, shown before the affordance. Mono, because these are
  /// values read at a glance — a time, a tier, an address.
  final String? value;

  /// Where the row goes. Null for a row that only reports.
  final VoidCallback? onTap;

  /// The switch's state, for a row that carries one.
  final bool? toggleValue;

  /// Fired with the value the learner asked for.
  final ValueChanged<bool>? onToggle;

  /// Whether this row destroys something — drawn in `berry`, the only red.
  final bool isDestructive;

  /// Whether this row reads as inactive — a reminder time with notifications
  /// switched off.
  ///
  /// **Visual only. It still acts:** tapping the dimmed reminder row is how a
  /// learner turns the reminder on, because choosing a time is asking for it.
  final bool isDimmed;

  /// Whether the press leaves the app — a browser, a mail composer, the store.
  ///
  /// The design draws these with its outward arrow rather than the chevron, so
  /// a row that hands the learner to another app says so before it is pressed.
  final bool isExternal;

  bool get _isToggle => toggleValue != null;

  /// What a press does, or null when the row only reports.
  ///
  /// A toggle row's press flips the switch: the design gives the *whole row*
  /// the 44px target, because reaching for a switch at the screen's edge is
  /// how a setting gets missed.
  VoidCallback? get _action =>
      _isToggle ? () => onToggle!(!toggleValue!) : onTap;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final ink = isDestructive ? mood.berry : mood.ink;
    final action = _action;

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
      child: Row(
        children: [
          Expanded(
            child: _labelBlock(mood: mood, ink: ink),
          ),
          const SizedBox(width: _trailingGap),
          ..._trailing(mood),
        ],
      ),
    );

    final acts = action != null && !_isToggle;

    return Semantics(
      // The switch inside a toggle row is already a control, and controls do
      // not nest: only a navigating row announces itself. A row that leaves
      // the app is a link, which is what the outward arrow beside it says.
      button: acts && !isExternal,
      link: acts && isExternal,
      // The gutter sits outside the rule, because the design's row lives
      // inside the page's `px-24` column: the hairline stops where the label
      // starts rather than running the width of the screen.
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: mood.rule)),
          ),
          child: Opacity(
            opacity: isDimmed ? _dimmedOpacity : 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: minHeight),
              child: action == null ? row : InkWell(onTap: action, child: row),
            ),
          ),
        ),
      ),
    );
  }

  Widget _labelBlock({required MoodColors mood, required Color ink}) {
    final title = Text(
      label,
      style: AppText.body(mood: mood, color: ink),
    );
    if (sub == null) return title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        const SizedBox(height: AppSpacing.xxs),
        Text(
          sub!,
          style: AppText.label(mood: mood, color: mood.inkMute),
        ),
      ],
    );
  }

  List<Widget> _trailing(MoodColors mood) {
    // Whichever mark the row ends on takes the row's own ink, so a
    // destructive row cannot end in a muted affordance.
    final affordanceInk = isDestructive ? mood.berry : mood.inkMute;

    if (_isToggle) {
      return [
        Switch(value: toggleValue!, onChanged: onToggle),
      ];
    }

    return [
      if (value case final shown?)
        Text(
          shown,
          style: AppText.support(
            mood: mood,
            color: mood.inkMute,
            face: AppFace.mono,
          ),
        ),
      if (onTap != null) ...[
        const SizedBox(width: _trailingGap),
        if (isExternal)
          OutwardMark(color: affordanceInk)
        else
          IconMark(AppIcon.chevron, color: affordanceInk),
      ],
    ];
  }
}
