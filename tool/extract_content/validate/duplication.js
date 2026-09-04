"use strict";

/**
 * The two ways one piece of content reaches a learner twice.
 *
 * Both are invisible to a referential check: every id resolves, every pointer
 * lands, and the course is still wrong. A lesson pasted into a second module
 * reads as a lesson that did not teach anything new, and two collectibles with
 * one name read as a grid that lost a card.
 *
 * Neither is a rule about ids, so neither belongs in a per-registry validator —
 * they compare content across the whole course, once.
 */

/**
 * A card in canonical form, so two cards compare equal only if every value in
 * them is equal.
 *
 * Keys are sorted at every depth rather than only the top, because two objects
 * that differ solely in key order are the same card. `JSON.stringify`'s second
 * argument does **not** do this: it is a property allow-list applied at every
 * depth, so passing the top-level keys strips every nested object to `{}` —
 * which erases exactly the choices and pairs that distinguish one question from
 * another, and makes two unrelated cards with the same prompt collide.
 */
function canonical(value) {
  if (Array.isArray(value)) return value.map(canonical);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.keys(value)
        .sort()
        .map((key) => [key, canonical(value[key])]),
    );
  }
  return value;
}

/**
 * Position and lesson are deliberately not part of this: the same card in two
 * places is the defect, so what makes two cards identical must not include
 * where they sit.
 */
function fingerprint(card) {
  return JSON.stringify(canonical(card));
}

/**
 * No two lessons carry the same card.
 *
 * Byte-identical only. Paraphrase is the larger half of this defect class and
 * is not machine-decidable without false positives — it stays with the human
 * pass, which the ticket says plainly rather than pretending a check reaches it.
 */
function validateNoRepeatedCards(banks, report) {
  const places = new Map();
  for (const [lessonId, lesson] of Object.entries(banks.lessons)) {
    (lesson.cards || []).forEach((card, index) => {
      const key = fingerprint(card);
      const at = `${lessonId} card ${index + 1}`;
      if (!places.has(key)) places.set(key, []);
      places.get(key).push(at);
    });
  }

  for (const [, at] of places) {
    if (at.length < 2) continue;
    const [first, ...rest] = at;
    report(
      `lesson ${first}`,
      `is byte-identical to ${rest.join(", ")}. ` +
        "A learner meets the same card twice; split the subject or cut one.",
    );
  }
}

/**
 * No two collectibles share a name.
 *
 * The words are on the lesson, not the collectible: a collectible carries
 * identity only (`id`, `unlock`, `kind`) and takes its title from the reward of
 * whatever lesson unlocks it. So the collision this guards against is between
 * two **lesson rewards**, which is where a duplicate title can actually be
 * authored. Checking the collectibles themselves would find nothing, ever.
 */
function validateRewardTitlesAreDistinct(banks, report) {
  const byTitle = new Map();
  for (const [lessonId, lesson] of Object.entries(banks.lessons)) {
    const title = lesson.reward && lesson.reward.title;
    if (!title) continue;
    if (!byTitle.has(title)) byTitle.set(title, []);
    byTitle.get(title).push(lessonId);
  }

  for (const [title, lessons] of byTitle) {
    if (lessons.length < 2) continue;
    report(
      `reward '${title}'`,
      `is the title of the collectible from ${lessons.join(" and ")}. ` +
        "Two cards would sit in the grid under one name.",
    );
  }
}

function validateDuplication(banks, index, report) {
  validateNoRepeatedCards(banks, report);
  validateRewardTitlesAreDistinct(banks, report);
}

module.exports = { validateDuplication };
