# BrewPath — what the app is

A plain-language description of the whole product: what it does, why it was
designed this way, and what is worth arguing about.

**No code in this document.** No file names, no identifiers, no method names.
Everything is named the way a user would see it. If you want to know *how* a
thing is built, the numbered sections in this folder cover that — this file is
for deciding *whether* it should work this way at all.

**How to use it.** Read it end to end, or jump to whatever you want to
challenge. Every feature section ends with **the trade-off** — the thing that
was given up to get it — and the last section collects the questions that are
genuinely still open.

### Where each judgement comes from

Trade-offs and rationale are tagged, because it matters whether you are arguing
with the project or with me:

| Tag | Means |
|---|---|
| **[Recorded]** | A position actually stated in the project's own documents — the v1 Readiness Audit, the tree-variety proposal, or a design comment written into the prototype. Quoted where useful. |
| **[Derived]** | Not stated anywhere, but a factual consequence of how the product works. Checkable. |
| **[My reading]** | My product judgement. **Nobody on this project has said it.** Treat as an outside opinion, argue with it freely, delete it if it is unhelpful. |

The project's own one-line description of itself is **"learn coffee, a little
every day."** Everything else below is built on that.

---

## 1. The idea in a paragraph

BrewPath teaches people about coffee the way Duolingo teaches languages. You do
one short lesson a day — three to five minutes, a handful of swipeable cards —
and each lesson teaches exactly one idea: what altitude does to a bean, why
pre-ground coffee goes flat, how to tell an over-extracted cup from an
under-extracted one. Finishing a lesson earns points, keeps a streak alive,
unlocks a collectible card, and grows a coffee plant that is the single picture
of how far you've come. A cartoon coffee bean called Roasty reacts to everything
you do. A searchable coffee dictionary sits one tap away and links back into the
lessons. And every so often the app asks you to go and actually brew something
and taste the difference.

**Free gives you the first two lessons**, permanently, with unlimited replay —
plus the whole glossary at a glance, practice on what you have unlocked, and the
streak. Premium unlocks the remaining thirty, lifts the two-activity daily cap,
and adds unlimited Saved and both Studios. The free tier is a **preview**: it
shows you the shape of the course and lets you keep the habit, but the course
itself is what you buy.

## 2. Who it's for, and what the project says it is

**[Recorded]** The project describes itself in one line — **"learn coffee, a
little every day"** — and that line is the test the scope decisions were made
against. Two more positions are written down:

- **"Free builds the habit. Plus makes it yours."** The monetization model in six words.
- **"Cosmetics that teach are the thesis of the app."** Written to justify making the plant three real coffee species rather than three colour filters — the personalization is supposed to leave you knowing something.

**[Recorded]** The audience is addressed indirectly but consistently as a
**beginner who owns no special equipment**. The clearest statement is the reason
the espresso lesson carries no real-world challenge: *"it would ask for a machine
the learner does not own."* The same constraint explains why only seven of
thirty-two lessons have a challenge at all — they exist only where a beginner can
honestly run the experiment with what is already in the kitchen.

**[My reading]** Beyond that, no document describes the user, their motivation,
or why this app should work. There is no positioning statement, no persona, no
articulated bet. My own reading — that coffee is unusual in paying its theory
back at breakfast the next morning, and that this is what makes the real-world
challenges the load-bearing idea rather than a gimmick — **is mine and appears
nowhere in the project.** It is a reasonable story for the shape of the product,
but if you are deciding something important, decide it against the recorded
lines above, not against my inference.

> **⚠️ Worth noticing:** the absence itself is a finding. Scope, monetization and
> mechanics are all argued in writing and argued well. *Who this is for and why
> they would keep coming back* is the one layer nobody wrote down.

## 3. A day in the app

You open it in the morning. The first screen is called **Today**: the date, and
a card showing the lesson you're up to. You tap Begin.

