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
