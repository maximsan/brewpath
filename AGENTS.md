# BrewPath — AGENTS.md

**The canonical agent guide is [`CLAUDE.md`](CLAUDE.md)** — architecture,
critical rules, conventions, and code-quality rules all live there, once.
(This file used to mirror it; the two copies drifted, so the mirror was
retired — 2026-08-16.)

## Orientation

The Flutter app is **at the git root** — there is no nested app directory.

```
brewpath/               ← git root; canonical rules in CLAUDE.md
├── lib/                ← Flutter app source (package: brew_path)
├── test/               ← unit + widget tests
├── integration_test/   ← integration tests
├── assets/             ← bundled content, fonts, images
├── ios/                ← iOS runner (SPM-only; no Podfile)
├── tool/               ← release + maintenance scripts
├── prototype/          ← design source (React prototype, not built) — READ-ONLY
├── docs/               ← doc map at docs/README.md; design reference, ADRs, agent guides
├── learning/           ← hands-on Flutter course for this app
└── .claude/            ← Claude Code project settings
```

Read in this order:

1. [`CLAUDE.md`](CLAUDE.md) — the rules and conventions (canonical)
2. [`docs/README.md`](docs/README.md) — the doc map and source-precedence rules
3. [`CONTEXT.md`](CONTEXT.md) — the domain glossary; use its terms, respect its _Avoid_ lists

## Agent skills

Issue tracker (`gh` on `maximsan/brewpath`):
[`docs/agents/issue-tracker.md`](docs/agents/issue-tracker.md). Triage labels:
[`docs/agents/triage-labels.md`](docs/agents/triage-labels.md). Domain docs
(`CONTEXT.md` + `docs/adr/`): [`docs/agents/domain.md`](docs/agents/domain.md).
