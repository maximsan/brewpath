"use strict";

const { fingerprint } = require("./fingerprint");
const {
  classify,
  mirrorOf,
  pathOf,
  stringsIn,
  translatableIn,
} = require("./fields");

/** The mark key for [pointer]: the field's place inside its own entry. */
function keyOf(pointer) {
  return pointer
    .map((step) => (typeof step === "number" ? `[${step}]` : `.${step}`))
    .join("")
    .replace(/^\./, "");
}

const TRANSLATED_FROM = "translatedFrom";
const NATIVE_REVIEWED = "nativeReviewed";

/** The value at [pointer] inside [root], or undefined. */
function at(root, pointer) {
  return pointer.reduce(
    (node, step) => (node === undefined || node === null ? undefined : node[step]),
    root,
  );
}

/** Writes [value] at [pointer] inside [root], making the shape on the way. */
function put(root, pointer, value) {
  let node = root;
  pointer.slice(0, -1).forEach((step, index) => {
    const next = pointer[index + 1];
    if (node[step] === undefined) node[step] = typeof next === "number" ? [] : {};
    node = node[step];
  });
  node[pointer[pointer.length - 1]] = value;
}

/**
 * What a language still owes on one bank.
 *
 * A field is **absent** when the folder has no words for it and **stale** when
 * the English it was translated from has changed since (ADR-0026). A stale
 * field keeps the words it has — ADR-0027 leaves the reader a translation
 * until a better one arrives — so this only ever queues work.
 */
function planBank({ bank, master, folder }) {
  const translated = new Map(folder.map((entry) => [entry.id, entry]));
  const work = [];
  for (const record of master) {
    const entry = translated.get(record.id);
    const marks = (entry || {})[TRANSLATED_FROM] || {};
    for (const { pointer, value } of translatableIn(bank, record)) {
      const key = keyOf(pointer);
      const has = entry !== undefined && at(entry, pointer) !== undefined;
      const digest = fingerprint(value);
      const state = !has ? "absent" : marks[key] === digest ? "current" : "stale";
      if (state === "current") continue;
      work.push({
        bank,
        id: record.id,
        key,
        english: value,
        state,
        held: has ? at(entry, pointer) : null,
      });
    }
  }
  return work;
}

/** Every alias list the language has not written its own forms for yet. */
function aliasWork({ bank, master, folder }) {
  const translated = new Map(folder.map((entry) => [entry.id, entry]));
  const work = [];
  for (const record of master) {
    for (const { path, pointer } of stringsIn(bank, record)) {
      if (classify(path) !== "searchKeys") continue;
      const listPointer = pointer.slice(0, -1);
      const entry = translated.get(record.id);
      if (entry !== undefined && at(entry, listPointer) !== undefined) break;
      work.push({
        bank,
        id: record.id,
        key: keyOf(listPointer),
        english: at(record, listPointer),
        state: "absent",
        searchKeys: true,
        held: null,
      });
      break;
    }
  }
  return work;
}

/**
 * [folder] with [translations] written into it, marks brought up to date.
 *
 * A field whose English is unchanged keeps its words *and* its review mark;
 * a field translated afresh loses its review mark, because nobody has read
 * the new words yet (ADR-0026).
 */
function applyBank({ bank, master, folder, translations }) {
  const held = new Map(folder.map((entry) => [entry.id, entry]));
  const out = [];
  for (const record of master) {
    const previous = held.get(record.id) || {};
    const entry = { id: record.id };
    const marks = {};
    const reviewed = {};
    const previousMarks = previous[TRANSLATED_FROM] || {};
    const previousReviewed = previous[NATIVE_REVIEWED] || {};

    for (const { pointer, value } of translatableIn(bank, record)) {
      const key = keyOf(pointer);
      const supplied = translations.get(`${record.id}|${key}`);
      const digest = fingerprint(value);
      const carried = at(previous, pointer);
      const fresh = supplied !== undefined && supplied !== "";
      const text = fresh ? supplied : carried;
      if (text === undefined) continue;
      put(entry, pointer, text);
      marks[key] = fresh ? digest : previousMarks[key];
      if (!fresh && previousReviewed[key]) reviewed[key] = true;
    }

    copySearchKeys({ bank, record, previous, entry, translations });

    mirrorAnswers({ bank, record, entry });
    if (Object.keys(entry).length === 1) continue;
    if (Object.keys(marks).length) entry[TRANSLATED_FROM] = marks;
    if (Object.keys(reviewed).length) entry[NATIVE_REVIEWED] = reviewed;
    out.push(entry);
  }
  return out;
}

