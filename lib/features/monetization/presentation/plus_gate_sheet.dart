import 'package:brew_path/core/config/app_links_provider.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/app_sheet.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/core/widgets/link_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/monetization/config/paywall_config.dart';
import 'package:brew_path/features/monetization/config/paywall_copy.dart';
import 'package:brew_path/features/monetization/domain/paywall_view.dart';
import 'package:brew_path/features/monetization/domain/paywall_view_provider.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/features/monetization/domain/plus_purchase_controller.dart';
import 'package:brew_path/features/monetization/domain/purchase_exit.dart';
import 'package:brew_path/features/monetization/domain/purchase_welcome_return.dart';
import 'package:brew_path/features/monetization/presentation/plus_pitch_list.dart';
import 'package:brew_path/features/monetization/presentation/purchase_outcome_line.dart';
import 'package:brew_path/services/links/open_link.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The one sheet every lock raises.
///
/// Opens with **what was just hit** — the trigger's own header — then the
/// ranked bullets, then the arm's own action: no trial on any arm (ADR-0024)
/// and **no ad path** (v1 ships no ads). *Not now* writes nothing; a sale
/// lands on the welcome, which comes back here.
Future<void> showPlusGate(BuildContext context, PlusGateTrigger trigger) {
  // Held rather than looked up again on the way out: closing the sheet leaves
  // its own context behind. Absent only where a single screen is pumped on its
  // own, which is a test, and where there is nowhere to celebrate anyway.
  final router = GoRouter.maybeOf(context);
  final raisedAt = router?.state.uri.toString();

  return showAppSheet<void>(
    context: context,
    title: PaywallCopy.gateTitle,
    builder: (sheetContext) => _PlusGateBody(
      trigger: trigger,
      onPurchased: () {
        _close(sheetContext);
        if (router == null || raisedAt == null) return;
        router.goNamed(
          AppRoutes.purchaseWelcome.name,
          queryParameters: welcomeReturnTo(raisedAt),
        );
      },
      // A recovery, not a sale: the lock behind the sheet is open now, and
      // that is the whole of what the learner asked for.
      onRestored: () => _close(sheetContext),
    ),
  );
}

/// Closes the sheet, unless it is already leaving — dragged away while the
/// store was still answering, when a pop would take the screen under it.
void _close(BuildContext sheetContext) {
  if (ModalRoute.of(sheetContext)?.isCurrent ?? false) {
    Navigator.of(sheetContext).pop();
  }
}

class _PlusGateBody extends ConsumerStatefulWidget {
  const _PlusGateBody({
    required this.trigger,
    required this.onPurchased,
    required this.onRestored,
  });

  final PlusGateTrigger trigger;
  final VoidCallback onPurchased;
  final VoidCallback onRestored;

  @override
  ConsumerState<_PlusGateBody> createState() => _PlusGateBodyState();
}

class _PlusGateBodyState extends ConsumerState<_PlusGateBody> {
  late final PurchaseExit _exit = PurchaseExit(
    onPurchased: () => widget.onPurchased(),
    onRestored: () => widget.onRestored(),
  );

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final pitch = ref.watch(plusPitchProvider);
    final purchase = ref.watch(plusPurchaseProvider);

    ref.listen(plusPurchaseProvider, (_, next) => _exit.settle(next));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.trigger.header, style: AppText.lead(mood: mood)),
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
          label: PaywallCopy.notNow,
          onPressed: purchase == PlusPurchaseState.working
              ? null
              : () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: LinkButton(
            label: PaywallCopy.restore,
            onPressed: purchase == PlusPurchaseState.working
                ? null
                : () => _exit.restore(ref.read(plusPurchaseProvider.notifier)),
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
    final perMonth = view?.fromPerMonth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          label: isWorking
              ? PaywallCopy.working
              : withPrice(config.gateCta, price, perMonth: perMonth),
          onPressed: isWorking
              ? null
              : () => ref.read(plusPurchaseProvider.notifier).buy(),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          withPrice(config.gateFooter, price, perMonth: perMonth),
          textAlign: TextAlign.center,
          style: AppText.micro(mood: context.mood, face: AppFace.mono),
        ),
      ],
    );
  }
}

/// Terms and Privacy, which the App Store requires of a non-consumable.
///
/// Drawn even while unhosted — their absence on a buying surface is a
/// store-review failure, so an inert link is the lesser of the two (#448).
/// They go live the moment the pages exist.
class _LegalLinks extends ConsumerWidget {
  const _LegalLinks();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.xs),
    // Wrapped, not a Row: two links side by side fit a phone at the default
    // text size and stop fitting well before the largest one, and a required
    // legal link is the last thing that may be clipped off the sheet.
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xxs,
      children: [
        LinkButton(
          label: PaywallCopy.terms,
          onPressed: openOr(ref, ref.watch(termsPageProvider)),
        ),
        LinkButton(
          label: PaywallCopy.privacy,
          onPressed: openOr(ref, ref.watch(privacyPageProvider)),
        ),
      ],
    ),
  );
}