The lesson is a stack of cards you swipe through. It opens by asking you to
guess something — "Do you think a darker roast has more caffeine or less?" — and
your guess is held until the end. Then a few teaching cards, each with a
fill-in-the-blank sentence you complete by tapping the right word from two
choices. The sentence always resolves correctly whichever way you tap, so you
never leave holding a wrong idea. Then some questions: multiple choice, matching
pairs, putting steps in order, dragging a dial to the right setting. Then a card
that puts you in a real situation — "You're at the shelf and both bags say
Ethiopian. One is roasted three weeks ago, one is undated. Which do you buy?" —
with a proper explanation whichever you choose. Finally the app comes back to
your opening guess and tells you whether you were right.

Then the reward. Roasty does a little celebration first, and then you see: your
score, your points, whether the plant grew a stage, and the collectible card you
just unlocked. Sometimes it offers you a real-world challenge — *brew the same
coffee twice, one grind step apart, and taste which one is better* — that you can
start or park for later.

Tomorrow the streak counter goes up. That's the loop.

**The trade-off [My reading]:** it's a five-minute app. Someone who wants to binge ten lessons
can, but nothing rewards them for it — no bonus, no acceleration. That's a
deliberate bet on habit over enthusiasm, and it means the app is quiet for the
motivated learner who wants to go deep this weekend.

## 4. How progress is measured — four systems, on purpose

This is the most opinionated part of the design and the part most likely to be
mis-built, because four separate things are being tracked and they deliberately
do not talk to each other.

### Points — how much effort you've put in

Ten points for finishing a lesson the first time. Five for completing a
real-world challenge the first time. Nothing else pays anything. Replaying a
lesson pays zero. Getting a perfect score pays no bonus.

Points measure **turning up**. They are not a score, not a skill rating, and
they don't unlock anything.

### Mastery — how well you actually know it

Tracked separately, as a percentage, per lesson, and always your **best ever**
attempt. Below 80% a lesson is labelled *Needs Practice*. Above that it isn't
labelled at all — the app just quietly shows a fuller icon.

The important consequence: **a replay can improve your mastery even though it
pays no points.** Going back to fix a weak lesson is rewarded with the thing
that actually matters, and not with the currency. And your best score never goes
down, so revisiting something can't hurt you.

### The plant — how far through the journey you are

A coffee plant that grows through ten stages, from a bare seed to a full
harvest, driven only by first-time lesson completions. Replays don't grow it.
Challenges don't grow it. It only ever moves forward, and only resets if you
deliberately wipe your progress.

It is the one picture of overall progress, and it's the emotional payload of the
whole app. Ten stages across thirty-two lessons means roughly one visible growth
event every three lessons.

### The streak — whether you're still here

One lesson a day keeps it alive. Every seven days you earn a **streak freeze**,
and you can hold two. Miss a day and one is spent automatically — you aren't
asked, you aren't warned, the streak survives, and the app tells you afterwards
in a reassuring tone. The freeze is a mechanic, not a setting; there's no toggle,
because the design position is that someone coming back after a miss is the most
fragile user in the app and shouldn't be handed a decision.

**[Recorded]** Streak protection is **free forever**. It was considered as a paid
feature and rejected, because *"the streak carries no in-app reward, so selling
insurance on it is selling insurance on an item with no value."* The freeze was
made *earned* rather than a settings toggle *"so it is felt as a reward instead
of hidden as a preference,"* and the reassuring tone is deliberate: the design
note says someone returning after a miss is *"the most fragile user in the app."*

### Why four, and what it costs

Each answers a different question — *have I been showing up*, *do I actually know
this*, *how far have I come*, *am I still in the habit*. Collapsing them into one
number would make every one of those questions unanswerable.

**The trade-off [Derived]:** it's more to explain. A user who sees points go up but the
plant stay still needs to already understand that they're different things. The
app never explains this directly — it relies on the FAQ and on the shapes being
visually distinct. That's a real risk and worth challenging.

## 5. What you actually learn

Five modules, thirty-two lessons, in a fixed order. The course is called
**Beginner Foundations**.

