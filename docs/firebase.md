# BrewPath — Firebase

Firebase is **gated off**. Every service below exists under `lib/services/`
behind `kUseFirebase` (`lib/core/config/firebase_flags.dart`, currently
`false`), and feature code reaches it only through the abstractions — never
`Firebase*.instance`. Activation is the owner's checklist at the end, then the
flag and one line per provider.

## Services in scope

| Service       | Package                  | Purpose                               |
| ------------- | ------------------------ | ------------------------------------- |
| Analytics     | `firebase_analytics`     | Track screen views and lesson events  |
| Crashlytics   | `firebase_crashlytics`   | Catch and report unhandled exceptions |
| Remote Config | `firebase_remote_config` | Feature flags and tunable values      |

Firebase Auth, Firestore, Cloud Functions and Firebase Storage are not used.

## Where the code is

The interfaces, implementations and providers are the source; this doc does
not restate them — an earlier revision did, and every listing drifted.

| Service | Under `lib/services/` |
|---|---|
| Analytics | `analytics/analytics_service.dart` (the interface) · `firebase_analytics_service.dart` · `noop_analytics_service.dart` · `analytics_provider.dart` |
| Crash reporting | `crash_reporting/crash_reporting_service.dart` · `firebase_crashlytics_service.dart` · `noop_crash_reporting_service.dart` · `crash_reporting_provider.dart` |
| Remote config | `remote_config/remote_config_service.dart` · `firebase_remote_config_service.dart` · `noop_remote_config_service.dart` · `remote_config_keys.dart` · `remote_config_provider.dart` |

Each provider resolves to the No-Op — the do-nothing implementation, explained
in [architecture.md](architecture.md) under _Service Abstraction Pattern_ —
while `kUseFirebase == false`; activation swaps that one line per provider. The global error handlers are wired in
`lib/main.dart`, gated the same way, so a Firebase-less build keeps Flutter's
default error reporting. Remote config is fetched once in
`AppBootstrap.initialize()` (`lib/app/app_bootstrap.dart`) after Firebase
initialises, and every read goes through `RemoteConfigService`.

## Analytics conventions

Event and parameter names are `snake_case`; parameter values are `String`,
`int` or `double`, a Firebase Analytics limit.

The events that fire — the source is `LessonCompletionService`
(`lib/features/lessons/domain/lesson_completion_service.dart`) and the lesson
screen; regenerate this table from them:

| Event Name         | When Fired                            |
| ------------------ | ------------------------------------- |
| `lesson_started`   | User starts a lesson                  |
| `lesson_completed` | First-time lesson completion          |
| `lesson_reviewed`  | Completed replay / practice run       |
| `card_unlocked`    | Coffee Card earned                    |
| `module_unlocked`  | Next module unlocked                  |
| `points_earned`    | Points awarded (`source`: always `lesson` today) |

Screen views are not a `logEvent`; they flow through
`AnalyticsService.logScreen` from `lib/app/analytics_navigator_observer.dart`,
wired into go_router.

**Where events are fired.** Never in a widget's `build`. Screen views come
from the navigator observer; lesson, card and module events from
`LessonCompletionService` after its persistence writes; anything else from a
provider notifier on a state transition, or from an explicit user-action
handler. This keeps widgets pure and tests clean.

## Remote config keys

Declared in `lib/services/remote_config/remote_config_keys.dart` and
defaulted in the Firebase implementation before the first fetch:

| Key                        | Default   | Purpose                                                   |
| -------------------------- | --------- | --------------------------------------------------------- |
| `force_update_min_version` | `"0.0.0"` | If app version < this value, show a force-update dialog   |
| `daily_lesson_goal`        | `1`       | How many lessons per day counts as meeting the daily goal |
| `enable_card_animations`   | `false`   | Toggle for future animated card unlock reveal             |

## Activation (manual — owner)

- [ ] Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
- [ ] Register an iOS app with bundle ID `dev.maximsan.brewPath`
- [ ] Download `GoogleService-Info.plist` and place it at `ios/Runner/GoogleService-Info.plist`
- [ ] In Xcode: Runner target → Build Phases → Copy Bundle Resources → add `GoogleService-Info.plist`
- [ ] Verify `GoogleService-Info.plist` is not in `.gitignore` — it holds public identifiers, no secrets
- [ ] Enable Crashlytics and Remote Config in the Firebase console
- [ ] Run `flutterfire configure` from the project root to generate `lib/firebase_options.dart`, and commit it:
  ```bash
  dart pub global activate flutterfire_cli
  flutterfire configure --project=your-firebase-project-id
  ```
- [ ] Flip `kUseFirebase` and swap the three provider one-liners
- [ ] Verify a test crash reaches Crashlytics and events appear in DebugView
