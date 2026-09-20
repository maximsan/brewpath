# BrewPath — CI/CD

## Strategy

GitHub Actions is the CI platform. The pipeline validates code quality and runs tests on every pull request and every push to `main`.

No automated App Store deployment. That is added later once TestFlight distribution is routine.

---

## Branches

Branch names, how a PR merges, and the state of branch protection are in
[`git-and-github-workflow.md`](git-and-github-workflow.md), _Branches_.

---

## GitHub Actions Workflow

**The source of truth is [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)** —
it is thoroughly commented, and this doc deliberately does not duplicate it (an
embedded copy drifted from the real file twice). What the jobs are, and why:

| Job | Runner | What it gates |
|---|---|---|
| `changelog` | ubuntu | PRs only: requires a `docs/CHANGELOG.md` entry for product changes (`tool/check_changelog.sh`); skipped when the PR carries the `no-changelog` label |
| `comments` | ubuntu | PRs only: the comment cap (`tool/check_comments.dart --changed <base>`) on every Dart file the PR touches — the rule is CLAUDE.md's _Comments_ convention, and the same check runs locally ([`quality-checks.md`](quality-checks.md)) |
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

## Local checks

What runs before code leaves the machine — on the agent's write, on commit and
on push — is documented once, in [`quality-checks.md`](quality-checks.md). The
hooks live in [`tool/git-hooks/`](../tool/git-hooks/) and run the same
commands as the jobs above.

---

## Automated distribution — not yet

No automated TestFlight or App Store upload exists, and none is added until
distribution by hand is routine. The two options, with their steps, are a
plan: [plans/testflight-automation.md](plans/testflight-automation.md).
