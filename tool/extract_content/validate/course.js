"use strict";

const { validateCard } = require("./answers");

/**
 * Modules and lessons, checked together because the rule that matters spans
 * both: every authored lesson is claimed by exactly one module. A lesson no
 * module lists is unreachable in the app, and a lesson two modules list appears
 * twice in the path.
 */
function validateCourse(banks, index, report) {
  const claimed = claimLessons(banks, index, report);
  for (const id of index.lessonIds) {
    if (!claimed.has(id)) {
      report(`lesson ${id}`, "is authored but no module lists it, so it is unreachable");
    }
  }
  validateLessons(banks, report);
}

function claimLessons(banks, index, report) {
  const claimed = new Set();
  for (const module of banks.modules) {
    const where = `module ${module.id}`;
    if (!banks.rewards[module.id]) {
      report(where, "has no MODULE_REWARDS entry, so its Field Guide has no words");
    }
    for (const entry of module.lessons) {
      if (!index.lessonIds.has(entry.id)) {
        report(where, `lists lesson '${entry.id}', which LESSONS does not define`);
      }
      if (claimed.has(entry.id)) {
        report(where, `lists lesson '${entry.id}', which another module claims`);
      }
      claimed.add(entry.id);
    }
  }
  return claimed;
}

function validateLessons(banks, report) {
  for (const [lessonId, lesson] of Object.entries(banks.lessons)) {
    if (!lesson.reward) {
      report(`lesson ${lessonId}`, "has no reward, so its collectible has no words");
    }
    const cards = lesson.cards || [];
    if (cards.length === 0) report(`lesson ${lessonId}`, "has no cards");
    cards.forEach((card, position) => {
      validateCard(card, `lesson ${lessonId} card ${position + 1} (${card.kind})`, report);
    });
  }
}

module.exports = { validateCourse };
