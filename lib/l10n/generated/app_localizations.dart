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
