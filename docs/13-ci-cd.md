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
| `iOS build` | macos | `flutter build ios --release --no-codesign` — no CocoaPods (SPM) and no Firebase plist while `kUseFirebase == false`. Then asserts `PrivacyInfo.xcprivacy` reached `Runner.app`: it is wired into the target by hand, and nothing else notices if a merge drops it (#166) |
| `smoke (simulator)` | macos | **Push to main only.** Boots an iPhone simulator and runs `integration_test/smoke_test.dart` — the only job that *runs* the app rather than compiling it. The app is built by `flutter build ios --simulator` and run by `xcodebuild test`, which launches it and reports each Dart test as an XCTest result (`ios/RunnerTests/RunnerTests.m`), because `flutter test integration_test` can miss the app's start-up line on this runner and wait forever (the reason is in the workflow's comments). The simulator is erased and fully booted first (`tool/ci/boot_simulator.sh`). The 60-minute cap only backstops a wedged runner |

Generated files are committed, so no `build_runner` step runs in CI.

---

## Required GitHub Secrets

**None for the current pipeline.** The `ios-build` job compiles with Firebase
gated off (`kUseFirebase == false`), so no `GoogleService-Info.plist` is needed
at build time. A `GOOGLE_SERVICE_INFO_PLIST` secret only becomes necessary if a
future CI job needs Firebase active at runtime (e.g. an integration-test job).

---

## Local checks (git hooks)

[`tool/git-hooks/`](../tool/git-hooks/) carries the checks that run before
code leaves the machine. [`tool/install_hooks.sh`](../tool/install_hooks.sh)
links them into the repository's shared hooks directory, so every worktree
runs them and a machine-wide `commit-msg` hook is left as it is. Claude Code
runs the installer at session start ([`.claude/settings.json`](../.claude/settings.json));
run it by hand once per clone otherwise.

- **pre-commit** fails the commit when a staged Dart file is unformatted or
  carries a comment block over the cap. Sub-second.
- **pre-push** runs the CI gates that need no device: the format check,
  `flutter analyze`, the `dart_code_linter` metrics, every
  `*_guard_test.dart`, the comment cap on every Dart file changed against
  the base, and `tool/check_changelog.sh`. About a minute. `git push
  --no-verify` skips all of it; `NO_CHANGELOG=1 git push` skips only the
  changelog check, for a PR that will carry the `no-changelog` label; a
  branch stacked on another names its base with `BASE_REF=origin/<branch>`,
  which is what CI compares against too.

The full test suite and the iOS build stay in CI: they take minutes, and a
push is not a merge. A repo-wide rule test is named `*_guard_test.dart` so the
pre-push hook picks it up.

The comment cap is [`tool/check_comments.dart`](../tool/check_comments.dart),
which runs with plain `dart`. The guard test holds a baseline of existing
overruns; the hook, the `comments` CI job and the agent's write hook allow
none, so a file a branch touches is a file that leaves the baseline.

Claude Code formats and comment-checks every Dart file it writes through the
`PostToolUse` hook in the same settings file; a failure goes straight back to
the agent.

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
