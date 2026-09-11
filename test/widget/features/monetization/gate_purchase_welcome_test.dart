import 'package:brew_path/app/app.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/monetization/config/paywall_copy.dart';
import 'package:brew_path/features/monetization/domain/free_tier.dart';
import 'package:brew_path/features/monetization/domain/locked_row_copy.dart';
import 'package:brew_path/features/monetization/presentation/purchase_welcome_screen.dart';
import 'package:brew_path/services/payments/payments_provider.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/find_mark.dart';
import '../../../support/progress_seed.dart';
import '../../../support/selling_payments_service.dart';
import '../../../support/widget_harness.dart';

// The whole way a sale made at a lock travels, against the real app: the Path
// row that raised the offer, the celebration it lands on, and the row it comes
// back to with the wall gone.
void main() {
  setUp(useInMemoryDatabase);

  /// The first lesson the free tier does not carry. `course_wall_test.dart`
  /// guards it against the shipped bank, and fails loudly if the bank moves.
  const firstPaidTitle = 'Why altitude matters';

  /// Advances without settling: the celebration draws the mascot, whose idle
  /// loop never ends, so `pumpAndSettle` would never return once it is up.
  Future<void> pumpAlong(WidgetTester tester) async {
    for (var i = 0; i < 15; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 60));
    }
  }

  testWidgets('a sale at a locked Path lesson lands on the welcome, and comes '
      'back to the row with the wall gone', (tester) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final semantics = tester.ensureSemantics();

    await seedCompletedLessons(SnapshotRepository(), freeLessonIds);

    final container = ProviderContainer(
      overrides: [
        paymentsServiceProvider.overrideWith((ref) => SellingPaymentsService()),
      ],
    );
    await pumpWithProviders(tester, const BrewPathApp(), container: container);

    await tester.tap(findMark(AppIcon.route, active: false));
    await settleLoaders(tester);

    final lockedRow = find.bySemanticsLabel(
      LockedRowCopy.purchaseLockedSemantics(firstPaidTitle),
    );
    expect(lockedRow, findsOneWidget);

    await tester.tap(find.text(firstPaidTitle));
    await settleLoaders(tester);
    expect(find.text(PaywallCopy.gateTitle), findsOneWidget);

    await tester.tap(find.byType(PrimaryButton));
    await pumpAlong(tester);

    expect(find.byType(PurchaseWelcomeScreen), findsOneWidget);
    expect(find.text(PaywallCopy.gateTitle), findsNothing);

    await tester.tap(find.text(PaywallCopy.welcomeBackToLearning));
    await pumpAlong(tester);

    // Back on the Path, where the offer was raised — not on Learn — and the
    // row that raised it is a lesson again.
    expect(find.byType(PurchaseWelcomeScreen), findsNothing);
    expect(find.text(firstPaidTitle), findsOneWidget);
    expect(lockedRow, findsNothing);
    semantics.dispose();
  });
}
