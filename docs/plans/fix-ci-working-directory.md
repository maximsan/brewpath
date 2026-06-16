# Plan: Make CI run from the repo root after the project restructure

> **Executor instructions**: Follow this plan step by step. Run every verification
> command and confirm the expected result before moving on. If anything under
> "STOP conditions" occurs, stop and report — do not improvise.
>
> **Drift check (run first)**: `git diff --stat 071b8b4..HEAD -- .github/workflows/ci.yml`
> If `.github/workflows/ci.yml` changed since this plan was written, compare the
> "Current state" excerpt below against the live file before editing; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P1 (CI is fully red on every push/PR)
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: dx / ci
- **Planned at**: commit `071b8b4`, 2026-06-14

## Why this matters

The `chore: project restructure` commit moved the Flutter app from `coffee_quest/`
to the repo root, but `.github/workflows/ci.yml` still sets
`working-directory: coffee_quest` as a job-wide default. That directory no longer
exists, so the runner fails before any step runs:

```
Error: An error occurred trying to start process '/usr/bin/bash' with working
directory '/home/runner/work/brewpath/brewpath/coffee_quest'. No such file or directory
```

All three CI jobs (`format`, `analyze & test`, `iOS build`) fail. Removing the stale
default makes every step run from the checkout root, where `pubspec.yaml`, `lib/`,
`test/`, and `integration_test/` now live. After this lands, CI is green again.

## Current state

- `.github/workflows/ci.yml` — the only workflow this repo owns. (The many
  `*.yml` files under `build/ios/SourcePackages/...` are vendored dependency
  workflows; GitHub does not run them. Do **not** touch them.)
- `pubspec.yaml` (package name still `coffee_quest`), `lib/`, `test/`, and
  `integration_test/` are all at the repo root — confirmed by `ls` at root.
- The broken section, exactly as it exists today (`.github/workflows/ci.yml:1-14`):

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

# The Flutter app lives in coffee_quest/; the repo root holds only docs.
defaults:
  run:
    working-directory: coffee_quest

env:
  FLUTTER_VERSION: "3.44.1"
```

Every `run:` step below this inherits `working-directory: coffee_quest`. The fix is
to delete the now-false comment **and** the `defaults:` block so steps run at root.
No `run:` step references a `coffee_quest/`-relative path, so nothing else needs to
change — all paths (`lib`, `test`, `integration_test`, `build/ios/iphoneos/Runner.app`)
are already correct relative to the root.

## Commands you will need

| Purpose            | Command                                                                                  | Expected on success        |
|--------------------|------------------------------------------------------------------------------------------|----------------------------|
| YAML parse check   | `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"`              | exit 0, no output          |
| Confirm fix        | `grep -n "working-directory" .github/workflows/ci.yml`                                    | no matches (exit 1)        |
| Format check       | `dart format --output=none --set-exit-if-changed lib test integration_test`              | exit 0                     |
| Deps               | `flutter pub get`                                                                        | exit 0                     |
| Analyze            | `flutter analyze`                                                                        | exit 0, "No issues found!" |
| Metrics gate       | `dart run dart_code_linter:metrics analyze lib --set-exit-on-violation-level=warning`    | exit 0                     |
| Tests              | `flutter test`                                                                           | all pass                   |
| iOS build (macOS)  | `flutter build ios --release --no-codesign`                                              | exit 0                     |

`actionlint` is **not installed** in this environment — use the `python3` YAML parse
above as the local syntax check. GitHub validates full workflow syntax on push.

## Scope

**In scope** (the only file to modify):
- `.github/workflows/ci.yml`

**Out of scope** (do NOT touch):
- Any `*.yml` under `build/` — vendored dependency workflows, not run by this repo.
- `CLAUDE.md`, `AGENTS.md`, `README.md` — they still describe the old `coffee_quest/`
  layout and are now inaccurate, but fixing docs is a separate follow-up (see
  Maintenance notes). Do not edit them in this plan.
- Application code, tests, `pubspec.yaml` — this is a config-only change.

## Git workflow

- Create a branch: `git checkout -b fix/ci-working-directory`.
- One commit; message style is conventional commits (see `git log --oneline`, e.g.
  `chore: project restructure`). Suggested: `ci: run workflow from repo root after restructure`.
