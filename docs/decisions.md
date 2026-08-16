# BrewPath — confirmed product decisions

> **❄️ Frozen — 2026-08-16.** This file is a historical ledger and never grows
> again, not even agent notes. New rulings — product and engineering alike —
> are recorded as ADRs in [`docs/adr/`](adr/README.md); the argument happens in
> the owning issue, the record lands there. The `§` numbering below is stable
> and stays citable. (This file was `docs/decisions-1.md` until Aug 2026 —
> links in older issues use that name.)

1. Foundations and ongoing practice
   Beginner Foundations is a finite five-module beginner course.
   Completing Foundations must have a proper ending and celebration.
   After Foundations, the main Today recommendation changes to Keep Sharp.
   Keep Sharp recommends one existing practice format; it is not a new multi-activity lesson.
   No countdown, minimum practice duration, or tracked minutes are required.
   Existing lesson duration estimates remain informational only.
   Additional modules and the Atlas/Dictionary are possible future expansions, not the solution to post-course retention.
2. Streak purpose and general rule

The streak represents consistent learning or practice.

Complete a lesson or finish a full practice activity to maintain your streak.

The streak advances no more than once per local calendar day.
The first qualifying completion protects the streak; further activity that day does not add another streak day.
No perfect result or minimum score is required.
Opening or abandoning an activity does not count.
Subscription status does not determine whether a completed accessible activity qualifies.

3. Activities that count toward the streak
   Activity Rule
   New lesson Counts after reaching the final conclusion card
   Completed lesson replay Counts after replaying through the final card
   Standalone mini-games Counts after completing two different mini-games during the same local calendar day
   Vocab game Counts after completing the selected round
   Flashcards Counts after reviewing every card in the selected flashcard set
   Keep Sharp recommendation Counts after meeting the completion rule of the recommended practice format

Vocab and flashcards follow the same principle: the user must reach the defined end of the selected round or flashcard review. Merely opening or abandoning either activity does not count.

4. Activities that do not count
   Coffee Challenges, including first completion and replays.
   Term of the Day.
   Reading Dictionary entries.
   Viewing Saved items or Coffee Cards.
   Roasty or Coffee Tree customization.
   Any activity that the user starts but does not complete.

Coffee Challenges are excluded because their current completion mechanic can be passed by skipping or selecting an arbitrary option without meaningful practice.

5. Standalone mini-games
   Standalone mini-games are available outside lessons.
   Each completed standalone mini-game counts as one activity.
   Completing two different standalone mini-games during the same local calendar day protects the streak.
   The two mini-games do not need to be completed consecutively.
   A single standalone mini-game does not protect the streak by itself.
   Two runs of the same mini-game do not protect the streak; the two runs must be of different mini-games.
   For free users, completing two mini-games uses both daily activities.
   Completing more mini-games does not produce additional streak days.
   Standalone mini-games do not grant points, grow the Coffee Tree, change course progress, or give a collectible reward.
   Completion feedback can show the result, score, animated Roasty, and a supporting phrase.
   Mini-games inside lessons remain part of the lesson and are not counted separately.

