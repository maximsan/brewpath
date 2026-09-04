#!/usr/bin/env node
"use strict";

/**
 * Bridges the collectible artwork into the app's bundled SVG assets.
 *
 *   node tool/extract_card_art.js
 *   node tool/extract_card_art.js --source <prototype-dir> --out <output-dir>
 *
 * The thirty-seven card arts are drawn in `prototype/screens.jsx`, so this
 * extracts them rather than redrawing them — the sibling of
 * `tool/extract_icons.js`, and for the same reason: the art the app shows is
 * the art the design drew, and a design edit reaches the app by re-running
 * this rather than by someone noticing.
 *
 * `prototype/` is the design source and is read-only. This opens it for
 * reading and writes only under `--out`.
 *
 * ## Why this one has to *run* the source
 *
 * The icons could be sliced as text: the catalogue draws them with a plain
 * `svg()` template helper. These cannot. Five arts compose a prop-taking
 * `FieldGuideFrame`, and eight compute their geometry with `Array.from` and
 * `Math` — so the components have to be executed, not read. The prototype
 * executes them with React and Babel from a CDN, which is not available
 * offline and would be this repo's first npm dependency. So
 * `extract_card_art/jsx.js` reads the one dialect this file writes, and
 * refuses anything outside it.
 *
 * ## Colour
 *
 * Nothing here bakes in a colour. Every paint is `none`, one of the
 * [SENTINELS] — a stand-in for a CSS variable, mapped back to a token on the
 * Dart side — or one of the [LITERAL_PAINTS] the design itself leaves
 * untokenised. `assertPaint` refuses anything else, so an art that would not
 * follow the mood cannot reach the assets.
 *
 * The split matters: `--sage` and `--berry` are declared once per mood and
 * flip, so they map to `MoodColors`. The `--art-*` family is declared once for
 * both moods and does not flip, so it maps to `ArtColors`. Baking either as a
 * hex here would put a second copy of a design value under `assets/`, where
 * nothing would notice it drifting from the token.
 *
 * ## What fails a run
 *
 * Writing nothing on any violation is the point: a partial write leaves the
 * app mixing a new art with a stale one.
 *
 * - an art paints in something outside the sets above;
 * - `CARD_ART` names a component the file does not define, or the JSX uses a
 *   construct `jsx.js` does not read;
 * - an art renders no drawable element, which would ship a blank tile.
 *
 * A successful run also sweeps `--out` of any `.svg` it did not just write,
 * so a drawing the design has dropped leaves the bundle with it.
 */

const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const { transform, h, render, PRAGMA } = require("./extract_card_art/jsx");

const REPO_ROOT = path.resolve(__dirname, "..");
const DEFAULT_SOURCE = path.join(REPO_ROOT, "prototype");
const DEFAULT_OUT = path.join(REPO_ROOT, "assets", "card_art");

const SOURCE_FILE = "screens.jsx";

/**
 * Where the block starts and ends, named by what the design calls them.
 *
 * It stops at `CARD_TINT` and does not read it: the wash behind an art is
 * already carried by `lib/features/cards/presentation/card_tint.dart`, and a
 * second copy under `assets/` is one nothing would notice drifting.
 */
const BLOCK_START = "function CardArtBotanical";
const BLOCK_END = "const CARD_TINT";

/**
 * Every CSS custom property the arts paint in, and the impossible colour
 * written in its place. Magenta on purpose: one that slips through unmapped is
 * visibly wrong rather than plausibly right in one mood.
 *
 * The `--art-*` half is mood-independent and maps to `ArtColors`; the rest
 * flips with the mood and maps to `MoodColors`.
 */
const SENTINELS = {
  "var(--ink)": "#FE0001",
  "var(--ink-mute)": "#FE0002",
  "var(--rule)": "#FE0003",
  "var(--surface)": "#FE0004",
  "var(--surface-2)": "#FE0005",
  "var(--accent)": "#FE0006",
  "var(--sage)": "#FE0007",
  "var(--berry)": "#FE0008",
  "var(--art-cream)": "#FE0011",
  "var(--art-ripe)": "#FE0012",
  "var(--art-sour)": "#FE0013",
  "var(--art-roast-light)": "#FE0014",
  "var(--art-roast-mid)": "#FE0015",
  "var(--art-roast-dark)": "#FE0016",
  "var(--art-seed-crease)": "#FE0017",
  "var(--art-cherry-skin)": "#FE0021",
  "var(--art-cherry-pulp)": "#FE0022",
  "var(--art-cherry-gel)": "#FE0023",
  "var(--art-cherry-parchment)": "#FE0024",
  "var(--art-cherry-silverskin)": "#FE0025",
  "var(--art-cherry-seed)": "#FE0026",
};

/**
 * Paints the design writes as literals, with the reason each is allowed.
 *
 * The register exists so that *these* pass and anything else still fails. A
 * new literal in the design is a question for the owner — a colour with no
 * token cannot follow the mood — not something to wave through.
 */
const LITERAL_PAINTS = {
  "rgba(27,22,20,0.24)":
    "the hairline between the cherry's six layers. Mood-independent, like the " +
    "--art-* fills it separates, and the design gives it no token.",
};

/** What an art may paint in, before the sentinels are substituted. */
const ALLOWED_PAINT = new Set([
  "none",
  ...Object.keys(SENTINELS),
  ...Object.keys(LITERAL_PAINTS),
]);

/** Elements that actually draw something. An art with none of these is blank. */
const DRAWABLE = /<(?:path|circle|rect|ellipse|line|polyline|polygon|text)\b/;

