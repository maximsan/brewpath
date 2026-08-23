/**
 * Dumps every countable fact the design reference (docs/design/) asserts, read out of the
 * prototype source. Throwaway: re-run it after any design change to re-derive
 * the doc's numbers instead of trusting them.
 *
 *   node docs/design/tools/extract-facts.js            # from the repo root
 *   node extract-facts.js ../../../prototype           # from this directory
 *
 * Data files are plain JS that assign onto `window`; they are evaluated in a
 * VM with a stub `window`. Files carrying JSX are read as text instead.
 */
const fs = require('fs');
const path = require('path');
const vm = require('vm');

const DEFAULT_ROOT = path.resolve(__dirname, '..', '..', '..', 'prototype');
const ROOT = process.argv[2] ? path.resolve(process.argv[2]) : DEFAULT_ROOT;
if (!fs.existsSync(path.join(ROOT, 'data.jsx'))) {
  console.error(`No data.jsx under ${ROOT} — pass the prototype directory as argv[2].`);
  process.exit(1);
}
const read = (f) => fs.readFileSync(path.join(ROOT, f), 'utf8');

/** Load the pure-data modules. bean-anatomy must precede lesson.jsx's reads. */
function loadData() {
  const ctx = { window: {}, console, React: { createElement: () => null } };
  ctx.window.window = ctx.window;
  vm.createContext(ctx);
  for (const f of ['dictionary-data.jsx', 'data.jsx']) {
    vm.runInContext(read(f), ctx, { filename: f });
  }
  return ctx.window;
}

/** Pull a top-level `const NAME = [...]` / `{...}` out of a JSX file as text. */
function block(src, name) {
  const start = src.search(new RegExp(`^(?:const|window\\.)\\s*${name}\\s*=`, 'm'));
  if (start < 0) return null;
  let depth = 0, started = false;
  for (let i = start; i < src.length; i++) {
    const ch = src[i];
    if (ch === '[' || ch === '{') { depth++; started = true; }
    else if (ch === ']' || ch === '}') { depth--; if (started && depth === 0) return src.slice(start, i + 1); }
  }
  return null;
}

const out = {};
const W = loadData();

// ── Silence is the real failure mode ──────────────────────────────────────
// This tool exists to contradict the docs. A read that quietly resolves to
// nothing lets it fail by *agreeing* with them instead — which is how
// `visualVariants` sat empty while the prototype renamed the field under it,
// and how `COLLECTION` took the whole script down only because it happened to
// be read unguarded. Every prototype symbol now goes through `need`, and
// anything unresolved is reported and exits non-zero.
const missing = [];

/** A `window` symbol the docs depend on. Absent is a finding, not an empty. */
function need(name) {
  if (W[name] === undefined || W[name] === null) {
    missing.push(name);
    return undefined;
  }
  return W[name];
}

/**
 * Reports anything unresolved and stops.
 *
 * Called at each section boundary rather than only at the end, because a
 * required symbol is dereferenced almost immediately — waiting until the end
 * means a raw `TypeError` on `undefined.length` instead of the name that
 * moved.
 */
function bailIfMissing() {
  if (!missing.length) return;
  console.error(
    `\n\u2717 ${missing.length} read(s) resolved to nothing:\n` +
    missing.map((name) => `    - ${name}`).join('\n') +
    '\n\nThe prototype has probably renamed something. Every number this tool\n' +
    'did not derive is a doc claim nobody checked.\n',
  );
  process.exit(1);
}

/** A derivation that should not be empty. Emptiness is a finding too. */
function expectNonEmpty(label, value) {
  const size = value == null ? 0 : (value.length ?? Object.keys(value).length);
  if (size === 0) missing.push(`${label} (derived nothing)`);
  return value;
}

// ── Course ────────────────────────────────────────────────────────────────
const L = need('LESSONS'), M = need('MODULES');
bailIfMissing();
/** Must match the graded-kind list in lesson.jsx's `quizTotal`. */
const GRADED = ['mcq', 'multi', 'match', 'slider', 'sequence', 'tastefix', 'bagpick', 'decision', 'recall', 'flavor'];
const kinds = {};
let cards = 0, graded = 0;
const perLesson = [];
const displayOrder = M.flatMap((m) => m.lessons.map((l) => l.id));

