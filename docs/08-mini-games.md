# Coffee Quest — Mini-Games

## Overview

Mini-games are the interactive steps inside lessons. Each lesson has 1–3 steps. Each step maps to one mini-game widget. All game types are data-driven — the widget receives its data from `LessonStepModel` and emits a result.

---

## MiniGameResult

```dart
// lib/features/mini_games/domain/mini_game_result.dart

sealed class MiniGameResult {
  const MiniGameResult();
}

class MiniGameCorrect extends MiniGameResult {
  const MiniGameCorrect();
}

class MiniGameIncorrect extends MiniGameResult {
  const MiniGameIncorrect({this.hint});
  final String? hint;
}
```

---

## LessonStepRunner

The dispatcher widget. Receives the current `LessonStepModel` and calls `onResult` when the user completes the step.

```dart
// lib/features/mini_games/presentation/lesson_step_runner.dart
import 'package:flutter/material.dart';
import '../../../shared/models/lesson_step_model.dart';
import '../domain/mini_game_result.dart';
import 'multiple_choice_game.dart';
import 'drag_drop_game.dart';
import 'slider_game.dart';
import 'tap_order_game.dart';

class LessonStepRunner extends StatelessWidget {
  const LessonStepRunner({
    super.key,
    required this.step,
    required this.onResult,
  });

  final LessonStepModel step;
  final void Function(MiniGameResult result) onResult;

  @override
  Widget build(BuildContext context) {
    return switch (step) {
      MultipleChoiceStep s => MultipleChoiceGame(step: s, onResult: onResult),
      DragDropStep s       => DragDropGame(step: s, onResult: onResult),
      SliderStep s         => SliderGame(step: s, onResult: onResult),
      TapOrderStep s       => TapOrderGame(step: s, onResult: onResult),
    };
  }
}
```

Adding a new game type = add a new `LessonStepModel` variant + add a case here. No other files need changing.

---

## 1. MultipleChoiceGame

### Purpose
Presents a question with 2–4 options. One correct answer.

### UX Flow
1. Question text displayed at top
2. Answer buttons shown below
3. User taps one button
4. If correct: button turns green, explanation shown, "Continue" button appears
5. If incorrect: button turns red, correct answer highlighted green, explanation shown, "Try Again" button appears
6. User taps Continue / Try Again → `onResult` called

### Implementation Spec

```dart
// lib/features/mini_games/presentation/multiple_choice_game.dart
import 'package:flutter/material.dart';
import '../../../shared/models/lesson_step_model.dart';
import '../domain/mini_game_result.dart';

class MultipleChoiceGame extends StatefulWidget {
  const MultipleChoiceGame({
    super.key,
    required this.step,
    required this.onResult,
  });

  final MultipleChoiceStep step;
  final void Function(MiniGameResult) onResult;

  @override
  State<MultipleChoiceGame> createState() => _MultipleChoiceGameState();
}

class _MultipleChoiceGameState extends State<MultipleChoiceGame> {
  int? _selectedIndex;
  bool _answered = false;

  void _onOptionTap(int index) {
    if (_answered) return;
    setState(() {
      _selectedIndex = index;
      _answered = true;
    });
  }

  void _onContinue() {
    final isCorrect = _selectedIndex == widget.step.correctIndex;
    widget.onResult(
      isCorrect ? const MiniGameCorrect() : MiniGameIncorrect(hint: widget.step.explanation),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Layout: Column with question, option buttons, explanation (if answered), continue button
    // Each option button: outlined by default, green border if correct answer after reveal,
    //                     red border if selected wrong answer
    // Show explanation text below buttons after answer is selected
    // Show Continue button after answer is selected
    throw UnimplementedError('Build the MultipleChoiceGame UI here');
  }
}
```

### Key Behaviors
- Tapping a button is irreversible within the step
- Correct answer is always highlighted after the user submits
- Explanation is always shown after submission (correct or incorrect)
- "Continue" advances to next step; "Try Again" calls `onResult(MiniGameIncorrect(...))` so the lesson screen can handle retry logic

---

## 2. DragDropGame

### Purpose
User matches terms on the left to definitions on the right by dragging.

### UX Flow
1. Left column: draggable term chips
2. Right column: drop targets labeled with the definition
3. User drags a term chip and drops it onto a definition
4. If match is correct: term chip snaps green into the target
5. If all pairs matched: `onResult(MiniGameCorrect())` called
6. If a drop is wrong: chip returns to original position, no penalty (try again)

### Implementation Spec

```dart
// lib/features/mini_games/presentation/drag_drop_game.dart
// Uses Flutter built-in: Draggable<String> and DragTarget<String>

// State to track:
// - Map<int, int?> _matches  — termIndex -> definitionIndex (null if unmatched)
// - bool get _allMatched => _matches.values.every((v) => v != null)

// When _allMatched is true, call onResult(MiniGameCorrect())

// Each Draggable carries the term index as data
// Each DragTarget checks: data (termIndex) == the definition index it represents
```

