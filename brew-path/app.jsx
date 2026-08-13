// app.jsx — top-level state, screen routing, mood/voice/cadence tweaks
// + lesson/module reward flow.

const { useState: useStateA, useEffect: useEffectA } = React;

// ── Tweaks ───────────────────────────────────────────────────
// Every key below is documented here, and this list is the whole set — if a key
// is not in this table it does not exist. Three categories, and the difference
// matters when you read the code:
//
//   PANEL   — has a control in the Tweaks panel. A reviewer can change it.
//   ROUTED  — no control, but a URL parameter can override the default for one
//             render, so screens-overview can show a variant as its own tile.
//             The override is read-only and is never persisted. Each ROUTED row
//             names the parameter it answers to.
//   SETTLED — read by the code, but neither a control nor routable: the design
//             decision behind it is made, and the value is the decision. The
//             alternate branches are still in the source because they are cheap
//             to keep and they document what was rejected. Deleting them is a v2
//             cleanup, not a v1 blocker. To try another value, edit the default
//             in the block below — every row lists its full value set, and those
//             are the strings the branches actually test. The default is listed
//             first.
//
// KEY              CAT      VALUES / WHAT SITS BEHIND IT
// scope            PANEL    v1 | everything. v1 hides Atlas, Duel, the ad layer,
//                           data export and the mood player — the surfaces the
//                           readiness audit deferred. `everything` renders them
//                           so they can be reviewed. SHIPS READING v1.
// progress         PANEL    default | states-demo | m1-complete | all-unlocked.
//                           Seeds the completed-lesson set that drives gating,
//                           the tree and the collection, so a reviewer can see
//                           late states without playing 32 lessons. states-demo
//                           also layers DEMO_BEST over the score map, so every
//                           mastery state appears at once. Dev-only.
// restoreOutcome   PANEL    plus | none | error. Which of the three Restore
//                           purchases results the button returns. There is no
//                           real store yet, so the outcome has to be chosen.
//                           Dies when StoreKit is wired.
// voice            SETTLED  field-guide | specimen | plain-spoken. Copy register
//                           across the app, applied as data-voice on <html>.
//                           field-guide is the baseline and has no CSS rules of
//                           its own; the other two override from index.html.
// onbFlow          ROUTED   guided | fieldguide. Which onboarding direction runs
//                           — guided keeps Roasty on every question, fieldguide
//                           steps back. Overridden per-iframe by ?flow= so the
//                           screens overview can show both (onboarding.jsx:91,
//                           271). Note the code's own fallback is `guided`; the
//                           default here wins whenever the tweak is present.
// roastyVoice      SETTLED  bubble-top | bubble-side | caption. Where Roasty's
//                           speech sits on an onboarding question.
// flowDepth        SETTLED  full | standard | essential. How many onboarding
//                           questions are asked (6 / 4 / 3, ONB_DEPTH).
//                           v1 does not reach this flow at all — Meet Roasty
//                           goes straight to Learn (app.jsx:1063), because the
//                           question flow is deferred to v2. The isV1 override
//                           below pins the depth to `standard` for anyone who
//                           deep-links in to review it, so editing the default
//                           here changes only the v2/Everything path.
// expectCopy       SETTLED  The expectation-setting line; {n} is the question
//                           count, substituted at render.
// lockStyle        SETTLED  blur | hard | curtain | tint | outline. How locked
//                           content is obscured behind a FeatureLock. `hard`
//                           renders no preview at all.
// bookmarkStyle    SETTLED  ring | solid | tint | outline. The saved/bookmark
//                           affordance. solid/tint/outline pick the glyph's
//                           filled state; ring instead puts a ring on the
//                           top-bar button (library.jsx:11-13, 66).
// tasteFixReact    SETTLED  true | false. Whether the cup on a taste-fix card
//                           reacts to your answer (settle + pulse, or shake).
// tasteFixSetup    SETTLED  card | brief. Whether a taste-fix scenario gets a
//                           full setup card or a one-line brief.
// atlasMapStyle    SETTLED  geo | dots. Atlas map rendering. v2 surface.
// atlasProfile     ROUTED   scroll | tabbed. The origin-profile layout, a v2
//                           surface (Atlas). The `origin-tabbed` ?screen= route
//                           pins it to `tabbed` so both layouts are reviewable
//                           side by side; everywhere else it reads the default.
// duelPicker       SETTLED  grid | list. Duel-type picker layout. v2 surface.
// duelReveal       SETTLED  tally | any other value. `tally` counts your score
//                           up; anything else shows the final number at once.
//                           Only `tally` is tested by name, so the alternative
//                           has no canonical spelling. v2 surface.
//
// The panel also carries three controls that are NOT tweak keys — Plus unlocked
// and the two freeze toggles write real app state, so they persist and behave
// exactly as the app would. They are listed in the panel, not here, on purpose.
const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "voice":   "field-guide",
  "onbFlow":      "fieldguide",
  "roastyVoice":  "bubble-top",
  "flowDepth":    "full",
  "expectCopy":   "Just {n} quick questions, then your first lesson.",
  "atlasMapStyle": "geo",
  "atlasProfile":  "scroll",
  "duelPicker":    "grid",
  "duelReveal":    "tally",
  "lockStyle":     "blur",
  "bookmarkStyle": "ring",
  "progress":      "default",
  "tasteFixReact": true,
  "tasteFixSetup": "card",
  "restoreOutcome": "plus",
  "scope": "v1"
}/*EDITMODE-END*/;

// ── Deep links ───────────────────────────────────────────────
// SCREEN_ROUTES is consumed by ?screen=… so the screens-overview
// iframes can route straight to any state. Each route is a partial
// state snapshot; we apply it on first render.
const _qs = new URLSearchParams(location.search);
const _initial = _qs.get('screen');
const SCREEN_ROUTES = {
  loading:          { view: 'loading' },
  welcome:          { view: 'onboarding-1' },
  meet:             { view: 'onboarding-meet' },
  expectation:      { view: 'onboarding-flow', onbSlug: 'expectation' },
  goal:             { view: 'onboarding-flow', onbSlug: 'goal' },
  brewer:           { view: 'onboarding-flow', onbSlug: 'brewer' },
  commitment:       { view: 'onboarding-flow', onbSlug: 'commitment' },
  experience:       { view: 'onboarding-flow', onbSlug: 'experience' },
  motivations:      { view: 'onboarding-flow', onbSlug: 'motivations' },
  reminders:        { view: 'onboarding-flow', onbSlug: 'reminders' },
  'onboarding-done':{ view: 'onboarding-flow', onbSlug: 'onboarding-done' },
  learn:            { view: 'app', tab: 'learn' },
  path:             { view: 'app', tab: 'path' },
  cards:            { view: 'app', tab: 'cards' },
  profile:          { view: 'app', tab: 'profile' },
  lesson:           { view: 'lesson', lessonId: 'm1l2' },
  // ── Two distinct game systems ──
  // 1. LESSON CARDS: interactive steps INSIDE a lesson. They advance the
  //    lesson, grant lesson points, and feed progression. The `card-*` deep-links
  //    open a lesson straight at a card of that kind (for the screens overview).
  'card-mcq':       { view: 'lesson', lessonId: 'm1l1', startKind: 'mcq' },
  'card-predict':   { view: 'lesson', lessonId: 'm1l2', startKind: 'predict' },
  'card-decision':  { view: 'lesson', lessonId: 'm1l2', startKind: 'decision' },
  'card-recall':    { view: 'lesson', lessonId: 'm1l2', startKind: 'recall' },
  'card-concept':   { view: 'lesson', lessonId: 'm1l2', startKind: 'concept' },
  'card-multi':     { view: 'lesson', lessonId: 'm1l2', startKind: 'multi' },
  'card-match':     { view: 'lesson', lessonId: 'm1l2', startKind: 'match' },
  'card-slider':    { view: 'lesson', lessonId: 'm1l2', startKind: 'slider' },
  'card-sequence':  { view: 'lesson', lessonId: 'm1l2', startKind: 'sequence' },
  // Visual-training / taste-fix card kinds, homed in the taste-first lessons.
  'card-visual':    { view: 'lesson', lessonId: 'm5l3', startKind: 'visual' },
  'card-anatomy':   { view: 'lesson', lessonId: 'm1l7', startKind: 'visual' },
  'card-bagpick':   { view: 'lesson', lessonId: 'm1l7', startKind: 'bagpick' },
  'lesson-layers':  { view: 'lesson', lessonId: 'm1l7' },
  'card-tastefix':  { view: 'lesson', lessonId: 'm4l3', startKind: 'tastefix' },
  'card-flavor':    { view: 'lesson', lessonId: 'm5l3', startKind: 'flavor' },
  'card-practical': { view: 'lesson', lessonId: 'm1l7', startKind: 'practical' },
  'lesson-grind':   { view: 'lesson', lessonId: 'm4l3' },
  'lesson-ratio':   { view: 'lesson', lessonId: 'm5l1' },
  'lesson-taste':   { view: 'lesson', lessonId: 'm5l3' },
  'card-training':  { view: 'app', tab: 'cards', sheet: true, cardId: 'tr-extraction' },
  // 2. MINI-GAMES: standalone, replayable challenges with their own
  //    intro → play → results flow. They never touch lesson points / progression.
  //    The `game-*` deep-links open a mini-game intro.
  'game-intro':     { view: 'game-intro', gameId: 'g-match' },
  'game-flavor':    { view: 'game-intro', gameId: 'g-flavor' },
  'game-quiz':      { view: 'game-intro', gameId: 'g-quiz' },
  'game-bagpick':   { view: 'game-intro', gameId: 'g-bagpick' },
  'game-tastefix':  { view: 'game-intro', gameId: 'g-tastefix' },
  'game-calibrate': { view: 'game-intro', gameId: 'g-calibrate' },
  'game-sequence':  { view: 'game-intro', gameId: 'g-sequence' },
  streak:           { view: 'streak' },
  tree:             { view: 'tree' },
  settings:         { view: 'settings' },
  paywall:          { view: 'paywall' },
  'plus-welcome':   { view: 'plus-welcome' },
  studio:           { view: 'studio' },
  'tree-chooser':   { view: 'tree-chooser' },
  'roasty-studio':  { view: 'roasty-studio' },
  'mood-player':    { view: 'mood-player' },
  cardsheet:        { view: 'app', tab: 'cards', sheet: true },
  saved:            { view: 'saved' },
  // Paywall / trials
  'rewarded-ad':    { view: 'rewarded-ad', adFeature: 'dictionary' },
  'roasty-gift':    { view: 'roasty-gift' },
  // Reward states
  'lesson-complete':{ view: 'lesson-complete', lessonId: 'm1l2', prevPoints: 110, newPoints: 120 },
  'lesson-complete-weak':{ view: 'lesson-complete', lessonId: 'm1l2', prevPoints: 110, newPoints: 120, result: { correct: 2, total: 7 } },
  'lesson-complete-perfect':{ view: 'lesson-complete', lessonId: 'm1l2', prevPoints: 110, newPoints: 120, result: { correct: 7, total: 7 } },
  'module-complete':{ view: 'module-complete', lessonId: 'm1l3', prevPoints: 110, newPoints: 150 },
  'module-card':    { view: 'module-card',     lessonId: 'm1l3', prevPoints: 110, newPoints: 150 },
  // ── Active Brew Challenge ──
  'module-challenge':    { view: 'module-challenge', lessonId: 'm1l3', prevPoints: 110, newPoints: 150 },
  'today-challenge':     { view: 'app', tab: 'learn', brewToday: 'active' },
  'today-challenge-done':{ view: 'app', tab: 'learn', brewToday: 'completed' },
  'today-nochallenge':   { view: 'app', tab: 'learn', brewToday: 'none' },
  'today-challenge-log': { view: 'app', tab: 'learn', brewToday: 'active', logSheet: true },
  'path-challenge':      { view: 'app', tab: 'path',  brewPath: 'completed' },
  'path-challenge-open': { view: 'app', tab: 'path',  brewPath: 'available' },
  'card-stamp':          { view: 'app', tab: 'cards', sheet: true, cardId: 'c1' },
  'card-stamp-locked':   { view: 'app', tab: 'cards', sheet: true, cardId: 'c3' },
  about:            { view: 'about' },
  help:             { view: 'help' },
  account:          { view: 'account' },
  subscription:     { view: 'subscription' },
  // Coffee Dictionary
  dictionary:       { view: 'dictionary' },
  term:             { view: 'term', termId: 'arabica' },
  'term-locked':    { view: 'term', termId: 'first-crack' },
  'term-reference': { view: 'term', termId: 'masl' },
  'term-of-day':    { view: 'term-of-day' },
  flashcards:       { view: 'flashcards' },
  'vocab-game':     { view: 'vocab-game' },
  // Coffee Atlas
  atlas:            { view: 'app', tab: 'atlas' },
  'atlas-loading':  { view: 'app', tab: 'atlas' },
  origin:           { view: 'origin', originSlug: 'ethiopia' },
  'origin-tabbed':  { view: 'origin', originSlug: 'colombia', atlasProfile: 'tabbed' },
  'atlas-region':   { view: 'atlas-region', regionId: 'africa' },
  'atlas-activity': { view: 'atlas-activity', originSlug: 'guatemala' },
  passport:         { view: 'passport' },
  'passport-empty': { view: 'passport', passportEmpty: true },
  'atlas-stamp':    { view: 'passport', stampDemo: 'rwanda' },
  'atlas-stamp-lesson': { view: 'passport', stampDemo: 'kenya', stampState: 'lesson' },
  // Coffee Duel — async challenge-a-friend flow
  duel:             { view: 'duel', duelStage: 'hub' },
  'duel-empty':     { view: 'duel', duelStage: 'hub-empty' },
  'duel-pick':      { view: 'duel', duelStage: 'pick' },
  'duel-play':      { view: 'duel', duelStage: 'play' },
  'duel-result':    { view: 'duel', duelStage: 'result' },
  'duel-invite':    { view: 'duel', duelStage: 'invite' },
  'duel-sent':      { view: 'duel', duelStage: 'sent' },
  'duel-received':  { view: 'duel', duelStage: 'received' },
  'duel-comparison':{ view: 'duel', duelStage: 'comparison' },
  'duel-loss':      { view: 'duel', duelStage: 'comparison-loss' },
  'duel-rematch':   { view: 'duel', duelStage: 'rematch' },
  'duel-expired':   { view: 'duel', duelStage: 'expired' },
  'duel-error':     { view: 'duel', duelStage: 'error' },
};
const _route = _initial && SCREEN_ROUTES[_initial] ? SCREEN_ROUTES[_initial] : null;
// Animation review screens: ?screen=anim-<state> → a centered, looping mascot.
const _animState = _initial && _initial.indexOf('anim-') === 0 ? _initial.slice(5) : null;

