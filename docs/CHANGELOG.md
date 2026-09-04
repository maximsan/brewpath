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

- **Flashcards explains an empty deck it used to blame you for.** If you
  bookmarked words your free lessons do not cover, the drill still told you to
  "bookmark terms in the dictionary and they become a flashcard deck" — which
  you had just done. It now says the terms you saved are not in your free
  lessons, and names the two things that would change that: save a word one of
  your lessons mentions, or unlock the full course. With nothing saved at all,
  the original wording is unchanged.
- **A shared BrewPath link opens the app, on the thing that was shared.** Tap
  `brewpath.maximsan.dev/card/<id>` with the app installed and it opens that
  collectible rather than a web page; without the app, the link goes to the App
  Store. A card you have not earned yet shows you its face — the art, the name,
  and the lesson that earns it — and keeps back the summary and the keepsake
  line, because those are the reward for finishing the lesson and card
  addresses are guessable. Sharing something the other person already has would
  be pointless, so showing them nothing was the one thing that could not stand.

  The link now survives being interrupted. Someone who installs the app
  *because* a card was shared with them used to lose it at the welcome screen —
  they onboarded and never saw the card. It is held through onboarding and
  opens when they arrive. A link naming a card the installed build has never
  heard of leaves them on the collection instead of an error, because a newer
  build can mint an address an older one cannot resolve.

  Sharing your streak now carries a link back to the app, where before it was a
  picture with no way home.

- **Locked lessons now say why they are locked.** Path looked the same whether
  or not a lesson was yours, so the only way to find the wall was to walk into
  it. Lessons and modules you have not bought now show a mark, say *Part of
  Foundations*, and open the offer when you tap them. What a row says depends on
  who is reading it: if you own the course, a module you have not reached still
  says *"Finish Beans to unlock"*, because that is something you can go and do.
  A lesson you have already finished never locks.

  The Reference shelf has stopped promising something it cannot give. It used to
  tell everyone that guides "unlock as lessons teach them". That was not true if
  you had not bought the course — the first guide is taught by the sixth lesson,
  and only the first three are free. Now it says the guides come with the course.
  If you own it, it names the lesson that opens the next one.

- **The dictionary has a Term of the Day.** A card at the top of the shelf
  offers one word each day — what it is, how to say it, and what it means —
  and opens a page of its own where you can save it or go on to the full
  entry. The word changes at midnight, walks the whole dictionary before it
  repeats, and is the same on every device you own, because it is worked out
  from the date rather than stored anywhere. Which words are on offer depends
  on what you have bought: the course opens up the reference words no lesson
  teaches. Reading it does not count toward your streak — it is something to
  notice, not a task.

- **Your saved terms are a flashcard deck now.** Bookmark a word in the
  dictionary and it joins a deck you can flip through: the term on the front,
  what it means on the back, and a link to the full entry once you have
  answered yourself. Reach it three ways — a chip on the dictionary, a row
  under the terms on your Saved shelf, and a free row in Learn's practice
  list — and Today can recommend it once you have cards. Finishing a review
  marks the day for your streak, the same as any other practice; walking away
  part-way through counts for nothing, because you have not reviewed the deck.
  Nothing is graded and nothing is scheduled: a flashcard teaches, it never
  marks you.

  The deck is what you saved *and* can reach, so a word from a lesson you have
  not done yet waits until you have done it. With no cards, the drill still
  opens and explains what a deck is made of rather than turning you away.

- **The dictionary has a game now.** *Guess the term* reads you a definition
  and offers four words; you pick the one it describes. Choose a deck — the
  terms you bookmarked, or everything you can reach — and how long a round runs
  (5, 8 or 12), and only the lengths your deck can honestly fill are offered,
  so a round never repeats a word to reach its number. Get one wrong and it
  names the right term and offers you the full entry rather than just marking
  you down. Finishing a round protects your streak, the same as a lesson does;
  walking out mid-round counts for nothing.

  What the game may ask you about is what your lessons have actually reached.
  A free learner is drilled on the words their three free lessons say — and the
  wrong answers come from that same set, so the game never quietly shows a term
  it has not taught. With the course, it draws on the whole glossary. If your
  lessons have not yet reached four words, the game says so and points you back
  at them instead of padding the round out with words you have never met.

  It is reachable from a chip on the dictionary's home, from a free row leading
  the Learn tab's practice list, and from Today when it is the day's
  recommendation.

- **The app now says on the record that it collects nothing.** Apple requires a
  privacy manifest before a build can go to the store, and BrewPath ships one
  that declares the truth: no tracking, no collected data, and a single
  required-reason API — SQLite reading the size and date of its own database
  file, which is how it opens the file at all. Firebase is compiled in but still
  switched off, so there is nothing for it to declare. Turning telemetry on is
  what would change this file, and the store's privacy labels with it. The build
  now fails if the manifest ever stops reaching the app, because the alternative
  is finding out from a rejection email.

