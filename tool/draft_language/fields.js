"use strict";

/**
 * Which of a bank's text a language translates, and which it copies.
 *
 * ADR-0008 exempts no prose from translation, so this register names the
 * opposite: the strings a learner never reads as language — ids, enum keys,
 * colours, asset paths — plus the two kinds that need more than translating.
 * A path the register does not name is prose. That direction is deliberate:
 * a new prose field is translated by default, and `translatable_fields_test.dart`
 * fails when the banks grow a string path nobody has classified, so a new
 * *structural* one cannot slip through as prose.
 *
 * A path is written the way `pathOf` renders it: bank name, field names, and
 * `[]` for any list index.
 */

/** Strings code consumes: ids and references, enum keys, colours, paths. */
const STRUCTURAL = {
  "brew_challenges.cardId": "names a card",
  "brew_challenges.id": "an id",
  "brew_challenges.lessonId": "names a lesson",
  "brew_challenges.moduleId": "names a module",
  "brew_challenges.type": "an enum key",
  "card_kind_help.id": "an id",
  "card_kind_help.kind": "an enum key",
  "collectibles.id": "an id",
  "collectibles.kind": "an enum key",
  "collectibles.unlock.lesson": "names a lesson",
  "collectibles.unlock.module": "names a module",
  "companion_gear.id": "an id",
  "companion_hats.id": "an id",
  "companion_lines.id": "an id",
  "companion_lines.occasion": "names a CompanionReaction",
  "companion_roasts.id": "an id",
  "companion_roasts.swatch": "a colour",
  "companion_sprouts.id": "an id",
  "dictionary_categories.glyph": "names a drawing",
  "dictionary_categories.id": "an id",
  "dictionary_terms.cat": "names a category",
  "dictionary_terms.id": "an id",
  "dictionary_terms.lesson": "names a lesson",
  "dictionary_terms.related[]": "names other terms",
  "dictionary_terms.sources[].url": "a link",
  "grove_lights.filter": "a CSS filter",
  "grove_lights.id": "an id",
  "grove_lights.swatch": "a colour",
  "grove_varieties.drop": "an enum key",
  "grove_varieties.id": "an id",
  "grove_varieties.latin": "a Latin binomial, the same in every language",
  "grove_varieties.leaf": "a CSS filter",
  "grove_varieties.shape": "a CSS transform",
  "lessons.cards[].bean.body": "a colour",
  "lessons.cards[].bean.crease": "a colour",
  "lessons.cards[].cues[].id": "an id",
  "lessons.cards[].kind": "an enum key",
  "lessons.cards[].tell": "an enum key",
  "lessons.cards[].visualGuide": "names a guide",
  "lessons.id": "an id",
  "mini_game_content.id": "an id",
  "mini_game_content.rounds[].bean.body": "a colour",
  "mini_game_content.rounds[].bean.crease": "a colour",
  "mini_game_content.rounds[].cues[].id": "an id",
  "mini_game_content.rounds[].kind": "an enum key",
  "mini_game_content.rounds[].tell": "an enum key",
  "mini_games.id": "an id",
  "mini_games.kind": "an enum key",
  "mini_games.lesson": "names a lesson",
  "modules.art": "an asset path",
  "modules.artPos": "a CSS position",
  "modules.glyph": "names a drawing",
  "modules.id": "an id",
  "modules.lessons[].id": "names a lesson",
  "modules.lessons[].status": "prototype demo state the app never reads",
  "visual_guides.id": "an id",
  "visual_guides.layers[].latin": "a Latin name, the same in every language",
  "visual_guides.layers[].n": "a numeral",
  "visual_guides.unlock.lesson": "names a lesson",
  "visual_guides.visualGuide": "names a guide",
};

/**
 * An answer held as one of its options' words, not as an index.
 *
 * Translating the options without it leaves the card unanswerable, so the
 * answer takes whatever its option became. Every other correct-answer marker
 * in the banks is an index, a flag on the choice, or a boolean.
 */
const MIRRORS = {
  "lessons.cards[].answer": "lessons.cards[].options[]",
  "lessons.cards[].fill[].a": "lessons.cards[].fill[].o[]",
  "mini_game_content.rounds[].answer": "mini_game_content.rounds[].options[]",
};

/** Search keys a language sets the length of, not prose (ADR-0025). */
const SEARCH_KEYS = new Set(["dictionary_terms.aliases[]"]);

/** The register's path for [pointer]: list indices collapse to `[]`. */
function pathOf(bank, pointer) {
  return (
    bank +
    pointer
      .map((step) => (typeof step === "number" ? "[]" : `.${step}`))
      .join("")
  );
}

/** What a language does with the string at [path]. */
function classify(path) {
  if (STRUCTURAL[path]) return "structural";
  if (MIRRORS[path]) return "mirror";
  if (SEARCH_KEYS.has(path)) return "searchKeys";
  return "prose";
}

/** The options path whose translation [path]'s answer must match. */
function mirrorOf(path) {
  return MIRRORS[path] || null;
}

/** Every string in [record], as `{ path, pointer, value }`, in bank order. */
function stringsIn(bank, record) {
  const found = [];
  const walk = (value, pointer) => {
    if (typeof value === "string") {
      found.push({ path: pathOf(bank, pointer), pointer, value });
    } else if (Array.isArray(value)) {
      value.forEach((item, index) => walk(item, [...pointer, index]));
    } else if (value && typeof value === "object") {
      for (const [key, item] of Object.entries(value)) {
        walk(item, [...pointer, key]);
      }
    }
  };
  walk(record, []);
  return found;
}

/** The strings a language must supply its own words for. */
function translatableIn(bank, record) {
  return stringsIn(bank, record).filter(
    ({ path }) => classify(path) === "prose",
  );
}

module.exports = {
  STRUCTURAL,
  MIRRORS,
  SEARCH_KEYS,
  pathOf,
  classify,
  mirrorOf,
  stringsIn,
  translatableIn,
};
