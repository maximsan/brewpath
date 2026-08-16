# Content inventory

> Part of the [BrewPath v1 design reference](README.md). All source paths are relative to `prototype/`.


## 6.1 Course — 5 modules, 32 lessons, 257 cards

Lessons are listed in **display order**, which is array position in
`MODULES[].lessons` — *not* id order. Existing ids never moved when the course
was restructured, so Roasting opens on `m3l4` and Grind runs `l1 · l2 · l5 · l3
· l6 · l7`. Four things point at lesson ids (`COLLECTION[].unlock.lesson`, brew
challenge pointers, dictionary `lesson` fields, mini-game `lessonId`), which is
why renumbering was ruled out.

| # | Module | Label | Lessons (display order) |
|---|---|---|---|
| 1 | Beans | BEANS | What coffee actually is · Arabica vs Robusta · What origin means · Why altitude matters · What the shelf promises · Why two Ethiopias taste different · **Inside the cherry, layer by layer** |
| 2 | Processing | PROCESSING | Washed, natural, honey · Why processing matters · Reading a bag label · Drying coffee · What happens in the tank · Decaf, honestly |
| 3 | Roasting | ROASTING | What roasting does · Light, medium, dark · First and second crack · Reading a roast date · Light vs dark, side by side · How much caffeine are you actually drinking? |
| 4 | Grind | GRIND | Particle size, in plain English · Burr vs blade · Which grind for which brewer · Dialing in by taste · Why pre-ground never tastes as good · Choosing your first grinder |
| 5 | Brew | BREW | The brew ratio · Water, the variable · Extraction explained · Choosing a filter · Tasting your cup · **Espresso, in one small cup** · Your first good cup |

**Two lessons are new since the 30-lesson restructure:**

- **`m1l7` — "Inside the cherry, layer by layer"** (Beans, 11 cards, the longest lesson in the course). Introduces the interactive cherry cross-section and the blind-bag card. Card run: `predict · visual · concept ×3 · sequence · match · mcq · practical · bagpick · recall`.
- **`m5l7` — "Espresso, in one small cup"** (Brew, 6 cards, the shortest). An orientation lesson pulled forward from the v2 Espresso Basics module: `predict · concept ×2 · mcq · decision · recall`.

Every lesson carries `points: 10` and `time: 3–6 min`; card counts run 6–11.

**Cards per lesson** (display order): m1l1 8 · m1l2 10 · m1l3 9 · m1l4 8 · m1l5 9 · m1l6 7 · m1l7 11 · m2l1 8 · m2l2 8 · m2l3 8 · m2l4 8 · m2l5 8 · m2l6 8 · m3l4 8 · m3l1 8 · m3l2 7 · m3l3 7 · m3l5 8 · m3l6 8 · m4l1 7 · m4l2 9 · m4l5 8 · m4l3 7 · m4l6 8 · m4l7 7 · m5l1 7 · m5l2 8 · m5l4 8 · m5l5 8 · m5l3 8 · m5l7 6 · m5l6 10 = **257**

**144 graded cards.** All strings carry typographic quotes and dashes.

> ✅ **The writing pass has landed.** **Zero lessons** now carry `draft: true`;
> the flag was removed from all 15 that had it. Prose is no longer provisional.

*(A recursive string count over `MODULES`, `LESSONS`, `COLLECTION` and
`MODULE_REWARDS` is the only defensible size measure; the old "1,445 strings"
figure predates two restructures and should not be quoted.)*

## 6.2 Card kinds (14 authored, 16 with renderers)

