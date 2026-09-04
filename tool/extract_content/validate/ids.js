"use strict";

/**
 * Id uniqueness across families that share a prefix.
 *
 * Every registry already refuses a duplicate inside itself. That is not enough:
 * `g-` now prefixes **two** families authored in different files under different
 * rules — mini-game formats (`g-match`, `g-quiz`, `g-flavor`) and visual guides
 * (`g-roast` … `g-distribution`). A per-registry check passes a `g-flavor`
 * guide, and two things sharing an id in two files nobody reads together is
 * exactly the collision this check set exists to catch (#106).
 *
 * Nothing is saved under a guide's id — a guide is saved as `g:` plus its
 * subject — so a clash is not a data-loss bug today. It is an ambiguity bug: a
 * message naming `g-flavor` stops telling you which thing it means.
 */

/** The families that share the `g-` namespace, each with where to look. */
function familiesOf(banks) {
  return [
    { family: "mini-game format", ids: banks.miniGames.map((format) => format.id) },
    { family: "visual guide", ids: banks.visualGuideCards.map((card) => card.id) },
  ];
}

function validateIds(banks, index, report) {
  const owners = new Map();
  for (const { family, ids } of familiesOf(banks)) {
    for (const id of ids) {
      if (!owners.has(id)) owners.set(id, []);
      owners.get(id).push(family);
    }
  }

  for (const [id, families] of owners) {
    if (families.length < 2) continue;
    report(
      `id '${id}'`,
      `names a ${families.join(" and a ")}. The two registries are authored ` +
        "separately, so one id has to mean one thing across both.",
    );
  }
}

module.exports = { validateIds };
