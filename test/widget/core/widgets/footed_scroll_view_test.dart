import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/footed_scroll_view.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const ValueKey<String> _footerKey = ValueKey('footer');
const Size _viewport = Size(400, 800);

void main() {
  Future<void> pump(WidgetTester tester, List<Widget> children) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.cupping,
        home: Scaffold(
          body: FootedScrollView(
            scrollPadding: const EdgeInsets.only(top: 100),
            footer: const SizedBox(key: _footerKey, height: 40),
            children: children,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a page shorter than the screen closes at the bottom of it', (
    tester,
  ) async {
    await pump(tester, [const SizedBox(height: 120)]);

    final footer = tester.getRect(find.byKey(_footerKey));
    expect(
      footer.bottom,
      greaterThan(_viewport.height - 100),
      reason:
          'the footer sits at the foot of the screen, not under the '
          'content it happens to follow',
    );
    expect(footer.bottom, lessThanOrEqualTo(_viewport.height));
  });

  testWidgets('a page taller than the screen pushes the footer below it', (
    tester,
  ) async {
    await pump(tester, [const SizedBox(height: 2000)]);

    expect(
      find.byKey(_footerKey).hitTestable(),
      findsNothing,
      reason: 'the footer is past the fold until the page is scrolled',
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
    await tester.pump();

    expect(find.byKey(_footerKey), findsOneWidget);
  });

  testWidgets('the content keeps the room the bar leaves above it', (
    tester,
  ) async {
    const content = ValueKey('content');
    await pump(tester, [const SizedBox(key: content, height: 120)]);

    expect(tester.getRect(find.byKey(content)).top, 100);
  });
}