/** A language's own alias forms, kept whole — it sets their length. */
function copySearchKeys({ bank, record, previous, entry, translations }) {
  for (const { path, pointer } of stringsIn(bank, record)) {
    if (classify(path) !== "searchKeys") continue;
    const listPointer = pointer.slice(0, -1);
    const key = keyOf(listPointer);
    const supplied = translations.get(`${record.id}|${key}`);
    const value = supplied !== undefined ? supplied : at(previous, listPointer);
    if (Array.isArray(value) && value.length) put(entry, listPointer, value);
    return;
  }
}

/** Points each mirrored answer at whatever its own option became. */
function mirrorAnswers({ bank, record, entry }) {
  for (const { path, pointer, value } of stringsIn(bank, record)) {
    if (classify(path) !== "mirror") continue;
    const optionsPath = mirrorOf(path);
    const siblings = optionsPointersFor({ bank, record, pointer, optionsPath });
    const chosen = siblings.find(
      (option) => at(record, option) === value,
    );
    if (chosen === undefined) continue;
    const translatedOption = at(entry, chosen);
    if (translatedOption !== undefined) put(entry, pointer, translatedOption);
  }
}

/** Where the options that [pointer]'s answer chooses from actually sit. */
function optionsPointersFor({ bank, record, pointer, optionsPath }) {
  const owner = pointer.slice(0, -1);
  const list = at(record, [...owner, optionsPath.split(".").pop().replace("[]", "")]);
  if (!Array.isArray(list)) return [];
  return list.map((_, index) => [
    ...owner,
    optionsPath.split(".").pop().replace("[]", ""),
    index,
  ]);
}

/** What stops [folder] being called complete: every prose field must be there. */
function checkBank({ bank, master, folder }) {
  const translated = new Map(folder.map((entry) => [entry.id, entry]));
  const missing = [];
  for (const record of master) {
    const entry = translated.get(record.id);
    for (const { pointer } of translatableIn(bank, record)) {
      if (entry !== undefined && at(entry, pointer) !== undefined) continue;
      missing.push(`${bank} "${record.id}" ${keyOf(pointer)}`);
    }
  }
  return missing;
}

/** Answers that name no option they are offered beside — an unanswerable card. */
function strandedAnswers({ bank, master, folder }) {
  const translated = new Map(folder.map((entry) => [entry.id, entry]));
  const stranded = [];
  for (const record of master) {
    const entry = translated.get(record.id);
    if (entry === undefined) continue;
    for (const { path, pointer } of stringsIn(bank, record)) {
      if (classify(path) !== "mirror") continue;
      const answer = at(entry, pointer);
      if (answer === undefined) continue;
      const options = optionsPointersFor({
        bank,
        record,
        pointer,
        optionsPath: mirrorOf(path),
      }).map((option) => at(entry, option) ?? at(record, option));
      if (!options.includes(answer)) {
        stranded.push(`${bank} "${record.id}" ${keyOf(pointer)} = "${answer}"`);
      }
    }
  }
  return stranded;
}

module.exports = {
  keyOf,
  at,
  put,
  planBank,
  aliasWork,
  applyBank,
  checkBank,
  strandedAnswers,
  TRANSLATED_FROM,
  NATIVE_REVIEWED,
  pathOf,
};
