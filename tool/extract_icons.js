#!/usr/bin/env node
"use strict";

/**
 * Bridges the design system's icon family into the app's bundled SVG assets.
 *
 *   node tool/extract_icons.js
 *   node tool/extract_icons.js --source <prototype-dir> --out <output-dir>
 *
 * The marks are drawn in `prototype/ds-content.js` as real SVG, so this
 * extracts them rather than redrawing them: a mark the app shows is the mark
 * the design drew, down to the stroke width, and a design edit reaches the app
 * by re-running this rather than by someone noticing.
 *
 * `prototype/` is the design source and is read-only. This script opens it for
 * reading and writes only under `--out`.
 *
 * ## Which source, and why it is not only this one
 *
 * `ds-content.js` is loaded by `Design System.html` alone — it is the
 * **catalogue**. ADR-0009 ranks the running prototype above the catalogue
 * wherever both describe a component, and the four v1 nav marks are described
 * twice: the catalogue draws each once, flat, while `flavor-wheel.jsx` (which
 * `index.html` boots) draws them with an active and an inactive state that
 * differ in fill, in opacity, and in the ink their interior lines take.
 *
 * The two agree on every coordinate. They disagree only on paint. So geometry
 * comes from the catalogue, which is data and can be read exactly, and the
 * paint of each state comes from the running components, transcribed into
 * [STATEFUL] — no coordinate is repeated there, so it cannot drift from the
 * drawing, and the element counts it depends on are checked on every run.
 *
 * ## Colour
 *
 * Nothing here bakes in a colour. A mark paints in `currentColor`, in `none`,
 * or in one of the [SENTINELS] — a stand-in for a CSS variable, which means
 * nothing to an SVG renderer, mapped back to a mood token on the Dart side.
 * `assertPaint` refuses any other value, so a mark that would not follow the
 * mood cannot reach the assets.
 *
 * The sentinels are deliberately not colours from either mood: an unmapped one
 * shows up as magenta rather than as a plausible result in one mood.
 *
 * ## What fails a run
 *
 * Writing nothing on any violation is the point. A partial write would leave
 * the app mixing a new mark with a stale one, which is the failure this is
 * built to make impossible:
 *
 * - the catalogue's `svg()` helper changed shape, so its output is no longer
 *   what this reads;
 * - a mark paints in a colour outside the set above;
 * - two sets share a mark's name but draw different geometry, against the
 *   family's own "one concept, one drawing" rule;
 * - a [STATEFUL] entry names a mark, an element, or a count the catalogue no
 *   longer has — meaning the running prototype and the catalogue have diverged
 *   in shape rather than in paint, which is a ruling for the owner to make.
 */

const fs = require("node:fs");
const path = require("node:path");

const { evaluateDeclaration } = require("./extract_content/slice");

const REPO_ROOT = path.resolve(__dirname, "..");
const DEFAULT_SOURCE = path.join(REPO_ROOT, "prototype");
const DEFAULT_OUT = path.join(REPO_ROOT, "assets", "icons");

const CATALOGUE = "ds-content.js";
const RUNNING = "screens.jsx";

/** CSS variable → the literal that stands in for it in a written asset. */
const SENTINELS = {
  "var(--surface)": "#FF00FF",
  "var(--surface-2)": "#FF00EE",
  "var(--accent-ink)": "#FF00DD",
  // The two the game-kind marks brought in. `--bg` is another knockout, like
  // `--surface`. `--accent` is not: it is a *second ink*, and these are the
  // family's first two-tone marks — the design draws them muted with one
  // detail in the accent, and that detail stays accent whatever ink the call
  // site gives the mark. See RUNNING_KINDS.
  "var(--bg)": "#FF00CC",
  "var(--accent)": "#FF00BB",
};

/**
 * The catalogue's own wrapper, as this expects to find it. Its output is what
 * every mark is made of, so a change to it changes all of them at once —
 * loudly, here, rather than quietly in the assets.
 */
const EXPECTED_HELPER =
  "const svg = (vb, inner, sw) => `<svg viewBox=\"${vb}\" fill=\"none\" " +
  'stroke-width="${sw||1.6}" aria-hidden="true">${inner}</svg>`;';

