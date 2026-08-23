#!/usr/bin/env node
"use strict";

/**
 * Bridges the React prototype's authored content into the app's bundled JSON.
 *
 *   node tool/extract_content.js
 *   node tool/extract_content.js --source <prototype-dir> --out <output-dir>
 *
 * Validating and refusing to write is the point of this tool. It reads every
 * bank, checks the whole cross-reference graph, and only then writes. On any
 * violation it names the offending card and the broken reference, writes
 * nothing, and exits non-zero — so a run can never leave a stale mixture of old
 * and new files behind.
 *
 * `prototype/` is the design source and is read-only. This script opens it for
 * reading and writes only under `--out`.
 *
 * ## How a bank is read
 *
 * Each declaration is sliced out and evaluated on its own rather than the file
 * being evaluated whole, because several of these files carry React markup
 * elsewhere in them. See `extract_content/slice.js` for why the slicing goes
 * through a real parser.
 *
 * ## Field vocabulary
 *
 * The prototype's field names are emitted verbatim; Dart takes idiomatic names
 * through serialization annotations. Nothing is renamed here. The cost is that a
 * prototype-side rename surfaces as a runtime null rather than a compile error,
 * which is why the Dart side both deserializes every card this script emits and
 * asserts that the committed output still matches a fresh run.
 *
 * ## The register: what is not here, what is joined, and where a rule bends
 *
 * - **`MINI_GAME_CONTENT` is the one seeded evaluation.** One of its seven
 *   entries is a getter reading `window.BAGPICK_ROUNDS`, which
 *   `bean-anatomy.jsx` defines — so that declaration is evaluated first and
 *   handed in as the `window`. Evaluated bare, the getter yields an empty
 *   game with nothing to signal it; the same silence is why a format with no
 *   rounds is a validation failure, never a pass.
 * - **`quiz` is graded here but is not a `ContentCard` kind.** True/false
 *   rounds exist only in mini-games, so their boolean-answer check lives with
 *   the mini-game validation — the graded-kinds set the lessons bank
 *   publishes, the one the Dart union asserts against, stays unchanged.
 * - **`MODULE_REWARDS` is read as a sixth declaration** and joined onto each
 *   module as `reward`, mirroring how a lesson carries its own. Without it the
 *   five module Field Guide collectibles have no words at all, since a
 *   collectible stores identity only.
 * - **`DICT_CATEGORIES` is both validated and emitted.** It validates every
 *   term's `cat` pointer, and ships as its own bank: the dictionary home needs
 *   each category's label, glyph and one-line description, and retyping those
 *   into Dart is how they drift from the design source.
 * - **The grove's two banks are assigned straight onto `window`.**
 *   `customize.jsx` declares `TREE_VARIETIES` and `GROVE_LIGHT` with no local
 *   binding, so the slicer accepts that form too and reads the value back off
 *   the object. Their counts — three species, four lights — are checked
 *   exactly, because both are closed product rulings rather than lists that
 *   grow. Each variety's `drop` is emitted but read by nothing: all three
 *   species ship, and a rollout note must not be able to re-defer that.
 * - **The visual guides are one bank joined from two files.** Identity, unlock
 *   and the meta table come from `VISUAL_GUIDE_CARDS` (`data.jsx`); the words
 *   from `VISUAL_GUIDE_CONTENT` (`practical.jsx`). The second is the only
 *   registry whose entries carry React markup — each ends with a `body` member
 *   V8 cannot parse — so it is read with that member cut away first, and the
 *   cut is validated by compilation exactly as the slice's own end is. Markup
 *   moved above the words would fail loudly rather than drop fields silently.
 * - **Module reward `meta` is not carried.** `data.jsx` computes it after the
 *   declaration, from lesson counts, so slicing does not see it. Deriving it
 *   app-side is also why the prototype computes it: a stored copy goes stale
 *   when a lesson is added.
 * - **"Exactly one correct answer" bends for `multi`.** A select-all card's
 *   answer is the whole set, so it is checked for being neither empty nor
 *   everything instead. See `extract_content/validate/answers.js`.
 * - **Module and lesson `status` / `locked` are emitted verbatim, and they are
 *   the prototype's demo progress** (`m1l1` complete, `m1l2` current, the rest
 *   locked). Real progress lives in the database. Nothing app-side should read
 *   these fields; they survive here only because this script renames and drops
 *   nothing.
 *
 * ## Bumping the schema version
 *
 * Every bank carries `schemaVersion` (see `SCHEMA_VERSION` below). The app
 * refuses a bank not stamped with the version it was built to read, so the
 * number is the contract between this script's output and the Dart loader.
 *
 * **Breaking — bump the version, and `contentSchemaVersion` in
 * `lib/shared/repositories/bank_envelope.dart` with it:**
 *
 * - Renaming a field, or removing one.
 * - Changing how an existing field is interpreted — same name, same type, new
 *   meaning.
 * - Changing what an existing card kind means, or what shape its records take.
 * - Making an optional field required.
 *
 * **Additive — leave the version alone:**
 *
 * - Adding an optional field.
 * - Adding a new bank, or new entries to an existing one.
 * - Changing authored copy, ids aside.
 * - Anything inside this script that does not change the output.
 *
 * The rule that catches people out is the second breaking one: **a change with
 * an unchanged shape is still breaking.** Field names are emitted verbatim and
 * Dart takes idiomatic names through serialization annotations, so a rename or
 * a quiet re-interpretation does not fail to compile — it surfaces as a null
 * inside a lesson, at the card that needed it, in front of a learner. That
 * silence is the reason the version exists; a bump turns it into a refusal at
 * startup.
 *
 * When in doubt, ask whether a build shipped *before* the change could read the
 * new output and be right about it. If not, it is breaking.
 */

