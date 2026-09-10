import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/config/support_contact.dart';
import 'package:brew_path/core/widgets/link_button.dart';
import 'package:brew_path/features/monetization/presentation/legal_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

LinkButton _link(WidgetTester tester, String label) =>
    tester.widget<LinkButton>(
      find.ancestor(of: find.text(label), matching: find.byType(LinkButton)),
    );

void main() {
  Future<void> pump(WidgetTester tester, {Widget? leading}) async {
    await tester.pumpWidget(
      ProviderScope(
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

  testWidgets('the constants are still unset, which is what disables them', (
    tester,
  ) async {
    // Falsifies the test above: it would pass on a widget that ignored the
    // constants entirely, so the reason for the nulls is asserted too.
    expect(termsUrl, isNull, reason: '#448 has not been given URLs yet');
    expect(privacyUrl, isNull, reason: '#448 has not been given URLs yet');
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
