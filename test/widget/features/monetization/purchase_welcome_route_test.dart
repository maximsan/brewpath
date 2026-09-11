import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/monetization/config/paywall_config.dart';
import 'package:brew_path/features/monetization/domain/purchased_term.dart';
import 'package:brew_path/features/monetization/presentation/purchase_welcome_route.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// The celebration says what was bought: the route reads the term the paywall
// recorded, and reads as the one-time purchase when nothing was.
void main() {
  Future<void> pump(WidgetTester tester, {PlusTerm? recorded}) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    if (recorded != null) {
      container.read(purchasedTermProvider.notifier).term = recorded;
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.cupping,
          home: const PurchaseWelcomeRoute(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('celebrates the plan the paywall recorded', (tester) async {
    await pump(tester, recorded: PlusTerm.monthly);

    final monthly = paywallPlans[PlusTerm.monthly]!;
    expect(find.text(monthly.welcome), findsOneWidget);
    expect(find.text(monthly.welcomeNote.toUpperCase()), findsOneWidget);
  });

  testWidgets('with nothing recorded, it reads as the one-time purchase', (
    tester,
  ) async {
    await pump(tester);

    final lifetime = paywallPlans[PlusTerm.lifetime]!;
    expect(find.text(lifetime.welcome), findsOneWidget);
    expect(find.text(lifetime.welcomeNote.toUpperCase()), findsOneWidget);
  });
}
