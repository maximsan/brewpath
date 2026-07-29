/* ============================================================================
   BrewPath — Design System content
   Pure data + a tiny vanilla renderer. No framework.
   Every entry carries WHERE it is used and the RULE / concept behind it.
   ========================================================================== */

/* -- mini DOM helper -------------------------------------------------------- */
function el(tag, attrs, ...kids) {
  const n = document.createElement(tag);
  if (attrs) for (const k in attrs) {
    if (k === 'html') n.innerHTML = attrs[k];
    else if (k === 'style') n.setAttribute('style', attrs[k]);
    else n.setAttribute(k, attrs[k]);
  }
  for (const c of kids.flat(Infinity)) { if (c == null) continue; n.append(c.nodeType ? c : document.createTextNode(c)); }
  return n;
}
const svg = (vb, inner, sw) =>
  `<svg viewBox="${vb}" fill="none" stroke-width="${sw||1.6}" aria-hidden="true">${inner}</svg>`;

/* ============================================================================
   1 · COLOR
   ========================================================================== */
const COLORS = [
  ['--bg',         'Page canvas',        'The base behind every screen. Nothing sits below it.',                       '#F4EFE6', '#1A130E'],
  ['--surface',    'Raised surface',     'Cards, list rows, MCQ options, sheets — anything that lifts off the canvas.', '#FBF7EE', '#251B14'],
  ['--surface-2',  'Recessed fill',      'Icon wells, card backs, inset thumbnails — one level deeper than surface.',   '#EFE8DA', '#30231A'],
  ['--ink',        'Primary text',       'Body copy, titles, active glyphs. The default foreground.',                   '#1B1614', '#F3E7D2'],
  ['--ink-mute',   'Secondary text',     'Metadata, labels, captions, every inactive icon.',                            '#6B5F54', '#B59E84'],
  ['--rule',       'Hairline',           '1px borders and dividers. The structural grid of the whole UI.',              '#D8CFBF', '#44321E'],
  ['--accent',     'Action / brand',     'The one brand colour — crema orange. Primary buttons, active tab, links, current step, selection, and the needs-practice signal — everything that invites a tap.', '#B8533A', '#E07A4F'],
  ['--accent-ink', 'On-accent text',     'Text and icons that sit ON an accent fill.',                                  '#FBF7EE', '#1A130E'],
  ['--sage',       'Success',            'Correct answers, Learned terms, lessons scored at or above the pass mark, and the Atlas “lesson done” rank — all one idea: learned. Never used for actions.', '#5F6E55', '#97A285'],
  ['--warn',       'Celebration',        'Win crown, fastest answer, streak flame, completion glow. Celebration ONLY — illustrations that need warmth use the --art-* palette below, never this.', '#9A5F1C', '#E6A35C'],
  ['--berry',      'Alert',              'Wrong answers, the cross mark, destructive actions. The only red.',            '#A8362A', '#C75450'],
];

// Literal coffee, for illustration and data art only. These do NOT flip with
// the mood: a ripe cherry is the same colour under any theme. Keeping them
// separate is what lets --warn mean exactly one thing.
const ART = [
  ['--art-raw',         'Green coffee',   'Unroasted bean — the first stage of the roast meter.',              '#9FB088'],
  ['--art-roast-light', 'Light roast',    'Roast-scale art, roast meter, cherry-to-cup diagrams.',                '#C79A63'],
  ['--art-roast-mid',   'Medium roast',   'The middle of any roast ramp; the roast-scale card tint.',              '#A2703C'],
  ['--art-roast-dark',  'Dark roast',     'The dark end of the ramp. Stops short of espresso so it survives the dark mood.', '#54301C'],
  ['--art-ripe',        'Ripe cherry',    'Fruit at harvest, the spectrum card tint — the warmth that used to borrow --warn.', '#C8843A'],
  ['--art-sour',        'Sour axis',      'The sour end of taste diagrams, opposite berry for bitter.',            '#B79A3C'],
];

function renderColors() {
  const grid = el('div', { class: 'swatch-grid' });
  COLORS.forEach(([v, role, usage, light, dark]) => {
    grid.append(el('div', { class: 'swatch' },
      el('div', { class: 'swatch-chip', style: `background: var(${v});` }),
      el('div', { class: 'swatch-body' },
        el('div', { class: 'mono token' }, v),
        el('div', { class: 'swatch-role' }, role),
        el('div', { class: 'swatch-usage' }, usage),
        el('div', { class: 'swatch-hex mono' },
          el('span', null, 'cupping ' + light),
          el('span', null, 'dark-roast ' + dark),
        ),
      ),
    ));
  });
  const artGrid = el('div', { class: 'swatch-grid' });
  ART.forEach(([v, role, usage, hex]) => {
    artGrid.append(el('div', { class: 'swatch' },
      el('div', { class: 'swatch-chip', style: `background: var(${v});` }),
      el('div', { class: 'swatch-body' },
        el('div', { class: 'mono token' }, v),
        el('div', { class: 'swatch-role' }, role),
        el('div', { class: 'swatch-usage' }, usage),
        el('div', { class: 'swatch-hex mono' }, el('span', null, 'both moods ' + hex)),
      ),
    ));
  });
  const wrap = el('div', null,
    grid,
    compSubhead('Illustration palette', 'Literal coffee · same in both moods · never UI meaning'),
    artGrid,
  );
  return section('color', 'Foundations', 'Colour',
    'Eleven UI tokens across two named moods, plus a separate literal palette for illustration. Both moods carry the same eleven roles — design once, the theme swaps underneath. Accent is the only true brand colour; sage, warn and berry are reserved for meaning, never decoration, and warmth in artwork comes from the --art-* palette so celebration keeps its own colour.',
    wrap);
}

/* ============================================================================
   2 · TYPE
   ========================================================================== */
const TYPE = [
  { fam: 'Fraunces', cls: 'ff-display', role: 'Display / editorial',
    use: 'Screen titles, card & lesson names, big celebration numbers. The expressive voice.',
    rule: 'One weight — 400. Optical sizing on, tracking −0.02em. Only at 30 / 26 / 19. Never for UI controls or data.',
    sample: 'What coffee actually is', size: '36px' },
  { fam: 'IBM Plex Sans', cls: 'ff-ui', role: 'Interface / body',
    use: 'All body copy, buttons, list titles, answer choices. The default.',
    rule: 'Two weights — 400 body, 500 for controls & emphasis. Sizes 17 / 15 / 13 / 11 / 9.5.',
    sample: 'Pour-over starts with a short bloom.', size: '17px' },
  { fam: 'IBM Plex Mono', cls: 'ff-mono', role: 'Data / labels',
    use: 'Metadata, smallcaps labels, points & time values, any aligned number.',
    rule: 'Tabular numerals, weight 500. Labels UPPERCASE, 0.14–0.18em tracking. 13 / 11 / 9.5 — plus 26 & 56 for stat numerals only.',
    sample: '10 PTS · 3 MIN · 25°N–25°S', size: '13px' },
];
function renderType() {
  const wrap = el('div', { class: 'stack-cards' });
  TYPE.forEach(t => {
    wrap.append(el('div', { class: 'panel' },
      el('div', { class: 'panel-head' },
        el('div', { class: 'mono eyebrow' }, t.role),
        el('div', { class: 'mono eyebrow dim' }, t.fam),
      ),
      el('div', { class: t.cls + ' type-sample', style: `font-size:${t.size};` }, t.sample),
      el('div', { class: 'kv' },
        el('div', null, el('span', { class: 'mono klabel' }, 'WHERE'), el('span', { class: 'kval' }, t.use)),
        el('div', null, el('span', { class: 'mono klabel' }, 'RULE'),  el('span', { class: 'kval' }, t.rule)),
      ),
    ));
  });
  // scale strip
  const scale = el('div', { class: 'panel' },
    el('div', { class: 'mono eyebrow' }, 'Type scale'),
    el('div', { class: 'scale' },
      ['Hero', 'Display', 'Title', 'Heading', 'Lead', 'Body', 'Support', 'Label', 'Micro'].map((s, i) => {
        const px = [56, 30, 26, 19, 17, 15, 13, 11, 9.5][i];
        return el('div', { class: 'scale-row' },
          el('span', { class: i === 0 ? 'ff-mono' : i < 4 ? 'ff-display' : 'ff-ui', style: `font-size:${px}px;` }, i === 0 ? '7' : 'Coffee'),
          el('span', { class: 'mono klabel' }, `${s.toUpperCase()} · ${px}PX`),
        );
      }),
    ),
  );
  wrap.append(scale);
  return section('type', 'Foundations', 'Typography',
    'Three families, three jobs — expressive, functional, factual. The split is strict: if it is a number or a label it is mono; if it is a control or a sentence it is Plex Sans; if it is a title it is Fraunces. One nine-step ladder is shared by every screen, and it is enforced rather than described: the app has no literal font sizes left — every rule and every inline style reads a --t-* token, so an off-ladder size has to be added to the ladder before it can be used. The one exception is the iOS device frame, which follows Apple\'s own metrics.',
    wrap);
}

/* ============================================================================
   3 · SHAPE & SPACE
   ========================================================================== */
function renderShape() {
  const radii = [
    ['2px',   'Editorial', 'Cards, buttons, inputs, MCQ & match tiles. The sharp, print-like default.'],
    ['12–20px','Soft chrome','Bottom sheets, icon wells, avatars, mini-game tiles. Friendly, app-like.'],
    ['999px', 'Pill / dot', 'Status dots, fav toggle, switch toggles, badges, the home indicator.'],
  ];
  const rwrap = el('div', { class: 'shape-grid' });
  radii.forEach(([r, name, use]) => {
    rwrap.append(el('div', { class: 'shape-card' },
      el('div', { class: 'shape-demo', style: `border-radius:${r === '12–20px' ? '16px' : r === '2px' ? '2px' : '999px'};` }),
      el('div', { class: 'mono token' }, r),
      el('div', { class: 'swatch-role' }, name),
      el('div', { class: 'swatch-usage' }, use),
    ));
  });
  const notes = el('div', { class: 'panel' },
    el('div', { class: 'mono eyebrow' }, 'Borders & elevation'),
    el('ul', { class: 'rules' },
      el('li', null, el('b', null, 'Hairlines do the work. '), '1px var(--rule) separates almost everything; shadows are reserved for sheets and floating buttons only.'),
      el('li', null, el('b', null, 'Selection = double stroke. '), 'A selected card keeps its border and adds inset 0 0 0 1px var(--accent) — a crisper edge, not a fill.'),
      el('li', null, el('b', null, 'Frame. '), 'Every screen is designed at 393 × 852 (iPhone 15). Content padding is 24px; tight layouts drop to 20px.'),
    ),
  );
  return section('shape', 'Foundations', 'Shape and space',
    'Two radius languages run in parallel: sharp 2px for editorial content, soft 12–20px for playful chrome. Mixing them on one element is the tell of an off-system component.',
    el('div', { class: 'stack-cards' }, rwrap, notes));
}

/* ============================================================================
   4 · ICONS  — the full catalog
   ========================================================================== */
