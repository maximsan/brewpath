# BrewPath — project rules

## Course content

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

## Design system & notes discipline

**Every design change is recorded in two places.** A new component, style, colour,
icon or interaction pattern is documented in the Design System (`ds-content.js`,
rendered by `Design System.html`) — and gets a short pointer note in
`Migration Notes.md`. The DS carries the rules; the notes carry the history.

**Superseded notes are deleted, not edited.** When a decision replaces an earlier
one, remove the old note and append the new one at the END of `Migration Notes.md`.
Never leave two versions of one rule in the file, and never rewrite history in
place — the order of the file is the order the decisions happened.

**A rule that changed must change everywhere it is stated.** Copy, comments, DS
tables and the audit docs all count. A stale statement of a live rule is how the
prototype and the app came to disagree (#175).

## Authoring traps in this codebase

Recorded because each of these has cost real time more than once.

**JSX comments.** In JSX *children*, only a brace-star comment works. A
double-slash comment there renders as literal text on the page. And a brace-star
comment is illegal in *expression* position — directly inside `x = ( … )`, or
between `cond && (` and the element — where the brace parses as an object
literal and the file stops compiling, which blanks the whole app because Babel
drops every component in that file. A comment must also never quote a comment
terminator inside its own text: it ends early and spills the rest onto the page.
When in doubt put the comment on a plain line ABOVE the statement.

**`ds-content.js` stores em-dashes and apostrophes as literal `\u2014` /
`\u2019` escape sequences.** A find-and-replace written with the real
characters matches nothing and fails silently. Check the log of every scripted
edit to that file rather than assuming it landed.

**Verify each scripted edit actually matched.** Several edits this session were
silent no-ops. Log a boolean per replacement.

**The preview harness does not advance time-based animation.** WAAPI and CSS
transitions both report `playState: running` with `currentTime: 0` and never
move, while `requestAnimationFrame` ticks normally. Motion looks identical to
"frozen, then teleports" here. Never rewrite animation code on sampling evidence
from the preview alone — see Migration Notes §20.

**Sticky offsets resolve against the scroll container's padding box.** Adding
the header height to a container that already pads for the header double-counts
it. Derive the value (`window.STICKY_SECTION_TOP`) instead of picking one.
