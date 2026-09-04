"use strict";

/**
 * Fields authored in two places, generated from one of them at write time.
 *
 * The prototype keeps its denormalized shape on purpose — a self-contained
 * lesson object is what makes it ergonomic to write and preview in, and it stays
 * the source of truth. Derivation is a write-time transform here and nowhere
 * else, so the app never reads a copy that can disagree with its original.
 *
 * This is the same move the card union made with `Gradable` and the snapshot
 * made with monotonic merge classes: ask first whether the data can be shaped so
 * the violation cannot occur, and only then write a check. All three defects
 * that motivated this work were fixed by reshaping data, never by a validator.
 *
 * **A disagreement is reported, not silently corrected.** Overwriting an
 * authored value with the derived one would discard an edit someone meant to
 * make, which is the same silence this whole check set exists to remove.
 */

/** `MODULE 3 · ROASTING` — the module's own number and label, never retyped. */
function moduleLabelOf(module) {
  return `MODULE ${module.n} · ${module.label}`;
}

/** The lesson fields the module registry keeps a second copy of. */
const ECHOED_LESSON_FIELDS = ["title", "points", "time"];

/**
 * Rebuilds the two denormalized shapes and reports every authored disagreement.
 *
 * Returns the modules and lessons the banks should be written from. Callers get
 * new objects; the parsed source is left alone so a later validator still sees
 * what was actually authored.
 */
function derive(banks, report) {
  const owningModule = new Map();
  for (const module of banks.modules) {
    for (const entry of module.lessons || []) owningModule.set(entry.id, module);
  }

  const lessons = {};
  for (const [id, lesson] of Object.entries(banks.lessons)) {
    const module = owningModule.get(id);
    // An unclaimed lesson is already reported by the course validator, and it
    // has no module to derive a label from. Pass it through untouched.
    if (!module) {
      lessons[id] = lesson;
      continue;
    }
    const derived = moduleLabelOf(module);
    if (lesson.moduleLabel !== undefined && lesson.moduleLabel !== derived) {
      report(
        `lesson ${id}`,
        `is labelled '${lesson.moduleLabel}' but sits in ${module.id}, which ` +
          `reads '${derived}'. The label is generated from the module, so the ` +
          "authored one would be discarded — fix whichever is wrong.",
      );
    }
    lessons[id] = { ...lesson, moduleLabel: derived };
  }

  const modules = banks.modules.map((module) => ({
    ...module,
    lessons: (module.lessons || []).map((entry) => {
      const lesson = banks.lessons[entry.id];
      // A module listing a lesson that does not exist is the course
      // validator's to report; there is nothing here to derive from.
      if (!lesson) return entry;
      const rebuilt = { ...entry };
      for (const field of ECHOED_LESSON_FIELDS) {
        if (entry[field] !== undefined && entry[field] !== lesson[field]) {
          report(
            `module ${module.id}`,
            `lists ${entry.id} with ${field} ${JSON.stringify(entry[field])}, ` +
              `but the lesson says ${JSON.stringify(lesson[field])}. The ` +
              "registry's copy is generated from the lesson — fix whichever is wrong.",
          );
        }
        rebuilt[field] = lesson[field];
      }
      return rebuilt;
    }),
  }));

  return { modules, lessons };
}

module.exports = { derive, moduleLabelOf };