- **Profile closes on the two doors the design gives it.** Under the streak and
  the challenge row there are now entry cards for the Studio and for Saved —
  each an art well, an accent kicker, what it opens and a line saying what is
  behind it. Saved counts what the shelf actually holds and opens it, so the
  things you kept are findable from the page about you rather than only from a
  bookmark in the header. The Studio door already existed; it now shares one
  row pattern with Saved instead of carrying its own, so the two cannot drift
  apart. It also keeps its Plus mark and still raises the offer rather than the
  chooser — Saved carries no mark, because the shelf is free for everyone and
  what Plus lifts is the cap on saving past five.

  Terms and Privacy on the Plus sheet now wrap onto a second line instead of
  running off the edge when the text is scaled up.

- **You can hear how a term is said.** Twenty-four of the dictionary's
  seventy-three words carry a pronunciation, and the respelling beside them is
  now a speaker you can press. It is the phone's own voice, offline — nothing
  is recorded, nothing is sent, and no permission is asked, because speaking
  aloud needs none. It reads in the language the course is written in rather
  than the one the phone is set to, so an English term is not pronounced as
  though it were French. Pressing again restarts the word instead of stacking a
  second reading behind the first, and a term with no respelling shows no
  control at all. Where a phone has no voice installed for the language, the
  respelling still reads as text — only the speaker goes, because a button that
  cannot do its one job is worse than none.

  The respelling also shows on the list rows now, next to the word rather than
  under it: scanning a list is where you meet a term you cannot say.

- **Hitting a lock now offers something.** A free learner whose shelf is full
  used to get a one-line snackbar; they now get the Plus gate — a sheet that
  opens on *what they just hit*, then makes the case for the course: the rest
  of Beginner Foundations first, practice depth second, the Studios and the
  bigger shelf last. One action, buy. No trial, no subscription, no plan to
  choose between and no watch-an-ad path, because v1 sells a single one-time
  purchase. Restore, Terms and Privacy sit under it, as the App Store requires.
  Every number the pitch says — lessons left, games locked, reference terms,
  the shelf cap — is counted from the shipped content, so authoring a lesson
  can never make the paywall lie.

- **You can choose what grows in your grove.** Profile gains a Studio door
  onto *Your grove*: three coffee species and four lights, with the plant drawn
  live under whatever you are considering — full-grown, so you are choosing the
  tree you end up with rather than the seedling you start as. Each species
  carries its real botany: the binomial, its share of the world's cups, where
  it comes from, how it grows and what it tastes like. Nothing is written until
  you confirm, and the confirm stays dark until the draft actually differs from
  what is planted, so backing out costs nothing and re-picking what you already
  have is not offered as a change. Every plant grows through all ten stages
  either way — the choice is what it looks like, never how far it gets.

  It is part of Plus. For everyone else the door is marked, and tapping it
  opens the same offer every other lock does — naming the Studio, then making
  the case for the course.

- **The Coffee Tree has its own screen.** Tapping the tree on Profile opens it:
  the stage's name — Seed, Flowering, Near harvest — the tree at hero size, how
  far through the core course you are as a bar that fills, what the next stage
  is called, and a ten-rung ladder of the whole climb. It explains, in the
  design's own words, that only first-time lesson completions grow the tree and
  that replays sharpen mastery instead. The tree also **sways** now, gently and
  forever, on the one screen you sit on — the Profile hero stays still, as the
  design has it, so a tab you leave open carries no permanent animation.
  Reduced motion holds the tree upright and fills the bar instantly.

- **Settings has the four screens its rows always implied.** Account and sync,
  Purchases, Help and support and About now exist and open from the rows that
  name them, instead of being sections the app had no destination for. They are
  frames rather than finished screens: each carries its real title and section
  headings, and says in a line what is still to come. The **App Guide** moved
  into Help and support, which is where it belongs — it sat on the Settings
  root only because that screen did not exist yet.

- **A daily reminder can be asked for.** Settings gains a Notifications switch
  and a Daily reminder row that opens a sheet of eight times to pick from. The
  choice is remembered; nothing is scheduled yet, because whether reminders
  ship at all is still an open question.

- **The app opens on a welcome screen it never had.** The first screen a new
  learner saw was the mascot's introduction wearing the welcome screen's slot:
  it led with *"Plant your tree."* and copy about Roasty, and the screen that
  says what the app actually is did not exist. There are two screens now, in
  the order they were designed. **Welcome** opens on the seed-to-tree film —
  framed the way the design frames it rather than cropped square — over
  *"Learn coffee. / Grow a tree."*, and the whole screen advances on a tap,
  with nothing to press. **Meet Roasty** follows with the mascot, what he is
  for, and one way on. Roasty no longer appears on the first screen at all; his
  arrival is the second screen's whole point.

  The loading screen now says it can be skipped. It has always been tappable
  and never mentioned it — the brand mark at its foot becomes *tap anywhere to
  continue* once a full wake-up has played, so a learner waiting on a slow
  start is told what to do instead of guessing.

  The film on the welcome screen can be heard. It has always had an audio
  track and no way to reach it; the design's mute control sits on the frame
  now, and the sound is cut on the way out so it never follows you to the
  next screen.

  A dead *Restore* link that went nowhere is gone.

