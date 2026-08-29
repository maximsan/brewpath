import 'package:brew_path/features/lessons/presentation/cards/slider_dial.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// The shipped bank against the renderers that must play it. A format in
/// `playableMiniGameIds` whose rounds this build cannot render would pass
/// every other test and fail in a learner's hands.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('g-match ships five boards, every one of them a match card', () async {
    final rounds = await ContentRepository().getMiniGameRounds('g-match');

    expect(rounds, hasLength(5));
    expect(rounds, everyElement(isA<MatchCard>()));
    for (final round in rounds.cast<MatchCard>()) {
      expect(round.pairs, isNotEmpty);
      expect(round.prompt, isNotEmpty);
    }
  });

  test('g-quiz ships six statements, every one of them a quiz card', () async {
    final rounds = await ContentRepository().getMiniGameRounds('g-quiz');

    expect(rounds, hasLength(6));
    expect(rounds, everyElement(isA<QuizCard>()));
  });

  test('every calibrate round reads its track back in words', () async {
    // Not decoration: the band is what the learner sees and what the target is
    // stated in. A round without one falls back to a scale built from its end
    // labels, and the fallback is a safety net, not the design.
    for (final id in ['g-calibrate', 'g-calibrate-grind-brewer']) {
      final rounds = await ContentRepository().getMiniGameRounds(id);

      expect(rounds, hasLength(5));
      expect(rounds, everyElement(isA<SliderCard>()));
      for (final round in rounds.cast<SliderCard>()) {
        expect(round.scale, isNotEmpty, reason: '$id authored a bare track');
        expect(round.tolerance, greaterThan(0));
      }
    }
  });

  test('the grind rounds still say FINER and COARSER', () async {
    // `sliderIsGrind` reads the collar off the round's end labels, because the
    // axis is the design's own test for it. That makes a copy edit on those
    // two words enough to drop the grinder dial silently, so the bank is
    // asserted rather than trusted.
    final grind = [
      for (final id in ['g-calibrate', 'g-calibrate-grind-brewer'])
        for (final round in (await ContentRepository().getMiniGameRounds(
          id,
        )).cast<SliderCard>())
          if (sliderIsGrind(
            leftLabel: round.leftLabel,
            rightLabel: round.rightLabel,
          ))
            round.prompt,
    ];

    expect(
      grind,
      hasLength(5),
      reason:
          'the shipped grind rounds no longer name the axis the collar '
          'is drawn from',
    );
  });

  test('every sequence round ships steps numbered from one', () async {
    for (final id in ['g-sequence', 'g-sequence-v60']) {
      final rounds = await ContentRepository().getMiniGameRounds(id);

      expect(rounds, hasLength(5));
      expect(rounds, everyElement(isA<SequenceCard>()));
      for (final round in rounds.cast<SequenceCard>()) {
        final orders = [for (final item in round.items) item.order]..sort();
        expect(
          orders,
          [for (var step = 1; step <= round.items.length; step++) step],
          reason:
              '${round.prompt} is not a permutation of 1..n, so no run of '
              'taps can ever be right',
        );
      }
    }
  });
}
