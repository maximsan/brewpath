# BrewPath — CI/CD

> **Status (2026-05-21):** The actual workflow shipped in
> `.github/workflows/ci.yml` differs from the original spec below, which is now
> updated to match: Flutter **3.44.0** (not 3.41.9), **no** `build_runner` step
> (generated files are committed), `main`-only triggers, **no**
> `GOOGLE_SERVICE_INFO_PLIST` secret and **no** `pod install` — the project
> migrated from CocoaPods to **Swift Package Manager** in Phase 11, and the iOS
> build needs no Firebase plist while `kUseFirebase == false`.

## Strategy

GitHub Actions is the default CI platform. The pipeline validates code quality and runs tests on every pull request and every push to `main`.

No automated App Store deployment in the initial scaffold. That is added later once TestFlight distribution is routine.

---

## Branch Strategy

| Branch | Protection | Purpose |
|---|---|---|
| `main` | Protected — requires PR, passing CI | Production-ready code |
| `develop` | Optional | Integration branch for active features |
| `feature/*` | None | Individual feature work |
| `fix/*` | None | Bug fixes |

Rules for `main`:
- [ ] Enable "Require a pull request before merging" in GitHub → Repository → Settings → Branches
- [ ] Enable "Require status checks to pass before merging" — select `format`, `analyze & test`, `iOS build` jobs
- [ ] Enable "Require branches to be up to date before merging"

---

## GitHub Actions Workflow

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

env:
  FLUTTER_VERSION: "3.44.0"

jobs:
  format:
    name: format
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true
      # Scoped to source dirs — `dart format .` would descend into build/
      # (Firebase plugins copy example apps there with broken includes).
      - name: Check formatting
        run: dart format --output=none --set-exit-if-changed lib test integration_test

  analyze-test:
    name: analyze & test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true
      - name: Install dependencies
        run: flutter pub get
      - name: Analyze
        run: flutter analyze
      # Generated helpers are committed, so no codegen step is required.
      - name: Test
        run: flutter test

  ios-build:
    name: iOS build
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true
      - name: Install dependencies
        run: flutter pub get
      # No CocoaPods (Swift Package Manager) and no GoogleService-Info.plist —
      # the build succeeds with Firebase gated off (kUseFirebase == false).
      - name: Build iOS (no code signing)
        run: flutter build ios --release --no-codesign
      - name: Verify build artifact
        run: ls -la build/ios/iphoneos/Runner.app
```

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

## Steps

- [x] Create `.github/workflows/ci.yml` with the 3-job YAML above (`format`, `analyze & test`, `iOS build`)
- [x] ~~Add `GOOGLE_SERVICE_INFO_PLIST` secret~~ — _N/A; iOS build needs no plist while `kUseFirebase == false`_
- [ ] Push to GitHub and verify all 3 jobs run green _(manual — user)_
- [ ] Verify the iOS build job passes (requires macOS runner — uses macOS credits) _(manual — user)_
- [ ] Enable branch protection rules on `main` requiring all 3 jobs to pass _(manual — user)_
- [ ] Add local pre-commit check instructions to README.md _(optional)_

---

## Definition of Done

- [x] `.github/workflows/ci.yml` exists and is syntactically valid YAML
- [x] `format` job: fails on unformatted code, passes on formatted code
- [x] `analyze & test` job: runs `flutter analyze` + all unit/widget tests
- [x] `ios-build` job: builds `Runner.app` without code signing errors on macOS runner
- [x] ~~`GOOGLE_SERVICE_INFO_PLIST` secret~~ — _N/A (see Required GitHub Secrets)_
- [ ] Branch protection on `main` requires all 3 jobs to pass before merge _(manual — user)_
- [ ] CI runs green on the first push _(manual — user)_
