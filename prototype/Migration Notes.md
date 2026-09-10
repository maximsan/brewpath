# Migration Notes

Reconstructed from code comments and doc pages — the original discussion notes were never written to a file.

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
- Tier derives from topic: free iff the topic's module is unlocked (`FREE_GAME_IDS` is derived, never hand-kept). Free today: g-match, g-quiz, g-flavor-origin-signatures (all M1). Ref: #175.
- Locked-game gate sheet leads with "TAUGHT IN <module label>" + module pitch; upgrade-only in v1.
- Bagpick stays a single game — its mechanic is bound to the green-bean artwork; uneven groups are intended.
- Round banks: `MINI_GAME_CONTENT` (`lesson.jsx`); all 13 authored.
- Pipeline (documented, not scheduled): second M5 tasting topic; AeroPress / Clever / drip-packet sequence recipes — wait on lessons that teach them.
- Doc surfaces kept in sync: Design System access-tier table + rules (`ds-content.js`), `games.html` (7 kinds · 13 games).
