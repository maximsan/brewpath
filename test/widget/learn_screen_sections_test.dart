import 'package:brew_path/app/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  /// Tall enough to build every section — a `ListView` only builds what fits,
  /// and the lower sections sit well below a phone's viewport.
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('the Learn screen shows its four sections in order', (
    tester,
  ) async {
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());
    // Learn is the initial tab — no nav needed.

    for (final section in const [
      "Today's lesson",
      'Practice any lesson',
      'Mini-games',
      'Modules',
    ]) {
      expect(find.text(section), findsOneWidget, reason: section);
    }
  });

  testWidgets('no section offers practice by game type', (tester) async {
    // The cross-lesson drill is gone (#113): a screen the design never had,
    // assembled from whatever the learner happened to finish, recording
    // nothing. The seven authored mini-games cover the same ground.
    useTallViewport(tester);

    await pumpWithProviders(tester, const BrewPathApp());

    expect(find.text('Practice by game type'), findsNothing);
  });
}
