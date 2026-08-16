# BrewPath — Firebase

## Services In Scope for MVP

| Service       | Package                  | Purpose                               |
| ------------- | ------------------------ | ------------------------------------- |
| Analytics     | `firebase_analytics`     | Track screen views and lesson events  |
| Crashlytics   | `firebase_crashlytics`   | Catch and report unhandled exceptions |
| Remote Config | `firebase_remote_config` | Feature flags and tunable values      |

Firebase Auth, Firestore, Cloud Functions, and Firebase Storage are **not used in MVP**.

---

## iOS Setup Steps

- [ ] Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com) _(manual — user)_
- [ ] Register an iOS app with bundle ID `dev.maximsan.brewPath` _(manual — user)_
- [ ] Download `GoogleService-Info.plist` _(manual — user)_
- [ ] Place `GoogleService-Info.plist` at `ios/Runner/GoogleService-Info.plist` _(manual — user)_
- [ ] In Xcode: select Runner target → Build Phases → Copy Bundle Resources → add `GoogleService-Info.plist` _(manual — user)_
- [ ] Verify `GoogleService-Info.plist` is NOT in `.gitignore` (it is safe to commit for iOS — it contains no secrets, only public identifiers) _(manual — user)_
- [ ] Enable Crashlytics in Firebase Console (Project → Crashlytics → Enable) _(manual — user)_
- [ ] Enable Remote Config in Firebase Console (Project → Remote Config → Create Configuration) _(manual — user)_
- [ ] Run `flutterfire configure` from project root to generate `lib/firebase_options.dart`: _(manual — user)_
  ```bash
  dart pub global activate flutterfire_cli
  flutterfire configure --project=your-firebase-project-id
  ```
- [ ] Commit `lib/firebase_options.dart` to version control _(manual — user)_

---

## AnalyticsService

### Interface

```dart
// lib/services/analytics/analytics_service.dart
abstract class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object>? parameters});
  Future<void> logScreen(String screenName);
  Future<void> setUserId(String? userId);  // null clears the user ID
}
```

### Firebase Implementation

```dart
// lib/services/analytics/firebase_analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:brew_path/services/analytics/analytics_service.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  final _analytics = FirebaseAnalytics.instance;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) =>
      _analytics.logEvent(name: name, parameters: parameters);

  @override
  Future<void> logScreen(String screenName) =>
      _analytics.logScreenView(screenName: screenName);

  @override
  Future<void> setUserId(String? userId) =>
      _analytics.setUserId(id: userId);
}
```

### No-Op Implementation (for tests)

```dart
// lib/services/analytics/noop_analytics_service.dart
import 'package:brew_path/services/analytics/analytics_service.dart';

class NoOpAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}

  @override
  Future<void> logScreen(String screenName) async {}

  @override
  Future<void> setUserId(String? userId) async {}
}
```

### Provider

```dart
// lib/services/analytics/analytics_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:brew_path/services/analytics/analytics_service.dart';
import 'package:brew_path/services/analytics/noop_analytics_service.dart';

part 'analytics_provider.g.dart';

// No-Op while kUseFirebase == false; activation swaps this one line.
@riverpod
AnalyticsService analyticsService(Ref ref) => const NoOpAnalyticsService();
```

---

## Analytics Event Naming Convention

All event names use `snake_case`. Parameters are also `snake_case` string keys with `String`, `int`, or `double` values (Firebase Analytics limitation).

The events that actually fire (source of truth:
`lib/features/lessons/domain/lesson_completion_service.dart` and
`lib/features/lessons/presentation/lesson_screen.dart` — regenerate this table
from them):

| Event Name         | When Fired                            |
| ------------------ | ------------------------------------- |
| `lesson_started`   | User starts a lesson                  |
| `lesson_completed` | First-time lesson completion          |
| `lesson_reviewed`  | Completed replay / practice run       |
| `card_unlocked`    | Coffee Card earned                    |
| `module_unlocked`  | Next module unlocked                  |
| `xp_earned`        | Points awarded (`source`: lesson, practice, module_bonus) |

Screen views are not a `logEvent` — they flow through
`AnalyticsService.logScreen` via `lib/app/analytics_navigator_observer.dart`,
wired into go_router.

