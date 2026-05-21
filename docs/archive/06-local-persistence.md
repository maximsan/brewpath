# Coffee Quest — Local Persistence

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


## Why Isar

| Criterion | Hive 2.x | Isar 3.x | Decision |
|---|---|---|---|
| Active maintenance | Stale (last release 2022) | Active | Isar |
| Native queries | No (manual filtering) | Yes (QueryBuilder) | Isar |
| Multi-isolate safety | No | Yes | Isar |
| Type adapters required | Yes (manual) | No (generator) | Isar |
| Read performance | Good | Excellent | Isar |
| Write performance | Good | Excellent | Isar |
| Offline support | Yes | Yes | Tie |
| Flutter compatibility | Yes | Yes | Tie |

Isar is not exposed to feature code directly. All reads and writes go through repository classes.

---

## Isar Schema Design

### ProgressRecord

Tracks completion of individual lessons.

```dart
// lib/shared/storage/progress_record.dart
import 'package:isar/isar.dart';

part 'progress_record.g.dart';

@collection
class ProgressRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String lessonId;

  late bool isCompleted;
  late int xpEarned;
  late DateTime completedAt;
}
```

### CardRecord

Tracks which Coffee Cards the user has collected.

```dart
// lib/shared/storage/card_record.dart
import 'package:isar/isar.dart';

part 'card_record.g.dart';

@collection
class CardRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String cardId;

  late DateTime unlockedAt;
}
```

### UserSettingsRecord

Stores app preferences. Uses a fixed ID of 0 (singleton row).

```dart
// lib/shared/storage/settings_record.dart
import 'package:isar/isar.dart';

part 'settings_record.g.dart';

@collection
class UserSettingsRecord {
  Id id = 0;  // singleton — always ID 0

  late bool hapticsEnabled;
  late bool soundEnabled;
  late int totalXp;
  late int streakDays;
  late DateTime? lastActivityDate;
}
```

---

## IsarService

Holds the singleton Isar instance. Initialized once in `app_bootstrap.dart`.

```dart
// lib/shared/storage/isar_service.dart
import 'package:isar/isar.dart';
import 'progress_record.dart';
import 'card_record.dart';
import 'settings_record.dart';

class IsarService {
  IsarService._();

  static late Isar instance;

  static List<CollectionSchema<dynamic>> get schemas => [
    ProgressRecordSchema,
    CardRecordSchema,
    UserSettingsRecordSchema,
  ];
}
```

Called in `AppBootstrap.initialize()`:

```dart
final dir = await getApplicationDocumentsDirectory();
final isar = await Isar.open(
  IsarService.schemas,
  directory: dir.path,
);
IsarService.instance = isar;
```

---

## Repository Pattern

Feature code never imports `IsarService` or Isar directly. It uses repository classes.

### ProgressRepository

```dart
// lib/shared/repositories/progress_repository.dart
import 'package:isar/isar.dart';
import '../storage/isar_service.dart';
import '../storage/progress_record.dart';

class ProgressRepository {
  Isar get _isar => IsarService.instance;

  Future<List<ProgressRecord>> getAllCompleted() async {
    return _isar.progressRecords
        .filter()
        .isCompletedEqualTo(true)
        .findAll();
  }

  Future<ProgressRecord?> getByLessonId(String lessonId) async {
    return _isar.progressRecords
        .filter()
        .lessonIdEqualTo(lessonId)
        .findFirst();
  }

  Future<void> saveCompletion({
    required String lessonId,
    required int xpEarned,
  }) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.progressRecords
          .filter()
          .lessonIdEqualTo(lessonId)
          .findFirst();
      if (existing != null) return;  // idempotent — do not re-award XP
      await _isar.progressRecords.put(ProgressRecord()
        ..lessonId = lessonId
        ..isCompleted = true
        ..xpEarned = xpEarned
        ..completedAt = DateTime.now());
    });
  }
}
```

### CardRepository