const ICONS = {
  nav: {
    title: 'Navigation', count: '5 tabs',
    rule: 'One tab, one coffee-vocabulary shape — drawn at 24×24, stroke 1.6. Outlined in ink-mute when inactive, filled in accent when active. This is the master icon family every other set should defer to.',
    items: [
      ['Cup', 'Learn', 'The everyday drink → the lessons home.',
        svg('0 0 24 24', '<path d="M9 3 Q10 4.5 9 6 Q8 7.5 9 9" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" opacity="0.7"/><path d="M12 3 Q13 4.5 12 6 Q11 7.5 12 9" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" opacity="0.7"/><path d="M15 3 Q16 4.5 15 6 Q14 7.5 15 9" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" opacity="0.7"/><path d="M5 10.5 L19 10.5 L18 19 Q17.5 20.5 16 20.5 L8 20.5 Q6.5 20.5 6 19 Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M19 12.5 Q22 12.5 22 15.5 Q22 18 19 18" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>', 1.6)],
      ['Route', 'Path', 'A trail of stops → the structured learning journey.',
        svg('0 0 24 24', '<path d="M4 20 Q8 18 9 14 Q10 8 14 7 Q18 6 20 4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-dasharray="0.1 3.4"/><circle cx="4" cy="20" r="2.1" stroke="currentColor" stroke-width="1.6"/><circle cx="10" cy="13" r="2.1" stroke="currentColor" stroke-width="1.6"/><circle cx="20" cy="4" r="2.4" stroke="currentColor" stroke-width="1.6"/>', 1.6)],
      ['Globe', 'Atlas', 'The world → coffee origins & geography.',
        svg('0 0 24 24', '<circle cx="12" cy="12" r="8.5" stroke="currentColor" stroke-width="1.6"/><ellipse cx="12" cy="12" rx="3.6" ry="8.5" stroke="currentColor" stroke-width="1.6"/><path d="M3.6 9.5h16.8M3.6 14.5h16.8" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>', 1.6)],
      ['Cards', 'Cards', 'A deck → the collectible knowledge cards.',
        svg('0 0 24 24', '<rect x="5" y="6" width="11" height="14" rx="1.6" transform="rotate(-8 10.5 13)" stroke="currentColor" stroke-width="1.6"/><rect x="8" y="5" width="11" height="14" rx="1.6" stroke="currentColor" stroke-width="1.6"/><ellipse cx="13.5" cy="12" rx="1.7" ry="2.4" transform="rotate(-18 13.5 12)" stroke="currentColor" stroke-width="1.3"/>', 1.6)],
      ['Leaf', 'Profile', 'The coffee plant → you, growing with points.',
        svg('0 0 24 24', '<path d="M20 4 Q20 13 14 18 Q9 21 6 19 Q3 16 5 11 Q9 5 20 4 Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M20 4 L7 18" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" opacity="0.75"/><path d="M14 9 L11 11" stroke="currentColor" stroke-width="1" stroke-linecap="round" opacity="0.6"/><path d="M12 13 L8.5 14.5" stroke="currentColor" stroke-width="1" stroke-linecap="round" opacity="0.6"/>', 1.6)],
    ],
  },
  duel: {
    title: 'Coffee Duel types', count: '5 types',
    rule: 'Each duel type names its subject by re-using the navigation concept vocabulary: the icon tells you what you are about to be quizzed on. Cup / Globe / Route are pulled straight from the shared nav family (window.Icons) — one drawing, one stroke (1.6). Only Tiles and Drop are duel-specific, matched to the same weight.',
    items: [
      ['Cup', 'Basics', 'Fundamentals — beans, species, where it grows. Same concept as the Learn tab — same drawing, from window.Icons.',
        svg('0 0 24 24', '<path d="M9 3 Q10 4.5 9 6 Q8 7.5 9 9" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" opacity="0.85"/><path d="M12 3 Q13 4.5 12 6 Q11 7.5 12 9" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" opacity="0.85"/><path d="M15 3 Q16 4.5 15 6 Q14 7.5 15 9" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" opacity="0.85"/><path d="M5 10.5 L19 10.5 L18 19 Q17.5 20.5 16 20.5 L8 20.5 Q6.5 20.5 6 19 Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M19 12.5 Q22 12.5 22 15.5 Q22 18 19 18" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>', 1.6)],
      ['Globe', 'Origin detective', 'Read the clues, name the country — geography, like the Atlas tab — same drawing, from window.Icons.',
        svg('0 0 24 24', '<circle cx="12" cy="12" r="8.5" stroke="currentColor" stroke-width="1.6"/><ellipse cx="12" cy="12" rx="3.6" ry="8.5" stroke="currentColor" stroke-width="1.6"/><path d="M3.6 9.5h16.8M3.6 14.5h16.8" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>', 1.6)],
      ['Route', 'Brew order', 'Ratios, temps, the right step in order — a sequence, like the Path tab — same drawing, from window.Icons.',
        svg('0 0 24 24', '<path d="M4 20 Q8 18 9 14 Q10 8 14 7 Q18 6 20 4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-dasharray="0.1 3.4"/><circle cx="4" cy="20" r="2.1" fill="var(--surface)" stroke="currentColor" stroke-width="1.6"/><circle cx="10" cy="13" r="2.1" fill="var(--surface)" stroke="currentColor" stroke-width="1.6"/><circle cx="20" cy="4" r="2.4" fill="var(--surface)" stroke="currentColor" stroke-width="1.6"/>', 1.6)],
      ['Tiles', 'Taste match', 'Two tiles joined → pairing a flavour to its cause. Duel-specific.',
        svg('0 0 24 24', '<rect x="3.5" y="7" width="7" height="10" rx="2" stroke="currentColor" stroke-width="1.6"/><rect x="13.5" y="7" width="7" height="10" rx="2" stroke="currentColor" stroke-width="1.6"/><path d="M10.5 12h3" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>', 1.6)],
      ['Cherry section', 'Processing', 'Seed inside the opened fruit. Duel-specific; same mark as the Processing dictionary category.',
        svg('0 0 24 24', '<path d="M13.6 5.9 Q 15.2 3.7 17.4 3.5" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/><circle cx="11.8" cy="13.2" r="7" stroke="currentColor" stroke-width="1.6"/><ellipse cx="11.8" cy="13.2" rx="2.9" ry="4.2" transform="rotate(-18 11.8 13.2)" stroke="currentColor" stroke-width="1.3"/>', 1.6)],
    ],
  },
  dict: {
    title: 'Knowledge marks', count: '9 topics',
    rule: 'One literal line mark per topic, drawn at stroke 1.6 (the shared family weight), interior accents lighter. These serve twice — dictionary categories AND the Path module headers — so each is the most recognisable OBJECT for its subject, never an abstract symbol, and no two topics share a mark.',
    items: [
      ['Beans', 'Beans', 'Two cherries on a stem — the raw fruit.',
        svg('0 0 24 24', '<path d="M11 4 Q12 9 9 12" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/><circle cx="8" cy="15" r="4.2" stroke="currentColor" stroke-width="1.6"/><circle cx="15.5" cy="14" r="4.2" stroke="currentColor" stroke-width="1.6"/>', 1.6)],
      ['Processing', 'Processing', 'Cherry in section — one cherry on its stem, the seed revealed inside. Neutral across washed / natural / honey; water is not the category.',
        svg('0 0 24 24', '<path d="M13.6 5.9 Q 15.2 3.7 17.4 3.5" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/><circle cx="11.8" cy="13.2" r="7" stroke="currentColor" stroke-width="1.6"/><ellipse cx="11.8" cy="13.2" rx="2.9" ry="4.2" transform="rotate(-18 11.8 13.2)" stroke="currentColor" stroke-width="1.3"/>', 1.6)],
      ['Roasting', 'Roasting', 'Roast curve on its axes — temperature over time, with first crack marked. Heat plus change, and it leaves the flame to the streak.',
        svg('0 0 24 24', '<path d="M4.8 4.5 V19.2 H19.6" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" opacity="0.55"/><path d="M6.2 17.2 Q 10 16.6 12.4 11.4 T 19.4 6.8" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/><circle cx="12.4" cy="11.4" r="2" fill="currentColor"/>', 1.6)],
      ['Brewing', 'Brewing', 'Pour-over cone with a drip.',
        svg('0 0 24 24', '<path d="M6 6 H18 L13 14 H11 L6 6 Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M12 16.5 v2.5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>', 1.6)],
      ['Espresso', 'Espresso', 'A demitasse — the concentrated cup.',
        svg('0 0 24 24', '<path d="M5.5 8 H16 V12 a4 4 0 0 1 -4 4 H9.5 a4 4 0 0 1 -4 -4 Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M16 9 h2 a2 2 0 0 1 0 4 h-2" stroke="currentColor" stroke-width="1.6"/><path d="M8 4.5 v1.5 M11.5 4.5 v1.5" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" opacity="0.6"/>', 1.6)],
      ['Sensory', 'Sensory', 'Tasting wheel — the flavour wheel, one wedge picked. The words for what you taste, not a mood face.',
        svg('0 0 24 24', '<path d="M12 12 L12 4 A 8 8 0 0 1 18.93 8 Z" fill="currentColor" opacity="0.9"/><circle cx="12" cy="12" r="8" stroke="currentColor" stroke-width="1.6"/><path d="M12 4 V20 M5.07 8 L18.93 16 M5.07 16 L18.93 8" stroke="currentColor" stroke-width="1.3"/>', 1.6)],
      ['Grind', 'Grind (module)', 'Hand grinder with its crank, burr line across the body. The Grind module’s own mark — it used to borrow the Equipment gear.',
        svg('0 0 24 24', '<path d="M12 9.4 V6.6 H15.8 A1.7 1.7 0 0 1 15.8 10" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round"/><path d="M7.6 9.4 H16.4 V18 A2.4 2.4 0 0 1 14 20.4 H10 A2.4 2.4 0 0 1 7.6 18 Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M9.4 14.2 H14.6" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/>', 1.6)],
      ['Equipment', 'Equipment', 'Gooseneck kettle — the most recognisable tool on the counter. A gear says settings, not coffee gear.',
        svg('0 0 24 24', '<path d="M8.4 11.2 C 8.4 8.2 13.2 8.2 13.2 11.2" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/><path d="M6.2 11.2 H15 V16.6 A3 3 0 0 1 12 19.6 H9.2 A3 3 0 0 1 6.2 16.6 Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M15 12.6 C 18.1 12.1 18.7 8.6 17 6.2" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>', 1.6)],
      ['Trade', 'Trade', 'Balance scales — what a lot is worth and who gets paid. Exchange arrows read as sync, not trade. Globe stays reserved for geography.',
        svg('0 0 24 24', '<path d="M12 5.4 V18" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/><path d="M4.6 8.6 H19.4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/><path d="M8.6 18.4 H15.4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/><path d="M7 8.6 V10.2 M17 8.6 V10.2" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/><path d="M4.4 10.2 A 2.6 2.6 0 0 0 9.6 10.2" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/><path d="M14.4 10.2 A 2.6 2.6 0 0 0 19.6 10.2" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/>', 1.6)],
    ],
  },
  status: {
    title: 'Status and feedback', count: '7 marks',
    rule: 'Meaning is carried by colour as much as shape: sage = right / solid / learned, berry = wrong / incorrect, accent = anything to act on (current step, needs practice), warn = celebration. Each mark has exactly one job.',
    items: [
      ['Check', 'Correct · Learned', 'Right answer, learned term, completed challenge. Always sage. A finished lesson is NOT a check — its bean node shows how full.',
        svg('0 0 18 18', '<path d="M3 9.5l3.5 3.5L15 5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>', 2)],
      ['Cross', 'Incorrect', 'Wrong answer, in answer review. Always berry.',
        svg('0 0 16 16', '<path d="M3 3l10 10M13 3L3 13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>', 2)],
      ['Lock', 'Locked', 'Content not yet unlocked. Always ink-mute at low opacity.',
        svg('0 0 20 20', '<rect x="4.5" y="8.5" width="11" height="8" rx="1.6" stroke="currentColor" stroke-width="1.5"/><path d="M7 8.5 V6.5 a3 3 0 0 1 6 0 V8.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>', 1.5)],
      ['Status dot', 'Current / Locked', 'Pill marker — filled = active, hollow = pending, none = locked.',
        svg('0 0 20 20', '<circle cx="10" cy="10" r="3.4" stroke="currentColor" stroke-width="1.5" fill="currentColor"/>', 1.5)],
      ['Crown', 'Win', 'Awarded to the duel winner. Always warn.',
        svg('0 0 26 18', '<path d="M3 15h20l1.5-10-6 4L13 2 7.5 13l-6-4L3 15Z" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/>', 1.4)],
      ['Bolt', 'Fastest answer', 'Highlights the quickest response in a duel. Always warn.',
        svg('0 0 24 24', '<path d="M13 2L4 13h6l-1 9 9-12h-6l1-8Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/>', 1.6)],
      ['Bean', 'Points currency', 'The unit of progress. Appears beside every points value.',
        svg('0 0 24 24', '<ellipse cx="12" cy="12" rx="6.5" ry="9.4" transform="rotate(32 12 12)" stroke="currentColor" stroke-width="1.6"/><path d="M8.4 5.6 C 12.4 9, 11.6 15, 15.6 18.4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>', 1.6)],
    ],
  },
  action: {
    title: 'Actions and navigation', count: '11 controls',
    rule: 'Workhorse interface glyphs — small chrome marks, not part of the 24×24 concept family, so they keep a lighter 1.4–1.7 range. Ink for primary actions, ink-mute for passive affordances, accent only when the control itself is the primary action.',
    items: [
      ['Chevron', 'Drill in', 'Trailing affordance on a tappable row. One shared definition at 70% ink-mute — rows never draw their own.',
        svg('0 0 8 14', '<path d="M1 1l6 6-6 6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>', 1.5)],
      ['Caret', 'Expand / collapse', 'Accordions, review toggles. Rotates 180° when open.',
        svg('0 0 20 20', '<path d="M5 8 L10 13 L15 8" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>', 1.6)],
      ['Back', 'Back', 'Returns up a level in a flow. Shared definition, currentColor.',
        svg('0 0 18 18', '<path d="M11 3 L5 9 L11 15" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>', 1.5)],
      ['Close', 'Close / quit', 'Dismisses a lesson, game or sheet. Shared definition, currentColor.',
        svg('0 0 18 18', '<path d="M3 3l12 12M15 3L3 15" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>', 1.5)],
      ['Share', 'Share', 'Opens the native share sheet for a duel invite.',
        svg('0 0 20 20', '<path d="M10 13V3M10 3L6.5 6.5M10 3l3.5 3.5" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/><path d="M5 11v4a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2v-4" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>', 1.7)],
      ['Link', 'Copy link', 'The shareable challenge URL.',
        svg('0 0 20 20', '<path d="M8.5 11.5l3-3" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/><path d="M11 8l1.7-1.7a3.3 3.3 0 0 1 4.6 4.6L15.6 12.6" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/><path d="M9 12l-1.7 1.7a3.3 3.3 0 0 1-4.6-4.6L4.4 7.4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>', 1.6)],
      ['Rematch', 'Run it back', 'Restarts the same duel with a fresh question set.',
        svg('0 0 20 20', '<path d="M4 10a6 6 0 0 1 10.5-4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/><path d="M16 10a6 6 0 0 1-10.5 4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/><path d="M14.5 3v3h-3M5.5 17v-3h3" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>', 1.6)],
      ['More', 'Overflow', 'Additional share targets / actions.',
        svg('0 0 24 24', '<circle cx="6" cy="12" r="1.5" fill="currentColor"/><circle cx="12" cy="12" r="1.5" fill="currentColor"/><circle cx="18" cy="12" r="1.5" fill="currentColor"/>', 1.6)],
      ['Bookmark', 'Save / favourite', 'Toggles on lessons, terms, cards & games. Filled accent when saved.',
        svg('0 0 20 20', '<path d="M5.5 3.5h9a1 1 0 0 1 1 1v12l-5.5-3.2-5.5 3.2v-12a1 1 0 0 1 1-1z" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/>', 1.5)],
      ['Gear', 'Settings', 'Top-right entry to Settings from Profile.',
        svg('0 0 20 20', '<path d="M3 6h7 M16 6h1" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/><path d="M3 14h2 M11 14h6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/><circle cx="12.5" cy="6" r="2.3" stroke="currentColor" stroke-width="1.5"/><circle cx="7.5" cy="14" r="2.3" stroke="currentColor" stroke-width="1.5"/>', 1.5)],
      ['Duel', 'Coffee Duel entry', 'Crossed coffee-stirrers — the persistent top-right duel button.',
        svg('0 0 24 24', '<path d="M7 5.5l10 13M17 5.5l-10 13" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/><circle cx="7" cy="5.5" r="1.7" fill="currentColor"/><circle cx="17" cy="5.5" r="1.7" fill="currentColor"/>', 1.6)],
    ],
  },
  kinds: {
    title: 'Content kinds', count: '4 marks',
    rule: 'Used in the "replay" and "saved" lists to tag what kind of thing a row is. Each mirrors the shape of the activity itself.',
    items: [
      ['Module', 'Module', 'A stacked cube — a bundle of lessons.',
        svg('0 0 20 20', '<path d="M10 3 L17 6.5 L10 10 L3 6.5 Z" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/><path d="M3 10.5 L10 14 L17 10.5" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/>', 1.4)],
      ['Match', 'Match game', 'Two joined tiles — the pairing game.',
        svg('0 0 20 20', '<rect x="2.5" y="6" width="6" height="8" rx="1.6" stroke="currentColor" stroke-width="1.4"/><rect x="11.5" y="6" width="6" height="8" rx="1.6" stroke="currentColor" stroke-width="1.4"/><path d="M8.5 10 H11.5" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/>', 1.4)],
      ['Quiz', 'Quiz game', 'A target — quick-fire true/false.',
        svg('0 0 20 20', '<circle cx="10" cy="10" r="6.5" stroke="currentColor" stroke-width="1.4"/><circle cx="10" cy="10" r="2.4" stroke="currentColor" stroke-width="1.4"/>', 1.4)],
      ['Flavour', 'Flavour / tasting', 'A spoke wheel — the flavour-wheel game & lessons.',
        svg('0 0 20 20', '<circle cx="10" cy="10" r="7" stroke="currentColor" stroke-width="1.3"/><circle cx="10" cy="10" r="2.4" stroke="currentColor" stroke-width="1.3"/><path d="M10 3v3.6M10 13.4V17M3 10h3.6M13.4 10H17M5 5l2.6 2.6M15 15l-2.6-2.6M15 5l-2.6 2.6M5 15l2.6-2.6" stroke="currentColor" stroke-width="1.1" stroke-linecap="round"/>', 1.3)],
    ],
  },
};

