# Content pipeline — regenerating what the app derives from the prototype

The design prototype in `prototype/` is the source the app is built against
and the place the owner authors course content
([ADR-0006](adr/0006-the-prototype-authors-v1-and-the-extracted-json-is-the-contract.md)).
Three things in the app are *derived* from it rather than written by hand —
the content banks, the icon family and the collectible artwork — each by a
Node script under `tool/`. When a prototype drop lands, these are re-run; when
the design changes, a change reaches the app by re-running them, never by
someone noticing.

## The contract every extractor keeps

- **It validates everything, then writes, or writes nothing.** On any
  violation it names the offending item and the broken reference, exits
  non-zero, and leaves the output untouched — so a run can never leave a stale
  mixture of old and new files behind.
- **Its output is generated.** Regenerate it; never hand-edit it. A test reads
  the committed output and asserts it still matches a fresh run, so a hand
  edit or a half-applied regeneration fails the suite.
- **`prototype/` is opened for reading only.** Each script writes only under
  its `--out`, which the tests point at a temporary directory.
- **No dependencies.** Plain Node, so a run needs nothing installed beyond it.

## After a drop, in this order

The three extractors are independent of one another; the order is convention.

```bash
node tool/extract_content.js      # assets/content/generated/  — the banks
node tool/extract_icons.js        # assets/icons/              — the icon family
node tool/extract_card_art.js     # assets/card_art/           — the collectible art
node docs/design/tools/extract-facts.js   # the design reference's counts
flutter test test/unit/tool test/unit/core/icons   # the tests that pin all three
```

Each also takes `--source DIR --out DIR`, which is how the tests run it
against fixtures. Commit the regenerated output with the drop.

What changed in the *design* — a screen, a rule, a component — is a separate
question from what changed in the *content*, and it is answered by the design
reference's fix-on-contact rule and the parity register, not here:
[`design/README.md`](design/README.md), _Keeping this current_, and the
tracker's design-parity checklist. A drop that edits English course text also
makes translations stale; `plan` in [`localization.md`](localization.md)
queues exactly those.

## `tool/extract_content.js` — the banks

Writes seventeen banks — modules, lessons, collectibles, dictionary terms and
categories, Coffee Challenges, mini games and their content, card-kind help,
grove varieties and lights, visual guides, Roasty's lines and studio options —
into `assets/content/generated/`, after checking the whole cross-reference
graph. Each check is one file under `tool/extract_content/validate/`: the
course's lesson references, a challenge's card, a collectible's unlock, a
lesson's term mentions, a visual guide's lesson, ids, answers, duplicates.

**Every bank carries a `schemaVersion`, and the app refuses one it was not
built to read.** The number exists twice — `SCHEMA_VERSION` in the script and
`contentSchemaVersion` in `lib/shared/repositories/bank_envelope.dart` — and a
test holds the committed banks to the Dart side's value, so bumping one alone
fails the suite. When to bump is _Bumping the schema version_ in the script's
header: a rename or a change of meaning is breaking even when the shape is
unchanged.

The prototype's field names are emitted verbatim and Dart takes idiomatic
names through serialization annotations, so a prototype-side rename surfaces
as a runtime null rather than a compile error — which is why the Dart side
deserializes every card the script emits in `test/unit/tool/extract_content_test.dart`.

## `tool/extract_icons.js` — the icon family

Writes the design's marks as SVG into `assets/icons/`, plus the
`index.json` that describes the family, and gives five of them a second file
for the state the design draws when active. The marks carry arcs, transforms,
per-element opacity and nine stroke widths, which is why they are rendered
rather than transcribed into painters.

**Three sources**, per
[ADR-0009](adr/0009-the-running-prototype-wins-over-the-design-system-catalogue.md):
geometry from the catalogue (`prototype/ds-content.js`); the paint of each
active state from the running components (`prototype/flavor-wheel.jsx`),
which the catalogue does not draw; and the four game-kind marks the catalogue
has not got at all, from `ReplayIcon` in `prototype/screens.jsx`. The last of
those are the family's first two-tone marks, drawn muted with one detail in
the accent, which is why the sentinel list carries `--bg` and `--accent`.

**Colour is not baked in.** A mark paints in `currentColor`, which `IconMark`
resolves to a mood token, or in a sentinel magenta standing in for a CSS
variable, which it maps back to a token. An unmappable colour, two sets
drawing one name differently, or a state transcription the catalogue no
longer matches all refuse the run. Pinned by `test/unit/core/icons/app_icon_test.dart`.

## `tool/extract_card_art.js` — the collectible artwork

Writes the design's 37 collectible illustrations as SVG into `assets/card_art/`,
plus the `index.json` naming each kind and its file, and sweeps any drawing
the design has dropped.

**It runs the source rather than reading it.** Five arts compose a
prop-taking frame and eight compute their geometry with `Array.from` and
`Math`, so the components have to be executed. The prototype executes them
with React and Babel from a CDN, which is not available offline and would be
this repo's first npm dependency — so `tool/extract_card_art/jsx.js` reads the
one dialect the source is written in and refuses anything outside it: a moved
art block, an art that draws nothing, any construct the reader does not know.

**Colour is not baked in.** Mood tokens become sentinel magentas that
`CardArtMark` maps to `MoodColors`; the `--art-*` family, declared once for
both moods, maps to `ArtColors`. A paint belonging to neither refuses the run.
Computed coordinates are rounded to four decimal places, because `Math.cos`
and `Math.sin` disagree in their last bits between platforms.

**The words in the drawings stay English.** Nineteen arts have English words
drawn into them; they ship as part of the picture and are not translated
([ADR-0019](adr/0019-the-card-art-keeps-its-english-words.md)). Pinned by
`test/unit/tool/extract_card_art_test.dart`.

## When a run refuses

Read the message: it names the card, mark or art and the reference or paint
it could not resolve. The fix is in the prototype — which is the owner's to
edit — or, for a new field or colour the app has never seen, in the script's
register of what it knows. Never work around a refusal by hand-editing the
output; the test that pins it would fail next.
