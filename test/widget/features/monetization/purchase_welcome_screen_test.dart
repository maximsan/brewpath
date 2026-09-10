import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/monetization/presentation/purchase_welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The beat after a purchase: what it says, and that both its doors go forward.
void main() {
  late List<String> taken;

  setUp(() => taken = []);

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.cupping,
        home: PurchaseWelcomeScreen(
          onOpenStudio: () => taken.add('studio'),
          onContinue: () => taken.add('continue'),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('says what was bought, once', (tester) async {
    await pump(tester);

    expect(find.text(PlusCopy.welcomeTitle), findsOneWidget);
    expect(find.text(PlusCopy.welcomeBody), findsOneWidget);
    expect(find.text(PlusCopy.welcomeNote), findsOneWidget);
  });

  testWidgets('offers the Studio first, and the app after it', (tester) async {
    await pump(tester);

    await tester.tap(find.text(PlusCopy.welcomeOpenStudio));
    await tester.pump();
    expect(taken, ['studio']);

    await tester.tap(find.text(PlusCopy.welcomeBackToLearning));
    await tester.pump();
    expect(taken, ['studio', 'continue']);
  });

  testWidgets('has no way back to the offer', (tester) async {
    await pump(tester);

    expect(find.byType(BackButton), findsNothing);
    expect(find.text(PlusCopy.buy), findsNothing);
    expect(find.text(PlusCopy.maybeLater), findsNothing);
  });
}
