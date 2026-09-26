import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Heading of the onboarding step that asks for a first name.
  ///
  /// In en, this message translates to:
  /// **'And you are…?'**
  String get nameTitle;

  /// Line under the heading, saying why the app is asking. Roasty is the mascot's name and is not translated.
  ///
  /// In en, this message translates to:
  /// **'Just a first name — it’s how Roasty greets you.'**
  String get nameSupport;

  /// Button that keeps the entered name and moves on.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get nameContinue;

  /// Button that moves on without a name. Says the question can come back, which Settings makes true.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get nameSkip;

  /// Button that starts a replay of a lesson already finished.
  ///
  /// In en, this message translates to:
  /// **'Review lesson'**
  String get replayConfirmConfirm;

  /// Button that closes the replay sheet without starting anything.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get replayConfirmCancel;

  /// Title of the replay sheet: the lesson's name, asked as a question.
  ///
  /// In en, this message translates to:
  /// **'{lessonTitle}?'**
  String replayConfirmTitle(String lessonTitle);

  /// Label of the replay sheet line about points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get replayConfirmPointsLabel;

  /// Value of the points line: a replay pays nothing.
  ///
  /// In en, this message translates to:
  /// **'No change'**
  String get replayConfirmPointsValue;

  /// Label of the replay sheet line about the daily streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get replayConfirmStreakLabel;

  /// Streak line on a day the replay would still protect.
  ///
  /// In en, this message translates to:
  /// **'Counts for today'**
  String get replayConfirmStreakCounts;

  /// Streak line on a day already covered by something else.
  ///
  /// In en, this message translates to:
  /// **'Already earned today'**
  String get replayConfirmStreakEarned;

  /// Label of the replay sheet line about how long the lesson runs.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get replayConfirmLengthLabel;

  /// Label of the replay sheet line about when the lesson was last finished.
  ///
  /// In en, this message translates to:
  /// **'Last completed'**
  String get replayConfirmLastCompletedLabel;

  /// How long a replay runs and how many cards it holds.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min · {cards, plural, =1{{cards} card} other{{cards} cards}}'**
  String replayConfirmLength(int minutes, int cards);

  /// A past run's date once it is not this year, so an old run cannot pass as this year's.
  ///
  /// In en, this message translates to:
  /// **'{date}, {year}'**
  String replayConfirmDatedYear(String date, int year);

  /// Eyebrow on a multiple-choice card, naming the format.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice · pick one'**
  String get cardCueMcq;

  /// Eyebrow on a card that takes several answers at once.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply'**
  String get cardCueMulti;

  /// Eyebrow on a card where traits are dragged onto what they belong to.
  ///
  /// In en, this message translates to:
  /// **'Match · drag to pair'**
  String get cardCueMatch;

  /// Eyebrow on a card answered by dialling a slider.
  ///
  /// In en, this message translates to:
  /// **'Calibrate · dial to the target'**
  String get cardCueSlider;

  /// Eyebrow on a card answered by tapping items into order.
  ///
  /// In en, this message translates to:
  /// **'Put in order · tap in sequence'**
  String get cardCueSequence;

  /// Eyebrow on a card that asks whether a statement holds.
  ///
  /// In en, this message translates to:
  /// **'True or false'**
  String get cardCueQuiz;

  /// Eyebrow on a card that asks for the note behind a tasting clue.
  ///
  /// In en, this message translates to:
  /// **'Tasting · name the note'**
  String get cardCueFlavor;

  /// Eyebrow on a card that asks for the fix for a cup that came out wrong.
  ///
  /// In en, this message translates to:
  /// **'Taste Fix'**
  String get cardCueTastefix;

  /// Eyebrow on a card that asks for the process behind an unlabelled bag.
  ///
  /// In en, this message translates to:
  /// **'Blind bag · read the beans'**
  String get cardCueBagpick;

  /// Eyebrow on a card answered by filling the blanks in a sentence.
  ///
  /// In en, this message translates to:
  /// **'Complete the sentence'**
  String get cardCueFill;

  /// Verdict line when the learner named the bag's process correctly.
  ///
  /// In en, this message translates to:
  /// **'Called it'**
  String get bagpickCalledIt;

  /// Name of the washed coffee process, as a bag-picking option.
  ///
  /// In en, this message translates to:
  /// **'Washed'**
  String get bagpickProcessWashed;

  /// Name of the honey coffee process, as a bag-picking option.
  ///
  /// In en, this message translates to:
  /// **'Honey'**
  String get bagpickProcessHoney;

  /// Name of the natural coffee process, as a bag-picking option.
  ///
  /// In en, this message translates to:
  /// **'Natural'**
  String get bagpickProcessNatural;

  /// Verdict line naming the real process after a wrong call.
  ///
  /// In en, this message translates to:
  /// **'{process}, actually'**
  String bagpickActually(String process);

  /// Caption over the beans drawn from an unlabelled bag.
  ///
  /// In en, this message translates to:
  /// **'A sample of {sampleSize} green beans from this bag.'**
  String bagpickSample(int sampleSize);

  /// Says the bag's process is not printed on it.
  ///
  /// In en, this message translates to:
  /// **'Process hidden'**
  String get bagpickProcessHidden;

  /// Prompt on a clue the learner has not opened yet.
  ///
  /// In en, this message translates to:
  /// **'Tap to inspect'**
  String get bagpickTapToInspect;

  /// What a screen reader is told about the clue that gave the process away.
  ///
  /// In en, this message translates to:
  /// **'{label}. {body}. This was the tell.'**
  String bagpickCueTell(String label, String body);

  /// What a screen reader is told about an opened clue.
  ///
  /// In en, this message translates to:
  /// **'{label}. {body}'**
  String bagpickCueRead(String label, String body);

  /// Button that commits the order the learner tapped.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get sequenceSubmit;

  /// Button that clears the order tapped so far.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get sequenceReset;

  /// Verdict line when the sequence was right.
  ///
  /// In en, this message translates to:
  /// **'In order'**
  String get sequenceInOrder;

  /// Explanation under a correct sequence verdict.
  ///
  /// In en, this message translates to:
  /// **'Nailed the sequence.'**
  String get sequenceNailedIt;

  /// Explanation under a wrong sequence verdict.
  ///
  /// In en, this message translates to:
  /// **'Not the right order this time.'**
  String get sequenceWrongOrder;

  /// Kicker over the reveal of the right order. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'CORRECT ORDER'**
  String get sequenceCorrectOrder;

  /// What a screen reader is told about a step's place in the run.
  ///
  /// In en, this message translates to:
  /// **'position {position}'**
  String sequencePosition(int position);

  /// What a screen reader is told about a step that sits in the wrong place.
  ///
  /// In en, this message translates to:
  /// **'belongs at {order}'**
  String sequenceBelongsAt(int order);

  /// Hint on a misplaced step, naming where it belongs.
  ///
  /// In en, this message translates to:
  /// **'GOES #{order}'**
  String sequenceGoesAt(int order);

  /// Button that commits the slider setting.
  ///
  /// In en, this message translates to:
  /// **'Check answer'**
  String get sliderCheck;

  /// Verdict line when the slider landed inside the target band.
  ///
  /// In en, this message translates to:
  /// **'Dialed in'**
  String get sliderDialedIn;

  /// Label over the value the learner dialled.
  ///
  /// In en, this message translates to:
  /// **'Your setting'**
  String get sliderYourSetting;

  /// Label over the value the card was asking for.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get sliderTarget;

  /// Opens the drawer explaining the card's format.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get cardHowToPlay;

  /// Closes the drawer explaining the card's format.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get cardHelpGotIt;

  /// Eyebrow on a practical card. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'HANDS ON'**
  String get practicalHandsOn;

  /// Kicker over the rule a practical card leaves the learner with.
  ///
  /// In en, this message translates to:
  /// **'Worth knowing'**
  String get practicalTakeaway;

  /// Button that bookmarks a visual guide.
  ///
  /// In en, this message translates to:
  /// **'Save this guide'**
  String get visualSaveGuide;

  /// Confirms a visual guide was bookmarked, and says where to find it.
  ///
  /// In en, this message translates to:
  /// **'Saved — review anytime in Saved'**
  String get visualGuideSaved;

  /// Verdict line when every answer on the card was right.
  ///
  /// In en, this message translates to:
  /// **'All correct'**
  String get cardAllCorrect;

  /// Verdict line when the answer was right.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get cardCorrect;

  /// Eyebrow over the question a predict card holds a guess for.
  ///
  /// In en, this message translates to:
  /// **'First guess'**
  String get predictFirstGuess;

  /// Verdict line repeating the learner's held guess back to them.
  ///
  /// In en, this message translates to:
  /// **'Your guess · {option}'**
  String predictYourGuess(String option);

  /// Spoken suffix on the option a learner picked.
  ///
  /// In en, this message translates to:
  /// **'chosen'**
  String get optionChosen;

  /// Spoken suffix on the option that was right.
  ///
  /// In en, this message translates to:
  /// **'correct answer'**
  String get optionCorrectAnswer;

  /// Spoken suffix on a wrong option the learner picked.
  ///
  /// In en, this message translates to:
  /// **'your answer, incorrect'**
  String get optionYourAnswerIncorrect;

  /// Spoken suffix on a right option the learner did not pick.
  ///
  /// In en, this message translates to:
  /// **'missed — this was an answer'**
  String get optionMissedAnswer;

  /// What a screen reader is told about a word the learner put in a blank.
  ///
  /// In en, this message translates to:
  /// **'{option}, chosen'**
  String fillOptionChosen(String option);

  /// What a screen reader is told about the word that belonged in a blank.
  ///
  /// In en, this message translates to:
  /// **'{option}, the answer'**
  String fillOptionAnswer(String option);

  /// What a screen reader is told about a word that did not belong in a blank.
  ///
  /// In en, this message translates to:
  /// **'{option}, not the answer'**
  String fillOptionNotAnswer(String option);

  /// What a screen reader is told about a card's closing note.
  ///
  /// In en, this message translates to:
  /// **'{label}. {text}'**
  String takeawaySemantics(String label, String text);

  /// Verdict when every pair landed on the first try.
  ///
  /// In en, this message translates to:
  /// **'Clean board'**
  String get matchCleanBoard;

  /// Verdict counting the misplaced drops on a match board.
  ///
  /// In en, this message translates to:
  /// **'{wrongDrops, plural, =1{1 wrong drop} other{{wrongDrops} wrong drops}}'**
  String matchWrongDrops(int wrongDrops);

  /// Explanation under a clean match board.
  ///
  /// In en, this message translates to:
  /// **'Every pair first time. That is the one that counts.'**
  String get matchClearedClean;

  /// Explanation under a match board cleared with misses.
  ///
  /// In en, this message translates to:
  /// **'Cleared it, but not first time — the board only scores when every pair lands on the first try.'**
  String get matchClearedNotClean;

  /// Announced when a dragged fact lands on the wrong target.
  ///
  /// In en, this message translates to:
  /// **'Not that one — try it somewhere else.'**
  String get matchWrongDrop;

  /// What a screen reader is told about a completed pair.
  ///
  /// In en, this message translates to:
  /// **'{left}, paired with {right}'**
  String matchPairedWith(String left, String right);

  /// What a screen reader is told a drop target would do.
  ///
  /// In en, this message translates to:
  /// **'Place under {target}'**
  String matchPlaceUnder(String target);

  /// Kicker over the cup as it was brewed. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'STARTING POINT'**
  String get tastefixStartingPoint;

  /// Kicker over the cup after the fix. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'FIXED'**
  String get tastefixFixed;

  /// Kicker over what the cup tastes of. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'TASTES'**
  String get tastefixTastes;

  /// Kicker over what the fix came to. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'RESULT'**
  String get tastefixResult;

  /// Name for a cup with nothing left to fix.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get tastefixBalanced;

  /// What a screen reader is told the fix came to.
  ///
  /// In en, this message translates to:
  /// **'Result: {result}'**
  String tastefixResultSemantics(String result);

  /// What a screen reader is told the cup tastes of.
  ///
  /// In en, this message translates to:
  /// **'Tastes: {tags}'**
  String tastefixTastesSemantics(String tags);

  /// End label on a calibrate track. Used for both ends: {label} is the round's own word for that end, so it reads 'Very Fine' at one and 'Very Coarse' at the other.
  ///
  /// In en, this message translates to:
  /// **'Very {label}'**
  String sliderVeryEnd(String label);

  /// Label for the centre of a calibrate track.
  ///
  /// In en, this message translates to:
  /// **'Middle'**
  String get sliderMiddle;

  /// Spoken suffix on an option the learner picked that was an answer.
  ///
  /// In en, this message translates to:
  /// **'correct'**
  String get optionCorrect;

  /// Spoken suffix on an option the learner picked that was not an answer.
  ///
  /// In en, this message translates to:
  /// **'incorrect'**
  String get optionIncorrect;

  /// Verdict line over the reply to the guess the lesson opened with.
  ///
  /// In en, this message translates to:
  /// **'Your opening guess'**
  String get payoffOpeningGuess;

  /// Start of the payoff sentence, before the learner's guess.
  ///
  /// In en, this message translates to:
  /// **'Before the lesson you guessed'**
  String get payoffOpener;

  /// End of the payoff sentence when the guess landed.
  ///
  /// In en, this message translates to:
  /// **'— and you were right.'**
  String get payoffAndRight;

  /// Turn in the payoff sentence when the guess missed, before the real answer.
  ///
  /// In en, this message translates to:
  /// **'. It\'s'**
  String get payoffButActually;

  /// End of the payoff sentence when the guess missed.
  ///
  /// In en, this message translates to:
  /// **'— now you know why.'**
  String get payoffNowYouKnow;

  /// The payoff read as one sentence for a screen reader, when the guess landed. The visible version sets {pick} as a chip, which announces nothing on its own.
  ///
  /// In en, this message translates to:
  /// **'Before the lesson you guessed {pick} — and you were right.'**
  String payoffSpokenRight(String pick);

  /// The payoff read as one sentence for a screen reader, when the guess missed. The visible version sets both words as chips, which announce nothing on their own.
  ///
  /// In en, this message translates to:
  /// **'Before the lesson you guessed {pick}. It\'s {answer} — now you know why.'**
  String payoffSpokenWrong(String pick, String answer);

  /// What a screen reader is told about the learner's place in the lesson.
  ///
  /// In en, this message translates to:
  /// **'Card {index} of {total}'**
  String lessonCardOfCount(int index, int total);

  /// Announced while a lesson is still being read.
  ///
  /// In en, this message translates to:
  /// **'Loading the lesson'**
  String get lessonLoading;

  /// Shown when the course no longer carries the lesson that was opened.
  ///
  /// In en, this message translates to:
  /// **'Lesson not found'**
  String get lessonNotFound;

  /// Shown when a lesson carries nothing to play.
  ///
  /// In en, this message translates to:
  /// **'This lesson has no cards.'**
  String get lessonNoCards;

  /// Kicker over the screen that closes a first run of a lesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson complete'**
  String get completionEyebrowComplete;

  /// Kicker over the screen that closes a replay, which pays nothing.
  ///
  /// In en, this message translates to:
  /// **'Review complete'**
  String get completionEyebrowReview;

  /// Headline closing a lesson answered without a miss.
  ///
  /// In en, this message translates to:
  /// **'Perfect run!'**
  String get completionBeatPerfect;

  /// Headline closing a lesson answered well.
  ///
  /// In en, this message translates to:
  /// **'Mastered it.'**
  String get completionBeatMastered;

  /// Headline closing a weak run. Congratulates rather than corrects.
  ///
  /// In en, this message translates to:
  /// **'Good start.'**
  String get completionBeatNeedsPractice;

  /// Headline closing a run with no stored score.
  ///
  /// In en, this message translates to:
  /// **'Nice work.'**
  String get completionBeatNeutral;

  /// What a screen reader is told the run came to.
  ///
  /// In en, this message translates to:
  /// **'Scored {correct} out of {total}'**
  String completionScored(int correct, int total);

  /// Label on the reward row for a streak freeze.
  ///
  /// In en, this message translates to:
  /// **'Freeze earned'**
  String get rewardFreezeLabel;

  /// Line under the streak-freeze reward, saying what it covers.
  ///
  /// In en, this message translates to:
  /// **'One missed day is covered.'**
  String get rewardFreezeDetail;

  /// Label on the reward row for a collectible card.
  ///
  /// In en, this message translates to:
  /// **'New card'**
  String get rewardCardLabel;

  /// What a screen reader is told when the tree advanced.
  ///
  /// In en, this message translates to:
  /// **'Your coffee tree grew to stage {stage}'**
  String treeGrewToStage(int stage);

  /// What a screen reader is told about the tree when it did not advance.
  ///
  /// In en, this message translates to:
  /// **'Your coffee tree, stage {stage}'**
  String treeAtStage(int stage);

  /// Button that opens the daily practice after the course is finished.
  ///
  /// In en, this message translates to:
  /// **'Start Keep Sharp'**
  String get courseStartKeepSharp;

  /// Headline on the screen that closes the whole course. Foundations is the course's name.
  ///
  /// In en, this message translates to:
  /// **'You finished Foundations'**
  String get courseFinishedFoundations;

  /// What a screen reader is told the finished course came to.
  ///
  /// In en, this message translates to:
  /// **'What you did: {lessons} lessons completed, {rewards} Module Rewards earned, a longest streak of {streak} days.'**
  String courseStatsSpoken(int lessons, int rewards, int streak);

  /// Label on the finished-course figure counting lessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons completed'**
  String get courseStatLessons;

  /// Label on the finished-course figure counting module rewards.
  ///
  /// In en, this message translates to:
  /// **'Module Rewards'**
  String get courseStatRewards;

  /// Label on the finished-course figure for the longest run of days.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get courseStatStreak;

  /// Line under a finished Keep Sharp card when the day has no phrase of its own.
  ///
  /// In en, this message translates to:
  /// **'Done for today.'**
  String get keepSharpDoneFallback;

  /// Kicker over the daily practice card. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'KEEP SHARP'**
  String get keepSharpKicker;

  /// What a screen reader is told about a finished Keep Sharp card.
  ///
  /// In en, this message translates to:
  /// **'Keep Sharp complete for today. {phrase}'**
  String keepSharpCompleteSpoken(String phrase);

  /// Button that begins the day's recommended practice.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get keepSharpStart;

  /// What a screen reader is told the start button opens.
  ///
  /// In en, this message translates to:
  /// **'Start: {title}'**
  String keepSharpStartSpoken(String title);

  /// What a screen reader is told when no practice can be recommended.
  ///
  /// In en, this message translates to:
  /// **'Keep Sharp: no recommendation today. Practice anything below to keep your streak alive.'**
  String get keepSharpNoneSpoken;

  /// Line shown when no practice can be recommended today.
  ///
  /// In en, this message translates to:
  /// **'Practice anything below to keep your streak alive.'**
  String get keepSharpNone;

  /// Name of the mini-games practice on the Keep Sharp card.
  ///
  /// In en, this message translates to:
  /// **'Mini-games'**
  String get keepSharpMiniGamesTitle;

  /// What finishing the mini-games practice takes.
  ///
  /// In en, this message translates to:
  /// **'Play two different games today.'**
  String get keepSharpMiniGamesRule;

  /// Name of the vocab practice on the Keep Sharp card.
  ///
  /// In en, this message translates to:
  /// **'Vocab game'**
  String get keepSharpVocabTitle;

  /// What finishing the vocab practice takes.
  ///
  /// In en, this message translates to:
  /// **'Finish one vocab round.'**
  String get keepSharpVocabRule;

  /// Name of the flashcard practice on the Keep Sharp card.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get keepSharpFlashcardsTitle;

  /// What finishing the flashcard practice takes.
  ///
  /// In en, this message translates to:
  /// **'Review your saved terms.'**
  String get keepSharpFlashcardsRule;

  /// Name of the lesson-replay practice on the Keep Sharp card.
  ///
  /// In en, this message translates to:
  /// **'Replay a lesson'**
  String get keepSharpReplayTitle;

  /// What finishing the lesson-replay practice takes.
  ///
  /// In en, this message translates to:
  /// **'Finish a replay of any lesson you\'ve completed.'**
  String get keepSharpReplayRule;

  /// Eyebrow naming a lesson's place in its module and how long it runs. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'LESSON {number}/{total} · ~{minutes} MIN'**
  String lessonPositionShort(int number, int total, int minutes);

  /// What a screen reader is told about a lesson's place and length.
  ///
  /// In en, this message translates to:
  /// **'Lesson {number} of {total}, about {minutes} minutes'**
  String lessonPositionSpoken(int number, int total, int minutes);

  /// Mark on a finished module that paid a streak freeze.
  ///
  /// In en, this message translates to:
  /// **'Freeze earned · One missed day covered'**
  String get moduleFreezeEarned;

  /// Name of the match mini-game in the catalog.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get miniGameKindMatch;

  /// Name of the true-or-false mini-game in the catalog.
  ///
  /// In en, this message translates to:
  /// **'True or false'**
  String get miniGameKindQuiz;

  /// Name of the tasting mini-game in the catalog.
  ///
  /// In en, this message translates to:
  /// **'Name the note'**
  String get miniGameKindFlavor;

  /// Name of the blind-bag mini-game in the catalog.
  ///
  /// In en, this message translates to:
  /// **'Blind bag'**
  String get miniGameKindBagpick;

  /// Name of the taste-fix mini-game in the catalog.
  ///
  /// In en, this message translates to:
  /// **'Taste fix'**
  String get miniGameKindTastefix;

  /// Name of the calibrate mini-game in the catalog.
  ///
  /// In en, this message translates to:
  /// **'Calibrate'**
  String get miniGameKindSlider;

  /// Name of the put-in-order mini-game in the catalog.
  ///
  /// In en, this message translates to:
  /// **'Sequence'**
  String get miniGameKindSequence;

  /// Closing line when a run had no rounds.
  ///
  /// In en, this message translates to:
  /// **'Nothing to play here yet.'**
  String get drillNothingToPlay;

  /// Closing line when every round was right.
  ///
  /// In en, this message translates to:
  /// **'A clean sweep. Every one of them.'**
  String get drillCleanSweep;

  /// Closing line for a strong run.
  ///
  /// In en, this message translates to:
  /// **'Sharp work — that is the mark.'**
  String get drillSharpWork;

  /// Closing line when no round was right.
  ///
  /// In en, this message translates to:
  /// **'Every one of these is worth another look.'**
  String get drillAllMissed;

  /// Closing line for a middling run.
  ///
  /// In en, this message translates to:
  /// **'Worth another run — the explanations stick.'**
  String get drillWorthAnotherRun;

  /// Kicker over a mini-game's opening screen.
  ///
  /// In en, this message translates to:
  /// **'Mini-game'**
  String get miniGameKicker;

  /// Announced while a mini-game is being read.
  ///
  /// In en, this message translates to:
  /// **'Loading the mini-game'**
  String get miniGameLoading;

  /// Shown when a mini-game cannot be read.
  ///
  /// In en, this message translates to:
  /// **'That mini-game could not be loaded.'**
  String get miniGameLoadFailed;

  /// Shown when the catalog no longer carries the game that was opened.
  ///
  /// In en, this message translates to:
  /// **'That mini-game is not in the catalog.'**
  String get miniGameNotInCatalog;

  /// Kicker over a mini-game's rules. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'HOW TO PLAY'**
  String get miniGameHowToPlay;

  /// Button that starts a mini-game.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get miniGamePlay;

  /// Button state for a mini-game the learner cannot start.
  ///
  /// In en, this message translates to:
  /// **'Not playable yet'**
  String get miniGameNotPlayable;

  /// What a screen reader is told about the learner's place in a run.
  ///
  /// In en, this message translates to:
  /// **'Round {index} of {total}'**
  String miniGameRoundOf(int index, int total);

  /// Announced while a mini-game's rounds are being read.
  ///
  /// In en, this message translates to:
  /// **'Loading the rounds'**
  String get miniGameRoundsLoading;

  /// Shown when a mini-game's rounds cannot be read.
  ///
  /// In en, this message translates to:
  /// **'These rounds could not be loaded.'**
  String get miniGameRoundsFailed;

  /// Shown when a mini-game carries nothing to play.
  ///
  /// In en, this message translates to:
  /// **'This mini-game has no rounds yet.'**
  String get miniGameNoRounds;

  /// Button that runs the same mini-game again.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get miniGamePlayAgain;

  /// Button that leaves a finished mini-game.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get miniGameDone;

  /// Button that closes the sheet in front of a locked mini-game.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get miniGameGateNotNow;

  /// Says which module teaches a locked mini-game. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'TAUGHT IN MODULE {number} · {label}'**
  String miniGameTaughtIn(int number, String label);

  /// Says a locked mini-game opens with the purchase.
  ///
  /// In en, this message translates to:
  /// **'This game comes with the full course.'**
  String get miniGameFullCourse;

  /// Hint on a locked mini-game row, saying what tapping it does.
  ///
  /// In en, this message translates to:
  /// **'Shows the module that teaches it'**
  String get miniGameLockedHint;

  /// Shown when the catalog has nothing to offer.
  ///
  /// In en, this message translates to:
  /// **'No mini-games available yet.'**
  String get miniGamesEmpty;

  /// Announced while the card collection is being read.
  ///
  /// In en, this message translates to:
  /// **'Loading your collection'**
  String get collectiblesLoading;

  /// Shown when the card collection cannot be read.
  ///
  /// In en, this message translates to:
  /// **'Your collection could not be loaded.'**
  String get collectiblesLoadFailed;

  /// Line under the collection, saying how new cards arrive.
  ///
  /// In en, this message translates to:
  /// **'Finish lessons to reveal new cards.'**
  String get collectiblesInvitation;

  /// Marks a card whose brew challenge the learner has attempted.
  ///
  /// In en, this message translates to:
  /// **'Challenge tried'**
  String get collectibleChallengeTried;

  /// Marks a card whose brew challenge is still to attempt.
  ///
  /// In en, this message translates to:
  /// **'Challenge to earn'**
  String get collectibleChallengeToEarn;

  /// Number over a card in the collection. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'CARD {number}'**
  String collectibleNumber(String number);

  /// Button on a locked card that opens the lesson which awards it.
  ///
  /// In en, this message translates to:
  /// **'Go to the course'**
  String get collectibleGoToCourse;

  /// Kicker over the fact on a card's sheet.
  ///
  /// In en, this message translates to:
  /// **'Fact'**
  String get collectibleFactLabel;

  /// Kicker over the keepsake line on a reward card.
  ///
  /// In en, this message translates to:
  /// **'Memorable'**
  String get collectibleMemorableLabel;

  /// Says a card is earned by finishing a module.
  ///
  /// In en, this message translates to:
  /// **'Earn this by finishing {moduleTag}'**
  String collectibleEarnByModule(String moduleTag);

  /// Says a card is earned by finishing one lesson.
  ///
  /// In en, this message translates to:
  /// **'Earn this by completing {lessonTitle}'**
  String collectibleEarnByLesson(String lessonTitle);

  /// What a screen reader is told a finished run came to.
  ///
  /// In en, this message translates to:
  /// **'Run complete. You scored {score} out of {total}. {encouragement}'**
  String drillRunComplete(int score, int total, String encouragement);

  /// The line every graded surface closes on when the answer was not right.
  ///
  /// In en, this message translates to:
  /// **'Not quite'**
  String get verdictNotQuite;

  /// The affirmative option on a true-or-false card.
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get quizTrue;

  /// The negative option on a true-or-false card.
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get quizFalse;

  /// Verdict when a decision card's call pays off.
  ///
  /// In en, this message translates to:
  /// **'Good call'**
  String get decisionGoodCall;

  /// Verdict when a decision card's call would go wrong.
  ///
  /// In en, this message translates to:
  /// **'That would backfire'**
  String get decisionBackfire;

  /// Verdict when a taste-fix card's fix worked.
  ///
  /// In en, this message translates to:
  /// **'Good fix'**
  String get tastefixGoodFix;

  /// Button that opens the lesson queued behind the one just finished.
  ///
  /// In en, this message translates to:
  /// **'Next lesson'**
  String get completionNextLesson;

  /// Button that leaves a finished lesson when nothing is queued.
  ///
  /// In en, this message translates to:
  /// **'Back to Path'**
  String get completionBackToPath;

  /// Invitation a weak run gets, in the action colour rather than a failure red.
  ///
  /// In en, this message translates to:
  /// **'Practice this lesson again'**
  String get completionPracticeAgain;

  /// How a finished run's score is drawn.
  ///
  /// In en, this message translates to:
  /// **'{correct} / {total} correct'**
  String completionScoreLine(int correct, int total);

  /// How many lessons are left before the tree grows again.
  ///
  /// In en, this message translates to:
  /// **'{lessons, plural, =1{{lessons} lesson} other{{lessons} lessons}} to the next stage'**
  String treeLessonsToNextStage(int lessons);

  /// What a screen reader is told a run paid.
  ///
  /// In en, this message translates to:
  /// **'{points} points earned'**
  String rewardPointsSpoken(int points);

  /// How points paid are drawn. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'+{points} PTS'**
  String rewardPointsLine(int points);

  /// How a finished drill's score is drawn.
  ///
  /// In en, this message translates to:
  /// **'{score} / {total}'**
  String drillScoreLine(int score, int total);

  /// What a screen reader is told about an unscored drill result.
  ///
  /// In en, this message translates to:
  /// **'{value} {note}. {line}'**
  String drillSpokenPlain(String value, String note, String line);

  /// A card's place in the whole collection.
  ///
  /// In en, this message translates to:
  /// **'{place} / {total}'**
  String collectiblePlaceInSet(String place, int total);

  /// Names the cards the grid does not draw.
  ///
  /// In en, this message translates to:
  /// **'{remaining} more to collect'**
  String collectiblesRemaining(int remaining);

  /// How far the collection has got.
  ///
  /// In en, this message translates to:
  /// **'{earned} of {total}'**
  String collectiblesEarnedOfTotal(int earned, int total);

  /// What a screen reader is told the collection holds, after the earned-of-total count.
  ///
  /// In en, this message translates to:
  /// **'{count} cards collected'**
  String collectiblesCollectedSpoken(String count);

  /// What a screen reader is told about a practice group and its size.
  ///
  /// In en, this message translates to:
  /// **'{label}, {count}'**
  String practiceGroupSpoken(String label, int count);

  /// What a screen reader is told about a replayable lesson row.
  ///
  /// In en, this message translates to:
  /// **'{lines}. Replay.'**
  String practiceReplaySpoken(String lines);

  /// What a screen reader is told about a practice row that starts a game or a drill.
  ///
  /// In en, this message translates to:
  /// **'{lines}. Play.'**
  String practicePlaySpoken(String lines);

  /// What a screen reader is told about a module's or a kind's sub-group in the practice list and its size.
  ///
  /// In en, this message translates to:
  /// **'{label}. {count, plural, =1{1 item} other{{count} items}}.'**
  String practiceSubGroupSpoken(String label, int count);

  /// Eyebrow over both dictionary drills in the practice list: where the drill draws from. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'Dictionary'**
  String get practiceDrillEyebrow;

  /// What a screen reader is told the Begin button opens.
  ///
  /// In en, this message translates to:
  /// **'{label}: {title}'**
  String todayBeginSpoken(String label, String title);

  /// Tag on an answer the learner did not pick. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'MISSED'**
  String get optionMissedTag;

  /// Spoken suffix on an option the learner has ticked.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get optionSelected;

  /// Spoken suffix on a sequence step that sits in the right place.
  ///
  /// In en, this message translates to:
  /// **'correct'**
  String get optionCorrectMark;

  /// Unit under the number on the grinder dial. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'CLICKS'**
  String get grinderClicksUnit;

  /// Name of the daily term drill, on its banner and its screen.
  ///
  /// In en, this message translates to:
  /// **'Term of the Day'**
  String get termOfDayTitle;

  /// Says what opening a term does, where there is no full entry to promise. On the Term of the Day banner, and on the peek sheet for a learner without the course.
  ///
  /// In en, this message translates to:
  /// **'Open entry'**
  String get termOpenEntry;

  /// Promises the whole entry, so it raises the gate for a learner without the course. Read on three surfaces — the Term of the Day screen, a gated term entry, and the peek sheet — which say the same words because they promise the same thing.
  ///
  /// In en, this message translates to:
  /// **'Read the full entry'**
  String get termReadFullEntry;

  /// The way out of the Term of the Day screen, under its action.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get termOfDayBack;

  /// Label over the part of a term's entry that needs the course.
  ///
  /// In en, this message translates to:
  /// **'Full explanation · Plus'**
  String get termEntryFullExplanation;

  /// Says what would open a gated term entry.
  ///
  /// In en, this message translates to:
  /// **'Comes with the full course.'**
  String get termEntryComesWithCourse;

  /// Count over a search that found something. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'{found, plural, =1{{found} RESULT} other{{found} RESULTS}}'**
  String searchResultCount(int found);

  /// Line under a search that found nothing, when the list was emptied by a filter rather than a query.
  ///
  /// In en, this message translates to:
  /// **'No terms match that search.'**
  String get searchNoMatchesLine;

  /// What a screen reader is told when a search found nothing and there is no query to name.
  ///
  /// In en, this message translates to:
  /// **'No terms match that search'**
  String get searchNoMatchesLabel;

  /// Line under a search that found nothing for a typed query.
  ///
  /// In en, this message translates to:
  /// **'No terms match “{query}”. Try a broader word — or browse by category.'**
  String searchNoMatchesForLine(String query);

  /// What a screen reader is told when a typed search found nothing.
  ///
  /// In en, this message translates to:
  /// **'No terms match that search: {query}'**
  String searchNoMatchesForLabel(String query);

  /// Name of the flashcards drill, on every entry point and on the screen itself.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get flashcardsTitle;

  /// Empty state: what a deck is made of and how to make one. It teaches rather than apologises.
  ///
  /// In en, this message translates to:
  /// **'Bookmark terms in the dictionary and they become a flashcard deck here — flip to test yourself.'**
  String get flashcardsEmptyBody;

  /// Empty state when the saved terms are all outside the learner's free lessons (#468). Names both ways out.
  ///
  /// In en, this message translates to:
  /// **'The terms you saved are not in your free lessons, so there is nothing to flip yet. Bookmark a term one of your lessons mentions, or unlock the full course to practise all of them.'**
  String get flashcardsEmptyOutOfReachBody;

  /// The empty state's one action.
  ///
  /// In en, this message translates to:
  /// **'Browse the dictionary'**
  String get flashcardsBrowse;

  /// Label over a flashcard's front face, which shows the term.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get flashcardsFrontFace;

  /// Label over a flashcard's back face, which shows the definition.
  ///
  /// In en, this message translates to:
  /// **'Definition'**
  String get flashcardsBackFace;

  /// Foot of a flashcard's front face, saying what a tap does.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get flashcardsTapToReveal;

  /// Foot of a flashcard's back face.
  ///
  /// In en, this message translates to:
  /// **'Tap to see term'**
  String get flashcardsTapToSeeTerm;

  /// Link under a revealed flashcard.
  ///
  /// In en, this message translates to:
  /// **'View full entry'**
  String get flashcardsViewEntry;

  /// Ends the review on the last card. The only button the deck keeps.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get flashcardsFinish;

  /// The focus-revealed way back through the deck, which a pointer user never sees.
  ///
  /// In en, this message translates to:
  /// **'Previous card'**
  String get flashcardsPreviousCard;

  /// The forward twin of the way back, shown until the last card.
  ///
  /// In en, this message translates to:
  /// **'Next card'**
  String get flashcardsNextCard;

  /// Re-deals the same cards in a new order.
  ///
  /// In en, this message translates to:
  /// **'Shuffle deck'**
  String get flashcardsShuffle;

  /// What the results number counts.
  ///
  /// In en, this message translates to:
  /// **'{cards, plural, =1{Term reviewed} other{Terms reviewed}}'**
  String flashcardsReviewedNote(int cards);

  /// The message closing a finished deck.
  ///
  /// In en, this message translates to:
  /// **'That’s every term you’ve saved. Run it back shuffled, or bookmark more in the dictionary.'**
  String get flashcardsResultsMessage;

  /// The results' primary action.
  ///
  /// In en, this message translates to:
  /// **'Shuffle and go again'**
  String get flashcardsGoAgain;

  /// The results' way out.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get flashcardsDone;

  /// The line over the deck, counting what is in it.
  ///
  /// In en, this message translates to:
  /// **'{cards, plural, =1{{cards} saved term} other{{cards} saved terms}}'**
  String flashcardsDeckLine(int cards);

  /// The shelf's row into the drill.
  ///
  /// In en, this message translates to:
  /// **'{cards, plural, =1{Study {cards} term as flashcards} other{Study {cards} terms as flashcards}}'**
  String flashcardsStudyRow(int cards);

  /// Name of the vocab drill, on every surface that opens it.
  ///
  /// In en, this message translates to:
  /// **'Guess the term'**
  String get vocabTitle;

  /// The dictionary quick chip's hint, saying what the drill asks.
  ///
  /// In en, this message translates to:
  /// **'From the definition'**
  String get vocabRowSubtitle;

  /// Line under the title on the drill's setup screen.
  ///
  /// In en, this message translates to:
  /// **'Read a definition, pick the term. Choose your deck and how long a round you want.'**
  String get vocabSetupBlurb;

  /// Heading over the deck choices on setup.
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get vocabDeckHeading;

  /// Heading over the length choices on setup.
  ///
  /// In en, this message translates to:
  /// **'Round length'**
  String get vocabLengthHeading;

  /// Name of the shortest offered round.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get vocabLengthQuick;

  /// Name of the middle offered round.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get vocabLengthStandard;

  /// Name of the longest offered round.
  ///
  /// In en, this message translates to:
  /// **'Deep'**
  String get vocabLengthDeep;

  /// The bookmarked-terms deck's row.
  ///
  /// In en, this message translates to:
  /// **'Saved terms'**
  String get vocabSavedDeck;

  /// What the saved deck offers once it has enough on it.
  ///
  /// In en, this message translates to:
  /// **'The terms you have bookmarked'**
  String get vocabSavedDeckReady;

  /// What the saved deck says before it has enough. Stated as the number it needs, so the row explains itself rather than only refusing.
  ///
  /// In en, this message translates to:
  /// **'Save {minimum} or more terms to unlock'**
  String vocabSavedDeckShort(int minimum);

  /// The missed-terms deck's row.
  ///
  /// In en, this message translates to:
  /// **'Review misses'**
  String get vocabMissesDeck;

  /// What the misses deck offers once enough terms are owed a review.
  ///
  /// In en, this message translates to:
  /// **'Terms you have missed before'**
  String get vocabMissesDeckReady;

  /// What the misses deck says before then. States the condition rather than asking for it — nobody sets out to miss questions.
  ///
  /// In en, this message translates to:
  /// **'Miss a few first'**
  String get vocabMissesDeckShort;

  /// The all-terms deck's row, for a learner who owns the course.
  ///
  /// In en, this message translates to:
  /// **'Whole glossary'**
  String get vocabAllDeck;

  /// The all-terms deck's row for a free learner, whose pool the course scoped.
  ///
  /// In en, this message translates to:
  /// **'Your terms'**
  String get vocabYourTermsDeck;

  /// What the all-terms deck holds for a learner who owns the course.
  ///
  /// In en, this message translates to:
  /// **'Every term in the dictionary'**
  String get vocabAllDeckNote;

  /// What a free learner's deck holds. Mentioned, not taught — ADR-0014's rule.
  ///
  /// In en, this message translates to:
  /// **'Every term your lessons mention'**
  String get vocabYourTermsNote;

  /// The whole-deck length card, shown when no offered length fits.
  ///
  /// In en, this message translates to:
  /// **'Every term in this deck'**
  String get vocabWholeDeck;

  /// Nudge under a saved deck too short for the longer rounds.
  ///
  /// In en, this message translates to:
  /// **'Longer rounds unlock as you bookmark more terms.'**
  String get vocabLongerRoundsHint;

  /// Nudge under a misses deck too short for the longer rounds.
  ///
  /// In en, this message translates to:
  /// **'Longer rounds unlock as you log more misses.'**
  String get vocabLongerMissRoundsHint;

  /// Starts the drill.
  ///
  /// In en, this message translates to:
  /// **'Start round'**
  String get vocabStart;

  /// The question's lead-in.
  ///
  /// In en, this message translates to:
  /// **'Which term means…'**
  String get vocabQuestionLead;

  /// Advances past an answered question.
  ///
  /// In en, this message translates to:
  /// **'Next question'**
  String get vocabNext;

  /// Ends the last question.
  ///
  /// In en, this message translates to:
  /// **'See score'**
  String get vocabSeeScore;

  /// Link out of an answered question into the term's entry.
  ///
  /// In en, this message translates to:
  /// **'See the full entry'**
  String get vocabReadEntry;

  /// Runs the drill again with a fresh draw.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get vocabPlayAgain;

  /// Returns to setup to pick a different deck or length.
  ///
  /// In en, this message translates to:
  /// **'Change round'**
  String get vocabChangeRound;

  /// Heading shown when the pool cannot fill a question. The drill never pads from the full glossary.
  ///
  /// In en, this message translates to:
  /// **'A few more terms first'**
  String get vocabTeachingTitle;

  /// Body of the teaching state, naming what would actually help.
  ///
  /// In en, this message translates to:
  /// **'The game draws on the terms your lessons mention, and it needs at least {minimum}. Play a lesson or two and come back.'**
  String vocabTeachingBody(int minimum);

  /// The teaching state's way out.
  ///
  /// In en, this message translates to:
  /// **'Back to learning'**
  String get vocabTeachingAction;

  /// Announced while the drill's pools resolve.
  ///
  /// In en, this message translates to:
  /// **'Loading the drill'**
  String get vocabLoading;

  /// Shown when the drill's pools cannot be read.
  ///
  /// In en, this message translates to:
  /// **'This drill could not be loaded.'**
  String get vocabLoadFailed;

  /// What a screen reader is told about the learner's place in a round.
  ///
  /// In en, this message translates to:
  /// **'Question {position} of {total}'**
  String vocabProgress(int position, int total);

  /// What a screen reader is told about the right choice once a question is answered.
  ///
  /// In en, this message translates to:
  /// **'{term}, correct'**
  String vocabAnsweredChoiceCorrect(String term);

  /// What a screen reader is told about a wrong choice once a question is answered.
  ///
  /// In en, this message translates to:
  /// **'{term}, incorrect'**
  String vocabAnsweredChoiceIncorrect(String term);

  /// Verdict over a missed question. Names the term, which is the whole teaching moment. Opens on the same words as every other wrong answer, spelled out here so a translator has the whole sentence.
  ///
  /// In en, this message translates to:
  /// **'Not quite — it\'s {answer}'**
  String vocabVerdictWrong(String answer);

  /// Verdict over an answered question the learner got right.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get vocabCorrectVerdict;

  /// What the score adds when the round was drawn from the review deck, where a missed term was already in it. Opens on a space, joining the line before it.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{ The {count} term you missed was kept in your review deck.} other{ The {count} terms you missed were kept in your review deck.}}'**
  String vocabReviewDeckKept(int count);

  /// What the score adds when the round was not drawn from the review deck. Opens on a space, joining the line before it.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{ The {count} term you missed was added to your review deck.} other{ The {count} terms you missed were added to your review deck.}}'**
  String vocabReviewDeckAdded(int count);

  /// Line under a score for a round with no questions.
  ///
  /// In en, this message translates to:
  /// **'Nothing to drill here yet.'**
  String get vocabNothingToDrill;

  /// Line under a perfect score.
  ///
  /// In en, this message translates to:
  /// **'Every one of them. That is the whole deck.'**
  String get vocabWholeDeckScore;

  /// Line under a strong score.
  ///
  /// In en, this message translates to:
  /// **'Sharp palate. You know these cold.'**
  String get vocabSharpPalate;

  /// Line under a middling score.
  ///
  /// In en, this message translates to:
  /// **'Solid round — run it back to sharpen up.'**
  String get vocabSolidRound;

  /// Line under a weak score.
  ///
  /// In en, this message translates to:
  /// **'Worth another pass. The definitions stick faster the second time.'**
  String get vocabWorthAnotherPass;

  /// Line under the shelf when a free learner holds more than the cap allows — saved on Plus, and the cap refuses new saves rather than taking any away.
  ///
  /// In en, this message translates to:
  /// **'{count} saved · free limit {limit}'**
  String savedCountOverLimit(int count, int limit);

  /// Line under the shelf, counting a free learner's saves against the cap.
  ///
  /// In en, this message translates to:
  /// **'{count} of {limit} saved'**
  String savedCountOfLimit(int count, int limit);

  /// Heading over the saved dictionary terms.
  ///
  /// In en, this message translates to:
  /// **'Dictionary terms'**
  String get savedGroupTerms;

  /// Heading over the saved lessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get savedGroupLessons;

  /// Heading over the saved visual guides.
  ///
  /// In en, this message translates to:
  /// **'Visual guides'**
  String get savedGroupGuides;

  /// How many rows the shelf holds, said in words.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} item} other{{count} items}}'**
  String savedItemCount(int count);

  /// Subtitle on a saved term whose category the bank no longer carries.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get savedTermSubtitle;

  /// Subtitle on a saved lesson, naming the module it sits in.
  ///
  /// In en, this message translates to:
  /// **'Module {number} · {label}'**
  String savedLessonSubtitle(int number, String label);

  /// Subtitle on a saved visual guide.
  ///
  /// In en, this message translates to:
  /// **'Visual guide · {label}'**
  String savedGuideSubtitle(String label);

  /// What a screen reader is told the bookmark control would save.
  ///
  /// In en, this message translates to:
  /// **'Save {label}'**
  String savedBookmarkAdd(String label);

  /// What a screen reader is told the bookmark control would unsave.
  ///
  /// In en, this message translates to:
  /// **'Remove {label} from Saved'**
  String savedBookmarkRemove(String label);

  /// Heading on the empty saved shelf.
  ///
  /// In en, this message translates to:
  /// **'Your saved shelf is empty'**
  String get savedEmptyTitle;

  /// Body on the empty saved shelf, saying how things get here.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet. Tap the bookmark on any lesson, term or visual guide and it lands here for quick review.'**
  String get savedEmptyBody;

  /// Kicker over the Saved entry card on Profile — the small line above its heading.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedEntryTitle;

  /// Heading on the Saved entry card on Profile, under its kicker.
  ///
  /// In en, this message translates to:
  /// **'Your favorites'**
  String get savedEntrySubtitle;

  /// What the Saved entry card says it holds.
  ///
  /// In en, this message translates to:
  /// **'{count} saved to revisit'**
  String savedEntryCount(int count);

  /// A saved group's heading and how many rows are under it.
  ///
  /// In en, this message translates to:
  /// **'{label} · {count}'**
  String savedGroupHeading(String label, int count);

  /// Title of the Saved screen.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get savedScreenTitle;

  /// Announced while the saved shelf resolves.
  ///
  /// In en, this message translates to:
  /// **'Loading your saved items'**
  String get savedLoading;

  /// Shown when the saved shelf cannot be read.
  ///
  /// In en, this message translates to:
  /// **'Your saved items could not be loaded'**
  String get savedLoadFailed;

  /// Offer under a full free shelf.
  ///
  /// In en, this message translates to:
  /// **'Your shelf is full. Unlock Plus to save without a limit.'**
  String get savedUpgradeLine;

  /// Tour stop 1, on the Today card. The design's own script (#536).
  ///
  /// In en, this message translates to:
  /// **'Today starts here'**
  String get tourTodayTitle;

  /// Body of tour stop 1.
  ///
  /// In en, this message translates to:
  /// **'Your next lesson always waits in this card.'**
  String get tourTodayBody;

  /// Tour stop 2, on the practice area.
  ///
  /// In en, this message translates to:
  /// **'Practice again, any time'**
  String get tourPracticeTitle;

  /// Body of tour stop 2.
  ///
  /// In en, this message translates to:
  /// **'Lessons you finish collect here, with quick practice formats beside them.'**
  String get tourPracticeBody;

  /// Tour stop 3, on the header's Saved and Dictionary entries.
  ///
  /// In en, this message translates to:
  /// **'Saved and Dictionary'**
  String get tourHeaderTitle;

  /// Body of tour stop 3.
  ///
  /// In en, this message translates to:
  /// **'Anything you bookmark lands behind the ribbon; every coffee term you meet joins the book beside it.'**
  String get tourHeaderBody;

  /// Tour stop 4, on the bottom tab bar.
  ///
  /// In en, this message translates to:
  /// **'Find your way'**
  String get tourTabsTitle;

  /// Body of tour stop 4.
  ///
  /// In en, this message translates to:
  /// **'Path holds the whole course, Collection your earned cards, Profile your streak and coffee tree.'**
  String get tourTabsBody;

  /// The tour card's left-hand button, on every stop.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get tourSkip;

  /// What Skip is announced as, so one word does not stand alone in a screen reader's list of controls.
  ///
  /// In en, this message translates to:
  /// **'Skip the introduction'**
  String get tourSkipSemantics;

  /// The tour card's right-hand button on stops 1–3.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tourNext;

  /// The same button on the last stop, where advancing is finishing.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tourDone;

  /// What assistive technology calls the running tour.
  ///
  /// In en, this message translates to:
  /// **'Introduction to Today'**
  String get tourLayerSemantics;

  /// The App Guide row that replays the tour.
  ///
  /// In en, this message translates to:
  /// **'Replay Today introduction'**
  String get tourReplayTitle;

  /// Supporting line under the replay row.
  ///
  /// In en, this message translates to:
  /// **'Runs the short first-open tour again'**
  String get tourReplayBody;

  /// Which tour stop the learner is on.
  ///
  /// In en, this message translates to:
  /// **'{position} of {total}'**
  String tourStepOf(int position, int total);

  /// Closes a micro-tip.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get microTipDismiss;

  /// Title of the App Guide screen, and the Settings row that opens it.
  ///
  /// In en, this message translates to:
  /// **'App Guide'**
  String get appGuideTitle;

  /// Supporting line on the Settings row into the App Guide.
  ///
  /// In en, this message translates to:
  /// **'What each part does, plus the Today intro'**
  String get appGuideSettingsRowBody;

  /// Sentence under the App Guide's title.
  ///
  /// In en, this message translates to:
  /// **'What each part of BrewPath does, in a line or two.'**
  String get appGuideLead;

  /// The App Guide section the replay row sits in, at its foot.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get appGuideIntroSection;

  /// App Guide entry for the Today tab.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get appGuideTodayTitle;

  /// What the App Guide says the Today tab does.
  ///
  /// In en, this message translates to:
  /// **'Your daily start: the next lesson, any active Coffee Challenge, and practice worth revisiting.'**
  String get appGuideTodayBody;

  /// App Guide entry for the Path tab.
  ///
  /// In en, this message translates to:
  /// **'Learning Path'**
  String get appGuidePathTitle;

  /// What the App Guide says the Path tab does.
  ///
  /// In en, this message translates to:
  /// **'The whole course in order. Each finished lesson unlocks the next; diamonds along the line are Coffee Challenges.'**
  String get appGuidePathBody;

  /// App Guide entry for practice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get appGuidePracticeTitle;

  /// What the App Guide says practice does.
  ///
  /// In en, this message translates to:
  /// **'Replay finished lessons or drill the practice formats from Today. Reviews sharpen you but never change your points.'**
  String get appGuidePracticeBody;

  /// App Guide entry for the brew challenges.
  ///
  /// In en, this message translates to:
  /// **'Brew Challenges'**
  String get appGuideChallengesTitle;

  /// What the App Guide says the challenges do.
  ///
  /// In en, this message translates to:
  /// **'Real-world brewing tasks. Start one, make it within 48 hours, then log the result on Today to earn its stamp.'**
  String get appGuideChallengesBody;

  /// App Guide entry for the dictionary and the saved shelf.
  ///
  /// In en, this message translates to:
  /// **'Dictionary & Saved'**
  String get appGuideDictionaryTitle;

  /// What the App Guide says the dictionary and shelf do.
  ///
  /// In en, this message translates to:
  /// **'Terms join the Dictionary as lessons introduce them. Anything you bookmark waits in Saved, at the top of Today.'**
  String get appGuideDictionaryBody;

  /// App Guide entry for the coffee tree.
  ///
  /// In en, this message translates to:
  /// **'Coffee Tree'**
  String get appGuideTreeTitle;

  /// What the App Guide says the tree does.
  ///
  /// In en, this message translates to:
  /// **'Grows a stage as you complete core lessons, from seed to harvest. Only lessons grow it — it lives on your Profile.'**
  String get appGuideTreeBody;

  /// App Guide entry for the streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get appGuideStreakTitle;

  /// What the App Guide says the streak does. Rewritten from the design under a product-owner ruling (#338), because its first sentence named one of six qualifying activities and read as the only one.
  ///
  /// In en, this message translates to:
  /// **'One finished activity a day keeps it alive — a lesson, a replay, or practice. Every 7 days in a row earns a streak freeze (you hold one at a time); it covers a missed day automatically.'**
  String get appGuideStreakBody;

  /// Kicker on the path micro-tip. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'YOUR PATH'**
  String get microTipPathEyebrow;

  /// One-line claim on the path micro-tip.
  ///
  /// In en, this message translates to:
  /// **'The whole course, in order'**
  String get microTipPathTitle;

  /// The rule the path micro-tip exists to state.
  ///
  /// In en, this message translates to:
  /// **'Each finished lesson unlocks the next, top to bottom. The diamonds branching off the line are hands-on Coffee Challenges.'**
  String get microTipPathBody;

  /// Kicker on the brew micro-tip. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'COFFEE CHALLENGE'**
  String get microTipBrewEyebrow;

  /// One-line claim on the brew micro-tip.
  ///
  /// In en, this message translates to:
  /// **'A real brew, not a quiz'**
  String get microTipBrewTitle;

  /// The rule the brew micro-tip exists to state.
  ///
  /// In en, this message translates to:
  /// **'Make it at your own pace within 48 hours, then log the result here on Today. Logging it earns the challenge’s stamp.'**
  String get microTipBrewBody;

  /// Kicker on the tree micro-tip. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'COFFEE TREE'**
  String get microTipTreeEyebrow;

  /// One-line claim on the tree micro-tip.
  ///
  /// In en, this message translates to:
  /// **'Your tree just grew'**
  String get microTipTreeTitle;

  /// The rule the tree micro-tip exists to state.
  ///
  /// In en, this message translates to:
  /// **'Completing that lesson pushed it toward harvest. Only core lessons grow it — see it any time from your Profile.'**
  String get microTipTreeBody;

  /// Kicker on the saved micro-tip. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'SAVED'**
  String get microTipSavedEyebrow;

  /// One-line claim on the saved micro-tip.
  ///
  /// In en, this message translates to:
  /// **'Kept for later'**
  String get microTipSavedTitle;

  /// The rule the saved micro-tip exists to state.
  ///
  /// In en, this message translates to:
  /// **'Everything you save waits behind the ribbon at the top of Today — lessons, terms and guides on one shelf.'**
  String get microTipSavedBody;

  /// Kicker on the dictionary micro-tip. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'DICTIONARY'**
  String get microTipDictionaryEyebrow;

  /// One-line claim on the dictionary micro-tip.
  ///
  /// In en, this message translates to:
  /// **'Every term you’ve met'**
  String get microTipDictionaryTitle;

  /// The rule the dictionary micro-tip exists to state.
  ///
  /// In en, this message translates to:
  /// **'Terms join your Dictionary as lessons introduce them. Search them here, or drill them with flashcards.'**
  String get microTipDictionaryBody;

  /// Kicker on the freeze micro-tip. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'STREAK FREEZE'**
  String get microTipFreezeEyebrow;

  /// One-line claim on the freeze micro-tip.
  ///
  /// In en, this message translates to:
  /// **'A safety net you’ve earned'**
  String get microTipFreezeTitle;

  /// The rule the freeze micro-tip exists to state.
  ///
  /// In en, this message translates to:
  /// **'Every 7 streak days in a row earns a freeze; you hold one at a time. Miss a day and it’s spent for you — your streak survives.'**
  String get microTipFreezeBody;

  /// Kicker on the studio micro-tip. Set upper case by the design.
  ///
  /// In en, this message translates to:
  /// **'STUDIO'**
  String get microTipStudioEyebrow;

  /// One-line claim on the studio micro-tip.
  ///
  /// In en, this message translates to:
  /// **'Make it yours'**
  String get microTipStudioTitle;

  /// The rule the studio micro-tip exists to state.
  ///
  /// In en, this message translates to:
  /// **'Dress Roasty and choose your tree’s variety and light. The look you set here applies everywhere in the app.'**
  String get microTipStudioBody;

  /// Title of the dictionary index.
  ///
  /// In en, this message translates to:
  /// **'Coffee Dictionary'**
  String get dictionaryTitle;

  /// Heading over the whole dictionary index, before a category is chosen.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get dictionaryAllCategories;

  /// Announced while the dictionary resolves.
  ///
  /// In en, this message translates to:
  /// **'Loading the dictionary'**
  String get dictionaryLoading;

  /// Shown when the dictionary cannot be read.
  ///
  /// In en, this message translates to:
  /// **'The dictionary could not be loaded'**
  String get dictionaryLoadFailed;

  /// Placeholder in the dictionary's search field.
  ///
  /// In en, this message translates to:
  /// **'Search terms, e.g. crema, bloom…'**
  String get dictionarySearchHint;

  /// First-run hint on the dictionary list.
  ///
  /// In en, this message translates to:
  /// **'Swipe a term right to save it'**
  String get dictionarySwipeToSave;

  /// What a screen reader is told about a dictionary category.
  ///
  /// In en, this message translates to:
  /// **'{label}, {count} terms. {summary}'**
  String dictionaryCategorySpoken(String label, int count, String summary);

  /// A term the learner's lessons have taught.
  ///
  /// In en, this message translates to:
  /// **'Learned'**
  String get statusLearned;

  /// A term a lesson ahead of the learner will teach.
  ///
  /// In en, this message translates to:
  /// **'To learn'**
  String get statusToLearn;

  /// A term no lesson teaches, kept for looking up.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get statusReference;

  /// Heading over the lesson that taught a term.
  ///
  /// In en, this message translates to:
  /// **'Where you learned it'**
  String get statusPathLearned;

  /// Heading over the lesson that will teach a term.
  ///
  /// In en, this message translates to:
  /// **'Where you\'ll learn it'**
  String get statusPathToLearn;

  /// Heading on a term no lesson teaches.
  ///
  /// In en, this message translates to:
  /// **'Not on the path'**
  String get statusPathReference;

  /// Dictionary filter showing every term.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Title when the term that was opened no longer exists.
  ///
  /// In en, this message translates to:
  /// **'Not in the dictionary'**
  String get termDetailNotInDictionary;

  /// Announced while a term's entry resolves.
  ///
  /// In en, this message translates to:
  /// **'Loading the term'**
  String get termDetailLoading;

  /// Shown when a term's entry cannot be read.
  ///
  /// In en, this message translates to:
  /// **'The term could not be loaded'**
  String get termDetailLoadFailed;

  /// Body when the term that was opened no longer exists.
  ///
  /// In en, this message translates to:
  /// **'That term is not in the dictionary.'**
  String get termDetailMissing;

  /// Announced while Term of the Day resolves.
  ///
  /// In en, this message translates to:
  /// **'Loading today\'s term'**
  String get termOfDayLoading;

  /// Shown when Term of the Day cannot be read.
  ///
  /// In en, this message translates to:
  /// **'Today\'s term could not be loaded'**
  String get termOfDayLoadFailed;

  /// Shown when the pool has no term to offer today.
  ///
  /// In en, this message translates to:
  /// **'There is no term for today.'**
  String get termOfDayNone;

  /// What a reference-only term says instead of naming a lesson. The dash means not on the path at all; promising a lesson here would promise one the course does not have.
  ///
  /// In en, this message translates to:
  /// **'No lesson covers this one — it\'s here for when you meet it on a bag or a menu.'**
  String get termReferenceNote;

  /// Heading over the terms an entry points at.
  ///
  /// In en, this message translates to:
  /// **'Related terms'**
  String get termRelated;

  /// Heading over an entry's self-check.
  ///
  /// In en, this message translates to:
  /// **'Knowledge check'**
  String get termKnowledgeCheck;

  /// What a screen reader is told about a reachable lesson row on an entry.
  ///
  /// In en, this message translates to:
  /// **'{title}, opens the lesson'**
  String termLessonOpens(String title);

  /// What a screen reader is told about a lesson row the learner cannot open.
  ///
  /// In en, this message translates to:
  /// **'{title}, locked'**
  String termLessonLocked(String title);

  /// What a screen reader is told about a term row and its status.
  ///
  /// In en, this message translates to:
  /// **'{term}, {status}'**
  String termSpoken(String term, String status);

  /// Saves a term from its entry.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get termSave;

  /// Says a term is already on the saved shelf.
  ///
  /// In en, this message translates to:
  /// **'Already saved'**
  String get termAlreadySaved;

  /// Verdict when a term's self-check was answered right.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get termSelfCheckCorrect;

  /// What a screen reader is told about the right choice on a term's self-check.
  ///
  /// In en, this message translates to:
  /// **'{text}, correct'**
  String termSelfCheckChoiceCorrect(String text);

  /// What a screen reader is told about a wrong choice on a term's self-check.
  ///
  /// In en, this message translates to:
  /// **'{text}, incorrect'**
  String termSelfCheckChoiceIncorrect(String text);

  /// Heading over where an entry's facts came from.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get termSources;

  /// What a screen reader is told the sources block holds.
  ///
  /// In en, this message translates to:
  /// **'Sources, {count}'**
  String termSourcesSpoken(int count);

  /// What a screen reader is told a source link does.
  ///
  /// In en, this message translates to:
  /// **'{label}, opens in the browser'**
  String termSourceOpens(String label);

  /// What a screen reader is told the pronounce control would say.
  ///
  /// In en, this message translates to:
  /// **'Pronounce {word}'**
  String termPronounce(String word);

  /// First-run hint on the flashcard deck.
  ///
  /// In en, this message translates to:
  /// **'Swipe the card left for the next term'**
  String get flashcardsSwipeHint;

  /// What a screen reader is told a revealed flashcard says.
  ///
  /// In en, this message translates to:
  /// **'{term}. {explanation}'**
  String flashcardsFaceSpoken(String term, String explanation);

  /// Announced while the flashcard deck resolves.
  ///
  /// In en, this message translates to:
  /// **'Loading your deck'**
  String get flashcardsDeckLoading;

  /// Shown when the flashcard deck cannot be read.
  ///
  /// In en, this message translates to:
  /// **'Your deck could not be loaded'**
  String get flashcardsDeckLoadFailed;

  /// What a screen reader is told about the learner's place in the deck.
  ///
  /// In en, this message translates to:
  /// **'Card {card} of {total}'**
  String flashcardsCardOf(int card, int total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
