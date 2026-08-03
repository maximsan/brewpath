// practical.jsx — the "understand what changes taste, and what to fix" layer.
// Three new card families, all in the existing card system so they slot inside
// normal lessons (and, for training cards, into the Cards tab / dictionary /
// saved / flashcards):
//
//   1. TasteFixCard     — a lightweight scenario mini-game: my cup tastes X,
//                         what do I change first?
//   2. TrainingCard     — reusable visual reference: Roast / Grind / Extraction
//                         / Ratio. Rendered full inside lessons + the card
//                         sheet, and as a compact thumb in the collection grid.
//
// Nothing here invents a new engine — tastefix is just a card kind the
// LessonPlayer already knows how to advance, and TrainingCard is plain
// presentational markup.

// Small adjust/wrench glyph — the family mark for "a thing you can change".
function TuneMark({ size = 16, color = 'currentColor', stroke = 1.6 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={{ flexShrink: 0 }} aria-hidden="true">
      <path d="M4 7h9 M4 17h5" stroke={color} strokeWidth={stroke} strokeLinecap="round"/>
      <path d="M18 7h2 M14 17h6" stroke={color} strokeWidth={stroke} strokeLinecap="round"/>
      <circle cx="15.5" cy="7" r="2.4" fill="var(--bg)" stroke={color} strokeWidth={stroke}/>
      <circle cx="11" cy="17" r="2.4" fill="var(--bg)" stroke={color} strokeWidth={stroke}/>
    </svg>
  );
}
window.TuneMark = TuneMark;