function iconCard([name, where, concept, markup]) {
  return el('div', { class: 'icon-card' },
    el('div', { class: 'icon-well', html: markup }),
    el('div', { class: 'icon-name mono' }, name),
    el('div', { class: 'icon-where' }, where),
    el('div', { class: 'icon-concept' }, concept),
  );
}
function renderIcons() {
  const groups = el('div', { class: 'stack-cards' });
  Object.values(ICONS).forEach(g => {
    const grid = el('div', { class: 'icon-grid' });
    g.items.forEach(it => grid.append(iconCard(it)));
    groups.append(el('div', { class: 'icon-group' },
      el('div', { class: 'icon-group-head' },
        el('div', { class: 'ff-display ig-title' }, g.title),
        el('div', { class: 'mono eyebrow dim' }, g.count),
      ),
      el('p', { class: 'icon-rule' }, g.rule),
      grid,
    ));
  });
  return section('icons', 'Catalog', 'Icons',
    'Every glyph in the app, grouped by the job it does, with the concept it encodes and where it lives. The Navigation set is the master family; everything else should read as part of it.',
    groups);
}

/* ============================================================================
   5 · COMPONENTS
   ========================================================================== */
function gPointsBean(size, color, crease) {
  return `<svg width="${size}" height="${size}" viewBox="0 0 24 24" style="display:block;flex-shrink:0;" aria-hidden="true"><g transform="rotate(-18 12 12)"><ellipse cx="12" cy="12" rx="7.5" ry="9.5" fill="${color || 'var(--accent)'}"/><path d="M12 3.5 C 13.5 7, 10.5 9, 12 12 S 13.5 17, 12 20.5" fill="none" stroke="${crease || 'var(--surface)'}" stroke-width="1.9" stroke-linecap="round"/></g></svg>`;
}

function gBrewCup(size) {
  return `<svg width="${size}" height="${size}" viewBox="0 0 24 24" fill="none" style="flex-shrink:0;" aria-hidden="true"><g stroke="currentColor" stroke-width="1.15" stroke-linecap="round" opacity="0.85"><path d="M9 5.2 Q7.6 3.6 9 2"/><path d="M13.4 5.2 Q12 3.6 13.4 2"/></g><path d="M4.6 8.4 H17.2 l-0.9 8.1 A2.4 2.4 0 0 1 13.9 18.6 H7.9 A2.4 2.4 0 0 1 5.5 16.5 Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M17.2 9.6 a2.9 2.9 0 0 1 0 5.4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>`;
}

function comp(name, where, rule, exampleHTML) {
  return el('div', { class: 'panel comp' },
    el('div', { class: 'panel-head' },
      el('div', { class: 'ff-display comp-title' }, name),
    ),
    el('div', { class: 'comp-demo', html: exampleHTML }),
    el('div', { class: 'kv' },
      el('div', null, el('span', { class: 'mono klabel' }, 'WHERE'), el('span', { class: 'kval' }, where)),
      el('div', null, el('span', { class: 'mono klabel' }, 'RULE'), el('span', { class: 'kval' }, rule)),
    ),
  );
}

