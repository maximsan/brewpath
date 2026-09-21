# Automated TestFlight distribution — a plan, not a decision

Snapshot moved out of `ci-cd.md` on 21 September 2026. Nothing here is built
or ruled; CI has no upload step, and adds one only once TestFlight
distribution is routine by hand.

**What changed since this was written:** Codemagic is now the CI platform for
the macOS workflows, for reasons that have nothing to do with TestFlight —
GitHub bills macOS runners at ten times Linux, which a private repository
cannot absorb ([`../ci-cd.md`](../ci-cd.md), _Strategy_). That settles Option
B's first step by accident and makes Option B the cheaper of the two to
finish, but it does not decide anything below: no workflow signs or uploads
today.

## Option A — Fastlane + GitHub Actions

Now the more expensive option, not just the more manual one: it would put a
signing and upload build back on a GitHub macOS runner, at ten times the
per-minute rate of the Codemagic instance already building the app.

- [ ] Add `fastlane/` to the project root
- [ ] Create a `Fastfile` with `build_app` and `upload_to_testflight` lanes
- [ ] Store the `AuthKey_*.p8` and App Store Connect API key details as GitHub secrets
- [ ] Add a `release` workflow that triggers on `git tag v*`

## Option B — Codemagic

Codemagic signs through an App Store Connect API key and has a built-in
TestFlight step. The iOS build already runs there, so what remains is signing
and the upload trigger — the build itself no longer needs migrating.

- [x] Create a `codemagic.yaml` in the project root — done for the cost split, with an unsigned `ios-build` workflow
- [ ] Configure the iOS workflow with a code-signing environment group
- [ ] Enable the TestFlight upload trigger on `main`