### Key Behaviors
- A term that is already correctly placed cannot be dragged again
- There is no "Submit" button — completion triggers automatically when all terms are placed correctly
- Wrong drop visually rejects (chip bounces back) — no state penalty

---

## 3. SliderGame

### Purpose
User moves a labeled slider to a target range. Example: "Set water temperature to 90–96°C."

### UX Flow
1. Instruction text displayed at top
2. Labeled slider shown with min/max labels and unit
3. Current value shown numerically above or below the thumb
4. "Check" button at bottom
5. User moves slider and taps Check
6. If value is within `targetMin`–`targetMax`: green feedback, explanation, Continue
7. If outside range: red feedback, correct range shown, Try Again

### Implementation Spec

```dart
// lib/features/mini_games/presentation/slider_game.dart
// State: double _currentValue = (step.minValue + step.maxValue) / 2

// Slider widget:
// Slider(
//   value: _currentValue,
//   min: step.minValue,
//   max: step.maxValue,
//   onChanged: (v) => setState(() => _currentValue = v),
// )

// On Check:
// bool correct = _currentValue >= step.targetMin && _currentValue <= step.targetMax;
// onResult(correct ? MiniGameCorrect() : MiniGameIncorrect(hint: ...))
```

### Key Behaviors
- Initial slider position is the midpoint of the range
- Target range is NOT visually shown before the user submits (no spoilers)
- After submission, the target range is highlighted on the slider track

---

## 4. TapOrderGame

### Purpose
User taps items in the correct sequence. Example: ordering roast levels from light to dark.

### UX Flow
1. Items displayed in random order as chips
2. User taps chips in sequence — tapped chips move to an "answer area" at the bottom
3. When all chips are placed: automatically checks order
4. If correct order: green feedback, explanation, Continue
5. If wrong order: red feedback, correct order shown, Reset button to try again

### Implementation Spec

```dart
// lib/features/mini_games/presentation/tap_order_game.dart
// State:
// - List<String> _shuffled (shuffled on initState)
// - List<String> _selected (user's tap order, grows as user taps)
// - bool _answered = false

// On tap: add tapped item to _selected, remove from _shuffled pool
// When _selected.length == step.items.length:
//   bool correct = ListEquality().equals(_selected, step.items);
//   setState(() => _answered = true);
//   // Show feedback, then call onResult

// Reset: _selected = [], _shuffled = shuffled copy of step.items, _answered = false
```

### Key Behaviors
- Items are shuffled in `initState` using `List.from(step.items)..shuffle()`
- The shuffle must not produce the correct order (re-shuffle if it does — or accept it as valid)
- Tapping an item in the answer area does NOT remove it (no backtracking after placement, to match Duolingo UX)

---

## Steps

- [x] Create `lib/features/mini_games/domain/mini_game_result.dart`
- [x] Create `lib/features/mini_games/presentation/lesson_step_runner.dart`
- [x] Create `lib/features/mini_games/presentation/multiple_choice_game.dart` with full UI
- [x] Create `lib/features/mini_games/presentation/drag_drop_game.dart` with full UI
- [x] Create `lib/features/mini_games/presentation/slider_game.dart` with full UI
- [x] Create `lib/features/mini_games/presentation/tap_order_game.dart` with full UI
- [x] Write widget test: `MultipleChoiceGame` renders options, selects correct answer, emits `MiniGameCorrect`
- [x] Write widget test: `MultipleChoiceGame` selects wrong answer, emits `MiniGameIncorrect`
- [x] Write widget test: `SliderGame` within target range → `MiniGameCorrect`
- [x] Write widget test: `TapOrderGame` correct sequence → `MiniGameCorrect`

---

## Adding a New Game Type

1. Add a new `const factory` to `LessonStepModel` in `lib/shared/models/lesson_step_model.dart`
2. Re-run `build_runner`
3. Add a new `case` to `LessonStepRunner.build()`
4. Create the new game widget in `lib/features/mini_games/presentation/`
5. Add test coverage
6. Add sample steps to `lessons.json` using the new `"type"` value

---

## Definition of Done

- [x] `LessonStepRunner` dispatches all 4 step types without a default/throw case
- [x] All 4 game widgets compile and run on iOS Simulator
- [x] Each game widget correctly calls `onResult` with `MiniGameCorrect` on success
- [x] Each game widget correctly calls `onResult` with `MiniGameIncorrect` on failure
- [x] Widget tests for MultipleChoiceGame, SliderGame, and TapOrderGame pass
- [x] DragDropGame drops correctly matched items without error
