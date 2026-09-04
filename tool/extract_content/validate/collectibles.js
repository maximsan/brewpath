"use strict";

/**
 * Collectible cards carry identity only — the words come from whatever unlocks
 * them. That is the prototype's "one card, one text" rule, and it is why an
 * unlock pointing nowhere is worth failing a run over: the card still appears
 * in the grid, blank.
 */
/**
 * One lesson, one collectible — in both directions.
 *
 * The reward relationship is one-to-one by design: a lesson's reward words are
 * the collectible's words, so a lesson with two collectibles gives one of them
 * no text, and a lesson with none leaves a finished lesson paying out nothing.
 * Neither breaks a pointer, so neither is caught by resolving ids.
 */
function validateOnePerLesson(banks, index, report) {
  const byLesson = new Map();
  for (const card of banks.collectibles) {
    const lesson = (card.unlock || {}).lesson;
    if (!lesson) continue;
    if (!byLesson.has(lesson)) byLesson.set(lesson, []);
    byLesson.get(lesson).push(card.id);
  }

  for (const [lesson, ids] of byLesson) {
    if (ids.length > 1) {
      report(
        `lesson ${lesson}`,
        `unlocks ${ids.length} collectibles (${ids.join(", ")}); ` +
          "one lesson pays out exactly one card.",
      );
    }
  }

  for (const id of index.lessonIds) {
    if (!byLesson.has(id)) {
      report(`lesson ${id}`, "unlocks no collectible, so finishing it pays out nothing");
    }
  }
}

function validateCollectibles(banks, index, report) {
  validateOnePerLesson(banks, index, report);
  const seen = new Set();
  for (const card of banks.collectibles) {
    const where = `collectible ${card.id}`;
    if (seen.has(card.id)) report(where, "is declared twice");
    seen.add(card.id);

    const unlock = card.unlock || {};
    const sources = ["lesson", "module"].filter((key) => unlock[key]);
    if (sources.length !== 1) {
      report(where, `unlock names ${sources.length} sources, expected exactly 1`);
      continue;
    }
    if (unlock.lesson && !index.lessonIds.has(unlock.lesson)) {
      report(where, `unlocks from lesson '${unlock.lesson}', which does not exist`);
    }
    if (unlock.module && !index.moduleIds.has(unlock.module)) {
      report(where, `unlocks from module '${unlock.module}', which does not exist`);
    }
  }
}

module.exports = { validateCollectibles };
