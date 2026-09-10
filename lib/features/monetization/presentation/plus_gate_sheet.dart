import 'package:brew_path/core/widgets/app_sheet.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/core/widgets/link_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/features/monetization/domain/plus_purchase_controller.dart';
import 'package:brew_path/features/monetization/presentation/plus_pitch_list.dart';
import 'package:brew_path/features/monetization/presentation/purchase_outcome_line.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The one sheet every lock raises.
///
/// Opens with **what was just hit** — the trigger's own header — then the
/// ranked bullets, then a single action: ADR-0003 sells one non-consumable, so
/// there is no trial, no plan chooser and no ad path. *Not now* makes declining
/// a button rather than a swipe the learner has to discover; it writes nothing.
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
        PrimaryButton(
          label: purchase == PlusPurchaseState.working
              ? PlusCopy.working
              : PlusCopy.buy,
          onPressed: purchase == PlusPurchaseState.working
              ? null
              : () => ref.read(plusPurchaseProvider.notifier).buy(),
        ),
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

/// Terms and Privacy, which the App Store requires of a non-consumable.
///
/// ⚠️ Both are stubs, disabled rather than dead: the real URLs are owed at
/// [#448](https://github.com/maximsan/brewpath/issues/448). Their absence is a
/// store-review failure, and a link that looks live and does nothing is worse.
class _LegalLinks extends StatelessWidget {
  const _LegalLinks();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: AppSpacing.xs),
    // Wrapped, not a Row: two links side by side fit a phone at the default
    // text size and stop fitting well before the largest one, and a required
    // legal link is the last thing that may be clipped off the sheet.
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xxs,
      children: [
        LinkButton(label: PlusCopy.terms, onPressed: null),
        LinkButton(label: PlusCopy.privacy, onPressed: null),
      ],
    ),
  );
}