/** What a mark may paint in, before the sentinels are substituted. */
const ALLOWED_PAINT = new Set(["currentColor", "none", ...Object.keys(SENTINELS)]);

/**
 * Game-kind marks the running prototype draws and the catalogue has not got.
 *
 * `ds-content.js` draws four kinds — module, match, quiz, flavour — but the
 * catalogue of playable games has seven, so the practice shelf could head only
 * three of its groups and headed none instead (#436). The other four are drawn
 * in `screens.jsx`'s `ReplayIcon`, which `index.html` boots, and ADR-0009
 * ranks the running prototype above the catalogue — so they are read from
 * there rather than redrawn here.
 *
 * `name` is what the asset is slugged from, so it is the kind's own key: the
 * shelf looks a mark up by the `kind` its catalogue entry carries.
 */
const RUNNING_KINDS = {
  bagpick: {
    name: "Bagpick",
    label: "Blind bag",
    description:
      "An unlabelled bag with a bean inside — read the sample, name the process.",
  },
  tastefix: {
    name: "Tastefix",
    label: "Taste fix",
    description:
      "A cup with a corrective arrow curving back — diagnose and dial in.",
  },
  slider: {
    name: "Slider",
    label: "Calibrate",
    description: "A track with a handle on it — put the value where it belongs.",
  },
  sequence: {
    name: "Sequence",
    label: "Sequence",
    description: "Three stops and their rules — put the steps in order.",
  },
};

/** JSX spells these camelCase; SVG spells them with a hyphen. */
const JSX_ATTRIBUTES = {
  strokeWidth: "stroke-width",
  strokeLinecap: "stroke-linecap",
  strokeLinejoin: "stroke-linejoin",
  strokeDasharray: "stroke-dasharray",
  clipRule: "clip-rule",
  fillRule: "fill-rule",
};

/**
 * The marks the running prototype draws with a state, and the paint each state
 * gives each element — by index, because only paint is transcribed and the
 * geometry stays where it is drawn.
 *
 * From `prototype/flavor-wheel.jsx:336-404`, which `index.html` boots. Where it
 * and the catalogue disagree, ADR-0009 makes this the winner. Each divergence
 * is named so the next reader does not "fix" it back to the catalogue:
 *
 * - **Cup** — the catalogue sets the steam to `opacity 0.7`, a value the
 *   running component never uses: it draws 0.85 inactive and 0.55 active.
 * - **Route** — the catalogue leaves the stops unfilled, so the dashed trail
 *   shows through them; the running component fills them with the surface.
 * - **Cards** and **Leaf** — the catalogue strokes the interior line in the
 *   mark's own ink in both states; the running component knocks it out in
 *   `--accent-ink` when active, because by then the mark is a solid accent
 *   shape and its own ink would not read against it.
 */
const STATEFUL = {
  nav: {
    Cup: {
      elements: 5,
      inactive: { 0: { opacity: "0.85" }, 1: { opacity: "0.85" }, 2: { opacity: "0.85" } },
      active: {
        0: { opacity: "0.55" },
        1: { opacity: "0.55" },
        2: { opacity: "0.55" },
        3: { fill: "currentColor" },
      },
    },
    Route: {
      elements: 4,
      inactive: {
        1: { fill: "var(--surface)" },
        2: { fill: "var(--surface)" },
        3: { fill: "var(--surface)" },
      },
      active: {
        1: { fill: "currentColor" },
        2: { fill: "currentColor" },
        3: { fill: "currentColor" },
      },
    },
    Cards: {
      elements: 3,
      inactive: {},
      active: {
        0: { fill: "var(--surface-2)" },
        1: { fill: "currentColor" },
        2: { stroke: "var(--accent-ink)" },
      },
    },
    Leaf: {
      elements: 4,
      inactive: {},
      active: {
        0: { fill: "currentColor" },
        1: { stroke: "var(--accent-ink)" },
        2: { stroke: "var(--accent-ink)" },
        3: { stroke: "var(--accent-ink)" },
      },
    },
  },
  action: {
    // Not from a component — from the catalogue's own rule for this mark:
    // "Toggles on lessons, terms, cards & games. Filled accent when saved."
    // ADR-0009 leaves the catalogue authoritative where the running prototype
    // does not contradict it, and no component draws a second bookmark.
    //
    // The fill is `currentColor` rather than the accent itself: the accent is
    // what a saved bookmark is *given* by its call site, and baking it in here
    // would be the one mark that could not follow the mood.
    Bookmark: {
      elements: 1,
      inactive: {},
      active: { 0: { fill: "currentColor" } },
    },
  },
};

