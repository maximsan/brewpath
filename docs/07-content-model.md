# BrewPath — Content Model

## Overview

All MVP lesson content is bundled as JSON files in `assets/content/`. There is no network call at runtime. Content is loaded once at startup by `ContentRepository` and made available via Riverpod providers.

This approach allows offline-first behavior and keeps MVP complexity low.

---

## Content Files

### `assets/content/modules.json`

```json
[
  {
    "id": "module_beans",
    "title": "Beans",
    "description": "Where coffee comes from and what makes beans different.",
    "iconName": "beans",
    "lessonIds": [
      "lesson_where_coffee",
      "lesson_arabica_robusta",
      "lesson_green_coffee"
    ],
    "unlockRequirement": null
  },
  {
    "id": "module_processing",
    "title": "Processing",
    "description": "How coffee cherries are turned into green beans.",
    "iconName": "processing",
    "lessonIds": ["lesson_washed", "lesson_natural", "lesson_honey"],
    "unlockRequirement": "module_beans"
  },
  {
    "id": "module_roast",
    "title": "Roast",
    "description": "What roasting does to coffee and how roast level affects flavor.",
    "iconName": "roast",
    "lessonIds": [
      "lesson_what_roasting_does",
      "lesson_light_roast",
      "lesson_medium_roast",
      "lesson_dark_roast"
    ],
    "unlockRequirement": "module_processing"
  },
  {
    "id": "module_brewing",
    "title": "Brewing Basics",
    "description": "The key variables that control how your coffee tastes.",
    "iconName": "brewing",
    "lessonIds": [
      "lesson_grind_size",
      "lesson_water_temp",
      "lesson_brew_ratio",
      "lesson_extraction"
    ],
    "unlockRequirement": "module_roast"
  },
  {
    "id": "module_taste",
    "title": "Taste",
    "description": "How to understand and describe what you're tasting.",
    "iconName": "taste",
    "lessonIds": [
      "lesson_acidity_body",
      "lesson_how_to_taste",
      "lesson_flavor_descriptors"
    ],
    "unlockRequirement": "module_brewing"
  }
]
```

### `assets/content/lessons.json`

Each lesson entry:

```json
[
  {
    "id": "lesson_where_coffee",
    "moduleId": "module_beans",
    "title": "Where Coffee Comes From",
    "summary": "Coffee grows in a region called the Bean Belt, between the Tropics of Cancer and Capricorn. Altitude, climate, and soil all affect flavor.",
    "xpReward": 10,
    "cardId": "card_where_coffee",
    "steps": [
      {
        "type": "multiple_choice",
        "question": "In which region of the world does most coffee grow?",
        "options": ["The Bean Belt", "Northern Europe", "Canada", "The Arctic"],
        "correctIndex": 0,
        "explanation": "The Bean Belt sits between the Tropics of Cancer and Capricorn — the ideal climate for coffee plants."
      }
    ]
  }
]
```

Full lesson content for all 17 lessons must follow this pattern. The schema is the same for all lesson types.

---

## Dart Models

### ModuleModel

```dart
// lib/shared/models/module_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '../../docs/module_model.freezed.dart';
part '../../docs/module_model.g.dart';

@freezed
class ModuleModel with _$ModuleModel {
  const factory ModuleModel({
    required String id,
    required String title,
    required String description,
    required String iconName,
    required List<String> lessonIds,
    String? unlockRequirement,  // moduleId that must be completed first; null = always unlocked
  }) = _ModuleModel;

  factory ModuleModel.fromJson(Map<String, dynamic> json) =>
      _$ModuleModelFromJson(json);
}
```

### LessonModel

```dart
// lib/shared/models/lesson_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../docs/lesson_step_model.dart';

part '../../docs/lesson_model.freezed.dart';
part '../../docs/lesson_model.g.dart';

@freezed
class LessonModel with _$LessonModel {
  const factory LessonModel({
    required String id,
    required String moduleId,
    required String title,
    required String summary,
    required int xpReward,
    String? cardId,             // null if lesson does not award a card
    required List<LessonStepModel> steps,
  }) = _LessonModel;

  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);
}
```

### LessonStepModel (sealed class via Freezed)

