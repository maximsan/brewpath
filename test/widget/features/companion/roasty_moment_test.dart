import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/companion.dart';
import 'package:brew_path/features/companion/presentation/roasty_moment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

const String _eyebrow = 'Lesson complete';
const String _title = 'Perfect run!';

Widget _host(VoidCallback onDone, {bool reducedMotion = false}) =>
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: RoastyMoment(
            reaction: CompanionReaction.lessonComplete,
            eyebrow: _eyebrow,
            title: _title,
            onDone: onDone,
          ),
        ),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reducedMotion),
          child: child!,
        ),
      ),
    );

void main() {
  setUp(useInMemoryDatabase);

  testWidgets('shows the companion, the kicker and the headline', (
    tester,
  ) async {
    await tester.pumpWidget(_host(() {}, reducedMotion: true));
    await tester.pump();

    expect(find.byType(Companion), findsOneWidget);
    expect(find.text(_eyebrow.toUpperCase()), findsOneWidget);
    expect(find.text(_title), findsOneWidget);
  });

  testWidgets('hands over on its own when the hold is up', (tester) async {
    var done = 0;
    await tester.pumpWidget(_host(() => done++, reducedMotion: true));
    await tester.pump();
    expect(done, 0);

    await tester.pump(RoastyMoment.defaultHold);

    expect(done, 1);
  });

  // ⚠️ The rule the tree's growth is held to as well: a host sequences its
  // screen behind this callback, so stillness must not swallow it.
  testWidgets('hands over under reduced motion too', (tester) async {
    var done = 0;
    await tester.pumpWidget(_host(() => done++, reducedMotion: true));
    await tester.pump(RoastyMoment.defaultHold);

    expect(done, 1);
  });

  testWidgets('a tap ends it early', (tester) async {
    var done = 0;
    await tester.pumpWidget(_host(() => done++, reducedMotion: true));
    await tester.pump();

    await tester.tap(find.byType(RoastyMoment));

    expect(done, 1);
  });

  // The tap and the timer race by construction, and a host that rebuilds on
  // the callback would rebuild twice — or navigate twice — if both landed.
  testWidgets('a tap and the timer together still hand over once', (
    tester,
  ) async {
    var done = 0;
    await tester.pumpWidget(_host(() => done++, reducedMotion: true));
    await tester.pump();

    await tester.tap(find.byType(RoastyMoment));
    await tester.pump(RoastyMoment.defaultHold * 2);

    expect(done, 1);
  });

  testWidgets('a moment disposed mid-hold never calls back', (tester) async {
    var done = 0;
    await tester.pumpWidget(_host(() => done++, reducedMotion: true));
    await tester.pump();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(RoastyMoment.defaultHold * 2);

    expect(done, 0);
  });

  // One node for the whole beat, carrying both lines: a reader that met the
  // mascot, the kicker and the headline as three loose strings would not say
  // that any of it can be tapped past.
  testWidgets('it is announced as one tappable thing', (tester) async {
    await tester.pumpWidget(_host(() {}, reducedMotion: true));
    await tester.pump();

    final node = tester.getSemantics(
      find
          .descendant(
            of: find.byType(RoastyMoment),
            matching: find.byType(Semantics),
          )
          .first,
    );
    expect(node.label, contains(_title));
    expect(node.label, contains(_eyebrow));
    expect(node.flagsCollection.isButton, isTrue);
  });
}
