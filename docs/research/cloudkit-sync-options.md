# CloudKit on Flutter: what is actually available

Research for [issue #9](https://github.com/maximsan/brewpath/issues/9), child of the
v1-parity map [#6](https://github.com/maximsan/brewpath/issues/6).

**Scope.** v1 syncs progression via iCloud — no server, no accounts, no auth — so a
user who loses their phone keeps streak, tree, XP and collection. Firebase stays gated
off. This document establishes the options and recommends one; it does not relitigate
that product decision.

**Method.** Every Apple claim below is quoted from `developer.apple.com` (the DocC JSON
behind the rendered page, or the archived guide where the modern page is silent). Every
Dart claim was pulled live from the pub.dev API on 2026-07-29, not from recollection.
Where sources disagree, the disagreement is called out rather than smoothed over.

---

## 0. What the repo looks like today (matters for §2 and §4)

| Fact | Value | Source |
| --- | --- | --- |
| Bundle ID | `dev.maximsan.brewPath` | `ios/Runner.xcodeproj/project.pbxproj:396` — renamed from `dev.maximsan.coffeeQuest` by [#41](https://github.com/maximsan/brewpath/issues/41); this document's channel names and entitlement value were updated with it |
| iOS dependency manager | **Swift Package Manager only — there is no `ios/Podfile`** | `README.md:42-48`; `ls ios/` shows no Podfile; `project.pbxproj` has 8 `XCSwiftPackageProductDependency`/`XCLocalSwiftPackageReference` entries |
| iOS deployment target | 16.0 | `README.md:46` |
| Entitlements file | **none exists yet** (`find ios -name '*.entitlements'` → empty) | — |
| Dart SDK constraint | `>=3.8.0 <4.0.0`, Flutter `>=3.22.0`; toolchain in use is Flutter 3.44.1 / stable | `pubspec.yaml`, `flutter --version` |
| Persistence today | Drift (SQLite). `UserSettingsRecord` holds `totalXp`, `streakDays`, `lastActivityDate`; `ProgressRecord` holds per-lesson `isCompleted`, `xpEarned`, `bestScore`, `fullXpAwarded` | `lib/shared/storage/settings_record.dart`, `lib/shared/storage/progress_record.dart` |

The SPM-only fact is load-bearing and is the single biggest constraint on §2.

---

## 1. Which storage shape fits

### 1.1 The documented limits (get both numbers right)

`NSUbiquitousKeyValueStore` has **two independent limits plus a key cap**, and they are
frequently conflated. Verbatim from the current Apple docs
(<https://developer.apple.com/documentation/foundation/nsubiquitouskeyvaluestore>):

> Your app can have no more than **1024 keys** in the iCloud key-value store.
>
> The total amount of available storage space for all values is **1 megabyte**.
>
> The maximum size for a single value is **1 megabyte**. Therefore, if you associate 1
> megabyte of data with a single key, you can't write other keys to the store.
>
> The maximum length for each key string is **128 characters using the UTF-16 encoding**.
> Key strings don't count against the 1 megabyte quota for values.

And on overflow:

> If you exceed any of the prescribed limits during a write operation, the operation
> **fails and the system doesn't add the keys or values to the store**. If a key string
> exceeds the maximum length, the system raises an exception. If a write operation would
> exceed your app's quota, the system posts [`didChangeExternallyNotification`] with the
> change reason set to `NSUbiquitousKeyValueStoreQuotaViolationChange`.

So: **1 MB total, 1 MB per value, 1024 keys.** The per-value limit is *not* smaller than
the total — the two are the same number, and the per-value limit only bites because it
consumes the whole total.

**⚠️ Sources conflict on key length.** The archived *iCloud Design Guide*
(<https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/DesigningForKey-ValueDataIniCloud.html>)
says "The maximum length for a key string is **64 bytes using UTF8 encoding**", where the
current page says 128 characters UTF-16. The archive is retired documentation; the modern
page should win, but the safe engineering rule is **keep keys under 64 ASCII bytes** and
the discrepancy never matters. (The archive agrees exactly with the modern page on 1 MB
total / 1 MB per value / 1024 keys.)

Two further constraints from the same page:

> To use this object, you must **distribute your app through the App Store or Mac App
> Store**, and you must request the iCloud key-value store entitlement in your Xcode project.

> **Don't store personal or sensitive information** in the key-value store. The system
> stores the information on disk in an unencrypted format.

Both are fine here: the app is App Store-distributed, and a progression snapshot (XP,
streak, which lessons are done) is not sensitive data.

### 1.2 Realistic serialized size of the v1 snapshot

Measured, not guessed. Built from the real content IDs in `assets/content/lessons.json`
(25 lessons, mean ID length 18.7 chars, e.g. `lesson_where_coffee`) and
`assets/content/cards.json` (17 cards, mean ID length 16.2), with the full v1 field set
from the ticket: `streak`, `xp`, completed set (15), best-ever `{correct,total}` per
lesson, `frozenDays`, `freezesSpent`, ~40 prefixed favourite keys, 9 brew challenges,
plus/trial flags, plus `schemaVersion` / `updatedAt` / `deviceId` envelope.

| Payload | Compact JSON | gzipped | % of 1 MB quota |
| --- | --- | --- | --- |
| **v1 snapshot** | **2,345 bytes** | 718 bytes | **0.22 %** |
| v2 snapshot (all 25 lessons, all 17 cards favourited, + Atlas 15 origins with `states`/`favs`/`tastedFrom`, + Duel rating & 20-match history) | **4,583 bytes** | 1,049 bytes | **0.44 %** |

**Verdict: the key-value store is not merely comfortable, it is over-provisioned by
roughly 400×.** v1 would have to grow ~450× before it touched the quota. Even a
pessimistic v2 that ships every future subsystem at once lands under 0.5 %. Storing the
snapshot uncompressed as plain JSON in a `String` value is entirely safe; compression
would be premature optimisation. The 1024-key cap is irrelevant — the design below uses
fewer than ten keys.

### 1.3 What a CloudKit private database would buy, and cost

CloudKit is the heavier shape. Facts:

- A `CKRecord` is "a dictionary of key-value pairs"; CloudKit "provides **minimal offline
  caching support**" and "relies on the presence of the network"
  (<https://developer.apple.com/documentation/cloudkit>).
- "All access to the **private** and shared databases **requires an iCloud account**"
  (<https://developer.apple.com/documentation/cloudkit/ckdatabase>).
- Private-database storage is billed to *the user*, not the developer: `CKError.quotaExceeded`
  says "In the private database: **The user doesn't have enough iCloud storage.** Prompt
  the user to go to iCloud settings to manage their storage."
  (<https://developer.apple.com/documentation/cloudkit/ckerror/code/quotaexceeded>).
  So a user with a full 5 GB free tier can fail to sync 2 KB of progression — a failure
  mode `NSUbiquitousKeyValueStore` does not have at this size.
- CloudKit needs schema work in the CloudKit Console (record types, and a queryable index
  per record type before `getRecordsByType`-style reads work at all — see the setup notes
  in both `cloud_kit` and `flutter_cloud_kit` READMEs), plus a schema promotion from
  Development to Production before release.
- Adding the CloudKit service "also creates an iCloud container **and adds the Push
  Notifications capability**"
  (<https://developer.apple.com/documentation/cloudkit/enabling-cloudkit-in-your-app>) —
  a second capability, and for `CKSyncEngine` the remote-notifications entitlement too.

What it buys that KVS cannot: unbounded size, per-record change tags (§3), custom zones
with atomic multi-record writes
(<https://developer.apple.com/documentation/cloudkit/ckrecordzone>), sharing, and
`CKSyncEngine`. None of those are needed for a 2 KB snapshot with no sharing and no
server. **CloudKit is the right answer for a document/library app and the wrong answer
for a single settings blob.**

### 1.4 Third shape, for completeness: an iCloud Drive ubiquity-container file

Writing a JSON file into the app's iCloud Drive container is a real third option (and the
only shape with a well-maintained, SPM-native Flutter plugin — see §2). It is rejected
here because it inherits document-level conflict machinery (`NSFileVersion`, conflict
copies) for a payload that has none of a document's structure, and because it is visible
to the user in the Files app and deletable there, which silently breaks sync in a way
that looks like a bug. It also depends on iCloud **Drive** specifically being enabled,
whereas KVS does not (§4.3).

---

## 2. How Flutter reaches it

### 2.1 pub.dev survey — verified live, 2026-07-29

Queried via `https://pub.dev/api/packages/<name>` and `.../score`. "Legacy build" means
the pub.dev tag `is:darwin-legacy-native-build`, i.e. **CocoaPods podspec only, no
`Package.swift`**.

| Package | Latest | Last publish | Likes / points / 30-day downloads | Publisher | Wraps | Build |
| --- | --- | --- | --- | --- | --- | --- |
| [`icloud_kv_storage`](https://pub.dev/packages/icloud_kv_storage) | 0.0.1 | **2023-06-07** | 5 / 150 / 188 | **none (unverified)** | `NSUbiquitousKeyValueStore` ✅ | legacy |
| [`cloud_kit`](https://pub.dev/packages/cloud_kit) | 1.3.0 | 2024-09-14 | 33 / 140 / 92 | manuelschuler.dev | CloudKit `CKRecord` (string k/v) | legacy |
| [`flutter_cloud_kit`](https://pub.dev/packages/flutter_cloud_kit) | 0.0.3 | 2023-09-13 | 5 / 140 / 127 | fuelet.app | CloudKit `CKRecord` | legacy |
| [`icloud_kit_provider`](https://pub.dev/packages/icloud_kit_provider) | 1.5.0 | 2026-03-19 | **1** / 150 / 31 | **none (unverified)** | CloudKit database API | legacy |
| [`cloudkit_flutter`](https://pub.dev/packages/cloudkit_flutter) | 0.1.4 | **2021-08-11** | 3 / 130 / 49 | none | CloudKit **Web Services** (needs an API token / web auth — defeats "no auth") | n/a |
| [`icloud_storage`](https://pub.dev/packages/icloud_storage) | 2.2.0 | **2023-01-06** | 82 / 140 / 7,755 | none | iCloud **Drive files** | legacy |
| [`icloud_storage_sync`](https://pub.dev/packages/icloud_storage_sync) | 0.0.4 | 2026-04-02 | 45 / 150 / 482 | none | iCloud **Drive files** | legacy |
| [`icloud_storage_plus`](https://pub.dev/packages/icloud_storage_plus) | 4.0.0 | 2026-07-19 | 3 / **160** / 3,341 | jasonholtdigital.com | iCloud **Drive files** | **`is:swiftpm-plugin`** ✅ |
| [`universal_storage_cloudkit`](https://pub.dev/packages/universal_storage_cloudkit) | 0.1.0-**dev.1** | 2026-03-30 | 0 / 140 / 4 | none | CloudKit via a bridge | pre-release |
| [`remote_preferences`](https://pub.dev/packages/remote_preferences) | 1.0.0 | **2021-10-22** | 2 / 120 / 4 | none | abandoned; 1 version ever | legacy |

Null-safety / Dart 3: **all** of the above carry `is:null-safe` and `is:dart3-compatible`.
Two of them (`icloud_kv_storage`, `cloud_kit`) declare a pre-Dart-3 upper bound
`sdk: '>=2.12.0 <3.0.0'`, which looks like it would block resolution. I verified
empirically in a throwaway scratch package under `sdk: ">=3.8.0 <4.0.0"` that
`dart pub get` **does** resolve `icloud_kv_storage 0.0.1` — pub's legacy upper-bound
handling lets it through. So the constraint is not a blocker, but it is a maintenance
smell.

**Abandonment / bus-factor flags:**

- `icloud_kv_storage` — the only package that wraps the shape recommended in §1. **One
  version ever, published 2023-06-07, no verified publisher, one maintainer.** Its Dart
  surface is `writeString` / `getString` / `delete` / `onCloudKitKVUpdateCallBack`
  (strings only — no int/bool/data accessors, no `synchronize()`, no quota-violation
  reason exposed). Its Swift observes `didChangeExternallyNotification` but **silently
  drops** `NSUbiquitousKeyValueStoreAccountChange` and `…QuotaViolationChange`, forwarding
  only `ServerChange` and `InitialSyncChange`. Sign-out therefore reaches Dart as *nothing
  at all*. Verified against
  <https://github.com/JerryFans/icloud_kv_storage/blob/main/ios/Classes/CKKVStoragePlugin.swift>.
- `cloudkit_flutter` and `remote_preferences` — effectively abandoned (2021, single-digit
  downloads).
- `icloud_kit_provider` — brand new (first version 2026-03-13), 1 like, 31 monthly
  downloads, no publisher. Too green to depend on.
- `cloud_kit` is the healthiest CloudKit wrapper by likes, but it is GPL-3.0
  (`license:gpl-3.0` in its pub tags) — a licence a closed-source App Store app should not
  take on lightly.

### 2.2 The SPM constraint kills every candidate

This project is deliberately CocoaPods-free: `README.md:44` — "The iOS project uses
**Swift Package Manager**, not CocoaPods — there is no `ios/Podfile` and no `pod install`
step."

Flutter's own docs
(<https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers>):

> Note that Flutter falls back to CocoaPods for dependencies that don't yet support Swift
> Package Manager.
>
> Remember that the CocoaPods registry becomes read-only on **December 2, 2026** and
> disabling SwiftPM won't be allowed in the future.

Every KVS/CloudKit package in the table is `is:darwin-legacy-native-build`. Adopting any
one of them **reintroduces CocoaPods to this repo** — a Podfile, a `pod install` step,
`tool/reset_ios_spm.sh` becoming a half-truth, and CI on the macOS runner gaining a
dependency on a registry that goes read-only in four months. The only SPM-native option,
`icloud_storage_plus`, wraps the shape we rejected in §1.4.

### 2.3 Therefore: hand-written MethodChannel

`NSUbiquitousKeyValueStore` is roughly a 120-line Swift class. Written **into
`ios/Runner/` directly** (not as a plugin package), it needs no podspec, no
`Package.swift`, and no new pub dependency — the SPM-only invariant is preserved by
construction. It also lets us surface the two change reasons `icloud_kv_storage` drops,
which are exactly the ones §3 and §4 depend on.

Proposed surface — **method names and payload shape only, no implementation**:

```
MethodChannel  'dev.maximsan.brewPath/icloud_kv'
  isAvailable()                       -> { available: bool, reason: String? }
      // reason ∈ 'ok' | 'no_entitlement' | 'signed_out'
  getAll()                            -> Map<String, String>
  get({ key: String })                -> String?
  put({ key: String, value: String }) -> { ok: bool, error: String? }
  remove({ key: String })             -> { ok: bool }
  synchronize()                       -> bool
      // mirrors NSUbiquitousKeyValueStore.synchronize()'s Bool return

EventChannel   'dev.maximsan.brewPath/icloud_kv_events'
  emits { reason: String, changedKeys: List<String> }
      // reason ∈ 'server' | 'initialSync' | 'accountChange' | 'quotaViolation'
      // — the four NSUbiquitousKeyValueStoreChangeReasonKey constants, all four
      //   forwarded, including the two icloud_kv_storage swallows
```

`put` returns a result rather than `void` because a write that would exceed quota "fails
and the system doesn't add the keys or values to the store" — silently, from Dart's point
of view, unless the native side reports it.

Values are `String` (JSON) throughout: property-list types are supported natively but a
single encoding keeps the Dart side one `jsonDecode` away from a Freezed snapshot model,
matching the repo's existing content-model convention.

**Effort estimate:** the Swift is small; the cost is in §3's merge logic and §4's
provisioning, both of which are identical whichever route is taken. Choosing a package
saves perhaps a day of Swift and buys a CocoaPods migration plus a single-maintainer
dependency on the critical path of user data.

---

## 3. The conflict story

### 3.1 What `NSUbiquitousKeyValueStore` gives natively

The modern docs describe reconciliation only vaguely:

> When you write a new value, the iCloud key-value store saves it in memory initially and
> writes it to disk asynchronously later. If the device doesn't have an active Apple
> account, the changes remain only on the current device. When the person signs into their
> account, the system forwards any changes to the iCloud server and **reconciles the values
> there with the local ones**.
> (<https://developer.apple.com/documentation/foundation/nsubiquitouskeyvaluestore>)

The archived guide is the only Apple source that states the actual algorithm, and it is
**not plain last-writer-wins**:

> When a device attached to an iCloud account tries to write a value to key-value storage,
> iCloud checks to see if any recent changes have been made to the key-value store by other
> devices. **If no changes have been made recently**, the `NSUbiquitousKeyValueStore` object
> writes the pending local changes to the server. **If changes were made recently, it does
> not write the local values to the server.** Instead, it generates a
> `NSUbiquitousKeyValueStoreDidChangeExternallyNotification` notification to force your app
> to update itself based on the updated server values.
> (<https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/DesigningForKey-ValueDataIniCloud.html>)

Read that carefully: within the "recent" window it is **first-writer-wins with a callback**
— your local write is *dropped* and you are handed the server's values instead. Outside the
window it degrades to last-writer-wins. Apple never defines "recently". **This is the single
most important finding in this document: you cannot treat a successful `put` as durable.**
The same guide's own advice:

> When your handler for the `…DidChangeExternallyNotification` notification runs, validate
> the new values coming from the server to be sure that they make sense. If the new data
> does not match the local state of your app, consider whether data coming from another
> device might be out of date.

Native machinery available: the notification, `NSUbiquitousKeyValueStoreChangedKeysKey`
(which keys changed), and `NSUbiquitousKeyValueStoreChangeReasonKey`, whose value is one of
`ServerChange`, `InitialSyncChange`, `AccountChange`, `QuotaViolationChange`
(<https://developer.apple.com/documentation/foundation/nsubiquitouskeyvaluestore/didchangeexternallynotification>).

Native machinery **not** available: no version numbers, no change tags, no per-key
timestamps, no three-way merge, no "here is what you had before". You get "these keys are
now different" and nothing else.

Timing, from `synchronize()`
(<https://developer.apple.com/documentation/foundation/nsubiquitouskeyvaluestore/synchronize()>):

> This method **doesn't force the system to write new keys and values to iCloud**. Instead,
> it notifies iCloud that new keys and values are available. iCloud determines the best time
> to retrieve those keys and synchronize them with the person's other devices. Typically,
> **iCloud limits updates to several times per minute**.
>
> Don't rely on keys and values being available on the person's other devices immediately.
>
> Call this method sparingly … Typically, you call this method only at launch or when your
> app returns to the foreground.

### 3.2 What CloudKit gives natively

Materially better, and this is CloudKit's real selling point:

> Every time CloudKit saves a record, the server updates the record's change token to a new
> value. When you save your copy of the record, the server compares your record's token with
> the token on the server. If the two tokens match … it can apply your changes immediately.
> If the two tokens don't match, the server checks your app's save policy to determine how to
> proceed. (<https://developer.apple.com/documentation/cloudkit/ckrecord/recordchangetag>)

And on conflict, `CKError.serverRecordChanged` hands you a genuine three-way merge:

> CloudKit provides your app with **three copies** of the record in this error's userInfo
> dictionary … : The local record that the client's trying to save. : The record that exists
> on the server. : **The original version of the record.** When a conflict occurs, your app
> needs to merge all changes into the record for the [server record] key and attempt a new
> save using that record. Merging into either of the other two copies of the record results
> in another conflict error because those records have the old record change tag.
> (<https://developer.apple.com/documentation/cloudkit/ckerror/code/serverrecordchanged>)

`CKSyncEngine` (iOS **17.0+**, per the DocC availability metadata) automates scheduling,
subscription creation and transient-error retry — but explicitly **not** this:

> `CKSyncEngine` does **not** handle errors that require application-specific logic. For
> example, if you try to save a record and get a `serverRecordChanged`, **you need to handle
> that error yourself.**
> (<https://developer.apple.com/documentation/cloudkit/cksyncengine>)

It also "requires the CloudKit and Remote notifications entitlements", and persisting its
opaque state across launches is your responsibility.

### 3.3 What must be hand-written, either way

**The merge is hand-written in both worlds.** CloudKit gives you a better *detector*
(change tags, a common ancestor) and a better *scheduler*; it does not give you a merge
policy. So the delta between the two options on conflict is: CloudKit hands you the
common ancestor, KVS does not. For a snapshot whose fields are individually mergeable
without an ancestor (below), that delta is small.

Required regardless:

1. A versioned envelope — `schemaVersion`, `updatedAt`, `deviceId` — which map #6 already
   mandates ("a **versioned, serializable snapshot with `updatedAt`**").
2. A **field-typed merge function**, pure Dart, unit-testable without any iCloud at all.
3. Treating every remote arrival as a merge input, never as an assignment.
4. Re-publishing the merged result (both devices converge on the union, not on whoever
   spoke last).

### 3.4 Which fields are monotonic — the merge table

This is where the app's shape pays off. Most of the snapshot merges without an ancestor:

| Field | Merge rule | Why |
| --- | --- | --- |
| `xp` | **max** | monotonic; only ever awarded, never revoked |
| best-ever mastery `{correct,total}` per lesson | **max by accuracy ratio**, tie-break higher `total` | "best-ever" is monotonic by definition |
| tree stage | **derive, don't sync** | a pure function of merged `xp` + `completed`; syncing it invites disagreement with its own inputs |
| lifetime `freezesSpent` | **max** | ticket states it is lifetime-cumulative (`brew-path/app.jsx:426` — "how many have ever been spent") |
| `completed` lesson set | **union** (grow-only set) | a completed lesson never un-completes |
| brew-challenge state (9) | **max by rank**, per challenge | the prototype already does exactly this for Atlas: `Math.max(cur, targetRank)` at `brew-path/app.jsx:280` |
| `frozenDays` | **union**, then prune to the current week | additive within a week |
| `favourites` | **LWW on the whole field by `updatedAt`** | ⚠️ **not** monotonic — un-favouriting is a first-class action (`brew-path/app.jsx:257`), so a union would resurrect deleted favourites forever |
| `streak` / `lastActivityDate` | **max on `lastActivityDate`, then recompute `streak`** | ⚠️ **not** monotonic. Max-wins on `streak` is a real bug: a device that has been offline since a 40-day streak broke would beat a device that correctly reset to 1. Only the activity date is safe to merge |
| plus / trial flags | **don't sync** | StoreKit 2 on-device verification is authoritative (map #6: "StoreKit 2 verifies on-device"). Syncing an entitlement flag through an unencrypted, user-writable store is a piracy vector |

The upshot: **only two fields need last-writer-wins, and one field needs recomputation.**
Everything else is a lattice join and converges regardless of arrival order — which is
precisely what makes KVS's weak native story survivable.

**Key sharding.** Because KVS reports *which keys* changed, splitting the snapshot into a
handful of keys buys coarse field-level conflict granularity for free — e.g.
`cq.v1.core` (xp, streak, lastActivityDate, freezes), `cq.v1.lessons` (completed +
bestResults), `cq.v1.favourites`, `cq.v1.brew`. A user grinding lessons on one device and
curating favourites on another then never collides at all. Four keys of ~600 B each,
against a 1024-key / 1 MB budget.

---

## 4. Edge costs

### 4.1 Entitlement and capability setup

For **key-value storage only**, exactly one entitlement is needed:
`com.apple.developer.ubiquity-kvstore-identifier` — "The container identifier to use for
iCloud key-value storage. To add this entitlement to your app, **enable the iCloud
capability and 'Key-value storage' service in Xcode**"
(<https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.ubiquity-kvstore-identifier>).
Conventional value: `$(TeamIdentifierPrefix)dev.maximsan.brewPath`.

Notably **not** needed for the KVS route: `com.apple.developer.icloud-container-identifiers`,
the CloudKit service, and Push Notifications. Choosing CloudKit instead pulls all three in
— "Select the CloudKit checkbox. In addition to adding the CloudKit capability to your app,
this selection **also creates an iCloud container and adds the Push Notifications
capability**"
(<https://developer.apple.com/documentation/cloudkit/enabling-cloudkit-in-your-app>).

Concretely for this repo: there is **no `Runner.entitlements` file today**, so one must be
created and wired into `CODE_SIGN_ENTITLEMENTS` for both Debug and Release configurations —
a genuinely new build-settings surface, and the most likely source of a "works locally,
fails in CI" incident.

### 4.2 Provisioning-profile implications

- A **paid, active membership with admin rights** is required: "verify that your Apple
  Developer Program membership is active and has **admin permissions**" (same page).
- iCloud requires an **explicit App ID** — the App ID registration help says "A checkbox is
  disabled if the technology requires an explicit App ID and you're creating a wildcard App
  ID" (<https://developer.apple.com/help/account/identifiers/register-an-app-id/>), and the
  archived QA1713 frames wildcards as "for use with code signing all apps that **do not
  enable app-specific capabilities**"
  (<https://developer.apple.com/library/archive/qa/qa1713/_index.html>). `dev.maximsan.brewPath`
  is already explicit, so nothing changes here.
- Enabling the capability invalidates existing profiles: "Enabling a capability will
  **affect provisioning profiles for all eligible platforms**"
  (<https://developer.apple.com/help/account/identifiers/enable-app-capabilities/>). All
  profiles must be regenerated. **If CI signs with a checked-in or fastlane-matched profile,
  that profile must be regenerated and re-uploaded, or the iOS build job breaks on the
  commit that adds the entitlement.** Automatic signing in Xcode handles it locally and
  hides the problem until CI runs.
- The capability page also asks you to choose "Compatible with Xcode 5" vs "Include CloudKit
  support" — pick the former for a KVS-only app; picking CloudKit support commits you to
  container management you don't need.

### 4.3 Signed out of iCloud / iCloud Drive disabled

**Key-value store — degrades gracefully, by design.** Apple:

> If the device doesn't have an active Apple account, **the changes remain only on the
> current device.** When the person signs into their account, the system forwards any
> changes to the iCloud server and reconciles the values there with the local ones.

So the store keeps functioning as a local dictionary and back-fills on sign-in. Two
consequences to handle:

1. On sign-in (or account switch) the app receives `…AccountChange`, and typically an
   `…InitialSyncChange` carrying the new account's values. **`AccountChange` must wipe the
   in-memory sync state and re-run the merge from scratch** — otherwise account B inherits
   account A's streak. This is the reason to hand-write the channel: `icloud_kv_storage`
   drops this reason entirely.
2. KVS is *not* documented as depending on the iCloud **Drive** toggle specifically (that
   toggle governs the ubiquity document container). Apple's simulator setup instructions do
   mention enabling iCloud Drive
   (<https://developer.apple.com/documentation/cloudkit/enabling-cloudkit-in-your-app>), and
   there is a per-app iCloud toggle in Settings that users can switch off. **Treat "iCloud
   unavailable for any reason" as one state**, detected by probing rather than inferred from
   a specific setting — Apple does not document a first-class "is KVS available" query, which
   is why the proposed `isAvailable()` returns a reason string rather than a bare bool.

**CloudKit — does not degrade.** "All access to the private and shared databases requires an
iCloud account", and it "provides minimal offline caching support" and "relies on the
presence of the network". Every call must be guarded on `CKAccountStatus`, and the offline
cache is yours to build. This is more code, not less, for the "must never break" requirement.

Either way, **Drift stays the source of truth and the app never blocks on sync.** iCloud is
a mirror, not a dependency.

### 4.4 Simulator vs real device

Documented, for CloudKit:

> Perform the same sign-in process **for each iOS or iPadOS simulator you test your app on.**
> (<https://developer.apple.com/documentation/cloudkit/enabling-cloudkit-in-your-app>)

So a signed-in simulator is a supported CloudKit client.

**Not documented, for KVS.** ⚠️ I could not find an Apple statement about
`NSUbiquitousKeyValueStore` behaviour in the Simulator either way, and I am flagging that
rather than asserting a folk belief. What exists is practitioner report — including from the
maintainer of the one KVS plugin: "It is recommended to use **real device testing** for iOS
devices as the **iOS simulator may not synchronize in real-time**"
(<https://github.com/JerryFans/icloud_kv_storage#usage>). Apple's own throttling note
("iCloud limits updates to several times per minute", "don't rely on … immediately") means
even on device, propagation is seconds-to-minutes and not a stable basis for automated tests.

Practical split:

| Testable in the Simulator | Requires two real devices |
| --- | --- |
| The merge function (pure Dart — the bulk of the risk, and the bulk of the tests) | Actual cross-device propagation and latency |
| Channel plumbing against a fake native side | The offline-divergence scenario end-to-end |
| Local read/write/delete, entitlement-missing failure path | `AccountChange` on real sign-out/sign-in |
| Degraded/signed-out UI states, driven by a fake | Quota-violation behaviour (impractical to provoke at 0.2 % usage) |

Design consequence: **push everything decidable into a pure `mergeSnapshot()` in a sibling
pure-Dart file**, per the repo's "extract pure helpers" rule, so the untestable part is a
thin, boring transport.

---

## RECOMMENDATION

### Storage shape — `NSUbiquitousKeyValueStore`, sharded across ~4 keys

**Reasoning.** The payload is 2.3 KB measured, 0.22 % of the documented 1 MB total / 1 MB
per-value quota, using 4 of 1024 available keys. Even a v2 carrying Atlas and Duel lands at
4.6 KB (0.44 %). It needs no container, no schema, no CloudKit Console setup, no Development→
Production schema promotion, no Push Notifications capability, and no `CKAccountStatus`
guards on every call — and it is the only shape that **keeps working while signed out** and
back-fills on sign-in, which is exactly the "must degrade to local-only, never break"
requirement. It also cannot fail because the *user's* iCloud storage is full, which
`CKError.quotaExceeded` says a private-database write can.

**Strongest counter-argument.** It is a dead end if the data outgrows it. If a v3 ever wants
per-lesson attempt history, mistake logs, or user-generated tasting notes with photos, 1 MB
is nothing and the whole layer is rewritten against CloudKit. The honest mitigation is the
versioned envelope map #6 already mandates: a snapshot with `schemaVersion` and a pure merge
function is transport-agnostic, so the migration replaces a ~120-line Swift file and keeps
every line of merge logic and every test. Second-order: KVS is stored unencrypted, so it can
never hold anything sensitive — acceptable today, a hard ceiling if the product ever adds
account-like data.

### Integration route — hand-written `MethodChannel` + `EventChannel` in `ios/Runner/`

**Reasoning.** Every KVS/CloudKit package on pub.dev is `is:darwin-legacy-native-build`
(CocoaPods-only). This repo has **no `Podfile` by deliberate choice** (`README.md:44`), and
Flutter's docs confirm an app is CocoaPods-free only if *all* plugins support SPM — with the
CocoaPods registry going read-only **2026-12-02**. So adopting a package trades ~120 lines of
Swift for a build-system regression on a deprecation clock. The one candidate that wraps the
right API, `icloud_kv_storage`, is additionally: one version ever, June 2023, no verified
publisher, strings-only, and it **silently drops the `AccountChange` and `QuotaViolationChange`
reasons** — the two signals §3 and §4.3 depend on. Writing the channel into `Runner` (not as a
plugin package) needs neither podspec nor `Package.swift`.

**Strongest counter-argument.** It puts Swift on the critical path of user data in a
Flutter-first team, and Swift in `Runner/` is outside the reach of `flutter test`,
`very_good_analysis` and the repo's lint gates — an untested blind spot in the most
data-destructive layer of the app. Mitigation: keep the Swift dumb (no policy, no merging,
pure transport with all four change reasons forwarded verbatim), keep every decision in
`mergeSnapshot()` in pure Dart, and cover the channel with a fake platform handler in widget
tests. If that discipline slips, `icloud_kv_storage` remains a viable fallback at the cost of
reintroducing CocoaPods.

### Conflict rule — field-typed merge on a versioned snapshot; LWW only where forced

Formally: on every remote arrival, `merged = mergeSnapshot(local, remote)` where

- **union** — `completed`, `frozenDays` (then prune to current week)
- **max** — `xp`, `freezesSpent`, per-lesson best mastery (by accuracy ratio), brew-challenge
  rank
- **derive, never sync** — tree stage (from merged `xp` + `completed`); plus/trial (from
  StoreKit 2)
- **max on `lastActivityDate`, then recompute** — `streak`
- **last-writer-wins by `updatedAt`** — `favourites` only

then write `merged` back locally *and* re-publish it, so both devices converge on the join
rather than on whoever spoke last.

**Reasoning.** KVS gives you no change tags and no common ancestor — but it does not need to,
because the app's values are overwhelmingly monotonic and a join over a lattice converges
regardless of arrival order. Crucially, Apple's own description of KVS reconciliation is *not*
plain last-writer-wins: within an undefined "recent" window, a local write is **dropped** and
replaced by the server's values. A merge-on-arrival design is the only one that is correct
under that behaviour, and it is also the only one that survives the case that motivates the
whole feature — a user restoring on a new phone must not lose a streak by "winning" a clock
race. Two named traps are handled explicitly: `streak` must **not** be max-merged (a stale
device with a broken 40-day streak would beat a correctly-reset device), and `favourites` must
**not** be unioned (un-favouriting is a real action and a union resurrects deletions forever).

**Strongest counter-argument.** Max-wins is un-undoable. There is no "reset my progress" that
survives a second device — one stale device re-floods the old maximum, and a support request
to zero someone's XP becomes unanswerable. It also silently launders bugs: an XP-inflation
defect shipped once is permanent, because no later correction can lower a max. Mitigations:
scope every max-merge under an explicit `resetGeneration` counter in the envelope that a
deliberate reset increments and that dominates all other rules; and gate the merge on
`schemaVersion` so a future correction can re-derive rather than join. Both are cheap now and
expensive to retrofit — they belong in the first version of the envelope, not the second.
