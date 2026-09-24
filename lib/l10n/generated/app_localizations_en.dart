// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get nameTitle => 'And you are…?';

  @override
  String get nameSupport => 'Just a first name — it’s how Roasty greets you.';

  @override
  String get nameContinue => 'Continue';

  @override
  String get nameSkip => 'Skip for now';

  @override
  String get replayConfirmConfirm => 'Review lesson';

  @override
  String get replayConfirmCancel => 'Not now';

  @override
  String replayConfirmTitle(String lessonTitle) {
    return '$lessonTitle?';
  }

  @override
  String get replayConfirmPointsLabel => 'Points';

  @override
  String get replayConfirmPointsValue => 'No change';

  @override
  String get replayConfirmStreakLabel => 'Streak';

  @override
  String get replayConfirmStreakCounts => 'Counts for today';

  @override
  String get replayConfirmStreakEarned => 'Already earned today';

  @override
  String get replayConfirmLengthLabel => 'Length';

  @override
  String get replayConfirmLastCompletedLabel => 'Last completed';

  @override
  String replayConfirmLength(int minutes, int cards) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards cards',
      one: '$cards card',
    );
    return '~$minutes min · $_temp0';
  }

  @override
  String replayConfirmDatedYear(String date, int year) {
    return '$date, $year';
  }

  @override
  String get cardCueMcq => 'Multiple choice · pick one';

  @override
  String get cardCueMulti => 'Select all that apply';

  @override
  String get cardCueMatch => 'Match · drag to pair';

  @override
  String get cardCueSlider => 'Calibrate · dial to the target';

  @override
  String get cardCueSequence => 'Put in order · tap in sequence';

  @override
  String get cardCueQuiz => 'True or false';

  @override
  String get cardCueFlavor => 'Tasting · name the note';

  @override
  String get cardCueTastefix => 'Taste Fix';

  @override
  String get cardCueBagpick => 'Blind bag · read the beans';

  @override
  String get cardCueFill => 'Complete the sentence';

  @override
  String get bagpickCalledIt => 'Called it';

  @override
  String get bagpickProcessWashed => 'Washed';

  @override
  String get bagpickProcessHoney => 'Honey';

  @override
  String get bagpickProcessNatural => 'Natural';

  @override
  String bagpickActually(String process) {
    return '$process, actually';
  }

  @override
  String bagpickSample(int sampleSize) {
    return 'A sample of $sampleSize green beans from this bag.';
  }

  @override
  String get bagpickProcessHidden => 'Process hidden';

  @override
  String get bagpickTapToInspect => 'Tap to inspect';

  @override
  String bagpickCueTell(String label, String body) {
    return '$label. $body. This was the tell.';
  }

  @override
  String bagpickCueRead(String label, String body) {
    return '$label. $body';
  }

  @override
  String get sequenceSubmit => 'Submit';

  @override
  String get sequenceReset => 'Reset';

  @override
  String get sequenceInOrder => 'In order';

  @override
  String get sequenceNailedIt => 'Nailed the sequence.';

  @override
  String get sequenceWrongOrder => 'Not the right order this time.';

  @override
  String get sequenceCorrectOrder => 'CORRECT ORDER';

  @override
  String sequencePosition(int position) {
    return 'position $position';
  }

  @override
  String sequenceBelongsAt(int order) {
    return 'belongs at $order';
  }

  @override
  String sequenceGoesAt(int order) {
    return 'GOES #$order';
  }

  @override
  String get sliderCheck => 'Check answer';

  @override
  String get sliderDialedIn => 'Dialed in';

  @override
  String get sliderYourSetting => 'Your setting';

  @override
  String get sliderTarget => 'Target';

  @override
  String get cardHowToPlay => 'How to play';

  @override
  String get cardHelpGotIt => 'Got it';

  @override
  String get practicalHandsOn => 'HANDS ON';

  @override
  String get practicalTakeaway => 'Worth knowing';

  @override
  String get visualSaveGuide => 'Save this guide';

  @override
  String get visualGuideSaved => 'Saved — review anytime in Saved';

  @override
  String get cardAllCorrect => 'All correct';

  @override
  String get cardCorrect => 'Correct';

  @override
  String get predictFirstGuess => 'First guess';

  @override
  String predictYourGuess(String option) {
    return 'Your guess · $option';
  }

  @override
  String get optionChosen => 'chosen';

  @override
  String get optionCorrectAnswer => 'correct answer';

  @override
  String get optionYourAnswerIncorrect => 'your answer, incorrect';

  @override
  String get optionMissedAnswer => 'missed — this was an answer';

  @override
  String fillOptionChosen(String option) {
    return '$option, chosen';
  }

  @override
  String fillOptionAnswer(String option) {
    return '$option, the answer';
  }

  @override
  String fillOptionNotAnswer(String option) {
    return '$option, not the answer';
  }

  @override
  String takeawaySemantics(String label, String text) {
    return '$label. $text';
  }

  @override
  String get matchCleanBoard => 'Clean board';

  @override
  String matchWrongDrops(int wrongDrops) {
    String _temp0 = intl.Intl.pluralLogic(
      wrongDrops,
      locale: localeName,
      other: '$wrongDrops wrong drops',
      one: '1 wrong drop',
    );
    return '$_temp0';
  }

  @override
  String get matchClearedClean =>
      'Every pair first time. That is the one that counts.';

  @override
  String get matchClearedNotClean =>
      'Cleared it, but not first time — the board only scores when every pair lands on the first try.';

  @override
  String get matchWrongDrop => 'Not that one — try it somewhere else.';

  @override
  String matchPairedWith(String left, String right) {
    return '$left, paired with $right';
  }

  @override
  String matchPlaceUnder(String target) {
    return 'Place under $target';
  }

  @override
  String get visualSaveCaptionSaved => 'Saved — review anytime in Saved';

  @override
  String get tastefixStartingPoint => 'STARTING POINT';

  @override
  String get tastefixFixed => 'FIXED';

  @override
  String get tastefixTastes => 'TASTES';

  @override
  String get tastefixResult => 'RESULT';

  @override
  String get tastefixBalanced => 'Balanced';

  @override
  String tastefixResultSemantics(String result) {
    return 'Result: $result';
  }

  @override
  String tastefixTastesSemantics(String tags) {
    return 'Tastes: $tags';
  }

  @override
  String sliderVeryLeft(String label) {
    return 'Very $label';
  }

  @override
  String get sliderMiddle => 'Middle';

  @override
  String get optionCorrect => 'correct';

  @override
  String get optionIncorrect => 'incorrect';

  @override
  String get payoffOpeningGuess => 'Your opening guess';

  @override
  String get payoffOpener => 'Before the lesson you guessed';

  @override
  String get payoffAndRight => '— and you were right.';

  @override
  String get payoffButActually => '. It\'s';

  @override
  String get payoffNowYouKnow => '— now you know why.';

  @override
  String payoffSpokenRight(String opener, String pick, String andRight) {
    return '$opener $pick $andRight';
  }

  @override
  String payoffSpokenWrong(
    String opener,
    String pick,
    String butActually,
    String answer,
    String nowYouKnow,
  ) {
    return '$opener $pick$butActually $answer $nowYouKnow';
  }
}
