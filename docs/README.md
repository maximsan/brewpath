# BrewPath — doc map

Orientation for every documentation surface in this repo: what each area owns,
and which source wins when two of them disagree. Read this before resolving any
doc conflict.

## Who owns what

| Area | Owns |
|---|---|
| [`prototype/`](../prototype/) | The React design prototype — the source the app is built against, **read-only to agents** (the owner authors course content here). Findings go in the owning issue or `docs/design/`. |
| [`prototype/CLAUDE.md`](../prototype/CLAUDE.md) | **The course content rules** (what makes a good card). Lives with the authoring environment so it loads when the rules apply. |
| [`docs/design/`](design/README.md) | The engineering reference **derived from the prototype** (numbered sections), plus [`PRODUCT.md`](design/PRODUCT.md) (the conceptual layer)). |
| [`docs/adr/`](adr/README.md) | **All new decisions**, product and engineering — one numbered file per ruling. |
| [`docs/decisions.md`](decisions.md) | The **frozen ledger** of product-owner rulings up to Aug 2026. Stable `§` numbering; never grows. |
| [`CONTEXT.md`](../CONTEXT.md) | The domain glossary — the vocabulary rulings and code must share. |
| [`architecture.md`](architecture.md) · [`firebase.md`](firebase.md) · [`payments.md`](payments.md) · [`ads.md`](ads.md) · [`reminders.md`](reminders.md) · [`testing.md`](testing.md) · [`ci-cd.md`](ci-cd.md) · [`releasing.md`](releasing.md) · [`future-android-web-plan.md`](future-android-web-plan.md) · [`git-and-github-workflow.md`](git-and-github-workflow.md) · [`universal-links-setup.md`](universal-links-setup.md) · [`localization.md`](localization.md) · [`schema-migrations.md`](schema-migrations.md) · [`quality-checks.md`](quality-checks.md) · [`content-pipeline.md`](content-pipeline.md) | Live single-owner docs, one per subject, named for what they are. |
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

## A workflow gets one how-to

Anything someone *operates* — commands to run, files to fill in, a loop to
repeat — gets one how-to in `docs/`, named for what it is, that collects
everything about it: where the files live, what each command does, what you
will see, and how it is maintained afterwards. [`localization.md`](localization.md)
is the shape. The README's command section stays a summary that points there;
the rulings stay in their ADRs and are linked, never restated; and the how-to
is written for someone who has never seen the feature. Nobody should have to
ask in chat, or read the tool's source, to learn how we do a thing.

## Doc changes must leave every reference correct

Any change that adds, moves, renames or deletes documentation must verify — in
the same PR — that every link, path, name and `§`-reference it touches, or that
points at the touched files, still resolves.

## Renames worth knowing

- `prototype/` was `brew-path/` (Aug 2026)
- `docs/decisions.md` was `docs/decisions-1.md` (Aug 2026)
- The single-owner docs dropped their numbers (20 Sep 2026): `docs/architecture.md`
  was `02-architecture.md`, and likewise `09-firebase`, `10-payments`, `11-ads`,
  `12-testing`, `13-ci-cd`, `14-ios-release-checklist`,
  `15-future-android-web-plan`, `18-git-and-github-workflow`,
  `19-universal-links-setup`. Deprecations had left the sequence full of holes,
  and a number said nothing a name does not.
- `docs/releasing.md` was `docs/ios-release-checklist.md` (21 Sep 2026): it
  took the versioning policy from the README and is no longer only a checklist.

Older issues, PRs and CHANGELOG entries use the old paths; resolve them to the
new ones.
