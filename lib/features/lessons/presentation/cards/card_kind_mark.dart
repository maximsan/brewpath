import 'package:brew_path/core/icons/app_icon.dart';

/// The design's mark for each card kind that has a how-to-play entry.
///
/// Keyed by the `kind` the content carries, which is not always the mark's own
/// name: the banks spell the tasting game `flavor`, the icon set `flavour`. A
/// test holds every shipped kind to a mark, so one arriving without a mark
/// fails the build ([#436](https://github.com/maximsan/brewpath/issues/436)).
const Map<String, AppIcon> cardKindMarks = {
  'mcq': AppIcon.mcq,
  'multi': AppIcon.multi,
  'fill': AppIcon.fill,
  'match': AppIcon.match,
  'slider': AppIcon.slider,
  'sequence': AppIcon.sequence,
  'quiz': AppIcon.quiz,
  'flavor': AppIcon.flavour,
  'tastefix': AppIcon.tastefix,
  'bagpick': AppIcon.bagpick,
};

/// The mark for [kind], or null for a kind the design has not drawn.
///
/// Null rather than a throw: an unlisted kind should still open its drawer and
/// read its steps, and the test above is what keeps null off the shipped path.
AppIcon? cardKindMark(String kind) => cardKindMarks[kind];
