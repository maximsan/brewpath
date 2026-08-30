/// The Coffee Tree's stage-to-frame mapping, pure so it is testable without
/// pumping a widget.
///
/// The tree renders as one still frame per stage from the shipped art
/// (`assets/images/trees/1.png … 10.png`). The stored value is the highest
/// stage ever reached and starts at `0` on a fresh install, but the seed is
/// what "no growth yet" looks like — only a deliberate reset returns the tree
/// to seed, and a reset tree and a fresh one should read identically.
library;

/// How many stages the shipped art covers.
const int treeStageCount = 10;

/// What a fresh install stores: no growth yet. It renders as the seed frame,
/// the same picture a deliberately reset tree shows.
const int freshTreeStage = 0;

/// The first stage with a frame: the seed.
const int _seedStage = 1;

/// The stage actually rendered for a stored highest-ever [stage].
int displayedTreeStage(int stage) => stage.clamp(_seedStage, treeStageCount);

/// Asset path of the still frame for [stage].
String treeStageAsset(int stage) =>
    'assets/images/trees/${displayedTreeStage(stage)}.png';

/// Screen-reader label for the tree at [stage].
String treeStageLabel(int stage) =>
    'Your coffee tree, stage ${displayedTreeStage(stage)} of $treeStageCount';

/// Whether [from] → [to] is a rise the tree actually *shows*.
///
/// Asked of the displayed frames, not the stored numbers, and that is the
/// whole point: a fresh install stores `0` and its first completion stores
/// `1`, but both render the seed — so the raw pair says the tree grew while
/// the picture does not move. Every surface that decides between playing the
/// growth and holding still reads this, so the widget that animates and the
/// line that speaks for a still tree cannot disagree.
bool treeStageRises({required int from, required int to}) =>
    displayedTreeStage(to) > displayedTreeStage(from);
