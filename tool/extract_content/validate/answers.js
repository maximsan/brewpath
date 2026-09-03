"use strict";

/**
 * Card kinds, and the rule that every graded card resolves to exactly one
 * correct answer.
 *
 * The graded kinds are the keys of ANSWER_CHECKS rather than a second list
 * beside it: a kind that gains a check is graded by construction, so the two
 * cannot drift apart. `lessons.json` publishes this key set so the Dart union's
 * `Gradable` markers can be asserted against it — the JS and Dart views of
 * "graded" are the pair that would otherwise drift silently.
 */

/**
 * The 14 authored card kinds. `intro` and `takeaway` are deliberately absent:
 * renderers for them survive in the prototype but no card anywhere uses them —
 * `active-cards.jsx` records that `predict` and `recall` superseded them.
 */
const CARD_KINDS = [
  "predict",
  "concept",
  "mcq",
  "decision",
  "recall",
  "match",
  "multi",
  "slider",
  "sequence",
  "tastefix",
  "visual",
  "practical",
  "bagpick",
  "flavor",
];

/** A slider's target is a percentage of its scale. */
const SLIDER_MIN = 0;
const SLIDER_MAX = 100;

/**
 * How much longer than the runner-up the correct answer may be.
 *
 * The rulebook already forbids an answer that "is simply the longest or most
 * specific option", and the tell is measurable: across graded choice-cards the
 * correct answer was the single longest well above chance. The artifact is
 * familiar — the true answer gains a qualifying clause while the wrong ones stay
 * blunt — and it makes the card answerable with no coffee knowledge at all.
 *
 * Measured against the **runner-up**, not the mean or the shortest, because that
 * is the comparison a guesser actually makes. 1.5 is a dial, set so the check
 * lands green on the content it judges: a check born failing does not stop
 * anything — it gets suppressed in bulk and teaches everyone to bypass it.
 * Tightening it after the authoring pass is a one-line change (#45).
 */
const LONGEST_ANSWER_RATIO = 1.5;

/**
 * Cards with fewer options than this have no runner-up to compare against.
 *
 * Two-option `decision` cards are inside the check: with one wrong answer to
 * compare against, a long correct answer is the strongest tell of all, since
 * picking the longer text beats a coin toss. The two cards that exceeded the
 * ratio were rewritten by the owner before this widened (#100).
 */
const MIN_OPTIONS_FOR_TELL = 2;

/**
 * The correct answer is not conspicuously longer than its nearest rival.
 *
 * Ties are safe by construction: with two answers the same length the ratio is
 * 1, so a card can never fail for being *equal* to its runner-up.
 */
function reportLongestAnswerTell(choices, where, report) {
  if (choices.length < MIN_OPTIONS_FOR_TELL) return;
  // The option itself, `t` — what the learner picks. A decision card also
  // carries `sub`, a justification under each option, deliberately not measured:
  // the threshold was calibrated against option text, and whether a longer
  // justification is its own tell is a content question rather than a
  // validator one.
  const lengthOf = (choice) => (typeof choice.t === "string" ? choice.t.length : 0);

  const texts = choices
    .map((choice) => ({ correct: choice.correct === true, length: lengthOf(choice) }))
    .filter((choice) => choice.length > 0);
  if (texts.length < 2) return;

  const correct = texts.find((choice) => choice.correct);
  if (!correct) return;

  const runnerUp = Math.max(
    ...texts.filter((choice) => choice !== correct).map((choice) => choice.length),
  );
  if (runnerUp === 0) return;

  const ratio = correct.length / runnerUp;
  if (ratio >= LONGEST_ANSWER_RATIO) {
    report(
      where,
      `the correct answer is ${ratio.toFixed(2)}x the length of the runner-up ` +
        `(${correct.length} vs ${runnerUp} characters); at ${LONGEST_ANSWER_RATIO}x ` +
        "or more the card is answerable by picking the longest option. " +
        "Trim the answer, or give the distractors the same specificity.",
    );
  }
}

/** Exactly one entry of `field` carries `correct: true`. */
const oneCorrect = (field) => (card, where, report) => {
  const choices = card[field];
  if (!Array.isArray(choices) || choices.length === 0) {
    return report(where, `has no ${field}`);
  }
  const correct = choices.filter((choice) => choice.correct === true).length;
  if (correct !== 1) {
    report(where, `has ${correct} correct ${field}, expected exactly 1`);
    return;
  }
  reportLongestAnswerTell(choices, where, report);
};

/**
 * Every graded kind, mapped to the check that its answer is well formed. The
 * mastery denominator is this object's key set; a kind that scores without
 * appearing here inflates mastery past 100%, a bug the prototype has shipped
 * once already (`flavor`, fixed Aug 2026).
 */
const ANSWER_CHECKS = {
  mcq: oneCorrect("choices"),
  recall: oneCorrect("choices"),
  tastefix: oneCorrect("choices"),
  decision: oneCorrect("options"),

  /** Select-all: the answer is the set, so it must be neither empty nor all. */
  multi(card, where, report) {
    const choices = card.choices || [];
    const correct = choices.filter((choice) => choice.correct === true).length;
    if (correct === 0) {
      report(where, "has no correct choices, so the set can never be answered");
    } else if (correct === choices.length) {
      report(where, "marks every choice correct, so it is not a question");
    }
  },

  flavor(card, where, report) {
    const choices = card.choices || [];
    const index = card.answer;
    if (!Number.isInteger(index) || index < 0 || index >= choices.length) {
      report(where, `answer ${index} is not an index into its choices`);
    }
  },

  bagpick(card, where, report) {
    const options = card.options || [];
    if (!options.includes(card.answer)) {
      report(where, `answer '${card.answer}' is not one of its options`);
    }
    const cueIds = (card.cues || []).map((cue) => cue.id);
    if (!cueIds.includes(card.tell)) {
      report(where, `tell '${card.tell}' names no cue [${cueIds.join(", ")}]`);
    }
  },

  slider(card, where, report) {
    const { target, tolerance } = card;
    if (typeof target !== "number" || target < SLIDER_MIN || target > SLIDER_MAX) {
      report(where, `target ${target} is outside the ${SLIDER_MIN}–${SLIDER_MAX} scale`);
    }
    if (typeof tolerance !== "number" || tolerance <= 0) {
      report(where, `tolerance ${tolerance} leaves no answer band`);
    }
  },

  sequence(card, where, report) {
    const items = card.items || [];
    const orders = items.map((item) => item.order).sort((a, b) => a - b);
    const expected = items.map((_, index) => index + 1);
    if (orders.join() !== expected.join()) {
      report(where, `orders [${orders.join(", ")}] are not 1…${items.length}`);
    }
  },

  match(card, where, report) {
    const pairs = card.pairs || [];
    if (pairs.length === 0) return report(where, "has no pairs");
    pairs.forEach((pair, index) => {
      if (!pair.l || !pair.r) report(where, `pair ${index + 1} is missing a side`);
    });
  },
};

const GRADED_KINDS = Object.keys(ANSWER_CHECKS);

/** Checks one card's kind, and its answer when the kind is graded. */
function validateCard(card, where, report) {
  if (!CARD_KINDS.includes(card.kind)) {
    return report(where, `has kind '${card.kind}', which ContentCard cannot represent`);
  }
  const check = ANSWER_CHECKS[card.kind];
  if (check) check(card, where, report);
}

module.exports = { validateCard, CARD_KINDS, GRADED_KINDS };
