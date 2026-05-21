# Coffee Quest — Dependencies

> **Status (2026-05-20):** This document describes the original **Isar 3.x**
> persistence design. In Phase 3 the project migrated to **Drift 2.30.x**
> (SQLite). The shape of the persistence layer — abstract repositories,
> `AppDatabaseService.instance` singleton, mutable DTOs in
> `shared/storage/*_record.dart` — is preserved, but the code examples below
> reference Isar classes that no longer exist. Treat the JSON content model,
> repository interfaces, and folder layout as authoritative; treat the Isar
> code snippets as historical. Current source of truth: `CLAUDE.md`,
> `pubspec.yaml`, and `lib/shared/storage/app_database.dart`.

---


## Full pubspec.yaml

```yaml
name: coffee_quest
description: Coffee Quest — Duolingo-style coffee education app.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'
  flutter: '>=3.22.0'

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^3.3.1
  riverpod_annotation: ^3.3.1

  # Navigation
  go_router: ^17.2.3

  # Local persistence
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1    # Precompiled native Isar binaries for iOS/Android
  path_provider: ^2.1.4           # Required by Isar for documents directory

  # Firebase — added in Phase 8 only (deferred; app is offline-first for MVP)
  # firebase_core: ^4.8.0
  # firebase_analytics: ^12.4.0
  # firebase_crashlytics: ^5.2.1
  # firebase_remote_config: ^6.5.0

  # Payments (placeholder — not active in MVP)
  in_app_purchase: ^3.2.3

  # Ads (placeholder — not active in MVP)
  google_mobile_ads: ^8.0.0

  # Utilities
  freezed_annotation: ^2.4.4     # Immutable model generation
  json_annotation: ^4.9.0         # JSON serialization for content models
  collection: ^1.19.0             # Dart collection utilities

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

  # Code generation
  build_runner: ^2.4.13
  riverpod_generator: ^3.3.1
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  isar_generator: ^3.1.0+1

  # Linting
  flutter_lints: ^5.0.0
  custom_lint: ^0.7.5
  riverpod_lint: ^3.3.1

flutter:
  uses-material-design: true
  assets:
    - assets/content/
    - assets/images/
    - assets/icons/
```

---

## Dependency Justifications

### State Management

| Package | Version | Reason |
|---|---|---|
| `flutter_riverpod` | ^3.3.1 | Flutter Favorite; type-safe; async-first; no BuildContext required for business logic |
| `riverpod_annotation` | ^3.3.1 | Required for `@riverpod` annotation |
| `riverpod_generator` | ^3.3.1 | Code generation for providers; eliminates boilerplate |
| `riverpod_lint` | ^3.3.1 | Lint rules for common Riverpod mistakes |

### Navigation

| Package | Version | Reason |
|---|---|---|
| `go_router` | ^17.2.3 | Flutter team–maintained; StatefulShellRoute for persistent tab state; future web-ready |

### Local Persistence

| Package | Version | Reason |
|---|---|---|
| `isar` | ^3.1.0+1 | Fast NoSQL database; native queries; multi-isolate safe; better than stale Hive 2.x |
| `isar_flutter_libs` | ^3.1.0+1 | Precompiled Isar native libs — required on mobile to avoid compiling from source |
| `isar_generator` | ^3.1.0+1 | Code generation for Isar `@collection` schemas |
| `path_provider` | ^2.1.4 | Gets the correct documents directory for Isar to store its database |

### Firebase (Phase 8 — deferred)

Firebase packages are commented out in Phase 1–7. The app is local-first and offline-first for MVP. Uncomment and add `GoogleService-Info.plist` only when analytics, crash reporting, or Remote Config is concretely needed.

| Package | Version | Reason |
|---|---|---|
| `firebase_core` | ^4.8.0 | Required by all Firebase packages |
| `firebase_analytics` | ^12.4.0 | User behavior analytics |
| `firebase_crashlytics` | ^5.2.1 | Crash reporting |
| `firebase_remote_config` | ^6.5.0 | Feature flags and remote configuration |

### Monetization Stubs

| Package | Version | Reason |
|---|---|---|
| `in_app_purchase` | ^3.2.3 | Official Flutter package for StoreKit / Google Play Billing; no vendor lock-in |
| `google_mobile_ads` | ^8.0.0 | Official AdMob package; behind abstraction layer in MVP |

### Code Generation

| Package | Version | Reason |
|---|---|---|
| `freezed_annotation` | ^2.4.4 | Annotations for Freezed (immutable models) |
| `freezed` | ^2.5.7 | Generates immutable value classes with `copyWith`, `==`, `hashCode` |
| `json_annotation` | ^4.9.0 | Annotations for json_serializable |
| `json_serializable` | ^6.8.0 | Generates `fromJson`/`toJson` for content models loaded from JSON assets |
| `build_runner` | ^2.4.13 | Runs all code generators |

### Linting

| Package | Version | Reason |
|---|---|---|
| `flutter_lints` | ^5.0.0 | Official recommended lint rules |
| `custom_lint` | ^0.7.5 | Required by riverpod_lint |

---

## analysis_options.yaml

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  plugins:
    - custom_lint
  errors:
    invalid_annotation_target: ignore  # Needed for Freezed

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - avoid_unnecessary_containers
    - sized_box_for_whitespace
    - use_key_in_widget_constructors
```

---

## iOS-Specific Native Setup

### GoogleService-Info.plist
- [ ] Download from Firebase Console → Project Settings → iOS app
- [ ] Place at `ios/Runner/GoogleService-Info.plist`
- [x] Add to Xcode: Runner target → Copy Bundle Resources build phase

### Podfile minimum platform
- [x] `ios/Podfile` must have `platform :ios, '16.0'` on the first non-comment line
- [ ] After editing Podfile, run `pod install` from `ios/` directory

### Capabilities (Xcode)
No special capabilities required for MVP. The following will be needed in future:
- In-App Purchase (when payments go live)
- Push Notifications (when push goes live)

---

## Explicitly Excluded Packages

| Package | Reason for Exclusion |
|---|---|
| `hive` / `hive_flutter` | Stale; no active development; replaced by Isar |
| `drift` | SQL overhead not needed for this data shape |
| `shared_preferences` | Too limited (string/int/bool only); Isar handles all cases |
| `provider` | Superseded by Riverpod for this project |
| `bloc` / `flutter_bloc` | More boilerplate than needed for a one-developer app |
| `get` / `GetX` | Monolithic; opinionated global state; avoid |
| `purchases_flutter` | RevenueCat SDK; adds vendor lock-in; use only if in_app_purchase proves insufficient |
| `appsflyer_sdk` | Attribution; not needed for MVP |
| `amplitude_flutter` | Secondary analytics; Firebase Analytics sufficient for MVP |
| `flutter_native_splash` | Nice-to-have; add post-MVP if needed |
| `lottie` | Animation; not required for MVP |

---

## Definition of Done

- [x] `pubspec.yaml` matches this document exactly (versions pinned with `^`)
- [x] `flutter pub get` completes without errors
- [x] `analysis_options.yaml` is in the project root
- [x] `dart run build_runner build --delete-conflicting-outputs` completes without errors
- [ ] `pod install` completes without CocoaPods errors
- [x] All excluded packages are confirmed absent from pubspec.yaml
