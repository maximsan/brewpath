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
about **14**. No command was dropped — the two workflows run the same commands against the
same scripts. What changed is *when* they run, which the two notes below spell
out.

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
change confined to `.claude/` skips the workflow entirely. That is the only
path skipped, because it is the only one no test reads. `docs/`, `learning/`
and the root markdown files were skipped too until
`test/unit/tool/adr_numbering_test.dart` and
`test/unit/glossary_vocabulary_test.dart` turned out to assert over exactly
them — `tool/guard_tests.dart` lists `docs/` as a guard root — so skipping
them had switched two regression guards off.

---

## Codemagic — the macOS workflows

**The source of truth is [`codemagic.yaml`](../codemagic.yaml)**, on the same
terms: it is commented, and this doc does not restate it.

| Workflow | Trigger | What it gates |
|---|---|---|
| `ios-build` | push to `main` | `flutter build ios --release --no-codesign` — no CocoaPods (SPM) and no Firebase plist while `kUseFirebase == false`. Then asserts `PrivacyInfo.xcprivacy` reached `Runner.app` and that the associated-domains entitlement is still wired: both are wired into the target by hand, and nothing else notices if a merge drops them (#166, #171) |
| `smoke` | **nightly**, started over the API by `nightly-smoke.yml` | Boots an iPhone simulator and runs `integration_test/smoke_test.dart` — the only job that *runs* the app rather than compiling it. Built by `flutter build ios --simulator` and run by `xcodebuild test`, which launches it and reports each Dart test as an XCTest result (`ios/RunnerTests/RunnerTests.m`), because `flutter test integration_test` can miss the app's start-up line and wait forever (the reason is in the workflow's comments). The simulator is erased and fully booted first (`tool/ci/boot_simulator.sh`) |

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

### Where the nightly smoke runs

**The schedule is a GitHub Actions cron either way.** Codemagic's own scheduled
builds are a Team feature, and the free 500 macOS minutes a month are
personal-account only, so no free plan can hold both. That turned out for the
better: the trigger is declared in the repository, which is what #187 was
about.

[`.github/workflows/nightly-smoke.yml`](../.github/workflows/nightly-smoke.yml)
carries both destinations and fires exactly one, chosen by the repository
variable `SMOKE_RUNNER`:

| `SMOKE_RUNNER` | Runs | Costs |
|---|---|---|
| unset or `github` | the suite on a GitHub macOS runner | nothing while the repo is public; **ten times Linux** once it is private |
| `codemagic` | a POST to Codemagic's `/builds` API, starting the `smoke` workflow | ~14 real minutes against the free 500 a month |

Switch with `gh variable set SMOKE_RUNNER --body codemagic` — no code change —
or override for one run from the workflow's `runner` input. **Pick by
visibility:** `github` while the repo is public, because the minutes are free
and the result lands in the Actions tab; `codemagic` once it is private,
because that is the whole reason Codemagic is here.

The `codemagic` path needs two repository secrets, `CODEMAGIC_API_TOKEN` and
`CODEMAGIC_APP_ID`; the job fails by name if either is missing. Two things it
does not cover: it goes green when the build *starts*, not when it passes — it
deliberately does not poll, because polling bills the wall clock of a
fifteen-minute suite, so the result comes from Codemagic's own notification —
and GitHub disables a cron in a repository with no activity for 60 days.

The cost of holding both: the smoke steps exist twice, in this workflow and in
`codemagic.yaml`. Nothing can share them, because the two formats are
different products. A change to one is a change to both.

---

## Required secrets

**None for the builds themselves.** Only the optional `codemagic` nightly
path needs any: `CODEMAGIC_API_TOKEN` and `CODEMAGIC_APP_ID`, both repository
secrets, described above. The `ios-build` workflow compiles with Firebase
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