- **The sticky action bar, and the course ending is the first screen on it.**
  The design closes a scrolling screen with one pinned action over a gradient
  that fades from the page colour to nothing, so text passes *behind* the
  button instead of stopping above it. Six screens want it and the app had
  none, so each was about to grow its own. There is one now, and it takes a
  single action plus an optional quiet link — a second button is not something
  a screen can ask it for. The Foundations ending moved onto it: its Continue
  used to be a plain footer that content stopped dead above, and the last of a
  long celebration is now reachable rather than pinned behind the button.

- **The lesson cards are drawn the way the design draws them.** Answering a
  multiple-choice question now tints the row you picked — green for right, a
  softer red for wrong — instead of only outlining it. The opening guess of a
  lesson is two large tiles side by side rather than a list, the one you did
  not take dims instead of vanishing, and you can change your mind until you
  move on; nothing there is scored. A matched pair on a match card reads as
  solved rather than greyed out. On a select-all card, an answer you missed is
  outlined in dashes so it never looks like one you got right, and the card
  shows a single button that changes from *Check answers* to *Continue* rather
  than two.

- **Two more card kinds reach the lesson.** Fifteen authored cards sat in the
  banks with no renderer, so every one was filtered out before a lesson
  started. **Hands-on cards** now render: a step's name, what to do, and a
  closing "Worth knowing" note — read, not asked, so Continue is live on
  arrival and nothing is scored. **Select-all-that-apply cards** now render
  too: pick freely, commit the whole set with *Check answers*, and the card
  marks every choice — including the answers left unpicked, so a learner who
  under-picked can see what they missed. It scores all-or-nothing and pays
  once; a correct subset, a superset and a same-sized wrong set all score
  nothing, so neither picking cautiously nor picking everything is a strategy.

  Because select-all cards are graded, ten lessons regain a graded card each
  and now score out of what the course always specified — m1l2, m1l3, m1l5,
  m2l1, m2l3, m2l5, m3l1, m3l3, m4l2 and m4l6. A best already recorded is not
  disturbed: it stands until a run on the fuller lesson beats it.

- **Twenty-six dictionary terms gain their depth.** Each now carries the long
  explanation, the everyday example, the sources it rests on and a self-check
  question — the material the entry screen was already built to show. The app
  has read these fields all along; the shipped banks predated them, so the
  screens had nothing to render. Twenty-five entries also carry edited copy,
  and one lesson's line on fermentation is reworded.

- **The visual guides appear in the lessons that teach them.** Ten authored
  cards sat in four modules with no renderer, so every one of them was
  filtered out before a lesson started — the diagram was missing from the
  one lesson built to explain it, and only turned up later on the Reference
  section. They now render: the guide's drawing at full width, its caption
  above or below as authored, and a bookmark that keeps the guide under the
  same key its sheet writes. The cherry-anatomy card merges its header with
  the guide's, so the same title is not said twice. Nothing here is graded —
  a reference is shown, not asked, so Continue is live on arrival and
  mastery is untouched.

- **The cherry's six layers and the caffeine table reach the app.** The
  cross-section's layer names, latin names, fates and notes were authored
  beside the drawing that reads them, in a file the guide extraction never
  opened; the caffeine guide's servings and milligram figures sat in a field
  it never named. Both now ship in the guide bank — so a guide titled
  *Caffeine, Per Serving* finally carries its servings, and the cross-section
  has content to reveal. The extraction refuses a run where a layer loses a
  word, where the layers are not six outside-in, or where a serving figure is
  not a number.

- **Read the green bean.** An unlabelled bag, a sample of three seeds drawn
  from the round's own description, and three things worth inspecting — colour,
  centre cut, aroma — each hidden until tapped. Call the process from the look
  alone, and the feedback names which cue was the real tell. The bag keeps its
  process hidden until the call is made, and calling it without opening a single
  cue is a perfectly good way to play.

- **Fix the cup.** Tastefix rounds play: what the cup is doing wrong, the setup
  that rules out the obvious causes, and four fixes to choose between — with the
  reason named either way. Two more games open on the one renderer, the
  pour-over cup and the shot.

- **Name the note, and the free tier's missing seven rounds.** Flavor rounds
  play: a tasting clue, four notes, one commit, and the explanation either way.
  That lights up both games authored against the kind — *Name the flavor notes*
  and *Name the origin* — and the second of those is the third game the free
  tier has always advertised and never been able to open. Free practice went to
  18 reachable rounds from 11, which is the number ADR-0007 promises, and a test
  now holds it there.

- **Dial it in, and Put it in order — the last two formats.** Calibrate rounds
  play: drag along the scale, watch the setting read back as something concrete
  ("Sea salt — pour-over", not 71), and commit. The card then names the target
  and draws the band it accepted, so a near miss is visible rather than merely
  reported. Grind rounds draw the grinder's own collar above the track, counting
  clicks as the setting moves. Sequence rounds play too: tap the steps into
  order, take one back out if you change your mind and the rest renumber,
  submit, and see which places were right — a misplaced step says where it
  belonged, and the whole correct order is spelled out either way. Both grade
  all-or-nothing and pay once, like every other graded card, and both react
  inside the card when the answer is wrong.

  A sequence round is authored in its own answer, so the opening order is drawn
  from the run's seed **and checked against the solution** — no round can open
  already solved.

  With these two, every card kind in the app draws, and all 13 mini-games play.
  Four more games opened on the two renderers: *Dial it in*, *Set the grind*,
  *Put it in order* and *Pour-over, in order*.