| Module | What it's about | Example lessons |
|---|---|---|
| **Beans** | What coffee is before anyone roasts it | Arabica vs Robusta · Why altitude matters · Why two Ethiopian coffees taste different · Inside the cherry, layer by layer |
| **Processing** | What happens between the farm and the bag | Washed, natural, honey · Reading a bag label · What happens in the fermentation tank · Decaf, honestly |
| **Roasting** | What heat does, and how to read a bag | Light, medium, dark · First and second crack · Reading a roast date · How much caffeine are you actually drinking? |
| **Grind** | The variable most people never touch | Particle size in plain English · Burr vs blade · Dialling in by taste · Choosing your first grinder |
| **Brew** | Making the cup better tomorrow | The brew ratio · Water, the variable · Extraction explained · Tasting your cup · Your first good cup |

Roughly two hundred and sixty cards in total, about eight per lesson.

The course ends with a lesson called *Your first good cup* which is deliberately
practical — it walks you through actually making one, step by step, using
everything the course taught.

**Below the last module the app shows users four modules that don't exist yet:**
Espresso Basics, Milk Drinks, Brewing Gear, and Coffee Tasting. This is a
promise made to every user on the main screen.

> **⚠️ Worth knowing:** those four names are the *entire* specification. There is
> no lesson list, no scope, no rationale written down for any of them anywhere,
> and the document that records what ships and what defers doesn't mention them
> at all. They were never a decision — they're four words that ended up in the
> interface. If any of this is worth debating, that's the piece.

**The trade-off [My reading]:** a fixed linear order means someone who only cares about
espresso has to walk through beans and processing first. The counter-argument is
that grind and extraction genuinely don't make sense without them — but it's a
real cost and the coming-soon list makes it sharper, because it advertises the
espresso content that the ordering is keeping you from.

## 6. The lesson itself

There are about a dozen kinds of card, and the mix is the design.

**Cards that teach:**
- **A guess up front** — a binary question before you know the answer, resolved at the end. It makes you commit, which makes the answer stick.
- **Fill-in-the-blank teaching** — a sentence with gaps, two choices per gap. The sentence resolves correctly regardless, so it's a rehearsal device, not a test.
- **Visual guides** — full-bleed illustrated explainers (roast levels, grind sizes, the anatomy of a cherry) that you can save to keep.
- **Hands-on instructions** — actual step-by-step, used only in the final lesson.

**Cards that check:**
- Multiple choice with an explanation
- Select-all-that-apply
- Matching pairs, with lines that draw between them
- Putting steps in the right order
- Dragging a dial to a value and checking it against a target range
- **"This cup came out wrong — what do you change?"** — a diagnosis card
- **"Read the beans"** — you draw a sample from an unlabelled bag, inspect the colour and the centre cut, and call how it was processed
- A closing recall that circles back to your opening guess

Roughly eight in ten cards are graded. Every wrong answer gets an explanation.

Any coffee term in the body text is tappable and opens a small definition panel
without leaving the lesson.

**The trade-off [My reading]:** this is a lot of interaction types to build and to learn. A
user meets a new interaction pattern every few cards early on. The upside is
that no two lessons feel the same; the downside is cognitive load in the first
week, and a help panel exists for some card types but not others.

## 7. The dictionary

Seventy-two coffee terms across eight categories, reachable from anywhere.
Search matches alternative spellings. Terms cross-link to each other and back
into the lesson that teaches them.

A term is **Learned** once you've done the lesson that covers it — so the
dictionary doubles as a second view of your progress. Terms you haven't reached
show as **To learn**.

There's a third state that's easy to miss and quite thoughtful: **Reference**.
Eight terms are things you'll meet on a bag or a menu but that no lesson teaches
— they can never become "Learned". Rather than showing them as perpetually
not-yet-done, they're marked as reference-only, with a line saying *"No lesson
covers this one — it's here for when you meet it on a bag or a menu."* The design
note is that a "not yet" state would be a promise the course can't keep.

The dictionary also has two small practice modes: **flashcards** over the terms
you've saved, and a **vocab quiz** where you pick a deck and a round length.

Everything in the dictionary is free.

**The trade-off [Derived]:** seventy-two terms is a lot of writing for something most users
will dip into rather than read. Twenty-six of them are one-liners with no depth,
which is a visible quality gradient if anyone goes looking.

## 8. Coffee challenges — getting off the screen

Twelve small real-world tasks. One capstone per module, plus a few attached to
the most hands-on lessons.

