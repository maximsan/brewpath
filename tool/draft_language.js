#!/usr/bin/env node
"use strict";

/**
 * Drafts a language folder from the English master, and proves it complete.
 *
 * ADR-0026 gives the drafting step three jobs — draft a folder, mark it
 * complete, and queue what has gone stale — and ADR-0008 puts translation
 * after extraction, so this reads the generated banks and never `prototype/`.
 * The words themselves are agent-drafted: `plan` writes the queue, an agent
 * fills each `text`, and `apply` writes the folder with its marks.
 *
 * Usage:
 *   node tool/draft_language.js plan  <code> [queue.json]
 *   node tool/draft_language.js apply <code> [queue.json]
 *   node tool/draft_language.js check <code>
 */

const fs = require("node:fs");
const path = require("node:path");

const {
  planBank,
  aliasWork,
  applyBank,
  checkBank,
  strandedAnswers,
} = require("./draft_language/folder");

const REPO_ROOT = path.resolve(__dirname, "..");
const GENERATED = path.join(REPO_ROOT, "assets", "content", "generated");
const FOLDERS = path.join(REPO_ROOT, "assets", "content", "l10n");
const ARB_DIR = path.join(REPO_ROOT, "lib", "l10n");

const DO_NOT_EDIT =
  "Drafted by tool/draft_language.js from the English master. Edit the " +
  "queue and rerun, or fix a word here and clear its translatedFrom mark.";

function fail(lines) {
  for (const line of lines) console.error(`✗ ${line}`);
  process.exit(1);
}

/** Every bank the extractor writes, by name. */
function bankNames() {
  return fs
    .readdirSync(GENERATED)
    .filter((file) => file.endsWith(".json"))
    .map((file) => file.slice(0, -5))
    .sort();
}

function readJson(file, fallback) {
  if (!fs.existsSync(file)) return fallback;
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function masterItems(bank) {
  return readJson(path.join(GENERATED, `${bank}.json`), { items: [] }).items;
}

function folderItems(code, bank) {
  return readJson(path.join(FOLDERS, code, `${bank}.json`), { items: [] }).items;
}

function queuePath(code, given) {
  return given || path.join(REPO_ROOT, "build", "l10n", `${code}.queue.json`);
}

/** The English interface strings, and what the language has for them. */
function arbStrings(code) {
  const english = readJson(path.join(ARB_DIR, "app_en.arb"), {});
  const theirs = readJson(path.join(ARB_DIR, `app_${code}.arb`), {});
  const keys = Object.keys(english).filter((key) => !key.startsWith("@"));
  return { english, theirs, keys };
}

function plan(code, given) {
  const work = [];
  for (const bank of bankNames()) {
    const master = masterItems(bank);
    const folder = folderItems(code, bank);
    work.push(...planBank({ bank, master, folder }));
    work.push(...aliasWork({ bank, master, folder }));
  }
  const { english, theirs, keys } = arbStrings(code);
  for (const key of keys) {
    if (theirs[key] !== undefined) continue;
    work.push({
      bank: "app.arb",
      id: key,
      key,
      english: english[key],
      state: "absent",
      held: null,
    });
  }

  const file = queuePath(code, given);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(
    file,
    `${JSON.stringify(
      {
        language: code,
        drafted: DO_NOT_EDIT,
        items: work.map((item) => ({ ...item, text: item.searchKeys ? [] : "" })),
      },
      null,
      2,
    )}\n`,
  );
  const stale = work.filter((item) => item.state === "stale").length;
  console.log(
    `${work.length} to draft for ${code} (${stale} stale) → ` +
      `${path.relative(REPO_ROOT, file)}`,
  );
}

function apply(code, given) {
  const file = queuePath(code, given);
  if (!fs.existsSync(file)) {
    fail([`no queue at ${path.relative(REPO_ROOT, file)} — run plan first`]);
  }
  const queue = readJson(file, { items: [] });
  const byBank = new Map();
  for (const item of queue.items) {
    const text = item.text;
    const written =
      Array.isArray(text) ? text.length > 0 : String(text || "").length > 0;
    if (!written) continue;
    if (!byBank.has(item.bank)) byBank.set(item.bank, new Map());
    byBank.get(item.bank).set(`${item.id}|${item.key}`, text);
  }

  fs.mkdirSync(path.join(FOLDERS, code), { recursive: true });
  let written = 0;
  for (const bank of bankNames()) {
    const master = masterItems(bank);
    const items = applyBank({
      bank,
      master,
      folder: folderItems(code, bank),
      translations: byBank.get(bank) || new Map(),
    });
    const out = path.join(FOLDERS, code, `${bank}.json`);
    if (!items.length) {
      if (fs.existsSync(out)) fs.unlinkSync(out);
      continue;
    }
    fs.writeFileSync(
      out,
      `${JSON.stringify(
        {
          drafted: DO_NOT_EDIT,
          bank,
          language: code,
          schemaVersion: readJson(path.join(GENERATED, `${bank}.json`), {})
            .schemaVersion,
          items,
        },
        null,
        2,
      )}\n`,
    );
    written += 1;
  }
  writeArb(code, byBank.get("app.arb"));
  console.log(`${written} banks written to assets/content/l10n/${code}`);
  warnAboutPubspec(code);
}

/** The language's own interface strings, English keys in English order. */
function writeArb(code, supplied) {
  const { english, theirs, keys } = arbStrings(code);
  const out = { "@@locale": code };
  for (const key of keys) {
    const given = supplied && supplied.get(`${key}|${key}`);
    const value = given || theirs[key];
    if (value !== undefined) out[key] = value;
  }
  if (Object.keys(out).length === 1) return;
  fs.writeFileSync(
    path.join(ARB_DIR, `app_${code}.arb`),
    `${JSON.stringify(out, null, 2)}\n`,
  );
}

/** A folder Flutter does not bundle reads as missing, not as untranslated. */
function warnAboutPubspec(code) {
  const pubspec = fs.readFileSync(path.join(REPO_ROOT, "pubspec.yaml"), "utf8");
  if (pubspec.includes(`assets/content/l10n/${code}/`)) return;
  console.log(
    `  add "- assets/content/l10n/${code}/" under assets: in pubspec.yaml — ` +
      "a directory entry does not bundle its subdirectories",
  );
}

function check(code) {
  const problems = [];
  for (const bank of bankNames()) {
    const master = masterItems(bank);
    const folder = folderItems(code, bank);
    problems.push(...checkBank({ bank, master, folder }));
    problems.push(...strandedAnswers({ bank, master, folder }));
  }
  const { theirs, keys } = arbStrings(code);
  for (const key of keys) {
    if (theirs[key] === undefined) problems.push(`app_${code}.arb "${key}"`);
  }
  if (problems.length) {
    console.error(`✗ ${code} is not complete — ${problems.length} to go:`);
    for (const problem of problems.slice(0, 20)) console.error(`  ${problem}`);
    if (problems.length > 20) {
      console.error(`  … and ${problems.length - 20} more`);
    }
    process.exit(1);
  }
  console.log(`✓ ${code} is complete`);
}

function main(argv) {
  const [verb, code, file] = argv.slice(2);
  if (!verb || !code) {
    fail(["usage: node tool/draft_language.js plan|apply|check <code> [queue]"]);
  }
  if (code === "en") fail(["en is the master — it is not a folder"]);
  if (verb === "plan") return plan(code, file);
  if (verb === "apply") return apply(code, file);
  if (verb === "check") return check(code);
  return fail([`unknown command "${verb}"`]);
}

if (require.main === module) main(process.argv);

module.exports = { bankNames, main };
