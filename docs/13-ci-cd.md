# Coffee Quest — CI/CD

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
- [ ] Enable "Require status checks to pass before merging" — select `format`, `analyze`, `test` jobs
- [ ] Enable "Require branches to be up to date before merging"

---

## GitHub Actions Workflow

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

env:
  FLUTTER_VERSION: "3.41.9"

jobs:
  format:
    name: Format
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - name: Check formatting
        run: dart format --output=none --set-exit-if-changed .

  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Generate code
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Analyze
        run: flutter analyze --fatal-infos

  test:
    name: Unit & Widget Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Generate code
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: coverage/lcov.info
        continue-on-error: true  # Coverage upload failure does not block CI

  ios-build:
    name: iOS Build Validation
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Generate code
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Write GoogleService-Info.plist
        env:
          GOOGLE_SERVICE_INFO_PLIST: ${{ secrets.GOOGLE_SERVICE_INFO_PLIST }}
        run: |
          echo "$GOOGLE_SERVICE_INFO_PLIST" > ios/Runner/GoogleService-Info.plist

      - name: Install CocoaPods
        run: |
          cd ios
          pod install

      - name: Build iOS (no code signing)
        run: |
          flutter build ios --release --no-codesign

      - name: Verify build artifact
        run: |
          ls -la build/ios/iphoneos/Runner.app
```

---

## Required GitHub Secrets

Configure these in GitHub → Repository → Settings → Secrets and variables → Actions:

| Secret Name | Value | How to Get |
|---|---|---|
| `GOOGLE_SERVICE_INFO_PLIST` | Full contents of `GoogleService-Info.plist` | Firebase Console → iOS app → Download plist → `cat` the file |

**Do not commit `GoogleService-Info.plist` in CI workflows inline.** Always inject via secret.

> Note: For iOS, `GoogleService-Info.plist` contains only public Firebase identifiers (no private keys). It is safe to commit to the repo directly for developer use. In CI, it is still best practice to inject via secret to avoid public repository exposure.

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

- [x] Create `.github/workflows/ci.yml` with the full YAML above — _committed in `c1850fe`_
- [ ] Push to GitHub and verify all 4 jobs run (format, analyze, test, ios-build)
- [ ] Add `GOOGLE_SERVICE_INFO_PLIST` secret in GitHub Repository Settings
- [ ] Verify the iOS build job passes (requires macOS runner — uses macOS credits)
- [ ] Enable branch protection rules on `main` requiring all 4 jobs to pass
- [ ] Add local pre-commit check instructions to README.md

---

## Definition of Done

- [ ] `.github/workflows/ci.yml` exists and is syntactically valid YAML
- [ ] `format` job: fails on unformatted code, passes on formatted code
- [ ] `analyze` job: fails on `flutter analyze` warnings with `--fatal-infos`
- [ ] `test` job: runs all unit and widget tests, fails if any test fails
- [ ] `ios-build` job: builds `Runner.app` without code signing errors on macOS runner
- [ ] `GOOGLE_SERVICE_INFO_PLIST` secret is configured in GitHub
- [ ] Branch protection on `main` requires all 4 jobs to pass before merge
- [ ] CI runs green on the initial scaffold push
