# Modules 2–5 Review Plan — Processing · Roasting · Grind · Brew

Same review as `Beans Review Plan.md`, applied to m2–m5 lesson cards, module/lesson brew challenges, duel banks and mini-games. Goal: no question reveals its own answer; every distractor is plausible and on-topic; every game opens in a random arrangement. V1 cut only.

## Ground rules
- Touch ONLY what this plan lists: content in `data.jsx`, `duel-data.jsx`, mini-game content in `lesson.jsx`, choice-order rendering in `lesson.jsx` / `active-cards.jsx`.
- Do NOT change layout, styling, XP, card counts, teaching paragraphs, rewards, or grading logic.
- Keep typographic quotes/apostrophes; prefer `str_replace_edit`.
- Line numbers are approximate — locate by quoted text.

## Verified already fixed (no action)
- MatchCard shuffles both columns on mount (`shuffledIdx`, lesson.jsx ~559) — covers every m2–m5 match card AND `g-match`. Match always opens in random pair order. ✓
- SequenceCard shuffles display order with a solved-order guard (~910) — covers all m2–m5 authored-in-order sequences (m2l2 fruitiness, m2l4 drying, m2l5 washed stages, m3l2 cracks, m3l4 roast stages, m3l5 roast times, m5l4 levers, m5l5 rinse, m5l6 steps). ✓
- Duel “basics” bank positions were re-authored (0,2,3,1,2). ✓
- Flashcards + vocab mini-game already shuffle. ✓

---

## Part A — Code: randomize answer positions (the big one)

### A1. Shuffle choice display order in single-answer/multi cards
Correct answers are authored position-first almost everywhere and nothing shuffles them:
- `recall` cards: correct is choice #1 in **all ~24** m2–m5 recalls.
- `decision` cards: correct is option #1 in **all** m2–m5 decisions.
- `tastefix` cards (in lessons AND `g-tastefix`): correct is choice #1 in **all 10**.
- `mcq` cards: correct is #1 in ~14 of 19.
- `multi` cards: correct options always clustered at the top.

Fix in the components, not per-card (mirrors the MatchCard/SequenceCard approach — also silently fixes the same tell in Beans):
- Add a mount-stable shuffled display order (reuse `shuffledIdx`) to: `MCQCard`, `MultiCard` (lesson.jsx); `RecallCard`, `DecisionCard`, `TasteFixCard`, `BagPickCard` (active-cards.jsx); `FlavorCard` (mini-game — its `answer` is an index, keep the original index as identity and map through the display order).
- Display-only: grading keys (`correct` flags / `correctIdx` / `answer`) keep pointing at the original items. Feedback classes (`correct`/`incorrect`) and XP must follow the item, not the rendered position.
- Do NOT shuffle `predict` cards (2-option guess, ungraded, positions already mixed) or `quiz` (True/False order is fixed by nature).
- Verify: replay any lesson twice — choice order differs; picking the right item still grades right; multi check-all still grades per-item.

### A2. Slider scale labels that name the answer (data.jsx)
`SliderCard` shows the current band label live while dragging, so a label that names the answer lets the user stop when the text matches the question. Reword ONLY the offending band labels (keep target/tolerance/feedback):
- **m3l4** “Around what bean temperature does first crack happen?” — band 3 reads “195–205 °C — first crack”. Drop the crack names from bands: e.g. “195–205 °C — sharp popping starts” → still a tell; better: label bands by what the bean looks/sounds like without naming cracks: “150 °C — beans still pale”, “175 °C — golden, toast smell”, “195–205 °C — loud popping begins”, “225 °C — a second, sharper crackle”, “250 °C — smoke, nearly burnt”. (The question asks for first crack; “loud popping begins” requires knowing first crack IS the popping — that’s the learning.)
- **m3l6** “How much caffeine is in a 240 ml drip cup?” — band 3 reads “Drip cup — ~95 mg”. Remove drink names from bands; keep only mg values: “~3 mg”, “~63 mg”, “~95 mg”, “~190 mg”, “~200 mg”.
- **m4l5** “Set the dial for a French press.” — band 4 reads “Coarse sand — French press”. Remove brewer names: “Flour”, “Table salt”, “Kosher salt”, “Coarse sand”, “Peppercorns”.
- **m5l4** “Pick the target extraction yield.” — band 3 reads “18–22% — the sweet spot”. Replace tail with taste words: “18–22% — balanced, sweet”. Also soften band 1/5 (“sour, hollow” / “harsh” may stay — taste descriptors are the intended clues).
- **m5l6** bloom slider — band 3 reads “30 g — twice the dose” (restates the rule verbatim). Reword: “30 g — wets the whole bed”. Keep “50 g — you have started brewing” / “80 g — no bloom at all” (consequences, not the rule).

