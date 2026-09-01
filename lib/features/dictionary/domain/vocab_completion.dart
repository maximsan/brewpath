import 'package:brew_path/features/progress/domain/activity_recorder.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';

/// Records one **completed** vocab round — a drill that reached its score.
///
/// One finished round marks the day on its own (§3, #33) and spends a unit of
/// the free daily allowance (#65). The rule is not restated here:
/// [recordActivity] asks it once for every surface.
///
/// No subject, because a generated drill has no id to name — and two rounds in
/// a day are still two entries, which is what the allowance has to see.
Future<void> recordVocabRound(SnapshotRepository repository, DateTime now) =>
    recordActivity(
      repository,
      type: ActivityType.vocab,
      subject: '',
      now: now,
    );
