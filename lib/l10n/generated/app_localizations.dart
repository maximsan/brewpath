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

  /// Caption on the save control once a guide is bookmarked.
  ///
  /// In en, this message translates to:
  /// **'Saved — review anytime in Saved'**
  String get visualSaveCaptionSaved;

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

  /// End label on a calibrate track, naming its far end.
  ///
  /// In en, this message translates to:
  /// **'Very {label}'**
  String sliderVeryLeft(String label);

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

  /// The payoff read as one sentence for a screen reader, when the guess landed.
  ///
  /// In en, this message translates to:
  /// **'{opener} {pick} {andRight}'**
  String payoffSpokenRight(String opener, String pick, String andRight);

  /// The payoff read as one sentence for a screen reader, when the guess missed.
  ///
  /// In en, this message translates to:
  /// **'{opener} {pick}{butActually} {answer} {nowYouKnow}'**
  String payoffSpokenWrong(
    String opener,
    String pick,
    String butActually,
    String answer,
    String nowYouKnow,
  );
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
