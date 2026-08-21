// bean-anatomy.jsx — the six layers of a coffee cherry, and the blind-bag
// challenge that uses them.
//
//   1. CherrySection  — interactive cross-section reference (VISUAL_GUIDE_CONTENT.anatomy),
//                       so it also lands in Cards / Saved like the other guides.
//   2. GreenBean      — a green (unroasted) seed drawn from process cues:
//                       body colour, centre-cut colour, mottling, chaff.
//   3. BagPickCard    — card kind 'bagpick'. Draw a sample from an unlabelled
//                       bag, inspect it, and call the process from the look.
//
// Loaded before lesson.jsx (which reads BAGPICK_ROUNDS at eval time).

const { useState: useStateB } = React;

// The cherry ramp lives in the illustration palette (--art-cherry-*): a ripe
// cherry is the same colour in either mood, so these tokens never flip. The same
// six stops draw the Layers card and the practical cross-section.
const CHERRY_LAYERS = [
  { n: '01', name: 'Skin', latin: 'exocarp', fill: 'var(--art-cherry-skin)', r: 88,
    fate: 'Stripped at the mill',
    note: 'The outer skin. Deep red when ripe on most varieties — the colour pickers read from the row.' },
  { n: '02', name: 'Pulp', latin: 'mesocarp', fill: 'var(--art-cherry-pulp)', r: 81,
    fate: 'Stripped at the mill',
    note: 'A thin layer of sweet fruit. Less than you would hope: about as much flesh as a small grape.' },
  { n: '03', name: 'Mucilage', latin: 'pectin gel', fill: 'var(--art-cherry-gel)', r: 65,
    fate: 'Rinsed off, or dried on',
    note: 'Slippery, honey-sweet gel glued to the seed. Water alone will not shift it — it ferments loose, or dries on. This is the layer washed, honey and natural argue over.' },
  { n: '04', name: 'Parchment', latin: 'pergamino', fill: 'var(--art-cherry-parchment)', r: 57,
    fate: 'Hulled before export',
    note: 'A papery shell. Coffee rests and ships inside it, then gets hulled just before it leaves for the roaster.' },
  { n: '05', name: 'Silverskin', latin: 'spermoderm', fill: 'var(--art-cherry-silverskin)', r: 50,
    fate: 'Becomes chaff',
    note: 'A tissue-thin membrane. Most of it flakes off in the roaster as chaff; the rest stays packed in the bean’s centre crease.' },
  { n: '06', name: 'Seed', latin: 'endosperm', fill: 'var(--art-cherry-seed)', r: 45,
    fate: 'This is your coffee',
    note: 'The bean. Two per cherry, pressed flat face to flat face — which is why one side is domed and one is creased. About one cherry in twenty sets only one seed, which grows round instead: a peaberry.' },
];