They're deliberately modest: *brew the same coffee at two different strengths and
taste them side by side*. *Buy two bags of the same origin, one light one dark,
and compare*. *Next time you open a bag, find the country it was grown in and say
it out loud*. Every one is doable with beans and equipment the learner already
has — which is exactly why only seven of the thirty-two lessons have one.

You start a challenge and it sits on your Today screen for two days. If you don't
do it, it quietly disappears — no penalty, no nagging, no archive of failures.
You can also park one for later instead of starting it.

When you've done it, you pick one of three honest answers — *tasted the
difference* / *hard to tell* / *only managed one cup* — and that's it. "Hard to
tell" is a legitimate result. Completing one stamps a permanent mark on the
related collectible card, which is the actual reward: a record that you did this
for real.

Challenges never block anything. Not lessons, not streaks, not progress.

**The trade-off [My reading]:** they're entirely optional and easy to ignore, which means the
part of the app carrying the strongest argument for why it works is also the part
most users may never touch. Nothing pushes them beyond a suggestion at the end of
a lesson.

## 9. Collecting

Thirty-seven collectible cards, one per lesson plus one per completed module,
each with its own illustration and a fact on the back. The fact is written once,
in the lesson, and copied onto the card — so the moment you earn it and the card
you look at later can never say two different things. They unlock automatically
as you learn — there's no chase, no rarity, no duplicates.

There are also five reference guides — roast levels, grind size, extraction,
brew ratio, the cherry cross-section — that you have from the start and can save
for quick access.

Cards you haven't earned aren't shown as a grid of locked slots. You see what
you've earned, one teaser of what's next, and a count of how many remain.

**The trade-off [My reading]:** a collection with no scarcity and no trading is a progress
bar with pictures. That's a defensible choice for an education app — it can't
create pay-to-win pressure — but it also means the Cards tab has limited reasons
to return to it.

## 10. Roasty

A coffee bean with a face. He reacts to correct answers, wrong answers, finished
lessons, completed modules, unlocked cards, and being left alone too long. He
has nine distinct animated states.

He's also the paid tier's main lever: you can dress him in hats, glasses, scarves
and headphones, and change how dark he's roasted.

**The trade-off [My reading]:** a mascot is polarising. He's on nearly every screen, and
there's no way to turn him down. For an audience that skews adult and slightly
self-conscious about a coffee-hobby app, that's worth a conversation.

## 11. Making it yours, and what you pay for

> ### ⚠️ This section was rewritten twice. The model changed, then changed again.
>
> **[Recorded — product-owner ruling]** The free/paid axis is **content, not
> pacing and not features**:
>
> > **Free: the first two lessons, permanently, plus practice on unlocked
> > material and at most two learning/practice activities per day. Premium:
> > the remaining thirty lessons, no daily cap, unlimited Saved, both Studios.**
>
> Two superseded models are recorded here so neither is re-derived. **The
> original** — everything free, Plus buys an unlimited Saved shelf and the
> Studio — went first. **A pacing model** then replaced it (*2 new lessons/day
> free; Premium removes the limit*) and is **also withdrawn**. Settled on
> [Monetization shape](https://github.com/maximsan/brewpath/issues/29); full
> rules in `docs/decisions-1.md` §7, §8, §11 and §12.

### What the ruling means

**A pacing cap could not sustain a subscription on a finite course.** That is
why it was withdrawn. At two new lessons a day a free user finishes all
thirty-two in about sixteen days — after which *"no daily limit on new lessons"*
is worth nothing, forever, because there are no more lessons. A free user who
finished would hold the complete product while a paying user's benefit evaporated
in week three. A content gate has no such shape: Premium buys thirty lessons,
which do not expire on a schedule and cannot be reached by waiting.

**The daily cap survives, doing a different job.** With only two lessons ever
free it cannot pace a course; what it caps is **practice volume** — two
activities a day on two lessons' worth of material.

**This is a preview tier, not a generous free tier**, and the pitch has to be
written for that. Measured against current content, a free user reaches **2 of
32 lessons · 2 of 37 collectibles · 1 of 12 brew challenges · tree stage ~1 of
10**. The earlier positioning — *"everything that teaches is free"* — is no
longer true of this product.

**It is greenfield in both codebases.** Neither has ever gated a lesson by tier:
`featureUnlocked` only ever took feature keys (Studio, Atlas, dictionary, Saved,
Duel), and lesson locking is sequential progress. The Flutter app has no gate at
all. So there is no prototype behaviour to port and no "the source wins" to
appeal to: this is an invention, and the design reference says so.

**In v1 the feature axis has nearly dissolved.** Of the five `PLUS_FEATURES`,
the dictionary and Saved are free, Atlas and Duel are v2, and **Studio is the
only survivor** — while **lessons become the first content gate either codebase
has had**.

### Still open

**What Premium buys beyond the daily limit.** Only the cap lifted, or the cap
*plus* the feature set — Studio, cosmetics, and whatever else? Unresolved, and it
decides whether the prototype's timed-unlock machinery (a rewarded-ad trial, a
perfect-module gift) survives at all. Both grant *timed access to features*, and
neither means anything against a per-day lesson counter.

