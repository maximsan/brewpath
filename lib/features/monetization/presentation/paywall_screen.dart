import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/float_topbar.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/core/widgets/link_button.dart';
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
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The full offer, in one screen that any pricing model can drive.
///
/// Every word comes from `paywall_config.dart` and every price from the store,
/// so an arm selling three plans and one selling a single purchase are the
/// same screen with different data (#176).
class PaywallScreen extends ConsumerStatefulWidget {
  /// Creates a [PaywallScreen].
  const PaywallScreen({required this.onClose, super.key});

  /// The mascot's size in the hero — sized so the pitch and the action still
  /// land together on a phone.
  static const double _heroSize = 112;

  /// Called when the learner leaves without buying.
  final VoidCallback onClose;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  PlusTerm? _picked;

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(paywallViewProvider);

    return Scaffold(
      backgroundColor: context.mood.bg,
      body: switch (view) {
        AsyncData(:final value) => _Offer(
          view: value,
          picked: value.planFor(_picked).term,
          onPick: (term) => setState(() => _picked = term),
          onClose: widget.onClose,
        ),
        AsyncError() => _Unreachable(onClose: widget.onClose),
        _ => const Center(child: LoadingIndicator()),
      },
    );
  }
}

class _Offer extends ConsumerWidget {
  const _Offer({
    required this.view,
    required this.picked,
    required this.onPick,
    required this.onClose,
  });

  final PaywallView view;
  final PlusTerm picked;
  final ValueChanged<PlusTerm> onPick;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = context.mood;
    final plan = view.planFor(picked);
    final purchase = ref.watch(plusPurchaseProvider);
    final isWorking = purchase == PlusPurchaseState.working;

    return ScrollFlagScope(
      builder: (context, {required isScrolled}) => Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.xxl,
              AppSpacing.gutter,
              AppSpacing.lg,
            ),
            children: [
              const Center(
                child: Roasty(
                  state: RoastyState.correct,
                  size: PaywallScreen._heroSize,
                  animate: false,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(child: SmallcapsLabel(view.eyebrow, color: mood.accent)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                view.heroTitle,
                textAlign: TextAlign.center,
                style: AppText.display(mood: mood),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _Benefits(),
              if (view.offersAChoice) ...[
                const SizedBox(height: AppSpacing.lg),
                PlanPicker(plans: view.plans, selected: picked, onPick: onPick),
              ],
              const SizedBox(height: AppSpacing.lg),
              _Action(
                plan: plan,
                note: view.note,
                canBuy: view.canBuy,
                isWorking: isWorking,
                onClose: onClose,
              ),
            ],
          ),
          FloatTopbar(
            icon: AppIcon.close,
            label: PaywallCopy.close,
            onPressed: onClose,
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
    required this.onClose,
  });

  final PaywallPlanView plan;
  final String note;
  final bool canBuy;
  final bool isWorking;
  final VoidCallback onClose;

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
        const SizedBox(height: AppSpacing.xs),
        GhostButton(
          label: PaywallCopy.maybeLater,
          onPressed: isWorking ? null : onClose,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          canBuy ? note : PaywallCopy.storeUnreachable,
          textAlign: TextAlign.center,
          style: AppText.micro(mood: mood, face: AppFace.mono),
        ),
        const SizedBox(height: AppSpacing.xs),
        _RequiredLinks(isWorking: isWorking, onRestore: controller.restore),
      ],
    );
  }
}

/// Restore, Terms and Privacy — which the App Store requires of a purchase
/// screen. Terms and Privacy stay disabled until #448 gives them a home.
class _RequiredLinks extends StatelessWidget {
  const _RequiredLinks({required this.isWorking, required this.onRestore});

  final bool isWorking;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    spacing: AppSpacing.md,
    runSpacing: AppSpacing.xxs,
    children: [
      LinkButton(
        label: PaywallCopy.restore,
        onPressed: isWorking ? null : onRestore,
      ),
      const LinkButton(label: PaywallCopy.terms, onPressed: null),
      const LinkButton(label: PaywallCopy.privacy, onPressed: null),
    ],
  );
}

/// What the purchase contains — the same for every arm, because what is
/// unlocked never depends on how it was sold.
class _Benefits extends ConsumerWidget {
  const _Benefits();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = context.mood;
    final benefits = ref.watch(paywallBenefitsProvider).asData?.value;
    if (benefits == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final benefit in benefits)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: benefit.title,
                    style: AppText.body(mood: mood, face: AppFace.control),
                  ),
                  const TextSpan(text: '  '),
                  TextSpan(
                    text: benefit.detail,
                    style: AppText.support(mood: mood, color: mood.inkMute),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// The store said nothing, so there is no honest price to draw.
class _Unreachable extends StatelessWidget {
  const _Unreachable({required this.onClose});

  final VoidCallback onClose;

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
        GhostButton(label: PaywallCopy.maybeLater, onPressed: onClose),
      ],
    ),
  );
}
