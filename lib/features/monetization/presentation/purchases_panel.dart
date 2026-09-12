/// What Purchases holds: the owned state, or the offer and Restore.
library;

import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/monetization/config/paywall_config.dart';
import 'package:brew_path/features/monetization/config/paywall_copy.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/domain/plus_offering_provider.dart';
import 'package:brew_path/features/monetization/domain/plus_purchase_controller.dart';
import 'package:brew_path/features/monetization/domain/purchased_term.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:brew_path/features/monetization/presentation/purchase_outcome_line.dart';
import 'package:brew_path/services/links/link_provider.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Apple's own page, the only place a subscription can be changed or stopped.
final Uri appleSubscriptionsUrl = Uri.parse(
  'https://apps.apple.com/account/subscriptions',
);

/// The body of Settings → `ACCOUNT` → Purchases.
///
/// Lives in the paywall's own layer because what it says changes with the arm
/// the learner is on, which nothing outside that layer may know (#176).
class PurchasesPanel extends ConsumerWidget {
  /// Creates the panel.
  const PurchasesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Unresolved reads as locked, as everywhere else: the offer is the safe
    // thing to draw while the store is still answering.
    final owned = ref.watch(courseEntitlementProvider).asData?.value ?? false;

    return owned ? const _Owned() : const _Offer();
  }
}

/// The owned state: what was bought, and the one thing left to do about it.
class _Owned extends ConsumerWidget {
  const _Owned();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Nothing records the term across a restart, so an owner who bought on
    // another run reads as the one-time purchase — as the celebration does.
    final term = ref.watch(purchasedTermProvider) ?? PlusTerm.lifetime;
    final plan = paywallPlans[term]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SmallcapsLabel(plan.ownedChip),
        const SizedBox(height: AppSpacing.xs),
        _Lines(plan.ownedFooter),
        if (term != PlusTerm.lifetime)
          SettingsNavRow(
            label: PaywallCopy.manageSubscription,
            onTap: () =>
                ref.read(linkOpenerProvider).open(appleSubscriptionsUrl),
          ),
      ],
    );
  }
}

/// The free state: what this arm sells, the way in, and Restore.
class _Offer extends ConsumerWidget {
  const _Offer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model =
        ref.watch(plusOfferingProvider).asData?.value.model ??
        MonetizationModel.oneTime;
    final purchase = ref.watch(plusPurchaseProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Lines(paywallModels[model]!.purchasesFooter),
        SettingsNavRow(
          label: PaywallCopy.unlock,
          onTap: () => showPlusGate(context, const AskedForTheCourse()),
        ),
        SettingsNavRow(
          label: PaywallCopy.restore,
          isDimmed: purchase == PlusPurchaseState.working,
          onTap: () => ref.read(plusPurchaseProvider.notifier).restore(),
        ),
        PurchaseOutcomeLine(state: purchase),
      ],
    );
  }
}

/// The two-line caption a state carries, in the design's support type.
class _Lines extends StatelessWidget {
  const _Lines(this.lines);

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Text(line, style: AppText.support(color: mood.inkMute)),
        ],
      ),
    );
  }
}