> **Agent note — added 13 Aug 2026. Not the product owner's words.**
>
> This section previously ended with: _"Completing any two standalone mini-game runs during the same local calendar day protects the streak. They may be two different mini-games or two completed runs of the same mini-game."_ That line was **withdrawn by the product owner** on [Mini-game streak unit](https://github.com/maximsan/brewpath/issues/59); §3 and §5 above now say **two different** mini-games, matching [Mini-games](https://github.com/maximsan/brewpath/issues/22).
>
> **Not for anti-farming** — that rationale does not survive inspection. `advance()` (`lesson.jsx:1350`) moves to the next round unconditionally, so any mini-game can be "completed" by tapping through every card wrong in about ten seconds. Both rules therefore cost the same ~20 seconds, and §2 already rules out score minimums outright. The reason the rule stands is **content variety**: the round bank is fixed order, so a repeat replays the same 5 rounds, where two different games give 11 distinct ones.
>
> **This keeps the storage unchanged.** #22 stores `{day → set of gameIds}`, union-merged, and a set counts distinct games — exactly what this rule needs. Allowing repeats would have required counting runs, and a counter cannot merge across two offline devices under union, max or sum.

The mini-games section on Today screen shows the complete catalog of mini-game formats.

Two mini-games formats are included with free access and are fully playable.

Premium formats remain visible in the same catalog but are marked with a lock or Premium label.
Selecting a locked format opens the upgrade screen and explains that premium unlocks all mini-game formats.
After upgrading, the locked formats become playable without changing their position on the screen.
This makes the free offer clear while still showing the additional value available with premium.

Free users may replay either free mini-game as often as they want, using material from unlocked lessons.

6. Keep Sharp

After Foundations:

Today recommends one existing practice type: mini-games, vocab game, flashcards, or a lesson replay.
Recommendations use only completed and accessible material.
Selection should use a simple rotation and avoid unnecessary adaptive complexity.
The recommendation remains stable for that day.
Completing Keep Sharp means meeting that type's own streak rule; for mini-games that means two different games.
Another qualifying activity may protect the streak even if the recommendation is not completed.
Keep Sharp does not grant repeat points, grow the Coffee Tree, or change course progress.
Completion only needs animated Roasty and a short supporting phrase.

> **Agent note — added 14 Aug 2026. Not the product owner's words.**
>
> Two lines above were **sharpened, not changed in meaning**, on [Keep Sharp](https://github.com/maximsan/brewpath/issues/56).
>
> - *"Today recommends one existing practice **activity**"* → **type**, with the four named. §1 already says Keep Sharp recommends a *kind* of practice rather than one specific item; naming the four removes the reading where Today suggests a single mini-game by name.
> - *"Completing its **normal round** completes Keep Sharp"* → the type's own streak rule, stated. This is the line that was actually missing. "Normal round" is unambiguous for flashcards and vocab, but a normal round of mini-games is **one** game — and §3/§5 require **two different** games to mark a day active. Item-level wording would let Keep Sharp report itself complete while the user's streak breaks, which is the one outcome a daily recommendation must never produce.
>
> ⚠️ **An earlier revision of this note proposed swapping "activity" for "format" throughout. That was withdrawn.** "Activity" is used precisely everywhere else in this document — §2, §3, §4, §5 and §8 all mean one unit of work counting toward the streak and the daily cap, and §5 says so outright (*"Each completed standalone mini-game counts as one activity"*). It is **"format"** that is overloaded: §1 and §3 use it for a kind of practice, while §5 uses it for an individual game (*"Two mini-games formats are included with free access"*). The swap would have traded a precise word for an ambiguous one.

7. Free preview

Free access is limited by content, not by waiting.

Only the first two agreed preview lessons are available for free.
They remain available permanently for replay.
Waiting until another day does not unlock additional lessons.
Practice content is limited to material available from unlocked lessons.
After finishing the preview, free users can continue practising unlocked material and maintaining their streak.

8. Free daily activity limit

A free user may complete no more than two full learning/practice activities per day.

Allowed combinations:

One available preview lesson plus one practice activity.
Two practice activities.
One activity only, if that is all the user wants.

A free user cannot complete two new lessons in one day.

The first qualifying activity maintains the streak.
The second does not add another streak day.
Coffee Challenges and passive browsing do not consume the daily allowance.
Paid access unlocks the remaining course and removes the daily activity limit.

9. Rewards and progression
   Practice exists to reinforce knowledge and maintain the streak.
   Practice and replays do not grant repeat points.
   They do not grow the Coffee Tree.
   They do not change lesson or module completion.
   No separate material reward is needed for daily practice.
   Existing first-completion lesson rewards remain unchanged.

10. Streak freeze

- The user earns one streak freeze after completing seven qualifying days in a row.
- A maximum of one freeze can be held.
- The freeze is used automatically when the user misses a day.
- A frozen day preserves the current streak but does not increase it.
- The frozen day does not count as a qualifying day toward another freeze.
- While a freeze is already held, additional qualifying days do not accumulate progress toward another one.
- After the freeze is used, the user must complete seven new qualifying days in a row to earn another.
- If the user misses two consecutive days, the freeze protects the first missed day and the streak resets after the second.
- Streak freezes are available to all users and are not a paid benefit.

> **Agent note — added 13 Aug 2026. Not the product owner's words.**
>
> §10 above is a complete nine-rule specification. An earlier revision of this file ended the section with a _"Confirmed / the remaining freeze behaviour has not been finalized"_ stub listing five open items; that stub has been **removed**, because the rules above answer all five.
>
> ✅ **Settled: §10 ships as written.** [Streak freeze](https://github.com/maximsan/brewpath/issues/58) resolved the conflict in this document's favour — cap **1**, no accrual while holding, **7 fresh days** after each spend. [Streak and freeze](https://github.com/maximsan/brewpath/issues/17) is superseded **on freezes only**; everything else it decided stands, including the active-day set as the sole stored state, derivation over storage, recompute-on-resume, and the two live app bugs it fixed.
>
> Two of the four apparent conflicts **were never conflicts**: #17's all-or-nothing spend rule is inert, because its own formula zeroes the held count on any streak reset, so both rule sets leave a two-day gap with zero freezes and a reset streak. The prototype's `FREEZE_CAP = 2` was **not** treated as a tiebreaker — the freeze lifecycle has never executed there, so the constant is unexercised rather than observed.
>
> The table below is kept as **#17's superseded version**, so the disagreement stays legible instead of being rediscovered a third time. **It is not the spec — §10 above is.**

| Behaviour                                                       | #17's answer                                                                                                                                                                                 | Against §10                                                                                 |
| --------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| Maximum freezes held                                            | **2** — `held = clamp(0..2, floor(streak / 7) - spent)`                                                                                                                                      | ⚠️ §10 says **1**                                                                           |
| Whether a freeze is used automatically                          | **Yes, and all-or-nothing.** Spent only if they cover the _whole_ gap; a 3-day miss with 2 held resets and spends nothing, because a freeze burned on a streak that dies anyway is pure loss | ⚠️ §10 spends on **any** missed day, so a two-day gap consumes the freeze and resets anyway |
| Whether a frozen day preserves but does not increase the streak | **Preserves.** Covered days render as covered in the week strip; the streak survives the gap rather than advancing through it                                                                | ✅ agrees                                                                                   |
| How another freeze is earned after one is used                  | Same formula — continued qualifying days keep earning, one per 7, minus those spent                                                                                                          | ⚠️ §10 requires **seven new consecutive days** from the spend                               |
| Whether earning continues while holding a freeze                | **Yes, capped at 2** by the `clamp`                                                                                                                                                          | ⚠️ §10 says progress **does not accumulate** while one is held                              |

> **The architecture is not in dispute.** Both rule sets are a fold over the stored set of active calendar days in date order, so freezes stay **derived, never stored**, either way — §10's are simply more path-dependent. There is **no spend event to trigger**: nothing mutates when a freeze covers a day, the value is computed differently next time it is read. Whichever set ships is a product call, not a storage one.

11. Current premium benefits

Paid access provides:

Access beyond the two-lesson free preview.
Removal of the two-activity daily limit.
Unlimited Saved items.
Roasty Studio.
Coffee Tree Studio.

Free users can keep up to five Saved items across lessons and dictionary terms.

Saving a sixth item opens the upgrade offer.
The user can remove an existing item to save another.
Previously saved items remain accessible.
Paid users have no Saved-item limit.

12. Dictionary terms

Every published Dictionary term falls into one of two access classes.

- **Lesson terms** — taught by a lesson. All users may browse and search them. Free access provides the short explanation; premium access adds the full explanation where one exists.
- **Reference terms** — taught by no lesson. Premium only. They do not appear in search, categories, Term of the Day, flashcards or mini-games for free users.

Every published term must therefore have a short explanation.

| Available content | Free access | Premium access | Publication state |
| Short and full explanations | Short explanation | Short and full explanations | Published |
| Short explanation only | Short explanation | Short explanation | Published |
| Full explanation only | Not shown | Not shown | Unpublished until a short explanation is added |
| Neither explanation | Not shown | Not shown | Unpublished|

Additional rules:

A short-only term is a valid published term. It does not need a full explanation.
For a term with both versions, free users receive the useful short explanation rather than an empty or completely locked page.
The full explanation can be represented by a clearly labelled premium expansion, such as Full explanation · Premium.
“Do not publish” means the term may remain in the internal content system as a draft, but it does not appear in search, categories, Term of the Day, flashcards, or mini-games.
A full-only term is considered editorially incomplete. A short explanation must be written before the term becomes visible.
Dictionary browsing does not maintain the streak or consume the free daily activity allowance.
Reading all short explanations for free does not automatically place all terms into free practice. Mini-games and other practice formats continue to use only material from unlocked lessons.
Free users may save up to five items; premium users have unlimited Saved items.

All the terms belong to no lesson at all are not accessible with the free tier and are included with any subscription

> **Agent note — added 13 Aug 2026. Not the product owner's words.**
>
> §12's opening sentence previously read _"All users may browse and search every published Dictionary term"_, which covered the 8 reference terms and so contradicted the ruling on this line. It has been **scoped into two access classes** above; the ruling itself is unchanged.
>
> **The tier arithmetic**, measured from source: **72 terms = 64 lesson terms + 8 reference terms.** Free sees the 64 at short. Premium adds **38 full explanations** (26 of the 64 are short-only, so premium adds nothing to them) **plus the 8 reference terms whole**.
>
> ⚠️ **This makes Term of the Day tier-dependent**, amending [the Coffee Dictionary decision](https://github.com/maximsan/brewpath/issues/20), which set its pool to the 46 terms carrying a full explanation as a **pure date function** — same term for everyone, zero storage. All 8 reference terms are in that pool, so it splits: **premium 46, free 38**. Product-owner ruling: the free rotation runs over 38. It stays a pure function of the date and still never repeats during the course, but it is now a function of `(date, tier)` rather than date alone. A free user's Term of the Day therefore always carries a full explanation they cannot read, making its _"Read the full entry"_ button a permanent upgrade prompt. The dictionary's live **category counts** become tier-dependent for the same reason.
>
> Recorded in full on [Free-tier practice content](https://github.com/maximsan/brewpath/issues/57).

---

## Reconciliation against the decision map — 13 Aug 2026

Each section mapped onto [BrewPath v1 parity](https://github.com/maximsan/brewpath/issues/6). Added by an agent session. The sections above are the product owner's words, unchanged — §10 gains a cross-reference and a table of what is currently decided, but its own text stands.

### Where each section landed

| §                                             | Ticket                                                                                                                                 | Status                                                               |
| --------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| 1, 6 — Foundations ending, Keep Sharp         | [Keep Sharp](https://github.com/maximsan/brewpath/issues/56)                                                                           | **New scope.** Nothing owned this; ticket created.                   |
| 2, 3, 4 — streak rule and activity lists      | [The streak's qualifying-activity rule](https://github.com/maximsan/brewpath/issues/33) _(closed)_                                     | **Resolved from these sections** by a parallel session.              |
| 5 — standalone mini-games                     | [Mini-games](https://github.com/maximsan/brewpath/issues/22) _(closed)_ + [#59](https://github.com/maximsan/brewpath/issues/59)                                                                | **Agrees.** The calendar day matches, and the two-different-games rule stands. |
| 7, 8, 11 — free preview, daily limit, premium | [Monetization shape](https://github.com/maximsan/brewpath/issues/29) _(closed)_                                                        | **Resolved from these sections.**                                    |
| 12 — dictionary terms                         | [Coffee Dictionary](https://github.com/maximsan/brewpath/issues/20) _(closed)_ → [#57](https://github.com/maximsan/brewpath/issues/57) | **Resolved from this section.** Amends Term of the Day to be tier-dependent. |
| 9 — rewards and progression                   | [Points and mastery](https://github.com/maximsan/brewpath/issues/16) _(closed)_                                                        | Agrees; no change owed.                                              |
| 10 — streak freeze                            | [Streak and freeze](https://github.com/maximsan/brewpath/issues/17) _(closed)_ → [#58](https://github.com/maximsan/brewpath/issues/58) | All five have answers; **whether §10 re-opens them is itself open**. |

### Open conflicts needing a call

**1. ~~§5 "session" vs the calendar day.~~ RESOLVED.** §5 was rewritten to use the local calendar day, matching [Mini-games](https://github.com/maximsan/brewpath/issues/22). A closing line briefly allowed **two runs of the same game**, reversing that decision's *two different* rule; it was **withdrawn by the product owner** on [Mini-game streak unit](https://github.com/maximsan/brewpath/issues/59). §3 and §5 now say *two different*, the stored `{day → set of gameIds}` is unchanged, and **no field change is owed** to [Sync scope](https://github.com/maximsan/brewpath/issues/14). ⚠️ Recorded there: the *anti-farming* rationale both #22 and #59 gave for the rule is **false** — a mini-game completes with every answer wrong in ~10s, so both rules cost the same. The rule stands on **content variety** (11 distinct rounds vs 5 seen twice).

**2. ~~§7 practice-content filtering.~~ RESOLVED** by §12 and the rewritten §5. Practice is scoped to terms the unlocked lessons **mention** (**12** for a free user, not the 4 a *taught-by* reading gives — which would have made the Vocab game unplayable, since its shortest round is 5). Mini-games gate **by format**, two free and five premium, which costs one module field on seven entries rather than the per-round authoring this looked like it needed. Full resolution: [Free-tier practice content](https://github.com/maximsan/brewpath/issues/57).

**3. §11 Saved scope.** The doc says _"across lessons and dictionary terms"_; the source counts **lessons, terms and guides** (`isSavedKey = /^(l|t|g):/`). Collectibles are already exempt. The resolution kept the source's behaviour — flag if guides were meant to be excluded.

### Consequences recorded elsewhere

- **The daily allowance is no longer derivable.** §8 counts _activities_, not lessons. Vocab rounds, flashcard sessions and Keep Sharp completions are recorded nowhere today — [amendment on Sync scope](https://github.com/maximsan/brewpath/issues/14#issuecomment-5277335296).
- **`SAVED_FREE_MAX` moves 10 → 5** in `prototype/app.jsx`, and the v1 audit's monetization section is now wrong in four places (_"never walls the daily loop"_, _"everything that teaches is free"_, _"All daily lessons & the full path… never gated"_, _"Saved up to 10"_).
- **Free tier is a demo tier**, measured: **2 of 32 lessons · 2 of 37 collectibles · 1 of 12 coffee challenges · tree stage ~1 of 10**. A deliberate strategy change, but it means the audit's _"Free builds the habit"_ positioning no longer describes the product.
- **Keep Sharp is paid-only in practice** — a free user never finishes Foundations, so never reaches it.
