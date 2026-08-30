import 'package:brew_path/core/widgets/app_sheet.dart';
import 'package:brew_path/core/widgets/link_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/features/monetization/domain/plus_purchase_controller.dart';
import 'package:brew_path/features/monetization/presentation/plus_pitch_list.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The one sheet every lock raises.
///
/// Opens with **what was just hit** — the trigger's own header — so the pitch
/// answers the question the learner actually asked, then the ranked bullets,
/// then a single action.
///
/// **Exactly one way out: buy.** No ad path (there are no ads in v1 and the
/// design's watch-an-ad route is dead), no trial and no plan chooser (ADR-0003
/// sells one non-consumable). Restore, Terms and Privacy are present because
/// the App Store requires them of one.
///
/// Dismissal writes nothing and changes nothing: looking is free.
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
        _PurchaseOutcome(state: purchase),
        PrimaryButton(
          label: purchase == PlusPurchaseState.working
              ? PlusCopy.working
              : PlusCopy.buy,
          onPressed: purchase == PlusPurchaseState.working
              ? null
              : () => ref.read(plusPurchaseProvider.notifier).buy(),
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

/// What the store said, when it has said anything.
///
/// Silent while idle or cancelled: backing out is a normal thing to do and
/// earns no message, which is what keeps the sheet from scolding.
class _PurchaseOutcome extends StatelessWidget {
  const _PurchaseOutcome({required this.state});

  final PlusPurchaseState state;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final (message, tone) = switch (state) {
      PlusPurchaseState.owned => (PlusCopy.owned, mood.accent),
      PlusPurchaseState.pending => (PlusCopy.pending, mood.inkMute),
      PlusPurchaseState.failed => (PlusCopy.failed, mood.berry),
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

/// Terms and Privacy, which the App Store requires of a non-consumable.
///
/// ⚠️ **Both are stubs, and disabled rather than dead.** The real URLs are owed
/// at [#448](https://github.com/maximsan/brewpath/issues/448). They are drawn
/// because their absence is a store-review failure, and disabled because a link
/// that looks live and does nothing is the defect the design docs already
/// record against the About screen.
class _LegalLinks extends StatelessWidget {
  const _LegalLinks();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: AppSpacing.xs),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LinkButton(label: PlusCopy.terms, onPressed: null),
        SizedBox(width: AppSpacing.md),
        LinkButton(label: PlusCopy.privacy, onPressed: null),
      ],
    ),
  );
}
