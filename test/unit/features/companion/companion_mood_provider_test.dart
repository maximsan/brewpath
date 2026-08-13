import 'dart:async';

import 'package:brew_path/features/companion/application/companion_providers.dart';
import 'package:brew_path/features/companion/domain/companion_mood.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer _containerWithStreak(int streakDays) {
  final container = ProviderContainer(
    overrides: [streakProvider.overrideWith((ref) => streakDays)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('companionMoodProvider', () {
    test('is happy while a streak is active', () async {
      final container = _containerWithStreak(3);
      await container.read(streakProvider.future);
      expect(container.read(companionMoodProvider), CompanionMood.happy);
    });

    test('is idle with no streak', () async {
      final container = _containerWithStreak(0);
      await container.read(streakProvider.future);
      expect(container.read(companionMoodProvider), CompanionMood.idle);
    });

    test('is idle while the streak is still loading', () {
      // A never-completing future keeps the provider in the loading state.
      final container = ProviderContainer(
        overrides: [
          streakProvider.overrideWith((ref) => Completer<int>().future),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(companionMoodProvider), CompanionMood.idle);
    });
  });
}
