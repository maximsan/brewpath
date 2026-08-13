import 'dart:async';

import 'package:brew_path/core/widgets/icon_badge.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Hero CTA at the top of the Profile screen. The real in-app purchase flow
/// lands with the AdMob/IAP integration; for now this opens a coming-soon
/// dialog so the visual hierarchy is in place ahead of monetization.
class PremiumCard extends StatelessWidget {
  /// Creates a [PremiumCard].
  const PremiumCard({super.key});

  static const double _cornerRadius = 20;
  static const double _subtitleAlpha = 0.85;
  static const double _iconBadgeSize = 72;
  static const double _iconBadgeAlpha = 0.12;
  static const double _iconSize = 40;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Material(
      color: mood.accent,
      borderRadius: BorderRadius.circular(_cornerRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showComingSoon(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Go Premium',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: mood.accentInk,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Unlock every module, remove ads, and keep your streak '
                      'safe with a BrewPath Plus subscription.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: mood.accentInk.withValues(
                          alpha: _subtitleAlpha,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconBadge.rounded(
                icon: Icons.workspace_premium,
                size: _iconBadgeSize,
                radius: _cornerRadius,
                iconSize: _iconSize,
                // Sits on the accent-filled premium card, so the well is a
                // wash of the card's own ink rather than another accent fill.
                background: mood.accentInk.withValues(alpha: _iconBadgeAlpha),
                foreground: mood.accentInk,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Premium is brewing'),
          content: const Text(
            'In-app purchases are wired up in a later release. Hold tight — '
            'your streak counts either way.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
