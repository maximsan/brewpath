# BrewPath — Future Android & Web Plan

## What Is Already Portable

The following components require **no changes** to run on Android or Web:

| Component | Portable? | Notes |
|---|---|---|
| Dart business logic | Yes | Pure Dart — platform-agnostic |
| Riverpod providers | Yes | Works on all platforms |
| go_router navigation | Yes | Has built-in URL strategy for web |
| Content models (Freezed) | Yes | Pure Dart |
| ContentRepository (JSON assets) | Yes | `rootBundle` works everywhere |
| XpService, StreakService | Yes | Pure Dart |
| LessonCompletionService | Yes | Pure Dart |
| Mini-game widgets | Yes | Standard Flutter widgets |
| All feature screens | Yes | Material widgets work on Android and web |
| Firebase Analytics | Yes | FlutterFire supports all platforms |
| Firebase Crashlytics | Yes | FlutterFire supports Android; web uses Firebase Hosting errors |

---

## What Needs Platform-Specific Work — Android

### Build System

- [ ] Add Android platform: `flutter create --platforms android .` from project root
- [ ] Set `minSdkVersion` / `targetSdkVersion` in `android/app/build.gradle`
      to whatever the Firebase plugins and Google Play require **at sprint
      time** — hardcoded API levels in a someday-doc are guaranteed to rot, so
      none are recorded here

### Firebase Android

- [ ] Register Android app in Firebase Console with package name `dev.maximsan.brewPath`
- [ ] Download `google-services.json`
- [ ] Place `google-services.json` at `android/app/google-services.json`
- [ ] Apply Google Services Gradle plugin in `android/build.gradle` and `android/app/build.gradle`
- [ ] Verify Crashlytics and Analytics initialize on Android

### Local Persistence — Drift

- [ ] `sqlite3_flutter_libs` (already a dependency) ships the Android native binaries — no extra package needed
- [ ] Verify `AppDatabase` opens on the Android Emulator — no code changes required
- [ ] Run `flutter test integration_test/ -d emulator-5554` and confirm smoke test passes

### App Signing — Android

- [ ] Create a keystore file: `keytool -genkey -v -keystore brew_path.jks`
- [ ] Store keystore in a secure location (NOT in the repo)
- [ ] Configure signing in `android/app/build.gradle`:
  ```gradle
  signingConfigs {
    release {
      keyAlias keystoreProperties['keyAlias']
      keyPassword keystoreProperties['keyPassword']
      storeFile file(keystoreProperties['storeFile'])
      storePassword keystoreProperties['storePassword']
    }
  }
  ```
- [ ] Create `android/key.properties` (gitignored) with the keystore credentials

### Google Play Store Setup

