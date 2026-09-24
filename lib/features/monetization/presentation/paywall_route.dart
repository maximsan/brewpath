import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/monetization/domain/purchase_welcome_return.dart';
import 'package:brew_path/features/monetization/presentation/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Where the paywall's three exits lead when a lock handed off to it.
///
/// The screen itself takes callbacks, so this is the only thing that knows a
/// sale lands on the celebration and that the other two doors go back to the
/// screen the lock was raised on — or to Learn, when nothing named one.
class PaywallRoute extends StatelessWidget {
  /// Creates the route host, returning to [returnTo] when the offer is left.
  const PaywallRoute({this.returnTo, super.key});

  /// The location the lock was raised on, or null when the offer was reached
  /// with nowhere to go back to.
  final String? returnTo;

  @override
  Widget build(BuildContext context) => PaywallScreen(
    // The celebration takes the same return, so *Back to learning* lands on
    // the lock's screen with the lock gone.
    onPurchased: () => context.goNamed(
      AppRoutes.purchaseWelcome.name,
      queryParameters: returnTo == null ? const {} : welcomeReturnTo(returnTo!),
    ),
    // A recovery is not a sale: no celebration, back to where the lock was.
    onRestored: () => _back(context),
    onDeclined: () => _back(context),
  );

  void _back(BuildContext context) {
    final back = returnTo;
    if (back == null) {
      context.goNamed(AppRoutes.learn.name);
    } else {
      context.go(back);
    }
  }
}
