"use strict";

/**
 * A match card the learner can finish by elimination.
 *
 * The learner pairs left items with right items. When every right item is
 * used exactly once, placing all but one pair forces the last: a four-pair
 * card is really three questions. The fix is to rebalance the pairs so one
 * right item serves two left ones — never to invent a pair for the sake of an
 * uneven split.
 *
 * Some sets genuinely are one-to-one, and the card is teaching exactly that
 * mapping. Those are listed by name in `exceptions.json`, each with a reason,
 * so an allowance is visible in review and cannot be granted by weakening the
 * check for everyone (#100, decision 3). An entry that names no match card, or
 * names one that is no longer one-to-one, fails the run: a stale allowance is
 * a suppression nobody asked for.
 */

const ALLOWANCE = "matchEvenSplit";
const EXCEPTIONS_FILE = "tool/extract_content/exceptions.json";

/** The key a card is listed under — the same words its messages use. */
function keyOf(lessonId, position) {
  return `lesson ${lessonId} card ${position + 1}`;
}

function isOneToOne(card) {
  const rights = (card.pairs ?? []).map((pair) => pair.r);
  return rights.length > 1 && new Set(rights).size === rights.length;
}

function validateMatchSplit(banks, index, report, exceptions) {
  const allowed = exceptions?.[ALLOWANCE] ?? {};
  const matchCards = new Map();

  for (const [lessonId, lesson] of Object.entries(banks.lessons)) {
    (lesson.cards ?? []).forEach((card, position) => {
      if (card.kind !== "match") return;
      matchCards.set(keyOf(lessonId, position), card);
    });
  }

  for (const [key, card] of matchCards) {
    const oneToOne = isOneToOne(card);
    const listed = Object.hasOwn(allowed, key);
    if (oneToOne && !listed) {
      const pairs = (card.pairs ?? []).length;
      report(
        `${key} (match)`,
        "every right-hand item is used exactly once, so placing all but one " +
          `pair forces the last — a ${pairs}-pair card is really ${pairs - 1} ` +
          "questions. Rebalance the pairs so one right item serves two left " +
          "ones (never invent a pair), or, if the set is genuinely " +
          `one-to-one, list \`${key}\` in ${EXCEPTIONS_FILE} under ` +
          `\`${ALLOWANCE}\` with the reason.`,
      );
    }
    if (!oneToOne && listed) {
      report(
        key,
        `is listed in ${EXCEPTIONS_FILE} under \`${ALLOWANCE}\`, but its ` +
          "right column is no longer one-to-one — remove the stale entry.",
      );
    }
  }

  for (const [key, reason] of Object.entries(allowed)) {
    if (!matchCards.has(key)) {
      report(
        key,
        `is listed in ${EXCEPTIONS_FILE} under \`${ALLOWANCE}\` but names ` +
          "no match card — remove the stale entry.",
      );
    }
    if (typeof reason !== "string" || reason.trim() === "") {
      report(
        key,
        `is listed in ${EXCEPTIONS_FILE} with no reason — every allowance ` +
          "says why, or the list decays into things that were turned off.",
      );
    }
  }
}

module.exports = { validateMatchSplit };
