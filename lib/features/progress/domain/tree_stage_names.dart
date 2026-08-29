/// What each of the tree's ten stages is called, and how far along it is.
///
/// Pure, so both derivations are testable without a widget. The names are the
/// design's `STAGE_NAMES` (`prototype/flavor-wheel.jsx:143`), transcribed in
/// its order — they are the stage's identity, not decoration, and the screen
/// titles itself with one.
library;

import 'package:brew_path/features/progress/domain/tree_frames.dart';

/// The ten stage names, in growth order, as the design stores them: upper
/// case, because it sets them in smallcaps in some places and title case in
/// others. [treeStageName] does the casing, so the source stays one list.
const List<String> treeStageNames = [
  'SEED',
  'SPROUT',
  'SAPLING',
  'BUDDING',
  'FLOWERING',
  'GREEN CHERRY',
  'TURNING',
  'RIPENING',
  'NEAR HARVEST',
  'HARVEST',
];

/// The name of [stage], title-cased the way the screen's heading sets it.
///
/// Takes a stored highest-ever stage, so it clamps the same way the art does:
/// a fresh install stores `0` and is shown the seed.
String treeStageName(int stage) => _titleCase(
  treeStageNames[displayedTreeStage(stage) - 1],
);

/// The name of the stage after [stage], or null at full growth.
///
/// Null rather than an empty string: the design omits the whole `NEXT · …`
/// line at stage 10 rather than showing it blank, and a caller cannot forget
/// to check a null.
String? nextTreeStageName(int stage) {
  final current = displayedTreeStage(stage);
  if (current >= treeStageCount) return null;
  return _titleCase(treeStageNames[current]);
}

/// `GREEN CHERRY` → `Green cherry`, which is the design's `pretty()`: first
/// letter up, the rest down, so a two-word name gets one capital and not two.
String _titleCase(String name) => name[0] + name.substring(1).toLowerCase();