| Kind | Count | Graded | What it is |
|---|---|---|---|
| `concept` | 66 | no | Teaching card. **Fill-in-the-blank sentence** (tap a word from two choices per blank — the sentence always resolves correctly, so the user always leaves with the right idea) + paragraphs + a meta key/value pair |
| `predict` | 32 | no | Opening card. A framing body + one binary guess, held at lesson scope |
| `recall` | 32 | **yes** | "Before you go" — closing check that resolves the opening prediction, plus a one-line takeaway |
| `decision` | 28 | **yes** | Scenario card ("AT THE SHELF" / "IN THE KITCHEN" / "AT THE BREWER") — a real situation, two options, separate right/wrong explanations, plus a takeaway note |
| `mcq` | 27 | **yes** | 4-choice multiple choice + explanation |
| `match` | 17 | **yes** | Drag or tap-tap pairing, several traits can share an answer, animated connector lines |
| `sequence` | 12 | **yes** | Tap items in order, submit, reveal which spots were right |
| `visual` | 10 | no | Full-bleed visual guide, savable to Saved under a `g:` key. **8 variants, all with art** (§6.3) |
| `multi` | 10 | **yes** | Select-all-that-apply, graded as a whole set |
| `slider` | 9 | **yes** | Calibrate — drag to a value, check against a target range (incl. a grinder-dial variant) |
| `tastefix` | 7 | **yes** | A cup came out wrong — pick the one change that fixes it, watch the cup react |
| `practical` | 5 | no | Hands-on instruction card. Four in `m5l6` (*Your first good cup*), one in `m1l7` |
| **`flavor`** | **1** | **yes** | **New.** A tasting clue ("Sharp and lively, with sweetness underneath and a finish that lingers") and four notes to choose from. Renderer `FlavorNoteCard`; the only authored instance is in `m5l3` (*Tasting your cup*), and it also backs the `g-flavor` mini-game |
| **`bagpick`** | **1** | **yes** | **New.** Draw a sample from an unlabelled bag, inspect colour / centre cut / mottling / chaff on the rendered green beans, and call the process from the look alone. Renderer + content in `bean-anatomy.jsx`; the only authored instance is in `m1l7`, but it also backs a full mini-game (§6.5) |
| `intro` | 0 | no | Plain framing card. **Renderer exists, no authored card anywhere** — superseded by `predict` |
| `takeaway` | 0 | no | Closing statement card. **Renderer exists, no authored card anywhere** — superseded by `recall` |

`active-cards.jsx` records the supersession explicitly: `predict` was `intro`,
`decision` was `practical`, `recall` was `takeaway` — the three read-only beats
became active ones. `intro` and `takeaway` are the leftovers of that change and
are candidates for deletion rather than authoring.

**Help drawer.** `CARD_KIND_HELP` (`lesson.jsx:9`) holds title + blurb + 3
numbered steps, surfaced from a "?" button in the lesson top bar. It has **10
entries and does not cover every kind**: `mcq` · `multi` · `match` · `slider` ·
`sequence` · `tastefix` · `bagpick` · `fill` (the concept fill-in-the-blank) ·
plus `quiz` and `flavor` for the mini-games. The "?" button simply does not
render for a kind with no entry — so `decision`, `recall`, `predict`, `visual`
and `practical` have no help. Whether that is deliberate (they are
self-explanatory) or an omission is an open question, not a documented decision.

> ⚠️ Earlier versions of this doc called this `GAME_HELP` and claimed every
> interactive kind had an entry. **No `GAME_HELP` exists in the source**; both
> the name and the coverage claim were wrong.

> ✅ **Fixed (Aug 2026).** `flavor` briefly scored without being counted —
> `FlavorNoteCard` incremented the correct tally while the kind was missing from
> the graded list, so mastery could exceed 100% and a perfect score was reachable
> with a wrong answer. `flavor` is now in the list at `lesson.jsx:165` and the
> graded total is 144.

**Lesson player chrome:** close button, `RoastBean` progress (fills as a roasting bean) + `NN / NN` counter, save-lesson bookmark. Glossary terms inside body copy are auto-linkified and open a `TermPeekSheet` without leaving the lesson.

## 6.3 Collectible cards — 37 collectibles + 5 guides, two registries

**The collectible model was restructured.** Training guides used to live inside
`COLLECTION`; they now sit in their own `TRAINING_CARDS` array. The recorded
reason is precise: sharing one array *"made a plain 'no two cards share a title'
check report false collisions."*

| Registry | Count | Unlock | In the Cards grid? |
|---|---|---|---|
| `COLLECTION` — lesson cards | 32 | One per lesson, no gaps | Yes |
| `COLLECTION` — module Field Guides | 5 | Beans · Processing · Roasting · Grind · Brew | Yes |
| `TRAINING_CARDS` — visual guides | 5 | `earned: true`, always available | **No — a separate array, never listed beside a collectible** |

`COLLECTION` **array order is the catalogue number printed on each card**, so
entries are never re-sorted — only appended.

