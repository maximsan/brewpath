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
  String sliderVeryEnd(String label) {
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
  String payoffSpokenRight(String pick) {
    return 'Before the lesson you guessed $pick — and you were right.';
  }

  @override
  String payoffSpokenWrong(String pick, String answer) {
    return 'Before the lesson you guessed $pick. It\'s $answer — now you know why.';
  }

  @override
  String lessonCardOfCount(int index, int total) {
    return 'Card $index of $total';
  }

  @override
  String get lessonLoading => 'Loading the lesson';

  @override
  String get lessonNotFound => 'Lesson not found';

  @override
  String get lessonNoCards => 'This lesson has no cards.';

  @override
  String get completionEyebrowComplete => 'Lesson complete';

  @override
  String get completionEyebrowReview => 'Review complete';

  @override
  String get completionBeatPerfect => 'Perfect run!';

  @override
  String get completionBeatMastered => 'Mastered it.';

  @override
  String get completionBeatNeedsPractice => 'Good start.';

  @override
  String get completionBeatNeutral => 'Nice work.';

  @override
  String completionScored(int correct, int total) {
    return 'Scored $correct out of $total';
  }

  @override
  String get rewardFreezeLabel => 'Freeze earned';

  @override
  String get rewardFreezeDetail => 'One missed day is covered.';

  @override
  String get rewardCardLabel => 'New card';

  @override
  String treeGrewToStage(int stage) {
    return 'Your coffee tree grew to stage $stage';
  }

  @override
  String treeAtStage(int stage) {
    return 'Your coffee tree, stage $stage';
  }

  @override
  String get courseStartKeepSharp => 'Start Keep Sharp';

  @override
  String get courseFinishedFoundations => 'You finished Foundations';

  @override
  String courseStatsSpoken(int lessons, int rewards, int streak) {
    return 'What you did: $lessons lessons completed, $rewards Module Rewards earned, a longest streak of $streak days.';
  }

  @override
  String get courseStatLessons => 'Lessons completed';

  @override
  String get courseStatRewards => 'Module Rewards';

  @override
  String get courseStatStreak => 'Longest streak';

  @override
  String get keepSharpDoneFallback => 'Done for today.';

  @override
  String get keepSharpKicker => 'KEEP SHARP';

  @override
  String keepSharpCompleteSpoken(String phrase) {
    return 'Keep Sharp complete for today. $phrase';
  }

  @override
  String get keepSharpStart => 'Start';

  @override
  String keepSharpStartSpoken(String title) {
    return 'Start: $title';
  }

  @override
  String get keepSharpNoneSpoken =>
      'Keep Sharp: no recommendation today. Practice anything below to keep your streak alive.';

  @override
  String get keepSharpNone =>
      'Practice anything below to keep your streak alive.';

  @override
  String get keepSharpMiniGamesTitle => 'Mini-games';

  @override
  String get keepSharpMiniGamesRule => 'Play two different games today.';

  @override
  String get keepSharpVocabTitle => 'Vocab game';

  @override
  String get keepSharpVocabRule => 'Finish one vocab round.';

  @override
  String get keepSharpFlashcardsTitle => 'Flashcards';

  @override
  String get keepSharpFlashcardsRule => 'Review your saved terms.';

  @override
  String get keepSharpReplayTitle => 'Replay a lesson';

  @override
  String get keepSharpReplayRule =>
      'Finish a replay of any lesson you\'ve completed.';

  @override
  String lessonPositionShort(int number, int total, int minutes) {
    return 'LESSON $number/$total · ~$minutes MIN';
  }

  @override
  String lessonPositionSpoken(int number, int total, int minutes) {
    return 'Lesson $number of $total, about $minutes minutes';
  }

  @override
  String get moduleFreezeEarned => 'Freeze earned · One missed day covered';

  @override
  String get miniGameKindMatch => 'Match';

  @override
  String get miniGameKindQuiz => 'True or false';

  @override
  String get miniGameKindFlavor => 'Name the note';

  @override
  String get miniGameKindBagpick => 'Blind bag';

  @override
  String get miniGameKindTastefix => 'Taste fix';

  @override
  String get miniGameKindSlider => 'Calibrate';

  @override
  String get miniGameKindSequence => 'Sequence';

  @override
  String get drillNothingToPlay => 'Nothing to play here yet.';

  @override
  String get drillCleanSweep => 'A clean sweep. Every one of them.';

  @override
  String get drillSharpWork => 'Sharp work — that is the mark.';

  @override
  String get drillAllMissed => 'Every one of these is worth another look.';

  @override
  String get drillWorthAnotherRun =>
      'Worth another run — the explanations stick.';

  @override
  String get miniGameKicker => 'Mini-game';

  @override
  String get miniGameLoading => 'Loading the mini-game';

  @override
  String get miniGameLoadFailed => 'That mini-game could not be loaded.';

  @override
  String get miniGameNotInCatalog => 'That mini-game is not in the catalog.';

  @override
  String get miniGameHowToPlay => 'HOW TO PLAY';

  @override
  String get miniGamePlay => 'Play';

  @override
  String get miniGameNotPlayable => 'Not playable yet';

  @override
  String miniGameRoundOf(int index, int total) {
    return 'Round $index of $total';
  }

  @override
  String get miniGameRoundsLoading => 'Loading the rounds';

  @override
  String get miniGameRoundsFailed => 'These rounds could not be loaded.';

  @override
  String get miniGameNoRounds => 'This mini-game has no rounds yet.';

  @override
  String get miniGamePlayAgain => 'Play again';

  @override
  String get miniGameDone => 'Done';

  @override
  String get miniGameGateNotNow => 'Not now';

  @override
  String miniGameTaughtIn(int number, String label) {
    return 'TAUGHT IN MODULE $number · $label';
  }

  @override
  String get miniGameFullCourse => 'This game comes with the full course.';

  @override
  String get miniGameFree => 'Free';

  @override
  String get miniGameLockedHint => 'Shows the module that teaches it';

  @override
  String get miniGamesEmpty => 'No mini-games available yet.';

  @override
  String get collectiblesLoading => 'Loading your collection';

  @override
  String get collectiblesLoadFailed => 'Your collection could not be loaded.';

  @override
  String get collectiblesInvitation => 'Finish lessons to reveal new cards.';

  @override
  String get collectibleChallengeTried => 'Challenge tried';

  @override
  String get collectibleChallengeToEarn => 'Challenge to earn';

  @override
  String collectibleNumber(String number) {
    return 'CARD $number';
  }

  @override
  String get collectibleGoToCourse => 'Go to the course';

  @override
  String get collectibleFactLabel => 'Fact';

  @override
  String get collectibleMemorableLabel => 'Memorable';

  @override
  String collectibleEarnByModule(String moduleTag) {
    return 'Earn this by finishing $moduleTag';
  }

  @override
  String collectibleEarnByLesson(String lessonTitle) {
    return 'Earn this by completing $lessonTitle';
  }

  @override
  String drillRunComplete(int score, int total, String encouragement) {
    return 'Run complete. You scored $score out of $total. $encouragement';
  }

  @override
  String get verdictNotQuite => 'Not quite';

  @override
  String get quizTrue => 'True';

  @override
  String get quizFalse => 'False';

  @override
  String get decisionGoodCall => 'Good call';

  @override
  String get decisionBackfire => 'That would backfire';

  @override
  String get tastefixGoodFix => 'Good fix';

  @override
  String get completionNextLesson => 'Next lesson';

  @override
  String get completionBackToPath => 'Back to Path';

  @override
  String get completionPracticeAgain => 'Practice this lesson again';

  @override
  String completionScoreLine(int correct, int total) {
    return '$correct / $total correct';
  }

  @override
  String treeLessonsToNextStage(int lessons) {
    String _temp0 = intl.Intl.pluralLogic(
      lessons,
      locale: localeName,
      other: '$lessons lessons',
      one: '$lessons lesson',
    );
    return '$_temp0 to the next stage';
  }

  @override
  String rewardPointsSpoken(int points) {
    return '$points points earned';
  }

  @override
  String rewardPointsLine(int points) {
    return '+$points PTS';
  }

  @override
  String drillScoreLine(int score, int total) {
    return '$score / $total';
  }

  @override
  String drillSpokenPlain(String value, String note, String line) {
    return '$value $note. $line';
  }

  @override
  String collectiblePlaceInSet(String place, int total) {
    return '$place / $total';
  }

  @override
  String collectiblesRemaining(int remaining) {
    return '$remaining more to collect';
  }

  @override
  String collectiblesEarnedOfTotal(int earned, int total) {
    return '$earned of $total';
  }

  @override
  String collectiblesCollectedSpoken(String count) {
    return '$count cards collected';
  }

  @override
  String practiceGroupSpoken(String label, int count) {
    return '$label, $count';
  }

  @override
  String practiceReplaySpoken(String lines) {
    return '$lines. Replay.';
  }

  @override
  String practiceMinutes(int minutes) {
    return '~$minutes min';
  }

  @override
  String get practiceFree => 'Free';

  @override
  String get practiceTwoMinutes => '~2 min';

  @override
  String todayBeginSpoken(String label, String title) {
    return '$label: $title';
  }

  @override
  String get optionMissedTag => 'MISSED';

  @override
  String get optionSelected => 'selected';

  @override
  String get optionCorrectMark => 'correct';

  @override
  String get grinderClicksUnit => 'CLICKS';

  @override
  String get termOfDayTitle => 'Term of the Day';

  @override
  String get termOfDayOpenEntry => 'Open entry';

  @override
  String get termOfDayReadFull => 'Read the full entry';

  @override
  String get termOfDayBack => 'Back';

  @override
  String get termEntryFullExplanation => 'Full explanation · Plus';

  @override
  String get termEntryComesWithCourse => 'Comes with the full course.';

  @override
  String termEntryGateSemantics(String action, String offer) {
    return '$action. $offer';
  }

  @override
  String searchResultCount(int found) {
    String _temp0 = intl.Intl.pluralLogic(
      found,
      locale: localeName,
      other: '$found RESULTS',
      one: '$found RESULT',
    );
    return '$_temp0';
  }

  @override
  String get searchNoMatchesLine => 'No terms match that search.';

  @override
  String get searchNoMatchesLabel => 'No terms match that search';

  @override
  String searchNoMatchesForLine(String query) {
    return 'No terms match “$query”. Try a broader word — or browse by category.';
  }

  @override
  String searchNoMatchesForLabel(String query) {
    return 'No terms match that search: $query';
  }

  @override
  String get flashcardsTitle => 'Flashcards';

  @override
  String get flashcardsEmptyBody =>
      'Bookmark terms in the dictionary and they become a flashcard deck here — flip to test yourself.';

  @override
  String get flashcardsEmptyOutOfReachBody =>
      'The terms you saved are not in your free lessons, so there is nothing to flip yet. Bookmark a term one of your lessons mentions, or unlock the full course to practise all of them.';

  @override
  String get flashcardsBrowse => 'Browse the dictionary';

  @override
  String get flashcardsFront => 'Term';

  @override
  String get flashcardsBack => 'Definition';

  @override
  String get flashcardsTapToReveal => 'Tap to reveal';

  @override
  String get flashcardsTapToSeeTerm => 'Tap to see term';

  @override
  String get flashcardsViewEntry => 'View full entry';

  @override
  String get flashcardsFinish => 'Finish';

  @override
  String get flashcardsPreviousCard => 'Previous card';

  @override
  String get flashcardsNextCard => 'Next card';

  @override
  String get flashcardsShuffle => 'Shuffle deck';

  @override
  String flashcardsReviewedNote(int cards) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: 'Terms reviewed',
      one: 'Term reviewed',
    );
    return '$_temp0';
  }

  @override
  String get flashcardsResultsMessage =>
      'That’s every term you’ve saved. Run it back shuffled, or bookmark more in the dictionary.';

  @override
  String get flashcardsGoAgain => 'Shuffle and go again';

  @override
  String get flashcardsDone => 'Done';

  @override
  String flashcardsDeckLine(int cards) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards saved terms',
      one: '$cards saved term',
    );
    return '$_temp0';
  }

  @override
  String flashcardsStudyRow(int cards) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: 'Study $cards terms as flashcards',
      one: 'Study $cards term as flashcards',
    );
    return '$_temp0';
  }

  @override
  String get flashcardsPracticeRowEyebrow => 'Flip and recall';

  @override
  String get vocabTitle => 'Guess the term';

  @override
  String get vocabRowSubtitle => 'From the definition';

  @override
  String get vocabSetupBlurb =>
      'Read a definition, pick the term. Choose your deck and how long a round you want.';

  @override
  String get vocabDeckHeading => 'Deck';

  @override
  String get vocabLengthHeading => 'Round length';

  @override
  String get vocabLengthQuick => 'Quick';

  @override
  String get vocabLengthStandard => 'Standard';

  @override
  String get vocabLengthDeep => 'Deep';

  @override
  String get vocabSavedDeck => 'Saved terms';

  @override
  String get vocabSavedDeckReady => 'The terms you have bookmarked';

  @override
  String vocabSavedDeckShort(int minimum) {
    return 'Save $minimum or more terms to unlock';
  }

  @override
  String get vocabMissesDeck => 'Review misses';

  @override
  String get vocabMissesDeckReady => 'Terms you have missed before';

  @override
  String get vocabMissesDeckShort => 'Miss a few first';

  @override
  String get vocabAllDeck => 'Whole glossary';

  @override
  String get vocabYourTermsDeck => 'Your terms';

  @override
  String get vocabAllDeckNote => 'Every term in the dictionary';

  @override
  String get vocabYourTermsNote => 'Every term your lessons mention';

  @override
  String get vocabWholeDeck => 'Every term in this deck';

  @override
  String get vocabLongerRoundsHint =>
      'Longer rounds unlock as you bookmark more terms.';

  @override
  String get vocabLongerMissRoundsHint =>
      'Longer rounds unlock as you log more misses.';

  @override
  String get vocabStart => 'Start round';

  @override
  String get vocabQuestionLead => 'Which term means…';

  @override
  String get vocabNext => 'Next question';

  @override
  String get vocabSeeScore => 'See score';

  @override
  String get vocabReadEntry => 'See the full entry';

  @override
  String get vocabPlayAgain => 'Play again';

  @override
  String get vocabChangeRound => 'Change round';

  @override
  String get vocabTeachingTitle => 'A few more terms first';

  @override
  String vocabTeachingBody(int minimum) {
    return 'The game draws on the terms your lessons mention, and it needs at least $minimum. Play a lesson or two and come back.';
  }

  @override
  String get vocabTeachingAction => 'Back to learning';

  @override
  String get vocabLoading => 'Loading the drill';

  @override
  String get vocabLoadFailed => 'This drill could not be loaded.';

  @override
  String vocabProgress(int position, int total) {
    return 'Question $position of $total';
  }

  @override
  String vocabAnsweredChoiceCorrect(String term) {
    return '$term, correct';
  }

  @override
  String vocabAnsweredChoiceIncorrect(String term) {
    return '$term, incorrect';
  }

  @override
  String vocabVerdictWrong(String notQuite, String answer) {
    return '$notQuite — it\'s $answer';
  }

  @override
  String get vocabCorrectVerdict => 'Correct';

  @override
  String vocabReviewDeckKept(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' The $count terms you missed were kept in your review deck.',
      one: ' The $count term you missed was kept in your review deck.',
    );
    return '$_temp0';
  }

  @override
  String vocabReviewDeckAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' The $count terms you missed were added to your review deck.',
      one: ' The $count term you missed was added to your review deck.',
    );
    return '$_temp0';
  }

  @override
  String get vocabNothingToDrill => 'Nothing to drill here yet.';

  @override
  String get vocabWholeDeckScore =>
      'Every one of them. That is the whole deck.';

  @override
  String get vocabSharpPalate => 'Sharp palate. You know these cold.';

  @override
  String get vocabSolidRound => 'Solid round — run it back to sharpen up.';

  @override
  String get vocabWorthAnotherPass =>
      'Worth another pass. The definitions stick faster the second time.';
}
