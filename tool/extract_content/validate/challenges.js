"use strict";

/**
 * Brew challenges are validated for the graph's sake rather than the app's. No
 * screen reads them yet, but their lesson, module and collectible pointers are
 * 31 edges that would otherwise go unchecked — including into `m1l1` and `c1`,
 * the content the first slice actually ships.
 */
function validateChallenges(banks, index, report) {
  for (const challenge of banks.challenges) {
    const where = `challenge ${challenge.id}`;
    if (challenge.type !== "lesson" && challenge.type !== "module") {
      report(where, `has type '${challenge.type}', expected 'lesson' or 'module'`);
    }
    if (challenge.type === "lesson" && !challenge.lessonId) {
      report(where, "is a lesson challenge with no lessonId");
    }
    if (challenge.lessonId && !index.lessonIds.has(challenge.lessonId)) {
      report(where, `points at lesson '${challenge.lessonId}', which does not exist`);
    }
    if (challenge.moduleId && !index.moduleIds.has(challenge.moduleId)) {
      report(where, `points at module '${challenge.moduleId}', which does not exist`);
    }
    if (challenge.cardId && !index.collectibleIds.has(challenge.cardId)) {
      report(where, `stamps collectible '${challenge.cardId}', which does not exist`);
    }
  }
}

module.exports = { validateChallenges };
