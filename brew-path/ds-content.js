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
  ['--water',      'Water',              'Water itself, wherever it is drawn as an object rather than a diagram — the loading screen’s drop, the bloom. The one cool token; never an action, never a status. --water-hi is its highlight.', '#5C93B8', '#7FB4D6'],
  ['--scrim',      'Media scrim',        'The tint behind a control that sits on video or photography. The one token that is identical in both moods — media does not invert with the theme, so its scrim must not either. --scrim-ink is the glyph on top.', '#1B1614 58%', '#1B1614 58%'],
  ['--dim-modal',  'Modal dim',          'Behind a bottom sheet — the app’s one blocking overlay. Also mood-independent: a modal must darken in both moods, so it never binds to --ink. Paired with a 5px backdrop blur.', '#0E0A07 62%', '#0E0A07 62%'],
  ['--veil',       'Veil',               'A soft wash over content that is still meant to be seen — the Plus feature lock. This one does follow the mood, because it is the page background pulled over the page. --veil-strong (82%) is the near-opaque step for a cover that only hints at what is under it.', 'bg 38%', 'bg 38%'],
];

// Literal coffee, for illustration and data art only. These do NOT flip with
// the mood: a ripe cherry is the same colour under any theme. Keeping them
// separate is what lets --warn mean exactly one thing.
const ART = [
  ['--art-raw',         'Green coffee',   'Unroasted bean — the first stage of the roast meter.',              '#9FB088'],
  ['--art-roast-light', 'Light roast',    'Roast-scale art, roast meter, cherry-to-cup diagrams.',                '#C79A63'],
  ['--art-roast-mid',   'Medium roast',   'The middle of any roast ramp; the roast-scale card tint. Light / medium / dark on the Roast practical card are these three, not a second set of browns.', '#A2703C'],
  ['--art-roast-deep',  'Deep roast',     'The fourth stop of the five-stop roast ramp the roast meter interpolates through.', '#7A4526'],
  ['--art-roast-dark',  'Dark roast',     'The dark end of the ramp. Stops short of espresso so it survives the dark mood.', '#54301C'],
  ['--art-ripe',        'Ripe cherry',    'Fruit at harvest, and the spectrum card tint.', '#C8843A'],
  ['--art-sour',        'Sour axis',      'The sour end of taste diagrams, opposite berry for bitter.',            '#B79A3C'],
  ['--cream',           'Art highlight',  'The warm highlight on an illustration fill — crema shine, a snow cap, the gloss on a droplet.', '#F0DCB8'],
  ['--art-cherry-skin', 'Cherry · skin',  'Outermost layer of the cherry in section. The ramp below is ONE definition shared by the Layers card and the practical cross-section.', '#A93227'],
  ['--art-cherry-pulp', 'Cherry · pulp',  'The thin layer of sweet fruit under the skin.',                        '#C9563A'],
  ['--art-cherry-gel',  'Cherry · gel',   'Mucilage — the honey-sweet gel washed, honey and natural argue over.',  '#D9A94C'],
  ['--art-cherry-parchment','Cherry · parchment','The papery shell coffee ships inside.',                          '#E3D2AE'],
  ['--art-cherry-silverskin','Cherry · silverskin','The tissue membrane that becomes chaff; also the bean crease highlight.', '#F1E8D6'],
  ['--art-cherry-seed', 'Cherry · seed',  'The green seed. This is your coffee.',                                  '#8FA184'],
  ['--art-seed-crease', 'Seed crease',    'The line splitting the two seeds in any cherry section.',               '#5C6B52'],
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
    'Fifteen UI tokens across two named moods, plus a separate literal palette for illustration. Both moods carry the same fifteen roles — design once, the theme swaps underneath. Accent is the only true brand colour; sage, warn and berry are reserved for meaning, never decoration; water is the one cool token and belongs to water as an object. The two overlay tokens that sit on fixed things — scrim on media, dim-modal behind a sheet — deliberately do not swap with the mood, while veil does, because it is the background pulled over the background. Warmth in artwork comes from the --art-* palette so celebration keeps its own colour.',
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
  { fam: 'Fraunces italic', cls: 'ff-display type-italic', role: 'Aside / spoken',
    use: 'Roasty’s own words and anything quoted or murmured: the loading caption, Roasty’s line under the mascot in onboarding, a recall card’s clue, the duel “vs”, the sleeping Zzz.',
    rule: 'Heading (19) or body (15), weight 400, usually ink-mute — ink only when it is the screen’s single line. It marks voice, never emphasis: never italicise a title, a label, a control, or a word inside body copy.',
    sample: 'Brewing your lesson', size: '26px' },
  { fam: 'IBM Plex Sans', cls: 'ff-ui', role: 'Interface / body',
    use: 'All body copy, buttons, list titles, answer choices — and every smallcaps label. The default.',
    rule: 'Two weights — 400 body, 500 for controls, emphasis & smallcaps. Sizes 17 / 15 / 13 / 11 / 9.5. Smallcaps labels are UPPERCASE at 11 or 9.5, weight 500, 0.14em tracking (.smallcaps).',
    sample: 'Pour-over starts with a short bloom.', size: '17px' },
  { fam: 'IBM Plex Mono', cls: 'ff-mono', role: 'Data / labels',
    use: 'Metadata, points & time values, any aligned number — and the caps marks that are brand or ceremony rather than UI labels: BREWPATH and the tap-to-continue cue on the intro screens.',
    rule: 'Tabular numerals, weight 500. Caps marks 0.14–0.18em tracking — with one sanctioned exception, the intro screens’ caps marks (BREWPATH and the tap cue) at 0.24em. 13 / 11 / 9.5 — plus 26 & 56 for stat numerals only. Use .smallcaps-mono only when the label carries a number that must align.',
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
    'Three families, four jobs — expressive, spoken, functional, factual. The split is strict: if it is a number or a label it is mono; if it is a control or a sentence it is Plex Sans; if it is a title it is Fraunces; if it is Roasty talking it is Fraunces italic. Smallcaps labels belong to Plex Sans, not mono — mono keeps the numbers and the brand marks. One nine-step ladder is shared by every screen, and it is enforced rather than described: the app has no literal font sizes left — every rule and every inline style reads a --t-* token, so an off-ladder size has to be added to the ladder before it can be used. The one exception is the iOS device frame, which follows Apple\'s own metrics.',
    wrap);
}

/* ============================================================================
   3 · SHAPE & SPACE
   ========================================================================== */
