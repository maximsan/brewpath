"use strict";

/**
 * Term material that only makes sense underneath the full explanation: an
 * example of what, a self-check on what, sources for what. A term carrying any
 * of these without `deep` renders as a stub with an orphaned quiz stapled to it.
 */
const DEEP_ONLY_FIELDS = ["example", "check", "sources"];

function validateTerms(banks, index, report) {
  for (const term of banks.terms) {
    const where = `term ${term.id}`;
    if (!term.short) {
      report(where, "has no short explanation, so it cannot be shown anywhere");
    }
    if (!index.categoryIds.has(term.cat)) {
      report(where, `sits in category '${term.cat}', which does not exist`);
    }
    if (term.lesson && !index.lessonIds.has(term.lesson)) {
      report(where, `points at lesson '${term.lesson}', which does not exist`);
    }
    for (const related of term.related || []) {
      if (!index.termIds.has(related)) {
        report(where, `relates to term '${related}', which does not exist`);
      }
    }
    if (!term.deep) reportOrphanedMaterial(term, where, report);
  }
}

function reportOrphanedMaterial(term, where, report) {
  for (const field of DEEP_ONLY_FIELDS) {
    if (isPresent(term[field])) {
      report(where, `carries '${field}' but no deep explanation to attach it to`);
    }
  }
}

function isPresent(value) {
  if (value == null) return false;
  return Array.isArray(value) ? value.length > 0 : true;
}

module.exports = { validateTerms };