// ───────────────────────────────────────────────────────────
// TASTE FIX CARD
// The signature interaction of this update. A scenario ("my cup tastes sour
// and thin"), one question ("what would you try first?"), a few options, and
// non-punitive feedback that names the cause. Scored like an MCQ so it feeds
// the lesson's perfect-run + XP the same way.
// card = { kind:'tastefix', tags:['SOUR','THIN'], scenario, prompt, choices:[{t,correct}], explain }
// ───────────────────────────────────────────────────────────
function TasteFixCard({ card, onContinue, onXp }) {
  const [picked, setPicked] = React.useState(null);
  // Render order only — the fix is authored first in every tastefix card, so
  // without this the answer is always the top button.
  const [order] = React.useState(() => {
    const a = Array.from({ length: card.choices.length }, (_, i) => i);
    for (let i = a.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }
    return a;
  });
  const correctIdx = card.choices.findIndex(c => c.correct);
  const handlePick = (i) => {
    if (picked !== null) return;
    setPicked(i);
    if (i === correctIdx && onXp) onXp(2);
  };
  const right = picked !== null && picked === correctIdx;

  // Cup reacts to your fix (tweakable). On a good fix the cup settles to
  // BALANCED and pulses; a wrong fix leaves it off and shakes.
  const cupReacts = (typeof window !== 'undefined' && window.__tweaks && window.__tweaks.tasteFixReact === false) ? false : true;
  const setupBrief = (typeof window !== 'undefined' && window.__tweaks && window.__tweaks.tasteFixSetup === 'brief');
  const balanced = picked !== null && right && cupReacts;
  const worsened = picked !== null && !right && cupReacts;
  const panelRef = React.useRef(null);
  React.useEffect(() => {
    if (picked === null || !cupReacts || !panelRef.current || !panelRef.current.animate) return;
    if (right) panelRef.current.animate([{ transform: 'scale(1)' }, { transform: 'scale(1.035)' }, { transform: 'scale(1)' }], { duration: 460, easing: 'ease-out' });
    else panelRef.current.animate([{ transform: 'translateX(0)' }, { transform: 'translateX(-5px)' }, { transform: 'translateX(5px)' }, { transform: 'translateX(-3px)' }, { transform: 'translateX(0)' }], { duration: 380, easing: 'ease-in-out' });
  }, [picked]);
  const cupColor = balanced ? 'var(--sage)' : 'var(--berry)';
  const hasScenario = !!card.scenario;
  const chipsEl = (
    <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', gap: 6 }}>
      {balanced ? (
        <span key="balanced" className="fade-up ff-mono" style={{
          fontSize: 'var(--t-label)', fontWeight: 500, letterSpacing: '0.1em', textTransform: 'uppercase',
          color: 'var(--sage)', background: 'color-mix(in oklab, var(--sage) 16%, transparent)',
          padding: '3px 9px', borderRadius: 999,
        }}>Balanced</span>
      ) : (card.tags || []).map((t, i) => (
        <span key={i} className="ff-mono" style={{
          fontSize: 'var(--t-label)', fontWeight: 500, letterSpacing: '0.1em', textTransform: 'uppercase',
          color: 'var(--berry)', background: 'color-mix(in oklab, var(--berry) 13%, transparent)',
          padding: '3px 9px', borderRadius: 999,
          opacity: worsened ? 0.6 : 1, transition: 'opacity .3s ease',
        }}>{t}</span>
      ))}
    </div>
  );
  const stateLabel = (
    <div className="ff-mono" style={{ fontSize: 'var(--t-label)', fontWeight: 500, letterSpacing: '0.12em', textTransform: 'uppercase', color: balanced ? 'var(--sage)' : 'color-mix(in oklab, var(--berry) 70%, var(--ink-mute))', transition: 'color .45s ease' }}>{balanced ? 'FIXED' : 'STARTING POINT'}</div>
  );

  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', flex: '1 0 auto', minHeight: 600 }}>
      <GameCue kind="tastefix">Taste Fix</GameCue>

      {/* prerequisites — the cup you're fixing + its setup, one crafted card that reacts to your fix */}
      <div ref={panelRef} style={{
        position: 'relative', borderRadius: 18, overflow: 'hidden', margin: '8px 0 0',
        padding: setupBrief ? 0 : '16px 18px 15px',
        background: setupBrief ? 'transparent'
          : (balanced
              ? 'linear-gradient(160deg, color-mix(in oklab, var(--sage) 14%, var(--surface)), var(--surface) 70%)'
              : 'linear-gradient(160deg, color-mix(in oklab, var(--berry) 8%, var(--surface)), var(--surface) 68%)'),
        border: setupBrief ? '0' : ('1px solid ' + (balanced ? 'color-mix(in oklab, var(--sage) 30%, var(--rule))' : 'color-mix(in oklab, var(--berry) 16%, var(--rule))')),
        boxShadow: setupBrief ? 'none' : '0 1px 2px color-mix(in oklab, var(--ink) 6%, transparent)',
        transition: 'background .45s ease, border-color .45s ease, box-shadow .45s ease',
      }}>
        {/* content, aligned to the card edge (cup removed) */}
        <div style={{ minWidth: 0, display: 'flex', flexDirection: 'column', gap: hasScenario ? 10 : 8 }}>
          {stateLabel}
          {hasScenario && (
            <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.4, color: 'var(--ink)', margin: 0, textWrap: 'pretty' }}>{card.scenario}</p>
          )}
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, flexWrap: 'wrap' }}>
            <span className="ff-mono" style={{ fontSize: 'var(--t-label)', fontWeight: 500, letterSpacing: '0.12em', textTransform: 'uppercase', color: 'var(--ink-mute)', flexShrink: 0 }}>{balanced ? 'RESULT' : 'TASTES'}</span>
            {chipsEl}
          </div>
        </div>
      </div>

      <h2 className="ff-display" style={{
        fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.15, letterSpacing: '-0.01em',
        margin: '20px 0 0', color: 'var(--ink)', textWrap: 'pretty',
      }}>{card.prompt}</h2>


      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 24 }}>
        {order.map((oi) => {
          let cls = 'mcq-choice';
          if (picked !== null) {
            if (oi === correctIdx) cls += ' correct';
            else if (oi === picked) cls += ' incorrect';
          }
          return (
            <button key={oi} className={cls} disabled={picked !== null} onClick={() => handlePick(oi)}>{card.choices[oi].t}</button>
          );
        })}
      </div>

      {picked !== null && (
        <div style={{ marginTop: 20, display: 'flex', gap: 14, alignItems: 'flex-start' }}>
          <div style={{ flexShrink: 0, marginTop: -8 }}>
            <Roasty state={right ? 'correct' : 'wrong'} size={72}/>
          </div>
          <div style={{ flex: 1 }}>
            <div className="ff-mono" style={{
              fontSize: 'var(--t-label)', letterSpacing: '0.14em', textTransform: 'uppercase', marginBottom: 8,
              color: right ? 'var(--sage)' : 'var(--berry)',
            }}>{right ? 'GOOD FIX' : 'NOT QUITE'}</div>
            <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: 0, textWrap: 'pretty' }}>{card.explain}</p>
          </div>
        </div>
      )}

      <div style={{ flex: 1 }}/>
      <div style={{ paddingTop: 32 }}>
        <button className="btn btn-primary" onClick={onContinue} disabled={picked === null}>Continue</button>
      </div>
    </div>
  );
}
window.TasteFixCard = TasteFixCard;

