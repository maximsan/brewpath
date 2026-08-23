"use strict";

const vm = require("node:vm");

/**
 * Reads one top-level declaration out of a prototype source file.
 *
 * The prototype's data files are not modules and several of them carry React
 * markup alongside their data, so a whole file cannot be evaluated. Each bank is
 * therefore read by slicing its own declaration out and evaluating only that.
 *
 * Finding where a declaration ends is the part worth explaining. Counting
 * brackets is the obvious approach and it is wrong: the prototype contains the
 * line comment `// Only 'match' cards.`, and an apostrophe inside a comment
 * desynchronises any scanner that tracks quotes without also tracking comments —
 * the exact bug a hand-rolled attempt hit. Rather than re-implement JavaScript's
 * lexer, this asks the real one. A slice that ends anywhere but the
 * declaration's true end has unbalanced delimiters and fails to compile, so the
 * first candidate end that V8 accepts is the declaration's end.
 */

/**
 * Candidate end positions: a `]` or `}` closing at the start of a line and
 * followed by a semicolon. Every bank in the prototype is formatted this way. A
 * candidate that is not the real end fails to compile, so an over-generous list
 * costs nothing but a few parse attempts.
 */
const CANDIDATE_END = /^[\]}];/gm;

/**
 * The two forms a bank is declared in, tried in order.
 *
 * `const NAME =` is how most of the prototype declares a bank, and it is
 * matched alone rather than loosely: the same files carry `window.NAME = NAME;`
 * re-export lines, and anchoring on one of those makes a *renamed* declaration
 * fail with a report about formatting when the truth is that it was renamed.
 *
 * `window.NAME = [` is the grove's form — `customize.jsx` assigns its two banks
 * straight onto `window` with no local binding, so requiring `const` would
 * report them as absent. Anchoring on the opening bracket is what keeps the
 * re-export exclusion intact: a re-export assigns a bare identifier, so it can
 * never match, and only a real literal definition can.
 */
const DECLARATION_FORMS = [
  { assignsOntoWindow: false, of: (name) => new RegExp(`^const\\s+${name}\\s*=`, "m") },
  {
    assignsOntoWindow: true,
    of: (name) => new RegExp(`^window\\.${name}\\s*=\\s*[[{]`, "m"),
  },
];

/**
 * Returns the match and which form produced it. The form is carried rather
 * than re-derived from the sliced text later: inferring it back from a
 * `window.` prefix happens to work only because these patterns are anchored,
 * and that is a coincidence to rest a read-back on.
 */
const declarationStart = (source, name) => {
  for (const form of DECLARATION_FORMS) {
    const match = form.of(name).exec(source);
    if (match) return { match, assignsOntoWindow: form.assignsOntoWindow };
  }
  return null;
};

/**
 * Returns the source text of `name`'s declaration, from the keyword through the
 * closing semicolon, and which form declared it.
 *
 * @throws if the declaration is absent, or if no candidate end compiles — both
 *   mean the prototype moved, and reading on would be guessing.
 */
function sliceDeclaration(source, name, filename, prepare = (text) => text) {
  const opening = declarationStart(source, name);
  if (!opening) {
    throw new Error(`${filename}: no top-level declaration of \`${name}\``);
  }
  const { assignsOntoWindow } = opening;
  const start = opening.match.index;

  for (const end of source.matchAll(CANDIDATE_END)) {
    const stop = end.index + end[0].length;
    if (stop <= start) continue;
    const text = prepare(source.slice(start, stop));
    if (compiles(text, filename, name)) return { text, assignsOntoWindow };
  }
  throw new Error(
    `${filename}: found \`${name}\` but no slice of it parses — the prototype's ` +
      "formatting changed, so the declaration boundary can no longer be found.",
  );
}

function compiles(text, filename, name) {
  try {
    new vm.Script(text, { filename: `${filename} (${name})` });
    return true;
  } catch {
    return false;
  }
}

