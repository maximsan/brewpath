import 'package:brew_path/features/monetization/config/paywall_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_purchase_controller.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// What the store said, when it has said anything.
///
/// Silent while idle or cancelled: backing out is a normal thing to do and
/// earns no message, which is what keeps the offer from scolding. Shared by the
/// gate sheet and the offer screen so one purchase reads the same on both.
class PurchaseOutcomeLine extends StatelessWidget {
  /// Creates the line for [state].
  const PurchaseOutcomeLine({required this.state, super.key});

  /// Where the purchase currently stands.
  final PlusPurchaseState state;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final (message, tone) = switch (state) {
      PlusPurchaseState.owned => (PaywallCopy.owned, mood.accent),
      PlusPurchaseState.pending => (PaywallCopy.pending, mood.inkMute),
      PlusPurchaseState.failed => (PaywallCopy.failed, mood.berry),
      PlusPurchaseState.nothingToRestore => (
        PaywallCopy.nothingToRestore,
        mood.inkMute,
      ),
      PlusPurchaseState.idle ||
      PlusPurchaseState.working ||
      PlusPurchaseState.cancelled => (null, mood.ink),
    };
    if (message == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        liveRegion: true,
        child: Text(message, style: AppText.support(color: tone)),
      ),
    );
  }
}
