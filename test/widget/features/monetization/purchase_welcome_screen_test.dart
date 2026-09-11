import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/monetization/config/paywall_config.dart';
import 'package:brew_path/features/monetization/config/paywall_copy.dart';
import 'package:brew_path/features/monetization/presentation/purchase_welcome_screen.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The beat after a purchase: what it says, and that both its doors go forward.
void main() {
  late List<String> taken;

  setUp(() => taken = []);

  Future<void> pump(
    WidgetTester tester, {
    PlusTerm term = PlusTerm.lifetime,
  }) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.cupping,
        home: PurchaseWelcomeScreen(
          plan: paywallPlans[term]!,
          onOpenStudio: () => taken.add('studio'),
          onContinue: () => taken.add('continue'),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('says what was bought, once', (tester) async {
    await pump(tester);

    final lifetime = paywallPlans[PlusTerm.lifetime]!;
    expect(find.text(PaywallCopy.welcomeTitle), findsOneWidget);
    expect(find.text(lifetime.welcome), findsOneWidget);
    expect(find.text(lifetime.welcomeNote.toUpperCase()), findsOneWidget);
  });

  testWidgets('a subscriber is told what a subscription is', (
    tester,
  ) async {
    await pump(tester, term: PlusTerm.yearly);

    final yearly = paywallPlans[PlusTerm.yearly]!;
    expect(find.text(yearly.welcome), findsOneWidget);
    expect(find.text(yearly.welcomeNote.toUpperCase()), findsOneWidget);
    expect(
      find.text(paywallPlans[PlusTerm.lifetime]!.welcomeNote.toUpperCase()),
      findsNothing,
    );
  });

  testWidgets('offers the Studio first, and the app after it', (tester) async {
    await pump(tester);

    await tester.tap(find.text(PaywallCopy.welcomeOpenStudio));
    await tester.pump();
    expect(taken, ['studio']);

    await tester.tap(find.text(PaywallCopy.welcomeBackToLearning));
    await tester.pump();
    expect(taken, ['studio', 'continue']);
  });

  testWidgets('has no way back to the offer', (tester) async {
    await pump(tester);

    expect(find.byType(BackButton), findsNothing);
    expect(find.text(PaywallCopy.maybeLater), findsNothing);
    expect(find.text(PaywallCopy.restore), findsNothing);
  });
}
