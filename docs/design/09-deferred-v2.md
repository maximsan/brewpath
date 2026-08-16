# Deferred features — detail (for v2 tickets)

> Part of the [BrewPath v1 design reference](README.md). All source paths are relative to `prototype/`.


## Coffee Atlas (`atlas*.jsx`, ~1,600 lines, 10 screens)
- **15 origins**: Ethiopia, Kenya, Rwanda, Yemen · Colombia, Brazil, Peru, Guatemala, Costa Rica, Honduras, Mexico, Panama · Indonesia, India, Vietnam
- Rich per-origin data: tag, intro, growing regions, altitude, climate, species, varieties, processing, harvest window, history, flavour note + tags, sources, review date, and one activity
- **4 exploration ranks**: `not-explored → discovered → lesson → tasted`. Tasting is a reversible toggle that remembers the prior rank.
- **4 activity types**: Identify the origin · Match them up · Locate on the map · Compare two origins
- Custom SVG world map (1000×560) with tropic/equator lines, 2 style modes (`geo` / stylised), origin markers, peek sheet
- Region screens (Africa / Americas / Asia), Passport with animated stamp-press overlay, filter sheet, empty state

## Coffee Duel (`duel*.jsx`, ~1,300 lines, 13 screens)
- **5 duel types** × 5 questions each = 25 questions: Coffee basics · Origin detective · Brew order · Taste match · Processing
- Async head-to-head: hub (with incoming/sent sections), picker (grid/list variants), play, result (tally/instant reveal variants), invite + share, sent, received, comparison (win/loss), rematch, expired, error
- Persists an in-flight run so a duel can be resumed
- **Needs:** share sheet, deep-link resolution, server for invites and result sync

## Rewarded ads + timed trials
`RewardedAdScreen` (simulated video → 15-min unlock), `RoastyGiftScreen` (perfect-module → 24-h Studio unlock), `TrialBadge` countdown. Needs an ad SDK.

## Onboarding question flow
6 question screens + expectation + closing. Fully built; nothing consumes the answers yet.

## Mood player
Roasty centred, tap an emotion to see the reaction, 5 backdrops.

## Liberica tree art
`TREE_VARIETIES.liberica` carries `drop: 'later'` — the species is authored and selectable in code but is waiting on its own silhouette art ([§6.7](06-content.md)).

---

← [Flows](08-flows.md) · [Contents](README.md) · [Assets](10-assets.md) →
