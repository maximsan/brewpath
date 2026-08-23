"use strict";

/**
 * The eight illustrated references, and the rule that turns ten lesson
 * placements into eight guides.
 *
 * Every check here is a defect this content has already produced or narrowly
 * avoided, which is why each is worth the run refusing over:
 *
 * - Three subjects were once fully authored with no card behind them, so a
 *   learner could save a guide that could never be opened again. That is the
 *   `visual`-resolves check.
 * - `grind` is taught in three lessons. Which of them unlocks it is not a
 *   preference — unlocking at anything but the earliest means a learner is
 *   shown a reference as locked *after* being taught it. That is the earliest
 *   check, and it is what makes reordering lessons safe.
 * - Two guides carry two meta rows and the rest carry three, so an "exactly
 *   three" assumption is wrong in both directions.
 */

/** Copy a guide owes its sheet; an empty one renders a blank block. */
const GUIDE_COPY = ["label", "title", "summary", "fact"];

/**
 * The guides are a closed set, checked exactly rather than as a minimum.
 *
 * Eight is what the course teaches; a ninth arriving silently would ship a
 * shelf the design does not describe, and a subject going missing would leave
 * a lesson teaching something the app cannot show. Both should stop the build
 * and be re-decided.
 */
const GUIDE_COUNT = 8;

/** A meta table is a short scannable pair list, never a paragraph. */
const META_ROWS_MIN = 2;
const META_ROWS_MAX = 3;

function validateVisualGuides(banks, index, report) {
  const guides = banks.visualGuideCards;
  const words = banks.visualGuideContent;

  bothRegistriesAgree(guides, words, report);
  countIsClosed(guides, report);

  for (const guide of guides) {
    const where = `visual guide ${guide.id}`;
    unlockResolves(guide, index, where, report);
    unlockIsEarliestTeachingLesson(guide, banks, where, report);
    metaIsAShortPairList(guide, where, report);

    for (const field of GUIDE_COPY) {
      const value = words[guide.visualGuide]?.[field];
      // Whitespace is not copy: a blank-looking title renders the blank sheet
      // this check exists to prevent.
      if (typeof value !== "string" || value.trim() === "") {
        report(where, `has no \`${field}\` — its sheet would render blank`);
      }
    }
  }

  everyLessonVisualHasAGuide(banks, guides, report);
}

/**
 * Exactly eight guides, and one card per subject.
 *
 * Two cards naming the same subject is the case a set comparison cannot see:
 * both sides would agree on the subjects while the join emitted nine records,
 * two of them carrying identical words.
 */
function countIsClosed(guides, report) {
  if (guides.length !== GUIDE_COUNT) {
    report(
      "visual guides",
      `there are ${guides.length}; the course teaches ${GUIDE_COUNT}`,
    );
  }
  const seen = new Set();
  for (const guide of guides) {
    if (seen.has(guide.visualGuide)) {
      report(
        `visual guide ${guide.id}`,
        `is a second card for \`${guide.visualGuide}\` — the shelf would ` +
          "list that subject twice",
      );
    }
    seen.add(guide.visualGuide);
  }
}

/** One subject per guide, present on both sides, each keyed by its own id. */
function bothRegistriesAgree(guides, words, report) {
  const carded = new Set(guides.map((guide) => guide.visualGuide));
  const worded = new Set(Object.keys(words));

  for (const subject of carded) {
    if (!worded.has(subject)) {
      report(`visual guide ${subject}`, "has a card but no words");
    }
  }
  for (const subject of worded) {
    if (!carded.has(subject)) {
      report(
        `visual guide ${subject}`,
        "has words but no card — nothing can ever open it",
      );
    }
    if (words[subject].id !== subject) {
      report(
        `visual guide ${subject}`,
        `is keyed \`${subject}\` but carries id \`${words[subject].id}\``,
      );
    }
  }
}

function unlockResolves(guide, index, where, report) {
  const lessonId = guide.unlock?.lesson;
  if (!lessonId) {
    report(where, "names no unlock lesson");
    return;
  }
  if (!index.lessonIds.has(lessonId)) {
    report(where, `unlocks at \`${lessonId}\`, which is not a lesson`);
  }
}

/**
 * A guide unlocks at the **earliest** lesson, in course order, that shows it.
 *
 * Course order is the module order the course ships in, then each module's own
 * lesson order — the order a learner meets them, which is the only order this
 * rule can mean.
 */
function unlockIsEarliestTeachingLesson(guide, banks, where, report) {
  const teaching = lessonsShowing(banks, guide.visualGuide);
  if (teaching.length === 0) {
    report(where, "is taught by no lesson, so nothing can ever unlock it");
    return;
  }
  const earliest = teaching[0];
  if (guide.unlock?.lesson !== earliest) {
    report(
      where,
      `unlocks at \`${guide.unlock?.lesson}\`, but \`${earliest}\` teaches it ` +
        "first — a learner would be shown it locked after being taught it",
    );
  }
}

/** Every lesson id showing `subject`, in course order. */
function lessonsShowing(banks, subject) {
  const shown = [];
  for (const module of banks.modules) {
    for (const { id } of module.lessons) {
      const cards = banks.lessons[id]?.cards ?? [];
      const shows = cards.some(
        (card) => card.kind === "visual" && card.visualGuide === subject,
      );
      if (shows) shown.push(id);
    }
  }
  return shown;
}

/** No lesson may show a visual whose subject has no guide behind it. */
function everyLessonVisualHasAGuide(banks, guides, report) {
  const subjects = new Set(guides.map((guide) => guide.visualGuide));
  for (const [lessonId, lesson] of Object.entries(banks.lessons)) {
    for (const card of lesson.cards ?? []) {
      if (card.kind !== "visual") continue;
      if (!subjects.has(card.visualGuide)) {
        report(
          `lesson ${lessonId}`,
          `shows visual \`${card.visualGuide}\`, which has no guide — saving ` +
            "it would be a dead end",
        );
      }
    }
  }
}

function metaIsAShortPairList(guide, where, report) {
  const meta = guide.meta ?? [];
  if (meta.length < META_ROWS_MIN || meta.length > META_ROWS_MAX) {
    report(
      where,
      `has ${meta.length} meta rows; a guide carries ` +
        `${META_ROWS_MIN}–${META_ROWS_MAX}`,
    );
  }
  for (const row of meta) {
    if (!Array.isArray(row) || row.length !== 2 || row.some((cell) => !cell)) {
      report(where, `has a meta row that is not a label and a value: ${row}`);
    }
  }
}

module.exports = { validateVisualGuides };
