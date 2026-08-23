# BrewPath — doc map

Orientation for every documentation surface in this repo: what each area owns,
and which source wins when two of them disagree. Read this before resolving any
doc conflict.

## Who owns what

| Area | Owns |
|---|---|
| [`prototype/`](../prototype/) | The React design prototype — the source the app is built against, **read-only to agents** (the owner authors course content here). Findings go in the owning issue or `docs/design/`. |
| [`prototype/CLAUDE.md`](../prototype/CLAUDE.md) | **The course content rules** (what makes a good card). Lives with the authoring environment so it loads when the rules apply; `docs/design/content-rules.md` points here. |
| [`docs/design/`](design/README.md) | The engineering reference **derived from the prototype** (numbered §0–§13), plus [`PRODUCT.md`](design/PRODUCT.md) (the conceptual layer) and [`content-rules.md`](design/content-rules.md) (a pointer to the content rules in [`prototype/CLAUDE.md`](../prototype/CLAUDE.md)). |
| [`docs/adr/`](adr/README.md) | **All new decisions**, product and engineering — one numbered file per ruling. |
| [`docs/decisions.md`](decisions.md) | The **frozen ledger** of product-owner rulings up to Aug 2026. Stable `§` numbering; never grows. |
| [`CONTEXT.md`](../CONTEXT.md) | The domain glossary — the vocabulary rulings and code must share. |
| `docs/02, 09–15, 18` | Live single-owner docs: architecture, the deferred Firebase/payments/ads plans, testing, CI, release, platform plans, git workflow. |
| [`docs/agents/`](agents/) | How agent skills consume this repo (issue tracker, triage labels, domain docs). |
| [`docs/archive/`](archive/README.md) | The tombstone ledger for removed docs — nothing in it is current. |
| [`docs/CHANGELOG.md`](CHANGELOG.md) | What actually changed, release by release, plus the build-milestone history. |
| [`docs/plans/`](plans/) · [`docs/research/`](research/) | Working plans and research notes — snapshots, not authority. |
| [`learning/`](../learning/README.md) | The hands-on Flutter course for this app, including the [Flutter glossary](../learning/glossary.md). |

## Which source wins — the precedence rule

Two axes, depending on what kind of fact is in dispute:

1. **Product rulings** — `docs/adr/` and `docs/decisions.md` (plus the issue
   rulings they cite) win over **everything, including the prototype**. The
   prototype shows what was designed; the rulings say what ships.
2. **Prototype facts** (counts, component behaviour, copy) — the **prototype
   source wins** over any derived doc. Numbers are re-derivable with
   `node docs/design/tools/extract-facts.js`.
3. **`PRODUCT.md` is commentary, never authoritative.** Its `[My reading]`
   passages are one person's product judgement; argue with them freely.

`docs/design/` is agent-derived and verified **on contact**: when work touches
a section and finds a discrepancy against the prototype or a ruling, fix it in
the same PR that found it.

## How decisions are made

See [`docs/adr/README.md`](adr/README.md) — it owns the process. In one line:
argue in the owning issue, record as a new ADR; the frozen ledger never grows.

## Doc changes must leave every reference correct

Any change that adds, moves, renames or deletes documentation must verify — in
the same PR — that every link, path, name and `§`-reference it touches, or that
points at the touched files, still resolves.

## Renames worth knowing (Aug 2026)

- `prototype/` was `brew-path/`
- `docs/decisions.md` was `docs/decisions-1.md`

Older issues, PRs and CHANGELOG entries use the old paths; resolve them to the
new ones.
