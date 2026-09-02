"use strict";

/**
 * Does the lesson a term points at actually say the word?
 *
 * This is a **word search**, and is named as one — it makes no claim about
 * teaching. A lesson can say a word once in passing and teach nothing; only a
 * human judges that. What the search does catch is the pointer that resolves
 * and is simply false, which is the defect this whole check set exists for:
 * #20 made term Learned state *stored*, so a false pointer is cemented into
 * every user's snapshot with no correction path short of a reset generation.
 */

/**
 * Keys whose values name a mechanism rather than say anything to a learner.
 *
 * Everything else on a card is collected, rather than a list of prose fields
 * being maintained by hand: the fourteen kinds spread their words across some
 * thirty keys — `paragraphs` carries most of the course — and a hand-kept list
 * silently stops seeing a field the day a new kind is authored. Listing what to
 * ignore fails safe; listing what to read fails quiet.
 */
const NOT_PROSE = new Set(["kind", "visualGuide"]);

/**
 * Whole-word, Unicode-aware.
 *
 * Substring matching is permissive in the dangerous direction — *body* matches
 * *everybody*, *fines* matches *defines* — and several terms are short with
 * thin alias lists. A naive `\b` cannot match a term carrying a subscript and
 * invents a false failure on CO₂, so the boundary is expressed as "not a letter,
 * digit or mark" instead.
 */
const WORD_CHARACTER = /[\p{L}\p{N}\p{M}]/u;

function escapeForRegExp(text) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

/** True when `needle` appears in `haystack` bounded by non-word characters. */
function mentionsWholeWord(haystack, needle) {
  const pattern = new RegExp(escapeForRegExp(needle), "giu");
  for (const match of haystack.matchAll(pattern)) {
    const before = haystack[match.index - 1];
    const after = haystack[match.index + match[0].length];
    const boundedLeft = before === undefined || !WORD_CHARACTER.test(before);
    const boundedRight = after === undefined || !WORD_CHARACTER.test(after);
    if (boundedLeft && boundedRight) return true;
  }
  return false;
}

/**
 * Every string on this lesson's cards, joined.
 *
 * Cards only, never the lesson title — a title is a label, not teaching. The
 * sweep is deliberately wide rather than accurate: a handful of the strings it
 * collects are enum values a learner never reads (`answer: "natural"`, a cue
 * `id`), and the keys holding them are the same keys that hold prose elsewhere,
 * so no per-key rule separates them. That makes the check very slightly
 * permissive in one direction — a term could in principle be satisfied by an
 * enum that happens to spell it — and never permissive in the other, which is
 * the trade that matters: a missed false pointer is cemented into every user's
 * snapshot, a spurious failure is one message to an author.
 */
function collectStrings(value, key, into) {
  if (typeof value === "string") {
    if (!NOT_PROSE.has(key)) into.push(value);
    return;
  }
  if (Array.isArray(value)) {
    for (const item of value) collectStrings(item, key, into);
    return;
  }
  if (value && typeof value === "object") {
    for (const [childKey, child] of Object.entries(value)) {
      collectStrings(child, childKey, into);
    }
  }
}

function lessonProse(lesson) {
  const parts = [];
  for (const card of lesson.cards || []) collectStrings(card, null, parts);
  return parts.join("\n");
}

/**
 * The loose search behind the near-miss line.
 *
 * Mechanical rather than a judgement: it lowercases, strips everything that is
 * not a word character, and asks whether the squeezed term appears at all. It
 * either finds something or it does not — which is exactly the difference
 * between "add an alias" and "this pointer is wrong", the two very different
 * repairs the author would otherwise be guessing between.
 */
function squeeze(text) {
  return text.toLowerCase().replace(/[^\p{L}\p{N}]+/gu, "");
}

function nearMiss(prose, term) {
  const squeezedTerm = squeeze(term);
  if (!squeezedTerm) return null;
  for (const line of prose.split("\n")) {
    if (squeeze(line).includes(squeezedTerm)) return line.trim();
  }
  return null;
}

/** Every spelling that counts as saying this term. */
function spellingsOf(term) {
  return [term.term, ...(term.aliases || [])].filter(
    (value) => typeof value === "string" && value.trim() !== "",
  );
}

function validateMentions(banks, index, report) {
  for (const term of banks.terms) {
    if (!term.lesson) continue;
    const lesson = banks.lessons[term.lesson];
    // A pointer at a lesson that does not exist is already reported by the
    // term validator; saying it twice would only bury the other failures.
    if (!lesson) continue;

    const prose = lessonProse(lesson);
    const spellings = spellingsOf(term);
    if (spellings.some((spelling) => mentionsWholeWord(prose, spelling))) continue;

    const similar = nearMiss(prose, term.term);
    const where = `term ${term.id}`;
    if (similar) {
      report(
        where,
        `"${term.term}" is not in ${term.lesson} as a whole word, but the ` +
          `lesson does contain: "${similar}". If that is the same term, add ` +
          "it to the term's aliases.",
      );
    } else {
      report(
        where,
        `"${term.term}" is not in ${term.lesson}, and no similar wording is ` +
          "either. Either this term points at the wrong lesson, or the lesson " +
          "does not teach it.",
      );
    }
  }
}

module.exports = { validateMentions, mentionsWholeWord };