- Do **not** push or open a PR unless the operator explicitly asks. (Verification
  step 4 below requires a push; only perform it on instruction.)

## Steps

### Step 1: Remove the stale comment and `working-directory` default

Edit `.github/workflows/ci.yml` so the top of the file (lines 1–14 above) becomes
**exactly**:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

env:
  FLUTTER_VERSION: "3.44.1"
```

That is: delete the line `# The Flutter app lives in coffee_quest/; the repo root
holds only docs.` and the three lines `defaults:` / `run:` / `working-directory:
coffee_quest`, leaving a single blank line between `pull_request:` and `env:`. Do
not change anything below `env:`.

**Verify**:
- `grep -n "working-directory" .github/workflows/ci.yml` → no matches (exit 1).
- `grep -n "coffee_quest" .github/workflows/ci.yml` → no matches (exit 1).
- `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"` → exit 0.

## Verification Plan

- [ ] Verification 1 — Workflow still parses
  - `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"`
  - Expected: exit 0, no error.

- [ ] Verification 2 — Each CI command succeeds from the repo root
  - Run, in order, from the repo root: the Format check, Deps, Analyze, Metrics
    gate, and Tests commands from the table above.
  - Expected: every command exits 0; no "No such file or directory" / missing-path errors.
  - If `flutter`/`dart` are not on PATH, STOP and report (see STOP conditions) —
    do not attempt to install a toolchain.

- [ ] Verification 3 — iOS build job (macOS hosts only)
  - `flutter build ios --release --no-codesign` then `ls -la build/ios/iphoneos/Runner.app`.
  - Expected: build exits 0 and `build/ios/iphoneos/Runner.app` exists.
  - If not on macOS, skip and note "skipped — not a darwin host"; GitHub's
    `macos-latest` runner covers it in Verification 4.

- [ ] Verification 4 — CI is green on GitHub (only after an authorized push)
  - Push the branch / open a PR, then watch the `CI` run (e.g. `gh run watch`).
  - Expected: all three jobs — `format`, `analyze & test`, `iOS build` — finish with
    a ✓ in the run summary, and the working-directory error is gone. If a job fails
    only on an infra/transient error (timeout, runner pull failure), re-run it once
    before treating it as a real failure.

## Test Plan

- No new or changed unit tests: this is a CI-config-only change with no application
  code touched. Adding tests here would be scope creep.
- The required project test is the **existing** suite passing from the new root:
  `flutter test` (Verification 2) locally and in the `analyze & test` job
  (Verification 4). DoD: suite passes in both.

## Done criteria

ALL must hold:

- [ ] `grep -n "working-directory" .github/workflows/ci.yml` returns no matches.
- [ ] `grep -n "coffee_quest" .github/workflows/ci.yml` returns no matches.
- [ ] `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"` exits 0.
- [ ] `git status --porcelain` shows only `.github/workflows/ci.yml` modified.
- [ ] (After authorized push) all three CI jobs are green.

## STOP conditions

Stop and report back (do not improvise) if:

- The drift check shows `.github/workflows/ci.yml` no longer matches the "Current
  state" excerpt (someone already edited it).
- `flutter` or `dart` is not installed / not on PATH — report it; do not install a toolchain.
- A `coffee_quest/` directory still exists at the repo root, or `pubspec.yaml` is
  **not** at the root — the restructure assumption is wrong; re-confirm before editing.
- Verification 2 surfaces `flutter analyze`, metrics, or test failures that are not
  path/working-directory related — these are likely pre-existing issues unrelated to
  this fix; report them rather than fixing them under this plan.

## Maintenance notes

- Follow-up (deferred, not in this plan): `CLAUDE.md`, `AGENTS.md`, and `README.md`
  still describe the `coffee_quest/` subdirectory and instruct running flutter/dart
  commands from there. They are now inaccurate and should be updated separately.
- If the app is ever moved back into a subdirectory, the `working-directory` default
  must be reintroduced (or per-step `working-directory:` added).
- Reviewer should confirm the diff touches only `.github/workflows/ci.yml` and that
  no `run:` step relies on a `coffee_quest/`-relative path.