- **Finishing a lesson finally says what you did.** The screen was a badge, the
  words *Lesson complete!* and a points number: it never named the lesson you
  had just finished, and it only showed your score if you were replaying. It
  now opens on a full-screen beat from Roasty whose line changes with how the
  run went, then names the lesson, prints the score, and gathers what the run
  paid into one receipt card — the points, and any collectible it handed over.
  A run that needs practice gets a chip in the action colour and an invitation
  to play it again rather than a red mark, and there is a close button now, so
  the celebration is not a screen you are held on.

- **The tree grows when you finish a lesson.** The completion screen never
  mentioned the Coffee Tree, which is the thing the whole app is a metaphor
  for. It is on the screen now, and on the completion that crosses a growth
  threshold it grows — the new stage fades up, settles, rings, and throws a few
  leaves. Most completions do not cross one, so a still tree says how far the
  next stage is rather than sitting there looking broken. Reduced motion keeps
  the fade and drops everything that moves.

- **The tree stopped finishing early.** Its ten stages were spread evenly over
  the thirty-two lessons, so it reached full growth at lesson twenty-nine and
  the last three lessons of Foundations grew nothing at all. The stages are
  pinned to the five modules the way they were designed to be — one step at
  each module's halfway point, one when you finish it — so a module boundary is
  always a visible jump and the harvest waits for the final lesson.

- **The card you just earned can be read where you earn it.** The completion
  screen listed a new collectible by name and left you to go and find it. The
  row opens now, onto the full card — its badge, its summary, and the keepsake
  line the app has always assembled and never once shown.

- **You meet the word "freeze" before you ever need one.** Seven qualifying
  days in a row earn a streak freeze, and the app only ever mentioned freezes
  *afterwards* — as the notice telling you a day had already been saved. The
  lesson that earns one now says so on the spot, which is where the design put
  it: the payout for keeping a streak, met before the day you need it rather
  than at the moment you are told you lost one.

### Changed

- **Both endings now read as one screen, and both turn over.** Finishing a
  lesson and finishing a module used to look like two unrelated celebrations.
  What you earned beyond the lesson itself — a streak freeze, a new card, the
  optional challenge — is now one quiet list of plain rows rather than a
  bordered receipt of icons and labels, and your points sit directly under the
  tree they fed. The card a lesson hands you lives on the **back of the
  screen**: the New-card row turns it over, the same way the module ending
  does, instead of covering the celebration with a sheet. A run that went badly
  is offered "Practice this lesson again" as a real button under the way
  forward, and the screen no longer stamps a "needs practice" badge next to
  your score — the score already said it, and the button is the invitation.

  Two smaller consequences. The optional challenge is now a single row you
  either take or scroll past, so the separate "Save for later" is gone —
  declining is just carrying on, and the challenge waits on the Path either
  way. And the module ending no longer re-announces the collectible its last
  lesson gave you: it is still yours and still on the Cards tab, but that
  moment is already handing you the module's own card.

- **Visual guides explain each level under the drawing, not in a table.**
  The roast and grind guides used to show a label/value table (`LIGHT ·
  Bright · acidic`) with each level's explanation tucked under its row. The
  design dropped that table, so the sheet now lists each level's name beside
  its explanation, directly under the illustration. The content banks no
  longer carry a guide `meta` field; the content schema moves to 2, and a
  build reading the old banks refuses them at startup rather than showing a
  guide with a hole in it.
- **Finishing a module is one celebration, not two.** The last lesson of a
  module used to play its own ending — mascot, score, points, card — and then
  hand you straight to the module ending for a second mascot and a second
  celebration. Now it plays one: the module ending, which also reports what
  that final lesson paid, so nothing you earned goes unmentioned. Its tree
  grows as well, where before it stood still because the lesson ending had
  already played the growth.

- **Roasty reacts when you answer, and every graded card closes the same way.**
  Answering used to end in whatever the card felt like — one said `ALL CORRECT`
  in green, another `Called it.` in amber, the match board wrote a sentence, and
  the dictionary's self-check just revealed its explanation with no verdict at
  all. Now every one of them ends on the same block the design draws: the mascot
  taking the news, the verdict in small caps, then the explanation. Roasty had
  never once reacted to an answer in the app; he does now, on all eleven graded
  kinds. The verdict is also spoken on every surface, which matters most where
  right and wrong differ only by colour — and the self-check, which said nothing
  aloud before, now says how it went.

- **Finishing a module is a moment again.** The recap was a companion, a
  heading, a 72-pt badge and a caption. It is now the ending the design draws:
  Roasty holds the screen with *"Look how far you've come."*, then the module's
  own name leads over the coffee tree — and a card is waiting on the other
  side. Turning it over rotates the whole screen to reveal the collectible as a
  full reward card, with its spec rows and its keepsake line, and the way on
  reads *Begin next module* or *Back to Path* rather than always *Continue*.
  Reduced motion gets the far side without the rotation.