/** Errors are collected so one run reports every problem, not just the first. */
const fail = (problems) => {
  for (const problem of problems) process.stderr.write(`  ✗ ${problem}\n`);
  process.stderr.write(`\n${problems.length} problem(s) — nothing was written.\n`);
  process.exit(1);
};

/** `Cherry section` → `cherry_section`; the file name and the Dart name. */
const slugify = (name) =>
  name
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");

/** The drawn elements of a mark, in document order, as source text. */
const elementsOf = (markup) => markup.match(/<(?:path|circle|rect|ellipse|line|polyline|polygon)\b[^>]*\/>/g) ?? [];

/** The geometry of a mark, with every paint attribute dropped. */
const geometryOf = (markup) =>
  markup
    .replace(
      /\s(?:stroke|fill|opacity|stroke-width|stroke-linecap|stroke-linejoin|stroke-dasharray)="[^"]*"/g,
      "",
    )
    .replace(/\s+/g, " ")
    .trim();

/** Sets `attribute` on one element's source text, replacing any it carries. */
const withAttribute = (element, attribute, value) =>
  new RegExp(`\\s${attribute}="[^"]*"`).test(element)
    ? element.replace(new RegExp(`\\s${attribute}="[^"]*"`), ` ${attribute}="${value}"`)
    : element.replace(/\/>$/, ` ${attribute}="${value}"/>`);

function readCatalogue(sourceDir, problems) {
  const file = path.join(sourceDir, CATALOGUE);
  if (!fs.existsSync(file)) fail([`${CATALOGUE}: not found under ${sourceDir}`]);
  const source = fs.readFileSync(file, "utf8");

  const helper = /const svg = [\s\S]*?;\n/.exec(source);
  if (!helper || helper[0].replace(/\s+/g, " ").trim() !== EXPECTED_HELPER) {
    problems.push(
      `${CATALOGUE}: the \`svg()\` helper is not the one this reads. Every ` +
        "mark is built by it, so its output cannot be assumed. Compare it " +
        "against EXPECTED_HELPER and update both together.",
    );
    fail(problems);
  }

  // The catalogue's marks call `svg()`, which is declared above them and whose
  // arrow form has no `};` line for the slicer to end on. Supplying it here is
  // safe precisely because the check above pins its source first.
  const svg = (vb, inner, sw) =>
    `<svg viewBox="${vb}" fill="none" stroke-width="${sw || 1.6}" aria-hidden="true">${inner}</svg>`;

  return evaluateDeclaration(source, "ICONS", CATALOGUE, { svg });
}

/**
 * Reads the four game-kind marks out of `ReplayIcon` and rewrites each as the
 * catalogue's `svg()` would have emitted it.
 *
 * A regex rather than a parser because the target is narrow and the failure
 * mode is loud: every kind named in [RUNNING_KINDS] must be found, must draw
 * at least one element, and must carry a 0-origin `viewBox`, or the run writes
 * nothing. A silent miss here is a heading with no glyph, which is exactly the
 * state this is fixing.
 */