// The shape of "no progress", defined once. Reset progress and Delete account
// both clear to these, so neither can forget a key the other remembers.
// (Delete additionally clears saved content, the Atlas passport, recents,
// timed unlocks, Plus and customisation — see deleteAccount.)
const EMPTY_PROGRESSION = () => ({ streak: 0, points: 0, prevPoints: 0, completed: new Set(), bestResults: {} });
const EMPTY_BREW = () => ({ activeId: null, startedAt: null, completed: new Set(), saved: new Set() });

// Seeded demo progress — the state a fresh install (or a reset, then a reload)
// starts from. Only lesson 1 is done, so the tree is an early sprout.
const SEED_PROGRESSION = () => ({
  streak: 7, points: 10, prevPoints: 10,
  completed: new Set(['m1l1']),
  // Best-ever { correct, total } per lesson id. Drives lesson state
  // (Needs Practice / Completed / Mastered / Perfect). We keep the highest
  // ratio ever achieved and never downgrade it on a worse replay.
  bestResults: { m1l1: { correct: 2, total: 3 } },
});

// Theme preference is a real, runtime user setting (light | dark | system).
// It is stored in localStorage — NOT the host-persisted tweak system — so it
// (a) survives reloads and (b) syncs live across every screens-overview iframe
// via the `storage` event. `system` resolves against the OS color scheme.
function readThemePref() {
  try { return localStorage.getItem('cq-theme') || 'dark'; } catch (e) { return 'dark'; }
}
function systemPrefersDark() {
  try { return window.matchMedia('(prefers-color-scheme: dark)').matches; } catch (e) { return true; }
}