- **Small-caps labels are lettered by the design, not by eye.** Sixteen kickers
  and eyebrows across Today, the challenge cards, the lesson cards, the mini-game
  catalogue, the dictionary and the Cards tab each picked their own
  letter-spacing —
  between a third and a half of what the design asks for, so a row of caps read
  as crammed. The type ladder now carries tracking as its own axis beside size
  and face: a label takes the design's small-caps spacing unless it is one of
  the few lines the design tracks differently, and a test fails if a new screen
  letters its own. Nothing moved on the two lines that really are exceptions —
  the tab bar and the tap cue.

- **The `MISSED` tag joins the answer it marks.** On a multi-select the row you
  should have picked is green to its border, its box and its check — and then
  said `MISSED` in small grey type, reading as a separate remark rather than as
  the mark's own word. It is now green, and a size smaller, which is what the
  design asked for all along.

- **The path looks like a path.** Lessons on Path were separate cards; the
  design threads them on one hairline spine that each lesson's bean punches a
  stop out of, which is what makes a list of them read as a route rather than
  a stack. The row you are on is washed in the accent and says *CURRENT*, and
  one that needs practice says so in a word. The rows drop the minutes, the
  points and the *Review* button — those belonged to the module screen, where
  you were picking a lesson; here the course is the subject.

- **Each kind of game is headed by its own glyph.** The practice shelf grouped
  games by kind but headed them with words alone, because only three of the
  seven kinds had a mark: the other four are drawn in the running prototype
  rather than in the design-system catalogue the icon extractor reads. The
  extractor reads both now, so *Blind bag*, *Taste fix*, *Calibrate* and
  *Sequence* have their marks and every group wears one. A kind can no longer
  be added without one.

- **The lesson ending's button moved onto the shared sticky action bar**, and
  now says where it goes: *Next lesson* while the course has one queued, *Back
  to Path* when it does not. The Coffee Challenge a lesson sometimes unlocks
  travels with that button instead of sitting in the scroll above it — the bar
  learned to carry an offer over its action, which the duel and the module
  ending will want too, and it still refuses a second button.

- **Profile leads with the tree, and the streak gets a card of its own.** The
  tab opened on a bare illustration and then four small tiles of numbers. The
  tree is now a card that names the stage it has reached and how far through
  the course that is; the streak has the full-width card the design gives it,
  carrying the steam mark, the day count and the week; and the three remaining
  tiles collapse into one quiet line of lessons and points. The screen closes
  with the month you joined. The whole tab also moves onto the 24-point gutter
  the design uses and the other tabs already keep, so everything on it — the
  challenge row and the preferences grid included — sits a little wider.

- **Mastery has a home outside the moment it is earned.** A card under the
  streak shows how many lessons are solid and how many want another run, as one
  bar, and taps through to the Path to practise them. It stays away until a
  lesson holds a score — an empty bar under a heading reads as "you are behind"
  to someone who simply has not started. Solid means at most one wrong answer,
  which is the band the app already scores on; the design's 80% rule is
  unreachable in 14 of 31 lessons and is not what is measured here.

- **The course lives in one place now, and Today is only today.** The app used
  to list every module on the Learn tab *and* on Path, and both opened a module
  screen — so a learner met the same five modules three times, and the tab meant
  to show today's work read as a course index. Learn keeps the day: the lesson
  card, Keep Sharp, the active brew and practice. Path is the course, and it
  fits on one screen because each module shows only as much as its state earns
  — the module you are in lists its lessons, a finished one collapses to a row
  that opens when you want to review or replay it, and one you have not reached
  is a single line saying what unlocks it. The module screen is gone entirely.

- **Practice is one section instead of two.** *"Practice a finished lesson"* and
  *"Mini-games"* were sibling headings for what the design calls one thing:
  **Practice**, holding **Lessons** and **Games**. Games are indented under
  their kind, the way the shelf is drawn. The day's card also gained the eyebrow
  that names which of its two states you are looking at — *Continue learning*,
  or *All caught up* when there is no lesson left today.

- **The Cards tab stops opening as a wall of blanks.** The grid laid out every
  collectible at once, so a learner who had earned nothing met a full screen of
  locked tiles. It now shows what you have earned plus a single locked card as
  a teaser, and a block underneath names the rest — *"29 more to collect ·
  Finish lessons to reveal new cards."* The count includes the teaser you can
  see, which is the design's reading of "how many are left".

  The tab loses three things with it: the grid is no longer sectioned by
  module, the progress bar is gone — the grid is the progress — and the header
  is the bare `0 OF 30` in mono the design gives it, rather than a second
  "Collection" title under the one the shared header already shows.

- **The lesson player is the card, and nothing else.** It used to print the
  module name and the lesson title above every card, and leave by a back
  arrow. Now the bar carries only what the design puts there: a close mark, the
  roasting bean with its position beside it, and the save control. Nothing
  competes with the question being asked.

- **Settings is grouped the way the design groups it.** Appearance leads, the
  sound and haptics switches move under **Practice** beside the new reminder
  rows they belong with, and **Account** and **Support** carry the rows that
  leave the screen. The version moved out of a labelled row into the centred
  line that closes the screen. Rows are label-left, value-right over a
  hairline, and none of them draws a leading icon any more: the design's
  settings row has no icon slot at all, so the six stock glyphs the app had put
  there were removals, not replacements. **Delete account** joins the two rows
  at the foot — drawn, but faded and unpressable until there are accounts to
  delete.