// ───────────────────────────────────────────────────────────
// TRAINING-CARD CONTENT + VISUALS
// Four beginner reference cards. Each has a title/summary/fact (for the
// collection + card sheet) and a `render` for the visual body.
// ───────────────────────────────────────────────────────────

// The roast ramp from the illustration palette — literal coffee, same in both
// moods. These are the tokens the roast meter and every roast drawing use, so
// "light / medium / dark" is one colour story app-wide.
const ROAST_BEANS = ['var(--art-roast-light)', 'var(--art-roast-mid)', 'var(--art-roast-dark)'];

function Swatch({ color, ring }) {
  return (
    <span style={{
      width: 30, height: 30, borderRadius: 999, flexShrink: 0, background: color,
      boxShadow: ring ? '0 0 0 1px var(--rule)' : 'none',
    }}/>
  );
}

// A level row: leading visual + name, keywords, and a beginner note.
function LevelRow({ visual, name, keywords, note }) {
  return (
    <div style={{ display: 'grid', gridTemplateColumns: 'auto 1fr', gap: 14, alignItems: 'start', padding: '14px 0', borderBottom: '1px solid var(--rule)' }}>
      <div style={{ paddingTop: 2 }}>{visual}</div>
      <div style={{ minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: 10 }}>
          <span style={{ fontSize: 'var(--t-body)', fontWeight: 500, color: 'var(--ink)' }}>{name}</span>
          <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.08em', textTransform: 'uppercase', color: 'var(--sage)', textAlign: 'right' }}>{keywords}</span>
        </div>
        <div style={{ fontSize: 'var(--t-support)', lineHeight: 1.45, color: 'var(--ink-mute)', marginTop: 5, textWrap: 'pretty' }}>{note}</div>
      </div>
    </div>
  );
}

// Grind particle box — dot field whose count/size fakes particle size.
function GrindDots({ level }) {
  const spec = level === 0 ? { n: 4, r: 3.4 } : level === 1 ? { n: 9, r: 2.2 } : { n: 18, r: 1.3 };
  const cells = [];
  const cols = Math.ceil(Math.sqrt(spec.n));
  for (let i = 0; i < spec.n; i++) {
    const cx = 6 + (i % cols) * (18 / cols) + (Math.random() * 2 - 1);
    const cy = 6 + Math.floor(i / cols) * (18 / cols) + (Math.random() * 2 - 1);
    cells.push(<circle key={i} cx={cx} cy={cy} r={spec.r} fill="var(--ink-mute)"/>);
  }
  return (
    <span style={{ width: 30, height: 30, borderRadius: 12, display: 'block', background: 'var(--surface-2)', border: '1px solid var(--rule)' }}>
      <svg viewBox="0 0 30 30" width="30" height="30">{cells}</svg>
    </span>
  );
}

