"use strict";

/**
 * The grove's two axes: the coffee species a learner plants, and the light it
 * stands in.
 *
 * Both counts are checked exactly rather than as a minimum, which is unusual
 * here and deliberate. Three species and four lights are a closed product
 * ruling, not a content list that grows: the species axis teaches a fact the
 * course itself teaches, and a fourth arriving silently would ship a chooser
 * the ruling does not describe. A count that moves should stop the build and
 * be re-decided, so the number lives here where it fails loudly.
 *
 * `drop` is carried through as data and is deliberately not read as a gate —
 * all three species ship, and a rollout note in the source must not be able to
 * re-defer that decision by itself.
 */

/** The species that ship, in the order the chooser lists them. */
const VARIETY_COUNT = 3;

/** Daylight plus three treatments. */
const LIGHT_COUNT = 4;

/** The species whose art is the real, unfiltered illustration. */
const IDENTITY_VARIETY = "arabica";

/** Copy every species owes the chooser; an empty one renders a blank row. */
const VARIETY_COPY = [
  "name",
  "latin",
  "share",
  "use",
  "origin",
  "grows",
  "cup",
  "tell",
];

/** Copy every light owes the picker. */
const LIGHT_COPY = ["name", "note", "swatch"];

/**
 * The CSS filter primitives the app knows how to turn into a colour matrix.
 * A filter naming anything else would compose to something the Flutter side
 * silently drops, so it is refused here instead.
 */
const FILTER_PRIMITIVES = new Set([
  "sepia",
  "saturate",
  "hue-rotate",
  "brightness",
  "contrast",
]);

const FILTER_TERM = /([a-z-]+)\(([^)]*)\)/g;

function validateGrove(banks, index, report) {
  validateCount("grove varieties", banks.groveVarieties, VARIETY_COUNT, report);
  validateCount("grove lights", banks.groveLights, LIGHT_COUNT, report);

  const varietyIds = new Set();
  for (const variety of banks.groveVarieties) {
    const where = `grove variety '${variety.id}'`;
    if (varietyIds.has(variety.id)) {
      report(where, "duplicates an earlier variety id");
    }
    varietyIds.add(variety.id);
    requireCopy(variety, VARIETY_COPY, where, report);

    // Arabica is the ten shipped frames as drawn. Any treatment on it would
    // mean no variety renders the real art, and the other two are defined as
    // departures from it.
    if (variety.id === IDENTITY_VARIETY) {
      if (variety.leaf) {
        report(where, "carries a leaf tone, but Arabica is the unfiltered art");
      }
      if (variety.shape && variety.shape !== "none") {
        report(where, "carries a silhouette, but Arabica is the unfiltered art");
      }
    }
    validateFilter(variety.leaf, `${where} leaf tone`, report);
  }

  const lightIds = new Set();
  for (const light of banks.groveLights) {
    const where = `grove light '${light.id}'`;
    if (lightIds.has(light.id)) {
      report(where, "duplicates an earlier light id");
    }
    lightIds.add(light.id);
    requireCopy(light, LIGHT_COPY, where, report);
    validateFilter(light.filter, `${where} filter`, report);
  }
}

function validateCount(what, items, expected, report) {
  if (!Array.isArray(items) || items.length !== expected) {
    const found = Array.isArray(items) ? items.length : "not a list";
    report(
      what,
      `has ${found} entries, but exactly ${expected} are decided — a count ` +
        "that moves is a product decision, not a content edit",
    );
  }
}

function requireCopy(entry, fields, where, report) {
  for (const field of fields) {
    if (typeof entry[field] !== "string" || entry[field].trim() === "") {
      report(where, `has no ${field}`);
    }
  }
}

/**
 * An empty filter is the identity and always allowed; anything present must be
 * a chain of primitives the app can compose.
 */
function validateFilter(filter, where, report) {
  if (filter === undefined || filter === null || filter.trim() === "") return;

  const terms = [...String(filter).matchAll(FILTER_TERM)];
  if (terms.length === 0) {
    report(where, `is '${filter}', which parses to no filter terms`);
    return;
  }
  for (const [, primitive] of terms) {
    if (!FILTER_PRIMITIVES.has(primitive)) {
      report(where, `uses '${primitive}', which the app cannot compose`);
    }
  }
}

module.exports = { validateGrove, VARIETY_COUNT, LIGHT_COUNT };
