import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/monetization/config/paywall_config.dart';
import 'package:brew_path/features/monetization/config/paywall_copy.dart';
import 'package:brew_path/features/monetization/domain/paywall_view.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/features/monetization/domain/purchase_welcome_return.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:brew_path/features/monetization/presentation/purchase_welcome_route.dart';
import 'package:brew_path/services/payments/payments_provider.dart';
import 'package:brew_path/services/payments/payments_service.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/selling_payments_service.dart';
import '../../../support/widget_harness.dart';

// The sheet a lock raises: what it says, the one way to buy, the way to
// decline, and what it refuses to offer.
void main() {
  setUp(useInMemoryDatabase);

  /// A counted pitch, so the sheet's assertions do not wait on the banks.
  const pitch = PlusPitch(
    premiumFormats: 4,
    firstPaidModule: 2,
    lastPaidModule: 5,
    remainingLessons: 29,
    lockedGames: 4,
    referenceTerms: 8,
    savedFreeCap: 5,
  );

  late GoRouter router;

  /// Raises the sheet on the Path tab, over a router carrying the celebration
  /// a sale lands on — the sheet navigates, so a stub `home:` cannot host it.
  Future<void> openWith(
    WidgetTester tester,
    PlusGateTrigger trigger, {
    PaymentsService? store,
  }) async {
    // Tall enough that the whole sheet is on screen: it scrolls at the default
    // size, and Restore sits under the fold where a tap cannot reach it.
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        plusPitchProvider.overrideWith((ref) async => pitch),
        if (store != null) paymentsServiceProvider.overrideWith((ref) => store),
      ],
    );
    addTearDown(container.dispose);

    router = GoRouter(
      initialLocation: AppRoutes.path.path,
      routes: [
        GoRoute(
          path: AppRoutes.path.path,
          name: AppRoutes.path.name,
          builder: (_, _) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showPlusGate(context, trigger),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.purchaseWelcome.path,
          name: AppRoutes.purchaseWelcome.name,
          builder: (_, state) =>
              PurchaseWelcomeRoute(returnTo: welcomeReturnIn(state.uri)),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.cupping,
          routerConfig: router,
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('it opens on what was just hit', (tester) async {
    await openWith(tester, const SavedShelfFull(cap: 5));

    // The header leads, above the pitch — the sheet answers the question the
    // learner asked rather than a generic one.
    expect(find.text('Your free shelf is full at 5.'), findsOneWidget);
    expect(find.text(PaywallCopy.gateTitle), findsOneWidget);
  });

  testWidgets('a locked game names the module that teaches it', (tester) async {
    await openWith(tester, const LockedGame(moduleTitle: 'Roasting'));

    expect(find.text('Taught in Roasting.'), findsOneWidget);
  });

  testWidgets('a locked lesson names the lesson', (tester) async {
    await openWith(tester, const LockedLesson(title: 'Why altitude matters'));

    expect(
      find.text('"Why altitude matters" is part of the full course.'),
      findsOneWidget,
    );
  });

  testWidgets('the pitch is ranked, course first', (tester) async {
    await openWith(tester, const SavedShelfFull(cap: 5));

    final bullets = PaywallCopy.bulletsFor(pitch);
    final positions = [
      for (final bullet in bullets)
        tester.getTopLeft(find.text(bullet.title)).dy,
    ];
    expect(
      positions,
      orderedEquals(<double>[...positions]..sort()),
      reason: 'the course must sit above practice, and practice above skins',
    );
    expect(find.textContaining('29 more lessons'), findsOneWidget);
  });

  testWidgets('there is exactly one way to buy', (tester) async {
    await openWith(tester, const SavedShelfFull(cap: 5));

    // The store is not stubbed here, so the CTA drops its price clause —
    // `Unlock Foundations — {price}` without a price is `Unlock Foundations`.
    expect(
      find.text(
        withPrice(paywallModels[MonetizationModel.oneTime]!.gateCta, null),
      ),
      findsOneWidget,
    );

    // The three things the design's sheet carries that v1 must not: an ad path,
    // a trial, and a plan chooser. Matched on whole words — this began as
    // `textContaining('ad')`, which passed by luck and would have fired on
    // *Loading*, *already* or *ahead*. A substring is the wrong shape for a
    // rule about vocabulary.
    final forbidden = RegExp(
      r'\b(ads?|advert\w*|trial|month(ly)?|year(ly)?|subscri\w+)\b',
      caseSensitive: false,
    );
    final onScreen = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data ?? '')
        .where(forbidden.hasMatch)
        .toList();

    expect(
      onScreen,
      isEmpty,
      reason:
          'v1 sells one non-consumable: no ad path, no trial, no plan '
          'chooser. Found: ${onScreen.join(' | ')}',
    );
  });

  testWidgets('Restore, Terms and Privacy are present', (tester) async {
    await openWith(tester, const SavedShelfFull(cap: 5));

    // The App Store requires all three of a non-consumable.
    expect(find.text(PaywallCopy.restore), findsOneWidget);
    expect(find.text(PaywallCopy.terms), findsOneWidget);
    expect(find.text(PaywallCopy.privacy), findsOneWidget);
  });

  testWidgets('declining is a button, not a swipe to discover', (tester) async {
    await openWith(tester, const SavedShelfFull(cap: 5));

    // The design puts a ghost under the buy action on every gate. The sheet
    // was always dismissible by the handle or the scrim; what was missing was
    // an exit the learner could see.
    expect(
      find.widgetWithText(GhostButton, PaywallCopy.notNow),
      findsOneWidget,
    );

    await tester.tap(find.text(PaywallCopy.notNow));
    await tester.pumpAndSettle();

    expect(find.text(PaywallCopy.gateTitle), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('dismissing changes nothing', (tester) async {
    await openWith(tester, const SavedShelfFull(cap: 5));

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text(PaywallCopy.gateTitle), findsNothing);
    // Back where they were, with nothing bought.
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('a sale closes the sheet and lands on the welcome', (
    tester,
  ) async {
    await openWith(
      tester,
      const SavedShelfFull(cap: 5),
      store: SellingPaymentsService(),
    );

    await tester.tap(find.byType(PrimaryButton));
    await pumpWithoutSettling(tester);

    expect(find.text(PaywallCopy.gateTitle), findsNothing);
    expect(find.text(PaywallCopy.welcomeTitle), findsOneWidget);

    // And it comes back to the screen the lock was on, not to Learn.
    await tester.tap(find.text(PaywallCopy.welcomeBackToLearning));
    await pumpWithoutSettling(tester);

    expect(router.state.uri.toString(), AppRoutes.path.path);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('a restore closes the sheet where it stands', (tester) async {
    await openWith(
      tester,
      const SavedShelfFull(cap: 5),
      store: SellingPaymentsService(restorable: true),
    );

    await tester.tap(find.text(PaywallCopy.restore));
    await pumpWithoutSettling(tester);

    // A recovery is not a sale: no celebration, and nowhere new to be.
    expect(find.text(PaywallCopy.gateTitle), findsNothing);
    expect(find.text(PaywallCopy.welcomeTitle), findsNothing);
    expect(router.state.uri.toString(), AppRoutes.path.path);
  });

  testWidgets('a restore that finds nothing leaves the sheet open', (
    tester,
  ) async {
    await openWith(
      tester,
      const SavedShelfFull(cap: 5),
      store: SellingPaymentsService(),
    );

    await tester.tap(find.text(PaywallCopy.restore));
    await pumpWithoutSettling(tester);

    expect(find.text(PaywallCopy.gateTitle), findsOneWidget);
    expect(find.text(PaywallCopy.nothingToRestore), findsOneWidget);
  });

  testWidgets('the sheet announces itself by name', (tester) async {
    final handle = tester.ensureSemantics();
    await openWith(tester, const SavedShelfFull(cap: 5));

    expect(find.bySemanticsLabel(PaywallCopy.gateTitle), findsWidgets);
    handle.dispose();
  });

  testWidgets('each bullet is heard as one item', (tester) async {
    final handle = tester.ensureSemantics();
    await openWith(tester, const SavedShelfFull(cap: 5));

    // Title and body merged: two fragments would lose the ranking that the
    // ordering exists to convey.
    for (final bullet in PaywallCopy.bulletsFor(pitch)) {
      expect(
        find.bySemanticsLabel('${bullet.title}. ${bullet.body}'),
        findsOneWidget,
      );
    }
    handle.dispose();
  });
}
