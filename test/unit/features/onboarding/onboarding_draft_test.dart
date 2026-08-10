import 'package:brew_path/features/onboarding/presentation/onboarding_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_onboarding_repository.dart';

void main() {
  late FakeOnboardingRepository fake;

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [onboardingRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() => fake = FakeOnboardingRepository());

  group('OnboardingDraft', () {
    test('setGoal and setBrewer accumulate into the draft', () {
      final container = makeContainer();
      final notifier = container.read(onboardingDraftProvider.notifier);

      notifier.setGoal('brew_better');
      notifier.setBrewer('v60');

      expect(container.read(onboardingDraftProvider), (
        goal: 'brew_better',
        brewer: 'v60',
      ));
    });

    test('complete persists both selections then clears the draft', () async {
      final container = makeContainer();
      final notifier = container.read(onboardingDraftProvider.notifier)
        ..setGoal('understand_tasting')
        ..setBrewer('aeropress');

      await notifier.complete();

      expect(fake.completeCalls, [
        (goal: 'understand_tasting', brewer: 'aeropress'),
      ]);
      expect(container.read(onboardingDraftProvider), (
        goal: null,
        brewer: null,
      ));
    });

    test('complete refreshes the onboardingCompleted gate', () async {
      final container = makeContainer();
      expect(await container.read(onboardingCompletedProvider.future), isFalse);

      container.read(onboardingDraftProvider.notifier)
        ..setGoal('just_curious')
        ..setBrewer('not_sure');
      await container.read(onboardingDraftProvider.notifier).complete();

      // Invalidated by complete() → re-reads the now-completed fake state.
      expect(await container.read(onboardingCompletedProvider.future), isTrue);
    });

    test(
      'complete throws and persists nothing if a selection is missing',
      () async {
        final container = makeContainer();
        container.read(onboardingDraftProvider.notifier).setGoal('brew_better');

        await expectLater(
          container.read(onboardingDraftProvider.notifier).complete(),
          throwsStateError,
        );
        expect(fake.completeCalls, isEmpty);
      },
    );
  });
}