/**
 * Slices `name` out of `source` and evaluates it in a bare context.
 *
 * The context is empty by default and on purpose: these declarations are
 * self-contained literals, and anything reaching outside them is a dependency
 * this mechanism cannot honour — it should fail loudly here rather than yield
 * a silently empty value. A caller that must honour such a dependency
 * assembles the globals itself and passes them as `seed` — the deliberate,
 * named exception (`MINI_GAME_CONTENT`'s `window.BAGPICK_ROUNDS` is the one
 * case; see the header of `extract_content.js`).
 */
function evaluateDeclaration(source, name, filename, seed = {}, prepare) {
  const { text, assignsOntoWindow } = sliceDeclaration(
    source,
    name,
    filename,
    prepare,
  );

  // The `window.NAME = [...]` form leaves no local binding to read back, so the
  // object has to exist before the slice runs and is where the value comes
  // from afterwards. A `const` bank still meets the bare context, so it keeps
  // failing loudly on any global it reaches for.
  //
  // The residual, stated rather than left to be discovered: inside the window
  // form that object exists, so a bank of that form reaching for some *other*
  // `window` property reads `undefined` instead of throwing. `guardShape`
  // catches only a wholly empty result, not a nested one. Both grove banks are
  // self-contained literals today; a future one that is not would need the
  // same explicit seeding `MINI_GAME_CONTENT` gets.
  //
  // `seed` is spread last so a caller-supplied `window` wins over the empty
  // one — the order `MINI_GAME_CONTENT`'s cross-file getter depends on.
  const context = vm.createContext(
    assignsOntoWindow ? { window: {}, ...seed } : { ...seed },
  );
  const readBack = assignsOntoWindow ? `window.${name}` : name;

  vm.runInContext(`${text}\n;globalThis.__extracted = ${readBack};`, context, {
    filename: `${filename} (${name})`,
  });
  return guardShape(context.__extracted, name, filename);
}

/**
 * A truncated slice cannot compile, so it cannot reach here — but that argument
 * rests on the prototype's formatting, and the cost of being wrong is a bank
 * that is quietly short rather than a run that fails. This makes it fail.
 */
function guardShape(value, name, filename) {
  const size = Array.isArray(value) ? value.length : Object.keys(value ?? {}).length;
  if (size === 0) {
    throw new Error(`${filename}: \`${name}\` evaluated to nothing`);
  }
  return value;
}

/**
 * Cuts every entry's `member` out of a declaration before it is evaluated.
 *
 * The one registry this exists for is `VISUAL_GUIDE_CONTENT`, whose eight
 * entries each end with a `body` member holding React markup. V8 cannot parse
 * that, so no candidate end compiles and the declaration reads as unfindable —
 * which is why the register long recorded it as "not a bank". Cutting the
 * member away leaves the words, which is all the app wants from it.
 *
 * **What compilation does and does not cover, stated rather than left to be
 * discovered.** A cut that leaves unbalanced delimiters does not parse, so the
 * boundary itself is validated the same way the slice's own end is. It does
 * **not** follow that a reordering fails loudly: moving a field *below* the
 * cut member makes the regex swallow that field too, and what remains still
 * compiles. Nothing here notices.
 *
 * Field loss is therefore caught downstream instead, by the validator that
 * requires each guide's copy **by name** — which covers exactly the fields it
 * names, and would not catch a new one added after the cut member. That is the
 * residual, and it is why the cut is deliberately anchored on the member being
 * an entry's **last**: the prototype's formatting makes that true today, and a
 * change to it is a change this comment is asking to be read alongside.
 *
 * The pattern also depends on the prototype's indentation — entries at two
 * spaces, members at four — which is the shape every registry in these files
 * is written in.
 */
const dropTrailingMember = (member) => (text) =>
  text.replaceAll(
    new RegExp(`\\n    ${member}: [\\s\\S]*?\\n  \\},`, "g"),
    "\n  },",
  );

module.exports = { sliceDeclaration, evaluateDeclaration, dropTrailingMember };
