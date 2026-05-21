# Coffee Quest — Project Scaffold

> **Status (2026-05-20):** This document was written for the original
> **Isar 3.x** scaffold. The actual Phase 1/3 implementation uses **Drift 2.30.x**
> (`AppDatabase`, `AppDatabaseService`) instead of `IsarService`. The structural
> work below — `flutter create`, iOS 16 target, bundle ID, code generation,
> bootstrap layout — is unchanged and complete; only the database class names
> differ. Current source of truth: `CLAUDE.md` + `lib/shared/storage/app_database.dart`.

---

## Prerequisites

- Flutter SDK (stable channel, 3.x or later)
- Xcode 16+ with iOS 16.0 SDK
- CocoaPods installed (`sudo gem install cocoapods`)

> Firebase is deferred to Phase 8. No `GoogleService-Info.plist` needed for Phases 1–7.

---

## Steps

### 1. Create the Flutter Project

```bash
flutter create \
  --org dev.maximsan \
  --project-name coffee_quest \
  --platforms ios \
  coffee_quest
```

- [x] Run the command above
- [x] Verify the project directory `coffee_quest/` is created
- [x] Verify `ios/` directory is present, `android/` and `web/` are absent (iOS-only for now)

> If you need Android later, run `flutter create --platforms android .` from the project root to add it without losing any existing code.

---

### 2. Set iOS Minimum Deployment Target

- [x] Open `ios/Podfile`
- [x] Set the minimum platform version:

```ruby
platform :ios, '16.0'
```

- [x] Open `ios/Runner.xcodeproj` in Xcode
- [x] Select the `Runner` target → General → Minimum Deployments → set to **iOS 16.0**
- [x] Also set in `ios/Flutter/AppFrameworkInfo.plist`: verify `MinimumOSVersion` is `16.0`

---

### 3. Set Bundle ID

- [x] In Xcode: Runner target → General → Bundle Identifier: `dev.maximsan.coffeequest`
- [x] Verify in `ios/Runner/Info.plist`: `CFBundleIdentifier` matches

---

### 4. Replace pubspec.yaml

Replace the default `pubspec.yaml` with the full version from `docs/05-dependencies.md`.

- [x] Copy the `pubspec.yaml` content from `docs/05-dependencies.md`
- [x] Paste into `coffee_quest/pubspec.yaml`, replacing all existing content
- [x] Run `flutter pub get` — verify no errors

---

### 5. Create the Folder Structure

Create all directories from `docs/04-folder-structure.md`.

```bash
# Run from the coffee_quest/ project root
mkdir -p lib/app
mkdir -p lib/core/constants lib/core/errors lib/core/utils lib/core/widgets
mkdir -p lib/services/analytics lib/services/crash_reporting
mkdir -p lib/services/remote_config lib/services/ads lib/services/payments
mkdir -p lib/features/learn/data lib/features/learn/domain lib/features/learn/presentation
mkdir -p lib/features/path/data lib/features/path/domain lib/features/path/presentation
mkdir -p lib/features/cards/data lib/features/cards/domain lib/features/cards/presentation
mkdir -p lib/features/profile/data lib/features/profile/domain lib/features/profile/presentation
mkdir -p lib/features/lessons/data lib/features/lessons/domain lib/features/lessons/presentation
mkdir -p lib/features/mini_games/data lib/features/mini_games/domain lib/features/mini_games/presentation
mkdir -p lib/features/progress/data lib/features/progress/domain lib/features/progress/presentation
mkdir -p lib/shared/models lib/shared/repositories lib/shared/storage lib/shared/theme
mkdir -p assets/content assets/images assets/icons
mkdir -p test/unit test/widget
mkdir -p integration_test
mkdir -p .github/workflows
```

- [x] Run the mkdir commands above
- [x] Verify the directory tree matches `docs/04-folder-structure.md`

---

### 6. Create asset directories in pubspec.yaml

In `pubspec.yaml`, under `flutter:`, add:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/content/
    - assets/images/
    - assets/icons/
```

- [x] Add the assets block to pubspec.yaml
- [x] Create placeholder files to avoid empty directory warnings:
  - `assets/content/.gitkeep`
  - `assets/images/.gitkeep`
  - `assets/icons/.gitkeep`

---

### 7. Write main.dart

Create `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app_bootstrap.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.initialize();
  runApp(
    const ProviderScope(
      child: CoffeeQuestApp(),
    ),
  );
}
```

- [x] Create `lib/main.dart` with this content

---

### 8. Write app_bootstrap.dart

Create `lib/app/app_bootstrap.dart`:

```dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../shared/storage/isar_service.dart';

class AppBootstrap {
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      IsarService.schemas,
      directory: dir.path,
    );
    IsarService.instance = isar;
  }
}
```

- [x] Create `lib/app/app_bootstrap.dart` with this content
- [x] Note: `IsarService.schemas` is wired in Phase 3. For Phase 1 the stub can use an empty schema list.
- [x] Firebase is NOT initialized here — that is Phase 8 only.

---

### 9. Write app.dart

Create `lib/app/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_router.dart';
import 'app_theme.dart';

class CoffeeQuestApp extends ConsumerWidget {
  const CoffeeQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Coffee Quest',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- [x] Create `lib/app/app.dart` with this content

---

### 10. Write app_theme.dart

Create `lib/app/app_theme.dart`:

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B3A2A),  // coffee brown
          brightness: Brightness.light,
        ),
        fontFamily: 'SF Pro Display',           // system font on iOS
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      );
}
```

- [x] Create `lib/app/app_theme.dart` with this content

---

### 11. Write app_router.dart (Stub)

Create `lib/app/app_router.dart` with a minimal shell route. Full implementation is in `docs/16-claude-code-task-plan.md` Phase 5.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/learn',
    routes: [
      GoRoute(
        path: '/learn',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Learn — coming soon')),
        ),
      ),
      GoRoute(
        path: '/path',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Path — coming soon')),
        ),
      ),
      GoRoute(
        path: '/cards',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Cards — coming soon')),
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Profile — coming soon')),
        ),
      ),
    ],
  );
}
```

- [x] Create `lib/app/app_router.dart` with this stub
- [x] Run `dart run build_runner build` to generate `app_router.g.dart`

---

### 12. Install CocoaPods Dependencies

```bash
cd ios && pod install && cd ..
```

- [x] Run `pod install` from the `ios/` directory
- [x] Verify no CocoaPods errors

---

### 13. Run Build Runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [x] Run build_runner to generate all `.g.dart` files
- [x] Verify no generation errors

---

### 14. Verify Launch on Simulator

```bash
flutter run -d "iPhone 17"
```

- [x] App launches on iOS Simulator
- [x] No crash on startup
- [x] Isar opens without error (check console logs)
- [x] Bottom navigation is not yet wired — stub screens appear

---

## Definition of Done

- [x] `flutter create` completed with iOS-only platforms
- [x] iOS minimum deployment target is set to 16.0 in Podfile, Xcode target, and Info.plist
- [x] Bundle ID is set to `dev.maximsan.coffeequest`
- [x] `pubspec.yaml` matches `docs/05-dependencies.md`
- [x] All directories from `docs/04-folder-structure.md` exist
- [x] `main.dart`, `app_bootstrap.dart`, `app.dart`, `app_theme.dart`, `app_router.dart` are created
- [x] Firebase is NOT initialized — `app_bootstrap.dart` only opens Isar
- [x] `pod install` succeeds
- [x] `build_runner build` succeeds with no errors
- [x] App launches on iOS Simulator without crashing