```dart
// lib/shared/models/lesson_step_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '../../docs/lesson_step_model.freezed.dart';
part '../../docs/lesson_step_model.g.dart';

@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.snake)
sealed class LessonStepModel with _$LessonStepModel {
  const factory LessonStepModel.multipleChoice({
    required String question,
    required List<String> options,
    required int correctIndex,
    required String explanation,
  }) = MultipleChoiceStep;

  const factory LessonStepModel.dragDrop({
    required String instruction,
    required List<String> terms,     // left side
    required List<String> definitions,  // right side (parallel list)
  }) = DragDropStep;

  const factory LessonStepModel.slider({
    required String instruction,
    required double minValue,
    required double maxValue,
    required double targetMin,
    required double targetMax,
    required String unit,
    required String explanation,
  }) = SliderStep;

  const factory LessonStepModel.tapOrder({
    required String instruction,
    required List<String> items,        // correct order
    required String explanation,
  }) = TapOrderStep;

  factory LessonStepModel.fromJson(Map<String, dynamic> json) =>
      _$LessonStepModelFromJson(json);
}
```

JSON `"type"` values map to Freezed union cases:

- `"multiple_choice"` → `MultipleChoiceStep`
- `"drag_drop"` → `DragDropStep`
- `"slider"` → `SliderStep`
- `"tap_order"` → `TapOrderStep`

### CoffeeCardModel

```dart
// lib/shared/models/coffee_card_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '../../docs/coffee_card_model.freezed.dart';
part '../../docs/coffee_card_model.g.dart';

@freezed
class CoffeeCardModel with _$CoffeeCardModel {
  const factory CoffeeCardModel({
    required String id,
    required String title,
    required String description,
    required String moduleTag,    // e.g., "Beans", "Roast"
    required String iconName,     // asset key under assets/icons/
    required String lessonId,     // lesson that awards this card
  }) = _CoffeeCardModel;

  factory CoffeeCardModel.fromJson(Map<String, dynamic> json) =>
      _$CoffeeCardModelFromJson(json);
}
```

---

## `assets/content/cards.json`

```json
[
  {
    "id": "card_where_coffee",
    "title": "Where Coffee Comes From",
    "description": "Coffee grows in the Bean Belt — between the Tropics of Cancer and Capricorn.",
    "moduleTag": "Beans",
    "iconName": "ic_beans",
    "lessonId": "lesson_where_coffee"
  }
]
```

One entry per lesson. 17 cards total.

---

## ContentRepository

```dart
// lib/shared/repositories/content_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/module_model.dart';
import '../../models/lesson_model.dart';
import '../../models/coffee_card_model.dart';

class ContentRepository {
  List<ModuleModel>? _modules;
  List<LessonModel>? _lessons;
  List<CoffeeCardModel>? _cards;

  Future<List<ModuleModel>> getModules() async {
    _modules ??= await _load('assets/content/modules.json',
        (j) => ModuleModel.fromJson(j));
    return _modules!;
  }

  Future<List<LessonModel>> getLessons() async {
    _lessons ??= await _load('assets/content/lessons.json',
        (j) => LessonModel.fromJson(j));
    return _lessons!;
  }

  Future<List<CoffeeCardModel>> getCards() async {
    _cards ??= await _load('assets/content/cards.json',
        (j) => CoffeeCardModel.fromJson(j));
    return _cards!;
  }

  Future<LessonModel?> getLessonById(String id) async {
    final lessons = await getLessons();
    return lessons.where((l) => l.id == id).firstOrNull;
  }

  Future<List<T>> _load<T>(
    String assetPath,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = await rootBundle.loadString(assetPath);
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
}
```

Riverpod provider:

```dart
@riverpod
ContentRepository contentRepository(Ref ref) => ContentRepository();
```

---

## Steps

- [x] Create `lib/shared/models/module_model.dart`
- [x] Create `lib/shared/models/lesson_model.dart`
- [x] Create `lib/shared/models/lesson_step_model.dart`
- [x] Create `lib/shared/models/coffee_card_model.dart`
- [x] Create `assets/content/modules.json` with all 5 modules
- [x] Create `assets/content/lessons.json` with all 17 lessons (each with at least 1 step)
- [x] Create `assets/content/cards.json` with all 17 card definitions
- [x] Create `lib/shared/repositories/content_repository.dart`
- [x] Add `@riverpod ContentRepository contentRepository(Ref ref)` provider
- [x] Run `dart run build_runner build --delete-conflicting-outputs`
- [x] Verify all Freezed and JSON serialization files are generated
- [x] Write a unit test that loads `modules.json` and asserts 5 modules are returned
- [x] Write a unit test that loads `lessons.json` and asserts 17 lessons are returned

---

## Definition of Done

- [x] All 4 model classes exist with Freezed + JSON annotations
- [x] All 3 content JSON files exist in `assets/content/`
- [x] `assets/content/` is declared in `pubspec.yaml` under `flutter.assets`
- [x] `ContentRepository` loads all models without errors
- [x] Freezed `copyWith`, `==`, and `hashCode` work for all models
- [x] `LessonStepModel` sealed class dispatches correctly to all 4 step types
- [x] Unit tests for content loading pass
