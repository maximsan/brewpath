# Scope: what ships in v1

> Part of the [BrewPath v1 design reference](README.md). All source paths are relative to `brew-path/`.


Locked in `v1 Readiness Audit.html` (June 2026, reconciled July 2026) and enforced by `isV1` in code.

## Counted by route

`SCREEN_ROUTES` holds **103 deep-link states**, of which **34 are `!isV1`**:
onboarding questions (8) · Atlas (10) · Duel (13) · trials (2) · mood player (1).
That leaves **69 v1 routes**.

Routes are not screens. Of the 69, **20 open the lesson player** at a given card
kind and **7 open the mini-game flow** — deep-link conveniences, not distinct
destinations. Collapsing those leaves roughly **44 distinct v1 destinations**.

> The previous "≈38 screens of ~64 built" could not be reproduced from any
> countable thing in the source and has been replaced by the route arithmetic
> above, which can. Treat "44" as *destinations you can navigate to*, not as a
> screen-file count.

## In v1
| Area | Notes |
|---|---|
| App intro | Welcome + Meet Roasty. Content only, no questions. |
| Learn + Path + Lesson player | The core loop. |
| Rewards + collectible cards | Lesson complete (3 variants), module complete, collectible card, module challenge. |
| Profile + progress + Settings | Profile, tree, streak, settings, about, help, account, subscription. |
| Coffee Dictionary | Home, term, term-locked, term-reference, term-of-day, flashcards, vocab game, peek sheet. |
| Plus + Studio + Saved | Paywall, Plus welcome, Studio hub, tree chooser, Roasty studio, Saved shelf. |
| Brew Challenge | Today card (3 states), log sheet, recap sheet, module challenge screen, path nodes, card stamps. |

## Deferred to v2 (built, but switched off)
| Feature | Routes | Why deferred |
|---|---|---|
| **Coffee Atlas** | 10 | Second content vertical: 15 origins, activities, regions, passport, stamps. Needs as much writing/art as the course. |
| **Coffee Duel** | 13 | Async social. Needs share + server infra: invites, pending/expired/error, rematch, link resolution, result sync. |
| **Rewarded ads + timed trials** | 2 | Needs an ad SDK. Includes the perfect-module gift unlock. |
| **Onboarding question flow** | 8 | Nothing reads the answers in v1. Welcome + Meet Roasty stay. |
| **Mood player** | 1 | Delightful extra; ships with Studio depth in v2. |
| Cosmetic IAPs, weekly-goal setting, data export | — | Explicitly deferred. |
| Lifetime tier, paid streak protection | — | **Dropped, not deferred.** Reasons recorded in the audit. |
| **Four future course modules** — Espresso Basics · Milk Drinks · Brewing Gear · Coffee Tasting | 0 built | Not built at all, but **named to users** on the Path tab by `ComingSoonPath` ([§4](04-information-architecture.md)). Unwritten content, not switched-off code. Two lessons have been pulled forward out of them into v1 ([§4](04-information-architecture.md)). |

## Tab bar
**v1: four tabs — Learn · Path · Cards · Profile.** Atlas is removed from the tab bar (`app.jsx` force-redirects `tab === 'atlas'` back to `learn`). Dictionary and Saved stay as pinned top-right header entries.

---

← [Product in one paragraph](01-product.md) · [Contents](README.md) · [Design system](03-design-system.md) →
