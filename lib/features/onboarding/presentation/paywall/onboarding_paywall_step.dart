import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/monetization/presentation/paywall_screen.dart';
import 'package:brew_path/features/onboarding/presentation/onboarding_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen 05 of the intro: the Plus offer, and the end of onboarding.
///
/// **Both exits finish the intro** (ADR-0010) — buying is never required. The
/// flag is written here rather than at the name step, because a learner still
/// looking at the offer has not been through the flow yet, and a router that
/// thought otherwise would bounce them off this screen before they answered.
class OnboardingPaywallStep extends ConsumerStatefulWidget {
  /// Creates the intro's offer step.
  const OnboardingPaywallStep({super.key});

  @override
  ConsumerState<OnboardingPaywallStep> createState() =>
      _OnboardingPaywallStepState();
}

class _OnboardingPaywallStepState extends ConsumerState<OnboardingPaywallStep> {
  /// Guards the two exits against firing twice — Restore can resolve while a
  /// tap on *Maybe later* is already on its way.
  bool _left = false;

  @override
  Widget build(BuildContext context) => PaywallScreen(
    onPurchased: () => _leaveFor(AppRoutes.purchaseWelcome.name),
    onDeclined: () => _leaveFor(AppRoutes.learn.name),
  );

  /// Finishes the intro, then goes to [routeName].
  ///
  /// The write lands before the navigation so a learner who closes the app on
  /// the next screen comes back to the app rather than to Welcome.
  Future<void> _leaveFor(String routeName) async {
    if (_left) return;
    _left = true;
    await ref.read(onboardingDraftProvider.notifier).complete();
    if (mounted) context.goNamed(routeName);
  }
}
