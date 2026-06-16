# Coffee Quest — Flutter Learning Curriculum

Two features, built end-to-end **by the learner**, each teaching a different
slice of the stack. Build order: **B then A** — B adds the favorites feature with
in-memory state (navigation focus); A then makes those favorites durable
(persistence focus).

Status legend: ☐ todo · ◐ in progress · ☑ done · 👉 current step

---

## Phase B — "Favorites tab" (navigation slice)

Teaches: class-based Riverpod + codegen, go_router nested routes & ordering,
derived providers, `AsyncValue` UI, empty/loading/error states.

- ☑ **B1 — Favorite state.** `FavoriteCards` controller in
  `lib/features/cards/domain/favorite_cards_provider.dart`: in-memory
  `Set<String>`, `toggle`, `isFavorite`. _Done 2026-06-13 — reworked to use the
  Notifier's `state` as the single source of truth, `@Riverpod(keepAlive: true)`,
  `void toggle` with immutable spread updates, renamed to `FavoriteCards` →
  `favoriteCardsProvider`._
- ☑ **B2 — Toggle UI.** Heart `IconButton` on `card_detail_screen.dart` AppBar.
  _Done 2026-06-16 — correct `watch state` / `read notifier` split, tooltip a11y,
  extracted badge constants. Known follow-up: inline `FutureBuilder` Future in
  `build` flickers the body on each toggle now that the screen rebuilds — fixed
  in B3 via a `cardById` provider._
- ☑ **B3 — Derived providers.** `favoriteCardsList` + `cardById` (family) in
  `cards_providers.dart`. _Done 2026-06-16 — correct reactive chain; rewired
  `card_detail_screen.dart` to `ref.watch(cardByIdProvider(cardId)).when(...)`,
  which removed the inline-Future flicker; cleaned up unused imports._
- 👉 ☐ **B4 — Favorites screen.** New `FavoritesScreen` (`ConsumerWidget`)
  rendering `favoriteCardsList`, with proper loading / empty / error states. Use
  `/flutter-mobile-design`; add `Semantics` labels and respect reduced motion.
- ☐ **B5 — Wire the route.** Nested `GoRoute` under `/cards` — declare the static
  `favorites` route **before** `:cardId` so the param doesn't capture
  "favorites". Add `RouteNames.favorites` + an `AppStrings` label; reach it via an
  AppBar action on `CardsScreen` using `context.goNamed('favorites')`.

## Phase A — "Persist favorites" (persistence slice)

Teaches: Drift schema change, migration, `drift_dev` codegen + schema snapshots,
repository + DTO mapping, a mutable controller backed by storage, provider
invalidation.

- ☐ **A1 — Schema.** Add a `FavoriteCardRecords` table (unique `cardId`) in
  `shared/storage/app_database.dart`; bump `schemaVersion`; add the `onUpgrade`
  migration step.
- ☐ **A2 — Codegen + schema snapshot.** `dart run build_runner build`, then the
  drift schema `dump`/`generate` workflow documented in `README.md`.
- ☐ **A3 — Repository.** `FavoriteCardRepository` mirroring `card_repository.dart`
  (list IDs, insert-or-ignore toggle, delete-all); register it in
  `repository_providers.dart`.
- ☐ **A4 — Back the controller with Drift.** Make `FavoriteCards.build()` load
  from the repo (now async → `Set<String>` becomes `Future`/`AsyncValue`), and
  `toggle` persist + refresh; add it to the Profile "Reset Progress" invalidation
  set.
- ☐ **A5 — Migration test.** Add a previous→new schema migration test using the
  `SchemaVerifier` pattern (see `test/database/`).
- ☐ **A6 — Cleanup.** `/improve-code` pass on the feature; `/changelog` to log it.

---

## Progress log

- **2026-06-13** — Kicked off the track. Gave full codebase onboarding; learner
  chose to build **B then A**. Learner implemented **B1**
  (`favorite_cards_provider.dart`) and ran `build_runner`. Review found the
  provider keeps a parallel private `_favorites` field and never assigns `state`,
  so it is non-reactive (a watching UI would always see an empty set); `toggle`
  is needlessly `async`; the class name `FavoriteCardsProvider` generates the
  doubled `favoriteCardsProviderProvider`; and `keepAlive` is missing. Captured as
  the B1 rework note. (Sandbox killed `flutter analyze`'s analysis server, code
  -9 — review done by reading the source + generated output.) **Next: B1 rework.**
- **2026-06-13** — B1 reworked and verified correct (generated `favoriteCardsProvider`,
  `isAutoDispose: false`). Covered the identity-based `updateShouldNotify`
  mechanism behind immutable `state` updates. **Next: B2 (toggle UI).**
- **2026-06-16** — Project restructured: Flutter app moved from `coffee_quest/` to
  the repo root (`lib/`, `pubspec.yaml`, `ios/` at `brewpath/`). Fixed the
  `coffee_quest/` path references in the learning docs + the `CLAUDE.md` learning
  pointer. (Root `CLAUDE.md` "Project Layout" / "run commands from coffee_quest/"
  still stale — flagged to user.) B2 verified done; covered `AppSpacing` token
  swap + the "never build a Future inside `build()`" rule. **Next: B3.**
- **2026-06-16** — B3 verified done (codegen emitted `favoriteCardsListProvider` +
  `cardByIdProvider` family). Flicker fixed via cached provider read. Covered
  family providers (arg as cache key) and why `ref.watch` of a provider beats an
  inline `FutureBuilder`. **Next: B4 (Favorites screen) — pull in
  `/flutter-mobile-design`.**
