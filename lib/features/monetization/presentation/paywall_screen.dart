import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/celebration_glow.dart';
import 'package:brew_path/core/widgets/float_topbar.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/scroll_flag_scope.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/monetization/domain/paywall_copy.dart';
import 'package:brew_path/features/monetization/domain/paywall_view.dart';
import 'package:brew_path/features/monetization/domain/paywall_view_provider.dart';
import 'package:brew_path/features/monetization/domain/plus_purchase_controller.dart';
import 'package:brew_path/features/monetization/presentation/plan_picker.dart';
import 'package:brew_path/features/monetization/presentation/purchase_outcome_line.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The full offer, in one screen that any pricing model can drive.
///
/// Every word comes from `paywall_config.dart` and every price from the store,
/// so an arm selling three plans and one selling a single purchase are the
/// same screen with different data (#176).
class PaywallScreen extends ConsumerStatefulWidget {
  /// Creates a [PaywallScreen].
  const PaywallScreen({
    required this.onPurchased,
    required this.onRestored,
    required this.onDeclined,
    super.key,
  });

  /// The mascot's size in the hero — the design's `size={96}`, sized so the
  /// pitch and the action still land together on a phone.
  static const double _heroSize = 96;

  /// Where the design opens the scroll under the floating close —
  /// `FLOAT_PAD = 96`, measured from the top of the screen.
  static const double _designScrollPad = 96;

  /// Run once the store says the learner has just bought Plus.
  final VoidCallback onPurchased;

  /// Run once Restore recovers a purchase made earlier.
  ///
  /// Apart from [onPurchased] because the two are different events: one is a
  /// sale to celebrate, the other is a learner getting back what they own.
  final VoidCallback onRestored;

  /// Run when the learner leaves without buying — the close, or *Maybe later*.
  final VoidCallback onDeclined;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  PlusTerm? _picked;

  /// Whether the entitlement now on the way was asked for by Restore.
  ///
  /// The controller reports only that Plus is owned, so which door to leave by
  /// is remembered here, at the press that started it.
  bool _restoring = false;

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(paywallViewProvider);

    ref.listen(plusPurchaseProvider, (_, next) {
      if (next != PlusPurchaseState.owned) return;
      _restoring ? widget.onRestored() : widget.onPurchased();
    });

    return Scaffold(
      backgroundColor: context.mood.bg,
      body: switch (view) {
        AsyncData(:final value) => _Offer(
          view: value,
          picked: value.planFor(_picked).term,
          onPick: (term) => setState(() => _picked = term),
          onDeclined: widget.onDeclined,
          onRestore: _restore,
        ),
        AsyncError() => _Unreachable(onDeclined: widget.onDeclined),
        _ => const Center(child: LoadingIndicator()),
      },
    );
  }

  Future<void> _restore() async {
    _restoring = true;
    await ref.read(plusPurchaseProvider.notifier).restore();
    // Cleared once the restore has settled, whatever it found: a sale made
    // after a restore that recovered nothing is still a sale.
    _restoring = false;
  }
}

class _Offer extends ConsumerWidget {
  const _Offer({
    required this.view,
    required this.picked,
    required this.onPick,
    required this.onDeclined,
    required this.onRestore,
  });

  final PaywallView view;
  final PlusTerm picked;
  final ValueChanged<PlusTerm> onPick;
  final VoidCallback onDeclined;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = context.mood;
    final plan = view.planFor(picked);
    final purchase = ref.watch(plusPurchaseProvider);
    final isWorking = purchase == PlusPurchaseState.working;