// Cross-section of a cherry: concentric layers you can tap, with the layer list
// below. Selecting either side highlights the other.
function CherrySection() {
  const [sel, setSel] = useStateB(2); // opens on mucilage — the layer that matters
  const L = CHERRY_LAYERS[sel];
  return (
    <div>
      <svg viewBox="0 0 200 200" style={{ width: '100%', maxWidth: 250, display: 'block', margin: '0 auto' }}>
        {CHERRY_LAYERS.map((l, i) => (
          <circle key={l.name} cx="100" cy="100" r={l.r}
                  fill={sel === i ? l.fill : `color-mix(in oklab, ${l.fill} 70%, var(--bg))`}
                  stroke="rgba(27,22,20,0.28)" strokeWidth="0.9"
                  onClick={() => setSel(i)} style={{ cursor: 'pointer', transition: 'fill .3s ease' }}/>
        ))}
        {/* the two seeds meet along a flat face */}
        <g opacity={sel === 5 ? 1 : 0.25} style={{ pointerEvents: 'none', transition: 'opacity .3s ease' }}>
          <line x1="100" y1="56" x2="100" y2="144" stroke="var(--art-seed-crease)" strokeWidth="2.4"/>
          <path d="M100 62 C104 74, 96 84, 100 100 S104 126, 100 138"
                fill="none" stroke="var(--art-cherry-silverskin)" strokeOpacity="0.5" strokeWidth="1.6" strokeLinecap="round"/>
        </g>
        {/* the selected band, called out: accent edges + a number chip sitting on it */}
        {(() => {
          const outer = L.r;
          const inner = sel < CHERRY_LAYERS.length - 1 ? CHERRY_LAYERS[sel + 1].r : 0;
          const mid = (outer + inner) / 2;
          return (
            <g style={{ pointerEvents: 'none' }}>
              <circle cx="100" cy="100" r={outer} fill="none" stroke="var(--accent)" strokeWidth="2.4"/>
              {inner > 0 && <circle cx="100" cy="100" r={inner} fill="none" stroke="var(--accent)" strokeWidth="2.4"/>}
              <circle cx="100" cy={100 - mid} r="11" fill="var(--accent)"/>
              <text x="100" y={100 - mid + 3.6} textAnchor="middle" fontFamily="IBM Plex Mono"
                    fontSize="10" fontWeight="600" fill="var(--bg)">{L.n}</text>
            </g>
          );
        })()}
      </svg>

      <div style={{ marginTop: 18 }}>
        {CHERRY_LAYERS.map((l, i) => {
          const on = sel === i;
          return (
            <div key={l.name} onClick={() => setSel(i)} style={{
              cursor: 'pointer', padding: on ? '11px 10px' : '11px 0',
              margin: on ? '0 -10px' : 0, borderRadius: on ? 10 : 0,
              background: on ? 'color-mix(in oklab, var(--accent) 10%, transparent)' : 'transparent',
              borderTop: '1px solid ' + (on ? 'transparent' : 'var(--rule)'),
              transition: 'background .25s ease',
            }}>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 9 }}>
                <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.1em', color: on ? 'var(--accent)' : 'var(--ink-mute)', flexShrink: 0 }}>{l.n}</span>
                <span style={{ width: 11, height: 11, borderRadius: 2, background: l.fill, flexShrink: 0, opacity: on ? 1 : 0.5, boxShadow: on ? '0 0 0 2px color-mix(in oklab, var(--accent) 55%, transparent)' : '0 0 0 1px rgba(27,22,20,0.18)' }}/>
                <span style={{ fontSize: 'var(--t-body)', fontWeight: on ? 600 : 500, color: on ? 'var(--ink)' : 'var(--ink-mute)' }}>{l.name}</span>
                {on && <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', color: 'var(--ink-mute)', whiteSpace: 'nowrap' }}>{l.latin}</span>}
              </div>
              {on && (
                <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.08em', textTransform: 'uppercase', color: 'var(--sage)', margin: '7px 0 0', paddingLeft: 30 }}>{l.fate}</div>
              )}
              {on && (
                <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: '5px 0 0', paddingLeft: 30, textWrap: 'pretty' }}>{l.note}</p>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
window.CherrySection = CherrySection;
window.CHERRY_LAYERS = CHERRY_LAYERS;

// ───────────────────────────────────────────────────────────
// GREEN BEAN — the same bean silhouette the app uses everywhere (RoastBean /
// PointsBean), coloured from a lot's real visual cues instead of a roast ramp.
// bean = { body, crease, mottle: 0–2, chaff: bool }
// ───────────────────────────────────────────────────────────
function GreenBean({ bean, size = 60, rot = -16, seed = 0 }) {
  const b = bean || {};
  const rnd = (i) => {
    const x = Math.sin((seed + 1) * 12.9898 + i * 78.233) * 43758.5453;
    return x - Math.floor(x);
  };
  const patches = [];
  const n = (b.mottle || 0) * 3;
  for (let i = 0; i < n; i++) {
    // polar placement keeps every patch inside the bean, so no clip path needed
    const a = rnd(i) * Math.PI * 2, d = 0.28 + rnd(i + 9) * 0.3;
    patches.push(
      <ellipse key={i} cx={12 + Math.cos(a) * 7.5 * d} cy={12 + Math.sin(a) * 9.5 * d}
               rx={1.5 + rnd(i + 3) * 1.6} ry={1.1 + rnd(i + 5) * 1.3}
               fill="#6B4A22" opacity={0.16 + rnd(i + 7) * 0.14}/>
    );
  }
  const flecks = b.chaff ? [
    <ellipse key="f1" cx="11.2" cy="8.2" rx="0.85" ry="0.42" fill="#F3EADA" opacity="0.6" transform="rotate(-14 11.2 8.2)"/>,
    <ellipse key="f2" cx="12.7" cy="16" rx="0.7" ry="0.38" fill="#F3EADA" opacity="0.5" transform="rotate(12 12.7 16)"/>,
  ] : null;
  return (
    <svg width={size} height={size * 1.04} viewBox="0 0 24 24" style={{ display: 'block', flexShrink: 0 }} aria-hidden="true">
      <g transform={`rotate(${rot} 12 12)`}>
        <ellipse cx="12" cy="12.6" rx="7.5" ry="9.5" fill="rgba(27,22,20,0.18)"/>
        <ellipse cx="12" cy="12" rx="7.5" ry="9.5" fill={b.body || 'var(--art-cherry-seed)'}/>
        {patches}
        <ellipse cx="12" cy="12" rx="7.5" ry="9.5" fill="none" stroke="rgba(27,22,20,0.35)" strokeWidth="0.7"/>
        <path d="M12 3.5 C 13.5 7, 10.5 9, 12 12 S 13.5 17, 12 20.5"
              fill="none" stroke="rgba(27,22,20,0.3)" strokeWidth="2.9" strokeLinecap="round"/>
        <path d="M12 3.5 C 13.5 7, 10.5 9, 12 12 S 13.5 17, 12 20.5"
              fill="none" stroke={b.crease || 'var(--art-cherry-silverskin)'} strokeWidth="2" strokeLinecap="round"/>
        {flecks}
      </g>
    </svg>
  );
}
window.GreenBean = GreenBean;

const PROCESS_LABEL = { washed: 'Washed', honey: 'Honey', natural: 'Natural' };
window.PROCESS_LABEL = PROCESS_LABEL;

// ───────────────────────────────────────────────────────────
// BAGPICK CARD — an unlabelled bag, a sample of three seeds, and three things
// you can inspect. Call the process from the look alone; the feedback names
// which cue was the real tell.
// card = { kind:'bagpick', bag, origin, bean, cues:[{id,label,text}], tell,
//          options:['washed','honey','natural'], answer, prompt, explain }
// ───────────────────────────────────────────────────────────
function BagPickCard({ card, onContinue, onCorrect }) {
  const [seen, setSeen] = useStateB(() => new Set());
  const [picked, setPicked] = useStateB(null);
  // Render order only — option identity is the process key, not the position.
  const [order] = useStateB(() => {
    const a = card.options.slice();
    for (let i = a.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }
    return a;
  });
  const right = picked !== null && picked === card.answer;
  const revealed = (id) => picked !== null || seen.has(id);

  const inspect = (id) => {
    if (picked !== null) return;
    setSeen(prev => { const next = new Set(prev); next.add(id); return next; });
  };
  const pick = (opt) => {
    if (picked !== null) return;
    setPicked(opt);
    if (opt === card.answer && onCorrect) onCorrect();
  };

  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', flex: '1 0 auto', minHeight: 600 }}>
      <CardCue kind="bagpick">Blind bag · read the beans</CardCue>

      {/* the bag: no label until you commit */}
      <div style={{
        borderRadius: 16, padding: '13px 15px 6px',
        border: '1px ' + (picked === null ? 'dashed' : 'solid') + ' ' + (picked === null ? 'color-mix(in oklab, var(--accent) 38%, var(--rule))' : 'var(--rule)'),
        background: picked === null ? 'color-mix(in oklab, var(--accent) 5%, transparent)' : 'var(--surface)',
        transition: 'background .35s ease, border-color .35s ease',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
          <span className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.14em', textTransform: 'uppercase', color: 'var(--ink-mute)' }}>{card.bag}</span>
          {picked === null ? (
            <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.16em', textTransform: 'uppercase', color: 'var(--accent)', border: '1px dashed color-mix(in oklab, var(--accent) 50%, transparent)', borderRadius: 999, padding: '3px 9px' }}>Process hidden</span>
          ) : (
            <span className="fade-up ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.16em', textTransform: 'uppercase', color: 'var(--sage)', border: '1px solid color-mix(in oklab, var(--sage) 45%, transparent)', background: 'color-mix(in oklab, var(--sage) 12%, transparent)', borderRadius: 999, padding: '3px 9px' }}>{PROCESS_LABEL[card.answer]}</span>
          )}
        </div>
        <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink)', marginTop: 4 }}>{card.origin}</div>
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'flex-end', gap: 8, padding: '16px 0 14px' }}>
          {[0, 1, 2].map(i => (
            <GreenBean key={i} bean={card.bean} seed={i} size={i === 1 ? 82 : 72}
                       rot={i === 0 ? -22 : i === 1 ? 7 : -6}/>
          ))}
        </div>
      </div>

      <h2 className="ff-display" style={{
        fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.15, letterSpacing: '-0.01em',
        margin: '20px 0 0', color: 'var(--ink)', textWrap: 'pretty',
      }}>{card.prompt}</h2>

      {/* inspect the sample — each cue is one tap */}
      <div style={{ marginTop: 16 }}>
        {card.cues.map((c) => {
          const on = revealed(c.id);
          const isTell = picked !== null && card.tell === c.id;
          return (
            <button key={c.id} onClick={() => inspect(c.id)} disabled={picked !== null}
                    style={{
                      appearance: 'none', width: '100%', textAlign: 'left', font: 'inherit',
                      display: 'grid', gridTemplateColumns: 'auto 1fr', alignItems: 'baseline', gap: 12,
                      padding: '12px 12px', marginBottom: 8, borderRadius: 12,
                      cursor: picked === null && !on ? 'pointer' : 'default',
                      background: isTell ? 'color-mix(in oklab, var(--accent) 12%, var(--surface))' : (on ? 'var(--surface)' : 'transparent'),
                      border: '1px ' + (on ? 'solid' : 'dashed') + ' ' + (isTell ? 'var(--accent)' : 'var(--rule)'),
                      transition: 'background .25s ease, border-color .25s ease',
                    }}>
              <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.12em', textTransform: 'uppercase', color: isTell ? 'var(--accent)' : 'var(--ink-mute)', whiteSpace: 'nowrap' }}>{c.label}</span>
              <span style={{ fontSize: 'var(--t-support)', lineHeight: 1.45, color: on ? 'var(--ink)' : 'var(--ink-mute)', textWrap: 'pretty' }}>
                {on ? c.text : 'Tap to inspect'}
              </span>
            </button>
          );
        })}
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 14 }}>
        {order.map((opt) => {
          let cls = 'mcq-choice';
          if (picked !== null) {
            if (opt === card.answer) cls += ' correct';
            else if (opt === picked) cls += ' incorrect';
          }
          return (
            <button key={opt} className={cls} disabled={picked !== null} onClick={() => pick(opt)}>{PROCESS_LABEL[opt]}</button>
          );
        })}
      </div>

      {picked !== null && (
        <window.AnswerFeedback correct={right} marginTop={20}
          label={right ? 'CALLED IT' : PROCESS_LABEL[card.answer].toUpperCase() + ', ACTUALLY'}
          text={card.explain}/>
      )}

      <div style={{ flex: 1 }}/>
      <div style={{ paddingTop: 32 }}>
        <button className="btn btn-primary" onClick={onContinue} disabled={picked === null}>Continue</button>
      </div>
    </div>
  );
}
window.BagPickCard = BagPickCard;

// ───────────────────────────────────────────────────────────
// THE ROUNDS — five bags, hardest last. Each one teaches a different tell:
// the centre cut, the mottling, the aroma, and (bag 04) the trap of reading
// age as process.
// ───────────────────────────────────────────────────────────
const BAGPICK_ROUNDS = [
  { kind: 'bagpick', bag: 'BAG 01', origin: 'Ethiopia · 1,900 m',
    prompt: 'How was this lot processed?',
    bean: { body: 'var(--art-cherry-seed)', crease: '#F0E9D9', mottle: 0, chaff: false },
    options: ['washed', 'natural'], answer: 'washed', tell: 'cut',
    cues: [
      { id: 'colour', label: 'Colour', text: 'Even blue-green. Every bean the same shade.' },
      { id: 'cut', label: 'Centre cut', text: 'A clean, pale line — nothing packed into it.' },
      { id: 'aroma', label: 'Aroma', text: 'Dry and grassy, like hay. No sweetness.' },
    ],
    explain: 'Depulped and fermented clean within hours, so no fruit sugar was ever left to stain the seed. Even colour and a pale centre cut are the washed signature.' },

  { kind: 'bagpick', bag: 'BAG 02', origin: 'Brazil · 1,100 m',
    prompt: 'And this one?',
    bean: { body: '#A98A55', crease: '#8E5A28', mottle: 2, chaff: true },
    options: ['washed', 'natural'], answer: 'natural', tell: 'cut',
    cues: [
      { id: 'colour', label: 'Colour', text: 'Uneven yellow-brown, patchy from bean to bean.' },
      { id: 'cut', label: 'Centre cut', text: 'Stained amber, with silverskin still packed inside.' },
      { id: 'aroma', label: 'Aroma', text: 'Sweet and winey, a little fermented.' },
    ],
    explain: 'The whole cherry dried on the seed, so mucilage sugars soaked into the centre cut and left it stained. That amber crease is the natural giveaway.' },

  { kind: 'bagpick', bag: 'BAG 03', origin: 'Costa Rica · 1,500 m',
    prompt: 'Three options now. Which is it?',
    bean: { body: '#B99C5F', crease: 'var(--art-cherry-gel)', mottle: 1, chaff: true },
    options: ['washed', 'honey', 'natural'], answer: 'honey', tell: 'colour',
    cues: [
      { id: 'colour', label: 'Colour', text: 'Warm gold, fairly even — too warm for washed, too tidy for a natural.' },
      { id: 'cut', label: 'Centre cut', text: 'Honey-orange, but mostly clean of debris.' },
      { id: 'aroma', label: 'Aroma', text: 'Sweet, like dried cane. None of the funk.' },
    ],
    explain: 'Honey lots dry with some mucilage still on: enough sugar to tint the whole seed gold, not enough fruit to ferment into full natural funk. It sits between the two on the look, too.' },

  { kind: 'bagpick', bag: 'BAG 04', origin: 'Colombia · last year’s harvest',
    prompt: 'Careful with this one',
    bean: { body: '#B3A878', crease: '#EFE7D3', mottle: 0, chaff: false },
    options: ['washed', 'honey', 'natural'], answer: 'washed', tell: 'cut',
    cues: [
      { id: 'colour', label: 'Colour', text: 'Yellowed all over — but evenly. Every bean has faded the same amount.' },
      { id: 'cut', label: 'Centre cut', text: 'Pale and clean.' },
      { id: 'aroma', label: 'Aroma', text: 'Flat and papery, faintly woody.' },
    ],
    explain: 'Age fades a green bean evenly — that is a freshness tell, not a process tell. Process shows in the centre cut, and this one is pale and clean: washed, just old.' },

  { kind: 'bagpick', bag: 'BAG 05', origin: 'Ethiopia · 2,050 m',
    prompt: 'Last bag. Call it',
    bean: { body: '#9E7C45', crease: '#7A4526', mottle: 2, chaff: true },
    options: ['washed', 'honey', 'natural'], answer: 'natural', tell: 'aroma',
    cues: [
      { id: 'colour', label: 'Colour', text: 'Mottled brown-green. No two beans quite alike.' },
      { id: 'cut', label: 'Centre cut', text: 'Dark, and packed with silverskin.' },
      { id: 'aroma', label: 'Aroma', text: 'Loud strawberry and fermented fruit — you can smell it across the bench.' },
    ],
    explain: 'Fruit dried on the seed for weeks in the sun. Mottled colour, a stained crease and that jammy smell all point the same way — and at this altitude, that is a very deliberate natural.' },
];
window.BAGPICK_ROUNDS = BAGPICK_ROUNDS;