### Superseded — kept because the reasoning is still worth reading

The old model was argued carefully, and the arguments are instructive even now
that the conclusion has moved:

- *"Free builds the habit. Plus makes it yours."* — the six-word version.
- The ten-item Saved cap was **deliberately calibrated**: *"generous enough that only power users hit the cap — and that user is your highest-intent upgrade prospect."* The free tier was the **bridge** that *"surfaces the upgrade at peak intent, not at install."*
- Unlimited Saved was **the hook** — *"concrete, renewable value — this turns 'cosmetics-only Plus' into a real recurring product."* The Studio was *"the face of Plus, not the whole pitch."*

**Two things were considered and dropped**, and these rulings stand:

- **A lifetime tier** — a non-renewing plan needs its own receipt, restore and manage-plan states.
- **Paid streak protection** — *"the streak carries no in-app reward, so selling insurance on it is selling insurance on an item with no value, and repair pitches at the exact moment a user has already lapsed."*

### What the Studio is, regardless of what it costs

Dress up Roasty, and choose which coffee species grows in your garden — Arabica,
Robusta, or Liberica — and what light it stands in. Each species is real, with
real botanical differences, and the plant's silhouette changes accordingly.
Robusta is broader and bushier; Liberica is enormous. *"Cosmetics that teach are
the thesis of the app."*

## 12. Settings, your account, and leaving

Standard stuff: light/dark/system theme, a daily reminder you can set to one of
eight times, sound and haptics toggles.

Two destructive actions, both behind a confirmation that itemises what you lose.

**Reset progress** wipes your learning — streak, points, lessons, mastery,
challenges, and your saved shelf — and returns the plant to a bare seed. It keeps
your subscription, your Studio choices and your theme, on the grounds that those
are things you bought or chose rather than things you did. The button says *Reset
everything*, and it means it: a bookmark is something you did, and a saved lesson
that just re-locked points at a lesson you can no longer open.

**Delete account** is permanent and immediate. There is no recovery period. The
confirmation says so plainly, and it also warns that deleting your account does
**not** cancel your App Store subscription — that has to be cancelled separately
in Apple's settings. If you later make a new account and restore purchases with
the same Apple Account, your subscription comes back. Your learning does not.

**The trade-off [Derived]:** immediate permanent deletion is the honest, privacy-respecting
choice, and it removes a whole class of "is my data really gone" ambiguity. The
cost is that there's no undo for a misclick, which puts real weight on that
confirmation screen being unmissable.

## 13. What ships now, and what's waiting

**In the first version:** the lessons, the dictionary, the plant, streaks,
collectible cards, coffee challenges, the games, the paid tier and the Studio.
Four tabs: Today, your Path, your Cards, your Profile.

**Built but switched off:**