function renderShape() {
  const radii = [
    ['2px',   'Editorial', 'Cards, buttons, inputs, MCQ & match tiles. The sharp, print-like default.'],
    ['14px · --r', 'Soft chrome', 'Media frames, bottom sheets, icon wells, avatars, mini-game tiles. Friendly, app-like. 14px is the token; 12–20 is the range other chrome may sit in.'],
    ['999px', 'Pill / dot', 'Status dots, fav toggle, switch toggles, badges, the home indicator.'],
  ];
  const rwrap = el('div', { class: 'shape-grid' });
  radii.forEach(([r, name, use]) => {
    rwrap.append(el('div', { class: 'shape-card' },
      el('div', { class: 'shape-demo', style: `border-radius:${r === '14px · --r' ? '14px' : r === '2px' ? '2px' : '999px'};` }),
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
      el('li', null, el('b', null, 'Media is chrome, not content. '), 'Any frame holding video or an image takes --r (14px), never the 2px editorial radius — a photograph has no print edge to honour.'),
    ),
  );
  return section('shape', 'Foundations', 'Shape and space',
    'Two radius languages run in parallel: sharp 2px for editorial content, soft 14px (--r) for playful chrome and media. Mixing them on one element is the tell of an off-system component.',
    el('div', { class: 'stack-cards' }, rwrap, notes));
}

/* ============================================================================
   4 · ICONS  — the full catalog
   ========================================================================== */
const ICONS = {
  nav: {
    title: 'Navigation', count: '5 tabs · 4 in v1',
    rule: 'One tab, one coffee-vocabulary shape — drawn at 24×24, stroke 1.6. Outlined in ink-mute when inactive, filled in accent when active. This is the master icon family every other set should defer to. Five concepts are drawn; v1 ships four — Globe / Atlas is built and kept here so the family stays whole, but the tab is held back for v2.',
    items: [
      ['Cup', 'Today (Learn)', 'The everyday drink → the lessons home. Labelled TODAY in the shipped tab nav; it becomes LEARN only in the merged nav model, where Path folds into it.',
        svg('0 0 24 24', '<path d="M9 3 Q10 4.5 9 6 Q8 7.5 9 9" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" opacity="0.7"/><path d="M12 3 Q13 4.5 12 6 Q11 7.5 12 9" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" opacity="0.7"/><path d="M15 3 Q16 4.5 15 6 Q14 7.5 15 9" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" opacity="0.7"/><path d="M5 10.5 L19 10.5 L18 19 Q17.5 20.5 16 20.5 L8 20.5 Q6.5 20.5 6 19 Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M19 12.5 Q22 12.5 22 15.5 Q22 18 19 18" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>', 1.6)],
      ['Route', 'Path', 'A trail of stops → the structured learning journey.',
        svg('0 0 24 24', '<path d="M4 20 Q8 18 9 14 Q10 8 14 7 Q18 6 20 4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-dasharray="0.1 3.4"/><circle cx="4" cy="20" r="2.1" stroke="currentColor" stroke-width="1.6"/><circle cx="10" cy="13" r="2.1" stroke="currentColor" stroke-width="1.6"/><circle cx="20" cy="4" r="2.4" stroke="currentColor" stroke-width="1.6"/>', 1.6)],
      ['Globe', 'Atlas · v2', 'The world → coffee origins & geography. Drawn and in use inside the Atlas screens; the tab itself is deferred to v2.',
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
      ['Grind', 'Grind (module)', 'Hand grinder with its crank, burr line across the body. The Grind module’s own mark.',
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
    title: 'Actions and navigation', count: '12 controls',
    rule: 'Workhorse interface glyphs — small chrome marks, not part of the 24×24 concept family, so they keep a lighter 1.4–1.7 range. Ink for primary actions, ink-mute for passive affordances, accent only when the control itself is the primary action.',
    items: [
      ['Chevron', 'Drill in', 'Trailing affordance on a tappable row. One shared definition at 70% ink-mute — rows never draw their own.',
        svg('0 0 8 14', '<path d="M1 1l6 6-6 6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>', 1.5)],
      ['Arrow', 'Direction along a scale', 'Slider endpoints and any labelled range. Shaft plus head, because it states a DIRECTION — Chevron is a head alone and states “more this way”. Same 1.5 stroke as Chevron so the two never clash. Rotate 180° for the left end; never redraw it mirrored.',
        svg('0 0 14 10', '<path d="M1.25 5h10.5M8.6 1.9L11.75 5 8.6 8.1" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>', 1.5)],
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

// Specimen helpers for the stateful entries below (module scope so every
// entry can reach them, unlike the locals inside the older *Demo functions).
function dsToggle(on) {
  return '<span style="position:relative;width:44px;height:26px;padding:3px;border-radius:999px;box-sizing:border-box;display:inline-block;border:1px solid ' + (on ? 'var(--accent)' : 'var(--rule)') + ';background:' + (on ? 'var(--accent)' : 'transparent') + ';"><span style="display:block;width:18px;height:18px;border-radius:999px;background:' + (on ? 'var(--accent-ink)' : 'var(--ink-mute)') + ';transform:translateX(' + (on ? '18px' : '0') + ');"></span></span>';
}
const glyphLearned = '<span style="width:20px;height:20px;border-radius:999px;background:color-mix(in oklab, var(--sage) 22%, var(--surface));border:1px solid color-mix(in oklab, var(--sage) 55%, var(--rule));display:grid;place-items:center;flex-shrink:0;"><svg width="10" height="10" viewBox="0 0 12 12"><path d="M2 6.2 L5 9 L10 3" fill="none" stroke="var(--sage)" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"/></svg></span>';
const glyphTodo = '<span style="width:20px;height:20px;border-radius:999px;border:1.5px dashed var(--rule);display:grid;place-items:center;flex-shrink:0;"><span style="width:4px;height:4px;border-radius:999px;background:var(--ink-mute);opacity:0.5;"></span></span>';
const fav32 = '<span style="width:32px;height:32px;border-radius:999px;border:1px solid var(--rule);display:grid;place-items:center;flex-shrink:0;"><svg width="13" height="13" viewBox="0 0 20 20" fill="none"><path d="M5 3.5 H15 V17 L10 13.5 L5 17 Z" stroke="var(--ink-mute)" stroke-width="1.5" stroke-linejoin="round"/></svg></span>';
function termRow(glyph, term, pron, cat) {
  return '<div style="display:flex;align-items:center;gap:12px;width:100%;">' + glyph +
    '<span style="flex:1;min-width:0;"><span style="display:flex;align-items:baseline;gap:8px;"><span style="font-size:15px;font-weight:500;color:var(--ink);">' + term +
    '</span><span class="mono" style="font-size:11px;color:var(--ink-mute);">' + pron +
    '</span></span><span style="display:block;font-size:13px;color:var(--ink-mute);margin-top:3px;">' + cat + '</span></span>' + fav32 + '</div>';
}
function refCard(playable) {
  return '<div style="display:grid;grid-template-columns:28px 1fr auto;align-items:center;gap:14px;background:var(--surface);border:1px solid var(--rule);border-radius:12px;padding:14px 16px;width:100%;' + (playable ? '' : 'opacity:0.75;') + '">' +
    beanDemo(playable ? 1 : 0, 'var(--sage)') +
    '<span style="min-width:0;"><span class="mono" style="display:block;font-size:9.5px;letter-spacing:0.14em;text-transform:uppercase;color:var(--ink-mute);">Module 2 \u00b7 Processing</span><span style="display:block;font-size:15px;font-weight:500;color:var(--ink);margin-top:2px;">Washed, natural, honey</span></span>' +
    '<span class="mono" style="font-size:9.5px;letter-spacing:0.12em;text-transform:uppercase;color:' + (playable ? 'var(--accent)' : 'var(--ink-mute)') + ';">' + (playable ? 'Open \u2192' : 'Soon') + '</span></div>';
}

// Same panel as comp(), but the rule is a LIST. Long prose rules are unusable
// at build time; each bullet should be one enforceable sentence.
function compRules(name, purpose, exampleHTML, rules) {
  return el('div', { class: 'panel comp' },
    el('div', { class: 'panel-head' }, el('div', { class: 'ff-display comp-title' }, name)),
    el('p', { class: 'comp-purpose' }, purpose),
    el('div', { class: 'comp-demo', html: exampleHTML }),
    el('ul', { class: 'rules tight' }, rules.map(r => el('li', { html: r }))),
  );
}

// A stateful component is documented as SPECIMENS, not prose: one cell per
// state, each carrying the live element, when it appears, and the spec you would
// need to build it. Rules below the grid say only what the cells cannot show.
function compStates(name, purpose, states, rules, min) {
  const grid = el('div', { class: 'state-grid', style: 'grid-template-columns:repeat(auto-fill,minmax(' + (min || 210) + 'px,1fr));' },
    states.map(s => el('div', { class: 'state-cell' },
      el('div', { class: 'state-demo', html: s.demo }),
      el('div', { class: 'state-name' }, s.label),
      el('div', { class: 'state-when' }, s.when),
      el('div', { class: 'state-spec' }, (s.spec || []).map(t => el('span', { class: 'spec-chip' }, t))),
    )));
  return el('div', { class: 'panel comp states' },
    el('div', { class: 'panel-head' }, el('div', { class: 'ff-display comp-title' }, name)),
    el('p', { class: 'comp-purpose' }, purpose),
    grid,
    rules && rules.length ? el('ul', { class: 'rules' }, rules.map(r => el('li', { html: r }))) : null,
  );
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

  wrap.append(compStates('Buttons',
    'One primary action per screen, a ghost for the second, a link for tertiary text actions.',
    [
      { label: 'Primary', demo: '<button class="btn btn-primary">Continue</button>',
        when: 'The single main action \u2014 Continue, Share, Accept.',
        spec: ['--accent', '--accent-ink', 'radius 2px', 'full width'] },
      { label: 'Primary \u00b7 disabled', demo: '<button class="btn btn-primary" disabled>Make a guess</button>',
        when: 'The action exists but its requirement is unmet \u2014 nothing picked yet.',
        spec: ['opacity 0.35', 'cursor not-allowed', 'stays visible'] },
      { label: 'Ghost', demo: '<button class="btn btn-ghost">Not now</button>',
        when: 'The second action in any bottom stack \u2014 dismiss, skip, back.',
        spec: ['transparent', '1px --rule', '--ink'] },
      { label: 'Link', demo: '<button class="btn btn-link">What is a washed coffee?</button>',
        when: 'Tertiary, inline in running content only.',
        spec: ['--accent', '13px', 'no border'] },
    ],
    [
      'Only <b>one</b> primary per screen \u2014 if two things compete, one of them is a ghost.',
      'A dismiss sitting under a primary (Not now, Maybe later, Back to Path) is a <b>ghost</b>, never a bare link.',
      'Disabled is never hidden: the learner has to see what the button is waiting for.',
    ]));

  wrap.append(compStates('Pick card',
    'Onboarding choices and any single- or multi-select list \u2014 goal, brewer, level.',
    [
      { label: 'Default', demo: '<div class="pick-card" style="min-width:180px;"><div><div class="pc-title">Filter</div><div class="pc-desc">Pour-over, drip, French press</div></div></div>',
        when: 'Available, not chosen.',
        spec: ['--surface', '1px --rule'] },
      { label: 'Selected', demo: '<div class="pick-card selected" style="min-width:180px;"><div><div class="pc-title">Espresso</div><div class="pc-desc">Machine or moka pot</div></div></div>',
        when: 'Chosen \u2014 one in a single-select, any number in a multi.',
        spec: ['--accent border', 'inset 0 0 0 1px --accent'] },
    ],
    [
      'Selection is a <b>stroke</b>, never a fill \u2014 a filled card reads as disabled at a glance.',
      'Never mark selection with a bean: partial fill belongs to the mastery gauge alone, so it cannot double as a radio.',
    ], 240));

  wrap.append(compStates('Pick tile',
    'The predict card\u2019s two-up guess \u2014 the only choice control that is never graded.',
    [
      { label: 'Default', demo: '<button class="pick-tile" style="min-width:130px;"><span class="pick-tile-t">Seed</span></button>',
        when: 'Available, no guess yet.',
        spec: ['--surface', '1px --rule', 'radius 14', 'Fraunces 19'] },
      { label: 'Chosen', demo: '<button class="pick-tile chosen" style="min-width:130px;"><span class="pick-tile-t">Seed</span></button>',
        when: 'The sealed guess \u2014 a claim, not a verdict. Switchable until \u201cFind out\u201d.',
        spec: ['--accent border', 'accent 12% fill'] },
      { label: 'Faded', demo: '<button class="pick-tile faded" style="min-width:130px;"><span class="pick-tile-t">Skin</span></button>',
        when: 'The unpicked sibling once a guess is in.',
        spec: ['opacity 0.62', 'still tappable'] },
    ],
    [
      'Accent means <b>committed</b>, never correct \u2014 sage and berry are banned here; the guess resolves on the recall card.',
      'Exception to the stroke-only rule: the 12% accent wash is allowed because there is no graded fill for it to be mistaken for.',
      'Always exactly two tiles, side by side \u2014 three or more choices belong to MCQ rows.',
    ], 150));

  wrap.append(compStates('MCQ choice',
    'Every multiple-choice row \u2014 lesson cards, mini-games, the dictionary knowledge check and the vocab game.',
    [
      { label: 'Default', demo: '<div class="mcq-choice">A seed inside a fruit</div>',
        when: 'Unanswered and tappable.',
        spec: ['--surface', '1px --rule', 'radius 2px'] },
      { label: 'Correct', demo: '<div class="mcq-choice correct">A seed inside a fruit</div>',
        when: 'The right answer, once the card is answered \u2014 shown whether or not it was picked.',
        spec: ['--sage border', 'sage 12% fill'] },
      { label: 'Incorrect', demo: '<div class="mcq-choice incorrect">A kind of bean</div>',
        when: 'Only on the row the learner picked, when it was wrong.',
        spec: ['--berry border', 'berry 8% fill'] },
    ],
    [
      'One tap locks the whole set \u2014 there is no second guess on a graded card.',
      'The correct row always reveals itself, so a wrong answer still leaves with the right one.',
      'Never colour an unpicked wrong row: only the mistake the learner actually made is marked.',
    ], 240));

  wrap.append(compStates('Lesson row',
    'The Path and Module screens \u2014 bean node, title, mono meta.',
    [
      { label: 'Complete', demo: '<div class="lesson-row" style="width:100%;"><span>' + miniBean(1, 'var(--sage)') + '</span><span class="title">What coffee actually is</span><span class="meta"></span></div>',
        when: 'Passed. No chip \u2014 the full sage bean already says it.',
        spec: ['sage bean 100%', 'no chip'] },
      { label: 'Current', demo: '<div class="lesson-row" style="width:100%;"><span>' + miniBean(0, 'var(--accent)') + '</span><span class="title">Arabica vs Robusta</span><span class="meta">' + chip('CURRENT', 'var(--accent)', true) + '</span></div>',
        when: 'The next lesson the Path points at.',
        spec: ['empty bean', 'accent chip'] },
      { label: 'Needs practice', demo: '<div class="lesson-row" style="width:100%;"><span>' + miniBean(0.4, 'var(--accent)') + '</span><span class="title">What origin means</span><span class="meta">' + chip('PRACTICE', 'var(--accent)', true) + '</span></div>',
        when: 'Finished below the pass mark \u2014 the bean shows how far short.',
        spec: ['accent bean, part fill', 'accent chip'] },
      { label: 'Locked', demo: '<div class="lesson-row locked" style="width:100%;"><span>' + miniBean(0, 'var(--ink-mute)') + '</span><span class="title">Reading a bag label</span><span class="meta">' + chip('LOCKED', 'var(--ink-mute)', false) + '</span></div>',
        when: 'Ahead of where the learner has reached.',
        spec: ['opacity 0.4', 'hollow chip'] },
    ],
    [
      'The bean carries the score and the chip carries the state \u2014 they never say the same thing, which is why a passed lesson has no chip.',
      'Rows are separated by a hairline, never boxed: the Path reads as one column, not a stack of cards.',
    ], 300));

  wrap.append(compRules('Form row',
    'The "cupping form" pattern — specs, settings, brew parameters, duel stats.',
    `<div class="card" style="padding:6px 18px;">
       <div class="form-row"><span class="lbl">RATIO</span><span class="val">1 : 16</span></div>
       <div class="form-row"><span class="lbl">WATER</span><span class="val">93 °C</span></div>
       <div class="form-row"><span class="lbl">TIME</span><span class="val">2:45</span></div>
     </div>`, ['Uppercase mono label left, tabular mono value right.', 'Hairline between rows; values align to the right edge.']));

  wrap.append(compStates('Status chips',
    'Lesson and term state wherever either is listed \u2014 rows, headers, filters.',
    [
      { label: 'Learned', demo: chip('LEARNED', 'var(--sage)', true),
        when: 'A term you have met in a lesson.',
        spec: ['--sage', 'filled dot'] },
      { label: 'Current', demo: chip('CURRENT', 'var(--accent)', true),
        when: 'The one lesson the Path is pointing at.',
        spec: ['--accent', 'filled dot'] },
      { label: 'Practice', demo: chip('PRACTICE', 'var(--accent)', true),
        when: 'Finished below the pass mark \u2014 something to act on.',
        spec: ['--accent', 'filled dot'] },
      { label: 'Locked', demo: chip('LOCKED', 'var(--ink-mute)', false),
        when: 'Not reachable yet.',
        spec: ['--ink-mute', 'hollow dot'] },
    ],
    [
      'A lesson at or above the pass mark gets <b>no chip</b> \u2014 its bean node already says how it went, and a green tick beside a full bean is the same sentence twice.',
      'Accent always means <i>there is something to do</i>; sage means done; hollow means wait.',
    ]));

  wrap.append(compStates('Match tiles',
    'Match cards inside a lesson, and the g-match mini-game that reuses them.',
    [
      { label: 'Idle', demo: '<div class="match-item">Robusta</div>',
        when: 'Waiting to be picked.',
        spec: ['--surface', '1px --rule'] },
      { label: 'Selected', demo: '<div class="match-item selected">More caffeine</div>',
        when: 'First half of a pair is chosen, waiting for its partner.',
        spec: ['--accent border', 'inset 0 0 0 1px --accent'] },
      { label: 'Matched', demo: '<div class="match-item matched">Arabica \u00b7 Higher grown</div>',
        when: 'Pair locked \u2014 the tile is now inert.',
        spec: ['--sage border', 'sage 10% fill', '--ink-mute text'] },
    ],
    [
      'A matched tile is <b>inert</b>: it cannot be unpicked, so the board only ever shrinks.',
      'Selection uses the same accent inset as the pick card \u2014 one selection language across the app.',
    ]));

  wrap.append(compStates('Save toggle',
    'Lessons, terms, cards, guides, games \u2014 the one favouriting control in the app.',
    [
      { label: 'Default', demo: favBtn(false),
        when: 'Not saved. Sits outside the row\u2019s main tap target so it never steals the open.',
        spec: ['1px --rule', '--ink-mute glyph', 'round'] },
      { label: 'Saved', demo: favBtn(true),
        when: 'On the Saved shelf. Free users hit a cap of 10 and get the Plus gate instead.',
        spec: ['--accent border', 'accent fill'] },
    ],
    [
      'Sizes are contextual \u2014 38px standalone, 36px in a sheet header, 32\u201334px in a row \u2014 but the glyph and states never change.',
      'Unsaving is always allowed, even past the free cap: a capped shelf must stay curatable.',
    ]));

  wrap.append(compStates('Collectible card',
    'The Cards collection grid \u2014 3:4 portrait, Fraunces title, mono catalogue number.',
    [
      { label: 'Earned', demo: '<div class="collect-card" style="width:120px;"><div class="cc-sub">CARD 04 / 36</div><div class="cc-title">The Coffee Cherry</div></div>',
        when: 'Unlocked by finishing the lesson that awards it.',
        spec: ['--surface', 'CARD nn / total'] },
      { label: 'Locked', demo: '<div class="collect-card locked" style="width:120px;"><div class="cc-sub">\u2014</div><div class="cc-title">?</div><div class="cc-sub">05 / 36</div></div>',
        when: 'Not yet earned \u2014 only the next one in the catalogue is shown.',
        spec: ['opacity 0.32', 'no detail'] },
    ],
    [
      'The sub is a <b>catalogue number</b>, never a category. nn is the card\u2019s place in the whole set, not in the grid \u2014 cards unlock out of order, so an earned grid legitimately reads 01, 04, 21.',
      'The denominator is what makes those gaps read as positions instead of a broken count.',
      'The Collection header also prints \u201cn of total\u201d; that overlap is intentional \u2014 the header counts what you own, the card states where it sits.',
    ]));

  wrap.append(compRules('Slider',
    'Estimation cards — grind size, ratios, anything on a scale.',
    `<div>
       <div style="display:flex;justify-content:space-between;" class="mono klabel"><span>FINER</span><span>COARSER</span></div>
       <input type="range" class="brew-slider" value="55" min="0" max="100"/>
     </div>`, ['Hairline track, accent thumb ringed in bg.', 'Bounds labelled in mono at each end.']));


  // ── Feedback & progress ────────────────────────────────────

  wrap.append(compSubhead('Dictionary and terms', 'Search field, segmented filter and MCQ choice are documented above'));

  wrap.append(compRules('Term entry header',
    'The top of every full term entry.',
    `<div>
       <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
         <span style="font-family:'IBM Plex Sans',sans-serif;font-size:11px;font-weight:500;letter-spacing:0.14em;text-transform:uppercase;color:var(--accent);display:inline-flex;align-items:center;gap:8px;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" style="color:var(--accent);flex-shrink:0;" aria-hidden="true"><path d="M13.6 5.9 Q 15.2 3.7 17.4 3.5" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/><circle cx="11.8" cy="13.2" r="7" stroke="currentColor" stroke-width="1.6"/><ellipse cx="11.8" cy="13.2" rx="2.9" ry="4.2" transform="rotate(-18 11.8 13.2)" stroke="currentColor" stroke-width="1.3"/></svg>Processing</span>
         <span class="mono" style="font-size:9.5px;letter-spacing:0.16em;text-transform:uppercase;color:var(--ink-mute);display:inline-flex;align-items:center;gap:6px;"><span style="width:6px;height:6px;border-radius:999px;border:1px solid var(--rule);"></span>To learn</span>
       </div>
       <div class="ff-display" style="font-size:32px;line-height:1.02;letter-spacing:-0.03em;color:var(--ink);margin:14px 0 0;">Fermentation</div>
       <div style="margin-top:14px;"><span style="display:inline-flex;align-items:center;gap:8px;border:1px solid var(--rule);border-radius:999px;padding:5px 12px 5px 9px;"><svg width="15" height="15" viewBox="0 0 20 20" fill="none" style="color:var(--accent);"><path d="M4 8 H6.5 L10 4.5 V15.5 L6.5 12 H4 Z" fill="currentColor" stroke="currentColor" stroke-width="1.1" stroke-linejoin="round"/><path d="M13 7.5 a3.5 3.5 0 0 1 0 5" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" opacity="0.7"/></svg><span class="mono" style="font-size:11px;letter-spacing:0.04em;color:var(--ink-mute);">fur-men-TAY-shun</span></span></div>
       <p class="ff-display" style="font-size:19px;line-height:1.35;letter-spacing:-0.01em;color:var(--ink);margin:18px 0 0;">The controlled breakdown of the fruit\u2019s sugars before the seed is dried.</p>
     </div>`, ['Three fixed lines: category eyebrow + status chip, term, pronunciation chip, definition.', 'The definition is set in Fraunces <b>heading</b>, not body \u2014 it is the entry\u2019s thesis.', 'No actions in the header: the bookmark lives in the top bar, the lesson action on the reference card below.']));

  wrap.append(compRules('Pronunciation chip',
    'Term entry, term peek sheet \u2014 anywhere a term is titled and has a respelling.',
    `<div style="display:flex;gap:10px;flex-wrap:wrap;align-items:center;">
       <span style="display:inline-flex;align-items:center;gap:8px;border:1px solid var(--rule);border-radius:999px;padding:5px 12px 5px 9px;"><svg width="15" height="15" viewBox="0 0 20 20" fill="none" style="color:var(--accent);"><path d="M4 8 H6.5 L10 4.5 V15.5 L6.5 12 H4 Z" fill="currentColor" stroke="currentColor" stroke-width="1.1" stroke-linejoin="round"/><path d="M13 7.5 a3.5 3.5 0 0 1 0 5" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" opacity="0.7"/></svg><span class="mono" style="font-size:11px;letter-spacing:0.04em;color:var(--ink-mute);">uh-RAB-ih-kuh</span></span>
       <span style="display:inline-flex;align-items:center;gap:8px;border:1px solid var(--rule);border-radius:999px;padding:4px 10px 4px 8px;"><svg width="15" height="15" viewBox="0 0 20 20" fill="none" style="color:var(--accent);"><path d="M4 8 H6.5 L10 4.5 V15.5 L6.5 12 H4 Z" fill="currentColor" stroke="currentColor" stroke-width="1.1" stroke-linejoin="round"/><path d="M13 7.5 a3.5 3.5 0 0 1 0 5" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" opacity="0.7"/></svg><span class="mono" style="font-size:11px;letter-spacing:0.04em;color:var(--ink-mute);">KREH-muh</span></span>
     </div>`, ['Hairline pill: accent speaker glyph + respelling in mono.', 'Tapping speaks the term and pulses a second arc.', 'Renders only when a respelling exists \u2014 never a bare speaker icon.', 'Respelling, never IPA: the respelling is the readable artefact, the audio is the bonus.',
     'The respelling convention: syllables split by hyphens, <b>exactly one syllable in caps \\u2014 the stressed one</b> (primary stress only, never a secondary beat: <span class="mono">POR-tuh-fil-ter</span>), and sounds spelled as an English reader would guess them \u2014 <span class="mono">uh</span> for a schwa, <span class="mono">ay/ee/oh</span> for long vowels, a trailing <i>a</i> as <span class="mono">-uh</span>.',
     'Names read as letters take no stress cap at all \u2014 acronyms go letter by letter (<span class="mono">S-C-A</span>, <span class="mono">M-A-S-L</span>) and any number is written as a word (<span class="mono">V-sixty</span>, <span class="mono">C-O-two</span>, <span class="mono">S-L twenty-eight</span>). Caps are for stress, and a string of letter names has none.',
     'Spell the sound, not the spelling: Chemex is <span class="mono">KEM-ex</span>, never <span class="mono">CHEM-ex</span> \u2014 if the respelling can be misread, it has failed.',
     'A respelling is authored only where the term is genuinely mispronounceable. Plain English words (Bloom, Body, Fines) carry none and the chip does not render \u2014 do not invent one to fill the line.']));

  wrap.append(compStates('Term status chip',
    'Term entry header and term rows \u2014 the dictionary\u2019s only two states.',
    [
      { label: 'Learned', demo: '<span class="mono" style="font-size:9.5px;letter-spacing:0.16em;text-transform:uppercase;color:var(--sage);display:inline-flex;align-items:center;gap:6px;"><span style="width:6px;height:6px;border-radius:999px;background:var(--sage);"></span>Learned</span>',
        when: 'The term has been met in a lesson.',
        spec: ['--sage', 'filled dot'] },
      { label: 'To learn', demo: '<span class="mono" style="font-size:9.5px;letter-spacing:0.16em;text-transform:uppercase;color:var(--ink-mute);display:inline-flex;align-items:center;gap:6px;"><span style="width:6px;height:6px;border-radius:999px;border:1px solid var(--rule);"></span>To learn</span>',
        when: 'Readable, but not yet taught.',
        spec: ['--ink-mute', 'hollow dot'] },
    ],
    [
      'There is no locked term. Every entry is readable from day one \u2014 only lessons lock, so the dictionary never uses a third state.',
    ]));

  wrap.append(compRules('Related chips',
    'Term entry (RELATED TERMS) and the peek sheet (RELATED) \u2014 the lateral path through the dictionary.',
    `<div style="display:flex;flex-wrap:wrap;gap:8px;">
       <span style="background:var(--surface);border:1px solid var(--rule);border-radius:999px;padding:8px 14px;display:inline-flex;align-items:center;gap:8px;font-size:13px;color:var(--ink);">Washed<span style="width:5px;height:5px;border-radius:999px;background:var(--sage);"></span></span>
       <span style="background:var(--surface);border:1px solid var(--rule);border-radius:999px;padding:8px 14px;display:inline-flex;align-items:center;gap:8px;font-size:13px;color:var(--ink);">Natural process</span>
       <span style="background:var(--surface);border:1px solid var(--rule);border-radius:999px;padding:8px 14px;display:inline-flex;align-items:center;gap:8px;font-size:13px;color:var(--ink);"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" style="color:var(--ink-mute);flex-shrink:0;" aria-hidden="true"><path d="M5.5 8 H16 V12 a4 4 0 0 1 -4 4 H9.5 a4 4 0 0 1 -4 -4 Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M16 9 h2 a2 2 0 0 1 0 4 h-2" stroke="currentColor" stroke-width="1.6"/><path d="M8 4.5 v1.5 M11.5 4.5 v1.5" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" opacity="0.6"/></svg>Crema</span>
     </div>`, ['One pill per term, wrapping.', 'A 5px sage dot marks a term already learned.', 'The category glyph shows <b>only</b> for a term from another category.', 'The current term never appears in its own list.']));

  wrap.append(compStates('Term row',
    'Dictionary home lists, category lists, search results, the Saved shelf.',
    [
      { label: 'Learned', demo: termRow(glyphLearned, 'Arabica', 'uh-RAB-ih-kuh', 'Botany'),
        when: 'Met in a lesson \u2014 sage ring with a check.',
        spec: ['sage 22% fill', 'sage 55% border'] },
      { label: 'To learn', demo: termRow(glyphTodo, 'Mucilage', 'MYOO-sih-lij', 'Processing'),
        when: 'Not taught yet \u2014 a dashed ring with a faint centre dot.',
        spec: ['1.5px dashed --rule', '4px dot at 0.5'] },
    ],
    [
      'The dashed ring is semantic: an unlearned term is <b>provisional</b>, not empty \u2014 a solid empty circle would read as a disabled checkbox.',
      'One line under the term: the category normally, the definition in search results.',
      'The bookmark sits outside the tap target that opens the term.',
    ], 300));

  wrap.append(compStates('Term of the Day',
    'One term surfaced each day \u2014 the dictionary\u2019s daily hook.',
    [
      { label: 'Large', demo: '<div style="width:100%;max-width:250px;border-radius:16px;border:1px solid color-mix(in oklab, var(--accent) 24%, var(--rule));background:linear-gradient(158deg, color-mix(in oklab, var(--accent) 13%, var(--surface)) 0%, var(--surface) 62%);padding:16px;box-shadow:0 14px 34px rgba(0,0,0,0.18);"><div style="font-family:\'IBM Plex Sans\',sans-serif;font-size:11px;font-weight:500;letter-spacing:0.14em;text-transform:uppercase;color:var(--accent);">Term of the day</div><div class="ff-display" style="font-size:26px;line-height:1.04;color:var(--ink);margin-top:10px;">Crema</div><div class="mono" style="font-size:11px;color:var(--ink-mute);margin-top:6px;">KREH-muh</div><div class="mono" style="font-size:9.5px;letter-spacing:0.16em;text-transform:uppercase;color:var(--accent);margin-top:12px;">Open entry \u2192</div></div>',
        when: 'Dictionary home \u2014 the lead of the page.',
        spec: ['accent 13% gradient', 'shadow 0 14px 34px', 'radius 16'] },
      { label: 'Compact', demo: '<div style="width:100%;max-width:250px;display:grid;grid-template-columns:auto 1fr auto;align-items:center;gap:14px;background:var(--surface);border:1px solid var(--rule);border-radius:14px;padding:14px 16px;"><span style="width:40px;height:40px;border-radius:12px;display:grid;place-items:center;background:color-mix(in oklab, var(--accent) 10%, var(--surface));"><svg width="21" height="21" viewBox="0 0 24 24" fill="none" style="color:var(--accent);"><path d="M5.5 8 H16 V12 a4 4 0 0 1 -4 4 H9.5 a4 4 0 0 1 -4 -4 Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M16 9 h2 a2 2 0 0 1 0 4 h-2" stroke="currentColor" stroke-width="1.6"/></svg></span><span><span style="font-family:\'IBM Plex Sans\',sans-serif;font-size:11px;font-weight:500;letter-spacing:0.14em;text-transform:uppercase;color:var(--accent);display:block;">Term of the day</span><span style="display:block;font-size:15px;font-weight:500;color:var(--ink);margin-top:3px;">Crema</span></span><svg width="8" height="13" viewBox="0 0 8 13" fill="none"><path d="M1.5 1.5 L6.5 6.5 L1.5 11.5" stroke="var(--ink-mute)" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg></div>',
        when: 'Today \u2014 one row among the day\u2019s other prompts.',
        spec: ['40px accent tile', 'chevron', 'radius 14'] },
    ],
    [
      'Same label and same term in both \u2014 only the weight in the page changes.',
      'The large card is the <b>one</b> place a gradient and a soft shadow are allowed on a content surface.',
    ], 280));

  wrap.append(compRules('Knowledge check',
    'Inside a term entry, below the teaching text \u2014 the optional \u201cdid that land?\u201d beat.',
    `<div style="background:var(--surface);border:1px solid var(--rule);border-radius:14px;padding:16px;">
       <div style="font-family:'IBM Plex Sans',sans-serif;font-size:11px;font-weight:500;letter-spacing:0.14em;text-transform:uppercase;color:var(--ink-mute);margin-bottom:12px;">Knowledge check</div>
       <div class="ff-display" style="font-size:18px;line-height:1.35;color:var(--ink);margin-bottom:10px;">What does washed processing remove?</div>
       <div style="display:flex;flex-direction:column;gap:8px;">
         <span class="mcq-choice correct" style="font-size:13px;padding:12px 14px;">All the fruit, before drying</span>
         <span class="mcq-choice" style="font-size:13px;padding:12px 14px;">The silverskin</span>
       </div>
     </div>`, ['A surface card wrapping the standard MCQ rows.', 'One tap locks; Roasty answers CORRECT or NOT QUITE with one line of why.', 'Never scored, never awards points \u2014 reading the dictionary is not a lesson.']));

  wrap.append(compStates('Lesson reference card',
    'Term entry \u2014 \u201cwhere you learned it\u201d once known, \u201cwhere you\u2019ll learn it\u201d before.',
    [
      { label: 'Playable', demo: refCard(true),
        when: 'The lesson is unlocked and authored \u2014 the card opens it.',
        spec: ['bean node = lesson state', '--accent OPEN \u2192'] },
      { label: 'Soon', demo: refCard(false),
        when: 'Locked or not yet built \u2014 the card is inert.',
        spec: ['opacity 0.75', '--ink-mute SOON'] },
    ],
    [
      'Led by the <b>bean node</b> \u2014 the same progress primitive as a lesson row, filled to that lesson\u2019s state.',
      'The card never lies about being tappable: if it cannot open, it says SOON and drops out of the accent language entirely.',
    ], 300));

  wrap.append(compRules('Labelled block',
    'Every block in the body of a term entry \u2014 IN DEPTH, RELATED TERMS, WHERE YOU LEARNED IT, SOURCES.',
    `<div>
       <div style="font-family:'IBM Plex Sans',sans-serif;font-size:11px;font-weight:500;letter-spacing:0.14em;text-transform:uppercase;color:var(--ink-mute);margin-bottom:10px;">In depth</div>
       <p style="font-size:14px;line-height:1.6;color:var(--ink);margin:0;">Yeasts and bacteria eat the sugars in the mucilage. Time, temperature and oxygen decide how far it goes.</p>
     </div>`, ['One smallcaps label, then the block \u2014 same style every time.', 'The label names the block\u2019s <b>job</b>, never its content: IN DEPTH, not \u201cMore about fermentation\u201d.', 'WHERE YOU\u2019LL LEARN IT flips to WHERE YOU LEARNED IT once the lesson is done.']));

  wrap.append(compRules('In practice block',
    'The worked example that turns a definition into something you can use \u2014 after the teaching text in a term entry, and above the question on a lesson decision card.',
    `<div style="border-left:2px solid var(--accent);padding-left:16px;">
       <div style="font-family:'IBM Plex Sans',sans-serif;font-size:11px;font-weight:500;letter-spacing:0.14em;text-transform:uppercase;color:var(--accent);margin-bottom:8px;">In practice</div>
       <p style="font-size:14px;line-height:1.6;color:var(--ink);margin:0;">A bag that says \u201c72h anaerobic\u201d is telling you it will taste boozy and loud.</p>
     </div>`, ['A 2px accent left rule. Labelled IN PRACTICE in a term entry; unlabelled when a lesson decision card uses it to set its scenario.', 'The app\u2019s <b>only</b> left-rule treatment \u2014 it means <i>a real situation, pulled aside</i>, and never spreads to ordinary prose or callouts.', 'One per screen: two of them and neither reads as the practical one.']));

  wrap.append(compRules('Sources list',
    'The last block of a term entry \u2014 where the definition came from.',
    `<div>
       <div style="font-family:'IBM Plex Sans',sans-serif;font-size:11px;font-weight:500;letter-spacing:0.14em;text-transform:uppercase;color:var(--ink-mute);margin-bottom:10px;">Sources</div>
       <div style="display:flex;flex-direction:column;gap:8px;">
         <span class="mono" style="font-size:11px;line-height:1.5;color:var(--ink-mute);display:flex;gap:8px;"><span style="color:var(--accent);">01</span><span>SCA \u2014 Flavor Wheel and Lexicon</span><svg width="10" height="10" viewBox="0 0 10 10" style="flex-shrink:0;margin-top:3px;"><path d="M2.5 1.5 h6 v6 M8.5 1.5 L1.5 8.5" fill="none" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/></svg></span>
         <span class="mono" style="font-size:11px;line-height:1.5;color:var(--ink-mute);display:flex;gap:8px;"><span style="color:var(--accent);">02</span><span>World Coffee Research \u2014 variety catalogue</span></span>
       </div>
     </div>`, ['Mono rows at label size, each led by an accent zero-padded index.', 'External sources link out with the corner arrow and turn accent on hover.', 'Unlinked sources sit inert in ink-mute.', 'Cite the body, not the blog \u2014 this is what makes the dictionary quotable.']));

  wrap.append(compRules('Dictionary quick chips',
    'Dictionary home, directly under the search field.',
    `<div style="display:flex;gap:10px;">
       <span style="flex:1;background:var(--surface);border:1px solid var(--rule);border-radius:12px;padding:11px 14px;display:flex;align-items:center;gap:10px;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" style="color:var(--accent);"><rect x="3" y="6" width="14" height="12" rx="2" stroke="currentColor" stroke-width="1.6"/><path d="M7 9.5h6M7 12.5h4" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/><path d="M9 4.5h9a2 2 0 0 1 2 2v9" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" opacity="0.5"/></svg><span style="font-size:13px;font-weight:500;color:var(--ink);">Flashcards</span><span class="mono" style="font-size:9.5px;color:var(--ink-mute);margin-left:auto;">12</span></span>
       <span style="flex:1;background:var(--surface);border:1px solid var(--rule);border-radius:12px;padding:11px 14px;display:flex;align-items:center;gap:10px;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" style="color:var(--accent);"><circle cx="12" cy="12" r="8" stroke="currentColor" stroke-width="1.6"/><path d="M9.5 9.8a2.5 2.5 0 1 1 3.2 2.4c-.5.2-.7.6-.7 1.1v.4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/><circle cx="12" cy="16.3" r="0.9" fill="currentColor"/></svg><span style="font-size:13px;font-weight:500;color:var(--ink);">Vocab game</span></span>
     </div>`, ['Two equal chips: accent glyph, label, and a mono count when there is a number.', 'Shortcuts, not features \u2014 the same games live in Learn, so these never carry a badge or a lock.']));

  wrap.append(compRules('Term peek sheet',
    'In-lesson bottom sheet when a tapped term needs a quick definition without leaving the lesson.',
    `<div>
       <div style="display:flex;align-items:center;gap:12px;">
         <span class="ff-display" style="font-size:23px;color:var(--ink);flex:1;line-height:1;">Coffee Cherry</span>
         <span style="width:36px;height:36px;border-radius:999px;flex-shrink:0;display:grid;place-items:center;border:1px solid color-mix(in oklab, var(--sage) 55%, var(--rule));background:color-mix(in oklab, var(--sage) 12%, var(--surface));"><svg width="13" height="13" viewBox="0 0 10 10" fill="none"><path d="M1.5 5.2 L4 7.6 L8.5 2.6" stroke="var(--sage)" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg></span>
         <span style="width:36px;height:36px;border-radius:999px;border:1px solid var(--rule);display:grid;place-items:center;"><svg width="14" height="14" viewBox="0 0 20 20" fill="none"><path d="M5 3.5 H15 V17 L10 13.5 L5 17 Z" stroke="var(--ink-mute)" stroke-width="1.5" stroke-linejoin="round"/></svg></span>
       </div>
       <p style="font-size:13px;line-height:1.45;color:var(--ink);margin:12px 0 0;">The fruit of the coffee plant. Each cherry holds two seeds — the “beans” we roast.</p>
       <div class="mono" style="font-size:10px;letter-spacing:0.16em;text-transform:uppercase;color:var(--ink-mute);margin:18px 0 16px;">Related</div>
       <div style="display:flex;gap:8px;">
         <span style="background:var(--surface);border:1px solid var(--rule);border-radius:999px;padding:8px 14px;display:inline-flex;align-items:center;gap:8px;font-size:13px;color:var(--ink);">Arabica <span style="width:5px;height:5px;border-radius:999px;background:var(--sage);"></span></span>
         <span style="background:var(--surface);border:1px solid var(--rule);border-radius:999px;padding:8px 14px;font-size:13px;color:var(--ink);">Bean Belt</span>
       </div>
     </div>`, ['Header is ONE 36px control row: term left, status cluster right.', 'Status cluster = sage check (only when learned) + bookmark, identical sizes \u2014 never a text chip.', 'No category tile: category belongs to the Dictionary and the full entry.', 'RELATED is the only label in the sheet; its chips carry a sage dot when learned.', 'Footer is a pair \u2014 ghost dismiss, primary Full entry.']));



  wrap.append(compSubhead('Feedback and progress', 'How the app answers back'));

  wrap.append(compStates('Bean node',
    'The one progress primitive \u2014 Path and Module lesson rows, the points mark, card and collection nodes.',
    [
      { label: 'Empty', demo: beanDemo(0, 'var(--accent)'),
        when: 'Not attempted, or locked. Outline only.',
        spec: ['--ink-mute outline', '0% fill'] },
      { label: 'Part-filled', demo: beanDemo(0.45, 'var(--accent)'),
        when: 'Completed below the pass mark \u2014 the fill is the best score as a ratio of that lesson\u2019s own questions.',
        spec: ['--accent', 'fills bottom-up'] },
      { label: 'Full', demo: beanDemo(1, 'var(--sage)'),
        when: 'At or above the pass mark.',
        spec: ['--sage', '100% fill', '--ink outline'] },
    ],
    [
      'The bean is a <b>gauge</b>: partial fill always means mastery, never selection, never quantity.',
      'The points mark is the same silhouette with <b>no</b> fill state \u2014 points are a quantity, so they must not read as a level.',
      'It fills bottom-up, never left-to-right: a progress bar and a bean are different instruments.',
    ]));

  wrap.append(compRules('Mastery rollup',
    'Profile — a persistent home for what the Lesson Complete screen says once.',
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
     </div>`, ['A two-segment bar over the whole lesson count: sage solid, accent needs-practice, remainder empty.', 'Two numbers, never a third.', 'Tapping deep-links to the Path to practise the weak ones.']));

  wrap.append(compStates('Roast meter',
    'The top bar of any run of questions \u2014 a lesson, a mini-game, flashcards, the vocab game.',
    [
      { label: 'First', demo: drillMeterDemo(1, 8), when: 'Opening question \u2014 raw green bean.', spec: ['--art-roast-light'] },
      { label: 'Mid-run', demo: drillMeterDemo(4, 8), when: 'Halfway \u2014 the bean has taken colour.', spec: ['ramp interpolated'] },
      { label: 'Last', demo: drillMeterDemo(8, 8), when: 'Final question \u2014 espresso.', spec: ['--art-roast-dark'] },
    ],
    [
      'Reports <b>position</b>, never quality \u2014 it has no fill state, so it can never be read as the mastery gauge.',
      'Roast colours are literal coffee: unlike every UI token, they do not change with the mood.',
    ]));

  wrap.append(compRules('Points mark',
    'Anywhere a points number appears — the toast, Lesson Complete, the profile stat.',
    `<div style="display:flex;gap:22px;align-items:center;flex-wrap:wrap;">
       <span style="display:flex;align-items:center;gap:10px;">${gPointsBean(18)}<span class="mono" style="font-size:13px;font-weight:500;letter-spacing:0.06em;text-transform:uppercase;color:var(--ink);">+12 PTS</span></span>
       <span style="display:inline-flex;align-items:center;gap:8px;background:var(--accent);color:var(--accent-ink);border-radius:999px;padding:8px 14px;">${gPointsBean(14, 'var(--accent-ink)', 'var(--accent)')}<span class="mono" style="font-size:13px;font-weight:500;letter-spacing:0.06em;text-transform:uppercase;">+12 PTS</span></span>
     </div>`, ['One solid silhouette with a carved crease and <b>no</b> fill state.', 'Points are a quantity, not a level \u2014 partial fill belongs to the gauge alone.', 'On an accent fill it inverts, crease in the fill colour.']));

  wrap.append(compRules('Points chip',
    'The sage points mark. Fires once at the end of a run \u2014 a logged Brew Challenge, a finished lesson, a finished module. Never mid-lesson.',
    `<div style="display:flex;gap:14px;align-items:center;">
       <span class="mono" style="font-size:11px;font-weight:500;letter-spacing:0.1em;color:var(--sage);border:1px solid color-mix(in oklab, var(--sage) 45%, transparent);background:color-mix(in oklab, var(--sage) 10%, transparent);border-radius:999px;padding:3px 9px;">+10 PTS</span>
       <span class="mono" style="font-size:9.5px;letter-spacing:0.14em;text-transform:uppercase;color:var(--ink-mute);">rises 12px · fades at 950ms</span>
     </div>`, ['A sage pill that scales up as its screen lands. It never interrupts a lesson in progress.', 'Points are effort, so the chip never reports mastery.', 'Mid-lesson feedback is qualitative only \u2014 Roasty reacts, the explanation teaches, and no counter appears either way.']));

  wrap.append(compStates('Fill-in-the-blank',
    'FillSlot (lesson.jsx) on the shared .fill-slot class \u2014 concept \u201ccomplete the sentence\u201d cards and the predict card\u2019s cloze question.',
    [
      { label: 'Empty', demo: '<span class="fill-slot">&nbsp;</span>',
        when: 'Waiting for a word. Holds its own width so the sentence never reflows on fill.',
        spec: ['2px dashed', 'accent 55%', 'min-width 74px'] },
      { label: 'Guess', demo: '<span class="fill-slot filled guess">Seed</span>',
        when: 'The predict card\u2019s ungraded pick \u2014 the learner\u2019s claim, not a verdict.',
        spec: ['--accent', 'solid'] },
      { label: 'Filled', demo: '<span class="fill-slot filled">bean</span>',
        when: 'A word is in, the sentence is not checked yet.',
        spec: ['--ink text', 'accent 70% rule', 'solid'] },
      { label: 'Right', demo: '<span class="fill-slot filled right">unevenly</span>',
        when: 'Checked and correct.',
        spec: ['--sage'] },
      { label: 'Wrong', demo: '<span class="fill-slot filled wrong">evenly</span>',
        when: 'Checked and wrong \u2014 the option row below shows which word was right.',
        spec: ['--berry'] },
    ],
    [
      'Mono by default so a filled blank reads as a token; add <b>inherit</b> only when the slot sits inside Fraunces display type.',
      'Predict questions are cloze <b>whenever grammar allows</b> \u2014 short options (1\u20132 words) that slot into a claim the learner reads back. Question form is the fallback for true/false claims and long phrase options, which wrap badly in the slot.',
      'Right and wrong belong to <b>graded</b> cards only \u2014 an ungraded guess never turns berry.',
      'The sentence must keep reading as a sentence. Never a form.',
    ]));

  wrap.append(compRules('Sequence row',
    'Put-in-order cards — brew steps, roast stages.',
    `<div style="display:flex;flex-direction:column;gap:8px;">
       <div style="display:flex;align-items:center;gap:12px;padding:13px 14px;border:1px solid var(--sage);border-radius:14px;background:color-mix(in oklab, var(--sage) 10%, var(--surface));"><span class="mono" style="width:22px;height:22px;border-radius:999px;background:var(--sage);color:var(--surface);display:grid;place-items:center;font-size:11px;">1</span><span style="font-size:14px;color:var(--ink);">Rinse the filter</span></div>
       <div style="display:flex;align-items:center;gap:12px;padding:13px 14px;border:1px solid var(--rule);border-radius:14px;background:var(--surface);"><span class="mono" style="width:22px;height:22px;border-radius:999px;border:1px solid var(--rule);color:var(--ink-mute);display:grid;place-items:center;font-size:11px;">2</span><span style="font-size:14px;color:var(--ink);">Bloom for 30 seconds</span></div>
     </div>`, ['A mono number token leads each row; tapping assigns the next number.', 'On check, rows turn sage or berry and the token inverts to a solid fill.']));

  wrap.append(compStates('Taste Fix card',
    'The diagnostic mini-game \u2014 \u201cmy cup tastes like this, what do I change first?\u201d Runs inside lessons and as a standalone game.',
    [
      { label: 'Starting point', demo: `<div style="width:100%;max-width:250px;border-radius:18px;padding:16px 18px 15px;background:linear-gradient(160deg, color-mix(in oklab, var(--berry) 8%, var(--surface)), var(--surface) 68%);border:1px solid color-mix(in oklab, var(--berry) 16%, var(--rule));box-shadow:0 1px 2px color-mix(in oklab, var(--ink) 6%, transparent);display:flex;flex-direction:column;gap:10px;">
         <div class="mono" style="font-size:11px;font-weight:500;letter-spacing:0.12em;text-transform:uppercase;color:color-mix(in oklab, var(--berry) 70%, var(--ink-mute));">Starting point</div>
         <p style="font-size:13px;line-height:1.4;color:var(--ink);margin:0;">Grind\u2019s dialled in and the beans are fresh.</p>
         <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;">
           <span class="mono" style="font-size:11px;font-weight:500;letter-spacing:0.12em;text-transform:uppercase;color:var(--ink-mute);">Tastes</span>
           <span class="mono" style="font-size:11px;font-weight:500;letter-spacing:0.1em;text-transform:uppercase;color:var(--berry);background:color-mix(in oklab, var(--berry) 13%, transparent);padding:3px 9px;border-radius:999px;">Sour</span><span class="mono" style="font-size:11px;font-weight:500;letter-spacing:0.1em;text-transform:uppercase;color:var(--berry);background:color-mix(in oklab, var(--berry) 13%, transparent);padding:3px 9px;border-radius:999px;">Thin</span>
         </div>
       </div>`,
        when: 'The cup as handed to the learner, with its fault tags. A wrong pick shakes the panel and dims the tags \u2014 it never turns them sage.',
        spec: ['berry 8% gradient', 'berry 16% border', 'radius 18'] },
      { label: 'Fixed', demo: `<div style="width:100%;max-width:250px;border-radius:18px;padding:16px 18px 15px;background:linear-gradient(160deg, color-mix(in oklab, var(--sage) 14%, var(--surface)), var(--surface) 70%);border:1px solid color-mix(in oklab, var(--sage) 30%, var(--rule));box-shadow:0 1px 2px color-mix(in oklab, var(--ink) 6%, transparent);display:flex;flex-direction:column;gap:10px;">
         <div class="mono" style="font-size:11px;font-weight:500;letter-spacing:0.12em;text-transform:uppercase;color:var(--sage);">Fixed</div>
         <p style="font-size:13px;line-height:1.4;color:var(--ink);margin:0;">Grind\u2019s dialled in and the beans are fresh.</p>
         <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;">
           <span class="mono" style="font-size:11px;font-weight:500;letter-spacing:0.12em;text-transform:uppercase;color:var(--ink-mute);">Result</span>
           <span class="mono" style="font-size:11px;font-weight:500;letter-spacing:0.1em;text-transform:uppercase;color:var(--sage);background:color-mix(in oklab, var(--sage) 16%, transparent);padding:3px 9px;border-radius:999px;">Balanced</span>
         </div>
       </div>`,
        when: 'The right change was picked \u2014 tags collapse to BALANCED and the label flips to FIXED.',
        spec: ['sage 14% gradient', 'sage 30% border', '450ms ease'] },
    ],
    [
      'The <b>only</b> surface in the app that changes colour to report a result \u2014 everywhere else sage and berry live in borders, dots and text.',
      'The line inside is a caption on the cup\u2019s state, not an aside: it never takes the accent left rule that marks a scenario.',
      'Scored like an MCQ, so it feeds the lesson\u2019s perfect run \u2014 but the feedback names the cause, never a score.',
    ], 280));

  wrap.append(compRules('Brew challenge card',
    'Today (below Continue Learning) — the one “go do it with real coffee” prompt.',
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
     </div>`, ['The section kicker with the cup mark sits <b>outside</b> the card.', 'Accent-tinted surface, accent hairline; title 26, instruction 15.', 'Trigger and estimate are two mono lines against a primary Log Result.', 'The corner X saves for later \u2014 it never deletes.', 'Never scored: completion is self-reported.']));

  wrap.append(compRules('Card or section',
    'The decision every screen block faces: a bordered card, or a labelled section in the page flow.',
    `<div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;">
       <div>
         <div style="${SMALLCAPS}margin-bottom:7px;">CARD</div>
         <div style="border:1px solid color-mix(in oklab, var(--accent) 30%, var(--rule));border-radius:2px;padding:14px;background:linear-gradient(160deg, color-mix(in oklab, var(--accent) 12%, var(--surface)) 0%, var(--surface) 62%);">
           <div style="${SMALLCAPS}color:var(--accent);">BREWPATH PLUS</div>
           <div class="ff-display" style="font-size:19px;color:var(--ink);margin-top:8px;">$29.99/yr</div>
           <div style="font-size:12px;color:var(--ink-mute);margin-top:4px;">Renews 18 Jun 2027</div>
         </div>
       </div>
       <div>
         <div style="${SMALLCAPS}margin-bottom:7px;">SECTION</div>
         <div style="${SMALLCAPS}margin-bottom:4px;">FREE PLAN</div>
         <div style="font-size:14px;color:var(--ink);padding:12px 0;">Every lesson and the dictionary, included.</div>
       </div>
     </div>`,
    ['A card is a <b>container for facts</b> — a price, a renewal date, a countdown. Given facts, it earns its border.',
     'With nothing to hold, drop the card, not the content: use the screen’s own grammar — smallcaps label, then rows at 16px 0. A bordered box with one line in it reads as a render failure, not restraint.',
     'Never let a container change weight between states of one screen. The Subscription screen keeps its card only where there is billing; free uses the same section shape as MANAGE and WITH PLUS below it.',
     'The display slot states a <b>value</b>. If a state has no value to show, it has no display line — it must never be filled with an absence (“No subscription”).']));

  wrap.append(compRules('Empty state',
    'A filter with no matches, a passport with no stamps, a Saved shelf before anything is saved.',
    `<div style="text-align:center;padding:22px 16px;">
       <div style="color:var(--ink-mute);opacity:0.6;display:flex;justify-content:center;">${beanDemo(0, 'var(--ink-mute)')}</div>
       <div class="ff-display" style="font-size:19px;color:var(--ink);margin-top:12px;">No stamps yet</div>
       <p style="font-size:13px;line-height:1.5;color:var(--ink-mute);margin:8px auto 16px;max-width:260px;">Explore an origin on the map and its stamp lands here.</p>
       <div class="btn btn-ghost" style="width:auto;display:inline-block;padding:12px 20px;">Open the map</div>
     </div>`, ['Always three parts: a muted glyph, one Fraunces line, a ghost button that clears the cause.', 'Never an apology, and never an illustration the user cannot act on.']));

  wrap.append(compRules('Roasty, the companion',
    'Loading screens, lesson and module completion, correct and wrong answers, the gift and duel moments.',
    `<div style="display:flex;align-items:center;gap:14px;">
       <span style="width:52px;height:52px;border-radius:16px;background:var(--surface-2);display:grid;place-items:center;">${beanDemo(1, 'color-mix(in oklab, var(--accent) 70%, var(--ink))')}</span>
       <a href="Mascot - Roasty.html" style="font-size:13px;color:var(--accent);">Open the Roasty study →</a>
     </div>`, ['One shape, eleven states: idle, card, lesson, module, correct, wrong, sleep, gift, duel win/loss, tasting.', 'He reacts, he never instructs \u2014 copy carries the teaching.', 'Full state sheet and motion specs live in the Mascot study file.']));

  // ── Chrome & navigation ────────────────────────────────────
  wrap.append(compSubhead('Chrome and navigation', 'Frames every screen'));

  wrap.append(compRules('Screen top bar',
    'Every pushed screen — lessons, modules, settings, saved, the streak & tree screens, game intros.',
    topBarDemo(), ['A 32 \u00b7 1fr \u00b7 32 grid: back or close left, roast meter centre, optional action right.', 'The centre stays empty on plain back bars.', 'The screen\u2019s title lives in the body below, never in the bar.']));

  wrap.append(compRules('Header buttons',
    'Pinned top-right on the main tabs — the persistent entries to Coffee Duel and the Coffee Dictionary.',
    headerButtonsDemo(), ['42px round, surface fill, hairline border, soft shadow.', 'The glyph is always accent.', 'A count or lock badge pins to the top-right corner when relevant.']));

  // Tab bar — full width, lives with the rest of the chrome
  wrap.append(el('div', { class: 'panel comp comp-wide' },
    el('div', { class: 'panel-head' }, el('div', { class: 'ff-display comp-title' }, 'Tab bar')),
    el('div', { class: 'comp-demo', html: tabBarHTML() }),
    el('div', { class: 'kv' },
      el('div', null, el('span', { class: 'mono klabel' }, 'WHERE'), el('span', { class: 'kval' }, 'Persistent navigation across the top-level destinations. Five are designed; v1 renders four — Atlas is filtered out of the array (shown dimmed above) and returns in v2.')),
      el('div', null, el('span', { class: 'mono klabel' }, 'RULE'), el('span', { class: 'kval' }, 'Active tab is accent + filled icon; the rest are ink-mute outlines. Labels are 9px mono, always uppercase. The first tab reads TODAY in the default tab nav and LEARN in the merged model, where Path folds into it — one tab id, two labels, never both at once.')),
    ),
  ));

  wrap.append(compRules('Bottom sheet',
    'The app\u2019s one modal pattern \u2014 Share, Reset confirm, Daily reminder, Billing cycle, the Plus gate, and the dictionary & atlas peeks.',
    sheetDemo(),
    [
      'Rises from the bottom over a 40% scrim: 36px handle, then content.',
      'Lead with a mono eyebrow, then a Fraunces title, then actions.',
      'Tap-scrim or \u201cNot now\u201d always dismisses \u2014 never trap the user.',
    ]));

  wrap.append(compRules('Result sheet',
    'What a system action reports back — restore purchases succeeded, found nothing, or could not reach the store.',
    `<div style="max-width:300px;background:var(--bg);border:1px solid var(--rule);border-radius:14px;padding:18px;">
       <div style="${SMALLCAPS}margin-bottom:8px;">NOTHING TO RESTORE</div>
       <div class="ff-display" style="font-size:19px;color:var(--ink);line-height:1.1;">No purchase on this Apple ID.</div>
       <p style="font-size:13px;line-height:1.5;color:var(--ink-mute);margin:10px 0 16px;">If you bought Plus with a different Apple ID, sign in with that one and try again.</p>
       <div class="btn-primary" style="text-align:center;box-sizing:border-box;">Done</div>
     </div>`,
    ['The confirm sheet with <b>one</b> action instead of two — there is nothing to cancel, only to acknowledge. Same shell, same type ramp.',
     'iOS owns the system auth sheet; the outcome is ours. Every branch gets stated — a silent failure reads as a broken button.',
     'The body says only what to do next. The title already carries the finding, so it is never restated, and no outcome is padded with reassurance the user did not ask for (“nothing was charged”).',
     'A recoverable failure labels its action for the retry (“Try again”), not “Done”.',
     'In the build, the branch is whatever StoreKit returns. This prototype exposes a <b>Restore result</b> tweak only so all three sheets can be seen without a real purchase history \u2014 it is a preview control, not app state, and it does not port.']));

  wrap.append(compStates('Sheet layers',
    'Two stacking layers, and the rule for what happens to an open sheet when the screen behind it changes.',
    [
      { label: 'Base layer', demo: '<div style="width:100%;max-width:220px;"><div style="height:34px;border:1px solid var(--rule);border-bottom:none;border-radius:14px 14px 0 0;background:var(--surface);display:grid;place-items:center;"><span style="width:34px;height:3px;border-radius:999px;background:var(--rule);"></span></div></div>',
        when: 'Every ordinary sheet \u2014 peek, share, confirm, reminder, card, log, recap.',
        spec: ['scrim 95', 'sheet 96'] },
      { label: 'Interrupt layer', demo: '<div style="width:100%;max-width:220px;position:relative;"><div style="height:24px;border:1px solid var(--rule);border-bottom:none;border-radius:14px 14px 0 0;background:var(--surface);opacity:0.5;margin:0 12px;"></div><div style="height:34px;border:1px solid var(--accent);border-bottom:none;border-radius:14px 14px 0 0;background:var(--surface);display:grid;place-items:center;margin-top:-6px;"><span style="width:34px;height:3px;border-radius:999px;background:var(--accent);"></span></div></div>',
        when: 'The Plus gate only \u2014 it can be raised from inside another sheet, e.g. saving a term past the free cap.',
        spec: ['scrim 97', 'sheet 98'] },
    ],
    [
      'Two sheets on the <b>same</b> layer must never be open at once \u2014 they tie on z-index and the later one wins by accident.',
      'A sheet that outlives its screen (peek, card, log, recap, review confirm) <b>closes on navigation</b>: it must never float over a screen it did not open from.',
    ], 260));

  wrap.append(compRules('Scrims and dims',
    'Every overlay in the app — the four ways something is put behind something else.',
    `<div style="display:flex;gap:10px;flex-wrap:wrap;">
       ${['--dim-modal', '--veil', '--veil-strong', '--scrim'].map(t => `<div style="width:104px;">
         <div style="height:56px;border:1px solid var(--rule);border-radius:2px;background-image:linear-gradient(var(${t}),var(${t})),repeating-linear-gradient(45deg,var(--surface) 0 7px,var(--surface-2) 7px 14px);"></div>
         <div class="mono" style="font-size:9.5px;letter-spacing:0.1em;color:var(--ink-mute);margin-top:6px;">${t}</div>
       </div>`).join('')}
     </div>`,
    ['<b>--dim-modal</b> · blocking. Behind a bottom sheet, with a 5px blur. The content behind is unavailable, so it recedes completely and the sheet owns the screen.',
     '<b>--veil</b> · teasing. Over content the user is meant to keep reading — the Plus feature lock. Light enough that the screen behind stays legible; that legibility <i>is</i> the pitch.',
     '<b>--veil-strong</b> · covering. A near-opaque wash when a panel takes over a screen but should still show its outline underneath.',
     '<b>--scrim</b> · separating. Only behind a control sitting on media. It is the only one of the four that is not full-screen.',
     'Weight follows intent, never taste: blocking &gt; covering &gt; teasing &gt; separating. If two overlays look alike, one of them is describing the wrong relationship.',
     'Never stack two full-screen overlays. A sheet opening over a locked screen already has --veil beneath it — --dim-modal is sized to read correctly on top of that, not to be doubled.',
     'Blur is part of the token’s job, not a decoration: 5px for the modal dim, 3px for a covering wash, 8px behind a media control, none on the plain veil.']));

  wrap.append(compRules('Sticky action bar',
    'The footer that carries the single primary action on a scrolling screen — duel hub, lesson end, pickers.',
    actionBarDemo(), ['The button sits over a transparent-to-bg gradient so content scrolls beneath it.', 'One primary action only; a quiet link may sit under it.', 'This and the tab bar are the app\u2019s only footers.']));

  // ── Inputs & controls ──────────────────────────────────────
  wrap.append(compSubhead('Inputs and controls', 'How the user makes choices'));

  wrap.append(compRules('Search field',
    'Dictionary search; the pattern for any future find-as-you-type input.',
    searchDemo(), ['Surface fill, 12px radius, leading magnifier in ink-mute.', 'The clear cross appears only once there is a query.', 'Placeholder shows a real example, never just \u201cSearch\u201d.']));

  wrap.append(compRules('Segmented control',
    'The All / Learned / To-learn filter; the pattern for any 2–3 way mutually-exclusive switch.',
    segmentedDemo(), ['One hairline pill split into equal segments.', 'Active segment fills accent with accent-ink text; the rest are ink-mute.', 'Labels are mono uppercase.']));

  wrap.append(compStates('Toggle',
    'Every on/off setting \u2014 notifications, sounds, reminders, theme switches.',
    [
      { label: 'Off', demo: dsToggle(false), when: 'Setting inactive.', spec: ['1px --rule track', '--ink-mute knob'] },
      { label: 'On', demo: dsToggle(true), when: 'Setting active.', spec: ['--accent track', '--accent-ink knob'] },
    ],
    [
      'The one place radius goes fully round \u2014 everywhere else the app is square, per the shape rule.',
      '44\u00d726 hit target, knob travels 18px. Never animate the colour without the knob: the movement is the feedback.',
    ]));

  wrap.append(compRules('Settings / nav row',
    'ONE component (NavRow, settings.jsx) behind every settings row in the app \u2014 Settings, About, Account and sync, Help and support, Subscription. SettingsRow is an alias of it, not a second copy.',
    settingsRowDemo(), ['Label left; the right takes a mono value, then a chevron (internal), arrow (external) or toggle.', 'Hairline between rows.', 'Destructive rows take berry, never accent.',
      'A row that fires a <b>network call</b> has a pending state: the label swaps to the present participle (“Restoring…”), drops to ink-mute, the chevron becomes a spinner and taps are refused until it settles. Never leave a row looking tappable while it is working.',
      'Rows are the register for a settings <b>action</b>. A quiet mono link is for purchase surfaces; a primary button is for the one thing a screen is for. Restore purchases is a row in Settings and a link on the paywall — same action, different surface.',
      'Six trailing variants, one row: mono value, chevron, external arrow, toggle, pending spinner, destructive. A row carrying a <b>toggle</b> is tappable across its full width \u2014 the 26px switch is never the only target \u2014 and the switch stops its own tap so the row cannot double-fire.']));

  return section('components', 'Library', 'Components',
    'The reusable building blocks, each shown live in the current theme. Anything new should be assembled from these before a fresh pattern is invented.',
    wrap);
}

function tabBarHTML() {
  // v1 ships four: Atlas is filtered out of the same five-item array in the app,
  // so the DS shows it dimmed in place rather than pretending it was never drawn.
  const labels = ['TODAY', 'PATH', 'ATLAS', 'CARDS', 'PROFILE'];
  let cells = '';
  TAB_SVGS.forEach((s, i) => {
    const active = i === 0;
    const held = i === 2;
    if (held) {
      cells += `<div class="tab" style="position:static;color:var(--ink-mute);opacity:0.32;">
        <span class="tab-ico">${s}</span><span class="label">${labels[i]} · V2</span></div>`;
      return;
    }
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
function settingsRowDemo() {
  const chev = `<svg width="8" height="14" viewBox="0 0 8 14"><path d="M1 1l6 6-6 6" fill="none" stroke="var(--ink-mute)" stroke-opacity="0.6" stroke-width="1.5" stroke-linecap="round"/></svg>`;
  const ext = `<svg width="13" height="13" viewBox="0 0 13 13"><path d="M3 10 L10 3 M4.5 3 H10 V8.5" fill="none" stroke="var(--ink-mute)" stroke-opacity="0.6" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"/></svg>`;
  const tog = `<span style="position:relative;width:44px;height:26px;padding:3px;border-radius:999px;box-sizing:border-box;display:inline-block;border:1px solid var(--accent);background:var(--accent);"><span style="display:block;width:18px;height:18px;border-radius:999px;background:var(--accent-ink);transform:translateX(18px);"></span></span>`;
  const spin = `<svg width="15" height="15" viewBox="0 0 15 15"><circle cx="7.5" cy="7.5" r="5.6" fill="none" stroke="var(--rule)" stroke-width="1.6"/><path d="M7.5 1.9a5.6 5.6 0 0 1 5.6 5.6" fill="none" stroke="var(--accent)" stroke-width="1.6" stroke-linecap="round"/></svg>`;
  const row = (label, right, last, danger) => `<div style="display:flex;align-items:center;justify-content:space-between;gap:16px;padding:16px 0;${last ? '' : 'border-bottom:1px solid var(--rule);'}"><span style="font-size:15px;color:${danger ? 'var(--berry)' : 'var(--ink)'};">${label}</span><span style="display:flex;align-items:center;gap:10px;">${right}</span></div>`;
  const val = (v) => `<span class="mono" style="font-size:13px;color:var(--ink-mute);">${v}</span>`;
  return `<div class="card" style="padding:4px 18px;">
    ${row('Daily reminder', val('8:00') + chev, false, false)}
    ${row('Sound effects', tog, false, false)}
    ${row('Rate the app', ext, false, false)}
    ${row('Restoring\u2026', spin, false, false)}
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

  wrap.append(compRules('Lock affordances',
    'Anywhere a Plus surface is referenced for a free user — header icons, profile cards, list rows, and the live trial countdown.',
    affordancesDemo(), ['Accent is the Plus colour.', 'The PLUS pill labels a gated entry; the lock badge pins to a header icon.', 'The trial pill counts down a temporary unlock \u2014 the only moving element.', 'Never gate with a grey-out alone: always pair a lock mark with a way in.']));

  wrap.append(compRules('Plus gate sheet',
    'The bottom sheet shown the moment a free user taps any locked feature.',
    gateSheetDemo(), ['Two ways out, never a dead end: upgrade (primary) or watch one ad (ghost).', 'Lead with the feature\u2019s name and its one-line value, never the price.', '\u201cNot now\u201d is always present.', 'Interrupt layer (97 / 98) \u2014 the gate is usually raised from inside another sheet.', 'Upgrading closes the sheet that raised it, so the paywall lands clean.']));

  wrap.append(compRules('Rewarded ad',
    'The simulated rewarded video reached from the gate sheet’s “watch an ad” path.',
    adDemo(), ['Full-bleed dark \u2014 the one place the app leaves its warm theme.', 'Close stays de-emphasised until the countdown ring completes.', 'The reward is restated before the claim.']));

  const treat = el('div', { class: 'panel comp comp-wide' },
    el('div', { class: 'panel-head' },
      el('div', { class: 'ff-display comp-title' }, 'Feature-lock treatments'),
      el('div', { class: 'mono eyebrow dim' }, '3 styles'),
    ),
    el('div', { class: 'comp-demo' },
      el('div', { class: 'lock-mini-grid', html: lockMini('blur') + lockMini('hard') + lockMini('curtain') }),
    ),
    el('div', { class: 'kv' },
      el('div', null, el('span', { class: 'mono klabel' }, 'WHERE'), el('span', { class: 'kval' }, 'Wraps a whole gated surface for a free user — in v1 that is Dictionary, Saved and Studio; Atlas and Duel are built against the same treatment and land with them in v2. One style is chosen per surface.')),
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
      'Nothing open. Fixes are folded into the rule they changed rather than logged here, so this section only ever holds live drift. New findings get listed as they are made.',
      el('div', { class: 'flag flag-low' },
        el('div', { class: 'flag-head' },
          el('span', { class: 'mono sev sev-done' }, 'ALL CLEAR'),
          el('div', { class: 'ff-display flag-title' }, 'No open flags'),
        ),
      ));
  }
  const doneCount = FLAGS.filter(f => f.done).length;
  const WORDS = ['None', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve'];
  const word = WORDS[doneCount] || String(doneCount);
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

/* ==========================================================================
   6 · GAMES  —  the two game systems and the full playable inventory
   ========================================================================== */

// Every interactive card kind in the app, in the order a lesson uses them.
// cue    — the game-cue phrase above the question (null = no cue, no "?" drawer)
// scored — does a right answer pay points / count toward a score?
// game   — the mini-game id this kind is also published as, if any.
const GAME_KINDS = [
  ['predict',  null,                            false, null,
   'The opening guess, made before anything is taught. Ungraded by design \u2014 a wrong guess is the point.'],
  ['concept',  'Complete the sentence',         false, null,
   'Teaching card with words blanked out. Picks lock on first tap and always resolve to the true sentence.'],
  ['mcq',      'Multiple choice \u00b7 pick one',   true,  null,
   'One right answer from three or four. The base question type.'],
  ['multi',    'Select all that apply',         true,  null,
   'Several right answers, graded as one set.'],
  ['match',    'Match \u00b7 drag to pair',         true,  'g-match',
   'Traits on the left, a deduped answer column on the right. Both columns shuffle on mount. Scores only on a clean board \u2014 no wrong drops.'],
  ['slider',   'Calibrate \u00b7 dial to the target', true, 'g-calibrate',
   'A 0\u2013100 track read through a five-band descriptive scale, graded against a target \u00b1 tolerance.'],
  ['sequence', 'Put in order \u00b7 tap in sequence', true, 'g-sequence',
   'Display order shuffles on mount with a solved-order guard, so a card authored in order never opens solved.'],
  ['decision', null,                            true,  null,
   'A buying scenario with two plausible bags. Feedback is framed as consequence, not score \u2014 neither option is wrong in the abstract.'],
  ['recall',   null,                            true,  null,
   'The closing question. Resolves the predict card\u2019s guess, so it only works inside its own lesson.'],
  ['tastefix', 'Taste Fix',                     true,  'g-tastefix',
   'A cup tagged with what is off; pick the single change that balances it. Choice order shuffles.'],
  ['bagpick',  'Blind bag \u00b7 read the beans',    true,  'g-bagpick',
   'Inspect colour, centre cut and aroma on an unlabelled sample, then call the process.'],
  ['flavor',   'Tasting \u00b7 name the note',       true,  'g-flavor',
   'Mini-game only. A tasting clue and four candidate notes.'],
  ['quiz',     'True or false',                 true,  'g-quiz',
   'Mini-game only. One statement, two buttons, an explanation either way.'],
  ['visual',   null,                            false, null,
   'An explorable diagram instead of prose. Savable to the Cards tab; never scored.'],
  ['practical', null,                           false, null,
   'A do-this-at-the-counter card. No answer to give.'],
];

const GAME_COLS = 'display:grid;grid-template-columns:100px 1fr 70px 92px;gap:14px;';

function gameInventory() {
  const head = el('div', { style: GAME_COLS + 'padding:0 0 10px;border-bottom:1px solid var(--rule);' },
    ['Kind', 'What it is', 'Scored', 'Mini-game'].map(h =>
      el('span', { class: 'mono', style: 'font-size:10px;letter-spacing:0.14em;text-transform:uppercase;color:var(--ink-mute);' }, h)));
  const rows = GAME_KINDS.map(([kind, cue, scored, game, what]) =>
    el('div', { style: GAME_COLS + 'padding:13px 0;border-bottom:1px solid var(--rule);align-items:start;' },
      el('span', { class: 'mono', style: 'font-size:11.5px;color:var(--accent);' }, kind),
      el('span', null,
        el('span', { style: 'font-size:13px;line-height:1.5;color:var(--ink-mute);display:block;text-wrap:pretty;' }, what),
        el('span', { class: 'mono', style: 'font-size:9.5px;letter-spacing:0.1em;text-transform:uppercase;color:var(--ink-mute);display:block;margin-top:5px;opacity:' + (cue ? '0.8' : '0.45') + ';' },
          cue ? 'CUE \u00b7 ' + cue : 'NO CUE')),
      el('span', { style: 'font-size:12.5px;color:' + (scored ? 'var(--sage)' : 'var(--ink-mute)') + ';' }, scored ? 'Yes' : 'No'),
      el('span', { class: 'mono', style: 'font-size:10.5px;color:' + (game ? 'var(--ink)' : 'var(--ink-mute)') + ';opacity:' + (game ? '1' : '0.45') + ';' }, game || '\u2014')));
  return el('div', { class: 'panel comp states' },
    el('div', { class: 'panel-head' }, el('div', { class: 'ff-display comp-title' }, 'Game inventory')),
    el('p', { class: 'comp-purpose' },
      'Every interactive card kind, in the order a lesson uses them. Fifteen kinds; eleven are scored; seven are also published as standalone mini-games. If a kind is not on this list it does not exist \u2014 add it here before building it.'),
    el('div', null, head, rows),
    el('ul', { class: 'rules' }, [
      'A kind is promoted to a <b>mini-game</b> only if all three hold: it is <b>self-scoring</b>, a whole round can be <b>one kind</b>, and it is a <b>skill that improves with reps</b>.',
      'predict, concept, visual and practical fail the first test; decision and recall fail the third \u2014 recall is bound to the guess made earlier in its own lesson.',
      'Mini-games never touch lesson points or progression. Lesson cards always do.',
      'A mini-game is <b>course-wide practice</b>, never a replay of one lesson \u2014 it carries no lesson id, and its Practice Again row leads with the game name over a topic eyebrow.',
      'A card that <b>cannot be failed</b> still has to be graded on something. Match has no wrong end state \u2014 you clear it either way \u2014 so it grades the <b>route</b>: a board scores only if every pair lands first time.',
    ].map(r => el('li', { html: r }))));
}

function roundLengthDemo() {
  const rows = [['g-match', 5], ['g-flavor', 5], ['g-quiz', 6], ['g-bagpick', 5], ['g-tastefix', 5], ['g-calibrate', 5], ['g-sequence', 5]];
  return '<div style="display:flex;flex-direction:column;gap:9px;font-family:\'IBM Plex Mono\',monospace;font-size:11px;color:var(--ink-mute);">' +
    rows.map(function (r) {
      var pips = '';
      for (var i = 0; i < 6; i++) {
        pips += '<span style="width:14px;height:6px;border-radius:999px;border:1px solid var(--rule);background:' +
          (i < r[1] ? 'var(--accent)' : 'var(--surface-2)') + ';"></span>';
      }
      return '<div style="display:flex;align-items:center;gap:12px;"><span style="width:92px;color:var(--accent);">' + r[0] +
        '</span><span style="display:flex;gap:4px;">' + pips + '</span><span>' + r[1] + ' rounds</span></div>';
    }).join('') + '</div>';
}

function renderGames() {
  const wrap = el('div', { class: 'comp-grid' });

  wrap.append(gameInventory());

  wrap.append(compRules('Card cue',
    'Above the question on every scored card \u2014 in a lesson and in a mini-game alike.',
    "<div style=\"display:flex;align-items:center;gap:8px;line-height:1;font-family:'IBM Plex Sans',sans-serif;font-size:11px;font-weight:500;letter-spacing:0.14em;text-transform:uppercase;color:var(--accent);\"><span>MATCH · DRAG TO PAIR</span><span style=\"width:20px;height:20px;border-radius:999px;border:1px solid var(--rule);color:var(--ink-mute);font-family:'IBM Plex Mono',monospace;font-size:11px;line-height:1;display:grid;place-items:center;flex-shrink:0;\">?</span></div>",
    ['Accent smallcaps naming the card kind, with a 20px “?” ring beside it. One component, <span class="mono">CardCue</span>, keyed by kind.',
     'The “?” opens the how-to-play drawer for that kind \u2014 title, one-line blurb, three numbered steps. The drawer teaches the <b>interaction</b>, so it reads the same wherever that kind appears. A standalone mini-game’s intro screen teaches <b>that game</b> and names its own subject \u2014 deliberately different copy, not a drifted duplicate.',
     'Every kind with a cue must have a matching <span class="mono">CARD_KIND_HELP</span> entry. A cue with no drawer is a bug.',
     'Narrative cards (predict, decision, recall) take a plain label instead \u2014 no ring, no drawer.']));

  wrap.append(compRules('Round length',
    'How many questions a standalone mini-game runs before its results screen.',
    roundLengthDemo(),
    ['<b>Five or six rounds.</b> Below five a single miss swings the score too hard \u2014 one wrong out of two reads as 50% and lands the harshest results copy.',
     'The intro screen states the real round count, read from <span class="mono">MINI_GAME_CONTENT</span>. Never hard-code it, and never count how-to-play steps instead.',
     'The roast meter runs 01 / N across the round; the results screen scores <span class="mono">n / N</span> and switches copy at 80% and 50%.']));

  return section('games', 'System', 'Games',
    'Two systems share one card library. Lesson cards advance a lesson, pay points and feed progression; mini-games are standalone, replayable and scored on their own. The same components render both \u2014 what changes is who is counting.',
    wrap);
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

/* ============================================================================
   9 · INTRO & ONBOARDING
   ========================================================================== */
function renderIntro() {
  const wrap = el('div', { class: 'comp-grid' });

  wrap.append(compRules('Intro screen skeleton',
    'The three screens before the app exists — Loading (00), Welcome (01), Meet Roasty (01b).',
    `<div style="width:100%;max-width:210px;aspect-ratio:9/16;border:1px solid var(--rule);border-radius:14px;background:var(--bg);display:flex;flex-direction:column;padding:18px 16px;gap:10px;">
       <div style="flex:1;border:1px dashed var(--rule);border-radius:14px;display:grid;place-items:center;"><span class="mono" style="font-size:9.5px;letter-spacing:0.14em;text-transform:uppercase;color:var(--ink-mute);">Subject</span></div>
       <div style="${SC}color:var(--accent);">Eyebrow</div>
       <div class="ff-display" style="font-size:19px;line-height:1.05;letter-spacing:-0.02em;color:var(--ink);">The promise.</div>
       <div style="font-size:11px;line-height:1.5;color:var(--ink-mute);">One sentence of what it means for you.</div>
       <div class="mono" style="margin-top:auto;font-size:11px;letter-spacing:0.24em;text-transform:uppercase;color:var(--ink-mute);text-align:center;">Tap anywhere</div>
     </div>`,
    ['Four parts in one order, every time: <b>subject</b> (video, mascot or animation), <b>eyebrow</b>, <b>display line</b>, <b>one sentence</b>. Then the exit affordance, pinned to the bottom.',
     'No chrome at all — no top bar, no tab bar, no header buttons, no progress dots. These screens run before the app frame exists.',
     'The eyebrow is accent on Welcome and Meet Roasty because it names the brand or the character; it is ink-mute anywhere it is only a section label.',
     'The exit affordance is centred on every intro screen even when the content above it is left-aligned — it belongs to the screen, not to the text column.',
     'One idea per screen. If a screen needs two sentences of body copy it is really two screens.']));

  wrap.append(compRules('Tap to continue',
    'Every intro screen that advances on a tap anywhere — Loading and Welcome today.',
    `<div style="display:flex;flex-direction:column;gap:16px;align-items:center;">
       <div class="mono" style="font-size:11px;letter-spacing:0.24em;text-transform:uppercase;color:var(--ink-mute);">Tap anywhere to continue</div>
       <div style="display:flex;align-items:center;gap:10px;opacity:0.45;">
         <span style="width:7px;height:7px;border-radius:999px;background:var(--accent);"></span>
         <span style="${SC}">Tap anywhere to continue</span>
         <span class="mono" style="font-size:9.5px;letter-spacing:0.14em;text-transform:uppercase;color:var(--berry);">← not this</span>
       </div>
     </div>`,
    ['<b>One design, everywhere (.tap-cue):</b> mono label (11), weight 400, 0.24em, uppercase, ink-mute, centred. No dot, no icon, no chevron, no animation.',
     'Mono at the widest tracking in the app — it is a ceremonial mark, not a UI label, so it does <b>not</b> take the Plex Sans smallcaps treatment that labels use.',
     'Centred and bottom-anchored on every intro screen, whatever the alignment of the content above it: 80px from the bottom on a centred screen, flush with the content column’s end on a laid-out one.',
     'The whole screen is the target — the cue is a caption on that fact, never a button. It never gets a border, a fill, or a hit area of its own.',
     'It appears only when the tap is the <b>only</b> way forward. A screen with a real button (Meet Roasty) never shows it.']));

  wrap.append(compRules('Brand mark',
    'The loading screen, first cycle only — the app’s one unaccompanied signature.',
    `<div class="mono" style="font-size:11px;letter-spacing:0.24em;text-transform:uppercase;color:var(--ink-mute);">Brewpath</div>`,
    ['Mono label (11) at <b>0.24em</b> — wider than any label in the app. The tap cue is set identically, because the two share one slot: BREWPATH holds it on the first loop, the cue on every loop after, and the screen never grows a second line.',
     'Mono, not Plex Sans: it is a signature, not a label — the same reason the tap cue is mono.',
     'This is the app’s only signature. It never appears inside the app proper, where the tab bar and headers do the identifying.']));

  wrap.append(compRules('Media frame',
    'Any video or image carried by an intro screen — the Welcome screen’s seed-to-tree loop.',
    `<div style="width:100%;max-width:230px;aspect-ratio:4/3;background:var(--surface);border:1px solid var(--rule);border-radius:14px;position:relative;display:grid;place-items:center;">
       <span class="mono" style="font-size:9.5px;letter-spacing:0.14em;text-transform:uppercase;color:var(--ink-mute);">Video · 4:3</span>
       <span style="position:absolute;bottom:10px;right:10px;width:34px;height:34px;border-radius:999px;background:var(--scrim);display:grid;place-items:center;color:var(--scrim-ink);"><svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M4 9v6h4l5 4V5L8 9H4z" fill="currentColor"/><path d="M16 9l5 6M21 9l-5 6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg></span>
     </div>`,
    ['<b>--r (14px)</b>, full content width, 4:3, 1px rule border, surface fill behind. Media is chrome — it never takes the 2px editorial radius.',
     'Video autoplays muted and loops. Muted is enforced on the element, not just the attribute, or it can start with sound.',
     'It silences and pauses itself before the screen advances, so audio never bleeds into the next screen.',
     'The frame is decorative: tapping it advances the screen like anywhere else.']));

  wrap.append(compRules('Media overlay button',
    'A control that has to sit on top of media — today only the sound toggle on the Welcome video.',
    `<div style="display:flex;gap:12px;">
       <span style="width:44px;height:44px;border-radius:999px;background:var(--scrim);display:grid;place-items:center;color:var(--scrim-ink);"><svg width="19" height="19" viewBox="0 0 24 24" fill="none"><path d="M4 9v6h4l5 4V5L8 9H4z" fill="currentColor"/><path d="M16 9l5 6M21 9l-5 6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg></span>
       <span style="width:44px;height:44px;border-radius:999px;background:var(--scrim);display:grid;place-items:center;color:var(--scrim-ink);"><svg width="19" height="19" viewBox="0 0 24 24" fill="none"><path d="M4 9v6h4l5 4V5L8 9H4z" fill="currentColor"/><path d="M16.5 8.5a5 5 0 010 7M19 6a8.5 8.5 0 010 12" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg></span>
     </div>`,
    ['44px round, no border, 8px backdrop blur, glyph at 19px. Fill is <b>--scrim</b>, glyph is <b>--scrim-ink</b>. Never a raw rgba().',
     '<b>The scrim does not follow the mood.</b> It is the same dark tint in cupping and dark roast, because the footage under it is the same in both — a scrim bound to --ink inverts to cream in dark mood and dissolves into light media.',
     'The only button in the app allowed to sit on a fill instead of a surface — it has media under it, not a background.',
     'Inset 12px from the media frame’s bottom-right corner.',
     'It stops the tap from reaching the screen, so toggling sound never advances the flow. Any control placed on media must do the same.']));

  wrap.append(compRules('Loading sequence',
    'The wake-up loop the app shows while it opens — Roasty asleep, watered, awake, sprouting.',
    `<div style="display:flex;flex-direction:column;align-items:center;gap:12px;">
       <div style="display:flex;align-items:center;gap:8px;">
         <svg width="12" height="17" viewBox="0 0 14 20"><path d="M7 0 C 9 6 13 10 13 14 A 6 6 0 0 1 1 14 C 1 10 5 6 7 0 Z" fill="var(--water)"/><ellipse cx="5" cy="11" rx="1.5" ry="2.4" fill="var(--water-hi)" opacity="0.7"/></svg>
         <span class="mono" style="font-size:9.5px;letter-spacing:0.14em;text-transform:uppercase;color:var(--ink-mute);">— water</span>
       </div>
       <div class="ff-display" style="font-style:italic;font-size:19px;letter-spacing:-0.02em;color:var(--ink);">Brewing your lesson</div>
       <div style="display:inline-flex;gap:6px;">
         <span style="width:5px;height:5px;border-radius:999px;background:var(--accent);opacity:1;"></span>
         <span style="width:5px;height:5px;border-radius:999px;background:var(--accent);opacity:0.55;"></span>
         <span style="width:5px;height:5px;border-radius:999px;background:var(--accent);opacity:0.22;"></span>
       </div>
     </div>`,
    ['Six steps, then it loops: sleep · drop · wake · sprout · idle · hold — 1200 / 800 / 600 / 700 / 1800 / 1400ms.',
     'The caption is <b>Fraunces italic</b> at heading size — Roasty narrating, not a title. It fades in only at step 4, once the mascot has finished waking; a caption that appears immediately reads as a title.',
     'The falling drop is <b>--water</b> with a --water-hi highlight — the only cool colour on the screen.',
     'Three accent dots, 5px, pulsing on a 1.4s stagger. They are decoration, not progress — the app never claims a percentage it does not know.',
     'It always loops rather than ending, and a tap escapes it from the first frame. A loader that can finish would need a real completion signal.']));

  return section('intro', 'Flow', 'Intro and onboarding',
    'Three screens run before the app frame exists — Loading, Welcome, Meet Roasty — and they are the first design the user ever sees. Because they sit outside the tab bar, the header and every screen chrome pattern, nothing else in the library governs them; without this section each one quietly invents its own tap cue, its own caption type and its own overlay colour. The shape is fixed: one subject, one eyebrow, one display line, one sentence, one way out.',
    wrap);
}

const SECTIONS = [
  ['color', 'Colour'], ['type', 'Type'], ['shape', 'Shape'],
  ['icons', 'Icons'], ['intro', 'Intro'], ['components', 'Components'], ['games', 'Games'], ['plus', 'Plus'], ['flags', 'Flags'],
];

function boot() {
  const main = document.getElementById('ds-main');
  main.append(renderColors(), renderType(), renderShape(), renderIcons(), renderIntro(), renderComponents(), renderGames(), renderGating(), renderFlags());

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
