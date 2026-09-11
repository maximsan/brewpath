import 'package:brew_path/core/config/app_links.dart';
import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/core/widgets/sub_header.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_destinations.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_sub_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

/// The kicker is rendered uppercase, so it is found by what it was given
/// rather than by what it draws.
final Finder _tagline = find.byWidgetPredicate(
  (widget) =>
      widget is SmallcapsLabel && widget.text == SettingsCopy.aboutTagline,
);

void main() {
  setUp(useInMemoryDatabase);

  /// Bounded pumps rather than `pumpAndSettle`: About mounts Roasty, whose
  /// idle animation never ends.
  Future<void> pump(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: screen)),
    );
    await tester.pump();
    for (var attempt = 0; attempt < 30; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty &&
          attempt >= 2) {
        break;
      }
    }
  }

  testWidgets('opens on the app, not on the row that reached it', (
    tester,
  ) async {
    await pump(tester, const AboutScreen());

    expect(find.byType(Roasty), findsOneWidget);
    expect(find.text(AppLabels.appName), findsOneWidget);
    expect(_tagline, findsOneWidget);
    expect(
      find.byType(SettingsScreenHeading),
      findsNothing,
      reason: 'the page is about the app, so About is not its heading',
    );
  });

  testWidgets('keeps About in the bar, as every page behind Settings does', (
    tester,
  ) async {
    await pump(tester, const AboutScreen());

    expect(
      tester.widget<SubHeader>(find.byType(SubHeader)).title,
      SettingsCopy.aboutTitle,
    );
  });

  testWidgets('centres the mascot, the name and the tagline as one block', (
    tester,
  ) async {
    await pump(tester, const AboutScreen());

    final centres = [
      tester.getCenter(find.byType(Roasty)).dx,
      tester.getCenter(find.text(AppLabels.appName)).dx,
      tester.getCenter(_tagline).dx,
    ];

    for (final centre in centres) {
      expect(centre, moreOrLessEquals(centres.first, epsilon: 0.5));
    }
  });

  testWidgets('the other screens behind Settings still open on their name', (
    tester,
  ) async {
    // About is the one that wants a different opening; the frame it shares
    // with the other three is unchanged.
    await pump(tester, const AccountSyncScreen());

    expect(find.byType(SettingsScreenHeading), findsOneWidget);
    expect(
      tester
          .widget<SettingsScreenHeading>(find.byType(SettingsScreenHeading))
          .title,
      SettingsCopy.accountSyncTitle,
    );
  });

  testWidgets('draws no legal row while neither page is hosted', (
    tester,
  ) async {
    // #448 owns the two URLs; until they exist the rows are absent rather
    // than drawn live and inert, and the placeholder still names them.
    await pump(tester, const AboutScreen());

    expect(SupportLinks.terms, isNull, reason: '#448 has no URLs yet');
    expect(SupportLinks.privacy, isNull, reason: '#448 has no URLs yet');
    expect(find.byType(SettingsNavRow), findsNothing);
    expect(find.text(SettingsCopy.aboutComing), findsOneWidget);
  });
}
