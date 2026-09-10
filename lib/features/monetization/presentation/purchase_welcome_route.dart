import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/monetization/presentation/purchase_welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Where the celebration's two doors lead.
///
/// The screen itself takes callbacks, so this is the only thing that knows the
/// app has a Studio and a Learn tab — the same split every other screen keeps.
class PurchaseWelcomeRoute extends StatelessWidget {
  /// Creates the route host.
  const PurchaseWelcomeRoute({super.key});

  @override
  Widget build(BuildContext context) => PurchaseWelcomeScreen(
    onOpenStudio: () => context.goNamed(AppRoutes.studio.name),
    onContinue: () => context.goNamed(AppRoutes.learn.name),
  );
}