const TAB_SVGS = ICONS.nav.items.map(i => i[3]);
function renderComponents() {
  const wrap = el('div', { class: 'comp-grid' });

  wrap.append(comp('Buttons',
    'Primary = the one main action per screen (Continue, Share, Accept). Ghost = the second action in any bottom stack. Link = tertiary, inline in content only.',
    'Primary is full-width accent; only one per screen. Disabled drops to 35% — never hide it. A dismiss that sits under a primary (Not now, Maybe later, Back to Path) is a GHOST, never a bare link — the link style is reserved for inline actions inside content, like “See the full entry →”.',
    `<div style="display:flex;flex-direction:column;gap:10px;">
       <button class="btn btn-primary">Continue</button>
       <button class="btn btn-ghost">Maybe later</button>
       <button class="btn btn-primary" disabled>Continue</button>
       <button class="btn btn-link">Skip for now</button>
     </div>`));

  wrap.append(comp('Pick card',
    'Onboarding choices and any single-/multi-select list (goal, brewer, level).',
    'Title in Fraunces, helper in ink-mute. Selected = accent border + inset accent stroke, never a fill — and never a bean: partial fill belongs to the mastery gauge alone, so it cannot double as a radio.',
    `<div style="display:flex;flex-direction:column;gap:10px;">
       <div class="pick-card selected"><div><div class="pc-title">Pour-over</div><div class="pc-desc">Clean, bright, hands-on.</div></div></div>
       <div class="pick-card"><div><div class="pc-title">Espresso</div><div class="pc-desc">Short, intense, crema.</div></div></div>
     </div>`));

  wrap.append(comp('MCQ choice',
    'Every multiple-choice question — in lessons and duels.',
    'One tap locks the row. Correct → sage tint, incorrect → berry tint. Disabled after answering.',
    `<div style="display:flex;flex-direction:column;gap:10px;">
       <button class="mcq-choice correct" disabled>Seed</button>
       <button class="mcq-choice" disabled>Leaf</button>
       <button class="mcq-choice incorrect" disabled>Root</button>
     </div>`));

  wrap.append(comp('Lesson row',
    'Module and path screens.',
    'Bean node · title · mono meta. The bean FILLS to your best score (ratio of that lesson’s own questions), so mastery is a level, not a word: sage at or above the pass mark, accent below it — where the row also earns the one chip, PRACTICE. A lesson row carries no cost or length meta at all — the right column is reserved for the practice chip, the continue chevron, or the lock. Locked rows drop to 40% and lose their tap target.',
    `<div>
       <div class="lesson-row"><span>${miniBean(1, 'var(--sage)')}</span><span class="title">What coffee actually is</span><span class="meta"></span></div>
       <div class="lesson-row"><span>${miniBean(0.8, 'var(--sage)')}</span><span class="title">Arabica vs Robusta</span><span class="meta"></span></div>
       <div class="lesson-row"><span>${miniBean(0, 'var(--ink-mute)')}</span><span class="title">Two cups, two ratios</span><span class="meta"></span></div>
       <div class="lesson-row"><span>${miniBean(0.67, 'var(--accent)')}</span><span class="title">Why processing matters</span><span class="meta" style="color:var(--accent);">PRACTICE</span></div>
       <div class="lesson-row"><span>${miniBean(0.45, 'var(--accent)')}</span><span style="position:relative;min-width:0;"><span class="title" style="display:block;">What origin means</span><span class="mono" style="position:absolute;top:100%;left:0;font-size:9.5px;letter-spacing:0.18em;text-transform:uppercase;color:var(--accent);margin-top:2px;line-height:1;">CURRENT</span></span><span class="meta" style="display:flex;align-items:center;"><svg width="6" height="10" viewBox="0 0 6 10" style="display:block;"><path d="M1 1l4 4-4 4" fill="none" stroke="var(--accent)" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg></span></div>
       <div class="lesson-row locked"><span>${miniBean(0, 'var(--ink-mute)')}</span><span class="title">Reading a bag label</span><span class="meta" style="display:flex;align-items:center;"><svg width="13" height="15" viewBox="0 0 13 15" aria-label="Locked"><rect x="1" y="6" width="11" height="8" rx="1.5" fill="none" stroke="var(--ink-mute)" stroke-width="1.3"/><path d="M3.5 6V4a3 3 0 0 1 6 0v2" fill="none" stroke="var(--ink-mute)" stroke-width="1.3" stroke-linecap="round"/></svg></span></div>
     </div>`));

  wrap.append(comp('Form row',
    'The "cupping form" pattern — specs, settings, brew parameters, duel stats.',
    'Uppercase mono label left, tabular mono value right, hairline between. Values align to the right edge.',
    `<div class="card" style="padding:6px 18px;">
       <div class="form-row"><span class="lbl">RATIO</span><span class="val">1 : 16</span></div>
       <div class="form-row"><span class="lbl">WATER</span><span class="val">93 °C</span></div>
       <div class="form-row"><span class="lbl">TIME</span><span class="val">2:45</span></div>
     </div>`));

  wrap.append(comp('Status chips',
    'Lesson & term states everywhere they are listed.',
    'Mono uppercase + a 6px dot. Learned = sage, Current and Practice = accent, Locked = hollow ink-mute. A lesson at or above the pass mark gets NO chip — its bean node already says how it went, so the only lesson label left is the one you can act on.',
    `<div style="display:flex;gap:18px;flex-wrap:wrap;align-items:center;">
       ${chip('LEARNED', 'var(--sage)', true)}
       ${chip('CURRENT', 'var(--accent)', true)}
       ${chip('PRACTICE', 'var(--accent)', true)}
       ${chip('LOCKED', 'var(--ink-mute)', false)}
     </div>`));

  wrap.append(comp('Match tiles',
    'The pairing mini-game and Taste-match duels.',
    'Tap to select (accent inset), tap its pair to lock (sage, muted text). Matched tiles are inert.',
    `<div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;">
       <div class="match-item matched">Higher elevation</div><div class="match-item matched">Arabica</div>
       <div class="match-item selected">More caffeine</div><div class="match-item">Robusta</div>
     </div>`));

  wrap.append(comp('Save toggle',
    'Lessons, terms, cards, games — the single favouriting control.',
    'Round hairline button. Bookmark fills accent and the border turns accent when saved.',
    `<div style="display:flex;gap:14px;align-items:center;">
       ${favBtn(true)} ${favBtn(false)}
       <span class="mono klabel" style="opacity:.7;">SAVED · DEFAULT</span>
     </div>`));

  wrap.append(comp('Collectible card',
    'The Cards collection grid.',
    '3:4 portrait, Fraunces title, mono sub. Locked cards sit at ~32% with no detail.',
    `<div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;max-width:260px;">
       <div class="collect-card"><div class="cc-sub">BOTANICAL</div><div class="cc-title">The Coffee Cherry</div></div>
       <div class="collect-card locked"><div class="cc-sub">LOCKED</div><div class="cc-title">?</div></div>
     </div>`));

  wrap.append(comp('Slider',
    'Estimation cards — grind size, ratios, anything on a scale.',
    'Hairline track, accent thumb ringed in bg. Bounds labelled in mono at each end.',
    `<div>
       <div style="display:flex;justify-content:space-between;" class="mono klabel"><span>FINER</span><span>COARSER</span></div>
       <input type="range" class="brew-slider" value="55" min="0" max="100"/>
     </div>`));


  // ── Feedback & progress ────────────────────────────────────
  wrap.append(compSubhead('Feedback and progress', 'How the app answers back'));

  wrap.append(comp('Bean node',
    'The one progress primitive: Path and Module lesson rows, the points mark, and card/collection nodes.',
    'A coffee bean that FILLS bottom-up. On a lesson it is a gauge — the fill is your best score as a ratio of that lesson’s own questions, sage at or above the pass mark, accent below it, outline-only when unplayed. It animates between levels, so a replay visibly raises the level. Only a scored lesson can fill: a lesson marked done with no stored score keeps the empty muted bean, because a full sage bean must always mean an earned score. Variable fill belongs to this gauge and nothing else — points use the solid Points mark below, and choice rows use no bean at all.',
    `<div style="display:flex;gap:26px;align-items:flex-start;flex-wrap:wrap;">
       <div style="text-align:center;">${beanDemo(0, 'var(--ink-mute)')}${capDemo('UNPLAYED')}</div>
       <div style="text-align:center;">${beanDemo(0, 'var(--ink-mute)')}${capDemo('DONE · UNSCORED')}</div>
       <div style="text-align:center;">${beanDemo(0.45, 'var(--accent)')}${capDemo('CURRENT')}</div>
       <div style="text-align:center;">${beanDemo(0.67, 'var(--accent)')}${capDemo('67% · PRACTICE')}</div>
       <div style="text-align:center;">${beanDemo(0.8, 'var(--sage)')}${capDemo('80% · SOLID')}</div>
       <div style="text-align:center;">${beanDemo(1, 'var(--sage)')}${capDemo('100% · PERFECT')}</div>
     </div>`));

  wrap.append(comp('Mastery rollup',
    'Profile — a persistent home for what the Lesson Complete screen says once.',
    'A two-segment bar over the whole lesson count: sage for solid, accent for needs-practice, the remainder empty. Two numbers, never a third. Tapping it deep-links to the Path to practise the weak ones.',
    `<div class="card" style="padding:16px;">
       <div style="display:flex;align-items:baseline;justify-content:space-between;gap:10px;">
         <div style="${SC}">LESSON PROGRESS</div>
         <div class="mono" style="font-size:11px;letter-spacing:0.06em;color:var(--ink-mute);">4 / 15 DONE</div>
       </div>
       <div style="display:flex;margin-top:12px;height:8px;border-radius:999px;overflow:hidden;background:var(--bg);">
         <div style="flex:3;background:var(--sage);border-right:1.5px solid var(--surface);"></div>
         <div style="flex:1;background:var(--accent);border-right:1.5px solid var(--surface);"></div>
         <div style="flex:11;"></div>
       </div>
       <div style="display:flex;gap:16px;margin-top:12px;">
         <span style="display:flex;align-items:center;gap:6px;font-size:13px;color:var(--ink);"><span style="width:8px;height:8px;border-radius:999px;background:var(--sage);"></span><b style="font-weight:500;">3</b> solid</span>
         <span style="display:flex;align-items:center;gap:6px;font-size:13px;color:var(--ink);"><span style="width:8px;height:8px;border-radius:999px;background:var(--accent);"></span><b style="font-weight:500;">1</b> need practice</span>
       </div>
     </div>`));

  wrap.append(comp('Roast meter',
    'The top bar of any run of questions — lesson mini-games, duel rounds, flashcards, vocab.',
    'One bean that ROASTS as you advance: raw green at the first question, espresso at the last, with the zero-padded mono count beside it. It reports POSITION, never quality — and because it has no fill state it can never be confused with the mastery gauge. Roast colours are literal coffee, so unlike every UI token they stay the same in both moods.',
    `<div style="display:flex;gap:22px;align-items:center;flex-wrap:wrap;">
       ${[0, 0.25, 0.5, 0.75, 1].map((t, i) => `<div style="text-align:center;">${gRoastBean(26, t)}<div class="mono" style="font-size:9.5px;letter-spacing:0.12em;color:var(--ink-mute);margin-top:8px;">${String(Math.round(t * 8)).padStart(2, '0')} / 08</div></div>`).join('')}
     </div>`));

  wrap.append(comp('Points mark',
    'Anywhere a points number appears — the toast, Lesson Complete, the profile stat.',
    'The currency bean: one solid silhouette with a carved crease and NO fill state. Points are a quantity, not a level, so this mark must never partially fill — that is the gauge’s only job. On an accent fill it inverts, crease in the fill colour.',
    `<div style="display:flex;gap:22px;align-items:center;flex-wrap:wrap;">
       <span style="display:flex;align-items:center;gap:10px;">${gPointsBean(18)}<span class="mono" style="font-size:13px;font-weight:500;letter-spacing:0.06em;text-transform:uppercase;color:var(--ink);">+12 PTS</span></span>
       <span style="display:inline-flex;align-items:center;gap:8px;background:var(--accent);color:var(--accent-ink);border-radius:999px;padding:8px 14px;">${gPointsBean(14, 'var(--accent-ink)', 'var(--accent)')}<span class="mono" style="font-size:13px;font-weight:500;letter-spacing:0.06em;text-transform:uppercase;">+12 PTS</span></span>
     </div>`));

  wrap.append(comp('Points toast',
    'Fires the moment a quiz card is answered correctly, mid-lesson.',
    'A sage pill that lifts and fades — the only celebration that interrupts. Points are effort, so the toast never reports mastery, and a wrong answer gets no counter-toast: feedback lives in the explanation instead.',
    `<div style="display:flex;gap:14px;align-items:center;">
       <span class="mono" style="font-size:11px;font-weight:500;letter-spacing:0.1em;color:var(--sage);border:1px solid color-mix(in oklab, var(--sage) 45%, transparent);background:color-mix(in oklab, var(--sage) 10%, transparent);border-radius:999px;padding:3px 9px;">+10 PTS</span>
       <span class="mono" style="font-size:9.5px;letter-spacing:0.14em;text-transform:uppercase;color:var(--ink-mute);">rises 12px · fades at 950ms</span>
     </div>`));

  wrap.append(comp('Fill-in-the-blank',
    'Concept-check cards — the learner drops words into a sentence.',
    'The blank is a dashed underline that becomes solid once filled: accent while unchecked, sage when right, berry when wrong. The sentence keeps reading as a sentence — never a form.',
    `<div style="font-size:15px;line-height:2;color:var(--ink);">
       Uneven grounds extract <span style="border-bottom:1.5px solid var(--sage);color:var(--sage);padding:0 6px;">unevenly</span>, so one cup tastes <span style="border-bottom:1.5px dashed color-mix(in oklab, var(--accent) 70%, var(--rule));color:var(--ink-mute);padding:0 18px;">&nbsp;</span>.
     </div>`));

  wrap.append(comp('Sequence row',
    'Put-in-order cards — brew steps, roast stages.',
    'A mono number token leads each row; tapping assigns the next number. On check, rows turn sage or berry and the token inverts to a solid fill.',
    `<div style="display:flex;flex-direction:column;gap:8px;">
       <div style="display:flex;align-items:center;gap:12px;padding:13px 14px;border:1px solid var(--sage);border-radius:14px;background:color-mix(in oklab, var(--sage) 10%, var(--surface));"><span class="mono" style="width:22px;height:22px;border-radius:999px;background:var(--sage);color:var(--surface);display:grid;place-items:center;font-size:11px;">1</span><span style="font-size:14px;color:var(--ink);">Rinse the filter</span></div>
       <div style="display:flex;align-items:center;gap:12px;padding:13px 14px;border:1px solid var(--rule);border-radius:14px;background:var(--surface);"><span class="mono" style="width:22px;height:22px;border-radius:999px;border:1px solid var(--rule);color:var(--ink-mute);display:grid;place-items:center;font-size:11px;">2</span><span style="font-size:14px;color:var(--ink);">Bloom for 30 seconds</span></div>
     </div>`));

  wrap.append(comp('Brew challenge card',
    'Today (below Continue Learning) — the one “go do it with real coffee” prompt.',
    'A section kicker with the cup mark sits OUTSIDE the card; the card itself is an accent-tinted surface with an accent hairline. Display title at 26, instruction at 15, then the trigger and the estimate as two mono lines against a primary Log Result button. Dismiss is an X in the corner — it saves for later, it does not delete. Never scored: completion is self-reported, so the card asks, it never tests.',
    `<div>
       <div style="${SC}color:var(--accent);display:flex;align-items:center;gap:8px;margin-bottom:28px;">${gBrewCup(15)} BREW CHALLENGE</div>
       <div class="card" style="position:relative;background:color-mix(in oklab, var(--accent) 6%, var(--surface));border-color:color-mix(in oklab, var(--accent) 28%, var(--rule));">
         <span style="position:absolute;top:14px;right:14px;color:var(--ink-mute);line-height:0;"><svg width="16" height="16" viewBox="0 0 15 15" aria-label="Save for later"><path d="M3 3l9 9M12 3l-9 9" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg></span>
         <div class="ff-display" style="font-size:26px;font-weight:400;line-height:1.1;letter-spacing:-0.01em;padding-right:28px;color:var(--ink);">Name the origin</div>
         <p style="font-size:15px;line-height:1.5;color:var(--ink-mute);margin:10px 0 0;text-wrap:pretty;">Next time you open a bag, find the country it was grown in — and say it out loud.</p>
         <div style="display:flex;align-items:center;justify-content:space-between;gap:16px;margin-top:20px;">
           <div style="display:flex;flex-direction:column;gap:8px;">
             <div class="mono" style="font-size:11px;letter-spacing:0.14em;text-transform:uppercase;color:var(--ink-mute);">NEXT BAG YOU OPEN</div>
             <div class="mono" style="font-size:11px;letter-spacing:0.14em;text-transform:uppercase;color:var(--ink-mute);">~2 MIN</div>
           </div>
           <div class="btn-primary" style="width:auto;min-width:132px;padding:12px 22px;font-size:13px;text-align:center;box-sizing:border-box;flex-shrink:0;">Log Result</div>
         </div>
       </div>
     </div>`));

  wrap.append(comp('Empty state',
    'A filter with no matches, a passport with no stamps, a Saved shelf before anything is saved.',
    'Always three parts: a muted glyph, one Fraunces line saying what would live here, and a ghost button that clears the cause. Never an apology, never an illustration the user cannot act on.',
    `<div style="text-align:center;padding:22px 16px;">
       <div style="color:var(--ink-mute);opacity:0.6;display:flex;justify-content:center;">${beanDemo(0, 'var(--ink-mute)')}</div>
       <div class="ff-display" style="font-size:19px;color:var(--ink);margin-top:12px;">No stamps yet</div>
       <p style="font-size:13px;line-height:1.5;color:var(--ink-mute);margin:8px auto 16px;max-width:260px;">Explore an origin on the map and its stamp lands here.</p>
       <div class="btn btn-ghost" style="width:auto;display:inline-block;padding:12px 20px;">Open the map</div>
     </div>`));

  wrap.append(comp('Roasty, the companion',
    'Loading screens, lesson and module completion, correct and wrong answers, the gift and duel moments.',
    'The mascot is a coffee bean with a cap: one shape, eleven states (idle, card, lesson, module, correct, wrong, sleep, gift, duel win/loss, tasting). He reacts, he never instructs — copy carries the teaching. Full state sheet, motion specs and the storyboard live in the Mascot study file.',
    `<div style="display:flex;align-items:center;gap:14px;">
       <span style="width:52px;height:52px;border-radius:16px;background:var(--surface-2);display:grid;place-items:center;">${beanDemo(1, 'color-mix(in oklab, var(--accent) 70%, var(--ink))')}</span>
       <a href="Mascot - Roasty.html" style="font-size:13px;color:var(--accent);">Open the Roasty study →</a>
     </div>`));

  // ── Chrome & navigation ────────────────────────────────────
  wrap.append(compSubhead('Chrome and navigation', 'Frames every screen'));

  wrap.append(comp('Screen top bar',
    'Every pushed screen — lessons, modules, settings, saved, the streak & tree screens, game intros.',
    'A 32 · 1fr · 32 grid: a back chevron or close cross on the left, the centre reserved for the roast meter (empty on plain back bars), an optional action on the right. The screen’s own title lives in the body below, never in the bar.',
    topBarDemo()));

  wrap.append(comp('Header buttons',
    'Pinned top-right on the main tabs — the persistent entries to Coffee Duel and the Coffee Dictionary.',
    '42px round, surface fill, hairline border, soft shadow; the glyph is always accent. A count badge or a lock badge pins to the top-right corner when relevant.',
    headerButtonsDemo()));

  // Tab bar — full width, lives with the rest of the chrome
  wrap.append(el('div', { class: 'panel comp comp-wide' },
    el('div', { class: 'panel-head' }, el('div', { class: 'ff-display comp-title' }, 'Tab bar')),
    el('div', { class: 'comp-demo', html: tabBarHTML() }),
    el('div', { class: 'kv' },
      el('div', null, el('span', { class: 'mono klabel' }, 'WHERE'), el('span', { class: 'kval' }, 'Persistent navigation across the five top-level destinations.')),
      el('div', null, el('span', { class: 'mono klabel' }, 'RULE'), el('span', { class: 'kval' }, 'Active tab is accent + filled icon; the rest are ink-mute outlines. Labels are 9px mono, always uppercase.')),
    ),
  ));

  wrap.append(comp('Bottom sheet',
    'The app’s one modal pattern — Share, Reset confirm, Daily reminder, Billing cycle, the Plus gate, and the dictionary & atlas detail peeks.',
    'Rises from the bottom over a 40% scrim; a 36px handle, then content. Lead with a mono eyebrow, a Fraunces title, then actions. Tap-scrim or “Not now” always dismisses — never trap the user.',
    sheetDemo()));

  wrap.append(comp('Sticky action bar',
    'The footer that carries the single primary action on a scrolling screen — duel hub, lesson end, pickers.',
    'The button sits over a transparent-to-bg gradient so content scrolls comfortably beneath it. One primary action only; a quiet link may sit under it. This — plus the tab bar — is the app’s only “footer”.',
    actionBarDemo()));

  // ── Inputs & controls ──────────────────────────────────────
  wrap.append(compSubhead('Inputs and controls', 'How the user makes choices'));

  wrap.append(comp('Search field',
    'Dictionary search; the pattern for any future find-as-you-type input.',
    'Surface fill, 12px radius, leading magnifier in ink-mute. A clear cross appears only once there’s a query. Placeholder shows a real example, never just “Search”.',
    searchDemo()));

  wrap.append(comp('Segmented control',
    'The All / Learned / To-learn filter; the pattern for any 2–3 way mutually-exclusive switch.',
    'A single hairline pill split into equal segments. The active segment fills accent with accent-ink text; the rest are ink-mute. Labels are mono uppercase.',
    segmentedDemo()));

  wrap.append(comp('Toggle',
    'Every on/off setting — notifications, sounds, reminders.',
    'A 999px pill — the one place radius goes fully round, per the radius rule. Off = hairline track + ink-mute knob; on = accent track + accent-ink knob. 44×26 hit target.',
    toggleDemo()));

  wrap.append(comp('Settings / nav row',
    'Settings, About and Account screens, and the navigational cards on Profile.',
    'Label left; on the right a mono value, then a chevron (internal), an arrow (external), or a toggle. Hairline between rows. Destructive rows (e.g. Reset) take berry, never accent.',
    settingsRowDemo()));

  return section('components', 'Library', 'Components',
    'The reusable building blocks, each shown live in the current theme. Anything new should be assembled from these before a fresh pattern is invented.',
    wrap);
}

