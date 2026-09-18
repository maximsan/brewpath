"use strict";

const crypto = require("node:crypto");

/**
 * The mark that says which English a translation was made from (ADR-0026).
 *
 * Short on purpose: it is compared, never inverted, and a folder carries one
 * per translated field. Taken over the English text alone, so moving a card
 * within its lesson leaves every fingerprint in it alone.
 */
function fingerprint(english) {
  return crypto
    .createHash("sha256")
    .update(String(english), "utf8")
    .digest("hex")
    .slice(0, 12);
}

module.exports = { fingerprint };
