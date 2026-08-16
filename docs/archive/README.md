# Removed docs — the ledger

The documents listed here guided the initial build and are **superseded**. The
files themselves have been deleted so nothing can cite them as current; every
one is recoverable from git history. This README is the tombstone record: what
each file was, why it went, and where its subject lives now.

| File | Why removed | Current source of truth |
|---|---|---|
| `00-project-overview.md` | Original vision doc; superseded by the design reference. | `docs/design/PRODUCT.md` |
| `01-mvp-scope.md` | Original scope; superseded by the derived scope doc and the product rulings. | `docs/design/02-scope.md`, `docs/decisions.md` |
| `03-project-scaffold.md` | One-time scaffold steps; the project is built. | The repository itself; `CLAUDE.md` |
| `04-folder-structure.md` | Original `lib/` folder-structure spec, written around the Isar 3.x design; the tree it prescribed drifted from the one that got built. | `CLAUDE.md` (Project Layout), the repository itself |
| `05-dependencies.md` | Dependency snapshot drifted from reality. | `pubspec.yaml` |
| `06-local-persistence.md` | Designed for Isar; the app migrated to Drift. | `docs/02-architecture.md`, `lib/shared/storage/app_database.dart` |
| `07-content-model.md` | Original content-model spec; the models and banks now exist. | Freezed models under `lib/`, `assets/content/generated/`, `docs/design/06-content.md` |
| `08-mini-games.md` | Original mini-game spec; superseded by the design reference and rulings. | `docs/design/06-content.md`, `docs/decisions.md` §5 |
| `16-claude-code-task-plan.md` | Phase-by-phase build checklist — all 11 phases complete. | `docs/CHANGELOG.md` "Build Milestones" |

Also moved, not removed: `17-glossary.md` (a Flutter/Dart concepts primer, not
a domain glossary) now lives at [`learning/glossary.md`](../../learning/glossary.md).

Rows 03/05/06/16 date from the first sweep (2026-05-21, after Phase 11); the
rest were removed in the documentation restructure of 2026-08-16.
