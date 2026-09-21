# BrewPath — CI/CD

## Strategy

CI runs on two platforms, split by what a runner costs rather than by what it
does:

- **GitHub Actions** ([`.github/workflows/ci.yml`](../.github/workflows/ci.yml))
  runs the Linux checks — format, analyze, metrics, tests and the two
  pull-request gates — on every pull request and every push to `main`.
- **Codemagic** ([`codemagic.yaml`](../codemagic.yaml)) runs the two macOS
  workflows: the iOS build, and the simulator smoke suite.

The reason is billing. GitHub charges a macOS runner at **ten times** the
Linux rate and rounds every job up to the minute, so on a private repository
the iOS build and smoke cost about **150 charged minutes per push to `main`** —
an order of magnitude more than the entire Linux suite. Codemagic bills real
minutes against a 500-a-month personal allowance, where the same work costs
about **14**. Nothing was dropped in the move; the two workflows run the same
commands against the same scripts.

No automated App Store deployment. That is added later once TestFlight
distribution is routine — and Codemagic's built-in TestFlight step is now the
likelier route, which [plans/testflight-automation.md](plans/testflight-automation.md)
records.

---

## Branches

Branch names, how a PR merges, and the state of branch protection are in
[`git-and-github-workflow.md`](git-and-github-workflow.md), _Branches_.

---

## GitHub Actions — the Linux checks

**The source of truth is [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)** —
it is thoroughly commented, and this doc deliberately does not duplicate it (an
embedded copy drifted from the real file twice).

One job, `checks`, runs every Linux gate in sequence. It is one job rather than
four because each separate job paid its own checkout, its own Flutter install
and its own rounded-up billing minute for work that took seconds. The cheap
steps run first, so a formatting slip still fails in under a minute instead of
behind the test suite.

| Step | What it gates |
|---|---|
| changelog | PRs only: requires a `docs/CHANGELOG.md` entry for product changes (`tool/check_changelog.sh`); skipped when the PR carries the `no-changelog` label |
| comments | PRs only: the comment cap (`tool/check_comments.dart --changed <base>`) on every Dart file the PR touches — the rule is CLAUDE.md's _Comments_ convention, and the same check runs locally ([`quality-checks.md`](quality-checks.md)) |
| format | `dart format` over `lib test integration_test tool` (after `pub get`, so the language version resolves) |
| analyze | `flutter analyze` |
| metrics | the `dart_code_linter` per-function metrics gate |
| test | `flutter test` (Node pinned for the extractor tests) |

Generated files are committed, so no `build_runner` step runs in CI.

Two further economies, both in the workflow's `on:` and `concurrency:` blocks:
a second push to a pull request cancels the run its predecessor started, and a
change confined to `docs/`, `learning/`, `.claude/` or any `*.md` skips the
workflow entirely. `prototype/` is deliberately **not** in that skip list —
`test/unit/tool/extract_content_test.dart` and `extract_card_art_test.dart`
read its sources, so an edit there can genuinely fail CI.

---

## Codemagic — the macOS workflows

**The source of truth is [`codemagic.yaml`](../codemagic.yaml)**, on the same
terms: it is commented, and this doc does not restate it.

| Workflow | Trigger | What it gates |
|---|---|---|
| `ios-build` | push to `main` | `flutter build ios --release --no-codesign` — no CocoaPods (SPM) and no Firebase plist while `kUseFirebase == false`. Then asserts `PrivacyInfo.xcprivacy` reached `Runner.app` and that the associated-domains entitlement is still wired: both are wired into the target by hand, and nothing else notices if a merge drops them (#166, #171) |
| `smoke` | **nightly schedule** | Boots an iPhone simulator and runs `integration_test/smoke_test.dart` — the only job that *runs* the app rather than compiling it. Built by `flutter build ios --simulator` and run by `xcodebuild test`, which launches it and reports each Dart test as an XCTest result (`ios/RunnerTests/RunnerTests.m`), because `flutter test integration_test` can miss the app's start-up line and wait forever (the reason is in the workflow's comments). The simulator is erased and fully booted first (`tool/ci/boot_simulator.sh`) |

Two things about this table are worth stating plainly, because both are
changes in what CI proves:

**The iOS build no longer runs on pull requests.** It ran on every push to a
branch and then again on the merge, proving the same thing twice at fifty
charged minutes a go. A branch that warrants an iOS check before it merges
gets a manual build from the Codemagic UI.

**The smoke suite runs nightly, not per-push.** What it guards against is
*rot* rather than a specific regression — a migration that fails on a real
database, an asset the pubspec does not bundle, an unregistered plugin — and
rot is a thing you check on a clock. It is also the expensive half of the
macOS budget, and moving it to a schedule is what keeps the month inside the
free allowance. The cost: a push that breaks start-up is now found the
following morning rather than within the hour.

**The nightly schedule is not in `codemagic.yaml`.** Codemagic configures
scheduled builds in its UI (Build scheduling), and the format has no key for
them. The `smoke` workflow therefore carries no `triggering:` block at all, so
nothing in the repository starts it — if the UI schedule is ever deleted, the
suite silently stops running, which is the same failure #187 already caught
once.

---

## Required secrets

**None, on either platform.** The `ios-build` workflow compiles with Firebase
gated off (`kUseFirebase == false`), so no `GoogleService-Info.plist` is needed
at build time, and neither macOS workflow signs anything. A
`GOOGLE_SERVICE_INFO_PLIST` secret only becomes necessary if a future job needs
Firebase active at runtime (e.g. an integration-test job); a code-signing
environment group only when TestFlight upload arrives.

Codemagic needs read-only access to the repository, granted by installing its
GitHub App on `maximsan/brewpath`.

---

## Local checks

What runs before code leaves the machine — on the agent's write, on commit and
on push — is documented once, in [`quality-checks.md`](quality-checks.md). The
hooks live in [`tool/git-hooks/`](../tool/git-hooks/) and run the same
commands as the steps above.

---

## Profiling the test suite

`flutter test` is the longest step in CI, so
[`tool/profile_tests.js`](../tool/profile_tests.js) exists to attribute its
time rather than guess at it:

```bash
node tool/profile_tests.js                  # runs the suite, then reports
node tool/profile_tests.js --report r.json  # reports on an existing run
```

It separates the per-file cost of loading a test file from the cost of running
the tests inside it, because the two have unrelated fixes — fewer and larger
files, or a different `--concurrency`, against repairing individual slow tests.

---

## Automated distribution — not yet

No automated TestFlight or App Store upload exists, and none is added until
distribution by hand is routine. The options, with their steps, are a plan:
[plans/testflight-automation.md](plans/testflight-automation.md).
