# Automated TestFlight distribution — a plan, not a decision

Snapshot moved out of `ci-cd.md` on 21 September 2026. Nothing here is built
or ruled; CI has no upload step, and adds one only once TestFlight
distribution is routine by hand.

## Option A — Fastlane + GitHub Actions

- [ ] Add `fastlane/` to the project root
- [ ] Create a `Fastfile` with `build_app` and `upload_to_testflight` lanes
- [ ] Store the `AuthKey_*.p8` and App Store Connect API key details as GitHub secrets
- [ ] Add a `release` workflow that triggers on `git tag v*`

## Option B — Codemagic

Not required today. Consider it only if the team needs automated TestFlight
uploads from CI, or iOS code signing in GitHub Actions becomes too complex to
manage; Codemagic signs through an App Store Connect API key and has a
built-in TestFlight step.

- [ ] Create a `codemagic.yaml` in the project root
- [ ] Configure the iOS workflow with a code-signing environment group
- [ ] Migrate the iOS build job and enable the TestFlight upload trigger on `main`
