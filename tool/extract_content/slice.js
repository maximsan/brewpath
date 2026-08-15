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
 * Deliberately matches `const` alone. Every bank is declared that way, and the
 * files also carry `window.NAME = NAME;` re-export lines that a looser pattern
 * matches instead — anchoring on the re-export makes a renamed declaration fail
 * with a report about formatting when the truth is that it was renamed.
 */
const declarationStart = (name) => new RegExp(`^const\\s+${name}\\s*=`, "m");

/**
 * Returns the source text of `name`'s declaration, from the keyword through the
 * closing semicolon.
 *
 * @throws if the declaration is absent, or if no candidate end compiles — both
 *   mean the prototype moved, and reading on would be guessing.
 */
function sliceDeclaration(source, name, filename) {
  const opening = declarationStart(name).exec(source);
  if (!opening) {
    throw new Error(`${filename}: no top-level declaration of \`${name}\``);
  }
  const start = opening.index;

  for (const end of source.matchAll(CANDIDATE_END)) {
    const stop = end.index + end[0].length;
    if (stop <= start) continue;
    const text = source.slice(start, stop);
    if (compiles(text, filename, name)) return text;
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
 * The context is empty on purpose: these declarations are self-contained
 * literals, and anything reaching outside them is a dependency this mechanism
 * cannot honour — it should fail loudly here rather than yield a silently empty
 * value. (`MINI_GAME_CONTENT` is exactly that case, which is why mini-games are
 * not one of the banks; see the header of `extract_content.js`.)
 */
function evaluateDeclaration(source, name, filename) {
  const text = sliceDeclaration(source, name, filename);
  const context = vm.createContext({});
  vm.runInContext(`${text}\n;globalThis.__extracted = ${name};`, context, {
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

module.exports = { sliceDeclaration, evaluateDeclaration };
