import 'package:brew_path/core/widgets/icon_badge.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Square tile used in the "Customize" grid. Has two flavors:
///
/// * [PreferenceTile.toggle] — backed by a [Switch], state owned by the caller.
/// * [PreferenceTile.action] — taps run [onTap]; an optional [trailingText]
///   hints at the action (e.g. "Coming soon").
class PreferenceTile extends StatelessWidget {
  /// Creates a toggle [PreferenceTile] backed by a [Switch].
  const PreferenceTile.toggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    super.key,
  }) : _value = value,
       _onChanged = onChanged,
       onTap = null,
       trailingText = null;

  /// Creates an action [PreferenceTile] that runs [onTap] when tapped.
  const PreferenceTile.action({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
    this.trailingText,
  }) : _value = null,
       _onChanged = null;

  static const double _badgeSize = 44;
  static const double _badgeRadius = 12;
  static const double _iconSize = 22;

  /// Leading icon.
  final IconData icon;

  /// Tile title.
  final String title;

  /// Supporting subtitle.
  final String subtitle;

  /// Tap handler (action flavor).
  final VoidCallback? onTap;

  /// Optional trailing hint text (action flavor).
  final String? trailingText;
  final bool? _value;
  final ValueChanged<bool>? _onChanged;

  bool get _isToggle => _value != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge.rounded(
                icon: icon,
                size: _badgeSize,
                radius: _badgeRadius,
                iconSize: _iconSize,
              ),
              const Spacer(),
              if (_isToggle)
                Switch.adaptive(value: _value!, onChanged: _onChanged)
              else if (trailingText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: mood.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trailingText!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: mood.inkMute,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: mood.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: mood.inkMute,
            ),
          ),
        ],
      ),
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: mood.rule),
    );

    return Material(
      color: mood.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: _isToggle
          ? InkWell(onTap: () => _onChanged!(!_value!), child: content)
          : InkWell(onTap: onTap, child: content),
    );
  }
}
