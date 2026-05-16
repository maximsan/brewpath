# Coffee Quest — Firebase

## Services In Scope for MVP

| Service | Package | Purpose |
|---|---|---|
| Analytics | `firebase_analytics` | Track screen views and lesson events |
| Crashlytics | `firebase_crashlytics` | Catch and report unhandled exceptions |
| Remote Config | `firebase_remote_config` | Feature flags and tunable values |

Firebase Auth, Firestore, Cloud Functions, and Firebase Storage are **not used in MVP**.

---

## iOS Setup Steps

- [ ] Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
- [ ] Register an iOS app with bundle ID `com.yourcompany.coffeequest`
- [ ] Download `GoogleService-Info.plist`
- [ ] Place `GoogleService-Info.plist` at `ios/Runner/GoogleService-Info.plist`
- [ ] In Xcode: select Runner target → Build Phases → Copy Bundle Resources → add `GoogleService-Info.plist`
- [ ] Verify `GoogleService-Info.plist` is NOT in `.gitignore` (it is safe to commit for iOS — it contains no secrets, only public identifiers)
- [ ] Enable Crashlytics in Firebase Console (Project → Crashlytics → Enable)
- [ ] Enable Remote Config in Firebase Console (Project → Remote Config → Create Configuration)
- [ ] Run `flutterfire configure` from project root to generate `lib/firebase_options.dart`:
  ```bash
  dart pub global activate flutterfire_cli
  flutterfire configure --project=your-firebase-project-id
  ```
- [ ] Commit `lib/firebase_options.dart` to version control

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
import 'analytics_service.dart';

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
import 'analytics_service.dart';

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
import 'analytics_service.dart';
import 'firebase_analytics_service.dart';

part 'analytics_provider.g.dart';

@riverpod
AnalyticsService analyticsService(Ref ref) => FirebaseAnalyticsService();
```

---

## Analytics Event Naming Convention

All event names use `snake_case`. Parameters are also `snake_case` string keys with `String`, `int`, or `double` values (Firebase Analytics limitation).

| Event Name | When Fired | Parameters |
|---|---|---|
| `screen_view` | On screen navigation | `screen_name: String` |
| `lesson_started` | User taps Start on a lesson | `lesson_id: String`, `module_id: String` |
| `lesson_completed` | Lesson completion confirmed | `lesson_id: String`, `module_id: String`, `xp_earned: int` |
| `lesson_step_correct` | Mini-game step answered correctly | `lesson_id: String`, `step_index: int`, `game_type: String` |
| `lesson_step_incorrect` | Mini-game step answered incorrectly | `lesson_id: String`, `step_index: int`, `game_type: String` |
| `card_unlocked` | Coffee Card earned | `card_id: String`, `lesson_id: String` |
| `module_unlocked` | Module unlocked | `module_id: String` |
| `xp_earned` | XP awarded | `amount: int`, `source: String` |

### Where Events Are Fired

- `screen_view` → call in `initState` or via `RouteObserver`, never in `build()`
- Lesson events → call from `LessonCompletionService` (domain layer), not from widgets
- Card/module unlock events → call from `LessonCompletionService` after persistence writes

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
import 'crash_reporting_service.dart';

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

Add after `WidgetsFlutterBinding.ensureInitialized()` and before `runApp()`:

```dart
// Catch Flutter framework errors
FlutterError.onError = (errorDetails) {
  FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
};

// Catch async errors outside Flutter
PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
};
```

- [ ] Add both error handlers in `main.dart` before `runApp()`

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
import 'remote_config_service.dart';

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

- [ ] Call `remoteConfigService.fetchAndActivate()` in `AppBootstrap.initialize()` after Firebase init
- [ ] All Remote Config reads go through `RemoteConfigService`, never directly via `FirebaseRemoteConfig.instance`

---

## Minimum Remote Config Strategy for MVP

| Key | Default | Purpose |
|---|---|---|
| `force_update_min_version` | `"0.0.0"` | If app version < this value, show a force-update dialog |
| `daily_lesson_goal` | `1` | How many lessons per day counts as meeting the daily goal |
| `enable_card_animations` | `false` | Toggle for future animated card unlock reveal |

---

## Steps

- [ ] Create Firebase project and register iOS app
- [ ] Download and place `GoogleService-Info.plist`
- [ ] Run `flutterfire configure` and commit `firebase_options.dart`
- [ ] Enable Crashlytics and Remote Config in Firebase Console
- [ ] Create `lib/services/analytics/analytics_service.dart`
- [ ] Create `lib/services/analytics/firebase_analytics_service.dart`
- [ ] Create `lib/services/analytics/noop_analytics_service.dart`
- [ ] Create `lib/services/analytics/analytics_provider.dart`
- [ ] Create `lib/services/crash_reporting/crash_reporting_service.dart`
- [ ] Create `lib/services/crash_reporting/firebase_crashlytics_service.dart`
- [ ] Create `lib/services/crash_reporting/crash_reporting_provider.dart`
- [ ] Create `lib/services/remote_config/remote_config_service.dart`
- [ ] Create `lib/services/remote_config/remote_config_keys.dart`
- [ ] Create `lib/services/remote_config/firebase_remote_config_service.dart`
- [ ] Create `lib/services/remote_config/remote_config_provider.dart`
- [ ] Add Flutter and platform error handlers in `main.dart`
- [ ] Call `fetchAndActivate()` in `AppBootstrap`
- [ ] Run `build_runner` to generate provider `.g.dart` files
- [ ] Verify: Crashlytics receives a test crash (trigger `FirebaseCrashlytics.instance.crash()` once, then remove)
- [ ] Verify: Analytics events appear in Firebase Console (DebugView)

---

## Definition of Done

- [ ] All three services (Analytics, Crashlytics, Remote Config) have abstract interfaces
- [ ] All three have Firebase implementations and No-Op test implementations
- [ ] All Firebase SDK calls are behind service abstractions — no direct `FirebaseAnalytics.instance` calls in feature code
- [ ] Global error handlers are wired in `main.dart`
- [ ] Remote Config fetches defaults and remote values at startup
- [ ] `NoOpAnalyticsService` is used in all widget and unit tests (via Riverpod override)
- [ ] Test crash confirmed received in Firebase Crashlytics console