### Where Events Are Fired

- Screen views → the navigator observer, never in `build()`
- Lesson/card/module events → `LessonCompletionService` (domain layer) after persistence writes, not from widgets

---

## CrashReportingService

### Interface

```dart
// lib/services/crash_reporting/crash_reporting_service.dart
abstract class CrashReportingService {
  Future<void> recordError(Object error, StackTrace? stack, {bool fatal = false});
  Future<void> log(String message);
  Future<void> setCustomKey(String key, Object value);
}
```

### Firebase Implementation

```dart
// lib/services/crash_reporting/firebase_crashlytics_service.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:brew_path/services/crash_reporting/crash_reporting_service.dart';

class FirebaseCrashlyticsService implements CrashReportingService {
  final _crashlytics = FirebaseCrashlytics.instance;

  @override
  Future<void> recordError(Object error, StackTrace? stack, {bool fatal = false}) =>
      _crashlytics.recordError(error, stack, fatal: fatal);

  @override
  Future<void> log(String message) => _crashlytics.log(message);

  @override
  Future<void> setCustomKey(String key, Object value) =>
      _crashlytics.setCustomKey(key, value);
}
```

### Global Error Wiring in main.dart

Both handlers are wired in `lib/main.dart` — **gated**, so a Firebase-less
build keeps Flutter's default error reporting:

```dart
// Installed only once Firebase is active (lib/main.dart)
if (kUseFirebase) {
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
    );
    return true;
  };
}
```

---

## RemoteConfigService

### Interface

```dart
// lib/services/remote_config/remote_config_service.dart
abstract class RemoteConfigService {
  Future<void> fetchAndActivate();
  String getString(String key);
  bool getBool(String key);
  int getInt(String key);
  double getDouble(String key);
}
```

### Remote Config Keys

```dart
// lib/services/remote_config/remote_config_keys.dart
abstract class RemoteConfigKeys {
  static const String forceUpdateMinVersion = 'force_update_min_version';
  static const String dailyLessonGoal = 'daily_lesson_goal';
  static const String enableCardAnimations = 'enable_card_animations';
}
```

### Firebase Implementation

```dart
// lib/services/remote_config/firebase_remote_config_service.dart
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:brew_path/services/remote_config/remote_config_service.dart';

class FirebaseRemoteConfigService implements RemoteConfigService {
  final _config = FirebaseRemoteConfig.instance;

  @override
  Future<void> fetchAndActivate() async {
    await _config.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await _config.setDefaults({
      RemoteConfigKeys.forceUpdateMinVersion: '0.0.0',
      RemoteConfigKeys.dailyLessonGoal: 1,
      RemoteConfigKeys.enableCardAnimations: false,
    });
    await _config.fetchAndActivate();
  }

  @override String getString(String key) => _config.getString(key);
  @override bool getBool(String key) => _config.getBool(key);
  @override int getInt(String key) => _config.getInt(key);
  @override double getDouble(String key) => _config.getDouble(key);
}
```

- [x] Call `remoteConfigService.fetchAndActivate()` in `AppBootstrap.initialize()` after Firebase init
- [x] All Remote Config reads go through `RemoteConfigService`, never directly via `FirebaseRemoteConfig.instance`

---

## Minimum Remote Config Strategy for MVP

| Key                        | Default   | Purpose                                                   |
| -------------------------- | --------- | --------------------------------------------------------- |
| `force_update_min_version` | `"0.0.0"` | If app version < this value, show a force-update dialog   |
| `daily_lesson_goal`        | `1`       | How many lessons per day counts as meeting the daily goal |
| `enable_card_animations`   | `false`   | Toggle for future animated card unlock reveal             |

---

## Status

All service scaffolding above exists under `lib/services/` (interfaces,
Firebase and No-Op implementations, providers, error handlers), gated off
behind `kUseFirebase == false`. Remaining activation work is manual (user):
the **iOS Setup Steps** checklist at the top of this doc, then flip
`kUseFirebase` + the provider one-liners (see `CLAUDE.md`), then verify a test
crash reaches Crashlytics and events appear in DebugView.
