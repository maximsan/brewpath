# Changelog

All notable changes to BrewPath are recorded here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This is the single place to track **major app changes** over time — when you
finish a meaningful piece of work, add a line under **Unreleased** before you
commit. When you ship a build to TestFlight/App Store, move the Unreleased items
under a new dated version heading.

> **How to use this file (quick guide):**
>
> - Group each change under **Added**, **Changed**, **Fixed**, or **Removed**.
> - Write one short line per change, in plain language — describe the user- or
>   developer-visible effect, not the implementation detail.
> - You don't need to log every commit. Log things you'd want to _remember later_.
> - The **Build Milestones** table at the bottom is the frozen history of the
>   initial 0–11 build phases. Don't edit it; add new work above instead.

### Workflow — when and how to update this file

Two helpers keep this near-zero effort:

| When | Do this | What it does |
| --- | --- | --- |
| You finished something worth remembering | Run **`/changelog`** in Claude Code | Reads your recent code changes (not commit messages), proposes Added/Changed/Fixed bullets, and — once you approve — writes them into **[Unreleased]** below. |
| You're shipping a build to TestFlight / App Store | Run **`node tool/release.js`** | Renames **[Unreleased]** to a dated version heading, opens a fresh empty [Unreleased], bumps the version in `pubspec.yaml`, and (with `--commit`) tags the release. |

`release.js` usage (run from the repo root):

```bash
node tool/release.js                  # 1.0.0+1 → 1.0.0+2   (build number only)
node tool/release.js minor            # → 1.1.0+2
node tool/release.js 1.2.0            # → 1.2.0+2  (explicit version)
node tool/release.js minor --commit   # also commits + tags v1.1.0+2
node tool/release.js --dry-run        # preview only, writes nothing
```

You can always edit this file by hand instead — the helpers just save effort.

---

## [Unreleased]

### Added