// Horizontal 3-stop spectrum with a marker at the ideal middle.
function SpectrumBar({ stops, marker = 0.5, colors }) {
  return (
    <div>
      <div style={{ position: 'relative', height: 12, borderRadius: 999, overflow: 'hidden', display: 'flex', border: '1px solid var(--rule)' }}>
        {colors.map((c, i) => (
          <span key={i} style={{ flex: 1, background: c }}/>
        ))}
        <span style={{
          position: 'absolute', top: -3, left: `calc(${marker * 100}% - 8px)`,
          width: 16, height: 16, borderRadius: 999, background: 'var(--bg)',
          border: '2px solid var(--ink)', boxShadow: '0 1px 3px rgba(0,0,0,0.3)',
        }}/>
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 8, marginTop: 12 }}>
        {stops.map((s, i) => (
          <div key={i} style={{ textAlign: i === 0 ? 'left' : i === 2 ? 'right' : 'center' }}>
            <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.1em', textTransform: 'uppercase', color: i === 1 ? 'var(--sage)' : 'var(--ink-mute)' }}>{s.label}</div>
            <div style={{ fontSize: 'var(--t-support)', lineHeight: 1.4, color: 'var(--ink)', marginTop: 4, textWrap: 'pretty' }}>{s.cue}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

const TRAINING = {
  roast: {
    id: 'roast', label: 'ROAST',
    title: 'Roast Levels',
    summary: 'Light to dark — how the roast shifts taste before you even brew.',
    fact: 'Medium roast is the most forgiving place for a beginner to start.',
    body: () => (
      <div>
        <LevelRow visual={<Swatch color={ROAST_BEANS[0]} ring/>} name="Light" keywords="Bright · floral" note="Acidic and fruity. Can taste sharp or sour if under-extracted." />
        <LevelRow visual={<Swatch color={ROAST_BEANS[1]}/>} name="Medium" keywords="Balanced · sweet" note="Rounded and easygoing — the safest place for a beginner to start." />
        <LevelRow visual={<Swatch color={ROAST_BEANS[2]}/>} name="Dark" keywords="Bitter · smoky" note="Heavier and bolder. Turns harsh easily, so go gentler on grind and heat." />
      </div>
    ),
  },
  grind: {
    id: 'grind', label: 'GRIND SIZE',
    title: 'Grind Size',
    summary: 'Coarse to fine — the dial that controls how fast flavour extracts.',
    fact: 'Grind is usually the first thing to change when a cup tastes off.',
    body: () => (
      <div>
        <LevelRow visual={<GrindDots level={0}/>} name="Coarse" keywords="Slow extraction" note="French press, cold brew. Too coarse and the cup turns weak, sour, watery." />
        <LevelRow visual={<GrindDots level={1}/>} name="Medium" keywords="The middle" note="Pour-over and drip. The forgiving default to start from." />
        <LevelRow visual={<GrindDots level={2}/>} name="Fine" keywords="Fast extraction" note="Espresso, moka pot. Too fine and the cup turns bitter and harsh." />
      </div>
    ),
  },
  extraction: {
    id: 'extraction', label: 'EXTRACTION',
    title: 'Extraction',
    summary: 'Under to over — the one idea behind sour vs bitter.',
    fact: 'Sour usually means too little extraction; bitter usually means too much.',
    body: () => (
      <SpectrumBar
        colors={['color-mix(in oklab, var(--berry) 55%, var(--surface))', 'color-mix(in oklab, var(--sage) 65%, var(--surface))', 'var(--art-roast-dark)']}
        marker={0.5}
        stops={[
          { label: 'Under', cue: 'Sour, thin, sharp' },
          { label: 'Balanced', cue: 'Sweet, rounded, pleasant' },
          { label: 'Over', cue: 'Bitter, dry, harsh' },
        ]}/>
    ),
  },
  ratio: {
    id: 'ratio', label: 'RATIO',
    title: 'Coffee-to-Water Ratio',
    summary: 'How much coffee vs water sets the strength of your cup.',
    fact: 'Most brews land near 1:16 — one gram of coffee to sixteen of water.',
    body: () => (
      <div>
        <SpectrumBar
          colors={['#C9A97E', 'var(--art-roast-mid)', 'var(--art-roast-dark)']}
          marker={0.5}
          stops={[
            { label: 'Weak', cue: 'More water' },
            { label: 'Balanced', cue: '≈ 1:16' },
            { label: 'Strong', cue: 'More coffee' },
          ]}/>
        <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: '16px 0 0', textWrap: 'pretty' }}>
          More water makes it weaker; more coffee makes it stronger. Ratio changes <strong style={{ color: 'var(--ink)' }}>strength</strong> first — not whether the cup tastes good.
        </p>
      </div>
    ),
  },
  anatomy: {
    id: 'anatomy', label: 'CHERRY ANATOMY',
    title: 'The Cherry in Section',
    summary: 'Six layers between the skin of the fruit and the seed you brew.',
    fact: 'Layer 03 \u2014 the sticky mucilage \u2014 is the one washed, honey and natural argue over.',
    body: () => (window.CherrySection ? <window.CherrySection/> : null),
  },
  variety: {
    id: 'variety', label: 'VARIETY',
    title: 'The Variety Family Tree',
    summary: 'Typica and Bourbon — the two old parents behind most cups you\u2019ll meet.',
    fact: 'Geisha, Caturra and SL28 are all arabica — variety is why they taste nothing alike.',
    body: () => (
      <div>
        <svg viewBox="0 0 300 132" style={{ width: '100%', display: 'block' }}>
          <text x="150" y="14" textAnchor="middle" fontFamily="IBM Plex Mono" fontSize="9" letterSpacing="2" fill="var(--ink-mute)">ARABICA</text>
          <path d="M150 20 L150 30 M150 30 L80 30 L80 44 M150 30 L220 30 L220 44" fill="none" stroke="var(--rule)" strokeWidth="1.2"/>
          <rect x="50" y="44" width="60" height="22" rx="11" fill="none" stroke="var(--sage)" strokeWidth="1.2"/>
          <text x="80" y="58.5" textAnchor="middle" fontSize="11" fill="var(--ink)">Typica</text>
          <rect x="190" y="44" width="60" height="22" rx="11" fill="none" stroke="var(--sage)" strokeWidth="1.2"/>
          <text x="220" y="58.5" textAnchor="middle" fontSize="11" fill="var(--ink)">Bourbon</text>
          <path d="M80 66 L80 96 M220 66 L220 80 M220 80 L185 80 L185 96 M220 80 L255 80 L255 96" fill="none" stroke="var(--rule)" strokeWidth="1.2"/>
          <rect x="50" y="96" width="60" height="22" rx="11" fill="var(--surface-2)" stroke="var(--rule)" strokeWidth="1.1"/>
          <text x="80" y="110.5" textAnchor="middle" fontSize="11" fill="var(--ink)">Geisha</text>
          <rect x="152" y="96" width="66" height="22" rx="11" fill="var(--surface-2)" stroke="var(--rule)" strokeWidth="1.1"/>
          <text x="185" y="110.5" textAnchor="middle" fontSize="11" fill="var(--ink)">Caturra</text>
          <rect x="228" y="96" width="54" height="22" rx="11" fill="var(--surface-2)" stroke="var(--rule)" strokeWidth="1.1"/>
          <text x="255" y="110.5" textAnchor="middle" fontSize="11" fill="var(--ink)">SL28</text>
        </svg>
        <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: '14px 0 0', textWrap: 'pretty' }}>
          Nearly every arabica on a shelf descends from <strong style={{ color: 'var(--ink)' }}>Typica</strong> or <strong style={{ color: 'var(--ink)' }}>Bourbon</strong>. Variety is why two coffees from the same farm can taste nothing alike.
        </p>
      </div>
    ),
  },
  caffeine: {
    id: 'caffeine', label: 'CAFFEINE',
    title: 'Caffeine, Per Serving',
    summary: 'What each brew actually delivers — the serving matters as much as the method.',
    fact: 'A single espresso carries less caffeine than a mug of drip.',
    body: () => {
      const rows = [
        { name: 'Decaf', serve: '240 ml cup', mg: 3 },
        { name: 'Espresso', serve: '30 ml shot', mg: 63 },
        { name: 'Drip coffee', serve: '240 ml cup', mg: 95 },
        { name: 'Cold brew', serve: '450 ml glass', mg: 200 },
      ];
      return (
        <div>
          {rows.map((r, i) => (
            <div key={i} style={{ padding: '11px 0', borderBottom: i < rows.length - 1 ? '1px solid var(--rule)' : 'none' }}>
              <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: 10 }}>
                <span style={{ fontSize: 'var(--t-body)', fontWeight: 500, color: 'var(--ink)' }}>{r.name}</span>
                <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.08em', color: 'var(--sage)', whiteSpace: 'nowrap' }}>~{r.mg} mg</span>
              </div>
              <div style={{ position: 'relative', height: 8, borderRadius: 999, background: 'var(--surface-2)', border: '1px solid var(--rule)', overflow: 'hidden', marginTop: 7 }}>
                <div style={{ position: 'absolute', inset: 0, width: `${Math.max(3, r.mg / 200 * 100)}%`, background: 'var(--accent)', borderRadius: 999 }}></div>
              </div>
              <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.08em', textTransform: 'uppercase', color: 'var(--ink-mute)', marginTop: 5 }}>{r.serve}</div>
            </div>
          ))}
          <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: '14px 0 0', textWrap: 'pretty' }}>
            Serving size moves the number as much as the brew does — cold brew is strong <em>and</em> big.
          </p>
        </div>
      );
    },
  },
  distribution: {
    id: 'distribution', label: 'GRIND SPREAD',
    title: 'Particle Distribution',
    summary: 'Why a burr\u2019s tight spread beats a blade\u2019s fines-and-boulders.',
    fact: 'A blade chops unevenly — fines over-extract while boulders under-extract in the same brew.',
    body: () => (
      <div>
        <svg viewBox="0 0 300 118" style={{ width: '100%', display: 'block' }}>
          <line x1="16" y1="96" x2="284" y2="96" stroke="var(--rule)" strokeWidth="1"/>
          <path d="M24 95 Q58 34 92 82 Q112 96 138 68 Q175 24 235 86 Q262 96 280 95 L280 96 L24 96 Z" fill="var(--berry)" fillOpacity="0.1"/>
          <path d="M24 95 Q58 34 92 82 Q112 96 138 68 Q175 24 235 86 Q262 96 280 95" fill="none" stroke="var(--berry)" strokeWidth="1.8" strokeLinecap="round"/>
          <path d="M104 96 Q132 90 142 56 Q152 14 162 56 Q172 90 200 96 Z" fill="var(--sage)" fillOpacity="0.16"/>
          <path d="M104 96 Q132 90 142 56 Q152 14 162 56 Q172 90 200 96" fill="none" stroke="var(--sage)" strokeWidth="2" strokeLinecap="round"/>
          <text x="16" y="112" fontFamily="IBM Plex Mono" fontSize="9" letterSpacing="1.5" fill="var(--ink-mute)">FINE</text>
          <text x="284" y="112" textAnchor="end" fontFamily="IBM Plex Mono" fontSize="9" letterSpacing="1.5" fill="var(--ink-mute)">COARSE</text>
        </svg>
        <div style={{ display: 'flex', gap: 18, marginTop: 12 }}>
          {[['var(--berry)', 'Blade — wide, uneven'], ['var(--sage)', 'Burr — tight, even']].map(([c, l], i) => (
            <span key={i} style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
              <span style={{ width: 16, height: 3, borderRadius: 2, background: c, flexShrink: 0 }}></span>
              <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.08em', textTransform: 'uppercase', color: 'var(--ink-mute)' }}>{l}</span>
            </span>
          ))}
        </div>
        <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: '14px 0 0', textWrap: 'pretty' }}>
          One dose of blade-ground coffee brews as two coffees at once — sour boulders and bitter dust in the same cup.
        </p>
      </div>
    ),
  },
};
window.TRAINING = TRAINING;
window.trainingByVariant = (v) => TRAINING[v] || null;

