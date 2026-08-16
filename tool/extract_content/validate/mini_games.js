"use strict";

const { validateCard, CARD_KINDS } = require("./answers");

const QUIZ_KIND = "quiz";

/**
 * The mini-game format catalog, its content bank, and the card-kind help map.
 *
 * Two invariants come straight from the design reference. Every kind with a
 * cue must have a matching help entry — a cue with no drawer is a bug — so
 * both the catalog and every round are checked against the help map. And a
 * game's intro states the real round count read from the content bank, which
 * only means anything if the rounds are actually there: a format extracting
 * to zero rounds is the silent failure this bank's extraction is built
 * around, so it refuses the run instead of passing.
 */
function validateMiniGames(banks, index, report) {
  const catalogIds = new Set();
  for (const format of banks.miniGames) {
    const where = `mini-game format '${format.id}'`;
    if (catalogIds.has(format.id)) {
      report(where, "duplicates an earlier format id");
    }
    catalogIds.add(format.id);
    if (!index.helpKinds.has(format.kind)) {
      report(where, `has kind '${format.kind}', which has no help entry`);
    }
    if (!Object.hasOwn(banks.miniGameContent, format.id)) {
      report(where, "has no entry in MINI_GAME_CONTENT");
    }
  }

  for (const [formatId, rounds] of Object.entries(banks.miniGameContent)) {
    const where = `mini-game content '${formatId}'`;
    if (!catalogIds.has(formatId)) {
      report(where, "matches no catalog format");
    }
    if (!Array.isArray(rounds) || rounds.length === 0) {
      report(where, "has no rounds — an empty game would otherwise pass silently");
      continue;
    }
    rounds.forEach((round, roundIndex) => {
      validateRound(round, `${where} round ${roundIndex + 1}`, index, report);
    });
  }
}

function validateRound(round, where, index, report) {
  if (round.kind === QUIZ_KIND) {
    validateQuizAnswer(round, where, report);
  } else if (!CARD_KINDS.includes(round.kind)) {
    // Not validateCard's "ContentCard cannot represent": mini-games are not
    // bound to the union, `quiz` being the standing proof.
    report(where, `has kind '${round.kind}', which no mini-game round carries`);
  } else {
    validateCard(round, where, report);
  }
  if (!index.helpKinds.has(round.kind)) {
    report(where, `has kind '${round.kind}', which has no help entry`);
  }
}

/**
 * True/false is unique to mini-games, so its check lives here: joining
 * `ANSWER_CHECKS` would widen the graded-kinds set the lessons bank publishes
 * (the header register carries the full rationale).
 */
function validateQuizAnswer(round, where, report) {
  if (typeof round.answer !== "boolean") {
    report(where, `answer ${JSON.stringify(round.answer)} is not true or false`);
  }
}

module.exports = { validateMiniGames };
