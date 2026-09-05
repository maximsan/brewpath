import 'package:brew_path/features/tour/domain/micro_tip.dart';
import 'package:brew_path/features/tour/domain/micro_tip_candidate.dart';
import 'package:brew_path/features/tour/domain/micro_tip_place.dart';
import 'package:flutter_test/flutter_test.dart';

/// Which single tip is worth saying, given where the learner is and what they
/// have just done.
void main() {
  MicroTip? candidateAt(
    TipPlace place, {
    MicroTipSignals signals = const MicroTipSignals(),
    Set<String> seen = const {},
    bool suppressed = false,
  }) => microTipCandidate(
    place: place,
    signals: signals,
    seen: seen,
    suppressed: suppressed,
  );

  group('the place tips', () {
    test('the Path tab offers the path tip', () {
      expect(candidateAt(TipPlace.pathTab), MicroTip.path);
    });

    test("the dictionary's index offers the dictionary tip", () {
      expect(candidateAt(TipPlace.dictionary), MicroTip.dictionary);
    });

    test('an unlocked Studio offers the studio tip', () {
      expect(
        candidateAt(
          TipPlace.studio,
          signals: const MicroTipSignals(studioUnlocked: true),
        ),
        MicroTip.studio,
      );
    });

    test('a locked Studio offers nothing', () {
      // A free learner never reaches the screen — the door raises the Plus
      // gate instead — so there is nothing to explain.
      expect(candidateAt(TipPlace.studio), isNull);
    });

    test("the shelf and Today's term offer nothing of their own", () {
      expect(candidateAt(TipPlace.otherInShell), isNull);
      expect(candidateAt(TipPlace.termOfDay), isNull);
    });
  });

  group('the Learn tab', () {
    const challengeAndTreeAndFreeze = MicroTipSignals(
      challengeActive: true,
      lessonJustCompleted: true,
      freezeHeld: true,
    );

    test('offers the three in order, one at a time', () {
      expect(
        candidateAt(TipPlace.learnTab, signals: challengeAndTreeAndFreeze),
        MicroTip.brew,
      );
      expect(
        candidateAt(
          TipPlace.learnTab,
          signals: challengeAndTreeAndFreeze,
          seen: {MicroTip.brew.id},
        ),
        MicroTip.tree,
      );
      expect(
        candidateAt(
          TipPlace.learnTab,
          signals: challengeAndTreeAndFreeze,
          seen: {MicroTip.brew.id, MicroTip.tree.id},
        ),
        MicroTip.freeze,
      );
      expect(
        candidateAt(
          TipPlace.learnTab,
          signals: challengeAndTreeAndFreeze,
          seen: {MicroTip.brew.id, MicroTip.tree.id, MicroTip.freeze.id},
        ),
        isNull,
      );
    });

    test('skips a beat that has not happened', () {
      expect(
        candidateAt(
          TipPlace.learnTab,
          signals: const MicroTipSignals(freezeHeld: true),
        ),
        MicroTip.freeze,
      );
    });

    test('a quiet Learn tab says nothing', () {
      expect(candidateAt(TipPlace.learnTab), isNull);
    });
  });

  group('a fresh save', () {
    const justSaved = MicroTipSignals(savedJustHappened: true);

    test('outranks the tip of the screen it happened on', () {
      expect(
        candidateAt(TipPlace.dictionary, signals: justSaved),
        MicroTip.saved,
      );
    });

    test('lands on a screen with no tip of its own', () {
      expect(
        candidateAt(TipPlace.otherInShell, signals: justSaved),
        MicroTip.saved,
      );
      expect(
        candidateAt(TipPlace.termOfDay, signals: justSaved),
        MicroTip.saved,
      );
    });

    test("gives way to the screen's own tip once it has been shown", () {
      expect(
        candidateAt(
          TipPlace.dictionary,
          signals: justSaved,
          seen: {MicroTip.saved.id},
        ),
        MicroTip.dictionary,
      );
    });

    test('says nothing inside a lesson', () {
      expect(candidateAt(TipPlace.elsewhere, signals: justSaved), isNull);
    });
  });

  test('nothing is offered while the guide layer is suppressed', () {
    // The Tour running, or a sheet or dialog over the screen.
    expect(
      candidateAt(TipPlace.pathTab, suppressed: true),
      isNull,
    );
  });

  test('a tip already seen is never offered again', () {
    expect(
      candidateAt(TipPlace.pathTab, seen: {MicroTip.path.id}),
      isNull,
    );
  });
}
