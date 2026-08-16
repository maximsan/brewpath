# BrewPath — course content rules

What makes a good card, for anyone — agent or human — authoring or porting
course content. (This file lived at `brew-path/CLAUDE.md` — the prototype
folder's old name — until Aug 2026.)

**No two cards in a row may share an answer.** Check the whole lesson, not just
adjacent pairs: if two cards resolve to the same choice ("switch to Arabica",
"grind finer"), the second one teaches nothing — the learner pattern-matches
instead of reasoning. Vary the answer axis between neighbouring cards.

**Never let one option become the always-right answer.** If a lesson presents a
trade-off (Arabica vs Robusta, finer vs coarser, more vs less), the graded cards
must cut both ways. A lesson that says "Robusta earns its place" and then only
ever rewards picking Arabica is teaching the opposite of what it claims.

**A question must be able to surprise.** If the correct choice is obvious from
the framing alone, or is simply the longest or most specific option, rewrite it.
Prefer scenarios where the intuitive answer is wrong and the explanation says
why.

**A card's note must not restate its verdict.** Decision cards carry two texts:
the `right`/`wrong` line, which reacts to the choice the learner just made, and
the `note` under the rule, which is the same either way. The note only earns its
place if it *generalises* — turns the scenario into a rule, adds the other half
of the trade-off, or names the misconception the card sidesteps. If it says the
same thing as the right answer in different words, delete it; the learner has
already read that sentence ten seconds earlier and re-reading it teaches nothing.

**Distractors must be genuinely wrong, not merely worse.** A distractor that
would also work makes the card unanswerable. Where a distractor is a common real
mistake, name it in the explanation and say what it actually does.

**Match cards must not be solvable by elimination — where the content allows.**
When the left column holds traits, properties or effects that more than one
target could plausibly take (species traits, grind sizes, filter body), use an
uneven distribution — 3:2, 2:1:1 — so no drop is forced by the ones before it.
An even split there is really n−1 questions and a freebie.

Some sets are genuinely one-to-one and must stay that way: cherry layers, roast
stages, origin → flavour signature, label claim → what it guarantees, decaf
method → mechanism. Each item has exactly one true partner, and padding them
means inventing a fact or adding a contestable one. Leave those bijective. The
rule is never to fabricate a pair for the sake of an uneven split.