**The 5 training guides:** `tr-roast` Roast Levels · `tr-grind` Grind Size ·
`tr-extraction` Extraction · `tr-ratio` Coffee-to-Water Ratio · `tr-anatomy`
The Cherry in Section. Each carries identity plus a `meta` table; its words come
from `TRAINING` (`practical.jsx`).

### One card, one text — the invariant, and how *not* to port it

A collectible entry carries **identity only** — `id`, `kind` (its art and tint),
`unlock`, and an `earned` first-paint seed. **The words are not stored there.**

**The invariant, which matters:** a card's title, summary and fact are authored
in exactly one place — the lesson's own `reward`, or `MODULE_REWARDS`, or
`TRAINING` for the guides — and every surface that shows that card reads from
it. The stated purpose is *"so the reward moment and the collection sheet cannot
show two different facts."*

That is worth keeping. Before it existed, the same fact lived twice and nothing
stopped the two copies drifting; both strings look fine in isolation, which is
why that class of bug survives review.

**The prototype's mechanism, which is not worth keeping.** Two functions mutate
the arrays in place at load:

| Function | Copies | From | Into |
|---|---|---|---|
| `syncCardText()` | `title`, `summary`, `fact`, `meta` | the lesson's `reward`, or `MODULE_REWARDS` | the 37 `COLLECTION` entries |
| `syncTrainingText()` | `title`, `summary`, `fact` | `TRAINING` | the 5 `TRAINING_CARDS` |

Two properties of that approach are prototype-grade only:

- **It depends on script order, enforced by nothing.** `TRAINING_CARDS` ships with no titles at all — load `data.jsx` without `practical.jsx` and every guide is `undefined`. The titles exist solely because `practical.jsx` runs the sync afterwards, ten `<script>` tags later in `index.html`. Reorder them and five cards render blank with no error.
- **It fails quietly.** `syncCardText()` does `if (!src) return;`, so a collectible pointing at a lesson with no `reward` keeps whatever it had. *(All 37 currently resolve, and the QA record checks this — so there is no live gap, only a silent failure mode.)*

> **For the port: keep the invariant, drop the technique.** Derive a card's text
> from its lesson at read time — a getter, or a view model that takes the lesson
> as a dependency — so the compiler enforces what script order is currently
> enforcing by luck. Mutating a global list at startup and depending on
> initialisation order is a bad shape in Dart, and porting it faithfully would be
> a more expensive mistake than the blank titles it risks in the prototype.

**Not worth fixing in the prototype.** The order is correct, the dependency is
commented at both ends, and the failure is latent. The prototype is a
specification, not shipping software.

> ✅ **The three duplicate titles are resolved.** Extraction, Fermentation and
> The Cherry in Section no longer collide — `duplicateTitles` returns empty
> across both registries. The fix was structural (splitting the arrays) plus
> renaming, and the QA record now carries "no two collectible cards share a
> name" as a standing check.

**Art coverage is complete.** 37 collectibles, 37 distinct `kind` values — one
per card — each with art in `CARD_ART` and a tint in `CARD_TINT`. Both maps read
one higher (38 and 39) because each also carries a `guide` key belonging to the
library list rather than the grid.

Each card: title, summary, a `fact`, and a `meta` key/value table, plus bespoke
inline-SVG art and a colour tint. `MODULE_REWARDS` carries an additional badge
string per module (`BEANS · COMPLETE` … `BREW · COMPLETE`).

> **In the Cards grid**, only **earned cards plus one locked teaser** render, with
> a "{n} more to collect" footer — see [§5](05-mechanics.md) 5.6.

## 6.4 Coffee Dictionary — 72 terms, 8 categories

Categories and their counts: Beans and Botany (16) · Processing (12) · Equipment (9) · Roasting (8) · Brewing (7) · Espresso (7) · Coffee Trade (7) · Sensory Vocabulary (6).

Term shape: `{ id, term, pron?, cat, aliases?, short, deep?, example?, related[], lesson?, sources[], check{q, choices, explain} }`.

| Measure | Count |
|---|---|
| Terms | **72** (was 42) |
| "Full" terms carrying deep text | **46** (was 18) |
| Stubs with `short` only | 26 |
| With a self-check question | 29 |
| With a pronunciation respelling | 23 |
| **Reference-only** (no lesson teaches them) | **8** |

Sources cited across the full terms: Hoffmann's *World Atlas of Coffee*, SCA, World Coffee Research, Perfect Daily Grind.