```dart
// lib/shared/repositories/card_repository.dart
import 'package:isar/isar.dart';
import '../storage/isar_service.dart';
import '../storage/card_record.dart';

class CardRepository {
  Isar get _isar => IsarService.instance;

  Future<List<String>> getAllCollectedCardIds() async {
    final records = await _isar.cardRecords.where().findAll();
    return records.map((r) => r.cardId).toList();
  }

  Future<bool> isCardCollected(String cardId) async {
    final record = await _isar.cardRecords
        .filter()
        .cardIdEqualTo(cardId)
        .findFirst();
    return record != null;
  }

  Future<void> collectCard(String cardId) async {
    await _isar.writeTxn(() async {
      final exists = await _isar.cardRecords
          .filter()
          .cardIdEqualTo(cardId)
          .findFirst();
      if (exists != null) return;  // idempotent
      await _isar.cardRecords.put(CardRecord()
        ..cardId = cardId
        ..unlockedAt = DateTime.now());
    });
  }
}
```

### SettingsRepository

```dart
// lib/shared/repositories/settings_repository.dart
import 'package:isar/isar.dart';
import '../storage/isar_service.dart';
import '../storage/settings_record.dart';

class SettingsRepository {
  Isar get _isar => IsarService.instance;

  static const int _settingsId = 0;

  Future<UserSettingsRecord> getSettings() async {
    final record = await _isar.userSettingsRecords.get(_settingsId);
    if (record != null) return record;
    // Return defaults on first launch
    return UserSettingsRecord()
      ..id = _settingsId
      ..hapticsEnabled = true
      ..soundEnabled = true
      ..totalXp = 0
      ..streakDays = 0
      ..lastActivityDate = null;
  }

  Future<void> saveSettings(UserSettingsRecord settings) async {
    await _isar.writeTxn(() async {
      await _isar.userSettingsRecords.put(settings);
    });
  }

  Future<void> addXp(int xp) async {
    final settings = await getSettings();
    settings.totalXp += xp;
    await saveSettings(settings);
  }
}
```

---

## Riverpod Providers for Repositories

```dart
// lib/shared/repositories/repository_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'progress_repository.dart';
import 'card_repository.dart';
import 'settings_repository.dart';

part 'repository_providers.g.dart';

@riverpod
ProgressRepository progressRepository(Ref ref) => ProgressRepository();

@riverpod
CardRepository cardRepository(Ref ref) => CardRepository();

@riverpod
SettingsRepository settingsRepository(Ref ref) => SettingsRepository();
```

---

## Code Generation Step

After creating all `@collection` classes and repository providers:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates:
- `progress_record.g.dart`
- `card_record.g.dart`
- `settings_record.g.dart`
- `repository_providers.g.dart`

- [x] Run build_runner after creating schema files
- [x] Verify all `.g.dart` files are generated without errors
- [x] Add all `.g.dart` files to version control (they are committed, not gitignored)

---

## Migration Strategy

Isar supports schema versioning via the `version` parameter in `Isar.open()`.

For MVP: `version: 1` (default). When a schema change is needed:

1. Increment the version number: `Isar.open(..., version: 2)`
2. Provide a `migration` callback to transform old data
3. Document the migration in a `MIGRATIONS.md` file at the project root

Do not implement migrations in MVP — only add when a schema break is required.

---

## Steps

- [x] Create `lib/shared/storage/progress_record.dart`
- [x] Create `lib/shared/storage/card_record.dart`
- [x] Create `lib/shared/storage/settings_record.dart`
- [x] Create `lib/shared/storage/isar_service.dart`
- [x] Create `lib/shared/repositories/progress_repository.dart`
- [x] Create `lib/shared/repositories/card_repository.dart`
- [x] Create `lib/shared/repositories/settings_repository.dart`
- [x] Create `lib/shared/repositories/repository_providers.dart`
- [x] Update `lib/app/app_bootstrap.dart` to call `Isar.open()` with `IsarService.schemas`
- [x] Run `dart run build_runner build --delete-conflicting-outputs`
- [x] Verify all `.g.dart` files generated successfully
- [x] Write unit test for `ProgressRepository.saveCompletion` (idempotency check)
- [x] Write unit test for `SettingsRepository.addXp`

---

## Definition of Done

- [x] `ProgressRecord`, `CardRecord`, `UserSettingsRecord` Isar collections exist
- [x] `IsarService.instance` is initialized in `AppBootstrap` before `runApp()`
- [x] All repositories are behind Riverpod providers
- [x] No feature code imports `IsarService` or Isar directly
- [x] `ProgressRepository.saveCompletion` is idempotent (calling twice for the same lesson does not double-award XP)
- [x] `CardRepository.collectCard` is idempotent
- [x] App works in Airplane Mode — all data reads/writes succeed
- [x] Unit tests for repository logic pass
