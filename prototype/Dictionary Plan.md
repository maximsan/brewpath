# Dictionary depth pass — working notes

Goal: every glossary term carries `deep`, `example`, `check`, and `sources`
where a source is honestly citable. Facts must be real and verifiable; the
`check` must obey the CLAUDE.md card rules (distractors genuinely wrong, the
answer able to surprise, explanation generalises rather than restating).

## Field shape (dictionary-data.jsx)

    { id, term, pron?, cat, aliases?, short, deep?, example?,
      related?:[ids], lesson?, sources?:[{label, url}],
      check?:{ q, choices:[{t, correct?}], explain } }

## Step 1 — the thin 26 (short only: no deep, no example, no check)

STATUS: DONE.

Fixes already applied after review:
- correct answer was the longest option in 25/26 checks -> reasoning moved
  into `explain`, options shortened and balanced
- `development` distractor was defensible -> stem now rules the brew out
- `chemex` check re-axed onto drain rate (was duplicating `mouthfeel`)
- plain-language rewrite of every `deep` and `explain` in the 26: no
  telegraphic dashes standing in for verbs, no "axis/lever/fingerprint"
  metaphors doing the explaining, one idea per sentence
- `swiss-water` accuracy: was "stops near 97%" for all methods; now states
  the US 97% rule and Swiss Water's own 99.9% figure
- `aeropress` accuracy: the old check ("Does an AeroPress make espresso?")
  ignored pressure-valve cap attachments, which do produce an espresso-style
  concentrate with foam. `deep` now covers stock (~1 bar) vs valve cap, and
  the check turns on what the valve does. Added aeropress.com brew-guide link.

NEXT: user verification of the 26, then step 2.

    beans       cherry, bean-belt, terroir
    processing  honey, anaerobic, swiss-water
    roasting    second-crack, development, roast-date, degassing, staling
    brewing     pour-over, immersion
    espresso    cortado, channeling, tamp
    sensory     mouthfeel, finish, balance
    equipment   aeropress, chemex, scale, grind-size
    trade       direct-trade, traceability, specialty

Course-critical, write with most care: honey, degassing, roast-date, mouthfeel.

## Source policy

Prefer, in order: peer-reviewed / institutional > trade body > manufacturer
primary (only for what their own device is) > reputable trade press. No
citation invented; no URL guessed. A term with no honest source gets none
rather than a weak one — sensory vocabulary (mouthfeel, finish, balance)
leans on the SCA cupping form; equipment leans on the maker.

Source pool being used (verify each resolves before citing):

- SCA (sca.coffee) — standards, cupping protocol, Golden Cup, specialty definition
- NCA (ncausa.org) — brewing basics, roast levels, storage
- World Coffee Research — varieties catalogue, sensory lexicon
- MDPI Foods 11(13) 1907 — "Does Coffee Have Terroir and How Should It Be
  Assessed?" (peer-reviewed; terroir, altitude)
- Wang & Lim, Food Research International (2014) — CO2 degassing behaviour
- Smrke et al., J. Agric. Food Chem. (2017) — gravimetric degassing kinetics
- Manufacturer primaries: aeropress.com, chemexcoffeemaker.com, swisswater.com

## Steps 2-3 — DONE

All 73 terms now carry deep + example + check. 72 of 73 carry sources (masl
is a unit label — nothing to cite).

Step 2 wrote checks for the 17 that had depth but none: typica, caturra,
sl28, heirloom, masl, parchment, silverskin, center-cut, washing-station,
wet-hulled, cold-brew, dialing-in, cupping, v60, french-press, fines,
origin-boards.

Step 3 also rewrote 22 ORIGINAL recall-style cards ("X is…" with joke
distractors) as scenario cards, because they failed the CLAUDE.md rules the
new ones were held to: answer obvious from the framing, distractors not
credible, explanation restating the answer. Rewritten: arabica, robusta,
cultivar, bourbon, geisha, natural, washed, mucilage, fermentation, decaf,
green-coffee, first-crack, roast-level, co2, bloom, brew-ratio, extraction,
tds, espresso, crema, portafilter, acidity, body, burr-grinder, gooseneck,
single-origin, fair-trade, sca. Answer axes were re-pointed where two cards
resolved the same way (mucilage/fermentation, acidity/extraction,
caffeine/cold-brew, bloom/co2, pour-over/v60, mouthfeel/chemex).

