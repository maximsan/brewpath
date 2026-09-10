import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/celebration_glow.dart';
import 'package:brew_path/core/widgets/float_topbar.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/core/widgets/link_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/features/monetization/domain/plus_purchase_controller.dart';
import 'package:brew_path/features/monetization/presentation/plus_pitch_list.dart';
import 'package:brew_path/features/monetization/presentation/purchase_outcome_line.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The offer, as a screen: what Plus contains, what it costs, and two ways out.
///
/// The same purchase as every gate — one non-consumable, no plan picker and no
/// trial (ADR-0003) — drawn full-screen because the intro ends here rather than
/// interrupting something (ADR-0010). Buying is never required: [onDeclined]
/// and [onPurchased] both walk on.
class PaywallScreen extends ConsumerStatefulWidget {
  /// Creates the offer screen.
  const PaywallScreen({
    required this.onPurchased,
    required this.onRestored,
    required this.onDeclined,
    super.key,
  });

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
  /// Whether the entitlement now on the way was asked for by Restore.
  ///
  /// The controller reports only that Plus is owned, so which door to leave by
  /// is remembered here, at the press that started it.
  bool _restoring = false;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final purchase = ref.watch(plusPurchaseProvider);

    ref.listen(plusPurchaseProvider, (_, next) {
      if (next != PlusPurchaseState.owned) return;
      _restoring ? widget.onRestored() : widget.onPurchased();
    });

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: PlusCopy.screenSemanticLabel,
      child: Scaffold(
        backgroundColor: mood.bg,
        body: Stack(
          children: [
            CelebrationGlow.offer,
            _OfferBody(
              purchase: purchase,
              onDeclined: widget.onDeclined,
              onRestore: _restore,
            ),
            // Live even while the store is deciding: the purchase belongs to
            // the controller, not this screen, so leaving cannot strand it —
            // and a close that looks pressable must be.
            FloatTopbar.sealed(
              icon: AppIcon.close,
              label: PlusCopy.close,
              onPressed: widget.onDeclined,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _restore() async {
    _restoring = true;
    await ref.read(plusPurchaseProvider.notifier).restore();
  }
}

/// How large the dressed mascot is drawn — the design's `size={112}`, sized so
/// the pitch and the price still land together on one screen.
const double _heroSize = 112;

/// Hero, pitch, then the actions — one scroller, so the price is reachable at
/// every text size.
class _OfferBody extends ConsumerWidget {
  const _OfferBody({
    required this.purchase,
    required this.onDeclined,
    required this.onRestore,
  });

  final PlusPurchaseState purchase;
  final VoidCallback onDeclined;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = context.mood;
    final pitch = ref.watch(plusPitchProvider);
    final working = purchase == PlusPurchaseState.working;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          FloatTopbar.height,
          AppSpacing.gutter,
          AppSpacing.lg,
        ),
        children: [
          // The design dresses him here — hat, glasses, flower. The Studio
          // that owns those pieces is #367, so he arrives plain until it does.
          const Center(
            child: ExcludeSemantics(
              child: Roasty(state: RoastyState.correct, size: _heroSize),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: SmallcapsLabel(
              PlusCopy.screenEyebrow,
              color: mood.accentText,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            PlusCopy.screenTitle,
            textAlign: TextAlign.center,
            style: AppText.display(mood: mood),
          ),
          const SizedBox(height: AppSpacing.lg),
          PlusPitchList(pitch: pitch.asData?.value),
          const SizedBox(height: AppSpacing.md),
          PurchaseOutcomeLine(state: purchase),
          PrimaryButton(
            label: working ? PlusCopy.working : PlusCopy.buy,
            onPressed: working
                ? null
                : () => ref.read(plusPurchaseProvider.notifier).buy(),
          ),
          SizedBox(height: OffTokens.ghostUnderPrimaryGap.value),
          GhostButton(
            label: PlusCopy.maybeLater,
            onPressed: working ? null : onDeclined,
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            PlusCopy.screenNote,
            textAlign: TextAlign.center,
            style: AppText.micro(mood: mood, face: AppFace.mono),
          ),
          const SizedBox(height: AppSpacing.sm),
          _StoreLinks(working: working, onRestore: onRestore),
        ],
      ),
    );
  }
}

/// Restore, Terms and Privacy: what the App Store requires of the screen that
/// sells a non-consumable.
///
/// ⚠️ Terms and Privacy are the same disabled stubs the gate sheet draws, owed
/// real URLs at [#448](https://github.com/maximsan/brewpath/issues/448).
class _StoreLinks extends StatelessWidget {
  const _StoreLinks({required this.working, required this.onRestore});

  final bool working;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    spacing: AppSpacing.md,
    runSpacing: AppSpacing.xxs,
    children: [
      LinkButton(
        label: PlusCopy.restore,
        onPressed: working ? null : onRestore,
      ),
      const LinkButton(label: PlusCopy.terms, onPressed: null),
      const LinkButton(label: PlusCopy.privacy, onPressed: null),
    ],
  );
}
