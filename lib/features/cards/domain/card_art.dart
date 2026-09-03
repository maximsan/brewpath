/// The collectible kinds the design has drawn art for.
///
/// Every entry has a matching `assets/card_art/<slug>.svg`, written from the
/// design source by `tool/extract_card_art.js` — nothing here draws anything,
/// it only names what the design drew. A kind with no file, a file no kind
/// names, or a bank kind missing from this set fails
/// `test/unit/features/cards/card_art_test.dart`, which is what keeps the
/// three of them from drifting apart.
const cardArtKinds = <String>{
  'botanical',
  'layers',
  'map',
  'specimen',
  'dryingbed',
  'ferment',
  'label',
  'roastscale',
  'crack',
  'calendar',
  'gauge',
  'droplet',
  'spectrum',
  'scales',
  'hourglass',
  'burrs',
  'particles',
  'burrblade',
  'grinddial',
  'altitude',
  'varieties',
  'drying',
  'anaerobic',
  'decaf',
  'roastcurve',
  'lightdark',
  'caffeine',
  'grindbrewer',
  'extraction',
  'filter',
  'firstcup',
  'shot',
  'fieldGuideBeans',
  'fieldGuideProcess',
  'fieldGuideRoast',
  'fieldGuideGrind',
  'fieldGuideBrew',
};

/// The asset that draws [kind], or null when the design has drawn none.
///
/// Null is the useful answer rather than a thrown error: content can name a
/// new kind before anyone re-runs the extractor, and a collectible with no art
/// should fall back to its module's mark rather than take the screen down.
String? cardArtAsset(String kind) => cardArtKinds.contains(kind)
    ? 'assets/card_art/${cardArtSlug(kind)}.svg'
    : null;

/// `fieldGuideBeans` → `field_guide_beans`, the name the extractor writes.
///
/// The rule lives here rather than in a table so it cannot fall out of step
/// with the file names; the guard test checks it against the written manifest.
String cardArtSlug(String kind) => kind
    .replaceAllMapped(
      RegExp('([a-z0-9])([A-Z])'),
      (match) => '${match[1]}_${match[2]}',
    )
    .toLowerCase();
