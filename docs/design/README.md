# BrewPath — v1 design reference

A complete, source-derived description of the BrewPath design prototype that
lives in [`prototype/`](../../prototype/): every screen, rule, content item,
component state, asset and open decision.

## Two layers — start with the right one

| | [**PRODUCT.md**](PRODUCT.md) | The numbered files (§0–§13) |
|---|---|---|
| **Reads like** | Plain language, product prose | Engineering reference |
| **Contains** | What the app does and why, with the trade-off named for every feature | Exact rules, component states, counts, identifiers, defects |
| **Use it to** | **Decide** — debate a feature, hand to another model, agree what to keep, change or drop | **Build** — implement a rule correctly, port a screen, generate tickets |
| **Names things** | The way a user sees them | The way the code does |

**If you are reasoning about the product, read [PRODUCT.md](PRODUCT.md) and
ignore everything else in this folder.** It is one self-contained document with
no code in it. The numbered files exist for the moment someone actually builds
this.

**The rule this reference is written under:** everything here is read out of the
prototype source, not invented. Where the prototype and the design documents
disagree, **the source wins and the discrepancy is flagged** rather than
smoothed. The ⚠️ blocks are the most valuable part of these files — they mark
places where the product genuinely has not decided something.

> **Derived at `880b9d4` + staged design changes (Aug 2026).** Countable facts
> come from [`tools/extract-facts.js`](tools/extract-facts.js), not from prose.
> Re-run it after any design change — see [Keeping this current](#keeping-this-current).

---

## Start here

| If you want to… | Read |
|---|---|
| **Discuss the product conceptually — what to keep, change or drop** | [**PRODUCT.md**](PRODUCT.md) — the whole app in plain language, no code. **Start at §14–15** if you want the arguments rather than the description |
| Understand the product in 30 seconds | [§1 Product](01-product.md) |
| Know what ships in v1 and what doesn't | [§2 Scope](02-scope.md) |
| Find a specific screen in the prototype | [§0 How to read the prototype](00-reading-the-prototype.md) |
| Implement a rule correctly (points, streak, tree, gating) | [§5 Mechanics](05-mechanics.md) |
| Know what a component does in every state | [§7 Components](07-components.md) |
| Know what a component should *look* like | **`prototype/Design System.html`** — indexed in [§3](03-design-system.md), not reproduced here |
| Find what's undecided or broken | [§11 Open items](11-open-items.md) |
| Start building | [§11](11-open-items.md) to see what is still undecided, then [§12 Checklist](12-checklist.md) and [§13 Epics](13-epics.md) |

## All sections

| § | File | Contents |
|---|---|---|
| 0 | [How to read the prototype](00-reading-the-prototype.md) | File map, deep links, what was deleted and why |
| 1 | [Product](01-product.md) | One paragraph |
| 2 | [Scope](02-scope.md) | v1 vs v2 counted by route; the tab bar |
| 3 | [Design system](03-design-system.md) | Colour, type, radius, elevation, theming, Roasty, icons — **and the index of the 57 components specified in `Design System.html`** |
| 4 | [Information architecture](04-information-architecture.md) | Tabs, header, **the four coming-soon modules shown to users**, the 104-route list |
| 5 | [Mechanics](05-mechanics.md) | Points · mastery · tree · streak & freeze · gating · collectibles · Saved · coffee challenges · Plus & trials · persistence · frozen values |
| 6 | [Content](06-content.md) | Course · card kinds · collectibles · dictionary · mini-games · coffee challenges · Studio · settings |
| 7 | [Components](07-components.md) | Every exported component, its states and options, and its design-system binding |
| 8 | [Flows](08-flows.md) | First run · daily loop · reward routing · replay · challenges · dictionary · paywall |
| 9 | [Deferred — v2](09-deferred-v2.md) | Atlas · Duel · ads & trials · onboarding questions · mood player · Liberica art |
| 10 | [Assets](10-assets.md) | Raster vs inline SVG; what each folder holds |
| 11 | [Open items](11-open-items.md) | QA re-verification · still open · closed · newly opened · **divergences between the app and this design** · the omission sweep |
| 12 | [Checklist](12-checklist.md) | Flat list of build tasks — the input to issue generation, consumed once. **Build tasks only**: decisions live in §5, open questions in §11 |
| 13 | [Epics](13-epics.md) | How to slice the build |

---

## How to use this with an agent

These files are written to be pasted or referenced individually. A whole-folder
dump is usually the wrong move — it is ~1,400 lines and most of it will be
irrelevant to any one question.

**Pick by question type:**

| Question shape | Attach |
|---|---|
| "Does our implementation of X match the design?" | The one mechanics or content section covering X, plus [§7 Components](07-components.md) if it has UI. **Check [§11](11-open-items.md) "Divergences" first** — some disagreements are already known |
| "What should we build next?" | [§11](11-open-items.md) **first** (several tasks are blocked on decisions there), then [§2](02-scope.md) + [§12](12-checklist.md) |
| "Is this in scope for v1?" | [§2](02-scope.md) alone — it is self-contained |
| "Why does the app do X?" | [PRODUCT.md](PRODUCT.md) for the product reasoning; [§5](05-mechanics.md) for the exact rule |
| "Should the app do X at all?" | [PRODUCT.md](PRODUCT.md) alone — every feature section names its trade-off, and §14 lists the open arguments |
| "What's left undecided?" | [§11](11-open-items.md) alone |

**Two cautions when an agent works from this:**

1. **Numbers go stale the moment the prototype changes.** Every count here was true at the commit named above. If a number matters to a decision, re-run the extraction script rather than trusting the file. The counts moved twice during the writing of this reference alone.
2. **Absence of a section is not absence of a requirement.** [§7.9](07-components.md) lists what the component inventory deliberately does not cover (visual specs, empty states, error/loading states). An agent generating tickets from [§12](12-checklist.md) will not produce tickets for those.

---

## Keeping this current

```bash
# from the repo root
node docs/design/tools/extract-facts.js | less

# or against an explicit prototype directory
node docs/design/tools/extract-facts.js path/to/prototype
```

It prints JSON covering: module/lesson/card counts and per-lesson breakdown,
card-kind histogram, graded totals, collectible groups and duplicate titles,
`CARD_ART` / `CARD_TINT` coverage, dictionary totals by category and
reference-only terms, `dictLessonAudit()` results, mini-games, coffee challenges,
route keys, asset folder counts, and per-file line counts.

**The sections whose numbers it owns** — re-derive rather than hand-edit:
[§0](00-reading-the-prototype.md) line counts · [§2](02-scope.md) route arithmetic ·
[§4](04-information-architecture.md) route list · [§6](06-content.md) every count ·
[§10](10-assets.md) folder counts.

The argued sections — [§2](02-scope.md) rationale, [§5](05-mechanics.md),
[§7](07-components.md), [§11](11-open-items.md) — are hand-written and need
reading the diffs, not running a script.

---

## Conventions

- **Source paths are relative to `prototype/`.** `app.jsx` means `prototype/app.jsx`.
- **Line references** (`app.jsx:172`) were accurate at the derivation commit and drift fast. Treat them as a starting point for a search, not an address.
- **⚠️** marks a genuine contradiction, undecided question, or trap — not a nice-to-know.
- **✅** marks something previously flagged that has since been closed.
- **§N** references link to the file above. Sub-numbers (§5.3) point at a heading inside that file.

## Related

- [`prototype/Design System.html`](../../prototype/Design%20System.html) — the component specification. Authoritative for anything visual.
- [`prototype/v1 Readiness Audit.html`](../../prototype/v1%20Readiness%20Audit.html) — the scope decision record. Note that it does **not** cover the four coming-soon modules ([§4](04-information-architecture.md)).
- [`prototype/QA Findings.html`](../../prototype/QA%20Findings.html) — the QA record, re-verified Aug 2026.
- [`docs/CHANGELOG.md`](../CHANGELOG.md) — the Flutter app's change history, which this reference is meant to be diffed against.