for (const id of displayOrder) {
  const cs = L[id].cards || [];
  cards += cs.length;
  perLesson.push(`${id} ${cs.length}`);
  for (const c of cs) {
    kinds[c.kind] = (kinds[c.kind] || 0) + 1;
    if (GRADED.includes(c.kind)) graded++;
  }
}

out.course = {
  modules: M.length,
  lessons: displayOrder.length,
  cards,
  graded,
  draft: displayOrder.filter((i) => L[i].draft).length,
  coreTotal: need('CORE_TOTAL'),
  masteryPass: need('MASTERY_PASS'),
  kinds,
  perLesson: perLesson.join(' · '),
  moduleTable: M.map((m) => ({
    id: m.id,
    title: m.title,
    label: m.label,
    lessonIds: m.lessons.map((l) => l.id).join(' '),
    lessonTitles: m.lessons.map((l) => L[l.id] && L[l.id].title).join(' · '),
  })),
  // Per-lesson reward lives on the MODULES entry (`points`), not on LESSONS.
  // The legacy `xp` field is gone; reading it returned null for every lesson.
  pointsValues: [...new Set(M.flatMap((m) => m.lessons.map((l) => l.points)))],
  timeValues: [...new Set(displayOrder.map((i) => L[i].time))],
};

// Visual guides: the placements in lessons, and the subjects behind them.
// The card's field is `visualGuide` — the old `variant`/`guide`/`art` guesses
// matched nothing and returned an empty list without saying so.
const visualCards = displayOrder.flatMap((i) =>
  L[i].cards.filter((c) => c.kind === 'visual'));
out.course.visualPlacements = visualCards.length;
out.course.visualVariants = expectNonEmpty('course.visualVariants',
  [...new Set(visualCards.map((c) => c.visualGuide))].filter(Boolean));

// The guide registry itself, which the collectible count deliberately excludes.
const guides = need('VISUAL_GUIDE_CARDS') || [];
out.visualGuides = {
  total: guides.length,
  subjects: guides.map((g) => g.visualGuide),
  titles: guides.map((g) => g.title),
  unlockLessons: guides.map((g) => (g.unlock || {}).lesson),
};

// ── Collectibles ──────────────────────────────────────────────────────────
// Renamed from COLLECTION when the guides moved out into their own registry.
const C = need('COLLECTIBLES');
bailIfMissing();
out.collection = {
  total: C.length,
  groups: C.reduce((a, c) => { const g = c.group || (c.unlock ? (c.unlock.module ? 'module' : 'lesson') : 'training'); a[g] = (a[g] || 0) + 1; return a; }, {}),
  artKinds: [...new Set(C.map((c) => c.kind))].sort(),
  titles: C.map((c) => c.title),
  duplicateTitles: Object.entries(C.reduce((a, c) => { a[c.title] = (a[c.title] || 0) + 1; return a; }, {})).filter(([, n]) => n > 1),
  moduleRewards: Object.entries(W.MODULE_REWARDS || {}).map(([k, r]) => `${k}: ${r.title} / ${r.badge || ''}`),
};

// CARD_ART / CARD_TINT keys live in screens.jsx as JSX components
const screens = read('screens.jsx');
const artKeys = (block(screens, 'CARD_ART') || '').match(/^\s*([A-Za-z]\w*):/gm) || [];
const tintKeys = (block(screens, 'CARD_TINT') || '').match(/^\s*([A-Za-z]\w*):/gm) || [];
const clean = (arr) => arr.map((s) => s.trim().replace(':', ''));
out.collection.cardArtKeys = clean(artKeys);
out.collection.cardTintKeys = clean(tintKeys);
out.collection.artKindsMissingComponent = out.collection.artKinds.filter((k) => !clean(artKeys).includes(k));

// ── Dictionary ────────────────────────────────────────────────────────────
const T = need('DICT_TERMS');
bailIfMissing();
out.dictionary = {
  terms: T.length,
  categories: need('DICT_CATEGORIES').map((c) => c.name || c.title || c.id),
  full: T.filter((t) => t.deep).length,
  stubs: T.filter((t) => !t.deep).length,
  withCheck: T.filter((t) => t.check).length,
  withPron: T.filter((t) => t.pron).length,
  referenceOnly: T.filter((t) => !t.lesson).map((t) => t.id),
  learnedSeed: (W.DICT_LEARNED_SEED || []).length,
  lessonAudit: W.dictLessonAudit ? W.dictLessonAudit() : 'n/a',
  byCat: T.reduce((a, t) => { a[t.cat] = (a[t.cat] || 0) + 1; return a; }, {}),
};