function tabBarHTML() {
  const labels = ['LEARN', 'PATH', 'ATLAS', 'CARDS', 'PROFILE'];
  let cells = '';
  TAB_SVGS.forEach((s, i) => {
    const active = i === 0;
    cells += `<div class="tab${active ? ' active' : ''}" style="position:static;color:${active ? 'var(--accent)' : 'var(--ink-mute)'}">
      <span class="tab-ico">${s}</span><span class="label">${labels[i]}</span></div>`;
  });
  return `<div class="tabbar-demo">${cells}</div>`;
}

function beanDemo(pct, color) {
  const id = 'dsbean' + Math.round(pct * 100) + color.replace(/[^a-z]/g, '');
  return `<svg width="26" height="26" viewBox="0 0 24 24" style="display:block;flex-shrink:0;">
    <defs><clipPath id="${id}"><ellipse cx="12" cy="12" rx="7.5" ry="9.5" transform="rotate(-18 12 12)"/></clipPath></defs>
    <g clip-path="url(#${id})"><rect x="0" y="${24 - 24 * pct}" width="24" height="${24 * pct}" fill="${color}"/></g>
    <ellipse cx="12" cy="12" rx="7.5" ry="9.5" transform="rotate(-18 12 12)" fill="none" stroke="${pct >= 1 ? 'var(--ink)' : 'var(--ink-mute)'}" stroke-width="1.2"/>
    <path d="M12 3.5 C 13.5 7, 10.5 9, 12 12 S 13.5 17, 12 20.5" transform="rotate(-18 12 12)" fill="none" stroke="${pct > 0.6 ? 'var(--ink)' : 'var(--ink-mute)'}" stroke-width="1.1" stroke-linecap="round"/>
  </svg>`;
}
function capDemo(t) {
  return `<div class="mono" style="font-size:9.5px;letter-spacing:0.14em;text-transform:uppercase;color:var(--ink-mute);margin-top:8px;white-space:nowrap;">${t}</div>`;
}