- [ ] Create Google Play Developer account: [play.google.com/console](https://play.google.com/console) — one-time $25 fee
- [ ] Create new app in Google Play Console
- [ ] Build an AAB: `flutter build appbundle --release`
- [ ] Upload to Internal Testing track first
- [ ] Progress through Internal Testing → Closed Testing → Open Testing → Production

### Ads on Android

- [ ] Register Android app in AdMob console
- [ ] Add AdMob App ID to `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
  ```

### Android CI Matrix Addition

Add an `android-build` job to `.github/workflows/ci.yml` by **cloning the
shape of the existing `ios-build` job** (same checkout / flutter-action /
`pub get` steps, same pinned `FLUTTER_VERSION` env — no build_runner step,
generated files are committed). The only Android deltas:

- write `android/app/google-services.json` from a `GOOGLE_SERVICES_JSON`
  secret (only once Firebase is active)
- build with `flutter build apk --debug`

(An earlier revision embedded a full YAML template here; it rotted against the
real workflow — the live `ci.yml` is the only template worth cloning.)

---

## What Needs Platform-Specific Work — Web

### Build System

- [ ] Add web platform: `flutter create --platforms web .` from project root
- [ ] Test build: `flutter build web --release`

### Local Persistence — Drift on Web

The app already uses **Drift (SQLite)**, which **supports Flutter Web** via Drift's
WASM backend — so the persistence layer does **not** need replacing for web. (This
was the main blocker under the old Isar design; the Phase 3 move to Drift resolved
it.) The repository layer (`lib/shared/repositories/`) stays unchanged.

- [ ] Bundle the web assets (`sqlite3.wasm` + `drift_worker.js` under `web/`) per
      the Drift "Web" docs
- [ ] Give `AppDatabase` a web `DatabaseConnection` (`WasmDatabase`) via a
      conditional import; mobile keeps `NativeDatabase`
- [ ] Verify reads/writes + the integration smoke test pass under
      `flutter run -d chrome`

### go_router Web URL Strategy

- [ ] Enable path-based URLs (remove `#` from URL):
  ```dart
  // In app_router.dart
  GoRouter(
    routerNeglect: false,
    // go_router handles URL strategy automatically in Flutter web
  )
  ```
- [ ] In `web/index.html`: verify `<base href="/">` is present

### Firebase Web

- [ ] Register web app in Firebase Console
- [ ] Add Firebase SDK configuration to `web/index.html` (Firebase auto-generates this)
- [ ] `firebase_options.dart` already includes the `web` platform entry after `flutterfire configure` (add `--platforms web`)

### Web Deployment

- [ ] Build: `flutter build web --release`
- [ ] Deploy to Vercel, Firebase Hosting, or Cloudflare Pages
- [ ] For Vercel: `vercel deploy` from project root (detects Flutter web automatically via `flutter build web`)

---

## Architecture Decisions That Preserve Portability

These decisions were made in the iOS MVP specifically to avoid platform lock-in:

| Decision | Why it preserves portability |
|---|---|
| Riverpod for all state | Works on all Flutter platforms |
| go_router for navigation | Designed for multi-platform; built-in URL support |
| Repository pattern over Drift | Persistence impl can be swapped without touching features |
| Service abstraction for Firebase | Web Firebase SDK is injected; mobile native SDK is injected — same interface |
| Dart Freezed models | Pure Dart, no platform dependencies |
| Assets for content (no native DB) | `rootBundle` works everywhere |
| No iOS-specific Swift code in business logic | All business logic in Dart |

---

## Android Implementation Checklist

Complete these when Android sprint begins:

- [ ] Run `flutter create --platforms android .`
- [ ] Set `minSdkVersion = 21` in build.gradle
- [ ] Register Android app in Firebase Console and add `google-services.json`
- [ ] Verify `AppDatabase` (Drift) opens on Android Emulator
- [ ] Verify Firebase Analytics events appear in DebugView on Android
- [ ] Create keystore and configure signing
- [ ] Build AAB: `flutter build appbundle --release`
- [ ] Create Google Play Console app
- [ ] Upload to Internal Testing
- [ ] Add Android CI job (see template above)
- [ ] Add `GOOGLE_SERVICES_JSON` GitHub secret

---

## Web Implementation Checklist

Complete these when web sprint begins:

- [ ] Run `flutter create --platforms web .`
- [ ] Wire Drift's WASM backend for web (bundle `sqlite3.wasm` + `drift_worker.js`; conditional `AppDatabase` connection — no repository changes needed)
- [ ] Register web app in Firebase Console
- [ ] Run `flutterfire configure --platforms ios,android,web` to update `firebase_options.dart`
- [ ] Test `flutter build web --release` locally
- [ ] Verify all 4 tabs render correctly in Chrome
- [ ] Verify all mini-game types work in browser (Draggable/DragTarget — test on touch screen too)
- [ ] Deploy to staging environment
- [ ] Configure SEO metadata in `web/index.html`

---

## Definition of Done (for each platform)

**Android is "done" when:**
- [ ] App launches on Android Emulator without errors
- [ ] All mini-game types function correctly on Android
- [ ] Firebase Analytics and Crashlytics work on Android
- [ ] Drift persistence works on Android
- [ ] App is published to Google Play Internal Testing track
- [ ] Android CI job passes in GitHub Actions

**Web is "done" when:**
- [ ] App runs in Chrome and Safari
- [ ] All 4 tabs render correctly
- [ ] Progress persists across browser sessions
- [ ] go_router URL strategy works (no `#` in URLs)
- [ ] App is deployed to a staging URL