const fs = require("node:fs");
const path = require("node:path");

const {
  evaluateDeclaration,
  dropTrailingMember,
} = require("./extract_content/slice");
const { validate, GRADED_KINDS } = require("./extract_content/validate");

const REPO_ROOT = path.resolve(__dirname, "..");
const DEFAULT_SOURCE = path.join(REPO_ROOT, "prototype");
const DEFAULT_OUT = path.join(REPO_ROOT, "assets", "content", "generated");

const DO_NOT_EDIT =
  "Generated by tool/extract_content.js from the prototype source. " +
  "Do not edit by hand — rerun the script instead.";

/**
 * The schema version stamped into every bank. See "Bumping the schema version"
 * in the header above before changing it.
 *
 * This number exists twice — here and in `contentSchemaVersion` in
 * `lib/shared/repositories/bank_envelope.dart`, which refuses any bank not
 * stamped with it. They cannot share a constant across languages, so a test
 * reads the committed banks and asserts they carry the Dart side's value:
 * bumping one alone fails the suite rather than a learner's app.
 */
const SCHEMA_VERSION = 1;

function main(argv) {
  const { source, out } = parseArgs(argv);
  const read = (file) => {
    const full = path.join(source, file);
    if (!fs.existsSync(full)) {
      fail([`${full} does not exist — is --source pointing at the prototype?`]);
    }
    return fs.readFileSync(full, "utf8");
  };

  const data = read("data.jsx");
  const dictionary = read("dictionary-data.jsx");
  const challenges = read("brew-challenge.jsx");
  const screens = read("screens.jsx");
  const lesson = read("lesson.jsx");
  const anatomy = read("bean-anatomy.jsx");
  const customize = read("customize.jsx");
  const practical = read("practical.jsx");

  // A declaration that has been renamed or reformatted past recognition is as
  // much a refusal as a broken reference, and reports the same way: reading on
  // would be guessing, and a stack trace is a worse answer.
  let banks;
  try {
    const bagpickRounds = evaluateDeclaration(
      anatomy,
      "BAGPICK_ROUNDS",
      "bean-anatomy.jsx",
    );
    banks = {
      modules: evaluateDeclaration(data, "MODULES", "data.jsx"),
      lessons: evaluateDeclaration(data, "LESSONS", "data.jsx"),
      collectibles: evaluateDeclaration(data, "COLLECTIBLES", "data.jsx"),
      rewards: evaluateDeclaration(data, "MODULE_REWARDS", "data.jsx"),
      terms: evaluateDeclaration(dictionary, "DICT_TERMS", "dictionary-data.jsx"),
      categories: evaluateDeclaration(
        dictionary,
        "DICT_CATEGORIES",
        "dictionary-data.jsx",
      ),
      challenges: evaluateDeclaration(
        challenges,
        "BREW_CHALLENGES",
        "brew-challenge.jsx",
      ),
      miniGames: evaluateDeclaration(screens, "MINI_GAMES", "screens.jsx"),
      cardKindHelp: evaluateDeclaration(lesson, "CARD_KIND_HELP", "lesson.jsx"),
      // The seed is the assembled `window`; the spread reads every entry, so
      // the bagpick getter resolves once, here, and the bank holds real rounds
      // rather than a live property.
      miniGameContent: {
        ...evaluateDeclaration(lesson, "MINI_GAME_CONTENT", "lesson.jsx", {
          window: { BAGPICK_ROUNDS: bagpickRounds },
        }),
      },
      groveVarieties: evaluateDeclaration(
        customize,
        "TREE_VARIETIES",
        "customize.jsx",
      ),
      groveLights: evaluateDeclaration(customize, "GROVE_LIGHT", "customize.jsx"),
      visualGuideCards: evaluateDeclaration(
        data,
        "VISUAL_GUIDE_CARDS",
        "data.jsx",
      ),
      // The one registry whose entries carry React markup. Its `body` member
      // is cut away before evaluation — see `dropTrailingMember`.
      visualGuideContent: evaluateDeclaration(
        practical,
        "VISUAL_GUIDE_CONTENT",
        "practical.jsx",
        {},
        dropTrailingMember("body"),
      ),
    };
  } catch (error) {
    fail([error.message]);
  }

  const errors = validate(banks);
  if (errors.length > 0) fail(errors);

  writeBanks(out, [
    bank("modules", "data.jsx", withRewards(banks)),
    // The graded kinds ride along so the Dart union's `Gradable` markers can be
    // asserted against them. Two languages' idea of "graded" is the pair that
    // drifts silently, and mastery divides by it.
    bank("lessons", "data.jsx", keyedToList(banks.lessons), {
      gradedKinds: GRADED_KINDS,
    }),
    bank("collectibles", "data.jsx", banks.collectibles),
    bank("dictionary_terms", "dictionary-data.jsx", banks.terms),
    bank("dictionary_categories", "dictionary-data.jsx", banks.categories),
    bank("brew_challenges", "brew-challenge.jsx", banks.challenges),
    bank("mini_games", "screens.jsx", banks.miniGames),
    bank("card_kind_help", "lesson.jsx", helpToList(banks.cardKindHelp)),
    // Two sources, honestly: the bagpick rounds in this bank are authored in
    // `bean-anatomy.jsx`, and the envelope's provenance should say so.
    bank(
      "mini_game_content",
      "lesson.jsx + bean-anatomy.jsx",
      contentToList(banks.miniGameContent),
    ),
    // Two banks rather than one with a second list bolted on: the axes are
    // orthogonal and co-equal — any light applies over any plant — so neither
    // is the other's auxiliary data, and each validates on its own terms.
    bank("grove_varieties", "customize.jsx", banks.groveVarieties),
    bank("grove_lights", "customize.jsx", banks.groveLights),
    // Two sources, honestly: identity, unlock and the meta table are authored
    // in `data.jsx`, the words in `practical.jsx`, and a guide is only whole
    // once they are joined.
    bank(
"visual_guides", "data.jsx + practical.jsx", joinVisualGuides(banks)),
  ]);
}

