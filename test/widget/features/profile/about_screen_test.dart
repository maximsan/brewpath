import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/config/app_links.dart';
import 'package:brew_path/core/config/app_links_provider.dart';
import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/core/widgets/sub_header.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/profile/domain/support_links.dart';
import 'package:brew_path/features/profile/presentation/settings/about_screen.dart';
import 'package:brew_path/features/profile/presentation/settings/account_sync_screen.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_sub_screen.dart';
import 'package:brew_path/services/links/link_opener.dart';
import 'package:brew_path/services/links/link_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/settings_finders.dart';
import '../../../support/widget_harness.dart';

/// The kicker is rendered uppercase, so it is found by what it was given
/// rather than by what it draws.
final Finder _tagline = find.byWidgetPredicate(
  (widget) =>
      widget is SmallcapsLabel && widget.text == SettingsCopy.aboutTagline,
);

/// Records what a row asked the platform to open.
class _RecordingOpener implements LinkOpener {
  final List<Uri> opened = [];

  @override
  Future<bool> open(Uri target) async {
    opened.add(target);
    return true;
  }
}

void main() {
  setUp(useInMemoryDatabase);

  late _RecordingOpener opener;

  setUp(() => opener = _RecordingOpener());

  /// Bounded pumps rather than `pumpAndSettle`: About mounts Roasty, whose
  /// idle animation never ends.
  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    Uri? privacy,
    Uri? terms,
    String? mailbox,
    String? appStoreId,
  }) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          linkOpenerProvider.overrideWithValue(opener),
          if (privacy != null) privacyPageProvider.overrideWithValue(privacy),
          if (terms != null) termsPageProvider.overrideWithValue(terms),
          if (mailbox != null)
            supportMailboxProvider.overrideWithValue(mailbox),
          if (appStoreId != null)
            appStoreReviewProvider.overrideWithValue(reviewPage(appStoreId)),
        ],
        child: MaterialApp(theme: AppTheme.cupping, home: screen),
      ),
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

  testWidgets("draws the app's own two fine-print rows whatever is hosted", (
    tester,
  ) async {
    await pump(tester, const AboutScreen());

    expect(settingsRow(SettingsCopy.acknowledgementsRow), findsOneWidget);
    expect(settingsRow(SettingsCopy.licensesRow), findsOneWidget);
  });

  testWidgets('draws no legal row while neither page is hosted', (
    tester,
  ) async {
    // #448 owns the two URLs; until they exist the rows are absent rather
    // than drawn live and inert.
    await pump(tester, const AboutScreen());

    expect(SupportLinks.terms, isNull, reason: '#448 has no URLs yet');
    expect(SupportLinks.privacy, isNull, reason: '#448 has no URLs yet');
    expect(settingsRow(SettingsCopy.termsRow), findsNothing);
    expect(settingsRow(SettingsCopy.privacyRow), findsNothing);
  });

  testWidgets('draws Privacy above Terms once both are hosted', (tester) async {
    await pump(
      tester,
      const AboutScreen(),
      privacy: Uri.parse('https://brewpath.example/privacy'),
      terms: Uri.parse('https://brewpath.example/terms'),
    );

    expect(
      tester.getTopLeft(settingsRow(SettingsCopy.privacyRow)).dy,
      lessThan(tester.getTopLeft(settingsRow(SettingsCopy.termsRow)).dy),
      reason: 'the design orders the fine print Privacy, Terms',
    );
  });

  testWidgets('draws no Say something group while there is no mailbox', (
    tester,
  ) async {
    await pump(tester, const AboutScreen());

    expect(settingsRow(SettingsCopy.sayHelloRow), findsNothing);
    expect(settingsSection(SettingsCopy.saySomethingSection), findsNothing);
  });

  testWidgets('says hello once there is a mailbox, and opens a composer to '
      'it', (tester) async {
    await pump(tester, const AboutScreen(), mailbox: 'hi@brewpath.app');

    expect(settingsRow(SettingsCopy.sayHelloRow), findsOneWidget);
    expect(find.text('hi@brewpath.app'), findsOneWidget);

    await tester.tap(settingsRow(SettingsCopy.sayHelloRow));
    expect(opener.opened, [Uri.parse('mailto:hi@brewpath.app')]);
  });

  testWidgets('draws no Rate BrewPath while there is no listing to rate', (
    tester,
  ) async {
    // The row is absent, not inert: with no App Store id there is nowhere
    // for it to go (#532, ruling 4).
    await pump(tester, const AboutScreen(), mailbox: 'hi@brewpath.app');

    expect(SupportLinks.appStoreId, isNull, reason: 'no listing exists yet');
    expect(settingsRow(SettingsCopy.rateRow), findsNothing);
    expect(settingsSection(SettingsCopy.saySomethingSection), findsOneWidget);
  });

  testWidgets('rates BrewPath once a listing exists, above Say hello', (
    tester,
  ) async {
    await pump(tester, const AboutScreen(), appStoreId: '6448123456');

    expect(settingsRow(SettingsCopy.rateRow), findsOneWidget);

    await tester.tap(settingsRow(SettingsCopy.rateRow));
    expect(opener.opened, [reviewPage('6448123456')]);
  });

  testWidgets('closes on the build as well as the version, over the '
      'signature', (tester) async {
    // The design writes About's close as two lines where Settings writes
    // one: the build number is for whoever is reading a crash report.
    await pump(tester, const AboutScreen());

    expect(find.text('VERSION 1.0.0 · BUILD 1'), findsOneWidget);
    expect(
      find.text(SettingsCopy.aboutSignature.toUpperCase()),
      findsOneWidget,
    );
  });
}
