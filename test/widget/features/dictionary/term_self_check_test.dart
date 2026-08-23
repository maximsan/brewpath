import 'package:brew_path/features/dictionary/presentation/term_self_check.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _check = DictionaryCheck(
  question: 'Arabica usually has…',
  choices: [
    Choice(text: 'More caffeine'),
    Choice(text: 'More sweetness', isCorrect: true),
  ],
  explanation: 'Arabica is prized for sweetness.',
);

Widget _harness({required bool disableAnimations}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: const Scaffold(body: TermSelfCheck(check: _check)),
  ),
);

void main() {
  for (final reduceMotion in [false, true]) {
    testWidgets(
      'answering explains itself, reduced motion: $reduceMotion',
      (tester) async {
        await tester.pumpWidget(_harness(disableAnimations: reduceMotion));
        expect(find.text('Arabica is prized for sweetness.'), findsNothing);

        await tester.tap(find.text('More caffeine'));
        await tester.pumpAndSettle();

        expect(find.text('Arabica is prized for sweetness.'), findsOneWidget);
        expect(
          tester.takeException(),
          isNull,
          reason: 'a wrong guess should still teach, not throw',
        );
      },
    );
  }
}