    return ScrollFlagScope(
      builder: (context, {required isScrolled}) => Stack(
        children: [
          CelebrationGlow.offer,
          ListView(
            padding:
                FloatTopbar.scrollPadding(
                  context,
                  designScrollPad: PaywallScreen._designScrollPad,
                  inset: AppSpacing.gutter,
                ).copyWith(
                  // An explicit padding turns the list's own safe-area inset off,
                  // so the home indicator's room is added back under the design's
                  // `paddingBottom: 32`.
                  bottom:
                      AppSpacing.xl -
                      OffTokens.paywallLegalOverhang.value +
                      MediaQuery.paddingOf(context).bottom,
                ),
            children: [
              const Center(
                child: Roasty(
                  state: RoastyState.correct,
                  size: PaywallScreen._heroSize,
                  animate: false,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Center(
                child: SmallcapsLabel(
                  '${PaywallCopy.course} · ${view.eyebrow}',
                  color: mood.accent,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                view.heroTitle,
                textAlign: TextAlign.center,
                style: AppText.display(mood: mood),
              ),
              const SizedBox(height: AppSpacing.base),
              const _Benefits(),
              if (view.offersAChoice) ...[
                SizedBox(height: OffTokens.paywallPickerGap.value),
                PlanPicker(plans: view.plans, selected: picked, onPick: onPick),
              ],
              const SizedBox(height: AppSpacing.md),
              PurchaseOutcomeLine(state: purchase),
              _Action(
                plan: plan,
                note: view.note,
                canBuy: view.canBuy,
                isWorking: isWorking,
                onDeclined: onDeclined,
                onRestore: onRestore,
              ),
            ],
          ),
          FloatTopbar(
            icon: AppIcon.close,
            label: PaywallCopy.close,
            onPressed: onDeclined,
            isScrolled: isScrolled,
          ),
        ],
      ),
    );
  }
}

/// The buy action, the way out, and the chrome the App Store requires.
class _Action extends ConsumerWidget {
  const _Action({
    required this.plan,
    required this.note,
    required this.canBuy,
    required this.isWorking,
    required this.onDeclined,
    required this.onRestore,
  });

  final PaywallPlanView plan;
  final String note;
  final bool canBuy;
  final bool isWorking;
  final VoidCallback onDeclined;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = context.mood;
    final controller = ref.read(plusPurchaseProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          label: isWorking
              ? PaywallCopy.working
              : withPrice(paywallPlanCta(plan.term), plan.price),
          onPressed: canBuy && !isWorking
              ? () => controller.buy(
                  offer: PlusOffer(productId: plan.productId, term: plan.term),
                )
              : null,
        ),
        SizedBox(height: OffTokens.ghostUnderPrimaryGap.value),
        GhostButton(
          label: PaywallCopy.maybeLater,
          onPressed: isWorking ? null : onDeclined,
        ),
        SizedBox(height: OffTokens.paywallNoteGap.value),
        // The design sets the note in uppercase; the store's failure line is
        // the app's own sentence and keeps its case.
        Text(
          canBuy ? note.toUpperCase() : PaywallCopy.storeUnreachable,
          textAlign: TextAlign.center,
          style: AppText.micro(
            mood: mood,
            face: AppFace.mono,
            tracking: AppTracking.meta,
          ),
        ),
        // The links' targets overhang their line in the design, so the row's
        // top margin is measured to the text, not to the target's edge.
        SizedBox(
          height:
              OffTokens.paywallLegalTop.value -
              OffTokens.paywallLegalOverhang.value,
        ),
        _RequiredLinks(isWorking: isWorking, onRestore: onRestore),
      ],
    );
  }
}

/// Restore, Terms and Privacy — which the App Store requires of a purchase
/// screen. Restore takes ink, the two disclosures stay muted; Terms and
/// Privacy are inert until #448 gives them a home.
class _RequiredLinks extends StatelessWidget {
  const _RequiredLinks({required this.isWorking, required this.onRestore});

  final bool isWorking;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    spacing: OffTokens.paywallLegalRowGap.value,
    children: [
      _LegalLink(
        label: isWorking ? PaywallCopy.restoring : PaywallCopy.restore,
        onPressed: isWorking ? null : onRestore,
        isMuted: false,
      ),
      const _LegalLink(
        label: PaywallCopy.terms,
        onPressed: null,
        isMuted: true,
      ),
      const _LegalLink(
        label: PaywallCopy.privacy,
        onPressed: null,
        isMuted: true,
      ),
    ],
  );
}

/// One of the legal row's links: the design's mono label, uppercase, whose
/// `padding: 15px 8px` carries a fine-print line to a 44 target.
class _LegalLink extends StatelessWidget {
  const _LegalLink({
    required this.label,
    required this.onPressed,
    required this.isMuted,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final color = isMuted ? mood.inkMute : mood.ink;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        disabledForegroundColor: color,
        minimumSize: const Size(0, FloatTopbar.hitSize),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppText.label(
          color: color,
          face: AppFace.mono,
          tracking: AppTracking.meta,
        ),
      ),
    );
  }
}

/// What the purchase contains — the same for every arm, because what is
/// unlocked never depends on how it was sold.
class _Benefits extends ConsumerWidget {
  const _Benefits();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final benefits = ref.watch(paywallBenefitsProvider).asData?.value;
    if (benefits == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final benefit in benefits)
          _BenefitRow(benefit: benefit, isLast: benefit == benefits.last),
      ],
    );
  }
}

/// One row of the pitch: the design's accent check in a 24 disc, the title
/// over its line, and a hairline under every row but the last.
class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.benefit, required this.isLast});

  static const double _discSize = 24;
  static const double _checkSize = 12;
  static const int _detailLines = 2;

  final PaywallBenefit benefit;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      label: '${benefit.title}. ${benefit.detail}',
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: OffTokens.paywallPitchRowPadding.value,
        ),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: mood.rule)),
        ),
        child: Row(
          children: [
            Container(
              width: _discSize,
              height: _discSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mood.accentWash,
              ),
              child: Center(
                child: IconMark(
                  AppIcon.check,
                  size: _checkSize,
                  color: mood.accent,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    benefit.title,
                    style: AppText.body(mood: mood, face: AppFace.control),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    benefit.detail,
                    maxLines: _detailLines,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.support(mood: mood, color: mood.inkMute),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The store said nothing, so there is no honest price to draw.
class _Unreachable extends StatelessWidget {
  const _Unreachable({required this.onDeclined});

  final VoidCallback onDeclined;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.gutter),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          PaywallCopy.storeUnreachable,
          textAlign: TextAlign.center,
          style: AppText.body(mood: context.mood),
        ),
        const SizedBox(height: AppSpacing.md),
        GhostButton(label: PaywallCopy.maybeLater, onPressed: onDeclined),
      ],
    ),
  );
}
