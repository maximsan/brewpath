import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The one row the whole settings surface renders through.
///
/// The design is explicit that this is a single component, not a shape each
/// screen redraws: *"Settings, About, Account and sync, Help and support and
/// Purchases all render through this"* (`prototype/settings.jsx:149`). Six
/// trailing variants, one implementation, so the row cannot drift into two
/// versions again.
///
/// **It has no icon slot, deliberately.** The app's settings rows had grown
/// leading Material glyphs — `notifications_outlined`, `palette_outlined`,
/// `vibration`, `volume_up_outlined`, `tune`, `info_outline` — that the design
/// never draws, which is why the icon port (#378) left them alone rather than
/// hunting for marks that do not exist. The fix was removal, and removal is
/// this shape.
///
/// Layout is label left, affordance right, over a hairline: the rule is the
/// row's own bottom border in the design, so a list of these needs no
/// separators of its own.
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
    super.key,
  }) : assert(
         toggleValue == null || onToggle != null,
         'a switch nobody listens to is a control that lies',
       );

  /// The platform's minimum tap target, which is also the design's `minHeight`.
  static const double minHeight = 44;

  /// Vertical padding either side of the label (`settings.jsx:163`).
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
  /// **Visual only. It still acts**, which is the design's own behaviour:
  /// `dim` sets opacity and nothing else, and only `pending` withholds the
  /// press (`prototype/settings.jsx:151`). That matters here — tapping the
  /// dimmed reminder row is the way a learner turns the reminder *on*, because
  /// choosing a time is asking for it.
  final bool isDimmed;

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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.gutter,
        vertical: _verticalPadding,
      ),
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

    return Semantics(
      // The switch inside a toggle row is already a control, and controls do
      // not nest: only a navigating row announces itself as a button.
      button: action != null && !_isToggle,
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
        IconMark(
          AppIcon.chevron,
          color: isDestructive ? mood.berry : mood.inkMute,
        ),
      ],
    ];
  }
}
