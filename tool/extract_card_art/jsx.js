"use strict";

/**
 * A JSX reader small enough to own, for the one dialect `screens.jsx` writes.
 *
 * The card arts are React components, not markup: five of them compose a
 * prop-taking frame, and eight compute their geometry with `Array.from` and
 * `Math`. So they cannot be sliced out as text — they have to be *run*. The
 * prototype runs them with Babel and React from a CDN, which an offline
 * extractor cannot reach, and this repo's tooling carries no npm dependencies
 * at all. So the dialect is read here instead.
 *
 * It is deliberately narrow, and refuses what it does not understand rather
 * than guessing: the block uses no fragments, no spread attributes, no
 * conditional children and no `&&`. If one appears, [transform] throws and the
 * run writes nothing — the same bargain the icon extractor makes.
 */

/** Characters that can precede a `<` that opens JSX rather than compares. */
const EXPRESSION_HEAD = new Set(["(", ",", "=", "{", "[", ":", ";", ">", "&", "|", "?", "\n"]);

/**
 * Keywords a JSX element may follow. `return <line .../>` is the shape the
 * computed arts use, and its preceding character is a letter, so the
 * punctuation test above cannot see it.
 */
const EXPRESSION_KEYWORDS = new Set([
  "return",
  "case",
  "yield",
  "await",
  "else",
  "do",
  "typeof",
  "in",
  "of",
]);

/** Attribute names React spells in camelCase that SVG spells with dashes. */
const ATTRIBUTE_CASE = /[A-Z]/g;

/** React bookkeeping that means nothing to a renderer. */
const DROPPED_ATTRIBUTES = new Set(["key", "ref", "className", "style"]);

const isNameChar = (char) => /[A-Za-z0-9_$.-]/.test(char);

/**
 * Rewrites every JSX element in [source] into an `h(type, props, ...children)`
 * call, leaving the surrounding JavaScript untouched.
 */
function transform(source) {
  let out = "";
  let index = 0;

  /** Whether what has been emitted so far leaves us expecting an expression. */
  const atExpression = () => {
    let scan = out.length - 1;
    while (scan >= 0 && /\s/.test(out[scan])) scan -= 1;
    if (scan < 0) return true;
    if (EXPRESSION_HEAD.has(out[scan])) return true;
    if (!/[A-Za-z0-9_$]/.test(out[scan])) return false;

    let word = "";
    while (scan >= 0 && /[A-Za-z0-9_$]/.test(out[scan])) {
      word = out[scan] + word;
      scan -= 1;
    }
    return EXPRESSION_KEYWORDS.has(word);
  };

  while (index < source.length) {
    const char = source[index];

    // Strings and comments are copied whole: a `<` inside one is not JSX.
    if (char === '"' || char === "'" || char === "`") {
      const end = skipString(source, index);
      out += source.slice(index, end);
      index = end;
      continue;
    }
    if (char === "/" && source[index + 1] === "/") {
      const end = source.indexOf("\n", index);
      const stop = end === -1 ? source.length : end;
      out += source.slice(index, stop);
      index = stop;
      continue;
    }
    if (char === "/" && source[index + 1] === "*") {
      const end = source.indexOf("*/", index + 2);
      if (end === -1) throw new Error("unterminated block comment");
      out += source.slice(index, end + 2);
      index = end + 2;
      continue;
    }
    // A regex literal would be scanned as division, and a `/` or a quote
    // inside it would desynchronise everything after — silently, which is the
    // one thing this reader must never do. The block has none; if one
    // arrives, it is a refusal rather than a corrupt drawing.
    if (char === "/" && atExpression()) {
      throw new Error(
        "a regex literal is not read here — the arts use none, and guessing " +
          "at one would corrupt every element after it",
      );
    }

    if (char === "<" && /[A-Za-z]/.test(source[index + 1] ?? "") && atExpression()) {
      const { code, end } = readElement(source, index);
      out += code;
      index = end;
      continue;
    }

    out += char;
    index += 1;
  }
  return out;
}

