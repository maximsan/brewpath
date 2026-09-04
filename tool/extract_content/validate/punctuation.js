"use strict";

const { collectStrings } = require("./mentions");

/**
 * The course sets its quotes as “ ” and its apostrophes as ’.
 *
 * A straight mark (`"` or `'`) is not wrong English — it is the one place on
 * the page set differently from the hundred and thirty-five around it. The
 * check reads every string a learner sees on a card, in a guide's words, and
 * in mini-game content, and names the sentence so the fix is a retype.
 *
 * Dashes are deliberately not checked: `--` is a CSS custom property wherever
 * it appears in the source, never prose.
 */
const STRAIGHT_MARK = /["']/;

/** The first straight mark in `text`, with enough of the sentence to find it. */
function excerpt(text) {
  const at = text.search(STRAIGHT_MARK);
  const start = Math.max(0, at - 30);
  return text.slice(start, at + 30).replace(/\s+/g, " ").trim();
}

function reportStraightMarks(value, where, report) {
  const strings = [];
  collectStrings(value, null, strings);
  for (const text of strings) {
    if (!STRAIGHT_MARK.test(text)) continue;
    report(
      where,
      `uses a straight quote mark in “…${excerpt(text)}…”; the course sets ` +
        "quotes as “ ” and apostrophes as ’ — retype it.",
    );
  }
}

function validatePunctuation(banks, index, report) {
  for (const [lessonId, lesson] of Object.entries(banks.lessons)) {
    (lesson.cards ?? []).forEach((card, position) => {
      reportStraightMarks(
        card,
        `lesson ${lessonId} card ${position + 1} (${card.kind})`,
        report,
      );
    });
  }
  for (const [subject, words] of Object.entries(banks.visualGuideContent ?? {})) {
    reportStraightMarks(words, `visual guide ${subject}`, report);
  }
  reportStraightMarks(banks.miniGameContent ?? {}, "mini-game content", report);
}

module.exports = { validatePunctuation };