// The full training card — used inside lessons + the card-detail sheet.
function TrainingCard({ variant, inSheet = false, hideHeader = false }) {
  const t = TRAINING[variant];
  if (!t) return null;
  return (
    <div style={{
      width: '100%', background: 'var(--surface)', border: '1px solid var(--rule)',
      borderRadius: 16, padding: hideHeader ? '20px' : '20px 20px 22px',
    }}>
      {!hideHeader && (
        <div className="smallcaps" style={{ display: 'flex', alignItems: 'center', gap: 8, color: 'var(--accent)', marginBottom: 10 }}>
          <TuneMark size={14} color="var(--accent)"/> VISUAL GUIDE · {t.label}
        </div>
      )}
      {!hideHeader && (
        <h3 className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.01em', margin: 0, color: 'var(--ink)' }}>{t.title}</h3>
      )}
      <div style={{ marginTop: hideHeader ? 0 : 18 }}>{t.body()}</div>
    </div>
  );
}
window.TrainingCard = TrainingCard;

// Lesson wrapper: a training card as a full lesson step, with a Continue.
function VisualLessonCard({ card, onContinue, saved, onToggleSave }) {
  const t = TRAINING[card.variant];
  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', flex: '1 0 auto', minHeight: 600 }}>
      <div className="smallcaps" style={{ marginBottom: 14 }}>{card.label || 'VISUAL GUIDE'}</div>
      {card.title && (
        <h2 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.12, letterSpacing: '-0.01em', margin: '0 0 20px', color: 'var(--ink)', textWrap: 'pretty' }}>{card.title}</h2>
      )}
      {card.captionTop && card.caption && (
        <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink)', margin: '-6px 0 18px', textWrap: 'pretty' }}>{card.caption}</p>
      )}
      <TrainingCard variant={card.variant} hideHeader={!!card.mergeHeader}/>
      {onToggleSave && (
        <button type="button" onClick={onToggleSave} aria-pressed={!!saved} style={{
          appearance: 'none', cursor: 'pointer', background: 'transparent', border: 'none',
          alignSelf: 'flex-start', display: 'flex', alignItems: 'center', gap: 8,
          padding: '10px 0 0', color: saved ? 'var(--accent)' : 'var(--ink-mute)',
        }}>
          {window.Bookmark && <window.Bookmark filled={!!saved} size={16} color={saved ? 'var(--accent)' : 'var(--ink-mute)'}/>}
          <span className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.14em', textTransform: 'uppercase' }}>
            {saved ? 'Saved — review anytime in Saved' : 'Save this guide'}
          </span>
        </button>
      )}
      {card.caption && !card.captionTop && (
        <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.55, color: 'var(--ink-mute)', margin: '18px 0 0', textWrap: 'pretty' }}>{card.caption}</p>
      )}
      <div style={{ flex: 1 }}/>
      <div style={{ paddingTop: 32 }}>
        <button className="btn btn-primary" onClick={onContinue}>Continue</button>
      </div>
    </div>
  );
}
window.VisualLessonCard = VisualLessonCard;

