"use strict";

/**
 * Collectible cards carry identity only — the words come from whatever unlocks
 * them. That is the prototype's "one card, one text" rule, and it is why an
 * unlock pointing nowhere is worth failing a run over: the card still appears
 * in the grid, blank.
 */
function validateCollectibles(banks, index, report) {
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