#### The third term state: Reference

Previously a term was either **Learned** or **To learn**. A third state now
exists for terms **no lesson teaches**, so they can never become Learned:

| State | Glyph | Chip | When |
|---|---|---|---|
| Learned | filled `--sage` dot | `LEARNED` | The term's source lesson is complete |
| **Reference** | **hairline ring + a 7×1.5 `--ink-mute` dash** | **`REFERENCE`** | **`!term.lesson` — nothing on the path teaches it** |
| To learn | hollow dot, dashed `--rule` ring | `TO LEARN` | Readable, not yet taught |

The design note in `ds-content.js` is the rule to carry over: *dashed means "not
yet"; the dash means "not on the path at all". Never show a to-learn ring for a
term no lesson teaches* — a dashed ring there would be a promise the course
can't keep.

Behavioural consequences, all in `dictionary.jsx`:
- The **To-learn filter excludes reference terms** (`isToLearn = !learned && !!t.lesson`), and the filter counts follow. They appear under **All** only.
- `TermDetail` swaps the "WHERE YOU'LL LEARN IT" lesson card for a **`REFERENCE ONLY`** block reading *"No lesson covers this one — it's here for when you meet it on a bag or a menu."* Stated plainly rather than dropped, because a silent gap reads as a bug and a false link reads as a lie.
- Route `term-reference` deep-links the state (seeded with `masl`).

**The 8 reference-only terms:** `masl` · `wet-hulled` · `tds` · `cold-brew` · `cupping` · `gooseneck` · `sca` · `origin-boards`.

**Learned state**: a term is "learned" once its source lesson is complete; plus a 6-term demo seed. `dictLessonAudit()` returns `[]` — every non-reference term's `lesson` pointer resolves to a lesson that actually teaches it.

**Dictionary surfaces:**
- `DictionaryHome` — search bar (matches aliases, deep-linkable via `initialQuery` / `focusSearch`), status filter with live counts, category grid, Term-of-Day banner, quick chips (Flashcards, Vocab game). ⚠️ **No recent strip** — the `recent` prop is passed and never read; see [§7](07-components.md) 7.6
- `TermDetail` — pronunciation + text-to-speech button, deep text, example, self-check, related-term chips, a link into the source lesson **or the Reference-only block**, sources list
- `TermPeekSheet` — compact non-interrupting peek used inside lessons
- `TermOfDayScreen` — deterministic term-of-day by date (frozen to 18 Jun 2026, [§5.11](05-mechanics.md))
- `FlashcardsScreen` — drill over saved terms
- `VocabGameScreen` — generated multi-round vocab drill

The two Practice screens share the app's standard drill chrome — a lesson top bar with the roasting-bean counter, the same pattern `MiniGamePlayer` uses, and a Roasty results screen at the end.

## 6.5 Mini-games — 7 (standalone, replayable)

Separate system from lesson cards: own intro → play → results flow, **never** touch lesson points or progression.

| id | Title | Kind | Subject | Length |
|---|---|---|---|---|
| `g-match` | Match the facts | match | ARABICA VS ROBUSTA | ~2 min |
| `g-flavor` | Name the flavor notes | flavor | TASTING NOTES | ~2 min |
| `g-quiz` | True or false | quiz | COFFEE BASICS | ~1 min |
| **`g-bagpick`** | **Read the green bean** | bagpick | WASHED, HONEY OR NATURAL | ~2 min |
| `g-tastefix` | Fix the cup | tastefix | DIAGNOSE AND DIAL IN | ~2 min |
| **`g-calibrate`** | **Dial it in** | slider | GRIND, RATIO, WATER, TIME | ~2 min |
| **`g-sequence`** | **Put it in order** | sequence | BEAN TO CUP | ~2 min |

Three are new (`g-bagpick`, `g-calibrate`, `g-sequence`), and the catalogue now
covers every drillable card kind rather than a sample of them. `g-bagpick` runs
five unlabelled bags from `BAGPICK_ROUNDS`.

Each has a blurb + 3 how-to-play steps + its own content bank (`MINI_GAME_CONTENT`). Surfaced under Learn → "Practice again → Mini-games", where the row leads with the *lesson* name and the game name becomes the eyebrow.

## 6.6 Coffee Challenges — 12

