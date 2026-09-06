import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/storage/snapshot/merge_snapshot.dart';
import 'package:brew_path/shared/storage/snapshot/progress_snapshot.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:brew_path/shared/storage/snapshot/term_miss.dart';
import 'package:brew_path/shared/storage/snapshot/timestamped.dart';
import 'package:brew_path/shared/storage/snapshot/wipe_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/snapshot_generators.dart';

/// The two wipes, as the snapshots they publish.
///
/// Both are pure — a snapshot in, the tombstone out — so the clock and the
/// device identity are arguments. That is what lets every case here be decided
/// without a database, including the ones that only show up on a *second*
/// device.
const _wipedAt = 7000;
const _thisDevice = 'phone';

/// A learner who has done and chosen a great deal: every progress field holds
/// something, and both account fields are customised. A wipe that quietly skips
/// a field fails against this and passes against a sparser fixture.
const _loaded = ProgressSnapshot(
  updatedAt: 100,
  deviceId: 'tablet',
  resetGeneration: 1,
  clearedByReset: ClearedByReset(
    completedLessons: {'m1l1': 3},
    bestResults: {'m1l1': MasteryResult(correct: 5, total: 8)},
    activeDays: {1, 2, 3},
    acks: {'freezeNotice': 2},
    ownedCollectibles: {'c1'},
    completedModules: {'m1'},
    treeStage: 4,
    challengesCompleted: {'bc-m1'},
    learnedTerms: {'crema'},
    missedTerms: {'crema': TermMiss(lastMissedAt: 6000)},
    challengeReactions: {
      'bc-m1': ChallengeReaction(reaction: 'Sharper', at: 3),
    },
    dailyActivity: {
      4: {'miniGame:g-match:1-1'},
    },
    challengesSaved: Timestamped(
      value: {'bc-m1'},
      updatedAt: 5000,
      writerId: 'tablet',
    ),
    activeChallenge: Timestamped(
      value: ActiveChallenge(id: 'bc-m1', startedAt: 4000),
      updatedAt: 5000,
      writerId: 'tablet',
    ),
    favourites: Timestamped(
      value: {'l:m1l1'},
      updatedAt: 5000,
      writerId: 'tablet',
    ),
    unknown: {'futureProgress': 7},
  ),
  clearedByDeleteOnly: ClearedByDeleteOnly(
    grove: Timestamped(
      value: Grove(variety: 'liberica', light: 'moonlit'),
      updatedAt: 5000,
      writerId: 'tablet',
    ),
    companion: Timestamped(
      value: CompanionConfig(
        roast: 'dark',
        hat: 'field',
        gear: 'glasses',
        sprout: 'flower',
      ),
      updatedAt: 5000,
      writerId: 'tablet',
    ),
    unknown: {'futureChoice': 'teal'},
  ),
);

