import 'package:flutter/material.dart';

/// Square tile used in the "Customize" grid. Has two flavors:
///
/// * [PreferenceTile.toggle] — backed by a [Switch], state owned by the caller.
/// * [PreferenceTile.action] — taps run [onTap]; an optional [trailingText]
///   hints at the action (e.g. "Coming soon").
class PreferenceTile extends StatelessWidget {
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

  const PreferenceTile.action({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
    this.trailingText,
  }) : _value = null,
       _onChanged = null;

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final String? trailingText;
  final bool? _value;
  final ValueChanged<bool>? _onChanged;

  bool get _isToggle => _value != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: colors.onPrimaryContainer),
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
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trailingText!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
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
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: colors.outlineVariant),
    );

    return Material(
      color: colors.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: _isToggle
          ? InkWell(onTap: () => _onChanged!(!_value!), child: content)
          : InkWell(onTap: onTap, child: content),
    );
  }
}