- **Headings are drawn for the size they're set at.** Fraunces is a typeface
  with a size axis: at small sizes it thickens its strokes and opens its
  spacing, at large sizes it refines them. The app shipped one fixed drawing
  for every size from 9.5 to 56px, so headings came out thin and small labels
  came out cramped. It now carries the real typeface and asks it for the right
  drawing at each step — about 64KB more in the app.

- **Bold text is real bold now, or it isn't there.** 53 places asked for a
  weight the app doesn't ship — Flutter faked it by smearing the letterforms —
  and one asked for Roboto by accident. Emphasis now comes from the typeface
  the design actually bundles, and a test fails the build if a screen names a
  weight again.

- **Small orange labels are readable in the light theme.** Every eyebrow,
  kicker and smallcaps label set in the brand orange was drawing at 4.23:1 on
  the light background — under the accessibility minimum for text that size.
  The design had already answered this with a second, darker orange reserved
  for small labels; the app never carried it. It does now
  (`MoodColors.accentText`), and the eleven label-sized call sites use it,
  clearing the minimum in both themes. Marks, fills, borders and progress bars
  keep the brand orange, so a glyph and its label sit side by side in the two
  shades exactly as the design draws them.

- **The Welcome hero is rounded the way every other media frame is.** Its
  corner was a bespoke 4px, left over from a radius scale the design never
  had; it now takes the one radius token the design does ship, matching the
  bottom sheets, icon wells and mini-game tiles beside it.

- **One progress mark for every run: a bean that roasts as you go.** The lesson
  header's pill, percentage and bar and the mini-game's segmented strip are
  replaced by a bean that darkens from green to espresso beside a zero-padded
  `03 / 08`.

- **The illustration palette can be looked up by the name the design calls it.**
  Extracted content sometimes refers to a colour by the design bundle's own
  custom-property name rather than by hex, so the palette now answers to those
  names — and throws on one it does not carry, rather than falling back to a
  colour that would look plausible and be wrong. The mapping used to be written
  out inside the palette's drift guard; it now lives beside the colours, and the
  guard reads it instead of keeping a second copy.

### Removed

- **A dependency that had stopped doing anything.** `sqlite3_flutter_libs` used
  to compile SQLite into the app. From version 0.6.0 it is an empty package —
  `package:sqlite3` builds SQLite itself now — and the version we were asking
  for was that empty one. Writing the privacy manifest meant naming whatever
  really puts SQLite in the binary, which is how it surfaced. Drift still pulls
  the empty package in on its own, to keep the old build scripts out; we just no
  longer claim to own it. Nothing about the database changes.

- **Profile no longer carries settings.** The `Customize` grid — a Sound tile
  and a Haptics tile — is gone, and the heading with it. Both toggles already
  ship in Settings, under `Practice`, over the same stored record, so the grid
  was a second set of controls for one preference. The gear at the top of
  Profile is now the only way to a setting, which is what the design does. The
  Studio door the heading sat over stays where it is.

- **The Profile paywall card is gone.** "Go Premium" promised a subscription
  the app does not sell, used a word the glossary rules against, and offered to
  remove ads that do not exist. The design has no paywall slot on Profile at
  all, so the card is removed rather than reworded — where Plus is genuinely
  gated, the design marks the gated card itself.

### Fixed

- **Answering the Tour offer and leaving the Learn tab at once no longer
  throws.** The answer was saved, but refreshing the screen that offered the
  Tour after that screen was already gone raised an error in debug builds.
  The answer is still saved; the refresh is skipped when there is nothing
  left to refresh.
- **The streak-freeze notice can no longer contradict the streak it describes.**
  The Learn tab's "Your streak is safe" card, the streak it reads, and the
  notice's own dismissal each asked the clock separately, so a phone left open
  across midnight could show yesterday's save against today's streak. All
  three now read the one app day that the overnight rollover already
  refreshes.
- **A card you have not earned tells you which one it is.** A locked tile used
  to read `???`, which said only that something was missing. It now carries its
  place in the collection — `03 / 37` — so the gap is a card you can go and
  earn rather than an anonymous blank, and with one locked tile on screen at a
  time that tile is always the next one. Earned tiles gained the same line, and
  each is washed in its own subject's colour, so the grid reads as a collection
  instead of a table. A card whose Coffee Challenge you have brewed is stamped
  in the corner; one with a challenge waiting is ringed. The module name under
  each title is gone — the tile says what the card is, and the module was only
  ever repeating what the card above it already said.

- **Profile says the month you actually joined.** The closing line read the
  first day you did anything, so someone who installed the app and did not
  start for three weeks was told they joined the following month. The app now
  records its own first run, and reads the line from that. Devices that were
  installed before this shipped are not back-dated to today — they keep the
  earliest-activity reading, which is at least a day they were here for.
  Starting the course over leaves the date alone; deleting the account sets it
  to now, because what is left behind is a fresh install.

- **A card opens over your collection now, and finally says the thing worth
  keeping.** Tapping a collectible used to take you to a screen of its own, so
  closing it meant finding your place in the grid again; it opens as a sheet
  over the grid, and closing puts you back on the tile you tapped. The card's
  keepsake line — one true thing about it, written when the card was authored —
  was being loaded and thrown away on every card. It reads under the summary
  now, where the card was always meant to end. A challenge you have brewed
  stamps the card, and the module name no longer repeats under the title where
  the tile beside it already said it.