Audit clean at the end: 0 longest-correct answers, 0 duplicate answers,
0 malformed cards, 0 explanations under 90 chars, 0 ellipsis stems,
braces and brackets balanced.

NOTE: dictionary.html is a STATIC reference page with its own inline data.
The app reads dictionary-data.jsx via index.html — verify there, not in
dictionary.html (a runtime check against dictionary.html reports 0 terms,
which is expected, not a bug).

## Lesson-card audit (data.jsx) — DONE, 258 cards

Re-run fresh rather than working from the earlier list. Fixed:

- m5l2 c2 note restated its verdict verbatim -> note now adds the other half
  (filtered is not the same as demineralised; strip chlorine, not minerals)
- m2l5 c0/c5: the multi's headline true statement WAS the predict's answer ->
  swapped for the sealed-tank/microbes fact
- m4l2: FOUR cards resolved to "burr grinder" (c0 predict, c4 tastefix,
  c7 decision, c8 recall) -> c4 now cuts the other way (even grind, simply too
  fine = grind coarser, with "buy a better grinder" as the over-reach
  distractor); c0 re-pointed onto evenness
- m5l1: three ratio-definition cards -> c5 now the mirror case (sour and thin
  is extraction, not strength); c0 re-pointed onto scaling invariance
- m2l4 c6: two options, one absurd -> three credible options
- m2l6 c6: correct option's own subtitle gave the answer away
- m3l5 c6: light/medium won in m3l1, m3l2 AND m3l5 — nothing ever rewarded
  dark, though the note claimed "milk favours darker". Flipped to the milk
  case so the trade-off cuts both ways.
- 15 wrong-option subtitles editorialised the verdict ("Could be anything",
  "Convenient now", "Faster, in theory", "Safe and familiar", "Save time",
  "Push a button"...) -> neutral factual labels
- 10 cards where the correct answer was conspicuously the longest option

Audit clean at the end: 0 repeated answers within a lesson, 0 longest-correct
tells, 0 notes echoing their right line, 0 telling subtitles, 0 graded cards
with only two options.

### Checked and deliberately NOT changed

- 12 match cards with even splits are all in CLAUDE.md's bijective carve-out
  (cherry layers, roast stages, origin -> flavour, label claim -> guarantee,
  decaf method -> mechanism, drying method, roast level -> taste). The five
  uneven ones (2:3, 2:1:1) are the ones where elimination WAS possible.
- Freshness wins 5 of 28 decision cards (m1l1, m1l3, m1l5, m3l3, m4l6) and
  never loses. Left as is: fresh-vs-stale is a strict ordering, not a
  trade-off, so the both-ways rule does not apply. Worth a look anyway:
  m1l3 is "What origin means" but its decision resolves on freshness, which
  is off-axis for that lesson and duplicates m1l1.
- m3l1 c3 and m3l5 c3 are near-duplicate match cards in different lessons
  (roast level -> taste vs roast level -> flavour family).

## Step 4 — still open

The 8 reference-only terms (masl, wet-hulled, tds, cold-brew, cupping,
gooseneck, sca, origin-boards) have no lesson pointer because no lesson
covers them. Decide: leave glossary-only, or add pointers if a lesson
ever covers them.

## Source gaps left after step 1

Label-only sources (real, verifiable references, no link): cherry, cortado,
traceability (Hoffmann, World Atlas of Coffee); second-crack, development
(Scott Rao, The Coffee Roaster's Companion); channeling, tamp (Barista Hustle
technique guides); chemex (Hoffmann technique guides). aeropress now has the
official brew-guide link. Worth a search pass for: chemexcoffeemaker.com and
a citable espresso-puck reference for channeling/tamp.

## Later steps (not started)

2. `check` for the 17 terms that have deep + example but no self-check.
3. `sources` backfill on the 39 terms carrying none — only where a claim
   actually needs backing.
4. Decide the 8 reference-only terms: leave glossary-only, or give them
   lesson pointers if a lesson ever covers them.

## Do not lose

- `aliases` feed GLOSSARY_INDEX -> linkifyTerms, which auto-links terms in
  lesson prose. Adding a short/common alias can create false positives; check
  lesson copy for the adjective sense before adding one (this bit us on
  `natural`, fixed by rewording m2l2's concept paragraph).
- Multi-word aliases must sort before their fragments (GLOSSARY_INDEX already
  sorts by length).