/**
 * `LESSONS` is an object keyed by lesson id and the lesson objects carry no id
 * of their own. Flattening to a list restores the key as `id` — the map already
 * said it, so nothing is invented.
 */
function keyedToList(keyed) {
  return Object.entries(keyed).map(([id, value]) => ({ id, ...value }));
}

/**
 * `CARD_KIND_HELP` is keyed by card kind and its entries carry no kind of
 * their own. Flattening restores the key as `kind` — the field name every card
 * already uses for the same value.
 */
function helpToList(help) {
  return Object.entries(help).map(([kind, entry]) => ({ kind, ...entry }));
}

/**
 * `MINI_GAME_CONTENT` is keyed by format id, each value that game's rounds.
 * Flattening restores the key as `id` beside the rounds it owns.
 */
function contentToList(content) {
  return Object.entries(content).map(([id, rounds]) => ({ id, rounds }));
}

/** Joins each module's Field Guide words on from `MODULE_REWARDS`. */
function withRewards(banks) {
  return banks.modules.map((module) => ({
    ...module,
    reward: banks.rewards[module.id],
  }));
}

/**
 * Wraps one bank's items in the envelope the app reads.
 *
 * Every bank is built here, which is what makes the schema version a property
 * of the output rather than of anyone's memory: a bank added later is stamped
 * because it came through this function.
 */
function bank(name, sourceFile, items, extra = {}) {
  return {
    name,
    payload: {
      generated: DO_NOT_EDIT,
      source: sourceFile,
      bank: name,
      schemaVersion: SCHEMA_VERSION,
      ...extra,
      items,
    },
  };
}

/**
 * One record per visual guide, in registry order.
 *
 * `earned` and `kind` are deliberately not carried: the first is prototype
 * demo state — what a learner has unlocked is progress, and progress lives in
 * the database — and the second is a renderer hint the app does not need,
 * since a guide is only ever drawn as a guide.
 */
function joinVisualGuides(banks) {
  return banks.visualGuideCards.map((card) => {
    const words = banks.visualGuideContent[card.visualGuide] ?? {};
    return {
      id: card.id,
      visualGuide: card.visualGuide,
      unlock: card.unlock,
      label: words.label,
      title: words.title,
      summary: words.summary,
      fact: words.fact,
      meta: card.meta,
    };
  });
}

/** Only reached once validation has passed, so a run writes every bank or none. */
function writeBanks(out, banks) {
  fs.mkdirSync(out, { recursive: true });
  for (const { name, payload } of banks) {
    const file = path.join(out, `${name}.json`);
    fs.writeFileSync(file, `${JSON.stringify(payload, null, 2)}\n`);
    console.log(`${name}.json — ${payload.items.length} entries`);
  }
  console.log(`Wrote ${banks.length} banks to ${path.relative(REPO_ROOT, out) || out}`);
}

function parseArgs(argv) {
  const options = { source: DEFAULT_SOURCE, out: DEFAULT_OUT };
  for (let index = 0; index < argv.length; index += 2) {
    const flag = argv[index];
    const value = argv[index + 1];
    if (flag !== "--source" && flag !== "--out") {
      fail([`unknown argument '${flag}' — expected --source or --out`]);
    }
    if (!value) fail([`${flag} needs a directory`]);
    options[flag === "--source" ? "source" : "out"] = path.resolve(value);
  }
  return options;
}

function fail(errors) {
  console.error(`Refusing to write. ${errors.length} problem(s):\n`);
  for (const error of errors) console.error(`  ${error}`);
  console.error("\nNothing was written.");
  process.exit(1);
}

main(process.argv.slice(2));