- **The visual guides explain themselves.** A guide's table said *what* —
  `LIGHT / Bright · acidic` — and stopped there. Each row now carries the
  sentence that says what living with it is like ("Acidic and fruity. Can taste
  sharp or sour if under-extracted"), and the four guides that end on a thought
  now show it. Those words were authored all along, trapped inside markup the
  extractor could not read; the prototype moved them into data fields and the
  app finally carries them.

  The table and the prose are authored in two separate registries, so they are
  joined **by name rather than by position** — and the extractor refuses to
  write a gloss naming a row that does not exist, because a mismatch would not
  fail anywhere: the sentence would simply never render.

### Fixed

- **A schema bump no longer trips over a migration that predates it.** The
  step that dropped the two dead streak columns rebuilt `user_settings` from
  the current table definition, so it quietly depended on every column that
  table would ever gain — adding one broke every upgrade from older versions
  with an error naming the new column, in a step written long before it. The
  columns are now dropped by name, which nothing later can reach. The one
  rebuild that must stay gained a test that fails by name if a column is added
  without being declared.

- **The mini-game catalog stopped looking broken.** Eleven of its thirteen rows
  greyed themselves out and said "Not available yet" because their kind has no
  renderer yet — a fact about our build progress, dressed as a paywall, on the
  wrong screen. Every row now opens its intro, and a game we cannot yet play
  says so there, on the button the learner reached for. This also frees the row
  to carry one meaning, which the tier marks need (#267).

- **A dictionary self-check crashed for anyone using reduced motion.**
  Answering one asked `AnimatedSize` to finish in zero time, and it re-dirties
  itself inside its own layout when told to — so the framework asserted rather
  than the explanation appearing. Thirty of the seventy-three terms carry a
  self-check. The animator is now dropped entirely when the system asks for no
  motion, which is what "no animation" has to mean, and a sweep test fails on
  any file that pairs the two again.

### Added

- **Lessons can be bookmarked too.** The bookmark sits in the lesson player's
  own bar, so a lesson worth returning to is kept while it is being read rather
  than hunted down afterwards. Saved lessons fill the shelf's Lessons group,
  each showing the module it belongs to, in course order rather than the order
  they were saved.

- **The Saved shelf.** A bookmark button in the header on Learn, Path and
  Cards — carrying a dot when the shelf holds something — opens a screen
  listing what was kept, grouped as Dictionary terms, Lessons and Visual
  guides, each group hidden when it is empty. Rows open what they name and
  carry the same bookmark that saved them, so unsaving from the shelf and
  unsaving from the thing itself are one gesture. An empty shelf teaches the
  bookmark rather than reporting zero, a saved item the content no longer
  carries is skipped rather than drawn broken, and the header's dot counts what
  the shelf will actually show — so the badge can never promise a row that is
  not there. Reset Progress clears both.
- **Onboarding asks what to call you, and Profile says hello back.** A third,
  optional step takes a name and the Profile header greets by it — `Hello,
  Maya.` where one was given, `Hello, there.` where it was skipped, which is
  the same sentence either way. Skipping costs nothing and stays skippable.

- **A locked mini-game now offers something.** Tapping one opens a sheet naming
  the module that teaches its topic — "Taught in Module 4 · Grind" — and
  pitching that module in its own words, rather than refusing silently. The
  lock became a door. The purchase call to action arrives with the paywall
  (#89); this ships the pitch and the way out (#270).

- **Dictionary terms can be bookmarked.** A bookmark sits on the term entry and
  on the peek sheet, and what it saves survives closing the app. It is the same
  control every saveable kind will use — lessons and visual guides follow — and
  the key grammar behind it (`l:` a lesson, `t:` a term, `g:` a guide, and
  nothing else) now lives in one place rather than being spelled at each call
  site. The Saved shelf that displays them comes next; this is the half that
  records.

- **The eight visual guides get their drawings.** Roast swatches, grind dots,
  the extraction and ratio spectrums, the cherry's six rings, the variety
  family tree, caffeine bars and the blade-against-burr distribution curves —
  one painter per subject, every coordinate a fraction of the box it is given,
  so the row thumbnail and the sheet illustration are the same drawing at two
  sizes rather than two that can drift apart. Wordless, because each guide's
  meta table is already its diagram in words. They read the illustration
  palette, follow the mood, and stay out of the semantics tree.

- **Path ends in a Reference section.** Finish the lesson that teaches a visual
  guide and it appears at the bottom of Path, while you are still holding the
  phone — tap it and the reference opens as a sheet over Path, with its summary,
  its two-or-three-row table and its fact. Locked guides are not drawn at all;
  the section says how many are still to come, which turns the absence into a
  promise rather than a wall of grey tiles at the moment you own one of eight.
  Until the first guide is earned the section is locked and says what would fill
  it, and it refuses to open onto nothing.

- **The eight visual guides are content the app can read.** The illustrated
  references a lesson teaches — roast, grind, extraction, ratio, cherry anatomy,
  variety, caffeine, grind spread — now ship as their own bank, joined at
  extraction from the two prototype registries that hold half a guide each.
  Reading the second one meant teaching the extractor to slice a data object out
  of a file that also carries React markup, by cutting each entry's body away.
  Five checks refuse a run that would ship a broken guide, the sharpest being
  that a guide's unlock must be the *earliest* lesson that teaches it — which is
  what turns ten lesson placements into eight guides, and what stops a
  reordering leaving a learner shown a reference as locked after being taught
  it.

- **The mini-game catalog shows what the learner owns.** Ten of the thirteen
  games now carry a lock before any tap; Match, True or false and Name the
  origin do not — the three ADR-0007's free lesson list forces. The rule is one
  pure function, and a table test over the real shipped catalog pins the free
  set by id and guards ADR-0001's invariant that a free learner can always
  reach a qualifying streak day on free content alone. Entitlement is read
  through the payments abstraction; while it resolves the shelf shows no locks,
  so nobody who paid catches a frame of them (#269).

- **The mini-game shelf is grouped by kind.** Thirteen games in one flat list
  meant reading all thirteen to find the two that match. They now sit under
  seven headings — Match, True or false, Name the note, Blind bag, Taste fix,
  Calibrate, Sequence — in a fixed order that does not derive from the catalog,
  so adding a game never reshuffles the shelf (#268).

- **The Tour can be replayed.** A "Replay the tour" row at the bottom of
  Profile → Customize switches to Learn and runs the four stops again — no
  intro overlay, and nothing written: the question the overlay asks was
  answered the first time, and the flag records that answer rather than how
  many times the Tour has run.
- **The Tour.** A first launch that reaches the Learn tab now asks "Quick tour?"
  — four spotlight stops, auto-scrolled in order: the Today card and the daily
  loop, the practice area (replays and mini-games, as one idea), the finite
  module list, and the bottom tab bar. Each stop explains a *mechanic* rather
  than naming a widget, and the Tour says nothing about Plus or locks. Answering
  the intro either way writes `tourSeen`, so the offer is made once and
  abandoning the Tour halfway never re-arms it. Scrim and tooltip come from the
  app's tokens in both moods, and reduced motion turns the spotlight's movement,
  its scale-in and the auto-scroll into cuts.
- **The Tour has somewhere to remember itself.** A `tourSeen` bit on the
  settings row (schema v8), written once when the learner answers the Tour's
  intro and read to decide whether the Tour auto-runs at all. It fate-shares
  with the onboarding gate wherever a wipe decides: Reset Progress keeps both,
  Delete Account clears both, and the debug onboarding-reset clears both — so
  no wipe can leave a device replaying the welcome flow with the Tour silently
  suppressed. Device-local, and deliberately outside the progress snapshot.

- **The tab header gets out of the way as you scroll.** Scrolling a tab drops
  the header's eyebrow and shrinks it to the title; scrolling back to the top
  restores it. Each tab keeps its own collapse, for the same reason each keeps
  its own navigator stack — scrolling Learn, switching to Path and switching
  back finds Learn exactly as it was left. A tab with nothing to scroll never
  collapses, a carousel inside a tab is not the tab moving, and with reduced
  motion on, the change lands in one frame.

- **One header over the four tabs.** Learn, Path and Cards each wore a stock
  bar carrying nothing but the tab's name, and Profile wore a different header
  again. They now share one, owned by the shell: a smallcaps eyebrow over a
  display title — today's date on Learn, the course on Path, the collection on
  Cards, a greeting on Profile — with the Dictionary in reach from the first
  three and a Settings gear on Profile. Pushing into a module, a card or a term
  shows that page's own bar and never the tab header; a lesson or mini-game
  shows neither. Which chrome a location gets is one pure rule over the route,
  asserted as a table, so a route added later cannot silently inherit the wrong
  one. Learn's date joins the day-rollover list rather than being read once at
  build, and Profile's close button — an app-only invention the design has no
  equivalent for — is gone with its delegate.
- **Milestones get their moment.** The streak screen opens on a Roasty beat
  when a milestone day lands (3, 7, 14, 30, 60, 100, 180, 365, then every
  30) — once per milestone, self-healing after a lapse — and the count sits
  inside a progress ring toward the next badge.
- **The week reads at a glance.** A shared seven-cell week strip — done,
  covered-by-a-freeze, or empty, with a cue on today — renders on the streak
  screen and inside the Profile streak tile, each cell read straight from the
  recorded day set.
- **A spent freeze says so.** The first open after a freeze covered a day
  shows a dismissible notice on Learn — the streak is safe, the covered day
  named, the re-earn stated — acknowledged per covered day so sync can never
  replay it.
- **The streak has a home.** Tapping Day streak on Profile opens the new
  streak screen: the day count at hero size and a one-line freeze status —
  the covered day named, a held freeze stated, or the countdown to the next.
- **One sheet primitive, and reduced motion at last.** Every bottom sheet now
  opens through a single function that owns the chrome — the mood background, a
  dimmed barrier, rounded top corners, a drag handle, safe-area insets, a
  height cap that scrolls rather than clips, and the title, which is also the
  name a screen reader announces the sheet by. One string feeds both, so the
  spoken name and the visible one cannot drift.

  The dictionary's peek sheet is the first to wear it: opened raw, it had none
  of that and sat on a stock Material surface behind a moody design. And
  because `showModalBottomSheet` ignores the platform's reduced-motion setting
  outright, a learner who asked for less motion is now given it — the sheet
  arrives settled instead of sliding.

  Two rules the design writes down are deliberately not implemented: sheets
  stacking, and root-level sheets dismissing on navigation. Both are DOM
  problems that Flutter's navigator already solves, measured rather than
  assumed.

- **The Coffee Dictionary.** 73 terms across 8 categories, reachable from a
  header action on Learn: a home that searches names, aliases and category
  labels (case- and accent-insensitive) and filters by status with live counts,
  a full term entry — pronunciation, both depths of explanation, a worked
  example, an answerable self-check, related terms, sources and the lesson that
  teaches it — and a peek sheet that opens the same entry without costing the
  learner their screen. A term's status is **derived** from its lesson pointer
  against completed lessons, never stored, so it syncs and resets for free; the
  snapshot's reserved learned-terms field is deliberately left unwritten. The
  eight terms no lesson teaches are told so plainly and are kept out of the
  to-learn list *and* its count — a count in front of a learner has to be a
  promise the course can keep. Terms carrying only a short explanation render
  as finished entries rather than advertising a gap.

- **The practice catalog nearly doubles — 7 mini-games become 13.** Six new
  games join the seven that shipped, each pairing an existing mechanic with a
  course topic it suits: a second match on washed versus natural, a quiz on
  roast basics, origin signatures on flavour, espresso on taste-fix, a
  grind-by-brewer calibration and a V60 sequence.

  The original seven keep their ids. They are written into stored day-sets, so
  renumbering them would silently rewrite what a learner already played.

  The Coffee Dictionary gains a term and another full explanation.

- **The bundled content now states which contract it satisfies.** Every
  generated bank carries a schema version, the extractor stamps it, and the app
  refuses a bank it was not built to read — naming the file and both versions
  rather than reading past the mismatch. Field names travel from the prototype
  verbatim, so a rename used to surface as a blank inside a lesson at the card
  that needed it; it is now a refusal at startup, where a build can catch it.
  What counts as a breaking change is written in the extractor's header, and
  [ADR-0006](adr/0006-the-prototype-authors-v1-and-the-extracted-json-is-the-contract.md)
  records why the prototype still authors the course and what would end that.

- **Coffee Challenges show up everywhere they belong.** Finish a lesson that
  carries one and the completion screen offers it — start it there, or park it
  for later without leaving the celebration. Finish a module and its capstone
  appears on the Path, reading *Challenge*, *Saved*, *Active* or *Done*. Open a
  collectible you have earned and its challenge is stamped on the card, brewed
  or not. Profile gains a *Coffee Challenges* row counting how many of the
  course's brews you have made.

  The twenty lessons that carry **no** challenge are the point of the work:
  their completion screen is unchanged, down to the pixel — no gap, no divider,
  no placeholder where an offer would have been. That is the common case, and
  it has to look like nothing was ever missing.

- **Park, don't drop.** A Coffee Challenge you asked for is never lost. The log
  sheet gains **Save for later**, starting a second challenge parks the first
  rather than discarding it, and — the case that used to lose work silently — a
  challenge whose forty-eight hours run out now moves into a *Saved challenges*
  list on Today instead of simply vanishing. Each row starts its brew again or
  drops it for good.

  The expiry check runs on app open and on resume, with no timer: a window
  measured in elapsed time only needs looking at when the app can act on it. It
  writes **nothing** when nothing has lapsed, so repeating it changes nothing —
  including on a second device, which computes the identical result.

  This also fixes a real defect carried over from the design: the active
  challenge was never cleared when its window ran out, so a challenge expired
  months ago would keep syncing between devices as the one in play.

- **A brew can be logged, and it pays.** The Coffee Challenge card on Today now
  carries a Log Result button, and it opens the app's first bottom sheet: the
  challenge's own question — *WHICH CUP WON?* — above the outcomes it authors,
  with **Mark as done disabled until one is picked**. Every authored reaction
  asserts the brew happened, so logging without one would record a claim the
  learner never made. Dismissing the sheet writes nothing; looking is free.

  Logging pays **five points the first time and nothing on a replay**, records
  the outcome as text rather than a position, and hands off to a recap where
  Roasty celebrates and offers to brew it again. A replay re-asks the question
  and replaces the old answer, so the record is what the learner last found.

  A Coffee Challenge still records nothing toward the streak or the daily
  allowance, and grows no tree — it is not an activity, it is a real cup.

- **Coffee Challenges reach the app.** The twelve real-world brews the course
  authors now load, and the one that asks you to go and make coffee can be put
  in play. Finish every lesson of a module and its capstone is offered on the
  module screen — *Two cups, two ratios* after Beans — and starting it puts a
  Coffee Challenge card on Today, beside the day's lesson rather than instead
  of it: what to learn next and what to go and brew are two questions, and a
  learner can have both open at once.

  A challenge stays in play for forty-eight hours of **elapsed time**, not
  until midnight — "next brews" is a duration, not a day — and at exactly
  forty-eight hours it is still live, because the boundary belongs to the
  learner. Past that it leaves Today. Nothing is logged or rewarded yet; that
  is the next step.

- **The app teaches Foundations.** The course is now the real thirty-two-lesson
  syllabus the design authors — five modules, its own card vocabulary, its own
  ids — read from the generated banks. The twenty-five hand-authored lessons
  that shipped before Foundations existed are gone, and with them the second
  way to play a lesson: the step player and its four game widgets have no
  callers left. Opening the app lands on *What coffee actually is*, which plays
  its eight cards through the real renderers, banks ten points and awards *The
  Coffee Cherry*. Choice order is reseeded on every attempt and never stored,
  so a lesson cannot be passed by remembering the right answer was third.

  A card's words now live in exactly one place. Collectibles carry no text of
  their own — a card's title, summary and fact are read from the reward of the
  lesson or module that unlocks it, resolved by following the collectible's own
  pointer back to its source. Which module owns a lesson is resolved the same
  way, from the module's lesson list rather than parsed out of a display label.

  A missing, malformed or empty content bank now fails loudly instead of
  yielding a course with nothing in it. The banks ship inside the app, so any of
  those is a build defect, and an empty course that loads cleanly is the failure
  nobody notices until a learner opens a tab and finds it bare.

### Changed

- **The module collectible is a Module Reward, not a Field Guide.** The
  glossary settled the name when the visual-guides ruling landed, days after
  the module moment shipped under the older one — so the recap read
  "Field Guide unlocked" for a card the design calls a Module Reward.

  It now reads **"Reward unlocked"** — the words the design uses when a card
  is unlocked, borrowed into the recap's caption because the app has no
  dedicated reward screen to put them on as an eyebrow. What they are not is
  the glossary term: "Module Reward" names the thing, and was never the
  sentence shown over it.

  **The five cards keep their titles.** "Beans Field Guide" and its siblings
  are what those cards are *called*; Module Reward is what they *are*. The
  glossary now says so, so the next sweep does not reopen it. The collectible
  `kind` values stay `fieldGuide*` for a different reason: they are the
  read-only design source's wire vocabulary, not copy.

- **Points pay flat ten, once — and nothing else pays.** The whole system is
  now two rules: ten for a lesson's first completion, five for a Coffee
  Challenge's. Replays, perfect runs, module completion, practice and
  mini-games all pay zero.

  Two payouts are gone. The **module-completion bonus** of twenty-five paid for
  lessons it had already paid for, re-coupling points to course structure after
  the design deliberately separated them — the module moment keeps its
  celebration and now hands over its **Field Guide card**, which is what always
  waited there. Five of the thirty-seven collectibles had never been reachable
  in the app; they are now. The **per-day practice reward** of two points broke
  *replays pay zero* outright and scaled with the course: at thirty-two lessons
  it paid sixty-four a day for pure repetition against three hundred and twenty
  for learning everything, so five days of replaying out-earned the entire
  course. Under the free plan's two-new-lessons-a-day cap, grinding replays was
  strictly the faster route to a bigger number.

  **A finished course therefore banks 380 rather than 505 — about a quarter
  less, and more than that for anyone who had been replaying, because the
  practice reward had no ceiling. That is the intent, not a regression.**
  Replays are not left unrewarded — one can still lift mastery, and one still
  protects the streak.

- **The points total is derived, never stored.** It used to be a counter on the
  settings row that every payout incremented. Both of its inputs were already
  persisted, so it is now summed from them on read: a counter is a second copy
  of a derivable fact, and Reset Progress no longer needs a rule of its own.

- **The currency is called points everywhere a learner can read it.** Twelve
  strings said *XP* — the profile stat, both lesson previews, both result
  screens, the reset and settings copy, and a label painted into the mascot's
  reward burst. The glossary has ruled *points* since the beginning and lists
  *XP* under _Avoid_; a test now fails if the word comes back.

- **A lesson pays the flat ten it authors**, rather than ten per step. The
  per-step formula lost its input when steps became cards: how many cards a
  lesson runs is a shape of its teaching, not a measure of what finishing it is
  worth. The per-correct-answer points toast goes with it — it showed the full
  lesson award on every right answer, which was never what a card paid.

- **Modules unlock by position.** A module opens when the one before it is
  complete, derived from its place in the course. The bank ships a `locked`
  flag, but it is the prototype's demo state — one imaginary learner's progress
  — and honouring it would have left four modules shut for everyone.

- **Keep Sharp's replay button opens a replay that counts.** On a day the card
  recommends replaying a lesson, Start now opens it the same way the course
  path does, so reaching the final card records the day and protects the
  streak. It used to open a mode that recorded nothing, which meant a learner
  past Foundations could do exactly what Today asked, every day, and still lose
  their streak. The card is told to look again on return, so it acknowledges
  the practice instead of still asking for it.

- **Keep Sharp's mini-games button opens a mini-game.** On a day the card says
  *"play two different games today"*, Start now lands on one of the authored
  games — and skips any already played today, so pressing Start twice reaches
  two different ones and the day is marked. It used to open the cross-lesson
  practice drill, which is not a mini-game and recorded nothing, so following
  the card could never satisfy the card or protect the streak. The card is also
  told to look again when a run finishes, so it acknowledges the practice on
  return instead of still asking for it.

- **The streak runs on its real rules.** One pure module now folds the stored
  set of active calendar days into everything the streak needs — the day
  count, the freeze, the days a freeze covered and the week strip — and every
  one of those is derived on read rather than stored, so nothing about a
  streak can drift or be inflated by two devices. The rules are §10's, whole:
  a freeze is earned after **seven** qualifying days in a row, at most **one**
  is held, it is spent automatically on the first missed day, a covered day
  preserves the streak without raising it and earns nothing toward the next
  freeze, accrual pauses entirely while one is held, and after a spend it
  takes seven *new* days in a row to earn another. Miss two days running and
  the freeze covers the first while the second still ends the run. Freezes
  are free for everyone — there is no parameter a paid tier could arrive
  through. An unfinished today is never counted a miss, so the streak does not
  break at midnight for someone who has not practised yet.
- **What counts as a day, in one place.** A lesson, a completed replay, a
  vocab round or a flashcard review each protect the day on their own; two
  **different** mini-games do it together. The first qualifying completion
  protects the day and nothing after it counts twice. The rule is written as
  an exhaustive switch over the activity types, so §4's exclusions — Coffee
  Challenges, Term of the Day, reading, browsing, customising — are impossible
  to write rather than merely unlisted.
- **The week strip's seven cells** derive straight from the day set: in the
  set it is done, covered by a freeze it is frozen, otherwise empty. The
  prototype instead counted back `streak` cells from today, which silently
  drops a genuinely active day whenever a freeze covers one inside the visible
  week — a defect that cannot exist here. Nothing renders the strip yet; the
  surfaces are a separate slice.

- **The planted grove shows on the tree.** The species you own and the light
  it stands in now compose over the Coffee Tree: the plant's silhouette as a
  scale, its leaf tone and the light as a single colour filter. A grove synced
  from another device shows on the Profile hero without the Studio existing
  yet. Arabica in Daylight is painted as the untouched illustration rather
  than through a filter that happens to change nothing, and a stored species
  this build has never heard of falls back to the default instead of failing
  to draw.
- **Two different mini-games now mark the day.** A run that reaches its
  results records itself on the day's activity, and the second *different*
  game of a local day marks that day active — the anti-farm rule, so one run
  is not enough and the same game twice counts once while still costing two
  against the daily allowance. The mark is derived from what is stored rather
  than stored as a flag, and it merges by union, so two devices offline with
  one game each converge on a qualifying day. An abandoned run records
  nothing. Keep Sharp reads the same record, so a mini-games recommendation
  finally acknowledges itself.
- **The grove's two axes leave the prototype** — the extractor now emits the
  three coffee species (Arabica, Robusta, Liberica, each with its binomial,
  origin, growing conditions, cup profile and the tell describing the plant)
  and the four lights (Daylight, Golden Hour, Moonlit, First Frost), and the
  app loads both. Nothing renders them yet; the Studio chooser is a later
  slice. The counts are checked exactly — a fourth species stops the build,
  because three is a product ruling rather than a content list that grows.
- **The Coffee Tree grows.** Finishing a lesson for the first time advances the
  stored stage, so the one picture of course progress finally moves: a fresh
  install is a seed, finishing Foundations reaches the tenth stage, and replays
  and practice grow nothing. The stage is stored as the *outcome* rather than
  recomputed from a lesson count, and it is written raise-only — so adding
  lessons to the course later can never walk a finished learner's tree back
  down, and a stage reached on one device survives the merge with another.
- **The Coffee Tree stands** — the Profile tab now opens on the tree itself,
  showing the stage the learner has reached, announced to screen readers. A
  fresh install shows the seed. Note that nothing advances the stage yet, so
  every tree currently sits at seed; growing it is tracked separately.
- **The match board plays — the free mini-game pair is complete.** *Match the
  facts* joins *True or false*, so a free learner has the two different games
  a streak day needs. Read a fact, tap where it belongs; a wrong placement
  says so and leaves the fact in play, because the board is finished by
  clearing it. The card pays its single success signal **only on a board
  cleared without a wrong drop**, so a scrappy board still finishes the run
  and still scores nothing. The renderer lives in the shared card layer with
  no knowledge of its host, ready for the lesson player to pick up when it
  moves onto the card union.
- **The snapshot now records what the daily allowance counts.** A new
  `dailyActivity` field holds, per local day, the completions a free user's
  two-activity cap is measured against. Each entry is **one completion**, not
  one kind of one: two vocab rounds — or two replays of the same lesson —
  count as two, which a set keyed on activity type would have quietly
  collapsed into one. It merges by union per day, so two devices offline with
  one completion each converge on two rather than losing one, and it prunes to
  the last couple of days on a best-effort basis because nothing reads further
  back. `miniGamePlays` folds into it: the two-different-mini-games streak
  rule now derives from the distinct game ids among a day's entries, unchanged
  in meaning — two runs of one game still count once for the streak while
  costing two against the allowance.
- **Mini-games are playable — True or false plays end to end.** Learn gains a
  Mini-games group listing all seven formats from the extracted catalog (the
  game's name leads, the topic it drills is the eyebrow), and `g-quiz` runs
  the whole way: intro with how-to-play, six rounds one at a time with a
  progress strip and immediate feedback, then a results screen with the score,
  the companion's reaction and Play again. Both the round order and each
  round's choice order are seeded per run from a nonce minted at the start and
  never stored, so a replay cannot be passed by memorising positions. Nothing
  about a run is written anywhere — no points, no tree growth, no cards, no
  progress. Formats whose renderers are not built yet are listed but do not
  navigate.
- **Keep Sharp acknowledges the day's practice** — when the recommended
  practice type meets its own completion rule (for a replay, one completed
  replay today), the Today card swaps the recommendation for an animated
  Roasty and a short phrase. That is the whole reward: no repeat points, no
  tree growth. The state is derived each day from what the activity layer
  already records and stored nowhere; mini-game drill runs leave no record
  yet, so that recommendation does not acknowledge until they do.
- **The Foundations ending** — finishing the course now lands on a one-off,
  full-screen completion moment: Roasty celebrating, "You finished Beginner
  Foundations", what you actually did (lessons completed, cards collected,
  your streak), then a hand-off into Keep Sharp. It fires exactly once, gated
  by a key in the snapshot's acks map — only Reset Progress re-arms it — and
  new content landing later flips Today back to Continue Learning with no
  second celebration. Nothing is paid out: no points, no tree growth, no 38th
  card. The router owns the presentation; reduced motion renders it
  statically.
- **Keep Sharp** — a finished learner's Today card now recommends one practice
  type for the day instead of dead-ending at "all caught up". The pick is a
  simple fixed rotation derived purely from the date (stable all day, storing
  nothing), it skips types with no surface or no material, and the card states
  the type's own completion rule — mini-games say "play two different games" —
  so doing what Today asks always protects the streak. The old copy promising
  future modules is gone.
- **The mini-game rounds are extracted too** — `MINI_GAME_CONTENT` joins as
  the eighth and final bank. Its bagpick entry reads its rounds from a second
  prototype file through a `window` getter, the one dependency the extractor's
  bare slice-and-evaluate could not honour: evaluated alone it yields an empty
  game with no error. The extractor now assembles that dependency itself, so
  all seven formats carry their rounds, a format extracting to zero rounds
  refuses the run instead of shipping a silently empty game, and true/false
  rounds are graded without widening the lesson card union's graded kinds.
- **The extractor now emits the mini-game banks** — the seven-format catalog
  and the card-kind help map join the five existing banks, through the same
  validate-and-refuse-to-write pass. Two new checks: catalog format ids are
  unique, and every format's kind has a how-to-play help entry, so a mini-game
  surface can never ship a game whose "?" drawer is missing. The rounds
  themselves followed in the entry above.
- **The first five card renderers**, and the boundary they answer across —
  `predict`, `concept`, `mcq`, `decision` and `recall`, which are the eight
  cards of the first lesson and 185 of the course's 257. A graded card reports
  success and nothing else: a wrong answer raises its reaction inside the card,
  never through a callback, because nothing in the app consumes an incorrect
  signal.
- **Choice order is now shuffled from a seed** that is derived on every render
  and never stored. One nonce per lesson attempt, each card mixing in its own
  index — so a replay moves the answers, and a learner cannot pass a lesson by
  remembering where the right option sat.

- **Bundled content is now generated from the prototype rather than
  hand-copied.** `node tool/extract_content.js` reads five banks — modules,
  lessons, collectibles, dictionary terms and brew challenges — out of
  `brew-path/`, checks the whole cross-reference graph, and only then writes
  `assets/content/generated/`. On any violation it names the offending card and
  the broken reference, writes **nothing**, and exits non-zero, so a run can
  never leave a stale mixture of old and new files behind. Brew challenges are
  extracted for the validator's sake rather than the app's: no screen reads them
  yet, but their 31 lesson, module and collectible pointers are edges the graph
  would otherwise never check.
- **`ContentCard`** — one sealed union covering every authored lesson-card kind,
  so an unhandled kind is a compile error instead of a blank card. The graded
  kinds carry a `Gradable` marker, which lets scoring take a list that *cannot*
  contain an ungraded card — the shape of the bug that once let the prototype's
  mastery exceed 100%. The extractor publishes which kinds it grades and a test
  asserts the union agrees, so the two languages cannot drift apart.
- The progress snapshot is now **stored**, so what a learner earns survives
  closing the app. It lives as a single row rather than a table per thing —
  progress arrives from another device as one whole object, and taking it apart
  to store it is where the subtle merge bugs live. Writing it does not touch
  appearance, sound or haptics, which stay on the device and survive every
  wipe.
- The **progress snapshot** — one versioned value holding everything the
  learner has earned, split into what **Reset Progress** clears and what only
  **Delete Account** clears. The two halves are separate types, so a reset
  cannot quietly forget a field the way the prototype's once did, and a field
  that fits neither scope will not compile.
- **`mergeSnapshot()`** — the pure function that joins two devices' progress.
  No database, no clock, no network, so every conflict case is testable without
  a device. It is proved to converge — merging in either order, in any
  grouping, or re-merging the same payload twice all reach the same state —
  against four hundred generated snapshots per property rather than
  hand-picked examples.
- Progress written by a **newer version of the app survives a round trip
  through an older one**, instead of being silently dropped the next time the
  older build saves.

- The **lesson node is a mastery gauge** — a coffee bean that fills to your
  best score on that lesson, so how well you know it reads as "how full"
  instead of a number in the margin. A lesson you finished before scores were
  recorded stays a deliberately neutral empty bean rather than claiming a
  mastery it never measured.
- **`ModuleGlyph`** — one implementation of the bare module glyph the Learn and
  Path rows both draw.
- **`AppRoutes`** — a catalog pairing each route's go_router `name` with its
  `path` on one entry, so the two can no longer drift apart. The router builds
  every `GoRoute` from it, replacing sixteen pairs of hardcoded string
  literals.
- Two colour moods — **Cupping** (light) and **Dark Roast** (dark) — held as
  `MoodColors`, a single `ThemeExtension` carrying the design's own 13 token
  names plus the two background-derived veils. Screens read them through
  `context.mood`. Both moods are reachable through the appearance setting
  below.
- An **appearance setting** — Light / Dark / System — on Settings, persisted in
  the settings row and defaulting to Dark. `System` follows the OS live. The
  preference is read during bootstrap and handed to the first build, so the
  opening frame is already in the right mood rather than flashing the wrong one
  and correcting itself.
- Fonts are bundled as real Flutter font assets under `assets/fonts/`,
  replacing the `google_fonts` package and its runtime CDN fetch.
- Roasty became a **companion subsystem** rather than a loading-screen mascot:
  a mood + reaction API with a speech bubble and a static (non-animating) mode,
  speaking lines from the new `assets/content/companion_lines.json`. It now
  turns up on lesson completion.
- A floating **points-gain toast** that rises when points are awarded.
- A **module-summary screen** with a module-complete moment, reached when the
  last lesson in a module is finished.
- A **card detail screen**, and **favourite cards** — a card can be saved and
  read in full.
- **`learning/`** — a hands-on, learn-by-doing Flutter course for this app: a
  teaching contract in `README.md` and a `curriculum.md` that marks the current
  step.
- **The design source of truth now lives in the repo.** The React prototype is
  tracked under `brew-path/`, and `docs/design/` is the reference that indexes
  it — product, scope, design system, information architecture, mechanics,
  content, components and flows — so app work can be checked against the design
  without reading the prototype.
- The design's 15 illustration colours as `ArtColors` — the roast ramp, the
  cherry cross-section ramp and the standalone art colours — kept out of the
  mood system on purpose: a ripe cherry is the same colour in either mood.
  `ArtColors.roastAt()` gives a continuous point on the roast ramp, so the
  roast meter reads one colour story shared with every roast drawing.
- The three fixed overlays as `OverlayColors` (media scrim, its ink, and the
  modal dim). They are declared identically in both moods in the design, so a
  modal darkens the page in either one instead of inverting with it.
- `AppRadii` — the design's two radius languages (2px editorial for cards and
  buttons, 14px soft chrome for media frames and sheets) plus the 999px pill.
- `OffTokens`, a register for values deliberately outside the token system,
  each carrying its reason in code rather than a silenced lint. First entries
  are the rewarded-ad canvas and its countdown ring, which keeps the Dark Roast
  accent in both moods because the ad canvas is fixed near-black.

### Changed

- **"Practice any lesson" lists the lessons you have finished** — and
  replaying one from there counts, exactly as replaying it from the course path
  does. It used to list all 32 lessons including ones never unlocked, running
  them in a mode that recorded nothing; the design has always described this
  section as completed work to revisit. Renamed to *Practice a finished
  lesson* to say so.

- **Opening a lesson is expressed once.** Four places built lesson URLs by
  hand — path segments spelled out, the replay and practice flags appended as
  query strings — so renaming a route compiled perfectly and broke at the tap.
  Each way of opening a lesson is now a named destination carrying its own
  mode, and no caller spells a path out. Nothing changes for the learner: every
  destination resolves to the exact URL its string produced, which is what the
  tests assert.

- **Finishing a lesson records a day, not a number.** A first completion and a
  completed replay both write themselves onto the day's activity record and
  mark the day active; the streak is folded back out of that set wherever it
  is shown. Replays qualify every time, which is the rule that lets a streak
  outlive the last authored lesson. The settings row's `streakDays` and
  `lastActivityDate` are no longer written or read.
- **An existing learner's streak survives the move.** The day set the streak
  folds over is gathered from three sources at read time — the stored day set,
  the days the activity record still qualifies, and the days of every recorded
  first completion. The third is the backfill: an install that finished
  lessons before anything wrote a day has a full history and an empty day set,
  and without it the update would silently read every one of those streaks as
  zero. It is a union, so it can only ever add a day, and a read-time one, so
  there is no migration to half-apply. Reset clears the completion records
  along with the day set, so it cannot resurrect a streak the learner asked to
  be rid of.
- **One writer for a completed activity.** Lessons, replays and mini-game runs
  now go through the same record-a-completion path, so the qualifying question
  is asked once and a surface that registers later — vocab, flashcards —
  inherits the rule rather than restating it. The activity record also
  finally **prunes on write** to the last couple of days, as it was always
  documented to; the day set the streak folds over is never pruned.

- **Retry is gone.** A card latches irreversibly the moment the learner commits,
  and continuing is gated on that latch — no card offers a way back to an
  unanswered state, and the Try Again and Reset controls are removed. "How many
  did you get right" now has exactly one reading, so *first-try correct* is
  simply *correct*.

- **Reset Progress now clears what it says it clears, and a wipe reaches the
  learner's other device.** Reset wipes every progress field outright instead
  of relying on it recalculating to zero, and keeps the grove, the companion
  and every device-local preference. Both wipes publish an empty snapshot at
  the next reset generation rather than removing the stored one — a record that
  simply vanished reads elsewhere as a fresh install, and that device would
  hand the deleted progress straight back. Delete Account is the same mechanism
  at full scope, plus the device-local settings; its screen is still to come.
- **Module rows no longer signal completion with colour.** The filled accent
  square gives way to a bare glyph — muted when locked, accent otherwise — and
  a finished module goes quiet instead of lighting up, dropping its trailing
  chevron and its lesson-count line. Completion is announced to screen readers,
  which would otherwise hear nothing once both markers are gone.
- **A lesson's score is stored as `{correct, total}`, not a percentage.**
  Mastery bands on the number of wrong answers — 0 perfect, 1 solid, 2+ needs
  practice — because the design's 80% pass mark is unreachable in 14 of 31
  lessons, where a single mistake dropped a learner straight to "needs
  practice". Existing rows are not converted: the old percentage measured a
  different thing, so they read as unscored rather than inventing a result.
- Type collapses to a **nine-step ladder** — `AppText.hero · display · title ·
  heading · lead · body · support · label · micro` at 56 / 30 / 26 / 19 / 17 /
  15 / 13 / 11 / 9.5 — replacing `AppTypography`. There is no `fontSize`
  parameter anywhere in the API: sizes live in one private table, so going
  off-ladder means editing the ladder rather than passing a number at a call
  site. The eight off-ladder sizes the app was using are snapped onto it.
  Typeface is a separate axis (`AppFace`), because the design sets one step in
  more than one face — and a slot inside display type can inherit the
  surrounding face instead of asserting its own.
- `AppStrings` is now **`AppLabels`**, matching what it holds: user-facing
  labels rather than arbitrary strings.
- CI gained a **changelog job**: a pull request that changes `lib/`,
  `assets/content/` or `pubspec.yaml` now fails unless it adds an entry here.
  Generated Dart does not count, and the `no-changelog` label skips the check
  for refactors, formatting and regenerated output. Runnable locally as
  `tool/check_changelog.sh`.
- `AppTheme.lightTheme` is now `AppTheme.darkRoast` — the old name described a
  `Brightness.dark` theme.
- App code no longer reads `ColorScheme`; it stays populated purely so stock
  Material widgets are styled.
- Text styles take the ambient mood (`AppTypography.body(context.mood)`)
  instead of defaulting to hard-coded dark-roast ink.
- **The app is BrewPath.** The Dart package is `brew_path` (was
  `coffee_quest`), and the name is swept through code, tests, docs and the
  release tooling.
- **The Flutter app lives at the git root**, with no nested `coffee_quest/`
  directory; CI runs from the root. Paths in the released sections below are
  written against the old layout — they are left as they shipped.
- Lint stack moved from `flutter_lints` to **`very_good_analysis` +
  `dart_code_linter`**, with the DCL metrics (complexity, nesting, function
  size, magic numbers) calibrated to this codebase and CI failing on warnings.
  The existing code was remediated to satisfy them.
- `tool/release.sh` was rewritten as **`tool/release.js`**, run with `node`.
- The design prototype was restructured to the **30-lesson syllabus**, and the
  `docs/design/` reference regenerated to match it.
- Dependencies refreshed — `flutter_riverpod` 3.3.2, `riverpod_annotation`
  4.0.3, and `riverpod_generator` off its `-dev` release onto 4.0.4.
- Everything that must **not** flip with the mood — illustration colours, fixed
  overlays, spacing and radii — is now `static const` on an `abstract final
  class` with no `of(context)` accessor, so mood-dependence cannot be written
  rather than being merely discouraged. A test enforces it, and the colour and
  radius tests read `brew-path/index.html` directly, so a value drifting from
  the design bundle fails the suite.

### Fixed

- **The smoke suite runs again, and CI now notices when it does not.** All
  three integration tests had been failing since the app rename, and nothing
  ran them — `flutter test` covers `test/` only, so every pull request stayed
  green while the one suite that boots the real app was broken. It is the only
  thing that exercises a real on-disk database, the asset bundle as it ships,
  and the platform plugins; onboarding has no other coverage at all. A run is
  now a few seconds of actual testing rather than the ten minutes a hang
  disguised it as — the job itself is dominated by the cold Xcode build — and a
  macOS job runs it on every push to main.

- **Your streak is right when you come back the next day.** The streak, the
  freeze you are holding and the Keep Sharp recommendation are all worked out
  for *today* — and the app never worked them out again when you returned from
  the background. Leave it open overnight and it greeted you with yesterday's
  streak until something else happened to refresh it. It now recomputes them
  when you come back on a new day, and only then: an ordinary switch away and
  back changes nothing. An app left in the foreground across midnight still
  waits for your next tap.

- **Finishing a lesson counts however you got there.** Whether a run was a
  first completion or a replay used to be read off the URL, and a finished
  lesson opened without the replay marker produced a run that recorded
  nothing — no day, no mastery, no points. The app now decides from what the
  learner has actually done, so a deep link or a hand-typed address cannot
  cost a streak day, and there is no longer a flag for a caller to get wrong.
  What each path pays is unchanged.

- **One field list for the progress scope.** Two writers each copied the
  snapshot's progress scope field by field, so a change that renamed a field
  updated one and left the other naming something gone. Both now share a
  single private copy, and a test drives each over a fully populated scope: a
  forgotten field fails a test rather than silently dropping the progress the
  other write was not about.
- A lesson's **best result could disagree between two devices, permanently**.
  Two different scores can share a mastery band _and_ a percentage — three
  wrong out of six is the same 50% as two out of four — and the old comparison
  had no answer for that, so each device would keep its own and neither would
  ever win. Best results now settle on fewer wrong answers, and on the longer
  run when even that ties.
- A locked module could read as complete when its own lessons were all
  finished but a prerequisite had regressed — for instance after a content
  update adds a lesson. It now reads as locked, which also corrects the Path's
  completed-module count.
- The current node on the Path rail drew its play arrow in its own background
  colour, leaving the glyph invisible. It is an outlined node now, per the
  design.
- Correct-answer feedback in the mini-games used a raw Material green instead
  of the design's `sage`.
- The loading-screen water drop used two mis-transcribed hexes; both now match
  the design bundle.
- Hairlines that resolved to `outlineVariant` painted in full-strength ink
  rather than the `rule` token.
- The CI format job ran `dart format` before `flutter pub get`, so it read the
  wrong language version and failed on files that were correctly formatted. It
  had been red on `main` for over a week.
- Roasty's points burst drew its "+15 XP" label in a font family no `fonts:`
  entry declares (`IBMPlexMono`, without the spaces). Flutter does not throw on
  an unknown family, so it had been rendering in the platform fallback with
  nothing to signal it. The font guard now checks every family named anywhere
  in `lib/`, not only the ones the type ladder asks for.
- A Drift migration step was guarded by `from < _schemaVersion` rather than the
  version that introduced it, so the next schema bump would have re-run the
  v2 → v3 column adds on a device already at v3 and failed on the duplicate
  column. Each step now names its own version.

### Removed

- **Roasty's points-earned pose is gone.** It painted a rising chip reading a
  hardcoded payout — a number no rule produced. #16 ruled that literal dropped;
  the points rework renumbered it from `+15 XP` to `+10 PTS` instead, fixing the
  word and keeping the defect.

  Deleting rather than wiring it: the pose was unreachable — nothing in the app
  ever fired the reaction that selects it — and the lesson result screen already
  plays its own celebration, so a second one is a decision about what it
  displaces, not a cleanup. A points moment, if ever wanted, gets authored
  against a screen chosen for it and reads the real payout.

  A test now fails if any companion source states a points amount again.

- **The last two fields of the old streak engine are gone from the database.**
  `streakDays` and `lastActivityDate` sat on the settings row long after the
  streak moved onto the day set it derives from — read, written back and zeroed
  by a reset, but never advanced by anything. Schema v7 drops both, and the
  progress reset stops touching the settings row at all: everything it used to
  clear there is now derived from what the reset already empties. What is left
  on that row is what the learner *chose*, which a reset keeps.

- **Practice mode.** A third way to finish a lesson that deliberately recorded
  nothing — no score, no points, no streak. It existed for the practice list
  and Keep Sharp's replay button, and both now open a real replay, so whether
  a completed replay counts no longer depends on which list it was started
  from. There is no remaining way to reach a lesson's final card and have it
  count for nothing.

- **Practice by game type.** The cross-lesson drill — pick a question kind, get
  every step of that kind scraped out of the lessons you happened to finish —
  and its section on the Learn tab are gone, along with its route and the
  provider counting its material. The design has no such screen: it was empty
  on day one, different for every learner, assembled from leftovers rather
  than authored, and it wrote nothing. The seven authored mini-games cover the
  same ground with hand-written rounds. Its last caller was Keep Sharp, which
  now opens a real game.

- **`StreakService`.** It advanced a stored counter off a stored last-activity
  date, counted lessons only, and hard-reset on any gap — no freeze, no
  replays, no practice, and a shape that cannot merge across two devices. Its
  own doc comment admitted the gap. Replaced by the derivation above, not
  adapted.

- **Favouriting a collectible card.** The heart on the card detail screen, and
  the in-memory store behind it, are gone. The design has no card favouriting
  at all — only lessons, dictionary terms and training guides are saveable, and
  they belong to the Saved shelf, which this was never part of. It was the last
  remnant of the card-favourites screen already dropped earlier.
- The 6 unused legacy colour tokens (`coffeeBrown`, `espresso`, `latte`,
  `cream`, `surface`, `locked`).
- `AppColors` itself. Its one remaining token, `--cream`, is now
  `ArtColors.cream` alongside the rest of the illustration palette.

---

## [1.0.0+3] — 2026-06-08

### Added

- `riverpod_lint` static analysis, enabled via the native analyzer `plugins:`
  block in `analysis_options.yaml` (analysis_server_plugin — no `custom_lint`).
  Previously deferred by the custom_lint/analyzer-9 gap.

### Changed

- Moved the code-gen toolchain onto analyzer 12: `riverpod_generator` + `freezed`
  to their analyzer-12 `-dev` releases, `drift`/`drift_dev` 2.30 → 2.33 (+
  `drift_flutter` 0.3, `sqlite3_flutter_libs` 0.6), `json_serializable` 6.13 →
  6.14 (`json_annotation` 4.12). Drops the pins that had held the project in the
  analyzer-9 window. CI Flutter 3.44.0 → 3.44.1.
- Loading wake-up animation now grows Roasty's sprout out of its head during the
  grow phase (new host-driven `sproutScale`).
- Onboarding screens reorganized into per-screen folders with their orchestration
  pulled into extracted controllers (`GoalController`, `BrewerController`,
  `WakeSequenceController`), each unit-tested.
- Stricter analyzer linting — added `require_trailing_commas`,
  `always_declare_return_types`, `prefer_const_constructors_in_immutables`,
  `avoid_redundant_argument_values`, and `unawaited_futures` (codebase reformatted
  to match).
- Developer docs reorganized — common dev commands and run-time flags (e.g.
  `LOOP_LOADING`) now live in `coffee_quest/README.md`; `CLAUDE.md`/`AGENTS.md`
  slimmed to point there.

### Fixed

- `flutter analyze` no longer reports errors from the vendored Firebase Swift
  Package sources under `ios/build/` (analyzer now excludes nested `build/`
  directories).

---

## [1.0.0+2] — 2026-06-03

### Added

- Loading screen with a cycled "coffee bean cracking in two" animation, shown
  until the app finishes loading.
- Welcome hero screen for first launch.
- `coffee_quest/tool/reset_ios_spm.sh` — helper to reset the iOS Swift Package
  Manager state when native builds get stuck.
- `coffee_quest/tool/release.sh` — release helper that bumps the version + build
  number in `pubspec.yaml`, stamps the Unreleased section with the new version
  and date, and (with `--commit`) commits and tags the release.
- Changelog tracking workflow — this `docs/CHANGELOG.md` plus a `/changelog`
  helper that drafts Unreleased entries from real code diffs rather than commit
  messages.

### Changed

- Redesigned the UI/UX of all four tabs — Learn, Path, Cards, Profile — plus the
  Settings screen.
- Reworked scrolling behavior across screens.
- Reworked XP: corrected total-XP accumulation, adjusted XP-per-lesson
  calculation, and fixed "today's lesson" selection logic.
- Consolidated the welcome flow down to a single welcome screen variant.
- Migrated the iOS native build from CocoaPods to Swift Package Manager
  (no more `Podfile` / `pod install`).

### Fixed

- Repaired a broken test after the XP logic changes.

---

## Build Milestones

The initial product was built in numbered phases (0–11). All are complete except
Phase 8, whose Firebase code is written but gated off behind `kUseFirebase`
(activation is a manual user step). This table is the historical record of that
build; see `docs/archive/16-claude-code-task-plan.md` for the original
phase-by-phase plan.

| Phase | Status           | Description                                                                                                       |
| ----- | ---------------- | ----------------------------------------------------------------------------------------------------------------- |
| 0     | ✅ Done          | Prerequisites verified                                                                                            |
| 1     | ✅ Done          | Project scaffold, routing stub, theme                                                                             |
| 2     | ✅ Done          | Content models, JSON assets, ContentRepository                                                                    |
| 3     | ✅ Done          | Drift persistence, repositories, providers (replaced abandoned Isar)                                              |
| 4     | ✅ Done          | Domain logic: XP / streak / completion services, providers                                                        |
| 5     | ✅ Done          | Navigation: StatefulShellRoute app shell, 4 tabs, analytics observer                                              |
| 6     | ✅ Done          | Feature screens: Learn / Path / Cards / Profile + lock / settings / version providers                             |
| 7     | ✅ Done          | Lesson runner, 4 mini-games, completion screen, immersive lesson route                                            |
| 8     | 🚧 Code complete | Firebase services (Analytics / Crashlytics / Remote Config) behind abstractions; activation pending (`kUseFirebase`) |
| 9     | ✅ Done          | Ads & Payments service stubs (NoOp active; in_app_purchase / AdMob impls deferred)                                |
| 10    | ✅ Done          | Test suite (52 tests) + `integration_test/smoke_test.dart`; on-Simulator smoke run pending user                  |
| 11    | ✅ Done          | CI: 3-job `ci.yml` (format / analyze+test / iOS build); CocoaPods → SPM migration                                |