// ── Chrome & navigation demos ────────────────────────────────
const SC = "font-family:'IBM Plex Sans',sans-serif;font-size:11px;font-weight:500;letter-spacing:0.14em;text-transform:uppercase;color:var(--ink-mute);";
function compSubhead(title, meta) {
  return el('div', { class: 'comp-subhead' },
    el('div', { class: 'ff-display' }, title),
    el('div', { class: 'mono eyebrow dim' }, meta),
  );
}
const DS_ROAST_RAMP = ['#9FB088', '#C79A63', '#A2703C', '#7A4526', '#54301C'];
function dsRoastAt(t) {
  const p = Math.max(0, Math.min(1, t)) * (DS_ROAST_RAMP.length - 1);
  const i = Math.min(DS_ROAST_RAMP.length - 2, Math.floor(p));
  const f = p - i;
  const hex = (s) => [1, 3, 5].map(k => parseInt(s.slice(k, k + 2), 16));
  const a = hex(DS_ROAST_RAMP[i]), b = hex(DS_ROAST_RAMP[i + 1]);
  return '#' + a.map((v, k) => Math.round(v + (b[k] - v) * f).toString(16).padStart(2, '0')).join('');
}
function gRoastBean(size, t) {
  return `<svg width="${size}" height="${size}" viewBox="0 0 24 24" style="display:block;flex-shrink:0;" aria-hidden="true"><g transform="rotate(-18 12 12)"><ellipse cx="12" cy="12" rx="7.5" ry="9.5" fill="${dsRoastAt(t)}"/><ellipse cx="12" cy="12" rx="7.5" ry="9.5" fill="none" stroke="var(--ink-mute)" stroke-width="1"/><path d="M12 3.5 C 13.5 7, 10.5 9, 12 12 S 13.5 17, 12 20.5" fill="none" stroke="#FBF7EE" stroke-opacity="0.34" stroke-width="1.5" stroke-linecap="round"/></g></svg>`;
}
function drillMeterDemo(done, total) {
  return `<div style="display:flex;align-items:center;justify-content:center;gap:10px;">
    ${gRoastBean(22, done / total)}
    <span class="mono" style="font-size:11px;letter-spacing:0.12em;text-transform:uppercase;color:var(--ink-mute);">${String(done).padStart(2, '0')} / ${String(total).padStart(2, '0')}</span>
  </div>`;
}

function topBarDemo() {
  const ctrl = (svg) => `<span style="color:var(--ink);display:flex;align-items:center;justify-content:center;">${svg}</span>`;
  const back = `<svg width="18" height="18" viewBox="0 0 18 18" fill="none"><path d="M11 3 L5 9 L11 15" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>`;
  const close = `<svg width="18" height="18" viewBox="0 0 18 18" fill="none"><path d="M3 3l12 12M15 3L3 15" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>`;
  const bar = (left, center) => `<div style="border:1px solid var(--rule);border-radius:10px;background:var(--bg);"><div style="display:grid;grid-template-columns:32px 1fr 32px;align-items:center;gap:12px;padding:13px 16px;">${ctrl(left)}${center}<div></div></div></div>`;
  const progress = drillMeterDemo(3, 8);
  return `<div style="display:flex;flex-direction:column;gap:14px;">
    ${bar(close, progress)}
    ${bar(back, '<div></div>')}
  </div>`;
}
function headerButtonsDemo() {
  const round = (inner, badge) => `<span style="position:relative;width:42px;height:42px;border-radius:999px;background:var(--surface);border:1px solid var(--rule);box-shadow:0 2px 8px rgba(0,0,0,0.10);display:grid;place-items:center;">${inner}${badge}</span>`;
  const duel = `<svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M7 5.5l10 13M17 5.5l-10 13" stroke="var(--accent)" stroke-width="1.6" stroke-linecap="round"/><circle cx="7" cy="5.5" r="1.7" fill="var(--accent)"/><circle cx="17" cy="5.5" r="1.7" fill="var(--accent)"/></svg>`;
  const dict = `<svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M12 6.6C10.4 5.4 8.3 5.1 6.2 5.3A1 1 0 0 0 5 6.3v10.2a1 1 0 0 0 1.1 1c1.9-.2 3.9.1 5.4 1.2M12 6.6c1.6-1.2 3.7-1.5 5.8-1.3a1 1 0 0 1 1.1 1v10.2a1 1 0 0 1-1.1 1c-1.9-.2-3.9.1-5.4 1.2M12 6.6V19" stroke="var(--accent)" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>`;
  const count = `<span class="mono" style="position:absolute;top:-4px;right:-4px;min-width:18px;height:18px;padding:0 4px;border-radius:999px;background:var(--accent);color:var(--accent-ink);font-size:9.5px;font-weight:500;display:grid;place-items:center;border:2px solid var(--bg);">2</span>`;
  const lockBadge = `<span style="position:absolute;top:-4px;right:-4px;width:18px;height:18px;border-radius:999px;background:var(--surface-2);border:2px solid var(--bg);display:grid;place-items:center;color:var(--ink-mute);">${gLockGlyph(9, 2)}</span>`;
  const cell = (node, cap) => `<div class="afford">${node}<span class="cap">${cap}</span></div>`;
  return `<div class="afford-row">
    ${cell(round(duel, count), 'DUEL · COUNT')}
    ${cell(round(dict, ''), 'DICTIONARY')}
    ${cell(round(dict, lockBadge), 'LOCKED')}
  </div>`;
}
function sheetDemo() {
  return `<div style="max-width:340px;margin:0 auto;background:var(--bg);border:1px solid var(--rule);border-top-left-radius:16px;border-top-right-radius:16px;box-shadow:0 -18px 36px rgba(0,0,0,0.10);padding:0 24px 26px;">
    <div style="width:36px;height:4px;border-radius:2px;background:var(--rule);margin:8px auto 0;"></div>
    <div style="padding-top:18px;">
      <div style="${SC}">SHARE TO</div>
      <h2 class="ff-display" style="font-size:26px;font-weight:400;letter-spacing:-0.02em;line-height:1.06;margin:8px 0 6px;color:var(--ink);">Can you beat my score?</h2>
      <p style="font-size:13px;line-height:1.5;color:var(--ink-mute);margin:0 0 18px;text-wrap:pretty;">Send a link — they tap, play the same five questions, and the result comes back to you.</p>
      <div class="btn-primary" style="text-align:center;box-sizing:border-box;">Share link</div>
      <div class="btn btn-ghost" style="text-align:center;box-sizing:border-box;margin-top:10px;">Not now</div>
    </div>
  </div>`;
}
function actionBarDemo() {
  const row = `<div style="height:42px;border:1px solid var(--rule);border-radius:10px;background:var(--surface);"></div>`;
  return `<div style="position:relative;max-width:340px;margin:0 auto;height:210px;border:1px solid var(--rule);border-radius:12px;overflow:hidden;background:var(--bg);">
    <div style="padding:20px 18px 0;">
      <div style="${SC}color:var(--accent);">COFFEE DUEL</div>
      <div class="ff-display" style="font-size:19px;color:var(--ink);margin-top:4px;">Your turn</div>
      <div style="display:flex;flex-direction:column;gap:9px;margin-top:14px;">${row}${row}${row}</div>
    </div>
    <div style="position:absolute;left:0;right:0;bottom:0;padding:30px 18px 16px;background:linear-gradient(180deg,transparent,var(--bg) 40%);">
      <div class="btn-primary" style="text-align:center;box-sizing:border-box;">Start new duel</div>
    </div>
  </div>`;
}

// ── Inputs & controls demos ──────────────────────────────────
function searchDemo() {
  return `<div style="display:flex;align-items:center;gap:10px;background:var(--surface);border:1px solid var(--rule);border-radius:12px;padding:11px 14px;">
    <svg width="17" height="17" viewBox="0 0 20 20" fill="none" style="flex-shrink:0;"><circle cx="9" cy="9" r="6" stroke="var(--ink-mute)" stroke-width="1.6"/><path d="M13.5 13.5 L17 17" stroke="var(--ink-mute)" stroke-width="1.6" stroke-linecap="round"/></svg>
    <span style="flex:1;min-width:0;font-family:'IBM Plex Sans',sans-serif;font-size:15px;color:var(--ink);">crema</span>
    <span style="color:var(--ink-mute);display:flex;"><svg width="16" height="16" viewBox="0 0 18 18"><path d="M4 4l10 10M14 4L4 14" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg></span>
  </div>`;
}
function segmentedDemo() {
  const seg = (label, on) => `<div style="flex:1;text-align:center;font-family:'IBM Plex Sans',sans-serif;font-size:11px;font-weight:500;letter-spacing:0.1em;text-transform:uppercase;padding:9px 4px;background:${on ? 'var(--accent)' : 'transparent'};color:${on ? 'var(--accent-ink)' : 'var(--ink-mute)'};">${label}</div>`;
  return `<div style="display:flex;border:1px solid var(--rule);border-radius:999px;overflow:hidden;background:var(--surface);">${seg('All', true)}${seg('Learned', false)}${seg('To learn', false)}</div>`;
}
function toggleDemo() {
  const tog = (on) => `<span style="position:relative;width:44px;height:26px;padding:3px;border-radius:999px;box-sizing:border-box;display:inline-block;border:1px solid ${on ? 'var(--accent)' : 'var(--rule)'};background:${on ? 'var(--accent)' : 'transparent'};"><span style="display:block;width:18px;height:18px;border-radius:999px;background:${on ? 'var(--accent-ink)' : 'var(--ink-mute)'};transform:translateX(${on ? '18px' : '0'});"></span></span>`;
  const cell = (node, cap) => `<div class="afford">${node}<span class="cap">${cap}</span></div>`;
  return `<div class="afford-row" style="gap:36px;">${cell(tog(true), 'ON')}${cell(tog(false), 'OFF')}</div>`;
}
function settingsRowDemo() {
  const chev = `<svg width="8" height="14" viewBox="0 0 8 14"><path d="M1 1l6 6-6 6" fill="none" stroke="var(--ink-mute)" stroke-opacity="0.6" stroke-width="1.5" stroke-linecap="round"/></svg>`;
  const ext = `<svg width="13" height="13" viewBox="0 0 13 13"><path d="M3 10 L10 3 M4.5 3 H10 V8.5" fill="none" stroke="var(--ink-mute)" stroke-opacity="0.6" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"/></svg>`;
  const tog = `<span style="position:relative;width:44px;height:26px;padding:3px;border-radius:999px;box-sizing:border-box;display:inline-block;border:1px solid var(--accent);background:var(--accent);"><span style="display:block;width:18px;height:18px;border-radius:999px;background:var(--accent-ink);transform:translateX(18px);"></span></span>`;
  const row = (label, right, last, danger) => `<div style="display:flex;align-items:center;justify-content:space-between;gap:16px;padding:16px 0;${last ? '' : 'border-bottom:1px solid var(--rule);'}"><span style="font-size:15px;color:${danger ? 'var(--berry)' : 'var(--ink)'};">${label}</span><span style="display:flex;align-items:center;gap:10px;">${right}</span></div>`;
  const val = (v) => `<span class="mono" style="font-size:13px;color:var(--ink-mute);">${v}</span>`;
  return `<div class="card" style="padding:4px 18px;">
    ${row('Daily reminder', val('8:00') + chev, false, false)}
    ${row('Sound effects', tog, false, false)}
    ${row('Rate the app', ext, false, false)}
    ${row('Reset progress', chev, true, true)}
  </div>`;
}

