import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/config/app_links_provider.dart';
import 'package:brew_path/core/widgets/link_button.dart';
import 'package:brew_path/features/monetization/presentation/legal_links.dart';
import 'package:brew_path/services/links/link_opener.dart';
import 'package:brew_path/services/links/link_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

LinkButton _link(WidgetTester tester, String label) =>
    tester.widget<LinkButton>(
      find.ancestor(of: find.text(label), matching: find.byType(LinkButton)),
    );

/// Records what a link asked the platform to open.
class _RecordingOpener implements LinkOpener {
  final List<Uri> opened = [];

  @override
  Future<bool> open(Uri target) async {
    opened.add(target);
    return true;
  }
}

void main() {
  late _RecordingOpener opener;

  setUp(() => opener = _RecordingOpener());

  Future<void> pump(
    WidgetTester tester, {
    Widget? leading,
    Uri? terms,
    Uri? privacy,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          termsPageProvider.overrideWithValue(terms),
          privacyPageProvider.overrideWithValue(privacy),
          linkOpenerProvider.overrideWithValue(opener),
        ],
        child: MaterialApp(
          theme: AppTheme.cupping,
          home: Scaffold(
            body: LegalLinks(
              termsLabel: 'Terms',
              privacyLabel: 'Privacy',
              leading: leading,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('draws both links even while they have nowhere to go', (
    tester,
  ) async {
    // On a buying surface their absence is a store-review failure, so an
    // inert link is the lesser of the two (#448).
    await pump(tester);

    expect(find.text('Terms'), findsOneWidget);
    expect(find.text('Privacy'), findsOneWidget);
  });

  testWidgets('leaves them disabled while no page is hosted', (tester) async {
    await pump(tester);

    expect(_link(tester, 'Terms').onPressed, isNull);
    expect(_link(tester, 'Privacy').onPressed, isNull);
  });

  testWidgets('goes live the moment a page is hosted', (tester) async {
    // Falsifies the test above: it would pass on a widget that never read the
    // destinations at all.
    final page = Uri.parse('https://brewpath.app/terms');
    await pump(tester, terms: page);

    expect(_link(tester, 'Terms').onPressed, isNotNull);
    expect(_link(tester, 'Privacy').onPressed, isNull);

    await tester.tap(find.text('Terms'));
    await tester.pumpAndSettle();

    expect(opener.opened.single, page);
  });

  testWidgets('carries a surface its own link first, when it has one', (
    tester,
  ) async {
    await pump(
      tester,
      leading: LinkButton(label: 'Restore', onPressed: () {}),
    );

    final labels = tester
        .widgetList<LinkButton>(find.byType(LinkButton))
        .map((button) => button.label)
        .toList();

    expect(labels, ['Restore', 'Terms', 'Privacy']);
  });

  testWidgets('is one wrap, so a long label never clips a required link', (
    tester,
  ) async {
    await pump(tester);

    expect(find.byType(Wrap), findsOneWidget);
  });
}
