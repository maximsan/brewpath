import 'package:brew_path/shared/repositories/snapshot_repository.dart';

/// The Misses deck's write path: one answered question at a time, in order.
///
/// Each answer is a read-modify-write over the whole snapshot, so two in
/// flight lose one — chaining makes that unrepresentable. What an answer does
/// lives on the snapshot scope, not here: wrong adds the term in any deck,
/// right clears it.
class VocabMissLog {
  /// Creates a log writing through [_repository].
  VocabMissLog(this._repository);

  final SnapshotRepository _repository;

  Future<void> _pending = Future<void>.value();

  /// Resolves once every answer recorded so far has been written.
  ///
  /// Never completes with an error, so a caller waiting only to refresh what
  /// is on screen does not have to care whether a write failed.
  Future<void> get settled => _pending;

  /// Records that [termId] was answered, right or wrong, at [now].
  ///
  /// The returned future is this answer's own write, so a caller that needs to
  /// know whether it landed can wait on it. The queue behind it swallows the
  /// failure instead: one failed write must not take every later answer in the
  /// drill down with it.
  Future<void> record({
    required String termId,
    required bool correct,
    required DateTime now,
  }) {
    final written = _pending.then(
      (_) => _write(
        termId: termId,
        correct: correct,
        at: now.millisecondsSinceEpoch,
      ),
    );
    _pending = written.then((_) {}, onError: (Object _, StackTrace _) {});
    return written;
  }

  Future<void> _write({
    required String termId,
    required bool correct,
    required int at,
  }) async {
    final snapshot = await _repository.read();
    await _repository.write(
      snapshot.copyWith(
        updatedAt: at,
        clearedByReset: snapshot.clearedByReset.withTermAnswered(
          termId,
          correct: correct,
          at: at,
        ),
      ),
    );
  }
}
