# BrewPath — CI/CD

## Strategy

GitHub Actions is the CI platform. The pipeline validates code quality and runs tests on every pull request and every push to `main`.

No automated App Store deployment. That is added later once TestFlight distribution is routine.

---

## Branch Strategy

Branches follow the conventional prefixes `feat/`, `fix/`, `chore/`, `docs/`,
`prototype/` with a kebab-case slug (e.g. `feat/lesson-mastery-gauge`). Work
merges to `main` via PR; the `gh` commands and merge-strategy guidance live in
[`18-git-and-github-workflow.md`](18-git-and-github-workflow.md). Note `main`
currently has **no branch protection** — nothing refuses a merge with red CI,
so check the jobs before merging.

---

## GitHub Actions Workflow

**The source of truth is [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)** —
it is thoroughly commented, and this doc deliberately does not duplicate it (an
embedded copy drifted from the real file twice). What the jobs are, and why:

| Job | Runner | What it gates |
|---|---|---|
| `changelog` | ubuntu | PRs only: requires a `docs/CHANGELOG.md` entry for product changes (`tool/check_changelog.sh`); skipped when the PR carries the `no-changelog` label |
| `format` | ubuntu | `dart format` over `lib test integration_test` (after `pub get`, so the language version resolves) |
| `analyze & test` | ubuntu | `flutter analyze`, the `dart_code_linter` metrics gate, then `flutter test` (Node pinned for the extractor test) |
| `iOS build` | macos | `flutter build ios --release --no-codesign` — no CocoaPods (SPM) and no Firebase plist while `kUseFirebase == false` |

Generated files are committed, so no `build_runner` step runs in CI.

---

## Required GitHub Secrets

**None for the current pipeline.** The `ios-build` job compiles with Firebase
gated off (`kUseFirebase == false`), so no `GoogleService-Info.plist` is needed
at build time. A `GOOGLE_SERVICE_INFO_PLIST` secret only becomes necessary if a
future CI job needs Firebase active at runtime (e.g. an integration-test job).

---

## Local pre-commit checks

Developers should run these before pushing:

```bash
# Format
dart format .

# Analyze
flutter analyze

# Test
flutter test
```

Optionally add a git pre-push hook:

```bash
# .git/hooks/pre-push
#!/bin/sh
flutter analyze && flutter test
```

---

## Codemagic Alternative

Codemagic is NOT required for MVP. Consider it only if:
- The team needs automated TestFlight uploads from CI
- iOS code signing in GitHub Actions becomes too complex to manage

Codemagic provides better native iOS code signing integration (automatic code signing via App Store Connect API key) and built-in TestFlight upload steps.

If Codemagic is added later:
- [ ] Create a `codemagic.yaml` in the project root
- [ ] Configure iOS workflow with code signing environment group
- [ ] Add TestFlight distribution step

---

## Future: Automated TestFlight Distribution

When ready to automate TestFlight:

Option A — Fastlane + GitHub Actions:
- [ ] Add `fastlane/` directory to project root
- [ ] Create `Fastfile` with `build_app` and `upload_to_testflight` lanes
- [ ] Store `AuthKey_*.p8` and `App Store Connect API key` details as GitHub secrets
- [ ] Add a `release` GitHub Actions workflow that triggers on `git tag v*`

Option B — Codemagic:
- [ ] Migrate ios-build job to Codemagic
- [ ] Configure automatic code signing
- [ ] Enable TestFlight upload trigger on `main` branch

---

## Still open (manual — user)

- [ ] Enable branch protection on `main` requiring the CI jobs to pass before merge