// Compact thumbnail for the collection grid — mirrors the CARD_ART style.
function TrainingThumb({ variant }) {
  if (variant === 'roast') {
    return (
      <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
        <circle cx="30" cy="52" r="12" fill={ROAST_BEANS[0]}/>
        <circle cx="50" cy="52" r="12" fill={ROAST_BEANS[1]}/>
        <circle cx="70" cy="52" r="12" fill={ROAST_BEANS[2]}/>
      </svg>
    );
  }
  if (variant === 'grind') {
    return (
      <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
        <circle cx="26" cy="52" r="5.5" fill="var(--ink-mute)"/>
        {[[46,46],[54,46],[46,54],[54,54]].map(([x,y],i)=><circle key={i} cx={x} cy={y} r="3" fill="var(--ink-mute)"/>)}
        {Array.from({length:9}).map((_,i)=><circle key={i} cx={68+(i%3)*7} cy={45+Math.floor(i/3)*7} r="1.6" fill="var(--ink-mute)"/>)}
      </svg>
    );
  }
  if (variant === 'extraction') {
    return (
      <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
        <rect x="16" y="46" width="22.6" height="10" rx="2" fill="color-mix(in oklab, var(--berry) 55%, var(--surface))"/>
        <rect x="38.6" y="46" width="22.8" height="10" fill="color-mix(in oklab, var(--sage) 65%, var(--surface))"/>
        <rect x="61.4" y="46" width="22.6" height="10" rx="2" fill="var(--art-roast-dark)"/>
        <circle cx="50" cy="51" r="6" fill="var(--bg)" stroke="var(--ink)" strokeWidth="2"/>
      </svg>
    );
  }
  if (variant === 'variety') {
    return (
      <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
        <path d="M50 40 L50 52 M50 52 L30 52 L30 62 M50 52 L70 52 L70 62 M50 52 L50 62" fill="none" stroke="var(--ink-mute)" strokeWidth="1.4"/>
        <circle cx="50" cy="36" r="4.5" fill="var(--sage)"/>
        <circle cx="30" cy="66" r="3.5" fill="var(--ink-mute)"/>
        <circle cx="50" cy="66" r="3.5" fill="var(--ink-mute)"/>
        <circle cx="70" cy="66" r="3.5" fill="var(--ink-mute)"/>
      </svg>
    );
  }
  if (variant === 'caffeine') {
    return (
      <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
        <rect x="20" y="66" width="11" height="4" rx="1.5" fill="var(--accent)"/>
        <rect x="36" y="52" width="11" height="18" rx="1.5" fill="var(--accent)"/>
        <rect x="52" y="44" width="11" height="26" rx="1.5" fill="var(--accent)"/>
        <rect x="68" y="28" width="11" height="42" rx="1.5" fill="var(--accent)"/>
      </svg>
    );
  }
  if (variant === 'anatomy') {
    const rings = [
      ['var(--art-cherry-skin)', 34], ['var(--art-cherry-pulp)', 31], ['var(--art-cherry-gel)', 25],
      ['var(--art-cherry-parchment)', 22], ['var(--art-cherry-silverskin)', 19], ['var(--art-cherry-seed)', 17],
    ];
    return (
      <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
        {rings.map(([c, r], i) => (
          <circle key={i} cx="50" cy="50" r={r} fill={c} stroke="rgba(27,22,20,0.22)" strokeWidth="0.6"/>
        ))}
        <line x1="50" y1="34" x2="50" y2="66" stroke="var(--art-seed-crease)" strokeWidth="1.4"/>
      </svg>
    );
  }
  if (variant === 'distribution') {
    return (
      <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
        <line x1="14" y1="68" x2="86" y2="68" stroke="var(--rule)" strokeWidth="1.2"/>
        <path d="M18 67 Q30 44 40 62 Q48 68 56 56 Q68 40 82 66" fill="none" stroke="var(--berry)" strokeWidth="2" strokeLinecap="round"/>
        <path d="M38 68 Q47 65 50 44 Q53 65 62 68" fill="none" stroke="var(--sage)" strokeWidth="2.2" strokeLinecap="round"/>
      </svg>
    );
  }
  // ratio
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      <rect x="16" y="46" width="22.6" height="10" rx="2" fill="#C9A97E"/>
      <rect x="38.6" y="46" width="22.8" height="10" fill="var(--art-roast-mid)"/>
      <rect x="61.4" y="46" width="22.6" height="10" rx="2" fill="#4A2A1A"/>
      <text x="50" y="76" textAnchor="middle" className="ff-mono" fontSize="11" fill="var(--ink-mute)" letterSpacing="1">1:16</text>
    </svg>
  );
}
window.TrainingThumb = TrainingThumb;