- **The Coffee Atlas** — a second content area covering fifteen coffee-growing countries, with a world map, regional deep-dives and a passport you stamp as you explore. It's fully designed. It was deferred because it needs as much writing and illustration as the entire course, and doing it badly would be worse than not doing it.
- **Coffee Duel** — head-to-head quizzes against a friend, played asynchronously. Also fully designed. Deferred because it needs server infrastructure, invitations, and link handling that nothing else in the app requires.
- **Rewarded video ads** that unlock the Studio temporarily. Needs an ad provider, and sits awkwardly with the "everything that teaches is free" position.
- **A personalisation questionnaire at signup** — asking your goal, your brewing method, how much time you have. Fully built, but nothing in the app currently reads the answers, so it would be four screens of friction that change nothing.
- **A "mood player"** where you tap emotions and watch Roasty react.

**Dropped rather than deferred:** a lifetime purchase option, and paid streak
protection.

**[Recorded] The reason for deferring, in the audit's words.** The verdict was
*"strong build, oversized for a first release."* The stated risk was **shipping
five products at once** — *"a course, a dictionary, an atlas, an async duel, and
a cosmetics store — each pulling content, infra and QA a different way."* The
test applied to every feature was one question: *does it deliver the core
promise, and can it ship without infrastructure you'd build just for it?*

On why deferred rather than cut: *"Atlas and Duel are the obvious v2 marketing
beats — 'explore the coffee belt,' 'challenge a friend.' Holding them gives v2 a
story and v1 a fighting chance at quality. The work is waiting, not wasted."*
The claimed result: **~40% less surface to QA, two fewer infrastructure
dependencies, one monetization model.**

**[My reading] — and this one directly contradicts the recorded position.** The
audit's worry was that v1 was *too big*. Mine is the opposite: what ships is a
course, a dictionary and a plant, and the two features that would make it feel
like a world are both switched off. I think the risk of a thin first release is
real and was not weighed against the risk of an oversized one. **The project
considered this and decided against me** — I am recording the disagreement, not
the conclusion.

## 14. The questions actually worth arguing about

Everything above is decided and built. These aren't — and each is tagged so you
can see whether you would be arguing with the project or with me.

**1. What the app is on day 33. [Derived]** The course is finite and the habit
engine is not. Sharper under the pacing model (§11), which sells speed toward an
ending. See §15.

**2. The four coming-soon modules. [Recorded gap]** Espresso Basics, Milk Drinks,
Brewing Gear, Coffee Tasting are shown to every user with nothing behind them —
no plan, no scope, no mention in the scope document. **They are also the
implicit answer to §15**, which makes "no lesson list, no scope, no rationale"
more serious than a documentation gap: it means the retention plan is four words
in a component.

**3. What Premium buys beyond the daily limit. [Recorded — open]** The pacing
ruling fixed the free side and left the paid side unresolved: cap-lifted only, or
cap plus features? It also decides whether the prototype's timed-unlock
machinery survives, since none of it means anything against a per-day counter.
My earlier question here — *"is the free tier too generous to convert?"* — was
posed against the superseded model and no longer applies.

**4. Is v1 too thin? [My reading — the project decided the opposite]** The audit's
verdict was "oversized for a first release". I think the reverse risk went
unweighed. Recorded as a disagreement, not a gap.

**5. Four progress systems with no explanation. [Derived]** Points, mastery, plant, streak.
Nothing in the app teaches the user that these are different things.

**6. The mascot. [My reading]** Unavoidable, un-dimmable, and on every screen.

**7. Optional challenges carry the core argument. [My reading]** The real-world tasks are the
strongest reason the app works, and they're the easiest thing to skip.

**8. A fixed linear course. [My reading]** No way to jump to what you care about, while
simultaneously advertising future modules about the thing you might care about
most.

**9. Whether the course actually follows its own rules. [Recorded]** There is now
a written standard for what makes a good card — no two cards in a row sharing an
answer, no option that is always right, questions that can surprise, distractors
that are genuinely wrong rather than merely worse. Nobody has yet played the
course and checked it against them. The scope audit lists this as one of three
things blocking a release, and the only one that is not engineering.

**10. The app that exists already disagrees with this design about how progress
works. [Derived]** The Flutter build pays XP scaled to lesson length, adds a
module-completion bonus, and pays a small amount for practice runs. This design
says a flat amount per lesson, no module bonus, and **nothing** for replays — on
the grounds that points measure showing up while mastery measures knowing it,
and paying for practice collapses that distinction. Neither model is obviously
right, but they cannot both ship. See [§11](11-open-items.md) for the exact
differences.

