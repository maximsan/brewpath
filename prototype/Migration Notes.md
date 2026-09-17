# Migration Notes

The decision log behind the BrewPath prototype: what was built, what was tried and
dropped, and why. It exists to be **ported** — the prototype is HTML/React, the
product is a Flutter app, and nearly everything recorded here is a rule about
behaviour or composition rather than about the web.

## How to read this file

**Three kinds of statement, and they port differently.**

| | What it is | In the port |
|---|---|---|
| **Rule** — the bold lead-ins | A decision that binds every screen: the direction contract, one box per page, hints stop on use | Must survive verbatim. A Flutter build that breaks one has a bug, not a platform difference |
| **Finding** | Why an approach failed — a race, a contrast measurement, a geometry trap | Read before re-deriving. Many are platform-neutral (gesture arbitration, sticky offsets, damped resistance); the React-specific ones say so |
| **Number** | A threshold, duration or offset chosen against a measured constraint (104px park, 240ms disclosure, 92px of label uncovered) | Carry the number **and** its constraint. A number re-picked by feel is how two builds drift |

**The Design System is normative; this file is the history.** `ds-content.js`
(rendered by `Design System.html`) carries the live rule for every component, and
a note here points at the DS entry and records what it replaced. Where the two
disagree, the DS is right and the note is stale — a defect, and worth fixing.

**Shared primitives that need Flutter equivalents, not transliterations.**

| Prototype | File | What the port owes it |
|---|---|---|
| `useSwipeX` — the one horizontal gesture: direction contract, damped block, fly-off commit | `swipe.jsx` | ONE gesture implementation app-wide. Every screen that forked it cost the same bug twice (§27, §28, §33) |
| `DeckStack` — the peeked neighbour that makes a deck look swipeable | `swipe.jsx` | A stack behind the card, sized to the card, **outside** its transform (§29, §30) |
| `useSwipeHint` + `SwipeHintCaption` — nudge twice, caption, stop on USE | `swipe.jsx` | One controller per gesture over a persisted used-flag; the flag also dims the standing affordance (§9, §11, §33) |
| `Disclosure` — the one expand/collapse | `disclosure.jsx` | Two glyphs, 240ms, collapsed content out of the focus order (§3) |
| `HEADER_H` / `HEADER_PAD` / `HEADER_FADE_H` / `STICKY_SECTION_TOP` | `settings.jsx` | Derive the pinned offset from the bar and the scroll padding; never pick it (§18) |
| `MODULE_REWARDS`, `COLLECTIBLES`, `VISUAL_GUIDE_CONTENT`, `FREE_LESSON_IDS` | `data.jsx` | Author each text once and sync at load; derive every tier and count, never hand-keep them (§1, §5) |

**Course-content rules are not here.** Card authoring — distractors, note versus
verdict, match-card distribution, free-tier honesty — lives in `CLAUDE.md` and
binds the course data whichever framework renders it.

**How the log is kept:** when a note is superseded the old note is **deleted** and
the new one appended at the END — never edited in place, never two versions of one
rule. The order of the file is the order the decisions happened. Any new
component, style, colour or pattern is documented in the Design System first and
gets a short pointer here.

## 1. Training Guides → Module Rewards / Visual Guides

The old "Training Guides" concept was split into two distinct systems; the name no longer exists anywhere in code or docs.