void main() {
  group('Reset Progress', () {
    test('clears every progress-scoped field the learner had', () {
      final after = resetTombstone(
        _loaded,
        at: _wipedAt,
        deviceId: _thisDevice,
      );

      expect(after.clearedByReset, ClearedByReset.empty);
    });

    test('clears them whatever shape the stored snapshot was in', () {
      // Over generated snapshots as well as the loaded one: the claim is that
      // reset cannot *forget* a field, and a single fixture only ever proves it
      // for the fields its author remembered to populate.
      for (var seed = 0; seed < 40; seed++) {
        final before = SnapshotGen(seed).snapshot();

        final after = resetTombstone(
          before,
          at: _wipedAt,
          deviceId: _thisDevice,
        );

        expect(
          after.clearedByReset,
          ClearedByReset.empty,
          reason: 'seed $seed',
        );
      }
    });

    test("empties the Vocab game's review deck", () {
      // Named rather than left to the whole-scope assertion above: the deck
      // is in the reset scope precisely so a wipe empties it by construction,
      // and that promise deserves a test that fails by name.
      expect(_loaded.clearedByReset.missedTerms, isNotEmpty);

      final after = resetTombstone(
        _loaded,
        at: _wipedAt,
        deviceId: _thisDevice,
      );

      expect(after.clearedByReset.missedTerms, isEmpty);
    });

    test('increments the reset generation', () {
      final after = resetTombstone(
        _loaded.copyWith(resetGeneration: 4),
        at: _wipedAt,
        deviceId: _thisDevice,
      );

      expect(after.resetGeneration, 5);
    });

    test('keeps the grove and the companion exactly as they stood', () {
      final after = resetTombstone(
        _loaded,
        at: _wipedAt,
        deviceId: _thisDevice,
      );

      expect(after.clearedByDeleteOnly, _loaded.clearedByDeleteOnly);
    });

    test('keeps an account-scoped key written by a newer build', () {
      // Account-scoped passthrough survives a reset for the same reason the
      // grove does: a newer build's *preference* is not progress.
      final after = resetTombstone(
        _loaded,
        at: _wipedAt,
        deviceId: _thisDevice,
      );

      expect(after.clearedByDeleteOnly.unknown['futureChoice'], 'teal');
    });

    test('stamps the envelope with this device and this moment', () {
      final after = resetTombstone(
        _loaded,
        at: _wipedAt,
        deviceId: _thisDevice,
      );

      expect(after.updatedAt, _wipedAt);
      expect(after.deviceId, _thisDevice);
    });

    test('never writes the schema version backwards', () {
      // A newer build wrote the stored snapshot. Publishing the tombstone at
      // *this* build's version would walk the envelope backwards.
      final after = resetTombstone(
        _loaded.copyWith(version: 9),
        at: _wipedAt,
        deviceId: _thisDevice,
      );

      expect(after.version, 9);
    });

    test('carries an envelope key written by a newer build', () {
      // Envelope keys are not progress, and the merge never resolves them by
      // generation, so dropping them here would destroy data for nothing.
      final after = resetTombstone(
        _loaded.copyWith(unknown: {'futureField': 42}),
        at: _wipedAt,
        deviceId: _thisDevice,
      );

      expect(after.unknown['futureField'], 42);
    });
  });

  group('Delete Account', () {
    test('clears the progress scope, exactly as reset does', () {
      final after = deleteTombstone(
        _loaded,
        at: _wipedAt,
        deviceId: _thisDevice,
      );

      expect(after.clearedByReset, ClearedByReset.empty);
    });

    test('clears the account scope too, back to an uncustomised state', () {
      final after = deleteTombstone(
        _loaded,
        at: _wipedAt,
        deviceId: _thisDevice,
      );

      expect(after.clearedByDeleteOnly.grove.value, Grove.initial);
      expect(
        after.clearedByDeleteOnly.companion.value,
        CompanionConfig.initial,
      );
      expect(after.clearedByDeleteOnly.unknown, isEmpty);
    });

    test('increments the generation once, exactly as reset does', () {
      final after = deleteTombstone(
        _loaded.copyWith(resetGeneration: 2),
        at: _wipedAt,
        deviceId: _thisDevice,
      );

      expect(after.resetGeneration, 3);
    });

    test('stamps the cleared account fields, so the wipe can win a merge', () {
      // The trap: `ClearedByDeleteOnly.empty` stamps its fields at the epoch,
      // and account fields merge last-writer-wins rather than by generation. An
      // unstamped account tombstone therefore loses to *any* grove the other
      // device holds, and the deletion is walked straight back.
      final after = deleteTombstone(
        _loaded,
        at: _wipedAt,
        deviceId: _thisDevice,
      );

      expect(after.clearedByDeleteOnly.grove.updatedAt, _wipedAt);
      expect(after.clearedByDeleteOnly.grove.writerId, _thisDevice);
      expect(after.clearedByDeleteOnly.companion.updatedAt, _wipedAt);
      expect(after.clearedByDeleteOnly.companion.writerId, _thisDevice);
    });
  });

  group('the tombstone holds only the envelope', () {
    test('nothing personal survives a reset, down to the encoded form', () {
      // Encoded rather than compared as objects: the payload is what leaves the
      // device, so it is the thing that has to hold nothing.
      final tombstone = resetTombstone(
        _loaded,
        at: _wipedAt,
        deviceId: _thisDevice,
      ).toJson();

      expect(tombstone['clearedByReset'], ClearedByReset.empty.toJson());
    });

    test('and nothing personal survives a delete, in either scope', () {
      final tombstone = deleteTombstone(
        _loaded,
        at: _wipedAt,
        deviceId: _thisDevice,
      ).toJson();

      expect(tombstone['clearedByReset'], ClearedByReset.empty.toJson());
      expect(
        tombstone['clearedByDeleteOnly'],
        ClearedByDeleteOnly.clearedAfter(
          _loaded.clearedByDeleteOnly,
          at: _wipedAt,
          deviceId: _thisDevice,
        ).toJson(),
      );
    });
  });

  group('a reset is not walked back by a stale peer', () {
    // The tablet never saw the reset. It still holds the progress that was
    // wiped, at the generation before it — and it synced more recently, which
    // must not matter.
    final tablet = _loaded.copyWith(updatedAt: 20000);
    final phoneAfterReset = resetTombstone(
      _loaded,
      at: _wipedAt,
      deviceId: _thisDevice,
    );

    test('merging the stale peer in leaves the progress cleared', () {
      final merged = mergeSnapshot(phoneAfterReset, tablet);

      expect(merged.resetGeneration, _loaded.resetGeneration + 1);
      expect(merged.clearedByReset, ClearedByReset.empty);
    });

    test('and the peer merging the other way round agrees', () {
      // Convergence is the point: the tablet reaches the wiped state on its
      // own, rather than needing the phone to speak last.
      expect(
        mergeSnapshot(tablet, phoneAfterReset),
        mergeSnapshot(phoneAfterReset, tablet),
      );
    });

    test('while the peer keeps the grove it customised', () {
      final merged = mergeSnapshot(phoneAfterReset, tablet);

      expect(merged.clearedByDeleteOnly.grove.value.variety, 'liberica');
    });
  });

  group('a delete is not walked back by a stale peer', () {
    final tablet = _loaded.copyWith(updatedAt: 20000);
    final phoneAfterDelete = deleteTombstone(
      _loaded,
      at: _wipedAt,
      deviceId: _thisDevice,
    );

    test('the progress goes, and so does the personalisation', () {
      final merged = mergeSnapshot(phoneAfterDelete, tablet);

      expect(merged.clearedByReset, ClearedByReset.empty);
      expect(merged.clearedByDeleteOnly.grove.value, Grove.initial);
      expect(
        merged.clearedByDeleteOnly.companion.value,
        CompanionConfig.initial,
      );
    });

    test('either way round', () {
      expect(
        mergeSnapshot(tablet, phoneAfterDelete),
        mergeSnapshot(phoneAfterDelete, tablet),
      );
    });

    test('even when the peer stamped its grove after this device deleted', () {
      // The case a same-clock fixture hides. The stored snapshot can already
      // hold a grove stamped *later* than this device's clock reads — a peer
      // that synced ahead, or plain skew — and stamping the wipe at the raw
      // clock then loses the last-writer-wins comparison to the very value it
      // was published to erase.
      const peerAhead = ClearedByDeleteOnly(
        grove: Timestamped(
          value: Grove(variety: 'liberica', light: 'moonlit'),
          updatedAt: 30000,
          writerId: 'tablet',
        ),
        companion: Timestamped(
          value: CompanionConfig(
            roast: 'dark',
            hat: 'field',
            gear: 'glasses',
            sprout: 'flower',
          ),
          updatedAt: 30000,
          writerId: 'tablet',
        ),
      );
      final stored = _loaded.copyWith(clearedByDeleteOnly: peerAhead);

      final merged = mergeSnapshot(
        deleteTombstone(stored, at: _wipedAt, deviceId: _thisDevice),
        stored,
      );

      expect(merged.clearedByDeleteOnly.grove.value, Grove.initial);
      expect(
        merged.clearedByDeleteOnly.companion.value,
        CompanionConfig.initial,
      );
    });
  });
}