Worth noting separately: this was found by asking one question. Nobody has
systematically diffed the app against the design, which is what this whole
reference exists to enable.

---

## 15. What the app is on day 33

**[Derived]** This is not in any project document, and it is the largest thing
missing from the product as designed.

### The arithmetic

Thirty-two lessons, one a day, is **about five weeks**. After that the Today
screen shows a state that exists in the build and is easy to miss:

> **ALL CAUGHT UP** — "You've finished every lesson available."

**Every reward system terminates within the same few weeks.** The plant reaches
HARVEST and stops. Points come only from first completions and twelve challenges,
so they stop too. Mastery caps out. The collection completes at thirty-seven.
There is nothing left that pays.

**The streak is the exception, and that is the problem.** It is the one mechanic
designed for an indefinite horizon — earned freezes, a two-freeze cap, carefully
reassuring recovery copy, and an explicit decision that it stays free forever.
All of that assumes a tomorrow with something in it. The course does not have
one.

### The one rule that decides it

**Correction to an earlier draft of this section:** the streak rules are *not*
missing. They are designed in full and largely implemented — earn one freeze per
seven days, hold at most two, spend automatically on a miss, keep "this week's
covered days" separate from "freezes ever spent" (with a comment explaining the
shipped bug that separation fixed), derive the week strip from the real streak,
and suppress the earn notice at the cap. The Help FAQ states the qualifying
condition plainly: **"finish at least one lesson a day to keep it alive."**

What is unwired is only the clock — the prototype's date is frozen, so nothing
advances the streak, and the source says so while specifying the correct
real-world form. That is a porting note, not a gap.

**The actual gap is narrower and sharper:** *does a replay count as the day's
lesson?*

