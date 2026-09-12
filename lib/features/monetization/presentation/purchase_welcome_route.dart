import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/monetization/config/paywall_config.dart';
import 'package:brew_path/features/monetization/domain/purchased_term.dart';
import 'package:brew_path/features/monetization/presentation/purchase_welcome_screen.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Where the celebration's two doors lead, and which plan it celebrates.
///
/// The screen itself takes callbacks and a plan, so this is the only thing
/// that knows the app has a Studio and a Learn tab, and that the paywall
/// recorded what was bought. A celebration reached with nothing recorded —
/// a deep link an owner opens — reads as the one-time purchase v1 sells.
class PurchaseWelcomeRoute extends ConsumerWidget {
  /// Creates the route host, leaving for [returnTo] when the celebration is
  /// done.
  const PurchaseWelcomeRoute({this.returnTo, super.key});

  /// Where *Back to learning* goes — the screen the offer was raised on, or
  /// Learn when the sale happened somewhere with nothing to go back to.
  final String? returnTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final term = ref.watch(purchasedTermProvider) ?? PlusTerm.lifetime;
    final back = returnTo;

    return PurchaseWelcomeScreen(
      plan: paywallPlans[term]!,
      onOpenStudio: () => context.goNamed(AppRoutes.studio.name),
      onContinue: back == null
          ? () => context.goNamed(AppRoutes.learn.name)
          : () => context.go(back),
    );
  }
}
