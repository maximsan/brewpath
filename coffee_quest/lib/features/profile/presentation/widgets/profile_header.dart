import 'package:flutter/material.dart';

/// Collapsing header for the Profile screen.
///
/// At the top of the scroll the header is fully transparent: just a large
/// left-aligned title with floating X / gear buttons. As the user scrolls,
/// the large title fades out, a compact centered title fades in, and a
/// near-opaque tinted surface plus a soft drop shadow build up behind the
/// bar — so it reads as a distinct floating header over the content.
class ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  ProfileHeaderDelegate({
    required this.title,
    required this.onClose,
    required this.onSettings,
  });

  final String title;
  final VoidCallback onClose;
  final VoidCallback onSettings;

  static const double _expanded = 136;
  static const double _collapsed = 64;

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
    final colors = theme.colorScheme;

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
        // Tinted surface + drop shadow. Use `surfaceContainerHigh` rather
        // than `surface` so the bar reads as a distinct elevated tone
        // against the cream page background beneath.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh.withValues(
                  alpha: tintAlpha,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.08 * shadowOpacity,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 8,
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
                        color: colors.onSurface,
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
          left: 16,
          right: 16,
          bottom: 8,
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
                    color: colors.onSurface,
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.surfaceContainerLowest,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, size: 26, color: colors.onSurface),
          ),
        ),
      ),
    );
  }
}