// Hands-on step card — a real-world instruction inside a lesson (the "do it
// at the counter" layer). card = { kind:'practical', tag, title, paragraphs:[], note }
function PracticalCard({ card, onContinue }) {
  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', flex: '1 0 auto', minHeight: 600 }}>
      <div className="smallcaps" style={{ display: 'flex', alignItems: 'center', gap: 8, color: 'var(--accent)', marginBottom: 14 }}>
        <TuneMark size={14} color="var(--accent)"/> {card.tag || 'HANDS ON'}
      </div>
      <h2 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.12, letterSpacing: '-0.01em', margin: '0 0 18px', color: 'var(--ink)', textWrap: 'pretty' }}>{card.title}</h2>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
        {(card.paragraphs || []).map((p, i) => (
          <p key={i} style={{ fontSize: 'var(--t-body)', lineHeight: 1.6, color: 'var(--ink)', margin: 0, textWrap: 'pretty' }}>{p}</p>
        ))}
      </div>
      {card.note && (
        <div style={{ marginTop: 22, paddingTop: 16, borderTop: '1px solid var(--rule)' }}>
          <div className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.14em', textTransform: 'uppercase', color: 'var(--sage)', marginBottom: 8 }}>WORTH KNOWING</div>
          <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.55, color: 'var(--ink-mute)', margin: 0, textWrap: 'pretty' }}>{card.note}</p>
        </div>
      )}
      <div style={{ flex: 1 }}></div>
      <div style={{ paddingTop: 32 }}>
        <button className="btn btn-primary" onClick={onContinue}>Continue</button>
      </div>
    </div>
  );
}
window.PracticalCard = PracticalCard;
