import 'package:brew_path/core/widgets/app_sheet.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/core/widgets/link_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/monetization/config/paywall_config.dart';
import 'package:brew_path/features/monetization/domain/paywall_view.dart';
import 'package:brew_path/features/monetization/domain/paywall_view_provider.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/features/monetization/domain/plus_purchase_controller.dart';
import 'package:brew_path/features/monetization/presentation/legal_links.dart';
import 'package:brew_path/features/monetization/presentation/plus_pitch_list.dart';
import 'package:brew_path/features/monetization/presentation/purchase_outcome_line.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The one sheet every lock raises.
///
/// Opens with **what was just hit** — the trigger's own header — then the
/// ranked bullets, then one action: ADR-0003 sells a single non-consumable, so
/// no trial and no plan chooser, and **no ad path** (v1 ships no ads, so the
/// design's watch-an-ad route is dead). *Not now* writes nothing.
Future<void> showPlusGate(BuildContext context, PlusGateTrigger trigger) =>
    showAppSheet<void>(
      context: context,
      title: PlusCopy.title,
      builder: (_) => _PlusGateBody(trigger: trigger),
    );

class _PlusGateBody extends ConsumerWidget {
  const _PlusGateBody({required this.trigger});

  final PlusGateTrigger trigger;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = context.mood;
    final pitch = ref.watch(plusPitchProvider);
    final purchase = ref.watch(plusPurchaseProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(trigger.header, style: AppText.lead(mood: mood)),
        const SizedBox(height: AppSpacing.md),
        // The pitch waits for its counts rather than showing a number it is
        // about to correct. Nothing here is written down, so there is nothing
        // to fall back to.
        PlusPitchList(pitch: pitch.asData?.value),
        const SizedBox(height: AppSpacing.lg),
        PurchaseOutcomeLine(state: purchase),
        _GateAction(isWorking: purchase == PlusPurchaseState.working),
        const SizedBox(height: AppSpacing.xs),
        GhostButton(
          label: PlusCopy.notNow,
          onPressed: purchase == PlusPurchaseState.working
              ? null
              : () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: LinkButton(
            label: PlusCopy.restore,
            onPressed: purchase == PlusPurchaseState.working
                ? null
                : () => ref.read(plusPurchaseProvider.notifier).restore(),
          ),
        ),
        const _LegalLinks(),
      ],
    );
  }
}

/// The gate's action and the mono line under it, both from the arm's config —
/// so the sheet and the paywall screen never disagree about what is sold.
class _GateAction extends ConsumerWidget {
  const _GateAction({required this.isWorking});

  final bool isWorking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(paywallViewProvider).asData?.value;
    final config = paywallModels[view?.model ?? MonetizationModel.oneTime]!;
    final price = view?.planFor(null).price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          label: isWorking
              ? PlusCopy.working
              : withPrice(config.gateCta, price),
          onPressed: isWorking
              ? null
              : () => ref.read(plusPurchaseProvider.notifier).buy(),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          withPrice(config.gateFooter, price),
          textAlign: TextAlign.center,
          style: AppText.micro(mood: context.mood, face: AppFace.mono),
        ),
      ],
    );
  }
}

/// Terms and Privacy, which the App Store requires of a non-consumable.
class _LegalLinks extends StatelessWidget {
  const _LegalLinks();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: AppSpacing.xs),
    child: LegalLinks(
      termsLabel: PlusCopy.terms,
      privacyLabel: PlusCopy.privacy,
    ),
  );
}
