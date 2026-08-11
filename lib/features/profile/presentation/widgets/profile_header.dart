import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Collapsing header for the Profile screen.
///
/// At the top of the scroll the header is fully transparent: just a large
/// left-aligned title with floating X / gear buttons. As the user scrolls,
/// the large title fades out, a compact centered title fades in, and a
/// near-opaque tinted surface plus a soft drop shadow build up behind the
/// bar — so it reads as a distinct floating header over the content.
class ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  /// Creates a [ProfileHeaderDelegate].
  ProfileHeaderDelegate({
    required this.title,
    required this.onClose,
    required this.onSettings,
  });

  /// The header title text.
  final String title;

  /// Called when the close (X) button is tapped.
  final VoidCallback onClose;

  /// Called when the settings (gear) button is tapped.
  final VoidCallback onSettings;

  static const double _expanded = 136;
  static const double _collapsed = 64;
  static const double _hInset = 16;
  static const double _topInset = 8;
  static const double _bottomInset = 8;
  static const double _shadowMaxAlpha = 0.08;
  static const double _shadowBlur = 12;
  static const double _shadowOffsetY = 4;

  @override
  double get maxExtent => _expanded;

  @override
  double get minExtent => _collapsed;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final mood = context.mood;

    const range = _expanded - _collapsed;
    final t = (shrinkOffset / range).clamp(0.0, 1.0);

    final titleScale = 1.0 - (0.45 * t);
    final largeTitleOpacity = (1.0 - (t * 1.6)).clamp(0.0, 1.0);
    // Cross-fade the compact bar in almost immediately on scroll so the
    // "header appearing" intent is obvious, not a barely-perceptible drift.
    final compactTitleOpacity = ((t - 0.05) / 0.35).clamp(0.0, 1.0);
    // Tint reaches 0.95 alpha — almost solid, but still slightly translucent
    // so it reads as a glass bar floating over content rather than a
    // hard-edged AppBar.
    final tintAlpha = (t * 0.95).clamp(0.0, 0.95);
    final shadowOpacity = ((t - 0.1) / 0.4).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Tinted surface + drop shadow: the raised `surface` tone over the
        // page `bg` is what makes the bar read as elevated.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: mood.surface.withValues(alpha: tintAlpha),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: _shadowMaxAlpha * shadowOpacity,
                    ),
                    blurRadius: _shadowBlur,
                    offset: const Offset(0, _shadowOffsetY),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: _hInset,
          right: _hInset,
          top: _topInset,
          child: Row(
            children: [
              _CircleIconButton(
                icon: Icons.close,
                onPressed: onClose,
                tooltip: 'Close',
              ),
              Expanded(
                child: Center(
                  child: Opacity(
                    opacity: compactTitleOpacity,
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: mood.ink,
                      ),
                    ),
                  ),
                ),
              ),
              _CircleIconButton(
                icon: Icons.settings_outlined,
                onPressed: onSettings,
                tooltip: 'Settings',
              ),
            ],
          ),
        ),
        Positioned(
          left: _hInset,
          right: _hInset,
          bottom: _bottomInset,
          child: Opacity(
            opacity: largeTitleOpacity,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Transform.scale(
                alignment: Alignment.bottomLeft,
                scale: titleScale,
                child: Text(
                  title,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: mood.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant ProfileHeaderDelegate oldDelegate) {
    return oldDelegate.title != title ||
        oldDelegate.onClose != onClose ||
        oldDelegate.onSettings != onSettings;
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  static const double _size = 48;
  static const double _iconSize = 26;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: mood.surface,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: _size,
            height: _size,
            child: Icon(icon, size: _iconSize, color: mood.ink),
          ),
        ),
      ),
    );
  }
}