function readRunningKinds(sourceDir, problems) {
  const file = path.join(sourceDir, RUNNING);
  if (!fs.existsSync(file)) {
    problems.push(`${RUNNING}: not found under ${sourceDir}`);
    return [];
  }
  const source = fs.readFileSync(file, "utf8");
  const start = source.indexOf("function ReplayIcon");
  if (start === -1) {
    problems.push(
      `${RUNNING}: no \`ReplayIcon\` — the running prototype no longer draws ` +
        "the kind marks where this reads them, which is a ruling to make " +
        "rather than a miss to paper over.",
    );
    return [];
  }
  const body = source.slice(start);

  const items = [];
  for (const [kind, meta] of Object.entries(RUNNING_KINDS)) {
    const block = new RegExp(
      `if \\(kind === '${kind}'\\)[\\s\\S]*?(<svg[\\s\\S]*?</svg>)`,
    ).exec(body);
    if (!block) {
      problems.push(`${RUNNING}/${kind}: \`ReplayIcon\` no longer draws it`);
      continue;
    }

    const markup = normaliseJsxMark(block[1]);
    if (!/viewBox="0 0 [\d.]+ [\d.]+"/.test(markup)) {
      problems.push(`${RUNNING}/${kind}: no 0-origin viewBox`);
      continue;
    }
    if (elementsOf(markup).length === 0) {
      problems.push(`${RUNNING}/${kind}: draws nothing`);
      continue;
    }

    items.push([meta.name, meta.label, meta.description, markup]);
  }

  return items;
}

/** One JSX `<svg>` as the catalogue's helper would have written it. */
function normaliseJsxMark(markup) {
  const inner = markup.slice(markup.indexOf(">") + 1, markup.lastIndexOf("</svg>"));
  const viewBox = /viewBox="([^"]*)"/.exec(markup);
  const attributes = Object.entries(JSX_ATTRIBUTES).reduce(
    (text, [jsx, svg]) => text.replaceAll(`${jsx}=`, `${svg}=`),
    inner,
  );

  // The root is restated rather than carried over: the JSX one holds
  // `width={size}`, `height={size}` and `style={s}`, none of which mean
  // anything in a written asset.
  return (
    `<svg viewBox="${viewBox[1]}" fill="none" stroke-width="1.6" ` +
    `aria-hidden="true">${attributes.replace(/\s+/g, " ").trim()}</svg>`
  );
}

function assertPaint(sets, problems) {
  for (const [setKey, set] of Object.entries(sets)) {
    for (const [name, , , markup] of set.items) {
      for (const match of markup.matchAll(/(?:stroke|fill)="([^"]*)"/g)) {
        if (!ALLOWED_PAINT.has(match[1])) {
          problems.push(
            `${setKey}/${name}: paints in \`${match[1]}\`, which is not one of ` +
              `${[...ALLOWED_PAINT].join(", ")}. A mark that carries its own ` +
              "colour cannot follow the mood.",
          );
        }
      }
    }
  }
}

function assertOneDrawingPerName(sets, problems) {
  const seen = new Map();
  for (const [setKey, set] of Object.entries(sets)) {
    for (const [name, , , markup] of set.items) {
      const geometry = geometryOf(markup);
      const previous = seen.get(name);
      if (!previous) {
        seen.set(name, { setKey, geometry });
      } else if (previous.geometry !== geometry) {
        problems.push(
          `${setKey}/${name} draws different geometry from ${previous.setKey}/${name}. ` +
            "The family's rule is one concept, one drawing — two shapes under " +
            "one name is a design question, not something to resolve by picking one.",
        );
      }
    }
  }
}

function assertStateful(sets, problems) {
  for (const [setKey, marks] of Object.entries(STATEFUL)) {
    const set = sets[setKey];
    if (!set) {
      problems.push(`STATEFUL names set \`${setKey}\`, which the catalogue has not got`);
      continue;
    }
    for (const [name, state] of Object.entries(marks)) {
      const item = set.items.find(([itemName]) => itemName === name);
      if (!item) {
        problems.push(
          `STATEFUL names \`${setKey}/${name}\`, which the catalogue has not got — ` +
            "the running prototype and the catalogue no longer draw the same " +
            "family, which is a ruling to make rather than a mismatch to paper over.",
        );
        continue;
      }
      const drawn = elementsOf(item[3]).length;
      if (drawn !== state.elements) {
        problems.push(
          `${setKey}/${name}: STATEFUL paints ${state.elements} elements but the ` +
            `catalogue draws ${drawn}. The transcription addresses elements by ` +
            "position, so a changed drawing must be re-read against " +
            "`flavor-wheel.jsx` before it can be trusted.",
        );
      }
    }
  }
}

