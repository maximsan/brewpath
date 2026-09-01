import 'package:brew_path/features/progress/domain/activity_recorder.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';

/// Records one **completed** vocab round — a drill that reached its score.
///
/// The round pays nothing else: no points, no tree growth, no cards. What it
/// leaves behind is the fact that it happened, which is what protects the day
/// (§3, #33) and what the free daily allowance counts against (#65). One
/// finished round marks the day on its own; the mini-games' two-different rule
/// is theirs alone.
///
/// The rule itself is not restated here — [recordActivity] asks it once for
/// every surface, so this is a call, not a second opinion.
///
/// It carries **no subject**. A subject names *which* thing was completed, and
/// a drill is generated rather than authored: there is no id to name, and
/// minting one would put a value in the record that nothing can ever read
/// back. Two rounds in a day are still two entries — the token makes each one
/// unique — which is what the allowance has to see.
Future<void> recordVocabRound(
  SnapshotRepository repository,
  DateTime now,
) => recordActivity(
  repository,
  type: ActivityType.vocab,
  subject: '',
  now: now,
);
