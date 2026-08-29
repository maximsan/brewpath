import 'package:brew_path/features/onboarding/presentation/welcome/sound_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester, {
  required bool muted,
  required VoidCallback onPressed,
  VoidCallback? onBackgroundTap,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBackgroundTap ?? () {},
          child: Center(
            child: SoundToggle(muted: muted, onPressed: onPressed),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('names what a press will do, not what is true now', (
    tester,
  ) async {
    await _pump(tester, muted: true, onPressed: () {});
    expect(
      tester.getSemantics(find.byType(SoundToggle)).label,
      'Turn sound on',
    );

    await _pump(tester, muted: false, onPressed: () {});
    expect(
      tester.getSemantics(find.byType(SoundToggle)).label,
      'Turn sound off',
    );
  });

  testWidgets('shows the state it is in', (tester) async {
    await _pump(tester, muted: true, onPressed: () {});
    expect(find.byIcon(Icons.volume_off), findsOneWidget);

    await _pump(tester, muted: false, onPressed: () {});
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
  });

  testWidgets('does not advance the screen it floats on', (tester) async {
    // Welcome advances on a tap anywhere. A control sitting inside that must
    // absorb its own press, or a learner reaching for the sound leaves the
    // screen instead.
    var toggled = 0;
    var advanced = 0;
    await _pump(
      tester,
      muted: true,
      onPressed: () => toggled++,
      onBackgroundTap: () => advanced++,
    );

    await tester.tap(find.byType(SoundToggle));
    await tester.pumpAndSettle();

    expect(toggled, 1);
    expect(advanced, 0, reason: 'the press must not reach the screen beneath');
  });
}