> ## ✅ Decided — August 2026
>
> **A completed replay counts.** Product-owner ruling (`docs/decisions-1.md`),
> recorded at [The streak's qualifying-activity
> rule](https://github.com/maximsan/brewpath/issues/33). This confirms [Streak
> and freeze](https://github.com/maximsan/brewpath/issues/17), which had already
> ruled that a day is active when a structured activity completes.
>
> **And the answer to the section below is not one of the four options — it is C
> plus D's ending.** After Foundations, the Today recommendation becomes **Keep
> Sharp**: one existing practice activity, chosen by simple rotation from
> completed and accessible material, stable for the day. Finishing Foundations
> gets **a proper ending and celebration**. Options **A and B are ruled out by
> name** — *"additional modules and the Atlas/Dictionary are possible future
> expansions, not the solution to post-course retention."* Both surfaces are
> specified at [Keep Sharp](https://github.com/maximsan/brewpath/issues/56),
> which also carries the trap that *"course is complete"* is permanently true
> under derivation, so the celebration needs an acknowledgement marker or it
> re-fires on every launch.
>
> ⚠️ **The argument below is left standing because its reasoning is still
> load-bearing** — particularly the objection that a replay-fed streak measures
> app-opening rather than learning. That cost was accepted knowingly, and Keep
> Sharp's no-points, no-tree, no-progress framing is the concession to it. But
> one premise the argument leans on **is false**: see the correction under
> option C.

During the course it does not matter — there is always a new lesson.
**After the last lesson it is the whole question:**

- **If only new lessons qualify,** every user's streak dies the day after they finish the course. The freeze mechanic buys two days and then stops. A system built with real care for the returning user ends by punishing the user who completed everything.
- **If replays qualify,** the streak survives — but it now measures opening the app, not learning, and the points/mastery separation that the whole progress model rests on gets quietly undermined at the exact moment it stops being observable.

Neither is obviously right, and it is a one-line rule with five weeks of runway
before anyone notices.

### Four ways out

**A. Ship more course.** The four coming-soon modules add perhaps twenty-five
lessons — call it four more weeks. *This is the current implicit plan, and it
only moves the problem.* Finite content is finite; day 33 becomes day 90.

**B. Ship the Atlas.** Fifteen origins with activities, already designed, already
built, explicitly held as v2's headline. It is a genuine second content vertical
rather than more of the same. *Same objection, larger number.*

**C. Make daily practice the loop after the course. [My recommendation]** The
pieces already exist and are not wired together:

- Seven mini-games with ~~**generated** content banks — they do not run out~~ ⚠️ **This is false, and it was the load-bearing premise of this option.** `MINI_GAME_CONTENT` (`lesson.jsx:1022`) is **authored, finite and small** — *"Content is authored here, one homogeneous set per game id."* Measured: `g-quiz` 6 rounds, `g-bagpick` 6, and `g-match` / `g-flavor` / `g-tastefix` / `g-calibrate` / `g-sequence` 5 each — **37 rounds in total**. The only randomness is Fisher–Yates over *choice display order*: the same rounds, reshuffled. A user practising daily exhausts every round in under a week. C was still chosen, so **the practice pool is now known to need authoring** — tracked at [Free-tier practice variety](https://github.com/maximsan/brewpath/issues/66), which measures the free-tier slice at **11 rounds**, and at [Keep Sharp](https://github.com/maximsan/brewpath/issues/56)
- A vocab quiz with a deck picker and configurable round length
- Flashcards over saved terms
- A Term of the Day that is already deterministic by date
- Mastery data that already knows which lessons are weak, surfaced on Profile and deep-linking into practice

Assembled, that is a **daily drill** — today's term, a round of the game matching
your weakest lesson, a challenge suggestion — that never exhausts, needs **no new
authored content**, and gives the streak something legitimate to eat.

It also fixes a smaller thing: mastery currently has no ongoing home. It is
computed, displayed once, and then does nothing. Making practice the post-course
loop turns mastery from a readout into a driver — which is what the four-system
split was for.

**The cost, stated honestly:** a drill is not a lesson. Day 40 would be quieter
than day 4, and the app would have to be honest that you have moved from learning
to keeping sharp. That is a different product promise and the copy would have to
say so.

**D. Let it end well. [My reading]** Accept that this is a five-week course,
build a real ending — a finished plant, a completed collection, a genuine
send-off — and let the streak retire with dignity instead of dying quietly at
"all caught up". Then bring people back with a *release*, not a habit.

This is the option nobody takes and it is not obviously wrong. A course that
ends cleanly and is remembered fondly may be worth more than a habit loop
running on fumes.

### Why it matters beyond retention

The answer changes things already decided:

- **The streak's design rationale** assumes an open-ended horizon it does not have. ✅ **Resolved:** Keep Sharp supplies the horizon, so the freeze mechanic keeps its purpose — and the freeze itself was **tightened** rather than retired: cap **1**, no accrual while holding, 7 fresh days after each use. See [Streak freeze: §10 now rules nine behaviours](https://github.com/maximsan/brewpath/issues/58).
- ~~**The monetization model** now gates *pace* (§11).~~ ✅ **Superseded — the axis is now content, not pace.** The same product-owner ruling states *"free access is limited by content, not by waiting"*: two preview lessons, permanently replayable, and waiting unlocks nothing. A daily activity cap survives but now covers **practice as well as lessons**. Resolved at [Monetization shape](https://github.com/maximsan/brewpath/issues/29); the pieces are split across [Offers, plans and the paywall pitch](https://github.com/maximsan/brewpath/issues/55), [The free daily activity allowance](https://github.com/maximsan/brewpath/issues/65) and [Saved shelf](https://github.com/maximsan/brewpath/issues/60). **This also dissolves the objection in this bullet** — a subscription whose only lever was speed had nothing to sell once content ran out; one that sells the course itself does.
- **The coming-soon modules** stop being a marketing tease and become load-bearing. ✅ **Reversed** — they are explicitly *not* the retention answer.

~~**Recommendation: decide C or D explicitly before building.**~~ ✅ **Decided:
C's practice loop plus D's ending** — see the block under *"The one rule that
decides it"*. The warning against drifting into A held: A and B were ruled out by
name rather than by neglect.

---

## Where to go for detail

This file is the conceptual layer. The numbered files in this folder are the
engineering reference — exact rules, component states, counts and open technical
defects — derived from the prototype source. Use them when building; use this one
when deciding.

[Contents](README.md)