| id | Type | Title | Effort |
|---|---|---|---|
| `bc-m1` | module | Two cups, two ratios | Next brews · 5 min |
| `bc-m2` | module | Blind process test | Next brews · 5 min |
| `bc-m3` | module | Light vs dark, same origin | Next bags · 5 min |
| `bc-m4` | module | One-step grind test | Next brews · 3 min |
| `bc-m5` | module | Fix one bad cup | Next brew · 3 min |
| `bc-m1l1` | lesson | Name the origin | Next bag · 1 min |
| `bc-m3l1` | lesson | Compare two roasts | Next bags · 5 min |
| `bc-m4l3` | lesson | Move one grind step | Next brew · 3 min |
| `bc-m5l1` | lesson | Dial your ratio | Next brew · 3 min |
| `bc-m2l6` | lesson | Blind decaf test | Next brews · 5 min |
| `bc-m4l6` | lesson | Fresh vs pre-ground | Next brews · 5 min |
| `bc-m5l6` | lesson | Brew it by the numbers | Next brew · 5 min |

`BREW_TOTAL` derives from `BREW_CHALLENGES.length` (**12**), which is what the
Profile stat counts against. Seven of the 32 lessons carry one. Challenges exist
only where a beginner can honestly run the experiment with beans and a brewer
they already own — which is why 25 lessons have none, `m5l7` (espresso)
deliberately among them.
Each has three reaction options for the log sheet (e.g. "Tasted the difference / Hard to tell / Only brewed one").

## 6.7 Personalization content (Studio)

**The tree chooser is now two axes, not one skin list.** `Tree Variety Proposal
v2.html` is the design record; `customize.jsx` is the implementation.

**Axis 1 — species** (`TREE_VARIETIES`). What is planted. Each carries real
botanical data used as the chooser's copy: latin name, world share, typical use,
origin, growing conditions, cup character, and a `tell` sentence.

| id | Name | Share | Use | Silhouette | Ships |
|---|---|---|---|---|---|
| `arabica` | Arabica (*Coffea arabica*) | ~60% | Filter & pour-over | unmodified | launch |
| `robusta` | Robusta (*Coffea canephora*) | ~35% | Espresso & instant | `scale(1.2, 0.9)` — broader, bushier | launch |
| `liberica` | Liberica (*Coffea liberica*) | <1% | Local brews in SE Asia | `scale(1.1, 1.12)` — taller, bigger leaves | **`drop: 'later'`** |

**Axis 2 — light** (`GROVE_LIGHT`). What it stands in — mood only, four treatments including the unfiltered default: **Daylight** (no filter) · **Golden Hour** (late sun) · **Moonlit** (cool night) · **First Frost** (cold morning).

Species and light compose into one CSS filter (`groveFilter`) plus a separate transform (`groveShape`), over the same 10 stage PNGs. *(A real ship would want bespoke art per species — the silhouette transform is a stand-in, and `drop` is the rollout note for that art.)*

**Roasty options:** 4 roast levels (Light · Medium · Dark · Espresso, each with a swatch) · 4 hats (None · Beanie · Field hat · Cap) · 5 gear (None · Glasses · Shades · Scarf · Headphones) · 4 sprouts (Leaves · Blossom · Cherry · Bare).
**5 backdrops** (mood player, v2): Studio · Cream · Sage · Berry · Night.

Default Roasty: `{ roast: 'medium', hat: 'none', gear: 'none', sprout: 'leaf' }`. Default grove: `arabica` + `daylight`.

## 6.8 Settings content

**Appearance** — theme row (Light / Dark / System)
**Practice** — Notifications toggle · Daily reminder (`REMINDER_TIMES`, 8 presets: 6:30, 7:00, 7:30, 8:00, 8:30 AM · 12:30 PM · 6:00, 8:30 PM; default 8:00 AM) · Sound effects toggle · Haptics toggle
**Account** — Account and sync · Subscription (Free / Trial / Plus) · *Download my data (v2 only)*
**Support** — Help and support · About
**Destructive** — Reset progress · Delete account

Both destructive actions use a `danger` `ConfirmSheet`.

> ✅ **Decided (Aug 2026): account deletion is permanent — no recovery period.**
> The prototype's copy still promises a 30-day restore ("Sign back in before then
> and it's all restored") and is **superseded**; the body must be rewritten to
> state that deletion is immediate and cannot be undone. See
> [§5](05-mechanics.md) 5.12.