/** Index just past the string literal starting at [start]. */
function skipString(source, start) {
  const quote = source[start];
  let index = start + 1;
  while (index < source.length) {
    if (source[index] === "\\") {
      index += 2;
      continue;
    }
    // A template's `${…}` can hold another template, so the interpolation is
    // skipped whole rather than scanned for the closing backtick.
    if (quote === "`" && source[index] === "$" && source[index + 1] === "{") {
      index = readBraced(source, index + 1);
      continue;
    }
    if (source[index] === quote) return index + 1;
    index += 1;
  }
  throw new Error(`unterminated ${quote} string`);
}

/** Index just past the `{…}` balanced expression starting at [start]. */
function readBraced(source, start) {
  let depth = 0;
  let index = start;
  while (index < source.length) {
    const char = source[index];
    if (char === '"' || char === "'" || char === "`") {
      index = skipString(source, index);
      continue;
    }
    if (char === "{") depth += 1;
    if (char === "}") {
      depth -= 1;
      if (depth === 0) return index + 1;
    }
    index += 1;
  }
  throw new Error("unbalanced { } in JSX");
}

/** Reads one JSX element at [start]; returns its `h(...)` call and its end. */
function readElement(source, start) {
  let index = start + 1;
  let tag = "";
  while (isNameChar(source[index])) {
    tag += source[index];
    index += 1;
  }
  if (!tag) throw new Error("JSX element with no tag name");

  const props = [];
  for (;;) {
    while (/\s/.test(source[index])) index += 1;

    if (source[index] === "/" && source[index + 1] === ">") {
      return { code: call(tag, props, []), end: index + 2 };
    }
    if (source[index] === ">") {
      index += 1;
      break;
    }
    if (source[index] === "{") {
      throw new Error(`spread attributes are not supported (<${tag}>)`);
    }

    let name = "";
    while (isNameChar(source[index])) {
      name += source[index];
      index += 1;
    }
    if (!name) throw new Error(`unreadable attribute in <${tag}>`);

    if (source[index] !== "=") {
      props.push([name, "true"]);
      continue;
    }
    index += 1;

    if (source[index] === "{") {
      const end = readBraced(source, index);
      props.push([name, `(${transform(source.slice(index + 1, end - 1))})`]);
      index = end;
    } else {
      const end = skipString(source, index);
      props.push([name, source.slice(index, end)]);
      index = end;
    }
  }

  const children = [];
  for (;;) {
    if (source.startsWith(`</${tag}`, index)) {
      // The boundary matters: without it `</linearGradient>` would close a
      // `<line>`, and the tree would be silently wrong rather than refused.
      const after = source[index + tag.length + 2];
      if (after === ">" || /\s/.test(after ?? "")) {
        const close = source.indexOf(">", index);
        if (close === -1) throw new Error(`unterminated </${tag}>`);
        return { code: call(tag, props, children), end: close + 1 };
      }
    }
    if (index >= source.length) throw new Error(`unterminated <${tag}>`);

    if (source[index] === "{") {
      const end = readBraced(source, index);
      const inner = source.slice(index + 1, end - 1);
      // `{/* a note */}` is a comment, not a child.
      if (!/^\s*\/\*[\s\S]*\*\/\s*$/.test(inner)) {
        children.push(`(${transform(inner)})`);
      }
      index = end;
      continue;
    }
    if (source[index] === "<") {
      const element = readElement(source, index);
      children.push(element.code);
      index = element.end;
      continue;
    }

    let text = "";
    while (index < source.length && source[index] !== "<" && source[index] !== "{") {
      text += source[index];
      index += 1;
    }
    if (text.trim()) children.push(JSON.stringify(text.trim()));
  }
}