### A3. Duel banks — answer-position spread (duel-data.jsx)
Re-author positions in data (bot logic keys off authored index — do NOT shuffle at render):
- `origin`: strict alternation 2,1,2,1,2. `brew`: 2,2,1,2,2. `taste`: only slots 1–2 ever used. `processing`: 2,1,2,2,2.
- Spread correct answers across slots 1–4 in each bank, no run longer than two.

### A4. g-quiz True/False alternation (lesson.jsx ~1064)
Answers run T,F,T,F,T,F exactly. Reorder the six statements so the pattern breaks (e.g. T,T,F,T,F,F). Content unchanged.

---

## Part B — Giveaway titles & text (data.jsx)
Rule: a card’s visible title/scenario must never state its own correct answer. (Concept cards TEACHING a fact that a LATER card tests is fine — that’s the pedagogy. These are cards answering themselves.)

- B1. **m3l1 decision** title “Start at medium, then lean” — question “What do you tell them to buy?”, answer “A medium roast”. Retitle neutral, e.g. “A friend’s first bag”.
- B2. **m4l3 decision** title “Change one click at a time” — question “What do you do now?”, answer = change one variable. Retitle e.g. “Sour, then bitter”.
- B3. **m5l3 decision** title “Change one thing at a time” — same self-answer. Retitle e.g. “Bitter, and you want it fixed by morning”.
- B4. **m5l2 decision** title “Fix the water first” — question “What do you fix first?”. Retitle e.g. “Blaming the beans”.
- B5. **m5l1 decision** title “Start at 1:16, then adjust” — options are ratio-vs-grind and the title points at ratio. Retitle e.g. “Clean but thin”. (Keep `note` — it shows after answering.)
- B6. Checked and neutral, leave as-is: all other m2–m5 decision/concept titles (“Where those ‘funky’ notes come from”, “Grind it here?”, “Nine o’clock…”, “Ground for filter”, “The upgrade that pays off”, etc.).

## Part C — Weak / meaningless distractors (data.jsx)
Rule: every wrong choice is something a real beginner could believe, on-topic. Replace only the listed option text; keep everything else.

- C1. m2l1 mcq “cleanest, brightest cup”: replace “None — process doesn’t affect taste” → plausible, e.g. “Whichever dried longest in the sun”.
- C2. m2l2 mcq “Why might they taste so different?”: replace “One is fake” → e.g. “Different water at the roastery”. (Keep “They can’t — origin fixes the taste” — that IS the misconception this lesson corrects.)
- C3. m2l3 mcq “Ethiopia · Natural · blueberry, cocoa. Expect…”: replace “No flavour at all” → “A dark, smoky, roast-forward cup”; replace “A savoury, salty cup” → “A clean, tea-like cup with no fruit” (competitive with the washed profile just taught).
- C4. m2l3 multi “Which lines help you predict the taste?”: replace “The bag’s colour” → “The far-off ‘best by’ date” (genuinely tempting — they just learned dates matter; this one doesn’t).
- C5. m2l4 mcq “Why does even drying matter?”: replace “It changes the species of the coffee” → “It keeps the parchment from cracking”; replace “It removes the caffeine” → “Even lots dry faster overall”.
- C6. m2l4 recall: replace “Drier coffee is illegal to export” → “Drier beans are too brittle to hull”.
- C7. m2l5 mcq “anaerobic natural”: replace “Decaffeinated” → “Sharper and more acidic than a washed coffee”.
- C8. m3l1 mcq “keeps the most origin character”: replace “The roast doesn’t affect it” → “Medium — the balance point keeps the most”.
- C9. m3l2 mcq “pulled just after first crack”: replace “Green, unroasted bean” → “Medium roast” (the truly competitive wrong answer).
- C10. m3l5 mcq “better in a milk drink”: replace “It makes no difference at all” → “Light — milk brings the florals out”; replace “Decaf, always” → “Whichever roast is freshest”.
- C11. m3l6 recall: replace “Espresso is made from decaffeinated beans” → “An espresso shot brews too fast to pull much caffeine”.
- C12. m4l1 mcq “Why does a finer grind extract faster?”: replace “It has nothing to do with speed” → “Finer particles dissolve completely in hot water”. (See D2 — this card also duplicates the recall.)
- C13. m4l2 mcq “main advantage of a burr grinder”: replace “It adds flavour to the beans” → “It grinds much faster than a blade”; replace “It removes caffeine” → “It works better with dark, oily beans”.
- C14. m4l3 mcq “Finer grind generally makes a cup…”: replace “Taste exactly the same” → “Drain faster through the filter”.
- C15. m5l2 mcq “target temperature”: replace “As cold as possible” → “About 75 °C, to protect the aromatics” (a real belief); keep “Exactly 100 °C, always boiling”; replace “Room temperature” → “Whatever the machine’s hot tap gives”.
- C16. m5l5 mcq “Why rinse a paper filter?”: replace “It is only for decoration” → “It softens the paper so it seals to the cone”; replace “It removes caffeine from the filter” → “It slows the brew down for more contact time”.
- C17. Duel banks (duel-data.jsx, same pass as A3): origin — “The two poles” → “40°N and 40°S” exists; replace “The two poles” → “0° and 10°N” is taken; use e.g. “30°N and 60°N”. processing — Q1 “Never grown”/“Roasted first” → “Dried on before hulling” / “Rinsed off after roasting”; Q4 “They’re identical” → “Honey”; Q5 has three same-meaning wrongs (“The same cup” / “Only a color change” / “No difference”) → keep “The same cup”, replace the other two with “Different only if the roast changes too” and “Three cups apart in body, not flavour”. brew — Q1 “Serve” → “Rinse the filter” (topical, tempting, wrong order).
- C18. Longest-answer tell sweep: in m2l4 (mcq + recall), m2l5 recall, m2l6 recall, m3l5 mcq, m3l6 recall, m4l2 recall, m4l6 mcq, m4l7 recall, m5l2 recall, m5l4 recall the correct choice is clearly the longest and often carries its own justification (“Coarser — the French press holds water far longer”). Trim the correct choice to the verdict and move the reasoning into `explain`, or lengthen one distractor to match. Meaning must not change.

