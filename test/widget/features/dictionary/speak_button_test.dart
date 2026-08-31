import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_providers.dart';
import 'package:brew_path/features/dictionary/presentation/speak_button.dart';
import 'package:brew_path/features/dictionary/presentation/speaker_mark.dart';
import 'package:brew_path/features/dictionary/presentation/term_entry_body.dart';
import 'package:brew_path/services/speech/speech_providers.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_speech_service.dart';

const _beans = DictionaryCategory(
  id: 'beans',
  label: 'Beans and Botany',
  glyph: 'cherry',
  summary: 'The plant, the seed, where it grows.',
);

const _spoken = DictionaryTerm(
  id: 'arabica',
  term: 'Arabica',
  categoryId: 'beans',
  shortExplanation: 'The species behind most specialty coffee.',
  pronunciation: 'uh-RAB-ih-kuh',
);

const _silent = DictionaryTerm(
  id: 'tds',
  term: 'TDS',
  categoryId: 'beans',
  shortExplanation: 'Total dissolved solids.',
);

const _view = DictionaryView(
  terms: [_spoken, _silent],
  categories: [_beans],
  completedLessonIds: {},
);

Widget _wrap(DictionaryTerm term, FakeSpeechService speech) => ProviderScope(
  overrides: [speechServiceProvider.overrideWithValue(speech)],
  child: MaterialApp(
    theme: AppTheme.cupping,
    home: Scaffold(body: TermEntryBody(view: _view, term: term)),
  ),
);

void main() {
  group('the speak button', () {
    testWidgets('says the term when pressed', (tester) async {
      final speech = FakeSpeechService();
      await tester.pumpWidget(_wrap(_spoken, speech));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SpeakButton));
      await tester.pump(const Duration(milliseconds: 700));

      expect(speech.spoken, ['Arabica']);
    });

    testWidgets('says it again on a second press', (tester) async {
      final speech = FakeSpeechService();
      await tester.pumpWidget(_wrap(_spoken, speech));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SpeakButton));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.tap(find.byType(SpeakButton));
      await tester.pump(const Duration(milliseconds: 700));

      // Restarting is the design's behaviour; the service flushes rather than
      // queueing, so two presses are two readings and never an overlap.
      expect(speech.spoken, ['Arabica', 'Arabica']);
    });

    testWidgets('shows the respelling and a speaker', (tester) async {
      await tester.pumpWidget(_wrap(_spoken, FakeSpeechService()));
      await tester.pumpAndSettle();

      expect(find.text('uh-RAB-ih-kuh'), findsOneWidget);
      expect(find.byType(SpeakerMark), findsOneWidget);
    });

    testWidgets('keeps the respelling but drops the speaker with no voice', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(_spoken, FakeSpeechService(hasVoice: false)),
      );
      await tester.pumpAndSettle();

      // The respelling is content and stays. The control does not: a speaker
      // this device cannot use is the dead control #355 cleared.
      expect(find.text('uh-RAB-ih-kuh'), findsOneWidget);
      expect(find.byType(SpeakerMark), findsNothing);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('a term with no respelling shows no control at all', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_silent, FakeSpeechService()));
      await tester.pumpAndSettle();

      expect(find.byType(SpeakButton), findsNothing);
      expect(find.byType(SpeakerMark), findsNothing);
    });

    testWidgets('names itself for a screen reader', (tester) async {
      await tester.pumpWidget(_wrap(_spoken, FakeSpeechService()));
      await tester.pumpAndSettle();

      // The respelling alone would be read as letters; the term is the word.
      expect(find.bySemanticsLabel('Pronounce Arabica'), findsOneWidget);
    });
  });
}
