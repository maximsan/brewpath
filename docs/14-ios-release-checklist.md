# BrewPath — iOS Release Checklist

## Overview

This checklist covers everything needed to publish BrewPath to the App Store and distribute via TestFlight. Steps are ordered from first-time setup through submission.

---

## 1. Apple Developer Account

- [ ] Enroll in Apple Developer Program at [developer.apple.com](https://developer.apple.com) — $99/year
- [ ] Accept all agreements in App Store Connect
- [ ] Create an App-Specific Password for automated tools if needed (TestFlight CLI, Fastlane)

---

## 2. App ID and Bundle ID

- [ ] Go to Apple Developer Portal → Identifiers → App IDs
- [ ] Create a new App ID:
  - Description: `BrewPath`
  - Bundle ID (Explicit): `dev.maximsan.brewPath`
  - Capabilities: none required for MVP
- [ ] Verify the Bundle ID in Xcode matches: Runner target → General → Bundle Identifier

---

## 3. App Store Connect — Create App Record

- [ ] Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
- [ ] Click + (New App)
  - Platform: iOS
  - Name: BrewPath
  - Primary Language: English
  - Bundle ID: select `dev.maximsan.brewPath`
  - SKU: `BREWPATH001` (any unique string)
- [ ] Save the app record

---

## 4. Xcode Project Configuration

- [ ] Open `ios/Runner.xcworkspace` in Xcode (always use `.xcworkspace`, not `.xcodeproj`)
- [ ] Runner target → General:
  - [ ] Version and Build: taken from the **current** `pubspec.yaml` `version:`
        (never hardcode — the build number only moves forward)
  - [ ] Minimum Deployments: iOS 16.0
  - [ ] Display Name: BrewPath
- [ ] Runner target → Signing & Capabilities:
  - [ ] Team: select your Apple Developer team
  - [ ] Signing Certificate: iOS Distribution (Xcode will create if missing)
  - [ ] Provisioning Profile: Xcode Managed Profile (automatic)
- [ ] Verify there are no code signing errors (red icons) in the Signing section

---

## 5. Info.plist Required Keys

Open `ios/Runner/Info.plist` and verify these keys exist:

```xml
<key>CFBundleDisplayName</key>
<string>BrewPath</string>

<key>CFBundleShortVersionString</key>
<string>$(FLUTTER_BUILD_NAME)</string>

<key>CFBundleVersion</key>
<string>$(FLUTTER_BUILD_NUMBER)</string>

<key>LSRequiresIPhoneOS</key>
<true/>

<key>UILaunchStoryboardName</key>
<string>LaunchScreen</string>

<key>NSCalendarsUsageDescription</key>
<!-- Only add if using calendars — not needed for MVP -->

<key>ITSAppUsesNonExemptEncryption</key>
<false/>
<!-- Declare encryption status — false for apps with no custom encryption -->
```

- [ ] `ITSAppUsesNonExemptEncryption` is set to `false` (required unless using non-exempt encryption)
- [ ] `NSUserTrackingUsageDescription` is NOT required for MVP (add when ads go live)

---

## 6. Privacy Manifest (iOS 17+)

Apple requires a Privacy Manifest for apps accessing certain APIs.

- [x] Create `ios/Runner/PrivacyInfo.xcprivacy` — it lives at
      [`ios/Runner/PrivacyInfo.xcprivacy`](../ios/Runner/PrivacyInfo.xcprivacy)
      and its own comments carry the reasoning for each entry. Read the file, not
      a copy of it.
- [x] In Xcode: add `PrivacyInfo.xcprivacy` to the Runner target (Build Phases →
      Copy Bundle Resources). Wired in `project.pbxproj`; the `iOS build` CI job
      fails if it stops landing in `Runner.app`.

What the app declares today: **tracks nobody, collects nothing**, and one
required-reason API — `NSPrivacyAccessedAPICategoryFileTimestamp` (`C617.1`),
because SQLite stats its own database file. SQLite reaches the binary through
`package:sqlite3`, which compiles it via a Dart build hook and ships no manifest,
so the app has to declare it.

Two things move this file:

- **Telemetry.** `NSPrivacyCollectedDataTypes` is empty only while `kUseFirebase`
  is `false`. Turning crash reporting or analytics on adds entries here _and_
  changes the App Store privacy labels — see
  [#165](https://github.com/maximsan/brewpath/issues/165).
- **New plugins.** A plugin that ships its own `PrivacyInfo.xcprivacy` needs
  nothing from us; one that does not, and touches a required-reason API, has to
  be declared here. Today `package_info_plus`, `share_plus`, `stts`,
  `video_player_avfoundation` and `in_app_purchase_storekit` carry their own. The
  FlutterFire Dart packages do **not** — the manifests come from the underlying
  Google Firebase SDKs resolved over SPM.

- [ ] Before the first upload, read the App Store Connect response for
      `ITMS-91053` / `ITMS-91061` warnings about third-party SDKs. Every Google
      and plugin component in the bundle carries its own manifest **except
      `GoogleAppMeasurement` and `FirebaseAnalytics`**, whose xcframeworks ship
      none at the version we resolve — checked by hand in the `Runner.app` from
      `flutter build ios --release`. That is only a problem if Firebase ships at
      all, which is [#165](https://github.com/maximsan/brewpath/issues/165)'s
      call; the upload is the only place it can actually be confirmed. Note that
      `GoogleAdsOnDeviceConversion.framework` is linked in today purely as a
      dependency of `firebase_analytics`, in an app with no ads.

---

## 7. App Icons

- [ ] Create app icon at 1024×1024px (PNG, no alpha channel, no rounded corners — Apple applies the rounding)
- [ ] Use Xcode's asset catalog: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- [ ] Xcode will auto-generate all required icon sizes from the 1024px source if using Xcode 16 single-size icons
- [ ] Alternatively, use a tool like AppIconGenerator to produce all sizes manually

---

## 8. Launch Screen

- [ ] Edit `ios/Runner/Base.lproj/LaunchScreen.storyboard` in Xcode
- [ ] Minimum: app icon centered, solid background matching app primary color
- [ ] Avoid putting text on the launch screen (localization complications)
- [ ] Test launch screen on Simulator: Product → Run, observe launch screen during startup

---

## 9. Build for Release

```bash
# Increment build number for each submission
flutter build ios --release --build-number 1
```

- [ ] Run `flutter build ios --release` — no errors
- [ ] In Xcode: Product → Archive
  - Select `Any iOS Device (arm64)` as the destination (not a Simulator)
  - Wait for archive to complete
  - Organizer window opens automatically

---

## 10. TestFlight Distribution

- [ ] In Xcode Organizer: select the archive → Distribute App
- [ ] Select: App Store Connect
- [ ] Select: Upload (not Export)
- [ ] Options:
  - [ ] Include bitcode: NO (deprecated since Xcode 14)
  - [ ] Upload symbols: YES
  - [ ] Manage version and build number: YES
- [ ] Complete upload
- [ ] In App Store Connect → TestFlight → wait for processing (usually 5–15 minutes)
- [ ] Add internal testers (team members with Apple IDs added to App Store Connect)
- [ ] Submit for Beta App Review if adding external testers (1–2 day review)

---

## 11. App Store Submission Checklist

Before submitting for App Review:

**App Store Metadata:**

- [ ] App Name: BrewPath (max 30 characters)
- [ ] Subtitle: (optional, max 30 characters, e.g., "Learn Coffee Fundamentals")
- [ ] Description: (max 4000 characters — describe the app clearly)
- [ ] Keywords: (max 100 characters total — comma separated)
- [ ] Support URL: (required — can be a GitHub page, Notion page, or simple link)
- [ ] Marketing URL: (optional)
- [ ] Privacy Policy URL: (required for all apps)

**Screenshots:**

- [ ] At minimum: the two display sizes App Store Connect currently requires (check the current list — device classes churn yearly)
- [ ] Screenshots: 3–10 per device size
- [ ] Can be from Simulator with `File → Take Screenshot`

**App Review Information:**

- [ ] Notes for App Review: explain the app is a coffee education tool, no login required
- [ ] Demo account: not applicable (no login in MVP)

**Rating:**

- [ ] Complete the Content Rights and Rating questionnaire (MVP should be 4+)

**App Privacy:**

- [ ] Declare data collected: BrewPath MVP collects no user data — select "We do not collect data from this app"

**Pricing:**

- [ ] Free (MVP)

---

## 12. Version and Build Number Policy

| Field   | Location                          | Maps to                        |
| ------- | --------------------------------- | ------------------------------ |
| Version | `pubspec.yaml` → `version: X.Y.Z+N` | `X.Y.Z` (CFBundleShortVersionString) |
| Build   | `pubspec.yaml` → `version: X.Y.Z+N` | `N` (CFBundleVersion)          |

Increment the build number (`+1`, `+2`, etc.) for every upload to App Store Connect. The version string (`1.0.0`) changes only for user-facing releases.

---

## Definition of Done

- [ ] Apple Developer account is enrolled and agreements accepted
- [ ] App ID `dev.maximsan.brewPath` is registered in Developer Portal
- [ ] App record is created in App Store Connect
- [ ] Xcode code signing is configured with a valid Distribution certificate
- [ ] `Info.plist` has all required keys including `ITSAppUsesNonExemptEncryption = false`
- [x] `PrivacyInfo.xcprivacy` exists and is added to the Xcode target
- [ ] App icon at 1024×1024px is in the asset catalog
- [ ] `flutter build ios --release` completes without errors
- [ ] Archive uploaded to App Store Connect via Xcode Organizer
- [ ] Build appears in TestFlight and can be installed on a test device
- [ ] At least one internal tester has successfully installed the TestFlight build