/** Applies one state's paint, then rewrites the mark as a standalone file. */
function toAsset(markup, overrides = {}) {
  const painted = Object.keys(overrides).length
    ? elementsOf(markup).reduce((current, element, index) => {
        const attributes = overrides[index];
        if (!attributes) return current;
        const repainted = Object.entries(attributes).reduce(
          (text, [attribute, value]) => withAttribute(text, attribute, value),
          element,
        );
        return current.replace(element, repainted);
      }, markup)
    : markup;

  // The intrinsic size comes from the mark's own viewBox, never a constant:
  // the concept family is drawn 24x24, but the chrome sets are deliberately
  // smaller — 20, 18, 16, and two that are not square at all — and stamping
  // one size on all of them would scale the small ones up to match.
  const viewBox = /viewBox="0 0 ([\d.]+) ([\d.]+)"/.exec(painted);
  if (!viewBox) throw new Error(`a mark has no 0-origin viewBox: ${painted.slice(0, 80)}`);
  const open = painted
    .slice(0, painted.indexOf(">") + 1)
    .replace(' aria-hidden="true"', ` width="${viewBox[1]}" height="${viewBox[2]}"`);
  const body = elementsOf(painted)
    .map((element) => `  ${element}`)
    .join("\n");
  const file = `${open}\n${body}\n</svg>\n`;

  return Object.entries(SENTINELS).reduce(
    (text, [variable, literal]) => text.replaceAll(variable, literal),
    file,
  );
}

function main() {
  const options = { source: DEFAULT_SOURCE, out: DEFAULT_OUT };
  const argv = process.argv.slice(2);
  for (let index = 0; index < argv.length; index += 2) {
    const flag = argv[index];
    if (flag !== "--source" && flag !== "--out") {
      fail([`unknown argument '${flag}' — expected --source or --out`]);
    }
    if (argv[index + 1] === undefined) fail([`${flag} needs a value`]);
    options[flag.slice(2)] = path.resolve(argv[index + 1]);
  }

  const problems = [];
  const sets = readCatalogue(options.source, problems);

  // The running prototype's kind marks join the catalogue's own set, so every
  // assertion below reads them too — paint, one-drawing-per-name, and the
  // write itself. They are not a second pipeline.
  const running = readRunningKinds(options.source, problems);
  if (running.length) {
    if (!sets.kinds) {
      problems.push(`${CATALOGUE}: no \`kinds\` set for the running marks to join`);
    } else {
      sets.kinds.items.push(...running);
    }
  }

  assertPaint(sets, problems);
  assertOneDrawingPerName(sets, problems);
  assertStateful(sets, problems);
  if (problems.length) fail(problems);

  fs.mkdirSync(options.out, { recursive: true });

  const written = new Set();
  const marks = [];
  for (const [setKey, set] of Object.entries(sets)) {
    for (const [name, label, description, markup] of set.items) {
      const slug = slugify(name);
      if (written.has(slug)) continue;
      written.add(slug);

      const state = STATEFUL[setKey]?.[name];
      fs.writeFileSync(
        path.join(options.out, `${slug}.svg`),
        toAsset(markup, state?.inactive),
      );
      if (state) {
        fs.writeFileSync(
          path.join(options.out, `${slug}_active.svg`),
          toAsset(markup, state.active),
        );
      }

      marks.push({
        slug,
        name,
        set: setKey,
        label,
        description: String(description).replace(/\s+/g, " ").trim(),
        hasActive: Boolean(state),
      });
    }
  }

  fs.writeFileSync(
    path.join(options.out, "index.json"),
    `${JSON.stringify(
      {
        sentinels: SENTINELS,
        sets: Object.fromEntries(
          Object.entries(sets).map(([key, set]) => [
            key,
            { title: set.title, rule: String(set.rule).replace(/\s+/g, " ").trim() },
          ]),
        ),
        marks,
      },
      null,
      2,
    )}\n`,
  );

  const actives = marks.filter((mark) => mark.hasActive).length;
  process.stdout.write(
    `${marks.length} marks (${actives} with an active state) written to ` +
      `${path.relative(REPO_ROOT, options.out)}\n`,
  );
}

main();
