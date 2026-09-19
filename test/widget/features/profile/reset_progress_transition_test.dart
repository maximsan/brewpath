import 'package:brew_path/app/app.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/presentation/saved_screen.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/find_mark.dart';
import '../../../support/widget_harness.dart';

// The walk `saved_shelf_persistence_test.dart` deliberately does not make. It
// drives reset from a tab root instead, because the badge's subscription is
// paused while Settings covers the shell and flushes the reset's invalidation
// on resume, inside a build. That is #299, and the resume is the return to the
// badge's own tab — leaving Settings alone is not enough to provoke it.
void main() {
  setUp(useInMemoryDatabase);

  testWidgets('a reset survives the walk back to the badge it clears', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await toggleSaved(
      SnapshotRepository(),
      key: 't:arabica',
      now: DateTime(2026, 8, 23),
      isPlus: false,
      visible: 0,
    );

    await pumpWithProviders(tester, const BrewPathApp());
    expect(
      find.byTooltip('${SavedScreen.title}, 1 item'),
      findsOneWidget,
      reason: 'the badge is the standing consumer this turns on',
    );

    await tester.tap(findMark(AppIcon.leaf, active: false));
    await settleLoaders(tester);
    await tester.tap(findMark(AppIcon.gear));
    await settleLoaders(tester);

    await tester.tap(find.text(SettingsCopy.resetProgressRow));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Reset'));
    await tester.pumpAndSettle();

    await tester.tap(findMark(AppIcon.back));
    await tester.pumpAndSettle();
    await tester.tap(findMark(AppIcon.cup, active: false));
    await tester.pumpAndSettle();

    expect(
      find.byTooltip(SavedScreen.title),
      findsOneWidget,
      reason: 'the badge is a bare label again, with nothing saved',
    );
  });
}
