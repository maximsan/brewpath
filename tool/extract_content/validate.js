"use strict";

const { GRADED_KINDS } = require("./validate/answers");
const { validateCourse } = require("./validate/course");
const { validateCollectibles } = require("./validate/collectibles");
const { validateTerms } = require("./validate/terms");
const { validateChallenges } = require("./validate/challenges");
const { validateMiniGames } = require("./validate/mini_games");

/**
 * Validates the whole cross-reference graph before a single file is written.
 *
 * Every check answers the same question: would this content render as something
 * broken, blank or wrong in the app? A pointer that no longer resolves, a graded
 * card with no correct answer, a dictionary entry whose deeper material has lost
 * the explanation it hangs off. None of these throw at runtime — they degrade
 * quietly, which is why they are caught here instead.
 *
 * Violations are collected rather than thrown, so one run reports every problem
 * and names the card and the reference in each.
 */
function validate(banks) {
  const errors = [];
  const report = (where, message) => errors.push(`${where}: ${message}`);
  const index = indexOf(banks);

  validateCourse(banks, index, report);
  validateCollectibles(banks, index, report);
  validateTerms(banks, index, report);
  validateChallenges(banks, index, report);
  validateMiniGames(banks, index, report);

  return errors;
}

/** Every id a pointer could resolve against, resolved once for all validators. */
function indexOf(banks) {
  return {
    lessonIds: new Set(Object.keys(banks.lessons)),
    moduleIds: new Set(banks.modules.map((module) => module.id)),
    collectibleIds: new Set(banks.collectibles.map((card) => card.id)),
    termIds: new Set(banks.terms.map((term) => term.id)),
    categoryIds: new Set(banks.categories.map((category) => category.id)),
    helpKinds: new Set(Object.keys(banks.cardKindHelp)),
  };
}

module.exports = { validate, GRADED_KINDS };