function App() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);
  window.__tweaks = t;
  // The prototype ships as the v1 cut: only the surfaces the readiness audit
  // locked into v1 (learning core, Dictionary, Saved, Plus/Studio). Atlas, Duel,
  // the rewarded-ad/trial layer and the mood player stay held back for v2.
  // Scope: what the review build shows. 'v1' is what ships — the learning core,
  // Dictionary, Saved and Plus/Studio. 'everything' also renders the surfaces
  // held back for v2 (Atlas, Duel, the rewarded-ad/trial layer, the mood player,
  // data export), which are otherwise unreachable for review at any URL.
  const isV1 = t.scope !== 'everything';
  // Bookmark glyph reads a global so every screen (many separate component
  // files) stays in sync without threading a prop through each call site.
  window.BOOKMARK_STYLE = t.bookmarkStyle;

  // ── Theme (appearance) ──
  const [themePref, setThemePref] = useStateA(readThemePref);
  const [systemDark, setSystemDark] = useStateA(systemPrefersDark);
  const setTheme = (pref) => {
    setThemePref(pref);
    try { localStorage.setItem('cq-theme', pref); } catch (e) {}
  };
  // Track the OS color scheme so `system` follows it live.
  useEffectA(() => {
    const mq = window.matchMedia('(prefers-color-scheme: dark)');
    const onChange = (e) => setSystemDark(e.matches);
    if (mq.addEventListener) mq.addEventListener('change', onChange);
    else mq.addListener(onChange);
    return () => {
      if (mq.removeEventListener) mq.removeEventListener('change', onChange);
      else mq.removeListener(onChange);
    };
  }, []);
  // Keep every screen in sync: when one iframe changes the theme, the rest hear
  // it through the cross-document `storage` event and re-apply immediately.
  useEffectA(() => {
    const onStorage = (e) => { if (e.key === 'cq-theme' && e.newValue) setThemePref(e.newValue); };
    window.addEventListener('storage', onStorage);
    return () => window.removeEventListener('storage', onStorage);
  }, []);

  // ── Routing state ──
  // App opens on the Roasty loading screen, which auto-advances to onboarding
  // unless a deep-link route says otherwise.
  const [view, setView] = useStateA(_animState ? 'anim' : (_route ? _route.view : 'loading'));
  const [tab, setTab] = useStateA(_route && _route.tab ? _route.tab : 'learn');
  const [activeLessonId, setActiveLessonId] = useStateA(_route && _route.lessonId ? _route.lessonId : null);
  const [completedLesson, setCompletedLesson] = useStateA(
    _route && _route.lessonId && (_route.view === 'lesson-complete' || _route.view === 'module-complete' || _route.view === 'module-card' || _route.view === 'module-challenge')
      ? (() => {
          const lesson = findLessonOrPlaceholder(_route.lessonId);
          // Demo seed so the deep-linked result screen previews score + state.
          const result = _route.result || { correct: 5, total: 7 };
          return { ...lesson, result, lessonState: window.lessonStateFromResult(result) };
        })()
      : null
  );
  const [openCard, setOpenCard] = useStateA(
    _route && _route.sheet
      ? (window.findCard(_route.cardId) || COLLECTION[0])
      : null
  );
  const [activeGame, setActiveGame] = useStateA(
    _route && _route.view === 'game-intro'
      ? (window.MINI_GAMES ? (window.MINI_GAMES.find(g => g.id === _route.gameId) || window.MINI_GAMES[0]) : null)
      : null
  );
  const [lessonStartKind] = useStateA(_route && _route.startKind ? _route.startKind : null);
  const [sheetOpen, setSheetOpen] = useStateA(_route && _route.sheet ? true : false);
  const [onbStart, setOnbStart] = useStateA(_route && _route.onbSlug ? _route.onbSlug : 'expectation');
  const [activeModuleId, setActiveModuleId] = useStateA(_route && _route.moduleId ? _route.moduleId : 'm1');
  const [reviewLessonId, setReviewLessonId] = useStateA(null);
  const [reviewActive, setReviewActive] = useStateA(false);

  // —— Coffee Duel ——
  const [duelStage, setDuelStage] = useStateA(_route && _route.duelStage ? _route.duelStage : 'hub');
  const [duelKey, setDuelKey] = useStateA(0); // remount DuelFlow on a fresh entry
  const openDuel = (stage) => { setDuelStage(stage || 'hub'); setDuelKey(k => k + 1); setView('duel'); };

  // ── Favorites (saved lessons / cards / mini-games), persisted ──
  // Free tier keeps a soft cap on the Saved shelf; Plus lifts it.
  const SAVED_FREE_MAX = 10;
  const [favorites, setFavorites] = useStateA(() => {
    let stored = null;
    try { stored = JSON.parse(localStorage.getItem('cq-favorites')); } catch (e) {}
    return new Set(Array.isArray(stored) ? stored : ['l:m1l1', 'c:c1', 't:arabica', 't:bloom', 't:crema']);
  });
  useEffectA(() => {
    try { localStorage.setItem('cq-favorites', JSON.stringify([...favorites])); } catch (e) {}
  }, [favorites]);
  // Only lessons / terms / guides land on the Saved shelf, so only those count
  // against the free tier's soft cap.
  const isSavedKey = (key) => /^(l|t|g):/.test(key);
  const toggleFavorite = (key) => {
    // Free tier holds a limited shelf; Plus makes saving unlimited. Removing is
    // always allowed, so a capped free user can still curate.
    if (isSavedKey(key) && !favorites.has(key) && !isPlus
        && [...favorites].filter(isSavedKey).length >= SAVED_FREE_MAX) {
      setGateFeature('saved');
      return;
    }
    setFavorites(prev => {
      const next = new Set(prev);
      if (next.has(key)) next.delete(key); else next.add(key);
      return next;
    });
  };

  // ── Coffee Atlas state (exploration states + favourites), persisted ──
  const [atlasData, setAtlasData] = useStateA(() => {
    let s = null; try { s = JSON.parse(localStorage.getItem('cq-atlas')); } catch (e) {}
    if (s && s.states && s.favs) { s.tastedFrom = s.tastedFrom || {}; return s; }
    return { states: { ...window.ATLAS_SEED.states }, favs: [...window.ATLAS_SEED.favs], tastedFrom: {} };
  });
  useEffectA(() => { try { localStorage.setItem('cq-atlas', JSON.stringify(atlasData)); } catch (e) {} }, [atlasData]);
  const [atlasOriginSlug, setAtlasOriginSlug]     = useStateA(_route && _route.originSlug ? _route.originSlug : 'ethiopia');
  const [atlasRegionId, setAtlasRegionId]         = useStateA(_route && _route.regionId ? _route.regionId : 'africa');
  const [atlasActivitySlug, setAtlasActivitySlug] = useStateA(_route && _route.originSlug ? _route.originSlug : 'ethiopia');
  const [passportEmpty, setPassportEmpty]         = useStateA(!!(_route && _route.passportEmpty));
  const [stampAward, setStampAward]               = useStateA(_route && _route.stampDemo ? { slug: _route.stampDemo, state: _route.stampState || 'tasted' } : null);
  const [freshSlug, setFreshSlug]                 = useStateA(_route && _route.stampDemo ? _route.stampDemo : null);

  const ATLAS_RANK_STATE = ['not-explored', 'discovered', 'lesson', 'tasted'];
  const advanceAtlas = (slug, targetRank) => setAtlasData(d => {
    const cur = window.atlasRank(d.states[slug]);
    const nextRank = Math.max(cur, targetRank);
    if (nextRank === cur && d.states[slug]) return d;
    return { ...d, states: { ...d.states, [slug]: ATLAS_RANK_STATE[nextRank] } };
  });
  const atlasDiscover         = (slug) => advanceAtlas(slug, 1);
  const atlasCompleteActivity = (slug) => {
    const fresh = window.atlasRank(atlasData.states[slug]) < 2;
    advanceAtlas(slug, 2);
    if (fresh) setStampAward({ slug, state: 'lesson' });
  };
  // Tasting is a toggle. `tastedFrom` remembers the state before tasting so an
  // un-taste restores it (rather than wiping lesson/discovery progress).
  const atlasMarkTasted = (slug) => {
    const isTasted = window.atlasRank(atlasData.states[slug]) >= 3;
    if (isTasted) {
      setAtlasData(d => {
        const back = (d.tastedFrom && d.tastedFrom[slug]) || 'lesson';
        const tastedFrom = { ...(d.tastedFrom || {}) }; delete tastedFrom[slug];
        return { ...d, states: { ...d.states, [slug]: back }, tastedFrom };
      });
      if (freshSlug === slug) setFreshSlug(null);
    } else {
      setAtlasData(d => {
        const tastedFrom = { ...(d.tastedFrom || {}), [slug]: d.states[slug] || 'discovered' };
        return { ...d, states: { ...d.states, [slug]: 'tasted' }, tastedFrom };
      });
      setFreshSlug(slug);
      setStampAward({ slug, state: 'tasted' });
    }
  };
  const atlasToggleFav = (slug) => setAtlasData(d => {
    const has = d.favs.indexOf(slug) >= 0;
    return { ...d, favs: has ? d.favs.filter(x => x !== slug) : [...d.favs, slug] };
  });
  const openOrigin        = (slug) => { atlasDiscover(slug); setAtlasOriginSlug(slug); setView('origin'); };
  const openAtlasActivity = (slug) => { setAtlasActivitySlug(slug); setView('atlas-activity'); };
  const openPassport      = () => { setPassportEmpty(false); setView('passport'); };
  const openAtlasRegion   = (rid) => { setAtlasRegionId(rid); setView('atlas-region'); };

  // ── Coffee Dictionary state ──
  const [activeTermId, setActiveTermId] = useStateA(_route && _route.termId ? _route.termId : 'arabica');
  const [termPeek, setTermPeek]         = useStateA(null);   // id shown in the in-lesson peek sheet
  const [termReturn, setTermReturn]     = useStateA(null);   // where to return after a full term view
  const [flashBack, setFlashBack]       = useStateA('dictionary'); // view flashcards closes back to
  const [dictSearchSeed, setDictSearchSeed] = useStateA(_route && _route.dictSearch ? _route.dictSearch : '');
  const [dictFocus, setDictFocus]       = useStateA(false);
  // Recently-opened dictionary terms. Postponed for v2 (not currently surfaced
  // in the dictionary UI) but tracked so re-enabling is trivial.
  const [recentTerms, setRecentTerms]   = useStateA(() => {
    let s = null; try { s = JSON.parse(localStorage.getItem('cq-recent-terms')); } catch (e) {}
    return Array.isArray(s) ? s : ['crema', 'bloom'];
  });
  useEffectA(() => { try { localStorage.setItem('cq-recent-terms', JSON.stringify(recentTerms)); } catch (e) {} }, [recentTerms]);
  const recordRecent = (id) => setRecentTerms(prev => [id, ...prev.filter(x => x !== id)].slice(0, 10));

  // ── Customization (premium) state, persisted across refreshes ──
  const _savedCustom = (() => { try { return JSON.parse(localStorage.getItem('cq-custom')) || {}; } catch (e) { return {}; } })();
  const [isPlus, setIsPlus]       = useStateA(!!_savedCustom.plus);
  const [subPlan, setSubPlan]     = useStateA(_savedCustom.subPlan || 'yearly');
  // Trial is its own state, not a flavour of Plus: 0 means "paying", >0 means the
  // 7-day trial is still running. Access is identical either way (isPlus), so only
  // the billing language changes.
  const TRIAL_DAYS = 7;
  const [trialDaysLeft, setTrialDaysLeft] = useStateA(_savedCustom.trialDaysLeft || 0);
  // Where the Subscription screen should return to (reachable from both
  // Settings directly and Account and sync → Manage Plus).
  const [subFrom, setSubFrom]     = useStateA('account');
  // Where the Mood player should return to (reachable from the Studio hub
  // and from the "See moods" shortcut inside Dress up Roasty).
  const [moodFrom, setMoodFrom]   = useStateA('studio');
  // The grove has two axes: which botanical variety is planted, and the light
  // it stands in. Old saves held a single conflated "skin" id — migrateGrove splits it.
  const _grove = window.migrateGrove ? window.migrateGrove(_savedCustom) : { variety: 'arabica', light: 'daylight' };
  const [treeId, setTreeId]       = useStateA(_grove.variety);
  const [lightId, setLightId]     = useStateA(_grove.light);
  const [roastyCfg, setRoastyCfg] = useStateA(_savedCustom.roasty || { roast: 'medium', hat: 'none', gear: 'none', sprout: 'leaf' });

  // Mirror to window so every <Roasty/> and <CoffeePersona/> reflects the
  // applied look (set during render so children read current values), and persist.
  window.ROASTY_CONFIG = roastyCfg;
  window.TREE_CONFIG = {
    treatment: window.groveFilter ? window.groveFilter(treeId, lightId) : '',
    shape: window.groveShape ? window.groveShape(treeId) : '',
  };
  useEffectA(() => {
    try { localStorage.setItem('cq-custom', JSON.stringify({ plus: isPlus, trialDaysLeft, subPlan, variety: treeId, light: lightId, roasty: roastyCfg })); } catch (e) {}
  }, [isPlus, trialDaysLeft, subPlan, treeId, lightId, roastyCfg]);

  // ── Plus gating: temporary unlocks, gate sheet, rewarded ad, the gift ──
  // tempUnlocks maps a feature key → expiry timestamp (ms). A feature is open
  // if the user is Plus, or has an unexpired trial for it.
  const [tempUnlocks, setTempUnlocks] = useStateA(() => {
    let s = null; try { s = JSON.parse(localStorage.getItem('cq-temp')); } catch (e) {}
    return (s && typeof s === 'object') ? s : {};
  });
  useEffectA(() => { try { localStorage.setItem('cq-temp', JSON.stringify(tempUnlocks)); } catch (e) {} }, [tempUnlocks]);
  // Tick once a second so trial countdowns + expiries re-render live.
  const [, setNowTick] = useStateA(0);
  useEffectA(() => { const id = setInterval(() => setNowTick(n => n + 1), 1000); return () => clearInterval(id); }, []);

  const featureUnlocked = (key) => {
    // Option A + free Saved tier: in v1 everything that teaches is free, and
    // Saved is a free tier (soft cap), so neither is ever gated.
    if (isV1 && (key === 'dictionary' || key === 'saved')) return true;
    return isPlus || (!!tempUnlocks[key] && tempUnlocks[key] > Date.now());
  };
  const grantTrial = (key, minutes) => setTempUnlocks(u => ({ ...u, [key]: Date.now() + minutes * 60000 }));

  const [gateFeature, setGateFeature] = useStateA(null); // key → PlusGateSheet open
  const [adFeature, setAdFeature]     = useStateA(_route && _route.adFeature ? _route.adFeature : 'dictionary');

  // What each feature key actually does once it's open.
  const runFeature = (key) => {
    if (key === 'dictionary')  { setDictSearchSeed(''); setDictFocus(false); setView('dictionary'); }
    else if (key === 'atlas')  { setTab('atlas'); setView('app'); }
    else if (key === 'duel')   openDuel('hub');
    else if (key === 'saved')  setView('saved');
    else if (key === 'studio') setView('studio');
  };
  // Single funnel: open the feature if allowed, otherwise raise the gate sheet.
  const requestFeature = (key) => { if (featureUnlocked(key)) runFeature(key); else setGateFeature(key); };

  const openCustomize = () => setView('studio');

  // ── Progression state ──
  // Seed points from the real completed-lesson total so the growth tree matches
  // visible progress (only lesson 1 is done → an early sprout, not a full bush).
  // Persisted like every other store, so a challenge card or a favorite can
  // never outlive the lesson that earned it.
  const [progression, setProgression] = useStateA(() => {
    let s = null; try { s = JSON.parse(localStorage.getItem('cq-progress')); } catch (e) {}
    const base = (s && Array.isArray(s.completed))
      ? { streak: s.streak || 0, points: s.points || 0, prevPoints: s.prevPoints || 0,
          completed: new Set(s.completed), bestResults: s.bestResults || {} }
      : SEED_PROGRESSION();
    return base;
  });
  useEffectA(() => {
    try {
      localStorage.setItem('cq-progress', JSON.stringify({
        streak: progression.streak, points: progression.points, prevPoints: progression.prevPoints,
        completed: [...progression.completed], bestResults: progression.bestResults,
      }));
    } catch (e) {}
  }, [progression]);
  // Reward screens show a before → after points count. In a real session that
  // comes from progression; a reward deep link (six of them, app.jsx:99-105)
  // supplies its own fixture pair. Deriving it HERE rather than seeding it into
  // progression is what keeps route fixtures out of storage: nothing
  // route-driven is ever written, so persistence needs no special-casing and
  // every store — including this one — stays clearable by the wipes.
  const rewardPrevPoints = _route && _route.prevPoints != null ? _route.prevPoints : progression.prevPoints;
  const rewardNewPoints  = _route && _route.newPoints  != null ? _route.newPoints  : progression.points;

  // Surface a stable `state` reference for legacy callers (LearnTab, StreakScreen, ProfileTab).
  const state = { streak: progression.streak, points: progression.points };

  // ── Streak freeze ──
  // Earned, scarce, and spent for you: one freeze per 7 consecutive days, at most
  // two held. Miss a day and one is consumed automatically — the streak survives
  // and the day renders as covered in the week strip. Held count is DERIVED from
  // the real streak minus what's been spent, so it can never drift out of step,
  // and resetting progress zeroes it for free. There is no setting: it is a
  // mechanic, not a preference.
  const FREEZE_EARN_DAYS = 7, FREEZE_CAP = 2;
  // Two separate facts, deliberately not one value:
  //   frozenDays   — which days of THIS week a freeze covered. Drives the week
  //                  strip, and clears when the week rolls over.
  //   freezesSpent — how many have ever been spent. Drives the held count, and
  //                  is cleared by Reset progress and Delete account alike
  //                  (both go through wipeProgress).
  // Deriving held from frozenDays.length conflated the two: the moment the week
  // rolled over the strip cleared and every spent freeze was silently refunded.
  const [frozenDays, setFrozenDays] = useStateA([]);
  const [freezesSpent, setFreezesSpent] = useStateA(0);
  const freezesHeld = Math.max(0, Math.min(FREEZE_CAP,
    Math.floor(progression.streak / FREEZE_EARN_DAYS) - freezesSpent));
  const nextFreezeIn = FREEZE_EARN_DAYS - (progression.streak % FREEZE_EARN_DAYS);
  // The save notice rides on the same state as the strip: if a freeze covered a
  // day this week and the user hasn't acknowledged it, the Learn tab says so once.
  const [freezeNoticeSeen, setFreezeNoticeSeen] = useStateA(false);
  const freezeSaved = frozenDays.length > 0 && !freezeNoticeSeen;
  // The earn beat can't be derived here: the prototype's streak is fixed, so no
  // lesson completion crosses a 7-day boundary. Driven from the dev panel.
  const [freezeEarnedBeat, setFreezeEarnedBeat] = useStateA(false);
  // At the cap the earn is absorbed, so the payout row shows nothing rather than
  // announcing a freeze the user never receives. With real streak progression the
  // check belongs on the PRE-earn held count (heldBefore < FREEZE_CAP); the
  // derived value stands in for it here, where the streak never advances.
  const freezeEarnedShown = freezeEarnedBeat && freezesHeld < FREEZE_CAP;

  // Keep the static lesson/module lock flags in step with real progress so the
  // Path, Learn and Module screens unlock the next lesson the moment one is
  // finished, and read the module as complete once every lesson is done.
  // The Progress tweak fast-forwards by injecting Module 1's lessons into the
  // completed set that feeds gating + the collection.
  // A demo seed (Tweaks → Progress → "Demo · all lesson states") that fills the
  // Path with a spread of scores so every state is verifiable without playing
  // through. Percentages, not counts — lesson lengths differ.
  const DEMO_BEST = {
    m1l1: { correct: 3, total: 3 }, // 100% → Perfect (full bean, no label)
    m1l2: { correct: 4, total: 5 }, // 80%  → Solid, at the pass mark
    m1l3: { correct: 2, total: 4 }, // 50%  → Needs Practice (amber + chip)
    m2l1: { correct: 2, total: 3 }, // 67%  → Needs Practice (below the pass mark)
  };
  const effectiveCompleted = React.useMemo(() => {
    if (t.progress === 'm1-complete' && window.MODULES && window.MODULES[0]) {
      const ids = new Set(progression.completed);
      window.MODULES[0].lessons.forEach(lesson => ids.add(lesson.id));
      return ids;
    }
    if (t.progress === 'states-demo') {
      return new Set([...progression.completed, ...Object.keys(DEMO_BEST)]);
    }
    if (t.progress === 'all-unlocked' && window.MODULES) {
      const ids = new Set(progression.completed);
      window.MODULES.forEach(mod => mod.lessons.forEach(lesson => ids.add(lesson.id)));
      return ids;
    }
    return progression.completed;
  }, [t.progress, progression.completed]);
  const effectiveBest = React.useMemo(() => {
    if (t.progress === 'states-demo') return { ...progression.bestResults, ...DEMO_BEST };
    return progression.bestResults;
  }, [t.progress, progression.bestResults]);
  if (window.syncModuleProgress) window.syncModuleProgress(effectiveCompleted);
  if (window.syncMastery) window.syncMastery(effectiveBest);
  // Same for the collectible cards: each lesson card unlocks with its lesson,
  // and the module Field Guide card unlocks when the whole module is done.
  if (window.syncCollection) window.syncCollection(effectiveCompleted);

  // ── Perfect-module gift tracking ──
  // perfectLessons = lessons finished with every quiz answered correctly.
  // giftedModules  = modules whose Roasty gift has already been offered.
  const [perfectLessons, setPerfectLessons] = useStateA(() => new Set());
  const [giftedModules, setGiftedModules]   = useStateA(() => new Set());
  const [giftModule, setGiftModule]         = useStateA(null);

  // ── Active Brew Challenge state ──
  // A single active challenge (activeId + startedAt); a set of completed ids
  // (each unlocks a card stamp). Skipping/expiry just clears the active one —
  // no archive, no penalty. Persisted across refreshes.
  const [brew, setBrew] = useStateA(() => {
    let stored = null; try { stored = JSON.parse(localStorage.getItem('cq-brew')); } catch (e) {}
    if (stored && Array.isArray(stored.completed)) return { activeId: stored.activeId || null, startedAt: stored.startedAt || null, completed: new Set(stored.completed), saved: new Set(Array.isArray(stored.saved) ? stored.saved : []) };
    const _brewDemo = _initial && ['card-stamp', 'card-stamp-locked', 'path-challenge', 'path-challenge-open', 'today-challenge-done'].indexOf(_initial) >= 0;
    return { ...EMPTY_BREW(), completed: new Set(_brewDemo ? ['bc-m1l1'] : []) };
  });
  useEffectA(() => {
    try { localStorage.setItem('cq-brew', JSON.stringify({ activeId: brew.activeId, startedAt: brew.startedAt, completed: [...brew.completed], saved: [...brew.saved] })); } catch (e) {}
  }, [brew]);
  const [justLoggedId, setJustLoggedId] = useStateA(null); // ephemeral 'completed' card on Today
  const [justLoggedPoints, setJustLoggedPoints] = useStateA(true); // whether that completion earned points (first time only)
  const [logSheetId, setLogSheetId]     = useStateA(_route && _route.logSheet ? 'bc-m1l2' : null); // Log Result sheet target
  const [brewRecap, setBrewRecap]       = useStateA(null); // read-only recap for a completed challenge
  // Active only within the 48h window; past that it silently drops off Today.
  const brewActiveId = (brew.activeId && brew.startedAt && (Date.now() - brew.startedAt) <= (window.BREW_WINDOW_MS || 1)) ? brew.activeId : null;
  // Start (or replay) a challenge. Replaying a completed one is allowed and
  // unlimited — it never affects points, module progress, or the earned stamp. A
  // completed challenge only returns to Today when the user explicitly asks
  // (via the recap sheet); it never resurfaces on its own.
  // Starting a challenge makes it active and clears it from the saved queue.
  // If a different, uncompleted challenge was active, park it back into saved
  // (same rule as "Save for later") instead of silently dropping it.
  const startBrew = (id) => {
    if (!id) return;
    setJustLoggedId(null);
    setBrew(prev => {
      const saved = new Set(prev.saved);
      saved.delete(id);
      if (prev.activeId && prev.activeId !== id && !prev.completed.has(prev.activeId)) saved.add(prev.activeId);
      return { ...prev, activeId: id, startedAt: Date.now(), saved };
    });
  };
  // "Save for later": park the active challenge into the saved queue (unless it's
  // already completed — replays don't re-queue) and clear it off Today.
  const skipBrew = () => setBrew(prev => {
    const saved = new Set(prev.saved);
    if (prev.activeId && !prev.completed.has(prev.activeId)) saved.add(prev.activeId);
    return { ...prev, activeId: null, startedAt: null, saved };
  });
  // Explicit save without starting (from the lesson-complete suggestion).
  // A challenge can only be saved once its source lesson has been reached.
  const brewReached = (id) => {
    const challenge = window.brewById && window.brewById(id);
    if (!challenge) return false;
    if (challenge.type === 'module') {
      const mod = MODULES.find(m => m.id === challenge.moduleId);
      return !!mod && mod.lessons.every(lesson => lesson.status === 'complete');
    }
    if (!challenge.lessonId) return false;
    const context = window.findLessonContext && window.findLessonContext(challenge.lessonId);
    return !!context && context.lesson.status === 'complete';
  };
  const saveBrew = (id) => {
    if (!id || !brewReached(id)) return;
    setBrew(prev => {
      if (prev.completed.has(id)) return prev;
      const saved = new Set(prev.saved);
      saved.add(id);
      return { ...prev, saved };
    });
  };
  const unsaveBrew = (id) => setBrew(prev => {
    const saved = new Set(prev.saved);
    saved.delete(id);
    return { ...prev, saved };
  });
  const logBrewDone = (id) => {
    setBrew(prev => {
      const completed = new Set(prev.completed);
      completed.add(id);
      const saved = new Set(prev.saved);
      saved.delete(id);
      return { ...prev, activeId: null, startedAt: null, completed, saved };
    });
    setLogSheetId(null);
    setJustLoggedId(id);
  };
  // Complete from the Log Result reflection sheet: record the stamp and award
  // +5 PTS — but only on the FIRST completion; replays re-stamp nothing.
  const completeBrew = (id) => {
    if (!id) return;
    const first = !brew.completed.has(id);
    setBrew(prev => {
      const saved = new Set(prev.saved);
      saved.delete(id);
      if (prev.completed.has(id)) return { ...prev, activeId: null, startedAt: null, saved };
      const completed = new Set(prev.completed);
      completed.add(id);
      return { ...prev, activeId: null, startedAt: null, completed, saved };
    });
    setJustLoggedId(id);
    setJustLoggedPoints(first);
    if (first) setProgression(p => ({ ...p, prevPoints: p.points, points: p.points + 5 }));
  };

  // Apply theme/voice/cadence to the document root. The theme preference owns
  // the light↔dark axis: dark = 'dark-roast', light = 'cupping'.
  useEffectA(() => {
    const root = document.documentElement;
    root.setAttribute('data-voice',   t.voice);
    root.toggleAttribute('data-path-compact', true);
    const isDark = themePref === 'dark' || (themePref === 'system' && systemDark);
    if (isDark) {
      root.setAttribute('data-mood', 'dark-roast');
    } else {
      root.setAttribute('data-mood', 'cupping');
    }
  }, [t.voice, themePref, systemDark]);

  // In v1 the Atlas tab doesn't exist — if a deep link lands us on it, fall back
  // to Learn so we're never stranded on a hidden tab.
  useEffectA(() => { if (tab === 'atlas') setTab('learn'); }, [tab]);

  // Track the active tab's scroll so the shared AppHeader can collapse from a
  // large title into a compact, blurred sticky bar (iOS large-title pattern).
  const [headerScrolled, setHeaderScrolled] = useStateA(false);
  useEffectA(() => {
    if (view !== 'app') { setHeaderScrolled(false); return; }
    const el = document.querySelector('#screenArea .screen .scroll');
    if (!el) { setHeaderScrolled(false); return; }
    // Reveal the compact bar only once the large in-flow title has fully scrolled
    // behind the 116px header — otherwise both titles show at once (duplicate).
    const onScroll = () => setHeaderScrolled(el.scrollTop > 72);
    onScroll();
    el.addEventListener('scroll', onScroll, { passive: true });
    return () => el.removeEventListener('scroll', onScroll);
  }, [view, tab, isV1]);

  // ── Flow helpers ──
  const isLessonComplete = (id) => {
    if (progression.completed.has(id)) return true;
    const ctx = window.findLessonContext(id);
    return !!(ctx && ctx.lesson.status === 'complete');
  };

  const startLesson = (id) => {
    setActiveLessonId(id);
    setReviewActive(false);
    setProgression(p => ({ ...p, prevPoints: p.points }));
    setView('lesson');
  };

  // Open a lesson from a list. Completed lessons go through a review-confirm
  // sheet first (no new points); fresh lessons start immediately.
  const openLesson = (id) => {
    if (isLessonComplete(id)) setReviewLessonId(id);
    else startLesson(id);
  };

  // Confirmed from the review sheet → replay in review mode (no points, no reward).
  const startReview = () => {
    const id = reviewLessonId;
    setReviewLessonId(null);
    setActiveLessonId(id);
    setReviewActive(true);
    setView('lesson');
  };

  const openSaved = () => setView('saved');
  // Only lessons / terms / guides surface in the Saved screen, so the
  // header badge + counts must ignore other favorite keys (e.g. cards).
  const savedCount = [...favorites].filter(k => /^(l|t|g):/.test(k)).length;
  const savedTermCount = [...favorites].filter(k => k.indexOf('t:') === 0).length;

  // Set of learned term ids, derived from completed lessons (+ a demo seed).
  const learnedSet = React.useMemo(
    () => (window.learnedTermSet ? window.learnedTermSet(progression.completed) : new Set()),
    [progression.completed]
  );

  const openDictionary = (opts) => {
    setDictSearchSeed(opts && opts.search ? opts.search : '');
    setDictFocus(!!(opts && opts.focus));
    setView('dictionary');
  };
  // Open a full term entry, remembering where we came from.
  const openTermFull = (id) => {
    recordRecent(id);
    if (view !== 'term') setTermReturn({ view, tab, lessonId: activeLessonId });
    setActiveTermId(id);
    setTermPeek(null);
    setView('term');
  };
  // Compact, non-interrupting peek (used inside lessons).
  const openTermPeek = (id) => { recordRecent(id); setTermPeek(id); };
  // Root-level sheets outlive the screen they were opened from, so any
  // navigation out (saving past the free cap → gate → paywall, a deep link, a
  // back-out) would leave one floating on the sheet layer above the new screen.
  // One place closes them all; each is scoped to the view it belongs to.
  useEffectA(() => {
    if (view !== 'lesson' && termPeek) setTermPeek(null);
    if (view !== 'app') {
      if (sheetOpen) closeCardSheet();
      if (logSheetId) setLogSheetId(null);
      if (brewRecap) setBrewRecap(null);
      if (reviewLessonId) setReviewLessonId(null);
    }
  }, [view]);
  const closeTerm = () => {
    const origin = termReturn;
    setTermReturn(null);
    if (origin) { setActiveLessonId(origin.lessonId || activeLessonId); setTab(origin.tab || tab); setView(origin.view || 'app'); }
    else { setTab('learn'); setView('app'); }
  };

  const onLessonComplete = (lesson, meta) => {
    const id = activeLessonId;
    // Record the best-ever result for this lesson (never downgrade). Runs for
    // BOTH first completions and replays, so a replay can improve mastery even
    // though it grants no points and skips the reward screen.
    if (id && meta && meta.total > 0) {
      setProgression(p => {
        const prev = (p.bestResults && p.bestResults[id]) || null;
        const prevRatio = prev ? prev.correct / prev.total : -1;
        const nextRatio = meta.correct / meta.total;
        if (nextRatio <= prevRatio) return p; // worse-or-equal replay: keep best
        return { ...p, bestResults: { ...p.bestResults, [id]: { correct: meta.correct, total: meta.total } } };
      });
    }
    // Review replays don't grant points or route into the reward screens — they
    // just return you to wherever you opened the lesson from.
    if (reviewActive) {
      setReviewActive(false);
      setView('app');
      return;
    }
    // Remember a flawless run for the perfect-module gift.
    if (meta && meta.perfect) setPerfectLessons(prev => { const next = new Set(prev); next.add(id); return next; });
    const ctx = window.findLessonContext(id);
    // Best result to display + the derived lesson state (uses best-ever, so a
    // strong first run shows Mastered even if this exact run was weaker).
    const prevBest = (progression.bestResults && progression.bestResults[id]) || null;
    let result = prevBest;
    if (meta && meta.total > 0) {
      const prevRatio = prevBest ? prevBest.correct / prevBest.total : -1;
      const thisRatio = meta.correct / meta.total;
      result = thisRatio >= prevRatio ? { correct: meta.correct, total: meta.total } : prevBest;
    }
    const fullLesson = { ...(lesson || {}), id, result, lessonState: window.lessonStateFromResult(result) };
    setCompletedLesson(fullLesson);
    // Points = effort + habit: the lesson's authored payout on a FIRST completion.
    // Replays return early above (+0); Perfect earns no bonus — mastery is the
    // reward there. data.jsx is the only place the number is written.
    const earned = (lesson && lesson.points) || 10;
    setProgression(p => {
      const nextPoints = p.points + earned;
      const completed = new Set(p.completed);
      completed.add(id);
      return { ...p, prevPoints: p.points, points: nextPoints, completed };
    });
    // Route into the right reward screen.
    if (ctx && ctx.isLastInModule) {
      setView('module-complete');
    } else {
      setView('lesson-complete');
    }
  };

  // From LessonComplete → start the next lesson directly, but only if it has a
  // real body. In this build not every lesson is authored yet; advancing into an
  // unbuilt lesson would render a blank player, so fall back to the Path instead.
  const continueFromLessonComplete = () => {
    const nextId = window.findNextLessonId(completedLesson.id);
    const playable = !!(nextId && window.LESSONS && window.LESSONS[nextId]);
    if (playable) startLesson(nextId);
    else { setView('app'); setTab('path'); }
  };

  // From ModuleComplete → go to module reward card.
  const continueFromModuleComplete = () => setView('module-card');

  // From ModuleReward → offer the Module Brew Challenge (if any), else advance.
  const continueFromModuleReward = () => {
    const ctx = completedLesson ? window.findLessonContext(completedLesson.id) : null;
    const mod = ctx ? ctx.module : null;
    if (mod && window.brewForModule && window.brewForModule(mod.id)) { setView('module-challenge'); return; }
    advanceAfterModule();
  };

  // The original post-module routing (gift or next module / Path).
  const advanceAfterModule = () => {
    const ctx = window.findLessonContext(completedLesson.id);
    const mod = ctx ? ctx.module : null;
    // The perfect-module gift rides on the rewarded-trial layer, which is a v2
    // feature. In v1 a flawless module is rewarded with an earned stamp instead.
    if (mod && !isPlus && !isV1 && !giftedModules.has(mod.id) &&
        mod.lessons.length > 0 && mod.lessons.every(l => perfectLessons.has(l.id))) {
      setGiftModule(mod);
      setView('roasty-gift');
      return;
    }
    // Only advance into the next module if its first lesson is actually authored;
    // otherwise (v2 modules aren't built yet) land back on the Path, where Beans
    // now reads as complete and its module challenge is available.
    const nextId = window.findNextModuleFirstLesson(completedLesson.id);
    const playable = !!(nextId && window.LESSONS && window.LESSONS[nextId]);
    if (playable) startLesson(nextId);
    else { setView('app'); setTab('path'); }
  };

  // From the Roasty gift → either claim a temporary Studio unlock, or move on.
  const proceedAfterGift = () => {
    const id = giftModule ? giftModule.id : null;
    if (id) setGiftedModules(prev => { const next = new Set(prev); next.add(id); return next; });
    const nextId = completedLesson ? window.findNextModuleFirstLesson(completedLesson.id) : null;
    if (nextId) startLesson(nextId);
    else { setView('app'); setTab('path'); }
  };
  const claimRoastyGift = () => {
    if (giftModule) setGiftedModules(prev => { const next = new Set(prev); next.add(giftModule.id); return next; });
    grantTrial('studio', window.TRIAL_GIFT_MIN || 1440);
    setView('studio');
  };

  const backToPath = () => {
    setActiveLessonId(null); setCompletedLesson(null);
    setView('app'); setTab('path');
  };

  // ── The store registry ──────────────────────────────────────
  // Every account-scoped store is listed here ONCE, with its scope and how to
  // clear it. The wipes iterate this table rather than naming stores by hand,
  // which is what let three stores go unwiped. Adding a store to the app means
  // adding a row here; the dev guard below catches it if you forget.
  //   'progress' — cleared by Reset progress AND Delete account
  //   'account'  — cleared by Delete account only (a purchase or a preference)
  const ACCOUNT_STORES = [
    { key: 'cq-progress',      scope: 'progress', reset: () => setProgression(EMPTY_PROGRESSION()) },
    { key: 'cq-brew',          scope: 'progress', reset: () => setBrew(EMPTY_BREW()) },
    // Saved content and the Atlas passport are progress too: a favorited lesson
    // that has re-locked, or a passport stamp for an origin you no longer know,
    // are records of work that was just undone.
    { key: 'cq-favorites',     scope: 'progress', reset: () => setFavorites(new Set()) },
    { key: 'cq-atlas',         scope: 'progress', reset: () => setAtlasData({ states: {}, favs: [], tastedFrom: {} }) },
    { key: 'cq-recent-terms',  scope: 'progress', reset: () => setRecentTerms([]) },
    // Duel keeps its own store so a half-finished round survives a refresh.
    { key: 'cq-duel-progress', scope: 'progress', reset: () => window.clearDuelProgress && window.clearDuelProgress() },
    // In-memory only (no key), but still progress that must go with the rest.
    { key: null, scope: 'progress', reset: () => { setFrozenDays([]); setFreezesSpent(0); setFreezeNoticeSeen(false); } },
    { key: 'cq-temp',          scope: 'account',  reset: () => setTempUnlocks({}) },
    { key: 'cq-custom',        scope: 'account',  reset: () => {
      setIsPlus(false); setTrialDaysLeft(0);
      setTreeId('arabica'); setLightId('daylight');
      setRoastyCfg({ roast: 'medium', hat: 'none', gear: 'none', sprout: 'leaf' });
    } },
    // cq-theme is deliberately absent: appearance is a device preference, not
    // account data, and survives both wipes.
  ];
  const wipeStores = (scopes) => ACCOUNT_STORES.forEach(s => { if (scopes.indexOf(s.scope) >= 0) s.reset(); });
  // Dev guard: watch what the app actually WRITES and complain if a key isn't in
  // the table. This is the check that makes the registry worth having — without
  // it the table is just a tidier hand-list. Watching writes rather than reading
  // existing keys means no false alarms from stale keys or from other documents
  // on this origin (Coffee Tree.html owns cq-tree-modules, for instance).
  useEffectA(() => {
    let restore = null;
    try {
      const known = new Set(ACCOUNT_STORES.map(s => s.key).filter(Boolean).concat(['cq-theme']));
      const seen = new Set();
      const native = localStorage.setItem.bind(localStorage);
      localStorage.setItem = function (k, v) {
        if (String(k).indexOf('cq-') === 0 && !known.has(k) && !seen.has(k)) {
          seen.add(k);
          console.warn('[stores] "' + k + '" is written but not registered in ACCOUNT_STORES — Reset progress and Delete account will miss it.');
        }
        return native(k, v);
      };
      restore = () => { localStorage.setItem = native; };
    } catch (e) {}
    return () => { if (restore) restore(); };
  }, []);

  const wipeProgress = () => wipeStores(['progress']);
  // Reset progress — clears the trail. Completed core lessons drive the tree, so
  // zeroing them returns the grove to a bare seed. Plus and the trial are a
  // purchase, not progress, so they survive. Lands the user back on their profile.
  const resetProgress = () => {
    wipeProgress();
    setTab('profile'); setView('app');
  };
  // Delete account — permanent, per spec: no recovery period, nothing to
  // restore. Clears every store in the registry, both scopes, so no personal
  // state survives into the next signed-out session. Signs out to the welcome
  // screen, no success modal.
  const deleteAccount = () => {
    wipeStores(['progress', 'account']);
    setView('onboarding-1');
  };
  const openCardSheet = (card) => { setOpenCard(card); setSheetOpen(true); };
  const closeCardSheet = () => {
    setSheetOpen(false);
    setTimeout(() => setOpenCard(null), 280);
  };

  // ── Active Brew Challenge — derived review state ──
  // Both of these were once tweaks; they are now route-only, and the keys were
  // removed from TWEAK_DEFAULTS rather than left sitting there unread.
  // brewTodayMode: a screens-overview route can pin the Today card to a state
  // ('active' | 'completed' | 'none') so each one is reachable as its own tile.
  // Everywhere else it is 'auto' and follows live state.
  const brewTodayMode = (_route && _route.brewToday) || 'auto';
  // brewPathMode: the same idea for the Path row's challenge pip. No route sets
  // it today, so it is always 'auto' — kept as a named const because PathTab
  // takes it as a prop and 'auto' is the meaningful value, not a placeholder.
  const brewPathMode  = 'auto';
  let todayCh = null, todayMode = null;
  if (brewTodayMode === 'active')         { todayMode = 'active';    todayCh = window.brewById('bc-m1l2'); }
  else if (brewTodayMode === 'completed') { todayMode = 'completed'; todayCh = window.brewById('bc-m1l2'); }
  else if (brewTodayMode === 'none')      { todayMode = null; }
  else { // auto — real state
    // A replayed challenge (even an already-completed one) is set active via
    // startBrew and shows here in active mode. justLoggedId is the transient
    // just-finished confirmation immediately after logging.
    if (brewActiveId)      { todayMode = 'active';    todayCh = window.brewById(brewActiveId); }
    else if (justLoggedId) { todayMode = 'completed'; todayCh = window.brewById(justLoggedId); }
  }
  const onBrewTry = (ch) => { startBrew(ch.id); closeCardSheet(); setTab('learn'); setView('app'); };

  // ── Render screens ──
  let body;
  if (view === 'anim') {
    body = <RoastyAnimScreen state={_animState || 'idle'}/>;
  } else if (view === 'loading') {
    body = <RoastyLoadingScreen onDone={() => setView('onboarding-1')}/>;
  } else if (view === 'onboarding-1') {
    body = <OnboardingWelcome onNext={() => setView('onboarding-meet')}/>;
  } else if (view === 'onboarding-meet') {
    // v1 hides the personalization question flow entirely: the user is met
    // (Welcome), promised (Meet Roasty), then dropped straight onto Today.
    body = <OnboardingRoasty
      isV1={isV1}
      onStart={() => {
        if (isV1) { setView('app'); setTab('learn'); }
        else { setOnbStart('expectation'); setView('onboarding-flow'); }
      }}
      onSkip={() => { setView('app'); setTab('learn'); }}
    />;
  } else if (view === 'onboarding-flow') {
    // The v1 cut never routes here (Meet Roasty goes straight to Learn), so this
    // is the deep-linked review path: pin it to Standard, the depth v2 will ship.
    const onbT = isV1 ? { ...t, flowDepth: 'standard' } : t;
    body = <OnboardingFlow
      initialSlug={onbStart}
      t={onbT}
      onBack={() => setView('onboarding-meet')}
      onExit={() => { setView('app'); setTab('learn'); }}
    />;
  } else if (view === 'lesson' && activeLessonId) {
    body = <LessonPlayer
      lessonId={activeLessonId}
      startKind={lessonStartKind}
      isFav={favorites.has('l:' + activeLessonId)}
      onToggleFav={() => toggleFavorite('l:' + activeLessonId)}
      favorites={favorites}
      onToggleFavKey={toggleFavorite}
      onTermTap={openTermPeek}
      onClose={() => { setReviewActive(false); setView('app'); }}
      onComplete={onLessonComplete}
    />;
  } else if (view === 'saved') {
    body = <SavedScreen
      favorites={favorites}
      savedMax={SAVED_FREE_MAX}
      isPlus={isPlus}
      onUpgrade={() => setView('paywall')}
      onToggleFav={toggleFavorite}
      onLesson={openLesson}
      onOpenGuide={(variant) => { const card = window.findTrainingCard && window.findTrainingCard(variant); if (card) openCardSheet(card); }}
      onOpenTerm={openTermFull}
      onFlashcards={() => { setFlashBack('saved'); setView('flashcards'); }}
      onClose={() => { setView('app'); }}
    />;
  } else if (view === 'lesson-complete' && completedLesson) {
    const _newCore = window.coreDoneCount(effectiveCompleted);
    body = <LessonCompleteScreen
      freezeEarned={freezeEarnedShown}
      lesson={completedLesson}
      fromStage={window.treeStageFromCore(Math.max(0, _newCore - 1))}
      toStage={window.treeStageFromCore(_newCore)}
      result={completedLesson.result}
      lessonState={completedLesson.lessonState}
      onPractice={() => { setActiveLessonId(completedLesson.id); setReviewActive(true); setView('lesson'); }}
      prevPoints={rewardPrevPoints}
      newPoints={rewardNewPoints}
      nextPlayable={(() => { const nextId = window.findNextLessonId(completedLesson.id); return !!(nextId && window.LESSONS && window.LESSONS[nextId]); })()}
      brewChallenge={window.brewForLesson(completedLesson.id)}
      brewChallengeState={(() => { const ch = window.brewForLesson(completedLesson.id); if (!ch) return null; if (brewActiveId === ch.id) return 'active'; if (brew.completed.has(ch.id)) return 'completed'; if (brew.saved.has(ch.id)) return 'saved'; return null; })()}
      onStartChallenge={() => { const ch = window.brewForLesson(completedLesson.id); if (ch) startBrew(ch.id); setView('app'); setTab('learn'); }}
      onNotNowChallenge={() => { const ch = window.brewForLesson(completedLesson.id); if (ch) saveBrew(ch.id); continueFromLessonComplete(); }}
      onContinue={continueFromLessonComplete}
      onDuel={isV1 ? undefined : () => openDuel('pick')}
      onBack={backToPath}
    />;
  } else if (view === 'module-complete' && completedLesson) {
    const ctx = window.findLessonContext(completedLesson.id);
    const mod = ctx ? ctx.module : MODULES[0];
    const reward = MODULE_REWARDS[mod.id] || MODULE_REWARDS.m1;
    const _newCore = window.coreDoneCount(effectiveCompleted);
    body = <ModuleCompleteScreen
      module={mod}
      fromStage={window.treeStageFromCore(Math.max(0, _newCore - 1))}
      toStage={window.treeStageFromCore(_newCore)}
      prevPoints={rewardPrevPoints}
      newPoints={rewardNewPoints}
      reward={reward}
      hasNext={ctx && !ctx.isLastModule}
      onContinue={continueFromModuleReward}
      onBack={backToPath}
    />;
  } else if (view === 'module-card' && completedLesson) {
    const ctx = window.findLessonContext(completedLesson.id);
    const mod = ctx ? ctx.module : MODULES[0];
    const reward = MODULE_REWARDS[mod.id] || MODULE_REWARDS.m1;
    body = <ModuleRewardCardScreen
      module={mod}
      reward={reward}
      hasNext={ctx && !ctx.isLastModule}
      onContinue={continueFromModuleReward}
      onBack={backToPath}
    />;
  } else if (view === 'module-challenge' && completedLesson) {
    const ctx = window.findLessonContext(completedLesson.id);
    const mod = ctx ? ctx.module : MODULES[0];
    const moduleChallenge = window.brewForModule(mod.id);
    body = <window.ModuleChallengeScreen
      module={mod} challenge={moduleChallenge}
      onStart={() => { if (moduleChallenge) startBrew(moduleChallenge.id); setView('app'); setTab('learn'); }}
      onNotNow={() => { if (moduleChallenge) saveBrew(moduleChallenge.id); advanceAfterModule(); }}
      onBack={backToPath}/>;
  } else if (view === 'game-intro' && activeGame) {
    body = <GameIntroScreen
      game={activeGame}
      onStart={() => setView('mini-game')}
      onClose={() => { setActiveGame(null); setView('app'); setTab('learn'); }}
    />;
  } else if (view === 'mini-game' && activeGame) {
    body = <window.MiniGamePlayer
      game={activeGame}
      onClose={() => { setActiveGame(null); setView('app'); setTab('learn'); }}
    />;
  } else if (view === 'dictionary') {
    body = <DictionaryHome
      learnedSet={learnedSet}
      favorites={favorites}
      savedTermCount={savedTermCount}
      initialQuery={dictSearchSeed}
      focusSearch={dictFocus}
      onOpenTerm={openTermFull}
      onToggleFav={toggleFavorite}
      onTermOfDay={() => setView('term-of-day')}
      onFlashcards={() => { setFlashBack('dictionary'); setView('flashcards'); }}
      onVocabGame={() => setView('vocab-game')}
      onClose={() => { setTab('learn'); setView('app'); }}/>;
  } else if (view === 'term') {
    body = <TermDetail
      termId={activeTermId}
      learnedSet={learnedSet}
      learned={learnedSet.has(activeTermId)}
      isFav={favorites.has('t:' + activeTermId)}
      onToggleFav={() => toggleFavorite('t:' + activeTermId)}
      onOpenTerm={openTermFull}
      onLesson={(id) => { setTermReturn(null); openLesson(id); }}
      onClose={closeTerm}/>;
  } else if (view === 'term-of-day') {
    const tod = window.dictTermOfDay ? window.dictTermOfDay() : null;
    body = <TermOfDayScreen
      isFav={tod ? favorites.has('t:' + tod.id) : false}
      onToggleFav={() => tod && toggleFavorite('t:' + tod.id)}
      onOpenFull={openTermFull}
      onClose={() => { setTab('learn'); setView('app'); }}/>;
  } else if (view === 'flashcards') {
    body = <FlashcardsScreen
      favorites={favorites}
      onOpenTerm={openTermFull}
      onBrowse={() => setView('dictionary')}
      onClose={() => setView(flashBack === 'saved' ? 'saved' : 'dictionary')}/>;
  } else if (view === 'vocab-game') {
    body = <VocabGameScreen
      favorites={favorites}
      onOpenTerm={openTermFull}
      onClose={() => setView('dictionary')}/>;
  } else if (view === 'streak') {
    body = <StreakScreen
      streak={state.streak}
      frozenDays={frozenDays}
      freezesHeld={freezesHeld}
      freezeCap={FREEZE_CAP}
      nextFreezeIn={nextFreezeIn}
      onClose={() => setView('app')}
      onContinue={() => setView('app')}
    />;
  } else if (view === 'tree') {
    body = <TreeScreen
      stage={window.treeStageFromCore(window.coreDoneCount(effectiveCompleted))}
      coreDone={window.coreDoneCount(effectiveCompleted)}
      coreTotal={window.CORE_TOTAL}
      onClose={() => { setTab('profile'); setView('app'); }}
    />;
  } else if (view === 'settings') {
    const STAGE_NAMES = ['seed', 'sprout', 'seedling', 'young tree', 'flowering', 'fruiting', 'harvest'];
    body = <SettingsScreen
      theme={themePref}
      onTheme={setTheme}
      onClose={() => { setTab('profile'); setView('app'); }}
      onAbout={() => setView('about')}
      onAccount={() => setView('account')}
      onSubscription={() => { setSubFrom('settings'); setView('subscription'); }}
      onHelp={() => setView('help')}
      showDataExport={!isV1}
      isPlus={isPlus}
      inTrial={trialDaysLeft > 0}
      onReset={resetProgress}
      onDeleteAccount={deleteAccount}
      progressSummary={[
        { label: 'Daily streak', value: progression.streak + (progression.streak === 1 ? ' day' : ' days') },
        { label: 'Points earned', value: progression.points + ' pts' },
        { label: 'Lessons completed', value: String(progression.completed.size) },
        { label: 'Cards collected', value: COLLECTION.filter(c => c.earned).length + ' of ' + COLLECTION.length },
        { label: 'Brew challenges', value: brew.completed.size + ' of ' + window.BREW_TOTAL },
        { label: 'Saved items', value: String(savedCount) },
        { label: 'Your coffee tree', value: 'Back to ' + (STAGE_NAMES[0]) },
      ]}
    />;
  } else if (view === 'about') {
    body = <AboutScreen onClose={() => setView('settings')}/>;
  } else if (view === 'help') {
    body = <HelpSupportScreen onClose={() => setView('settings')}/>;
  } else if (view === 'account') {
    body = <AccountSyncScreen
      isPlus={isPlus}
      inTrial={trialDaysLeft > 0}
      onClose={() => setView('settings')}
      onManagePlan={() => { setSubFrom('account'); setView('subscription'); }}
      onSignOut={() => setView('settings')}
    />;
  } else if (view === 'subscription') {
    const renews = subPlan === 'monthly' ? '18 Jul 2026' : '18 Jun 2027';
    // Frozen "today" (Fri 8 May 2026) + days remaining, formatted like renews.
    const chargeDate = new Date(2026, 4, 8 + trialDaysLeft)
      .toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
    body = <SubscriptionScreen
      isPlus={isPlus}
      plan={subPlan}
      renews={renews}
      trialDaysLeft={trialDaysLeft}
      chargeDate={chargeDate}
      onClose={() => setView(subFrom)}
      onUpgrade={() => setView('paywall')}
      onChangePlan={(p) => setSubPlan(p)}
      onCancel={() => { setIsPlus(false); setTrialDaysLeft(0); setView(subFrom); }}
      restoreOutcome={t.restoreOutcome}
      onRestored={() => { setIsPlus(true); setTrialDaysLeft(0); }}
    />;
  } else if (view === 'paywall') {
    body = <PaywallScreen
      showMoodPlayer={!isV1}
      onSubscribe={(plan) => { setSubPlan(plan); setIsPlus(true); setTrialDaysLeft(TRIAL_DAYS); setView('plus-welcome'); }}
      onClose={() => { setTab('profile'); setView('app'); }}
    />;
  } else if (view === 'plus-welcome') {
    body = <PlusWelcomeScreen
      onOpenStudio={() => setView('studio')}
      onClose={() => { setTab('profile'); setView('app'); }}
    />;
  } else if (view === 'studio') {
    body = featureUnlocked('studio') ? (
      <StudioHub
        roastyCfg={roastyCfg} treeId={treeId} lightId={lightId}
        showMoodPlayer={!isV1}
        onChooseTree={() => setView('tree-chooser')}
        onDressRoasty={() => setView('roasty-studio')}
        onMoodPlayer={() => { setMoodFrom('studio'); setView('mood-player'); }}
        onClose={() => { setTab('profile'); setView('app'); }}
      />
    ) : (
      <div className="screen" data-screen-label="Studio" style={{ background: 'var(--bg)' }}>
        {window.SubScreenHeader && <window.SubScreenHeader scrolled={false} title="" onBack={() => { setTab('profile'); setView('app'); }}/>}
        <window.FeatureLock featureKey="studio" style="curtain" showAd={!isV1}
          onUnlock={() => setView('paywall')}
          preview={(
            <StudioHub
              roastyCfg={roastyCfg} treeId={treeId} lightId={lightId}
              showMoodPlayer={!isV1} chrome={false}
              onChooseTree={() => {}} onDressRoasty={() => {}}
              onMoodPlayer={() => {}} onClose={() => {}}
            />
          )}/>
      </div>
    );
  } else if (view === 'tree-chooser') {
    body = <TreeChooserScreen
      treeId={treeId} lightId={lightId}
      onApply={(v, l) => { setTreeId(v); setLightId(l); setView('studio'); }}
      onClose={() => setView('studio')}
    />;
  } else if (view === 'roasty-studio') {
    body = <RoastyStudio
      roastyCfg={roastyCfg}
      showMoodPlayer={!isV1}
      onApply={(cfg) => { setRoastyCfg(cfg); setView('studio'); }}
      onMoodPlayer={() => { setMoodFrom('roasty-studio'); setView('mood-player'); }}
      onClose={() => setView('studio')}
    />;
  } else if (view === 'mood-player') {
    body = <RoastyMoodScreen
      roastyCfg={roastyCfg}
      onClose={() => setView(isPlus ? moodFrom : 'app')}
    />;
  } else if (view === 'origin') {
    const slug = atlasOriginSlug;
    const originLayout = (_route && _route.view === 'origin' && _route.atlasProfile) ? _route.atlasProfile : t.atlasProfile;
    body = <OriginProfile slug={slug} state={atlasData.states[slug] || 'not-explored'}
      fav={atlasData.favs.indexOf(slug) >= 0} layout={originLayout}
      states={atlasData.states} favs={atlasData.favs}
      onActivity={openAtlasActivity} onToggleFav={atlasToggleFav} onMarkTasted={atlasMarkTasted}
      onClose={() => { setView('app'); setTab('atlas'); }}/>;
  } else if (view === 'atlas-region') {
    body = <RegionScreen regionId={atlasRegionId} states={atlasData.states} favs={atlasData.favs}
      onOpenOrigin={openOrigin} onClose={() => { setView('app'); setTab('atlas'); }}/>;
  } else if (view === 'passport') {
    body = <PassportScreen states={atlasData.states} favs={atlasData.favs} empty={passportEmpty} freshSlug={freshSlug}
      onOpenOrigin={openOrigin} onExplore={() => { setFreshSlug(null); setView('app'); setTab('atlas'); }}
      onClose={() => { setFreshSlug(null); setView('app'); setTab('atlas'); }}/>;
  } else if (view === 'atlas-activity') {
    body = <AtlasActivity origin={window.atlasOrigin(atlasActivitySlug)} states={atlasData.states} favs={atlasData.favs}
      onComplete={(s) => { atlasCompleteActivity(s); setAtlasOriginSlug(s); setView('origin'); }}
      onClose={() => { setView('app'); setTab('atlas'); }}/>;
  } else if (view === 'duel') {
    body = <DuelFlow key={duelKey} initialStage={duelStage}
      tweaks={{ picker: t.duelPicker, reveal: t.duelReveal }}
      onEarnPoints={(n) => setProgression(p => ({ ...p, prevPoints: p.points, points: p.points + n }))}
      onExit={() => { setView('app'); setTab('learn'); }}/>;
  } else if (view === 'rewarded-ad') {
    body = <window.RewardedAdScreen
      featureKey={adFeature}
      minutes={window.TRIAL_AD_MIN || 15}
      onClaim={() => { const feature = adFeature; grantTrial(feature, window.TRIAL_AD_MIN || 15); runFeature(feature); }}
      onClose={() => { setView('app'); }}/>;
  } else if (view === 'roasty-gift') {
    body = <window.RoastyGiftScreen
      module={giftModule || (window.MODULES || [])[0]}
      minutes={window.TRIAL_GIFT_MIN || 1440}
      onPersonalize={claimRoastyGift}
      onLater={proceedAfterGift}/>;
  } else {
    body = (
      <>
        {tab === 'learn'   && <LearnTab freezeSaved={freezeSaved}
                                        freezesHeld={freezesHeld}
                                        nextFreezeIn={nextFreezeIn}
                                        onDismissFreeze={() => setFreezeNoticeSeen(true)}
                                        onLesson={openLesson}
                                        onGame={(g) => { setActiveGame(g); setView('game-intro'); }}
                                        onOpenDuel={() => requestFeature('duel')}
                                        showDuel={!isV1}
                                        brewChallenge={todayCh}
                                        brewMode={todayMode}
                                        brewAutoHide={brewTodayMode === 'auto'}
                                        brewPointsAwarded={justLoggedPoints}
                                        onBrewLog={() => todayCh && setLogSheetId(todayCh.id)}
                                        onBrewSkip={skipBrew}
                                        onBrewDismiss={() => setJustLoggedId(null)}
                                        onBrewCard={openCardSheet}
                                        isLocked={(k) => !featureUnlocked(k)}
                                        brewCompleted={brew.completed}
                                        brewActiveId={brewActiveId}
                                        brewSaved={brew.saved}
                                        onBrewUnsave={unsaveBrew}
                                        onBrewAction={(ch, st) => { if (st === 'completed') { setBrewRecap(ch); return; } startBrew(ch.id); setTab('learn'); setView('app'); }} state={state}/>}
        {tab === 'path'    && <PathTab  onLesson={openLesson}
                                        brewCompleted={brew.completed}
                                        brewActiveId={brewActiveId}
                                        brewSaved={brew.saved}
                                        brewPathMode={brewPathMode}
                                        onBrewAction={(ch, st) => {
                                          // A completed challenge opens a read-only recap; it never restarts.
                                          if (st === 'completed') { setBrewRecap(ch); return; }
                                          startBrew(ch.id); setTab('learn'); setView('app');
                                        }}/>}
        {tab === 'atlas'   && (featureUnlocked('atlas')
                                ? <AtlasMapScreen
                                        states={atlasData.states} favs={atlasData.favs} styleMode={t.atlasMapStyle}
                                        holdLoading={_initial === 'atlas-loading'}
                                        onOpenOrigin={openOrigin} onOpenActivity={openAtlasActivity}
                                        onOpenPassport={openPassport}
                                        onToggleFav={atlasToggleFav} onMarkTasted={atlasMarkTasted}/>
                                : <window.FeatureLock featureKey="atlas" style={t.lockStyle} showAd={!isV1}
                                        onUnlock={() => setGateFeature('atlas')}
                                        preview={t.lockStyle === 'hard' ? null : (
                                          <AtlasMapScreen
                                            states={atlasData.states} favs={atlasData.favs} styleMode={t.atlasMapStyle}
                                            holdLoading={false}
                                            onOpenOrigin={() => {}} onOpenActivity={() => {}}
                                            onOpenPassport={() => {}}
                                            onToggleFav={() => {}} onMarkTasted={() => {}}/>
                                        )}/>)}
        {tab === 'cards'   && <CardsTab onOpen={openCardSheet} brewCompleted={brew.completed}/>}
        {tab === 'profile' && <ProfileTab state={state}
                                          brewDone={brew.completed.size}
                                          brewTotal={window.BREW_TOTAL}
                                          onOpenStreak={() => setView('streak')}
                                          frozenDays={frozenDays}
                                          onOpenTree={() => setView('tree')}
                                          onOpenBrew={() => setTab('path')}
                                          onPractice={() => setTab('path')}
                                          onOpenCustomize={openCustomize}
                                          onOpenSaved={() => requestFeature('saved')}
                                          onOpenDuel={() => requestFeature('duel')}
                                          showDuel={!isV1}
                                          savedCount={savedCount}
                                          isLocked={(k) => !featureUnlocked(k)}/>}
      </>
    );
  }

  const showTabs = view === 'app';
  // Which gated feature is the user currently inside? (for the trial countdown)
  const trialKey =
    (view === 'dictionary' || view === 'term' || view === 'term-of-day' || view === 'flashcards' || view === 'vocab-game') ? 'dictionary'
    : view === 'duel' ? 'duel'
    : view === 'saved' ? 'saved'
    : (view === 'studio' || view === 'tree-chooser' || view === 'roasty-studio' || view === 'mood-player') ? 'studio'
    : (showTabs && tab === 'atlas') ? 'atlas'
    : null;
  const trialUntil = (trialKey && !isPlus && tempUnlocks[trialKey] && tempUnlocks[trialKey] > Date.now()) ? tempUnlocks[trialKey] : null;
  const ConfirmSheetC = window.ConfirmSheet;
  const reviewLesson = reviewLessonId ? findLessonOrPlaceholder(reviewLessonId) : null;
  const reviewCtx = reviewLessonId ? window.findLessonContext(reviewLessonId) : null;
  const reviewTime = reviewLesson && reviewLesson.time ? reviewLesson.time : (reviewCtx ? reviewCtx.lesson.time : 3);
  const reviewCards = reviewLesson && reviewLesson.cards ? reviewLesson.cards.length : 0;

  return (
    <>
      {body}
      {trialUntil && window.TrialBadge && <window.TrialBadge until={trialUntil}/>}
      {window.PlusGateSheet && (
        <window.PlusGateSheet
          featureKey={gateFeature}
          open={!!gateFeature}
          showAd={!isV1}
          onClose={() => setGateFeature(null)}
          onUpgrade={() => { setGateFeature(null); setView('paywall'); }}
          onWatchAd={() => { const feature = gateFeature; setGateFeature(null); setAdFeature(feature); setView('rewarded-ad'); }}/>
      )}
      {window.StampPressOverlay && stampAward && (
        <window.StampPressOverlay origin={window.atlasOrigin(stampAward.slug)} state={stampAward.state}
          hold={!!(_route && _route.stampDemo)}
          onDone={() => setStampAward(null)}/>
      )}
      {showTabs && window.AppHeader && (
        <AppHeader
          tab={tab}
          variant={tab === 'profile' ? 'profile' : 'default'}
          scrolled={headerScrolled}
          onSettings={() => setView('settings')}
          dictLocked={!featureUnlocked('dictionary')}
          onDict={() => requestFeature('dictionary')}
          savedLocked={!featureUnlocked('saved')}
          onSaved={() => requestFeature('saved')}
          savedCount={savedCount}
          showDuel={!isV1}
          duelLocked={!featureUnlocked('duel')}
          duelCount={featureUnlocked('duel') ? (window.DUEL_RECORDS ? window.DUEL_RECORDS.incoming.length : 0) : 0}
          onDuel={() => requestFeature('duel')}/>
      )}
      {showTabs && <TabBar active={tab} onChange={setTab} isV1={isV1}/>}
      <CardSheet card={openCard} open={sheetOpen} onClose={closeCardSheet}
        guideSaved={!!(openCard && openCard.train && favorites.has('g:' + openCard.train))}
        onToggleGuideSave={openCard && openCard.train ? () => toggleFavorite('g:' + openCard.train) : null}
        brewCompleted={(() => { const ch = openCard && window.brewForCard(openCard.id); return !!(ch && brew.completed.has(ch.id)); })()}
        brewActive={(() => { const ch = openCard && window.brewForCard(openCard.id); return !!(ch && brewActiveId === ch.id); })()}
        onBrewTry={onBrewTry}/>

      {window.LogResultSheet && (
        <window.LogResultSheet
          challenge={logSheetId ? window.brewById(logSheetId) : null}
          open={!!logSheetId}
          onClose={() => setLogSheetId(null)}
          onComplete={() => logSheetId && completeBrew(logSheetId)}/>
      )}

      {window.BrewRecapSheet && (
        <window.BrewRecapSheet
          challenge={brewRecap}
          open={!!brewRecap}
          onClose={() => setBrewRecap(null)}
          onReplay={(ch) => { setBrewRecap(null); if (ch) { startBrew(ch.id); setTab('learn'); setView('app'); } }}/>
      )}

      <TermPeekSheet
        termId={termPeek}
        open={!!termPeek}
        learnedSet={learnedSet}
        learned={termPeek ? learnedSet.has(termPeek) : false}
        isFav={termPeek ? favorites.has('t:' + termPeek) : false}
        onToggleFav={() => termPeek && toggleFavorite('t:' + termPeek)}
        onOpenFull={(id) => openTermFull(id)}
        onOpenTerm={(id) => openTermPeek(id)}
        onClose={() => setTermPeek(null)}/>

      {ConfirmSheetC && (
        <ConfirmSheetC
          open={!!reviewLessonId}
          title={reviewLesson ? (reviewLesson.title + '?') : 'Review this lesson?'}
          lines={[
            { label: 'Points and streak', value: 'No change' },
            { label: 'Length', value: '~' + reviewTime + ' min' + (reviewCards ? (', ' + reviewCards + ' cards') : '') },
            { label: 'Last completed', value: 'Today' },
          ]}
          confirmLabel="Review lesson"
          cancelLabel="Not now"
          onConfirm={startReview}
          onClose={() => setReviewLessonId(null)}/>
      )}

      <TweaksPanel title="Tweaks">
        <TweakSection label="Prototype state"/>
        <TweakRadio label="Scope" value={t.scope}
          options={[
            { value: 'v1',         label: 'v1 cut' },
            { value: 'everything', label: 'Everything' },
          ]}
          onChange={(v) => setTweak('scope', v)}/>
        <TweakSelect label="Progress" value={t.progress}
          options={[
            { value: 'default',     label: 'Start — mid module 1' },
            { value: 'states-demo', label: 'Demo of all lesson states' },
            { value: 'm1-complete', label: 'Module 1 fully completed' },
            { value: 'all-unlocked', label: 'All modules unlocked' },
          ]}
          onChange={(v) => setTweak('progress', v)}/>

        <TweakSection label="Streak"/>
        <TweakToggle label="Freeze covered Thursday" value={frozenDays.length > 0}
          onChange={(v) => { setFrozenDays(v ? [3] : []); setFreezesSpent(v ? 1 : 0); setFreezeNoticeSeen(false); }}/>
        <TweakToggle label="Freeze earned this lesson" value={freezeEarnedBeat}
          onChange={(v) => setFreezeEarnedBeat(v)}/>

        <TweakSection label="Customize · Plus"/>
        <TweakToggle label="Plus unlocked" value={isPlus}
          onChange={(v) => setIsPlus(v)}/>
        <TweakSelect label="Restore result" value={t.restoreOutcome}
          options={[
            { value: 'plus',  label: 'Plus restored' },
            { value: 'none',  label: 'Nothing to restore' },
            { value: 'error', label: 'Store unreachable' },
          ]}
          onChange={(v) => setTweak('restoreOutcome', v)}/>
      </TweaksPanel>
    </>
  );
}

// Deep-link helper: synthesize a lesson object for any id so reward screens
// can render even when the lesson body isn't fully defined in LESSONS.
function findLessonOrPlaceholder(id) {
  const ctx = window.findLessonContext(id);
  const base = ctx ? {
    title: ctx.lesson.title,
    points: ctx.lesson.points || 10,
    cards: [],
    reward: { title: ctx.module.title, summary: '', meta: [] },
  } : { title: 'Lesson', points: 10, cards: [], reward: { title: 'Reward', meta: [] } };
  const lesson = LESSONS[id] || base;
  return { ...lesson, id };
}

ReactDOM.createRoot(document.getElementById('screenArea')).render(<App/>);
