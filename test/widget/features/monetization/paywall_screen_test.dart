import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/core/widgets/link_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/features/monetization/domain/plus_purchase_controller.dart';
import 'package:brew_path/features/monetization/presentation/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

// The offer as a screen: what it says, the two ways out, and the store chrome
// a non-consumable may not ship without.
void main() {
  setUp(useInMemoryDatabase);

  const pitch = PlusPitch(
    remainingLessons: 29,
    lockedGames: 4,
    referenceTerms: 8,
    savedFreeCap: 5,
  );

  late List<String> exits;

  setUp(() => exits = []);

  Future<ProviderContainer> pump(WidgetTester tester) async {
    // Tall enough to hold the whole offer: the body is a lazy list, so a
    // default-sized surface never builds the note or the store links, and an
    // assertion about them would be about the viewport rather than the screen.
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [plusPitchProvider.overrideWith((ref) async => pitch)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.cupping,
          home: PaywallScreen(
            onPurchased: () => exits.add('purchased'),
            onRestored: () => exits.add('restored'),
            onDeclined: () => exits.add('declined'),
          ),
        ),
      ),
    );
    await tester.pump();
    return container;
  }

  Future<void> tapAction(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets("offers the course on the design's own terms", (tester) async {
    await pump(tester);

    expect(find.text(PlusCopy.screenTitle), findsOneWidget);
    expect(find.text(PlusCopy.screenNote), findsOneWidget);
    // Smallcaps is the eyebrow's type rule, so it renders the copy uppercased.
    expect(
      find.textContaining(PlusCopy.screenEyebrow.toUpperCase()),
      findsOneWidget,
    );
  });

  testWidgets('ranks the same counted pitch every gate does', (tester) async {
    await pump(tester);

    for (final bullet in PlusCopy.bulletsFor(pitch)) {
      expect(find.text(bullet.title), findsOneWidget);
      expect(find.text(bullet.body), findsOneWidget);
    }
  });

  testWidgets('sells one thing — no plan chooser, no trial', (tester) async {
    await pump(tester);

    expect(find.byType(PrimaryButton), findsOneWidget);
    expect(find.byType(Radio<Object>), findsNothing);
    expect(find.textContaining('trial', findRichText: true), findsNothing);
    expect(find.textContaining('/month'), findsNothing);
  });

  testWidgets('carries Restore, Terms and Privacy', (tester) async {
    await pump(tester);

    expect(find.text(PlusCopy.restore), findsOneWidget);
    expect(find.text(PlusCopy.terms), findsOneWidget);
    expect(find.text(PlusCopy.privacy), findsOneWidget);
  });

  testWidgets('Terms and Privacy are drawn but inert until #448', (
    tester,
  ) async {
    await pump(tester);

    for (final label in [PlusCopy.terms, PlusCopy.privacy]) {
      final link = tester.widget<LinkButton>(
        find.ancestor(of: find.text(label), matching: find.byType(LinkButton)),
      );
      expect(link.onPressed, isNull, reason: '$label has no URL yet');
    }
  });

  testWidgets('Maybe later leaves without buying', (tester) async {
    await pump(tester);

    await tapAction(tester, PlusCopy.maybeLater);

    expect(exits, ['declined']);
  });

  testWidgets('buying leaves by the bought door', (tester) async {
    final container = await pump(tester);

    container.read(plusPurchaseProvider.notifier).state =
        PlusPurchaseState.owned;
    await tester.pump();

    expect(exits, ['purchased']);
  });

  testWidgets('restoring leaves by its own door, not the sale', (tester) async {
    final container = await pump(tester);

    await tapAction(tester, PlusCopy.restore);
    container.read(plusPurchaseProvider.notifier).state =
        PlusPurchaseState.owned;
    await tester.pump();

    expect(
      exits,
      ['restored'],
      reason: 'recovering a purchase is not a sale to celebrate',
    );
  });

  testWidgets('a restore that finds nothing says so', (tester) async {
    final container = await pump(tester);

    container.read(plusPurchaseProvider.notifier).state =
        PlusPurchaseState.nothingToRestore;
    await tester.pump();

    expect(find.text(PlusCopy.nothingToRestore), findsOneWidget);
    expect(exits, isEmpty);
  });

  testWidgets('a refusal leaves the learner on the offer, and says so', (
    tester,
  ) async {
    final container = await pump(tester);

    container.read(plusPurchaseProvider.notifier).state =
        PlusPurchaseState.failed;
    await tester.pump();

    expect(find.text(PlusCopy.failed), findsOneWidget);
    expect(exits, isEmpty);
  });

  testWidgets('the store cannot be asked twice while it is deciding', (
    tester,
  ) async {
    final container = await pump(tester);

    container.read(plusPurchaseProvider.notifier).state =
        PlusPurchaseState.working;
    await tester.pump();

    expect(
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
      isNull,
    );
    expect(
      tester.widget<GhostButton>(find.byType(GhostButton)).onPressed,
      isNull,
    );
  });

  testWidgets('the close stays live, so it is never a dead control', (
    tester,
  ) async {
    final container = await pump(tester);

    container.read(plusPurchaseProvider.notifier).state =
        PlusPurchaseState.working;
    await tester.pump();

    await tester.tap(find.byTooltip(PlusCopy.close));
    await tester.pump();

    expect(exits, ['declined']);
  });
}