**Module Rewards** — the per-module completion reward (the Field Guide collectible card).
- Registry: `MODULE_REWARDS` in `data.jsx` (keyed `m1–m5`; `title`, `summary`, `fact`; `meta` derived from module data so lesson counts can't drift).
- One card, one text: `syncCardText()` copies words from `MODULE_REWARDS` into `COLLECTIBLES` at load — reward screen and collection sheet can never disagree.
- Screens: `ModuleCompleteScreen` → `ModuleRewardCardScreen` (`rewards.jsx`); routed in `app.jsx`.
- Also consumed by the locked-game gate sheet (`gating.jsx`): the module's `summary` is the pitch under "TAUGHT IN <module>".

**Visual Guides** — explorable reference diagrams (roast, grind, extraction, ratio, anatomy, variety, caffeine, distribution).
- Registry: `VISUAL_GUIDE_CARDS` in `data.jsx` — deliberately a SEPARATE array from `COLLECTIBLES`: they render on the Reference shelf, don't count toward the collection total, and sharing one array broke the "no two cards share a title" check.
- Words authored once in `VISUAL_GUIDE_CONTENT` (`practical.jsx`), copied by `syncVisualGuideText()` at load.
- Field renames: card kind is `visualGuide`; lesson cards use `kind: 'visual'` with a `visualGuide: '<id>'` pointer; ids are `g-<topic>`.
- Unlock: each guide gates on the first lesson that shows its visual (`unlock.lesson`); `syncCollection()` flips `earned`.
- Lookups: `findCard(id)` spans both registries; `findVisualGuideCard(guide)` resolves by visual id.
- User-facing label everywhere: "VISUAL GUIDE" (library rows, card sheet, lesson cards, screens-overview).

## 2. Game catalog expansion (this session)

Vocabulary: a **kind** is the mechanic; a **game** is one catalog entry — kind + one course topic + its own 5–7-round bank, persistent id.

- Catalog: 13 games over 7 kinds in `MINI_GAMES` (`screens.jsx`), grouped by kind under `GAME_KINDS`, fixed order. Rendered in the Learn tab's "Games" group (with the 2 dictionary exercises as its first rows).
- Ids: the original seven (`g-match`, `g-quiz`, `g-flavor`, `g-bagpick`, `g-tastefix`, `g-calibrate`, `g-sequence`) are FROZEN — persisted in stored day-sets. New ids are topic-slugged: `g-match-washed-natural`, `g-quiz-roast-basics`, `g-flavor-origin-signatures`, `g-tastefix-espresso`, `g-calibrate-grind-brewer`, `g-sequence-v60`.
- Tier derives from topic: free iff the LESSON that teaches its topic is free (`FREE_GAME_IDS` is derived, never hand-kept). See §5 — asking whether its MODULE is unlocked is actively wrong now. Free today: g-match, g-quiz, g-flavor-origin-signatures — taught by m1l1/m1l2/m1l3, the three free lessons. Ref: #175.
- Locked-game gate sheet leads with "TAUGHT IN <module label>" + module pitch; upgrade-only in v1.
- Bagpick stays a single game — its mechanic is bound to the green-bean artwork; uneven groups are intended.
- Round banks: `MINI_GAME_CONTENT` (`lesson.jsx`); all 13 authored.
- Pipeline (documented, not scheduled): second M5 tasting topic; AeroPress / Clever / drip-packet sequence recipes — wait on lessons that teach them.
- Doc surfaces kept in sync: Design System access-tier table + rules (`ds-content.js`), `games.html` (7 kinds · 13 games).

## 3. Disclosure consolidated (this session)

Seven hand-rolled expand/collapse patterns replaced by one component, `Disclosure` (`disclosure.jsx`). DS entry: **Components → Disclosure · window.Disclosure**.

- Drift it removed: FaqRow used plus-to-cross and was keyboard-unreachable; Path rows had their own 11×7 chevron at 320ms; the rest were the same caret at three sizes and three durations.
- Two glyphs only — caret for lists, plus for FAQ prose. One duration — 240ms. Collapsed panels take `visibility:hidden` on delay so hidden content leaves the tab order.
- Rows with nothing to disclose render as static divs, not dead buttons (active Path module, locked Reference shelf).
- Group counts live in the header label (`LESSONS · 1`), matching `FOR LATER · n`; the trailing edge carries only the glyph and, where gated, the lock. Sub-group counts were dropped as redundant.

## 4. Collection ordering and the card mark (this session)

- `COLLECTIBLES` (`data.jsx`) now **sorts itself at load** into course order: by module, by lesson, each module's Field Guide closing its run. It had grown by append, so finishing Module 1 gave cards 01–04 and 21–24. Ids untouched; display order only.
- The locked "?" teaser tile is gone from the Cards grid — the "N more to collect" block below says the same thing, and out-of-order progress stranded it mid-grid.
- The "tried in real life" mark is a **coffee ring**, not a checkmark: `window.CupRingGlyph` (`screens.jsx`), used by the grid corner badge and the card sheet's TRIED chip. Empty dashed ring = to earn. DS entry: **Components → Card mark**.
- Module-closing lessons earn two cards (the lesson's and the Field Guide). The module reward screen reveals them **one at a time** with a card counter and a Previous card step; it is not a second full screen, and the two cards are never stacked.

## 5. Free tier narrowed to three lessons (this session)

Supersedes the "Module 1 entire" rule wherever it appeared.

- `window.FREE_LESSON_IDS` (`data.jsx`) is now the literal list `['m1l1','m1l2','m1l3']`. `FREE_MODULE_IDS` is deleted: deriving the tier from a module id would silently widen it the moment a lesson is added to m1.
- The load-time guard validates **each id** against `MODULES` and names the missing ones. Checking only that the set is non-empty let a typo'd id quietly lock the lesson it was meant to open.
- `FREE_GAME_IDS` stays derived from the lesson, never the module. It still comes out at three only because no game is taught by m1l4–m1l7.
- Copy updated at every site: paywall note, Settings FREE panel, Settings FAQ, DS access-tier table and rules, `v1 Readiness Audit.html` (dated supersession line). The "module test" claim was struck everywhere — the app has never had one.

## 6. Challenge card: slide to park (this session)

The optional Coffee Challenge card is dismissed by **sliding it aside**, not by a button. DS entry: **Components → Slide to park**.

- What was tried and dropped: an icon-only clock button (said nothing on its own), a `LATER` pill in the title row (wrapped the heading — the glyph plus its gap cost more width than the label), a ghost text row under the CTA (a second stacked action).
- Log result stays a visible CTA. It opens a form, and gestures can only fire an action — so the gesture takes the skippable job and the button keeps the primary one.
- Standing affordance: a directional double chevron inside the card (see §9 for its lifetime). An accent strip poking out of the left edge was tried and dropped — at 6px with a straight right edge it read as a separate object, and at the track's own 9%-accent tint it was 1.06:1 against the card.
- First-run hint: nudges the card twice with a caption (see §11 for when it stops). Replayable from **Tweaks → First-run hints**.
- Travel threshold is set by the label, not by feel: `PARK_AT = 104` with a 12px track inset uncovers 92px of an ~84px label, so the destination reads whole at release. At the earlier 92/20 it clipped its last glyphs exactly as the user decided to let go.

## 7. Reward copy is second-person (this session)

`MODULE_REWARDS` (`data.jsx`) — each card's `fact` (the MEMORABLE line) now names the thing that used to be opaque and hands it over: *"Washed, natural, honey — now you know why they matter."* The summary claims the capability; the fact must not restate it. Beans' and Roasting's summaries moved because the new line said what they said.

## 8. Replays queue under For Later (this session)

Supersedes the `OFF TODAY` label noted earlier — that note is deleted, not amended.

The bug: sliding an already-completed challenge aside cleared it off Today but never added it to For Later, so the gesture moved the card toward a destination it never reached.

- `skipBrew()` and `saveBrew()` (`app.jsx`) no longer refuse completed challenges — you only see one because you chose to brew it again, so "later" is a real intent.
- `SavedBrewList` (`brew-challenge.jsx`) filters only the currently active challenge. A completed entry renders with **Brew again** instead of **Start**, so the queue never implies it is unfinished.
- The track keeps one label, `FOR LATER`, for every case. Considered and rejected: keeping the no-requeue rule and relabelling the track `OFF TODAY` per replay — two labels for one gesture, to preserve a rule whose only symptom was the lie.

## 9. The swipe chevron persists (this session)

Supersedes "retires on first use" in §6 — that wording is removed there, not amended.

The chevron now steps back rather than disappearing: bright under the first-run hint, `0.7` until the gesture has been used, a quiet `0.35` ever after.

Why the reversal: "an affordance teaches, it does not decorate" holds for gestures performed daily. A Coffee Challenge surfaces roughly once per module, so by the next card the gesture has been forgotten and — with the hint budget spent — nothing on screen recalled it. That was the same discoverability hole the gesture work set out to close.

## 10. One horizontal swipe, one direction contract (this session)

`window.useSwipeX` (`swipe.jsx`, loaded after `disclosure.jsx`) — the shared gesture behind every card stack. DS entry: **Components → Horizontal swipe · window.useSwipeX**.

- **Direction is a contract:** left advances, right goes back or sets aside. Destructive actions get no swipe at all — the same motion must never mean "keep for later" here and "delete" there.
- Wired first where no product decision was attached: the **flashcard deck** (`dictionary-extras.jsx`, next/previous through the deck) and the **module reward carousel** (`rewards.jsx`, between the two earned cards). See §12 for what happened to the deck's buttons.
- Past the end of a deck the card moves damped to ~22% rather than freezing: a dead card reads as broken, a resisting one reads as empty.
- The hook owns arithmetic only — claim-threshold, damping, click suppression. Visuals stay with the caller.
- Considered, not built: swipe-to-grade on flashcards (the Anki idiom). That is not a gesture change but a new feature — it needs a second pile, a re-drill loop, and a results screen reporting recall instead of a count. Swipe-to-bookmark on dictionary rows shipped separately — see §11.

## 11. Swipe to save, and hints that stop on use (this session)

Supersedes the "up to 3 showings" hint rule in §6 — that wording is removed there, not amended. The `*-hint-shown` counter keys are gone with it.

**Swipe-to-save on dictionary rows** (`DictTermRow`, `dictionary.jsx`). Right — the set-aside direction — bookmarks the term, which is what fills the flashcard deck. DS entry: **Components → Horizontal swipe**.
- **Save-only, never un-save.** An already-saved row damps to 22% and its track reads `ALREADY SAVED` instead of `SAVE`, so the resistance explains itself. Un-saving stays on the button: losing a curated list to a stray 70px drag is the destructive case the direction contract keeps off gestures.
- The nudge teaches on the first unsaved row **above the fold** (`ROWS_ABOVE_FOLD`), not row 0 and not the first unsaved anywhere: the browse list opens on terms the user has usually already saved, so index 0 demonstrated the state where the gesture does nothing — and "first unsaved anywhere" moved the demonstration ~250px below the fold while its caption stayed in plain view. With every reachable row saved, nothing nudges and the caption does not render.

**Hints stop on USE, not on a count.** All three (`cq-brew-swipe-used`, `cq-flash-swipe-used`, `cq-dict-swipe-used`) show every time until the gesture is actually performed once. A cap only ever fires on the user who has not learned the gesture — who needs the explanation more the third time, not less. One Tweaks button resets all three.

## 12. Flashcards: the deck replaces its buttons (this session)

Supersedes §10's note that the deck "keeps its existing buttons" — that wording is removed there, not amended.

**Prev/Next deleted.** They used the opposite direction model to the gesture: a left chevron meaning "back", 40px under a card whose left drag means "next". Only **Finish** survives, on the last card — completing the deck is the one state a swipe cannot announce.

**The stack is the standing affordance.** A card sits visibly behind on each side — right until the last card, left once past card 1 — rising into place as the drag goes its way, so the current card visibly leaves. Both are built from one helper mapped over `[-1, 1]` so the sides cannot drift.

- The slivers sit at **full opacity** with a 52%-accent edge. A first attempt used `opacity: 0.55` over a 7%-accent fill and measured 1.09:1 against the page — invisible, and by then it was the only affordance left. Depth comes from offset and scale, which cost no contrast. This was the same dilution mistake as the challenge card's accent strip (§6).
- **Arrow keys are point-at-target, not the drag model:** Right advances, Left goes back. Mapping keys to the gesture's own direction put the collision back, just on the keyboard. Both directions also get a focus-revealed button — the slivers are `aria-hidden`, so Next alone left AT users with no way back.

## 13. Swipes commit by flying off (this session)

`useSwipeX` (`swipe.jsx`) gained `exitDistance`, `exitDurationMs` and `tiltDegreesPer100px`. A committed card now leaves the screen with a tilt before the content changes; previously it snapped back to centre with new content already inside, which read as a jump cut and made the gesture hard to see at all.

- On landing, the element returns to centre with transitions suppressed for a frame, so the incoming card appears in place rather than flying in from the edge the old one just left through.
- The exit is driven by **WAAPI on the node itself** (`bind.ref`), not by React state. Two state-driven attempts failed: a plain state write put the transition and the target value in one style recalculation, so nothing interpolated; a double-`requestAnimationFrame` version still raced the reset timer, which counted from commit rather than from when the value painted. In both, `getAnimations()` stayed empty — the card froze at the release position for the full duration and then teleported. `node.animate()` cannot be batched away; the content changes on `animation.finished`, and the `fill: 'forwards'` is cancelled a frame after React re-renders the card at centre.
- While exiting, the React-side `transition` is `none`: the animation owns the element, and a competing transition fights it on the landing frame.
- Decks and carousels opt in (flashcards 460px/7°, reward carousel 420px/6°). **List rows do not** — a saved dictionary row is still in the list afterwards, so it stays put.
- Hook fields renamed for legibility: `dx`/`dragging` → `dragX`/`isDragging`, plus `isExiting` and `commitProgress`; options `threshold`/`max` → `commitThreshold`/`maxDragDistance`.

## 14. Dictionary rows show a saved mark, not a toggle (this session)

`DictTermRow` (`dictionary.jsx`) no longer renders `FavButton`. A saved term carries a small filled bookmark in accent; an unsaved row carries nothing, with the slot reserved so rows align either way. DS entry: **Components → Horizontal swipe**.

- Ten identical outline toggles were the heaviest element on the screen and competed with the terms. Once right-swipe saves (§11), a per-row button is redundant for the add path.
- See §21: the mark is a real toggle, not a static mark.

## 15. Saved rows keep the ringed toggle (this session)

`SavedRow` (`library.jsx`) keeps `FavButton` unchanged. Two alternatives were tried and rejected:

- **A bare mark, as on dictionary rows (§14).** Every row on the Saved screen is saved by definition, so the mark states the obvious — and this is the curation surface, the one screen where removal must stay reachable. §14 already moved removal off the dictionary list; removing it here too would leave no way to un-save but opening each term.
- **The control with its ring stripped**, rendering the saved mark's own glyph at mark weight. This made a control look identical to a non-interactive mark — same glyph, colour, size, different behaviour. One appearance carrying two meanings is the same error as one gesture direction carrying two meanings.

The rule: a mark and a control may share a glyph only if they do not share a weight. Here the ring is what separates them.

## 16. Favorites drops its total count for owners (this session)

`SavedScreen` (`library.jsx`) shows the subtitle under the title only when the free cap applies.

- `6 ITEMS TO REVISIT` was the sum of the per-group counts already rendered beside each group header, plus filler wording — it restated the page.
- `3 OF 5 SAVED` stays: the free shelf limit is stated nowhere else, and the upgrade prompt below it depends on that context.

## 17. Flashcards route moves onto the terms group header (this session)

`SavedScreen` (`library.jsx`) — the full-width "Study 6 terms as flashcards" banner is replaced by a compact pill on the **Dictionary terms** group header, right-aligned opposite the label.

- The banner was an accent-tinted full-bleed button for a secondary route, sitting above and outweighing the rows it introduced.
- It belongs on the group header, not the page title: the deck is built from saved terms only, so beside "Favorites" it read as covering lessons and visual guides — and it already appeared and disappeared with terms existing.
- The group label already carries the count, so the button only names the destination.
- It is set at **type weight, not object weight**: same smallcaps as the group label, differing only in accent colour, with a small arrow — the first attempt used a bordered pill with an icon, which outweighed the label beside it and made a secondary route read louder than the group it belongs to. Padding restores the tap target without adding visible mass.

## 18. Favorites group headers adopt the count-in-label rule (this session)

`SavedScreen` (`library.jsx`) renders `DICTIONARY TERMS · 6` instead of the label followed by a loose mono digit in its own type style.

§3 set this form for disclosure headers (`LESSONS · 1`, matching `FOR LATER · n`), but these group headers predate it and were never brought over — a rule stated in one place and not applied in another, which CLAUDE.md calls out as how the prototype and the app drift apart.

The headers are also **sticky**, pinned at `window.STICKY_SECTION_TOP` — a **derived** value, never a chosen one: `HEADER_H − HEADER_PAD` (96 − 108 = −12). Sticky offsets resolve against the scroll container's **padding box**, and `.scroll` already carries `paddingTop: HEADER_PAD` to clear the bar, so any offset that counts the bar again double-counts it. Three hand-picked values failed in three different ways: `HEADER_H` (96) pinned the header at 204, leaving it 42px below its own flow position at rest and covering the group's first row; `0` pinned it inside the bar's gradient fade, dimmed with the previous row showing through; `22` — the fade's height, which is not the quantity needed — overshot the fade's bottom and stranded a clean 12px slice of the scrolling row above the header.

Pinned flush under the bar, the fade band below the bar still shows raw scrolling rows passing behind it. The header covers that band with an upward solid box-shadow (`0 -(HEADER_FADE_H + 2)px 0 var(--bg)`) rather than a fourth offset guess: a shadow paints outside the border box without affecting layout, so nothing shifts at rest. `HEADER_FADE_H` is exported alongside `HEADER_H`/`HEADER_PAD` so the three cannot drift apart.

At six saved terms pinning changes nothing; at twenty-five the group runs several screens and both the count and which group you are in scroll away. It answers both without adding an element, and keeps the Flashcards route reachable from anywhere in the list.

Considered and rejected: a per-group footer count, pagination-style. Every item is already rendered, so a pagination affordance promises a page that never arrives — and three groups would gain three footer lines to replace three inline counts.

## 19. Swipe surfaces must not be selectable (this session)

Dragging from a row's text started a native text selection, which cancels the pointer stream mid-gesture. The swipe therefore only worked when the drag began on the status glyph — an SVG with nothing to select — and felt random anywhere else.

- `userSelect: none` on the swipe surface AND on the interactive child inside it (`DictTermRow`, `dictionary-extras.jsx` flashcard face), plus `draggable={false}` on the inner button.
- `touch-action` applies to the element the touch **starts on**, not to an ancestor. Setting `pan-y` only on the row wrapper left the inner button at `auto`, so the browser owned the gesture there. It is now set on both.

## 20. Swipe robustness: capture, reduced motion, and a landing fallback (this session)

`useSwipeX` (`swipe.jsx`):

- **Implicit pointer capture is released on pointerdown.** The browser captures the pointer to the element that received it; when React re-renders that element mid-gesture — a dictionary row re-rendering after its own save — the capture is orphaned and the next gesture on a sibling row is swallowed until it expires. That is the "list goes dead for a few seconds after saving" report.
- **`prefers-reduced-motion` drops the flight**, falling back to the immediate path. A 460px 32°-tilted fling was the loudest motion in the app and the only one ignoring a preference the deck's own hint already honours.
- **The exit animation is presentation only.** `land()` now runs from whichever arrives first, `animation.finished` or a `setTimeout(duration + 120)`, guarded to run exactly once, and on the cancel path too. Previously the content change was hostage to the animation completing: a cancelled or throttled animation left `isExiting` true and the card parked at the release position.

Harness note for future work: **time-based animation does not progress in the preview iframe.** A plain probe div shows `playState: "running"`, `currentTime: 0` and no movement for both WAAPI and CSS transitions, while `requestAnimationFrame` ticks normally. Two rounds of "the fly-off never animates" were chasing that artifact. Do not rewrite motion code on animation-sampling evidence from this harness alone.

## 21. The dictionary's saved mark is a control (this session)

Supersedes §14's "un-saving moves to the term detail screen" — that line is removed there, not amended.

The save-only rule belongs to the **gesture**, not to the button. A stray 70px drag must never empty a curated list; that says nothing about whether a deliberate tap may. Extending it to the control left the dictionary asymmetric — adding a term cost one flick, removing it cost two navigations — with nothing justifying the difference.

- The bookmark on a saved row is now a `<button>` (44px target, no chrome), still absent on unsaved rows. No visual change: the heaviness §14 fixed came from toggles on *every* row, not from this one being tappable.
- §15's rule survives intact — a mark and a control must not look the same — because there is no longer a non-interactive mark in the app to confuse this with. Both this and the Saved screen's ringed toggle are controls.

## 22. The dictionary category view titles itself (this session)

`DictionaryHome` (`dictionary.jsx`), category drill-down:

- The page title is now the **category** ("Beans and Botany"), not "Coffee Dictionary". The back chevron already states where you came from.
- The eyebrow is gone entirely — see §23.
- The in-body category banner (glyph tile + label + description) is deleted: with the title naming the category, it restated the same label three rows lower. The description went with it — see §23.

## 23. One title-block shape, no eyebrows (this session)

Supersedes the eyebrow line added in §22 — removed there, not amended.

`DictionaryHome` put context **above** the title (`REFERENCE · 73 TERMS`) while Favorites puts it **below** (`3 OF 5 SAVED`) or nowhere. Two shapes for one job.

The form, now shared: **title first, then at most one muted support line — and only where that line says something the page does not already show.**

- Category view → nothing. The description belongs on the category **row**, where it helps you choose; repeating it once you are inside recaps a decision already made.
- Lesson-only glossary → what the glossary is limited to. Scope, not a count.
- Full dictionary → nothing. "73 terms" is the sum of the per-category counts listed directly below it, which is §16's argument applied again.

The empty lesson-glossary paragraph was rewritten so it no longer repeats the support line above it.

## 24 · A blocked swipe must explain itself on the gesture, not on the movement

`useSwipeX` damps a blocked direction to 22% so the element resists instead of
going dead. Dictionary rows are save-only, so an already-saved row is blocked —
and the row keyed its "ALREADY SAVED" track opacity to the **damped** offset. A
60px swipe therefore produced 13px of travel at 0.3 opacity: no visible motion
and no visible reason, on a screen where most rows are saved once a user has
been using it. Reported as the rows being completely broken; the gesture was
working the whole time.

The hook now returns `rawDragX` — the undamped finger distance — alongside
`dragX`, and any caller showing a caption for a blocked direction drives it from
`rawDragX`. Rows also reach full label opacity at 30px instead of 44px, so the
explanation arrives before the user concludes the list is dead.

## 25 · Release an implicit pointer capture at the END of a gesture, never at its start

Touch and pen pointers are **implicitly captured** to the element that received
`pointerdown`, and that capture is what keeps the whole move stream flowing to
one element. §24's predecessor released it *at pointerdown* to fix a different
bug (a saved row re-rendering left an orphaned capture, and the next gesture on
a sibling was swallowed for seconds). That trade was wrong in both directions:
mouse pointers have no implicit capture, so it fixed nothing there, and on touch
it let the engine retarget or cancel the stream — the drag never started at all.

The capture is now released in the pointerup handler, before the commit runs:
the node still exists, the gesture is over, and nothing is orphaned by the
re-render the commit causes. `onDragStart` is also refused on any swipe surface,
since a native drag fires `pointercancel` and would kill the gesture the same way.

## 26 · Attach a gesture's move/up listeners synchronously at pointerdown

`useSwipeX` attached its `pointermove`/`pointerup` listeners in a `useEffect`
keyed on the pointer origin held in state. A flick — press, 100px, release
inside a frame — therefore completed **before React committed the effect**, so
no move or up listener ever existed and the row did not move at all. A slow,
deliberate drag worked, which is why the gesture read as randomly dead, and why
every synthetic test passed: driving it with 40ms gaps between events gives
React all the time it needs.

The origin now lives in a ref and the listeners are added synchronously inside
`onPointerDown`, with a detach function in a ref (called at pointerup and on
unmount). Live options (`canNext`, thresholds) are read from a ref, so the
handlers never need re-attaching and no gesture can outrun its own listeners.

That fix was initially incomplete in the same way one layer down: `dragXRef` was
still assigned **in the render body**, and pointerup decided whether to commit by
reading it. A flick that finished before React committed a render released with
the ref at 0, below any threshold, so the gesture fell through and did nothing —
identical symptom, different line. The move handler now writes `dragXRef`
imperatively at the same moment it calls `setDragX`, and every reset writes both.
The general rule: **a value a native event handler needs must never be populated
during render.**

## 27 · The challenge card's park gesture carried both §26 races

`brew-challenge.jsx` hand-rolls its own pointer gesture instead of using
`window.useSwipeX`, so fixing the hook left the park-for-later swipe — the
gesture this whole session was built around — still broken in both ways: the
listeners were attached from a `useEffect` keyed on the drag state, and
`dxRef.current = dx` was assigned in the render body while release compared it
against `PARK_AT`. A flick therefore parked nothing.

Both corrections were applied in place at the time (origin and distance in refs,
listeners attached synchronously at pointerdown, `onDragStart` refused). The
duplication behind them is resolved in §33: the card now runs on the hook, so a
gesture fix lands once.

## 28 · The swipe hook rebuilt, and the whole row made the target

Three successive repairs to `useSwipeX` each fixed one layer and left another
(§25 capture timing, §26 effect-attach, §26 addendum render-body ref). Rebuilt
from scratch instead, on one rule: **nothing a pointer gesture depends on may
wait for React.**

- `pointerdown` is a NATIVE listener attached by the ref callback, not a React
  synthetic prop — removing the whole "did the event reach the component" class
  of doubt.
- the node takes EXPLICIT `setPointerCapture`, so moves and the release reach it
  even while its children re-render; it is released in the end handler, with the
  window listeners kept as a fallback for engines that drop the capture.
- origin, claim state and distance live in ONE ref written imperatively by the
  move handler. React state paints; it is never read to decide a commit.

Separately, the dictionary row's target was wrong: the content sat in an inner
`<button>` sized to the text, so the row's vertical padding, the gap and the
bookmark column answered neither the tap nor the drag — a press starting there
hit the container and did nothing, which is most of the row's area.

The row is now a plain div carrying the gesture, with the tap target a
**stretched `<button>` at `inset: 0`** behind the content (which is
`pointer-events: none`) and the bookmark above it in z-order. The first attempt
put `role="button"` on the row itself; that fixed the target and broke
something quieter — `role="button"` takes *presentational children*, so a screen
reader may prune the bookmark nested inside it, and the bookmark is the only way
to un-save a term (the gesture is save-only by design). No control inside a
control. Verified with a same-tick flick (commits), a vertical drag and a 40px
drag (neither commits), a tap anywhere on the row (opens the entry), and the
bookmark (un-saves without navigating).

The app also had **no focus styling at all**, so everything fell back to the
UA's light-blue ring — off-palette here, and conspicuous once a row-sized target
replaced a text-sized one. A single `:focus-visible` rule in `index.html` now
gives a 2px accent outline app-wide — **outline and offset only.** The first
version also set `border-radius: 3px`, which carries the same specificity as
every component class and is declared later in the sheet, so it replaced their
real radii for as long as the element held focus: a 14px card or button squared
off on tab and sprang back on blur, and a 999px pill became a near-rectangle.
The engine already paints the ring to the element's own radius; a focus rule has
no business setting geometry.

## 29 · The module reward carousel had the gesture but no affordance

Reported as "the cards in the module are not swipeable". They are: same-tick
flicks commit in both directions, verified at top level and inside the
`module.html` walkthrough frames. What was missing is the thing that makes a
gesture exist for the user. The screen said a second card EXISTS — a
`CARD 1 OF 2` counter and a Next/Previous control — and nothing said the deck
MOVES, so nobody tries.

It now peeks the neighbouring card at the edge, the same affordance the
flashcard deck uses, and honest here because there really is a card on that
side.

## 30 · The deck affordance and the first-run hint become components

§29 gave the reward carousel a peek of its own — a 34px strip at radius 14,
static, written inline on that screen. Two decks, two implementations, and
already two differences: the strip did not rise under the drag (the flashcard
cards do, which is what makes the gesture read as dragging a deck rather than
firing a command), and its 14px corner belonged to no card on that screen — the
reward card is the one deliberately square thing in the app at radius 2.

Both now come from `swipe.jsx`, next to the hook whose state they read:

- **`DeckStack`** — one card per side that HAS a card, at the caller's radius,
  rising from 13px/0.955 to 0/1 as the drag goes its way and driven to full size
  during the exit flight, so the incoming card rises to meet you as the old one
  leaves. It renders inside a relative box **the size of the card** as a sibling
  of the transformed element (§29's one durable geometry finding).
- **`useSwipeHint`** + **`SwipeHintCaption`** — the nudge-twice-and-caption
  contract, the `localStorage` used-flag, the replay event, the reduced-motion
  branch. The reward carousel had no hint at all; it inherited one by adopting
  the hook.

The flashcard deck keeps its geometry exactly (radius 20, minHeight 380) and
lost ~40 lines of inline stack and hint code.

**And the counter moved out of the footer.** It was put there when it was also
the nav ("below the card it fell under the fold on short viewports") — a
position readout sitting in the control row, reading like a control. With the
stack carrying discoverability, `CARD 1 OF 2` sits **above** the card as the
deck line, exactly where the flashcard deck puts `12 SAVED TERMS`, and the
Previous card button is gone: the topbar back already steps a card back and the
footer CTA carries forward.

## 31 · The term entry was three container styles deep

Reported as "overloaded with a lot of different styles and elements", and the
count backs it: one page was running a filled knowledge-check card (radius 14),
a filled lesson-reference card (radius 12), the accent left-rule in-practice
block, pill chips, five smallcaps labels and a mono sources list.

Two cuts, no new vocabulary:

- **The lesson reference loses its box.** It is now a hairline row — rules above
  and below, no fill — so the page holds exactly ONE filled container. The
  budget rule, now in the DS: the box goes to the block you act on from inside,
  which is the knowledge check. Everything else that needs bounding takes rules.
- **Sources collapse.** The block's smallcaps label became the header of the
  standard disclosure, closed by default. Provenance is what makes the entry
  quotable, and it is also the block nobody reads on the way through; it now
  costs one line until asked for.

Left alone deliberately: the in-practice left rule (a shared component — lesson
decision cards use it too, and it is the app's only left-rule treatment), and
the status chip in the header (LEARNED / TO LEARN / REFERENCE is the one thing
on the page no other block states).

## 32 · The Term of the Day screen is the term, and nothing about the term

`TermOfDayScreen` (`dictionary-extras.jsx`). DS entry: **Components → Term of the Day**.

The screen was one term and its definition carrying four other things: a category
label, a weak date line under Roasty, and spacing that let the mascot crowd the
display type.

- **The category line is deleted.** It changes nothing you can do on this screen,
  and the full entry — one tap away, behind the only primary button — states it.
  A label that is only ever read as decoration is decoration.
- **The date is framed by the app's own hairline, turned sideways:** a 28px rule
  either side of the mono date, centred above the mascot. It gives the
  composition a top edge without adding a new treatment — the rule is the
  app's existing separator at a different angle.
- **Nothing decorates the term itself.** Roasty is already the ornament and the
  display face is already the treatment; the entry and the flashcard both show
  the term plain, so a device used here only would make this screen the odd one.
- Spacing does the remaining work: 44px above Roasty and 34px below, so the
  mascot reads as its own beat rather than a badge on the heading. Order is
  dateline → Roasty → term → respelling → definition.

## 33 · One gesture implementation, for real this time

Supersedes §13's "still outstanding" line and §27's closing paragraph — both
removed there, not amended.

Every swipe surface in the app now runs on `swipe.jsx`. Two screens were still
carrying their own copies, and both were the same debt §27 named: a fix to the
hook did not reach them.

- **`ActiveBrewCard` (`brew-challenge.jsx`) is a `useSwipeX` consumer.** ~60 lines
  of pointer arithmetic — origin refs, window listeners, claim logic, the
  imperative distance ref — deleted. The park threshold survives as
  `commitThreshold: PARK_AT` (104) and the card now commits by **flying off**
  (`exitDistance: 340`) like every other committed swipe, instead of fading in
  place. Left is `canNext: false`, so a wrong-way drag damps and is clamped out
  of the transform: the direction contract, enforced by the hook rather than by
  a `Math.max` in one screen.
- **The first-run hint comes from `useSwipeHint`** on both the challenge card and
  `DictionaryHome` — the two remaining hand-rolled copies of the nudge timings,
  the used-flag, the replay listener and the reduced-motion branch. The caption
  is `SwipeHintCaption` everywhere, so the three surfaces no longer differ by
  6px of height and an alignment.
- **The hook returns `used`.** The challenge card's chevron dims against it
  (bright under the hint, 0.7 unused, 0.35 after, per §9), which is the one piece
  of hint state a caller legitimately needs and the reason that copy had survived.
- **§19 applied where it had been missed.** The challenge card was a swipe surface
  without `user-select: none`, and its CTA had no `touch-action` of its own — a
  drag starting on the title or the button was the browser's. Both set now.

Dead code and stated-twice rules removed in the same pass: `filterCounts` and two
unused call sites in `dictionary.jsx` (computed, never rendered), an unused
`headerCatCount`, two unused React aliases, a comment still describing the eyebrow
§23 deleted, a comment claiming the card parks at 92px when `PARK_AT` is 104, and
a duplicated paragraph in the flashcard footer. The free tier's category list also
hid the All/Learned/To-learn filter, which search had hidden from the start: in the
free dictionary every listed term is Learned by definition, so the control had
nothing to sort.

## 34 · One frozen today

The prototype ran two of them. The Learn header printed **Fri, May 8** from a date
hard-coded in `screens.jsx` (twice), while Term of the Day printed **Thursday,
June 18** from a date hard-coded in `dictionary-extras.jsx` — one tap apart, and
§32's new dateline had just made the second one prominent and centred.

Worse, that dateline was a hand-kept **copy of the selection seed**: `dictTermOfDay`
rotated the pick on its own frozen date in `dictionary-data.jsx`, so changing
either left the date naming a day the term was not chosen for. Same failure as
a hand-kept tier or count (§1, §5): two values for one fact.

`window.PROTO_TODAY` (`data.jsx`, Fri 8 May 2026) is now the single source. The
header reads it, the dateline reads it, and `dictTermOfDay` defaults to it —
with a real `new Date()` fallback, so nothing hard-codes a date again. For the
Flutter port: one injected clock, and the term-of-day rotation takes the date
rather than owning one.