const fail = (problems) => {
  process.stderr.write(`${problems.map((line) => `  - ${line}`).join("\n")}\n`);
  process.stderr.write("Nothing was written.\n");
  process.exit(1);
};

/** `fieldGuideBeans` → `field_guide_beans`, the asset's name on disk. */
const slugify = (kind) =>
  kind.replace(/([a-z0-9])([A-Z])/g, "$1_$2").toLowerCase();

/** The block of the source that draws the arts, as text. */
function sliceBlock(sourceDir, problems) {
  const file = path.join(sourceDir, SOURCE_FILE);
  const source = fs.readFileSync(file, "utf8");

  const start = source.indexOf(BLOCK_START);
  const end = source.indexOf(BLOCK_END);
  if (start === -1 || end === -1 || end < start) {
    problems.push(
      `${SOURCE_FILE} no longer runs from \`${BLOCK_START}\` to \`${BLOCK_END}\` — ` +
        "the art block has moved or been renamed.",
    );
    return null;
  }
  return source.slice(start, end);
}

/** Runs the block and hands back its `CARD_ART` map. */
function evaluateArts(block, problems) {
  let compiled;
  try {
    compiled = transform(block);
  } catch (error) {
    problems.push(`the art block uses JSX this reads no longer: ${error.message}`);
    return null;
  }

  const sandbox = { [PRAGMA]: h, Math, Array, Object, String, Number };
  try {
    vm.runInNewContext(`${compiled}\nglobalThis.__arts = CARD_ART;`, sandbox, {
      filename: SOURCE_FILE,
    });
  } catch (error) {
    problems.push(`the art block did not run: ${error.message}`);
    return null;
  }
  return sandbox.__arts ?? null;
}

/**
 * Every attribute in [markup] that carries a colour.
 *
 * Deliberately wider than `fill` and `stroke`: a gradient stop or a filter
 * would put a colour on `stop-color` or `flood-color`, and one that reached
 * the assets unchecked would be a fixed literal that never follows the mood —
 * the exact failure this guard exists to prevent. No art uses one today, which
 * is why the list has to be written before one does.
 */
const PAINT_ATTRIBUTES = [
  "fill",
  "stroke",
  "color",
  "stop-color",
  "flood-color",
  "lighting-color",
];

const paintsOf = (markup) =>
  [
    ...markup.matchAll(
      new RegExp(`(?:${PAINT_ATTRIBUTES.join("|")})="([^"]*)"`, "g"),
    ),
  ].map((match) => match[1]);

function assertPaint(kind, markup, problems) {
  for (const paint of paintsOf(markup)) {
    if (!ALLOWED_PAINT.has(paint)) {
      problems.push(
        `\`${kind}\` paints in \`${paint}\`, which maps to no token. Add it to ` +
          "SENTINELS with its token, or to LITERAL_PAINTS with its reason.",
      );
    }
  }
}

const substituteSentinels = (markup) =>
  Object.entries(SENTINELS).reduce(
    (text, [token, literal]) => text.split(token).join(literal),
    markup,
  );

function main() {
  const options = { source: DEFAULT_SOURCE, out: DEFAULT_OUT };
  const argv = process.argv.slice(2);
  for (let index = 0; index < argv.length; index += 1) {
    const flag = argv[index];
    if (flag !== "--source" && flag !== "--out") {
      fail([`unknown argument \`${flag}\`. Usage: --source <dir> --out <dir>`]);
    }
    const value = argv[index + 1];
    if (value === undefined) fail([`\`${flag}\` was given no value.`]);
    options[flag === "--source" ? "source" : "out"] = path.resolve(value);
    index += 1;
  }

  const problems = [];
  const block = sliceBlock(options.source, problems);
  if (problems.length) fail(problems);

  const arts = evaluateArts(block, problems);
  if (problems.length || !arts) fail(problems.length ? problems : ["`CARD_ART` was not found."]);

  const drawn = [];
  for (const [kind, component] of Object.entries(arts)) {
    if (typeof component !== "function") {
      problems.push(`\`${kind}\` names \`${component}\`, which is not a component.`);
      continue;
    }
    let markup;
    try {
      markup = render(component({}));
    } catch (error) {
      problems.push(`\`${kind}\` did not draw: ${error.message}`);
      continue;
    }
    if (!DRAWABLE.test(markup)) {
      problems.push(`\`${kind}\` drew nothing, which would ship a blank tile.`);
      continue;
    }
    assertPaint(kind, markup, problems);
    drawn.push({ kind, slug: slugify(kind), markup: substituteSentinels(markup) });
  }

  if (problems.length) fail(problems);

  fs.mkdirSync(options.out, { recursive: true });
  for (const { slug, markup } of drawn) {
    fs.writeFileSync(path.join(options.out, `${slug}.svg`), `${markup}\n`);
  }

  // A drawing the design has dropped would otherwise stay on disk, stay in
  // the bundle — the pubspec entry is the whole directory — and be caught by
  // nothing, since every check runs from what was written outwards.
  const written = new Set(drawn.map(({ slug }) => `${slug}.svg`));
  for (const file of fs.readdirSync(options.out)) {
    if (file.endsWith(".svg") && !written.has(file)) {
      fs.unlinkSync(path.join(options.out, file));
    }
  }

  fs.writeFileSync(
    path.join(options.out, "index.json"),
    `${JSON.stringify(
      {
        sentinels: SENTINELS,
        literals: LITERAL_PAINTS,
        arts: drawn.map(({ kind, slug }) => ({ kind, slug })),
      },
      null,
      2,
    )}\n`,
  );

  process.stdout.write(
    `${drawn.length} card arts written to ${path.relative(REPO_ROOT, options.out)}\n`,
  );
}

main();