- **The dictionary opens on its subjects, not on every word it knows.** Eight
  categories, each with its own mark, what it covers and how many terms sit
  behind it — one tap opens a subject, and one goes back. It leads with its own
  name, *Coffee Dictionary*, under a kicker that counts the shelf. The three
  filters became one control, because they were always one choice, and the
  search field wears the design's own glass.

- **A term reads as an entry, not a settings row.** The word is a heading on
  the page with its status beside it — a mark and a word together, so it does
  not depend on colour alone — and the blocks under it carry the names the
  design gives them: *in practice*, *knowledge check*, *related terms*.

- **The lesson's Continue is the same size as every other button that means
  the same thing.** It was Material's shorter default while the Continue on the
  screen after it stood taller — the most-pressed button in the app, visibly
  smaller than its own follow-up. The two challenge sheets' actions match now
  too. Buttons that sit *inside* a card or beside another button are left as
  they are, and say why.

- **A collectible's corner matches every other rounded thing.** It carried a
  hand-picked radius that belonged to no part of the design.


- **Every button in the app is the shape the design draws, and none of them
  were.** The app never told Material what a button looks like, so almost every
  one it drew fell back to a fully-rounded pill — on lesson completion, the
  module summary, the streak screen, both mini-game screens and a dozen smaller
  places. Onboarding escaped the pill, because it used a hand-built button that
  carried the rule privately — but that button had the wrong corner too, so
  onboarding's buttons change as well. The rule is declared once now, so a
  button is right wherever it is drawn.

  The corner they take is the one the running design actually sets. The
  component catalogue and the running prototype disagreed about buttons — 2px
  against 14px — and the app had followed the catalogue. It follows the running
  prototype now, as it already does for the quiz and match tiles, so everything
  rounded on a screen is rounded to the same measure. The Appearance toggle in
  Settings stays a pill, which is what the design draws it as.

- **The Today tour has a way out, and a way back in.** Every card in the
  four-stop tour now carries **Skip** on the left and **Next** on the right —
  **Done** on the last stop — where before it had no buttons at all and could
  only be finished by walking it to the end. Navigating to another tab
  mid-tour now ends the tour instead of leaving its callout floating over the
  tab you moved to. And the way back is **Settings → Help & Support → App
  Guide**: a new screen that says in a line or two what each part of the app
  does, with **Replay Today introduction** at the foot. That replay row moved
  there from Profile, where it read as a fifth preference in Customize. The
  guide's streak line says *"one finished activity a day"* rather than the
  design's *"one lesson a day"*, which named one of the six ways a day
  qualifies and read as the only one.

- **Overlays blur what is behind them, the way the design says they should.**
  Every overlay carries a blur radius in the same breath as its colour — 5px
  behind a bottom sheet, 8px behind a control sitting on video, none on the
  plain veil. The app had ported the colours and dropped every radius, so a
  sheet dimmed the screen behind it and left it sharp. An overlay is one value
  carrying both halves now, so every sheet, the tour's opening question and the
  sound toggle on the intro film arrive blurred. Reset Progress and Restart
  onboarding were also asking for confirmation behind Material's stock black,
  having never been given the app's dim at all; they open through the same door
  now. The blur holds steady while the tint fades, which is also what keeps it
  affordable on an older phone; turning animations off does not take it away,
  because a blur is not motion.

- **The tour's spotlight was wearing the wrong overlay.** It dimmed the screen
  with the media scrim — the one overlay the design reserves for a control
  sitting on a photo, and the only one of the four that is not full-screen.
  The coach mark now uses the blocking dim the design draws it with. It is the
  one dim deliberately left unblurred: blurring behind a spotlight would blur
  the thing the spotlight is pointing at.

- **Two cards told a screen reader everything except whether you passed.** On
  a select-all card every choice announced what it was — correct, incorrect,
  or an answer you missed — and on the blind-bag card the option list marked
  the call. But the line that names the actual outcome (`ALL CORRECT` /
  `NOT QUITE`, and `Called it.` / `Washed, actually.`) was drawn and never
  spoken, and it appears with no focus change to bring a reader to it. On the
  blind bag it was worse: right and wrong are told apart by colour there, and
  colour is the one thing a screen reader cannot report. Both are now
  announced when they appear, the way the match card's verdict already was.

- **Screens spelled their own URLs, so the router was not the only thing that
  knew them.** Eight places navigated by a literal path — `/learn`,
  `/welcome`, `/onboarding/goal`, a module's and a card's detail URL — and the
  router's own gate spelled four more inline while reading two from the route
  catalog in the same function. Every one now goes through that catalog, by
  route name where a name exists, so changing what a URL looks like is a change
  in one file. Opening a module went through two call sites that each spelled
  the `moduleId` parameter themselves; they share one helper now, the way
  opening a dictionary term already did.