function miniBean(pct, color) {
  const id = 'dsb' + Math.round(pct * 100) + color.replace(/[^a-z]/g, '');
  const full = pct >= 1;
  return `<svg width="20" height="20" viewBox="0 0 24 24" style="display:block;flex-shrink:0;">
    <defs><clipPath id="${id}"><ellipse cx="12" cy="12" rx="7.5" ry="9.5" transform="rotate(-18 12 12)"/></clipPath></defs>
    <g clip-path="url(#${id})"><rect x="0" y="${24 - 24 * pct}" width="24" height="${24 * pct}" fill="${color}"/></g>
    <ellipse cx="12" cy="12" rx="7.5" ry="9.5" transform="rotate(-18 12 12)" fill="none" stroke="${full ? 'var(--ink)' : 'var(--ink-mute)'}" stroke-width="1"/>
    <path d="M12 3.5 C 13.5 7, 10.5 9, 12 12 S 13.5 17, 12 20.5" transform="rotate(-18 12 12)" fill="none" stroke="${pct > 0.6 ? 'var(--ink)' : 'var(--ink-mute)'}" stroke-width="0.9" stroke-linecap="round"/>
  </svg>`;
}
function miniCheck() {
  return `<span style="width:24px;height:24px;border-radius:999px;display:grid;place-items:center;background:color-mix(in oklab,var(--sage) 22%,var(--surface));border:1px solid color-mix(in oklab,var(--sage) 55%,var(--rule));">
    <svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M2 6.2 L5 9 L10 3" stroke="var(--sage)" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"/></svg></span>`;
}
function miniDot() {
  return `<span style="width:24px;height:24px;border-radius:999px;display:grid;place-items:center;border:1px solid var(--accent);"><span style="width:7px;height:7px;border-radius:999px;background:var(--accent);"></span></span>`;
}
function miniLock() {
  return `<svg width="18" height="18" viewBox="0 0 20 20" style="color:var(--ink-mute)" fill="none"><rect x="4.5" y="8.5" width="11" height="8" rx="1.6" stroke="currentColor" stroke-width="1.5"/><path d="M7 8.5 V6.5 a3 3 0 0 1 6 0 V8.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>`;
}
function chip(label, color, filled) {
  const dot = `<span style="width:6px;height:6px;border-radius:999px;background:${filled ? color : 'transparent'};border:1px solid ${color};display:inline-block;"></span>`;
  return `<span class="mono" style="font-size:9.5px;letter-spacing:0.16em;color:${color};display:inline-flex;align-items:center;gap:6px;">${dot}${label}</span>`;
}
function favBtn(active) {
  const col = active ? 'var(--accent)' : 'var(--ink-mute)';
  const bd = active ? 'var(--accent)' : 'var(--rule)';
  return `<span style="width:38px;height:38px;border-radius:999px;border:1px solid ${bd};display:grid;place-items:center;">
    <svg width="19" height="19" viewBox="0 0 20 20" fill="none"><path d="M5.5 3.5h9a1 1 0 0 1 1 1v12l-5.5-3.2-5.5 3.2v-12a1 1 0 0 1 1-1z" fill="${active ? col : 'none'}" stroke="${col}" stroke-width="1.5" stroke-linejoin="round"/></svg></span>`;
}

/* ============================================================================
   6 · PLUS & PAYWALL — the monetization / gating layer
   ========================================================================== */
const SMALLCAPS = "font-family:'IBM Plex Mono',monospace;font-size:9.5px;letter-spacing:0.14em;text-transform:uppercase;color:var(--accent);";

function gLockGlyph(size, sw) {
  return `<svg width="${size}" height="${size}" viewBox="0 0 20 20" fill="none" aria-hidden="true"><rect x="4.5" y="8.7" width="11" height="7.8" rx="1.7" fill="none" stroke="currentColor" stroke-width="${sw || 1.6}"/><path d="M7 8.7 V6.6 a3 3 0 0 1 6 0 V8.7" fill="none" stroke="currentColor" stroke-width="${sw || 1.6}" stroke-linecap="round"/></svg>`;
}

// the persistent header-icon + corner lock badge
function lockBadgeDemo() {
  return `<span style="position:relative;width:34px;height:34px;display:grid;place-items:center;color:var(--accent);">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M7 5.5l10 13M17 5.5l-10 13" stroke="var(--accent)" stroke-width="1.6" stroke-linecap="round"/><circle cx="7" cy="5.5" r="1.7" fill="var(--accent)"/><circle cx="17" cy="5.5" r="1.7" fill="var(--accent)"/></svg>
    <span style="position:absolute;top:-4px;right:-4px;width:18px;height:18px;border-radius:999px;background:var(--surface-2);border:2px solid var(--bg);display:grid;place-items:center;color:var(--ink-mute);">${gLockGlyph(9, 2)}</span>
  </span>`;
}

function affordancesDemo() {
  return `<div class="afford-row">
    <div class="afford">
      <span class="plus-pill">PLUS</span>
      <span class="cap">PLUS PILL</span>
    </div>
    <div class="afford">
      <span style="width:34px;height:34px;border-radius:999px;display:grid;place-items:center;background:color-mix(in oklab,var(--accent) 13%,var(--surface));color:var(--accent);">${gLockGlyph(17, 1.7)}</span>
      <span class="cap">LOCK GLYPH</span>
    </div>
    <div class="afford">
      ${lockBadgeDemo()}
      <span class="cap">LOCK BADGE</span>
    </div>
    <div class="afford">
      <span class="trial-pill"><span class="dot"></span>Free trial · 12:30 left</span>
      <span class="cap">TRIAL COUNTDOWN</span>
    </div>
  </div>`;
}

function gateSheetDemo() {
  return `<div style="max-width:340px;margin:0 auto;border:1px solid var(--rule);border-radius:18px 18px 2px 2px;background:var(--surface);padding:16px 20px 20px;box-shadow:0 -12px 30px rgba(0,0,0,0.10);">
    <div style="width:40px;height:4px;border-radius:999px;background:var(--rule);margin:0 auto 16px;"></div>
    <div style="display:flex;align-items:center;gap:10px;margin-bottom:12px;">
      <span style="width:40px;height:40px;border-radius:999px;flex-shrink:0;display:grid;place-items:center;background:color-mix(in oklab,var(--accent) 13%,var(--surface));color:var(--accent);">${gLockGlyph(18, 1.7)}</span>
      <div style="text-align:left;"><div style="${SMALLCAPS}">PLUS FEATURE</div><div class="ff-display" style="font-size:19px;color:var(--ink);line-height:1.05;margin-top:2px;">Coffee Atlas</div></div>
    </div>
    <p style="font-size:13px;line-height:1.5;color:var(--ink-mute);margin:0 0 18px;text-wrap:pretty;">Travel the coffee belt, explore origins and collect passport stamps. It’s part of BrewPath Plus.</p>
    <div class="btn-primary" style="text-align:center;box-sizing:border-box;">Unlock Plus — 7-day free trial</div>
    <div style="display:flex;align-items:center;justify-content:center;gap:10px;margin-top:10px;border:1px solid var(--rule);border-radius:2px;padding:13px 16px;color:var(--ink);">
      <svg width="18" height="18" viewBox="0 0 20 20" fill="none" style="flex-shrink:0;"><circle cx="10" cy="10" r="8" stroke="var(--accent)" stroke-width="1.5"/><path d="M8.2 6.8 L13.4 10 L8.2 13.2 Z" fill="var(--accent)"/></svg>
      <span style="font-size:13px;font-weight:500;">Watch a short ad — try 15 min free</span>
    </div>
    <div style="${SMALLCAPS}color:var(--ink-mute);text-align:center;margin-top:14px;">One ad unlocks Coffee Atlas for 15 minutes</div>
  </div>`;
}

function adDemo() {
  return `<div style="max-width:300px;margin:0 auto;border-radius:18px;overflow:hidden;border:1px solid var(--rule);background:#0b0908;">
    <div style="display:flex;align-items:center;justify-content:space-between;padding:14px 16px;">
      <span style="font-family:'IBM Plex Mono',monospace;font-size:9.5px;letter-spacing:0.18em;text-transform:uppercase;color:rgba(255,255,255,0.6);">Ad · Rewarded</span>
      <span style="position:relative;width:34px;height:34px;display:grid;place-items:center;">
        <svg width="34" height="34" viewBox="0 0 40 40" style="position:absolute;transform:rotate(-90deg);"><circle cx="20" cy="20" r="17" fill="none" stroke="rgba(255,255,255,0.18)" stroke-width="2.5"/><circle cx="20" cy="20" r="17" fill="none" stroke="#E07A4F" stroke-width="2.5" stroke-linecap="round" stroke-dasharray="106.8" stroke-dashoffset="42"/></svg>
        <span style="font-family:'IBM Plex Mono',monospace;font-size:11px;color:#fff;">3</span>
      </span>
    </div>
    <div style="padding:4px 18px 0;display:grid;place-items:center;">
      <div style="width:100%;aspect-ratio:4/5;border-radius:12px;overflow:hidden;background:repeating-linear-gradient(135deg,#1c1714 0 14px,#221a15 14px 28px);border:1px solid rgba(255,255,255,0.08);display:flex;flex-direction:column;justify-content:space-between;padding:18px;">
        <div style="font-family:'IBM Plex Mono',monospace;font-size:9.5px;letter-spacing:0.18em;text-transform:uppercase;color:rgba(255,255,255,0.45);">SPONSORED · VIDEO</div>
        <div style="text-align:center;"><div class="ff-display" style="font-size:26px;color:#F0DCB8;line-height:1.05;">Daily Grind Co.</div><div style="font-size:13px;color:rgba(240,220,184,0.7);margin-top:6px;">Fresh-roasted beans, delivered weekly.</div></div>
        <div style="font-family:'IBM Plex Mono',monospace;font-size:9.5px;letter-spacing:0.16em;text-transform:uppercase;color:rgba(255,255,255,0.4);text-align:center;">[ ad creative placeholder ]</div>
      </div>
    </div>
    <div style="background:#161210;border-top:1px solid rgba(255,255,255,0.08);padding:16px 20px 20px;text-align:center;margin-top:14px;">
      <div style="font-family:'IBM Plex Mono',monospace;font-size:9.5px;letter-spacing:0.14em;text-transform:uppercase;color:rgba(255,255,255,0.5);margin-bottom:5px;">YOUR REWARD</div>
      <div class="ff-display" style="font-size:19px;color:#fff;line-height:1.1;">15 minutes of Coffee Atlas</div>
      <div style="margin-top:12px;height:34px;border-radius:2px;background:var(--accent);color:var(--accent-ink);display:grid;place-items:center;font-size:13px;font-weight:500;">Claim 15 min free</div>
    </div>
  </div>`;
}