## Part D — Duplicates & copy consistency (data.jsx)
- D1. **m2l2** mcq and recall ask the same Yirgacheffe two-bags question with near-identical choices. Keep the recall (it closes the lesson); re-angle the mcq, e.g. “A roaster wants a cleaner, brighter cup from the same lot next harvest. What do they change?” (processing method = correct; distractors: pick riper cherries / roast lighter / grow it higher).
- D2. **m4l1** mcq and recall both ask “why does finer extract faster” with the same choices. Re-angle the mcq into an application: “You grind the same dose finer. What happens in the brewer?” (water pulls flavour out faster = correct; distractors: the brew slows but tastes the same / more caffeine dissolves / nothing until you change the ratio).
- D3. **m5l3 decision** `note` says “If your coffee tastes sour…” but the scenario is a bitter cup. Reword note direction-neutral: “Don’t change ratio, grind and temperature at once. One variable, then compare.”
- D4. **m2l6 recall** “You said decaf has no caffeine at all” and **m4l6 recall** “You said ground coffee stales in days” assume the user guessed wrong on the predict card. Reword to third person: “A friend insists decaf has no caffeine at all…” / “The lesson opened with a guess: days or minutes…”.

## Part E — Dictionary knowledge checks tied to m2–m5 (dictionary-data.jsx)
Light sweep, same distractor rule (checks are one-tap, so only the worst offenders):
- “washed” check: “Always decaffeinated” → “Heavier and sweeter than a natural”.
- “burr-grinder” check: “Add caffeine” → “Heat the beans less, always”.
- “first-crack” check: “The grinder is too fine” → “Second crack is about to begin” (wrong but on-topic).
- Position bias is mild (correct at #2 mostly); vary a couple while editing the above — TermCheck renders authored order.

## Out of scope (checked, no action)
- Brew Challenges (brew-challenge.jsx): real-world tasks with reaction chips, no graded answers — nothing to leak. Content is sound.
- g-flavor distractors: cross-family notes are the intended design; positions fixed by A1.
- g-bagpick rounds: judgment-based on the visual; choice order fixed by A1.
- Atlas activities, flashcards, vocab game: already shuffled / not module v1 content.
- m5l4 “Order the extraction levers” sequence: content is course doctrine (grind first); debatable IRL but internally consistent — leave.
- Teaching-concept cards that state facts later tested: intended teach-then-test rhythm — leave.

## Acceptance checklist
1. Play one lesson per module end to end; nothing crashes; grading and XP unchanged.
2. Replay the same lesson: mcq/multi/recall/decision/tastefix choices appear in a different order; picking the right item still grades correct.
3. Match and sequence cards still open shuffled (regression check).
4. The four sliders in A2 no longer display the answer text while dragging; target band still grades right.
5. No decision title in m2–m5 states its own answer.
6. No “no effect / fake / decoration / joke” distractors remain in m2–m5, duels, or mini-games.
7. Duel correct answers spread across slots 1–4 in every bank; bots still score plausibly.
8. g-quiz no longer alternates T/F; g-tastefix correct answers no longer always render first.
9. m2l2 and m4l1 no longer ask the same question twice.
