"use strict";

/**
 * The mini-game format catalog against the card-kind help map.
 *
 * The help map is surfaced from the "?" beside a card's cue, and the design
 * reference states the invariant directly: every kind with a cue must have a
 * matching help entry — a cue with no drawer is a bug. Checking it per catalog
 * format means a new format cannot ship without its drawer.
 */
function validateMiniGames(banks, index, report) {
  const seen = new Set();
  for (const format of banks.miniGames) {
    const where = `mini-game format '${format.id}'`;
    if (seen.has(format.id)) report(where, "duplicates an earlier format id");
    seen.add(format.id);
    if (!index.helpKinds.has(format.kind)) {
      report(where, `has kind '${format.kind}', which has no help entry`);
    }
  }
}

module.exports = { validateMiniGames };