/**
 * The name the transformed source calls to build an element.
 *
 * Deliberately not `h`: one art names a local `h` for a height, and a pragma
 * called `h` would be shadowed by it inside that arrow function — which
 * surfaces as `h is not a function` at render time rather than as a parse
 * error, so it is worth being unmistakable.
 */
const PRAGMA = "__el";

const call = (tag, props, children) => {
  const type = /^[a-z]/.test(tag) ? JSON.stringify(tag) : tag;
  const bag = props.length
    ? `{${props.map(([name, value]) => `${JSON.stringify(name)}: ${value}`).join(", ")}}`
    : "null";
  return `${PRAGMA}(${[type, bag, ...children].join(", ")})`;
};

/**
 * The attributes SVG itself spells in camelCase, which must not be dashed.
 *
 * `clipPath` is **not** among them. It is camelCase as an *element*, which
 * this never touches — the attribute is `clip-path`, and emitting the element
 * spelling drops the clip silently: the parser reads `clip-path`, finds
 * nothing, and draws the shape unclipped with no error anywhere.
 */
const SVG_CAMEL_ATTRIBUTES = new Set([
  "viewBox",
  "clipPathUnits",
  "gradientUnits",
  "gradientTransform",
  "patternUnits",
  "preserveAspectRatio",
  "maskUnits",
  "markerWidth",
  "markerHeight",
  "refX",
  "refY",
]);

/** `strokeWidth` → `stroke-width`; SVG's own casing is left alone. */
const attributeName = (name) =>
  SVG_CAMEL_ATTRIBUTES.has(name)
    ? name
    : name.replace(ATTRIBUTE_CASE, (upper) => `-${upper.toLowerCase()}`);

/**
 * The element factory the transformed source calls. A capitalised tag is a
 * component and is invoked; a lowercase one becomes a node.
 */
function h(type, props, ...children) {
  const flat = children.flat(Infinity).filter((child) => child != null && child !== false);
  if (typeof type === "function") return type({ ...(props ?? {}), children: flat });
  return { tag: type, props: props ?? {}, children: flat };
}

/**
 * Decimal places kept on a computed coordinate.
 *
 * Eight of the arts place elements with `Math.cos`/`Math.sin`, and the last
 * bits of those differ between platforms — macOS produced
 * `-2.296100594190538` where Linux produced `-2.2961005941905377`. Emitting
 * full precision therefore bakes the build machine into the assets, and the
 * check that the committed files match a fresh extraction can only pass on
 * whichever machine wrote them.
 *
 * Four places is 0.0001 of a 100-unit viewBox — far below anything that can
 * be seen, and far above where the platforms disagree.
 */
const PRECISION = 4;

/** Rounds long decimals so the same source gives the same bytes anywhere. */
const roundNumbers = (value) =>
  value.replace(/-?\d*\.\d{5,}/g, (number) =>
    String(Number(Number(number).toFixed(PRECISION))),
  );

/** What XML cannot carry raw, in a label or an attribute value. */
const escapeXml = (text) =>
  text
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");

/** Serialises a node tree to SVG markup. */
function render(node) {
  if (node == null || node === false) return "";
  if (typeof node === "string" || typeof node === "number") return String(node);
  if (Array.isArray(node)) return node.map(render).join("");

  const attributes = Object.entries(node.props)
    .filter(([name, value]) => !DROPPED_ATTRIBUTES.has(name) && name !== "children" && value != null && value !== false)
    .map(
      ([name, value]) =>
        ` ${attributeName(name)}="${escapeXml(roundNumbers(String(value)))}"`,
    )
    .join("");

  const inner = (node.children ?? [])
    .map((child) =>
      typeof child === "string" || typeof child === "number"
        ? escapeXml(String(child))
        : render(child),
    )
    .join("");
  return inner ? `<${node.tag}${attributes}>${inner}</${node.tag}>` : `<${node.tag}${attributes}/>`;
}

module.exports = { transform, h, render, attributeName, PRAGMA };
