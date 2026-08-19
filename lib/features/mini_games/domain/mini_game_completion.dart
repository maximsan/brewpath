import 'package:brew_path/features/progress/domain/activity_recorder.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';

/// Records one **completed** mini-game run — a run that reached its results.
///
/// The run itself pays nothing: no points, no tree growth, no cards. The only
/// thing it leaves behind is the fact that it happened, because two different
/// games in a local day mark that day active and protect the streak (§5, #59).
///
/// The mark lands on the second *different* game, and it is derived from the
/// day's entries rather than stored as a flag — the same game twice leaves two
/// entries and marks nothing.
Future<void> recordMiniGameRun(
  SnapshotRepository repository,
  String formatId,
  DateTime now,
) => recordActivity(
  repository,
  type: ActivityType.miniGame,
  subject: formatId,
  now: now,
);