- **The app drew coffee with Material's icons, and three of them said the
  wrong thing.** The design has its own 39-mark family — a cup, a trail of
  stops, a cherry in section — and none of it had reached the app, which drew
  ~70 stock glyphs instead. Three broke the design's own rules by name:
  Roasting used a flame where the design leaves the flame to the streak,
  Processing used a droplet where "water is not the category", and every
  knowledge topic the lookup did not name fell back to the same book, so four
  topics shared one mark. The marks are extracted from the design source
  rather than redrawn, and they follow the mood — a tab fills with the accent
  when it is selected, a bookmark fills when it is saved, each the design's
  own rule for that mark, and one caret rotates rather than swapping for a
  second glyph. Points now carry the design's bean, not a lightning bolt,
  which the design reserves for the fastest answer. Icons also default to
  muted ink rather than Material's white, which is what the palette says
  every inactive icon should be. What the design has not drawn a mark for —
  a Settings toggle, "not collected yet", the start arrow — still uses
  Material, and says so at the call site.

- **Section headings are smallcaps everywhere, and lettered the same.** The
  shared `SectionHeader` — the heading over Learn's sections, Cards' groups,
  a module's lessons and the dictionary's categories — was not uppercase at
  all, and three more places wrote their own smallcaps a letter or two apart:
  the dictionary entry's block labels, Settings' group labels, and the
  mini-game kind headings each picked their own spacing, and Settings a weight
  the design does not have. All four now render through the one label the app
  already shipped. A screen reader hears these headings as they are written
  rather than as they are lettered, so a short one is not spelled out.

- **The active tab wore a green pill, and the first tab had two names.** The
  bar was stock Material with no theme of its own, so it reached through the
  palette for whatever Material's defaults pointed at: the pill behind the
  active tab came out `sage` — the token reserved for "learned", never for an
  action — and the mark inside it came out the page background. An active tab
  is now the accent in mark and in label with no pill behind it, and a
  hairline rules the bar off from the page the way the design does. The four
  labels are the design's own — `TODAY`, `PATH`, `CARDS`, `PROFILE` — so the
  first tab no longer calls itself `Learn` under a header already reading
  `TODAY`. The bar letters them wider than the type ladder does, which is
  recorded in `OffTokens` with its reason. The marks are still Material's;
  #378 ports the design's own.

- **A large share of the app's text was still Roboto.** The type ladder filled
  eight of Material's fifteen text slots, and an unset slot keeps Flutter's own
  font rather than falling back to a neighbouring step — so card titles, row
  headings, eyebrows and support lines across nearly every screen were set off
  the ladder. All fifteen slots are now mapped.

- **The blind bag's closed cues looked exactly like its open ones.** Inspecting
  a cue changed only its words, so finding the ones you had not read meant
  reading all of them — on the single card where looking *is* the interaction.
  Open and closed rows now differ before a word is read. The verdict is
  coloured by outcome too, rather than right and wrong sharing one weight of
  type that a learner scanning back over a run would not catch.

- **The green bean's colours left the token system.** Its shading was Cupping's
  `ink` frozen as a literal, so in Dark Roast the bean kept a light-mood
  outline with nothing recording why; and its chaff sat two points off
  `ArtColors.cherrySilverskin`, whose own description names it as chaff — a
  palette carrying two answers for one thing. The flecks take the token, and
  the shading ink and fruit stain are registered in `OffTokens` with their
  reasons (#334 owes the design source the matching fix).

- **Two mini-games were on the shelf but switched off.** *Match: washed vs
  natural* and *True or false: roast basics* both render, and both had sat
  behind a dead "Not playable yet" button since they were authored — they
  entered the catalog three days after the list of playable games was last
  written, so nobody ever ruled on them. Both play now, and a new guard fails
  the build when a game whose rounds can be drawn is neither playable nor
  recorded as deliberately held back, so the next game added to the catalog
  cannot go missing the same way.

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

- **A locked mini-game told screen readers it was locked and nothing more.**
  A sighted learner taps a lock speculatively and finds the offer behind it;
  someone hearing only "Locked" has no reason to try, so the dead end this
  catalog set out to remove was still there for them. The row now carries a
  hint naming what the tap does (#125).

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

- **The free shelf holds five, and says so.** A free learner's shelf reads
  `3 of 5 saved`; a sixth save does not take, and the app explains why rather
  than failing silently — the shelf is full, and Plus makes it unlimited. The
  offer also sits on the shelf itself, where the limit is felt. **Removing is
  always allowed**, including at the cap, so a full shelf can still be
  curated: one tap to make room, another to fill it. The cap counts lessons,
  terms and guides together, because there is one shelf rather than three, and
  a learner with Plus is never shown a limit that does not apply to them.

- **Visual guides can be bookmarked, and the shelf is complete.** The bookmark
  sits in the guide's own sheet, beside the label naming what it is, so a
  reference is kept from where it is read. Saved guides fill the shelf's third
  group in bank order, and a row opens the guide back over whatever the learner
  was reading. A guide the course has re-locked — after a reset, say — drops off
  the shelf rather than offering a way back into content that is no longer
  earned.

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
- **A streak travels.** Share your streak opens the iOS system share sheet
  with a rendered card — wordmark, count, the week's strip — composed
  off-screen at a fixed size, so it looks identical from any device. Image
  only, no link; share_plus rides behind a presenter seam and stays
  SPM-only.
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