// faux app content rendered behind the lock treatments
function lockFauxPreview() {
  const rows = [0, 1, 2, 3].map(() => `<div style="height:40px;border:1px solid var(--rule);border-radius:8px;background:var(--surface);"></div>`).join('');
  return `<div style="padding:26px 16px 0;">
    <div style="${SMALLCAPS}">COFFEE ATLAS</div>
    <div class="ff-display" style="font-size:19px;color:var(--ink);margin-top:4px;">Origins</div>
    <div style="display:flex;flex-direction:column;gap:9px;margin-top:14px;">${rows}</div>
  </div>`;
}

function miniLockCard(glass) {
  return `<div style="width:84%;max-width:208px;border-radius:14px;padding:16px 14px;text-align:center;background:${glass ? 'color-mix(in oklab,var(--surface) 82%,transparent)' : 'var(--surface)'};border:1px solid var(--rule);box-shadow:0 18px 40px rgba(0,0,0,0.28);${glass ? 'backdrop-filter:blur(6px);-webkit-backdrop-filter:blur(6px);' : ''}">
    <span style="width:38px;height:38px;border-radius:999px;margin:0 auto;display:grid;place-items:center;background:color-mix(in oklab,var(--accent) 14%,var(--surface));color:var(--accent);">${gLockGlyph(18, 1.8)}</span>
    <div style="${SMALLCAPS}margin-top:10px;">PLUS FEATURE</div>
    <div class="ff-display" style="font-size:19px;color:var(--ink);margin-top:3px;line-height:1.1;">Coffee Atlas</div>
    <div style="margin-top:12px;height:30px;border-radius:2px;background:var(--accent);color:var(--accent-ink);display:grid;place-items:center;font-size:13px;font-weight:500;">Unlock</div>
  </div>`;
}

function lockMini(kind) {
  let inner;
  if (kind === 'hard') {
    inner = `<div style="position:absolute;inset:0;display:grid;place-items:center;padding:14px;background:var(--bg);">${miniLockCard(false)}</div>`;
  } else if (kind === 'curtain') {
    inner = `<div style="position:absolute;inset:0;">${lockFauxPreview()}</div>
      <div style="position:absolute;inset:0;background:linear-gradient(180deg,transparent 0%,color-mix(in oklab,var(--bg) 30%,transparent) 34%,var(--bg) 72%);"></div>
      <div style="position:absolute;inset:0;display:flex;align-items:flex-end;justify-content:center;padding:0 12px 18px;">${miniLockCard(false)}</div>`;
  } else {
    inner = `<div style="position:absolute;inset:0;filter:blur(5px) saturate(0.8);transform:scale(1.06);opacity:0.9;">${lockFauxPreview()}</div>
      <div style="position:absolute;inset:0;background:color-mix(in oklab,var(--bg) 55%,transparent);"></div>
      <div style="position:absolute;inset:0;display:grid;place-items:center;padding:14px;">${miniLockCard(true)}</div>`;
  }
  const caps = { blur: 'BLUR · frosted peek', hard: 'HARD · no preview', curtain: 'CURTAIN · partial reveal' };
  return `<div><div class="lock-mini">${inner}</div><div class="lock-mini-cap">${caps[kind]}</div></div>`;
}

function renderGating() {
  const wrap = el('div', { class: 'comp-grid' });

  wrap.append(comp('Lock affordances',
    'Anywhere a Plus surface is referenced for a free user — header icons, profile cards, list rows, and the live trial countdown.',
    'Accent is the Plus colour. The PLUS pill labels gated entries; the lock badge pins to a header icon; the trial pill counts down a temporary unlock and is the only moving element. Never gate with a grey-out alone — always pair a lock mark with a way in.',
    affordancesDemo()));

  wrap.append(comp('Plus gate sheet',
    'The bottom sheet shown the moment a free user taps any locked feature.',
    'Two ways out, never a dead end: upgrade (primary) or watch one ad for a short trial (ghost). Lead with the feature’s name and its one-line value, not the price. “Not now” always present.',
    gateSheetDemo()));

  wrap.append(comp('Rewarded ad',
    'The simulated rewarded video reached from the gate sheet’s “watch an ad” path.',
    'Full-bleed dark — the one place the app leaves its warm theme, so the ad reads as a separate context. Close is de-emphasised until the countdown ring completes; the reward is always restated before the claim.',
    adDemo()));

  const treat = el('div', { class: 'panel comp comp-wide' },
    el('div', { class: 'panel-head' },
      el('div', { class: 'ff-display comp-title' }, 'Feature-lock treatments'),
      el('div', { class: 'mono eyebrow dim' }, '3 styles'),
    ),
    el('div', { class: 'comp-demo' },
      el('div', { class: 'lock-mini-grid', html: lockMini('blur') + lockMini('hard') + lockMini('curtain') }),
    ),
    el('div', { class: 'kv' },
      el('div', null, el('span', { class: 'mono klabel' }, 'WHERE'), el('span', { class: 'kval' }, 'Wraps a whole gated tab (Atlas, Dictionary, Duel, Saved, Studio) for a free user. One style is chosen per surface.')),
      el('div', null, el('span', { class: 'mono klabel' }, 'RULE'), el('span', { class: 'kval' }, 'Blur teases the real screen behind frosted glass (glass lock card); hard shows an opaque panel with no preview (solid card); curtain keeps the top of the screen legible and raises a gradient curtain with the card at the bottom. Lower the curtain for content worth previewing, go hard when a preview gives the value away.')),
    ),
  );
  wrap.append(treat);

  return section('plus', 'Monetization', 'Plus and paywall',
    'The gating layer that turns free users into Plus members — the lock affordances, the upgrade-or-watch-an-ad sheet, the rewarded ad, and the three ways a whole feature can be locked. Every lock offers a way in; none is a dead end.',
    wrap);
}

/* ============================================================================
   7 · FLAGS — inconsistencies + proposed fixes
   ========================================================================== */
const FLAGS = [];
function renderFlags() {
  const list = el('div', { class: 'stack-cards' });
  FLAGS.forEach(f => {
    const body = el('div', { class: 'flag-body' },
      el('div', null, el('span', { class: 'mono klabel' }, 'NOW'), el('span', { class: 'kval' }, f.problem)),
      el('div', null, el('span', { class: 'mono klabel acc' }, f.done ? 'DECISION' : 'PROPOSED'), el('span', { class: 'kval' }, f.fix)),
    );
    if (f.done && f.applied) {
      body.append(el('div', null, el('span', { class: 'mono klabel done' }, 'APPLIED'), el('span', { class: 'kval' }, f.applied)));
    }
    list.append(el('div', { class: 'flag flag-' + f.sev + (f.done ? ' flag-done' : '') },
      el('div', { class: 'flag-head' },
        el('span', { class: 'mono sev sev-' + (f.done ? 'done' : f.sev) },
          f.done ? 'RESOLVED' : f.sev === 'high' ? 'NEEDS DECISION' : f.sev === 'med' ? 'SHOULD FIX' : 'POLISH'),
        el('div', { class: 'ff-display flag-title' }, f.title),
      ),
      body,
    ));
  });
  if (!FLAGS.length) {
    return section('flags', 'Audit', 'Flags and fixes',
      'Nothing open. Every flag raised against this system has been fixed and removed — the bean does one job, the type ladder is enforced, --warn means celebration alone, and the chrome marks each have a single definition. New drift gets listed here as it is found.',
      el('div', { class: 'flag flag-low' },
        el('div', { class: 'flag-head' },
          el('span', { class: 'mono sev sev-done' }, 'ALL CLEAR'),
          el('div', { class: 'ff-display flag-title' }, 'No open flags'),
        ),
      ));
  }
  const doneCount = FLAGS.filter(f => f.done).length;
  const word = ['None', 'One', 'Two', 'Three', 'Four', 'Five', 'Six'][doneCount] || doneCount;
  let intro;
  if (doneCount === 0) {
    intro = 'Where the system still drifts from its own logic — with a proposed correction for each. Resolved flags are removed from this list once the fix ships, so what remains is the open work.';
  } else if (doneCount === FLAGS.length) {
    intro = `Where the system drifted from its own logic — with the correction made for each. All ${word.toLowerCase()} have been applied; the system is consistent with itself again.`;
  } else {
    intro = `Where the system already drifts from its own logic — with a proposed correction for each. ${word} ${doneCount === 1 ? 'has' : 'have'} been applied; the rest are decisions for you to make.`;
  }
  return section('flags', 'Audit', 'Flags and fixes', intro, list);
}

/* ============================================================================
   section shell + boot
   ========================================================================== */
function section(id, eyebrow, title, intro, body) {
  return el('section', { id, class: 'ds-section' },
    el('div', { class: 'sec-head' },
      el('div', { class: 'mono eyebrow acc' }, eyebrow),
      el('h2', { class: 'ff-display' }, title),
      el('p', { class: 'sec-intro' }, intro),
    ),
    body,
  );
}

const SECTIONS = [
  ['color', 'Colour'], ['type', 'Type'], ['shape', 'Shape'],
  ['icons', 'Icons'], ['components', 'Components'], ['plus', 'Plus'], ['flags', 'Flags'],
];

function boot() {
  const main = document.getElementById('ds-main');
  main.append(renderColors(), renderType(), renderShape(), renderIcons(), renderComponents(), renderGating(), renderFlags());

  // nav
  const nav = document.getElementById('ds-nav');
  SECTIONS.forEach(([id, label]) => {
    const a = el('a', { href: '#' + id, 'data-target': id }, label);
    nav.append(a);
  });
  // scroll-spy
  const links = [...nav.querySelectorAll('a')];
  const obs = new IntersectionObserver((entries) => {
    entries.forEach(e => {
      if (e.isIntersecting) {
        links.forEach(l => l.classList.toggle('active', l.dataset.target === e.target.id));
      }
    });
  }, { rootMargin: '-45% 0px -50% 0px' });
  document.querySelectorAll('.ds-section').forEach(s => obs.observe(s));
}
document.addEventListener('DOMContentLoaded', boot);
