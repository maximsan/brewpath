# Beans Module — Content & Game-Integrity Review Plan

Handover plan for fixing the Beans module (m1l1–m1l7) plus Beans-content games.
Goal: no challenge may reveal its own answer; every distractor must be plausible and on-topic; match and put-in-order games must render in random order.

## Ground rules for the implementing model
- Touch ONLY what this plan lists: card content in `data.jsx`, two components in `lesson.jsx`, choice positions in `duel-data.jsx`.
- Do NOT change layout, styling, tokens, XP values, card counts, screen chrome, or any file not named here.
- Do NOT reword teaching content (concept paragraphs, explains, rewards) except where an item says so.
- Keep typographic quotes/apostrophes (’ “ ”) — no straight quotes anywhere.
- Prefer `str_replace_edit`; never rewrite whole files.

---

## Part A — Code: randomize game order (lesson.jsx)

### A1. MatchCard — shuffle both columns (lesson.jsx ~line 537)
Today the left column renders in authored `card.pairs` order and the right column in first-appearance order, so layout is identical every play and pairs often sit adjacent.
- On mount, build a shuffled display order for left items (Fisher–Yates over pair indices) and a shuffled order for the deduped right column. Store once in a `useState`/`useMemo` initializer so it doesn't reshuffle mid-play.
- Matching logic (`tryMatch`, line refs, connection-line measurement) must keep working: keep original pair indices as the identity; only the RENDER order changes.
- This one fix also covers the `g-match` mini-game (it reuses `MatchCard` at ~line 1270) — no separate change needed there.
- Verify: replay the same match card twice; column orders differ; drag/tap matching and lines still work.

### A2. SequenceCard — shuffle display order (lesson.jsx ~line 888)
Items render in authored `card.items` order. Two Beans sequence cards are authored in ALREADY-CORRECT order, so the screen shows the answer:
- m1l2 “Order these by typical caffeine” (Decaf → Arabica → Robusta as written)
- m1l3 “Order these from broadest to most specific” (Country → Region → Single farm as written)
Fix in the component, not per-card:
- On mount, render items in a shuffled display order (stable for the play, like A1).
- Grading already uses `item.order`, so shuffle is display-only.
- After shuffling, if the display order happens to equal the correct order, reshuffle once (guard for 3-item lists).
- Verify: m1l2 and m1l3 sequence cards no longer open pre-solved; m1l7 “Peel a cherry” still grades correctly.

### A3. Duel “Coffee basics” — answer-position tell (duel-data.jsx lines 23–37)
All six questions have the correct choice in position 2. Fix by re-authoring positions in the data (do NOT shuffle at render — bot logic in duel.jsx keys off `correctIndex` of authored order):
- Move `correct: true` choices so positions vary across 1–4 with no run of more than two in the same slot.

---

## Part B — Content: giveaway headers & text (data.jsx)

Rule: a card's visible title/body/scenario must never state or strongly imply its own correct answer. Titles may name the topic, not the verdict.

- B1. m1l1 decision (~line 114): title “Fresh beans do most of the work” answers its own question (“What do you change first?” → buy fresh beans). Retitle to something neutral, e.g. “The flat cup”. Keep `right`/`wrong`/`note` unchanged (they show after answering).
- B2. m1l3 decision (~line 323): title “Use origin, don’t obsess over it” tells you to pick freshness over the famous farm. Retitle neutral, e.g. “Famous farm, old roast”.
- B3. m1l4 predict (~line 359): under the lesson title “Why altitude matters”, the options “Much the same” vs “Denser and more complex” make the answer obvious (a titled lesson can’t be about nothing changing). Replace “Much the same” with a competitive wrong guess, e.g. “Softer and sweeter”.
- B4. m1l7 card order (~lines 650–690): the mcq “Which layer ends up as chaff in the roaster?” directly follows a match card containing “Flakes off as chaff in the roaster → Silverskin”. Move the mcq to after the `practical` (“Read the crease”) card, OR reword the match left text to “The last tissue-thin membrane on the seed”.
- B5. Sweep the remaining decision/recall titles in m1l1–m1l7 for the same pattern; the rest currently look neutral (“Choosing beans by taste”, “Two kinds of promise”, “Same everything, one line apart”, “The number in metres”) — leave them.

---

## Part C — Content: weak / meaningless distractors (data.jsx)

Rule: every wrong choice must be something a real beginner could believe, drawn from the lesson's topic. No jokes, no “nothing changes” throwaways.

- C1. m1l1 mcq “Where does coffee grow best?”: replace “Only near the poles” and “Below sea level” with plausible options (e.g. “In cool coastal lowlands”, “Wherever rainfall is heaviest”).
- C2. m1l1 mcq “How many seeds sit inside a typical coffee cherry?”: replace “A dozen” with “Four”.
- C3. m1l2 tastefix: replace “Stir in sugar” (not a brewing fix) with a plausible one, e.g. “Pull a shorter shot”.
- C4. m1l3 mcq “Why can the same variety taste different…”: replace “The bag colour” and “Nothing — it tastes the same” with plausible options (e.g. “The roaster’s machine”, “How long it shipped at sea”).
- C5. m1l4 mcq “Why does cooler weather help quality?”: replace “It has no effect on flavour” with a plausible mechanism, e.g. “It concentrates caffeine, which adds flavour”.
- C6. Concept-fill joke options: m1l3 “Origin is a place” has `farm` vs `shelf`; m1l4 “Denser beans” has `bag` vs `receipt`. Replace the joke alternative with an in-domain plausible one (e.g. `shelf` → `roastery`, `receipt` → `label`). Fills are ungraded but the same learning rule applies.
- C7. Longest-answer tell: in several graded cards the correct choice is the longest/most specific — m1l1 recall, m1l3 mcq (C4 card), m1l4 recall, m1l5 recall, m1l7 recall and mcq at ~line 1610-style phrasing. For each mcq/recall/multi in m1l1–m1l7: if the correct choice is clearly the longest, either trim it (move detail into `explain`) or lengthen one distractor to match. Meaning must not change.

---

## Part D — Content: off-topic question

- D1. m1l2 slider “How fine should you grind for a V60?” (~line 195): grind is Module 4 material and unrelated to Arabica vs Robusta. Replace with an on-topic slider, e.g. “Where does Arabica grow best?” over an elevation scale (0 m → 2,400 m, target in the 900–2,000 m band), reusing the existing slider shape (`target`, `tolerance`, 5-step `scale`, `feedback`). Do not copy m1l4’s altitude slider verbatim — that one is about where specialty coffee overall grows.

---

## Out of scope (checked, no action)
- Flashcards & vocab mini-game: already shuffle deck and choices (dictionary-extras.jsx).
- Atlas match activity: already shuffles the right column; not part of Beans.
- Modules m2–m5 content: same tells exist there (e.g. authored-order sequences) — A1/A2 fix the mechanics globally, but content sweeps for other modules are a separate pass.

## Acceptance checklist (run after implementation)
1. Play m1l1–m1l7 end to end; nothing crashes; XP and grading unchanged.
2. Every match card and the g-match mini-game opens with a different arrangement on replay; lines/drag still connect correctly.
3. m1l2 and m1l3 sequence cards never open in the solved order; grading and the “Correct order” reveal are still right.
4. No card title, body, or scenario contains its own correct answer.
5. No “nothing changes / no effect / joke” distractors remain in m1l1–m1l7.
6. Duel basics: correct answers spread across positions 1–4; bot opponents still score plausibly.
7. Correct choices are no longer reliably the longest option.
