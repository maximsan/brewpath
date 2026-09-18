import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/swipe/swipe_geometry.dart';
import 'package:brew_path/core/swipe/swipe_hint.dart';
import 'package:brew_path/core/swipe/swipe_hint_caption.dart';
import 'package:brew_path/core/swipe/swipe_hint_timing.dart';
import 'package:brew_path/core/swipe/swipe_surface.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

const Key _cardKey = Key('card');
const String _label = 'Swipe to save';

/// The hint's state as the last build handed it over.
SwipeHintState? _handedOver;

Widget _app({bool reduceMotion = false, bool enabled = true}) => ProviderScope(
  child: MaterialApp(
    theme: AppTheme.darkRoast,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(
        body: Center(
          child: SwipeHint(
            surface: SwipeSurface.dictionary,
            enabled: enabled,
            builder: (context, hint) {
              _handedOver = hint;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwipeNudge(
                    offset: hint.offset,
                    child: const SizedBox(
                      key: _cardKey,
                      width: 200,
                      height: 100,
                    ),
                  ),
                  SwipeHintCaption(
                    show: hint.showing,
                    label: _label,
                    aim: SwipeAim.back,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  ),
);

double _cardLeft(WidgetTester tester) =>
    tester.getTopLeft(find.byKey(_cardKey)).dx;

Future<void> _openAndResolve(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(app);
  await settleLoaders(tester);
}

void main() {
  setUp(() async {
    _handedOver = null;
    await useInMemoryDatabase();
  });

  testWidgets('the caption comes up on a gesture never used', (tester) async {
    await _openAndResolve(tester, _app());
    await tester.pump();

    expect(_handedOver!.used, isFalse);
    expect(_handedOver!.showing, isTrue);
    expect(find.text(_label.toUpperCase()), findsOneWidget);
  });

  testWidgets('the element nudges twice, then settles', (tester) async {
    await _openAndResolve(tester, _app());
    await tester.pump();
    final centre = _cardLeft(tester);
    final steps = swipeNudgeSteps(-34);
    var elapsed = Duration.zero;
    final handed = <double>[];

    for (final step in steps) {
      await tester.pump(step.at - elapsed);
      elapsed = step.at;
      handed.add(_handedOver!.offset);
    }

    expect(handed, steps.map((step) => step.offset));
    await tester.pumpAndSettle();
    expect(_cardLeft(tester), centre);

    await tester.pump(swipeHintDuration - elapsed);
    expect(_handedOver!.showing, isFalse);
  });

  testWidgets('using the gesture stops the hint at once, and for good', (
    tester,
  ) async {
    await _openAndResolve(tester, _app());
    await tester.pump();
    expect(_handedOver!.showing, isTrue);

    _handedOver!.markUsed();
    await tester.pump();

    expect(_handedOver!.showing, isFalse);
    expect(_handedOver!.used, isTrue);
    expect(_handedOver!.offset, 0);

    await settleLoaders(tester);
    final stored = await SettingsRepository().getSettings();
    expect(SwipesUsed.decode(stored.swipesUsed), {SwipeSurface.dictionary.id});
  });

  testWidgets('a surface already used is never hinted again', (tester) async {
    final repository = SettingsRepository();
    final settings = await repository.getSettings();
    settings.swipesUsed = SwipesUsed.withSurface('', SwipeSurface.dictionary);
    await repository.saveSettings(settings);

    await _openAndResolve(tester, _app());
    await tester.pump(swipeHintDuration);

    expect(_handedOver!.used, isTrue);
    expect(_handedOver!.showing, isFalse);
  });

  testWidgets('a surface with nothing to teach yet stays quiet', (
    tester,
  ) async {
    await _openAndResolve(tester, _app(enabled: false));
    await tester.pump(swipeHintDuration);

    expect(_handedOver!.showing, isFalse);
  });

  testWidgets('reduced motion keeps the caption and drops the nudge', (
    tester,
  ) async {
    await _openAndResolve(tester, _app(reduceMotion: true));
    await tester.pump();
    final centre = _cardLeft(tester);

    expect(_handedOver!.showing, isTrue);
    await tester.pump(const Duration(milliseconds: 2100));

    expect(_handedOver!.offset, 0);
    expect(_cardLeft(tester), centre);
    await tester.pump(swipeHintReducedDuration);
    expect(_handedOver!.showing, isFalse);
  });

  testWidgets('an unresolved read counts as used, so nothing flashes bright', (
    tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(_handedOver!.used, isTrue);
    expect(_handedOver!.showing, isFalse);
    await settleLoaders(tester);
  });
}