**Help FAQ — 4 entries** (`FAQ_ITEMS`, `settings.jsx:619`). The answers are load-bearing spec, not filler:
1. *How does my streak work?* — restates the 7-day earn, freeze cap, automatic spend, and "nothing to switch on". ⚠️ **The shipped string is now wrong twice over** and must be rewritten before it ports: the cap is **1, not 2** ([Streak freeze](https://github.com/maximsan/brewpath/issues/58)), and *"finish at least one lesson a day"* understates the qualifying rule, which also accepts a completed replay, two different mini-games, the Vocab game, Flashcards and Keep Sharp ([The streak's qualifying-activity rule](https://github.com/maximsan/brewpath/issues/33)).
2. *How does my tree grow?* — "tracks the core course only … ten stages from bare seed to full harvest", points don't grow it, never shrinks except on reset.
3. *What do I get with Plus?* — unlimited Saved (free keeps 10) and the Studio; **learning content is always free, and so is your streak**.
4. *Can I learn offline?* — "modules you've opened are kept on your phone. Progress syncs the next time you're online." **This is an offline requirement, not just copy.**

**About screen** (`A FIELD GUIDE TO COFFEE`) — **6 rows, not a static page**:
`THE FINE PRINT` → Privacy policy · Terms of use · Acknowledgements · Open-source licenses;
`SAY SOMETHING` → Rate BrewPath · Say hello (`hi@brewpath.app`). Plus the version line.

**Help and support** — `COMMON QUESTIONS` (the 4 FAQ rows above) plus
`GET IN TOUCH` → Email support (`hi@brewpath.app`) · Report a problem.

**Subscription screen**: status (Trialling / Active), plan display, Renews / Next charge / First charge, benefits list (Unlimited Saved · Dress up Roasty · Choose your plant), change plan sheet (`PLAN_OPTS`), Restore purchases, cancel.
**Account and sync screen**: email, Plus/trial status pill, plan line, **Sync over cellular toggle**, **This iPhone device row**, Manage Plus / Upgrade to Plus, Sign out.

> ⚠️ **All 8 About and Help rows are `onClick={() => {}}` stubs** — they look
> finished and do nothing. Two of them (Privacy policy, Terms of use) are
> store-review requirements that also appear on the paywall. See
> [§7](07-components.md) 7.3.

## 6.9 The content rulebook (`CLAUDE.md`)

**New, and it closes a long-standing gap.** Until now the reference said nobody
had written down what makes a question good. `docs/design/content-rules.md` now does —
seven rules, all about the course content rather than the code:

| Rule | What it forbids |
|---|---|
| **No two cards in a row share an answer** | Checked across the whole lesson, not just adjacent pairs. If two cards both resolve to "grind finer", the second teaches nothing — the learner pattern-matches instead of reasoning |
| **No option is always right** | If a lesson presents a trade-off, the graded cards must cut both ways. A lesson that says "Robusta earns its place" and only ever rewards Arabica teaches the opposite of what it claims |
| **A question must be able to surprise** | If the answer is obvious from the framing, or is simply the longest/most specific option, rewrite it. Prefer scenarios where the intuitive answer is wrong |
| **A note must not restate its verdict** | Decision cards carry a `right`/`wrong` reaction *and* a `note`. The note only earns its place if it **generalises** — turns the scenario into a rule, adds the other half of the trade-off, or names the misconception sidestepped |
| **Distractors must be genuinely wrong, not merely worse** | A distractor that would also work makes the card unanswerable. Where one is a common real mistake, name it in the explanation |
| **Match cards must not be solvable by elimination** | Use uneven distributions (3:2, 2:1:1) so no drop is forced by the ones before it. An even split is really n−1 questions and a freebie |
| **…except where the content is genuinely bijective** | Cherry layers, roast stages, origin → flavour, label claim → guarantee, decaf method → mechanism. **Never fabricate a pair for the sake of an uneven split** |

The last two together are the sharpest thinking in the file: a rule, and an
explicit carve-out that stops the rule being applied where it would force
invention.

> **What this does and does not close.** It defines the standard. The audit's
> third remaining task — *"Play the course"* — is still open: whether each card
> actually meets these rules is a human pass that has not been done.

---

← [Core logic and mechanics](05-mechanics.md) · [Contents](README.md) · [Component & state inventory](07-components.md) →