// ── Mini-games ────────────────────────────────────────────────────────────
const lessonSrc = read('lesson.jsx');
const mg = block(screens, 'MINI_GAMES') || block(lessonSrc, 'MINI_GAMES') || '';
out.miniGames = [...mg.matchAll(/id:\s*'([^']+)',\s*kind:\s*'([^']+)',\s*title:\s*'([^']+)'[\s\S]*?lessonId:\s*'([^']*)'[\s\S]*?time:\s*'([^']*)'/g)]
  .map((m) => ({ id: m[1], kind: m[2], title: m[3], lessonId: m[4], time: m[5] }));
if (!out.miniGames.length) {
  out.miniGames = [...mg.matchAll(/id:\s*'([^']+)',\s*kind:\s*'([^']+)',\s*title:\s*'([^']+)'/g)]
    .map((m) => ({ id: m[1], kind: m[2], title: m[3] }));
}
out.miniGameRaw = mg.slice(0, 2500);

// ── Coffee challenges ─────────────────────────────────────────────────────
const brew = read('brew-challenge.jsx');
out.brewChallenges = [...brew.matchAll(/id:\s*'(bc-[^']+)',\s*type:\s*'([^']+)'[\s\S]*?title:\s*'([^']*)'[\s\S]*?effort:\s*'([^']*)'/g)]
  .map((m) => ({ id: m[1], type: m[2], title: m[3], effort: m[4] }));
out.brewWindow = (brew.match(/BREW_WINDOW_MS\s*=\s*([^;]+);/) || [])[1];

// ── Routes ────────────────────────────────────────────────────────────────
const app = read('app.jsx');
const routesBlock = block(app, 'SCREEN_ROUTES') || '';
const routeKeys = clean(routesBlock.match(/^\s*'?[a-z0-9-]+'?:\s*\{/gm) || []).map((s) => s.replace(/'/g, '').replace(/\s*\{$/, '').trim());
out.routes = { count: routeKeys.length, keys: routeKeys };
out.routes.distinctViews = [...new Set([...routesBlock.matchAll(/view:\s*'([^']+)'/g)].map((m) => m[1]))];

// ── Assets ────────────────────────────────────────────────────────────────
const dirCount = (d) => { try { return fs.readdirSync(path.join(ROOT, d)).filter((f) => !f.startsWith('.')).length; } catch { return null; } };
out.assets = {
  trees: dirCount('assets/trees'),
  uploads: dirCount('uploads'),
  explorations: dirCount('explorations'),
  scraps: dirCount('scraps'),
  screenshots: dirCount('screenshots'),
  scratch: dirCount('scratch'),
};
out.files = fs.readdirSync(ROOT).filter((f) => !f.startsWith('.')).sort();
out.jsx = out.files.filter((f) => f.endsWith('.jsx'));
out.lineCounts = {};
for (const f of out.jsx.concat(['index.html'])) {
  try { out.lineCounts[f] = read(f).split('\n').length; } catch {}
}

// ── Misc constants ────────────────────────────────────────────────────────
out.stageNames = (W.STAGE_NAMES || []).length ? W.STAGE_NAMES : (read('flavor-wheel.jsx').match(/STAGE_NAMES\s*=\s*\[([^\]]+)\]/) || [])[1];
out.savedFreeMax = (app.match(/SAVED_FREE_MAX\s*=\s*(\d+)/) || [])[1];
out.plusFeatures = (block(read('gating.jsx'), 'PLUS_FEATURES') || '').slice(0, 800);

// `savedFreeMax` is scraped from source text rather than the VM, so it fails
// the same way the symbol reads used to — quietly.
if (out.savedFreeMax === undefined) missing.push('SAVED_FREE_MAX (not matched)');

console.log(JSON.stringify(out, null, 2));

// Loud, and last, so it survives a piped stdout.
bailIfMissing();
