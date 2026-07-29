// customize.jsx — Premium customization (behind the "BrewPath Plus" paywall):
//   • PaywallScreen     — the gate. Teaser + plan + free-trial CTA.
//   • StudioHub         — landing with three doors once unlocked.
//   • TreeChooserScreen — pick which plant grows in your grove (5 skins).
//   • RoastyStudio      — dress Roasty up: roast, hat, gear, sprout.
//   • RoastyMoodScreen  — Roasty centered; tap an emotion to see them react.
//
// Customization is held in App state, mirrored to window.ROASTY_CONFIG /
// window.TREE_CONFIG so every <Roasty/> and <CoffeePersona/> in the app
// reflects the applied look, and persisted to localStorage.

const { useState: useStateC, useEffect: useEffectC } = React;

// ── Tree skins. Heirloom is the real art; the rest are seasonal treatments
//    layered on the same 10-stage illustrations via CSS filters. (Real ship
//    would want bespoke art per stage — these read as intentional skins.) ──
window.TREE_SKINS = [
  { id: 'heirloom',   name: 'Heirloom',    note: 'The classic coffee plant',  filter: 'none',                                                            free: true },
  { id: 'goldenhour', name: 'Golden Hour', note: 'Warm amber canopy',         filter: 'sepia(0.45) saturate(1.5) hue-rotate(-12deg) brightness(1.05)'    },
  { id: 'moonlit',    name: 'Moonlit',     note: 'Cool silver-blue leaves',   filter: 'saturate(0.6) hue-rotate(150deg) brightness(0.96) contrast(1.06)' },
  { id: 'blossom',    name: 'Blossom',     note: 'Soft pink spring bloom',    filter: 'hue-rotate(-42deg) saturate(1.3) brightness(1.08)'                },
  { id: 'verdant',    name: 'Verdant',     note: 'Deep evergreen, year-round',filter: 'saturate(1.5) hue-rotate(22deg) brightness(0.92)'                 },
];
window.skinFilter = (id) => {
  const s = (window.TREE_SKINS || []).find(x => x.id === id);
  return s && s.filter !== 'none' ? s.filter : '';
};

// ── Roasty option tables (labels live here; the art lives in roasty.jsx) ──
window.ROAST_OPTS  = [
  { id: 'light',    label: 'Light',    swatch: '#A87B4F' },
  { id: 'medium',   label: 'Medium',   swatch: '#6B3E22' },
  { id: 'dark',     label: 'Dark',     swatch: '#4A2C19' },
  { id: 'espresso', label: 'Espresso', swatch: '#2F1B10' },
];
window.HAT_OPTS    = [
  { id: 'none',   label: 'None' },
  { id: 'beanie', label: 'Beanie' },
  { id: 'field',  label: 'Field hat' },
  { id: 'cap',    label: 'Cap' },
];
window.GEAR_OPTS   = [
  { id: 'none',       label: 'None' },
  { id: 'glasses',    label: 'Glasses' },
  { id: 'sunglasses', label: 'Shades' },
  { id: 'scarf',      label: 'Scarf' },
  { id: 'headphones', label: 'Headphones' },
];
window.SPROUT_OPTS = [
  { id: 'leaf',   label: 'Leaves' },
  { id: 'flower', label: 'Blossom' },
  { id: 'sprig',  label: 'Cherry' },
  { id: 'none',   label: 'Bare' },
];
window.BACKDROPS = [
  { id: 'studio', label: 'Studio', bg: 'var(--surface)' },
  { id: 'cream',  label: 'Cream',  bg: '#ECE0CB' },
  { id: 'sage',   label: 'Sage',   bg: '#626C5A' },
  { id: 'berry',  label: 'Berry',  bg: '#7A2E26' },
  { id: 'night',  label: 'Night',  bg: '#181109' },
];
const DEFAULT_ROASTY = { roast: 'medium', hat: 'none', gear: 'none', sprout: 'leaf' };

// ── Shared chrome ──────────────────────────────────────────
function StudioTopbar({ onBack, kind = 'close' }) {
  return (
    <div className="lesson-topbar" style={{ borderBottom: 'none', background: 'transparent' }}>
      <button className="close-btn" onClick={onBack} aria-label="Back">
        {kind === 'close'
          ? <window.CloseMark/>
          : <window.BackMark/>}
      </button>
      <div/><div/>
    </div>
  );
}

function PlusBadge({ style }) {
  return (
    <span className="ff-mono" style={{
      fontSize: 'var(--t-micro)', letterSpacing: '0.16em', textTransform: 'uppercase',
      color: 'var(--accent)', border: '1px solid color-mix(in oklab, var(--accent) 45%, var(--rule))',
      borderRadius: 999, padding: '3px 9px', ...style,
    }}>PLUS</span>
  );
}

// A small lock chip used on teaser tiles.
function LockChip() {
  return (
    <span style={{
      position: 'absolute', top: 8, right: 8, width: 22, height: 22, borderRadius: 999,
      background: 'color-mix(in oklab, var(--bg) 70%, transparent)', display: 'grid', placeItems: 'center',
    }}>
      <svg width="11" height="11" viewBox="0 0 20 20" style={{ color: 'var(--accent)' }}>
        <rect x="4.5" y="8.5" width="11" height="8" rx="1.6" fill="none" stroke="currentColor" strokeWidth="1.7"/>
        <path d="M7 8.5 V6.5 a3 3 0 0 1 6 0 V8.5" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round"/>
      </svg>
    </span>
  );
}

// ───────────────────────────────────────────────────────────
// PAYWALL
// ───────────────────────────────────────────────────────────
function PaywallScreen({ onSubscribe, onClose, showMoodPlayer = true }) {
  const [plan, setPlan] = useStateC('yearly');

  const benefits = [
    ['Unlimited Saved', 'Keep every lesson, term and guide — past the free shelf of 10'],
    ['Dress up Roasty', 'Hats, glasses, scarves, roast level and more'],
    ['Choose your plant', 'Five botanical skins for your growing grove'],
    showMoodPlayer
      ? ['Mood player', "Tap through Roasty's reactions any time"]
      : null,
  ].filter(Boolean);

  return (
    <div className="screen" data-screen-label="Paywall · Plus" style={{ background: 'var(--bg)' }}>
      <div aria-hidden="true" style={{
        position: 'absolute', inset: 0, pointerEvents: 'none',
        background: 'radial-gradient(ellipse at 50% 16%, color-mix(in oklab, var(--accent) 16%, transparent) 0%, transparent 58%)',
      }}/>
      <StudioTopbar onBack={onClose}/>

      <div className="scroll" style={{ paddingTop: 70, paddingBottom: 24, display: 'flex', flexDirection: 'column' }}>
        {/* Hero — a dressed-up Roasty */}
        <div style={{ display: 'flex', justifyContent: 'center', paddingTop: 4 }}>
          <Roasty state="correct" size={150} roast="dark" hat="field" gear="glasses" sprout="flower"/>
        </div>

        <div className="px-24" style={{ textAlign: 'center', paddingTop: 4 }}>
          <div className="smallcaps" style={{ color: 'var(--accent)' }}>BREWPATH PLUS</div>
          <h1 className="ff-display" style={{
            fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em',
            margin: '8px 0 0', color: 'var(--ink)', textWrap: 'pretty',
          }}>Keep everything you learn. Make Roasty yours.</h1>
        </div>

        {/* Benefits */}
        <div className="px-24" style={{ paddingTop: 26 }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
            {benefits.map(([t, d], i) => (
              <div key={i} style={{ display: 'grid', gridTemplateColumns: '24px 1fr', gap: 14, alignItems: 'start', padding: '13px 0', borderBottom: i < benefits.length - 1 ? '1px solid var(--rule)' : 'none' }}>
                <span style={{ width: 24, height: 24, borderRadius: 999, background: 'color-mix(in oklab, var(--accent) 14%, var(--surface))', display: 'grid', placeItems: 'center', marginTop: 1 }}>
                  <svg width="12" height="12" viewBox="0 0 12 12"><path d="M2 6.2l2.6 2.6L10 3" fill="none" stroke="var(--accent)" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"/></svg>
                </span>
                <div>
                  <div style={{ fontSize: 'var(--t-body)', fontWeight: 500, color: 'var(--ink)' }}>{t}</div>
                  <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 2, lineHeight: 1.4 }}>{d}</div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Plan picker */}
        <div className="px-24" style={{ paddingTop: 22, display: 'flex', flexDirection: 'column', gap: 10 }}>
          {[
            { id: 'yearly',  title: 'Yearly',  price: '$29.99 / yr', note: '$2.50 / mo · best value', tag: 'SAVE 50%' },
            { id: 'monthly', title: 'Monthly', price: '$4.99 / mo',  note: 'Billed monthly', tag: null },
          ].map(p => {
            const sel = plan === p.id;
            return (
              <button key={p.id} onClick={() => setPlan(p.id)}
                style={{
                  appearance: 'none', cursor: 'pointer', textAlign: 'left', width: '100%',
                  display: 'grid', gridTemplateColumns: '24px 1fr auto', alignItems: 'center', gap: 14,
                  padding: '16px 18px', borderRadius: 4, background: 'var(--surface)',
                  border: '1px solid ' + (sel ? 'var(--accent)' : 'var(--rule)'),
                  boxShadow: sel ? 'inset 0 0 0 1px var(--accent)' : 'none',
                }}>
                <span style={{ width: 20, height: 20, borderRadius: 999, border: '1.5px solid ' + (sel ? 'var(--accent)' : 'var(--rule)'), display: 'grid', placeItems: 'center' }}>
                  {sel && <span style={{ width: 10, height: 10, borderRadius: 999, background: 'var(--accent)' }}/>}
                </span>
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                    <span style={{ fontSize: 'var(--t-body)', fontWeight: 500, color: 'var(--ink)' }}>{p.title}</span>
                    {p.tag && <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.12em', color: 'var(--accent-ink)', background: 'var(--accent)', borderRadius: 999, padding: '2px 7px' }}>{p.tag}</span>}
                  </div>
                  <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 2 }}>{p.note}</div>
                </div>
                <span className="ff-mono" style={{ fontSize: 'var(--t-support)', color: 'var(--ink)', whiteSpace: 'nowrap' }}>{p.price}</span>
              </button>
            );
          })}
        </div>

        <div style={{ flex: 1, minHeight: 18 }}/>

        <div className="px-24" style={{ paddingTop: 18 }}>
          <button className="btn btn-primary" onClick={() => onSubscribe(plan)}>Start 7-day free trial</button>
          <div style={{ marginTop: 10 }}>
            <a className="btn btn-ghost" href="#" style={{ display: 'block', textAlign: 'center', textDecoration: 'none' }} onClick={(e) => { e.preventDefault(); onClose(); }}>Maybe later</a>
          </div>
          <p className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.08em', color: 'var(--ink-mute)', textAlign: 'center', margin: '14px 0 0', textTransform: 'uppercase' }}>
            Free for 7 days, then {plan === 'yearly' ? '$29.99/yr' : '$4.99/mo'} · cancel anytime
          </p>
          {/* Store review requires restore + legal on the purchase screen itself. */}
          <div style={{ display: 'flex', justifyContent: 'center', gap: 18, marginTop: 12 }}>
            {['Restore purchases', 'Terms', 'Privacy'].map(l => (
              <a key={l} href="#" onClick={(e) => e.preventDefault()} className="ff-mono"
                 style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.08em', textTransform: 'uppercase', color: 'var(--ink-mute)', textDecoration: 'none' }}>{l}</a>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

// ───────────────────────────────────────────────────────────
// STUDIO HUB
// ───────────────────────────────────────────────────────────
// A single Studio door. Defined at module scope (NOT inside StudioHub) so its
// component identity is stable across App's 1s countdown re-renders — otherwise
// the tree/Roasty art would remount and replay its fade every second (blinking).
function StudioDoor({ onClick, eyebrow, title, sub, art }) {
  return (
    <button onClick={onClick} style={{
      appearance: 'none', cursor: 'pointer', textAlign: 'left', width: '100%',
      display: 'grid', gridTemplateColumns: '76px 1fr auto', alignItems: 'center', gap: 16,
      padding: 16, borderRadius: 16, background: 'var(--surface)', border: '1px solid var(--rule)',
    }}>
      <div style={{ width: 76, height: 76, borderRadius: 12, background: 'var(--bg)', border: '1px solid var(--rule)', overflow: 'hidden', display: 'grid', placeItems: 'center' }}>
        {art}
      </div>
      <div>
        <div className="smallcaps" style={{ color: 'var(--accent)', marginBottom: 4 }}>{eyebrow}</div>
        <div className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, letterSpacing: '-0.01em', color: 'var(--ink)', lineHeight: 1.05 }}>{title}</div>
        <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 3 }}>{sub}</div>
      </div>
      <window.Chevron/>
    </button>
  );
}

function StudioHub({ roastyCfg, treeId, showMoodPlayer = true, chrome = true, onChooseTree, onDressRoasty, onMoodPlayer, onClose }) {
  const skinName = ((window.TREE_SKINS || []).find(s => s.id === treeId) || {}).name || 'Heirloom';
  const SubHeader = window.SubScreenHeader;
  const [scrolled, onScroll] = window.useScrollFlag();
  return (
    <div className="screen" data-screen-label="Studio" style={{ background: 'var(--bg)' }}>
      {chrome && SubHeader && <SubHeader scrolled={scrolled} title="Studio" onBack={onClose}/>}
      <div className="scroll" onScroll={onScroll} style={{ paddingTop: 108, paddingBottom: 28 }}>
        <div className="px-24">
          <div className="smallcaps" style={{ color: 'var(--accent)' }}>BREWPATH PLUS</div>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em', margin: '8px 0 0', color: 'var(--ink)' }}>Make it yours.</h1>
        </div>

        <div className="px-24" style={{ paddingTop: 24, display: 'flex', flexDirection: 'column', gap: 12 }}>
          <StudioDoor onClick={onChooseTree} eyebrow="GROVE" title="Choose your plant" sub={skinName}
            art={<div style={{ width: 64, height: 64 }}><CoffeePersona stage={9} size={64} animate={false} withGround={false} treatment={window.skinFilter(treeId)}/></div>}/>
          <StudioDoor onClick={onDressRoasty} eyebrow="COMPANION" title="Dress up Roasty" sub="Hat, gear, roast and sprout"
            art={<Roasty state="idle" size={62} roast={roastyCfg.roast} hat={roastyCfg.hat} gear={roastyCfg.gear} sprout={roastyCfg.sprout}/>}/>
          {showMoodPlayer && (
          <StudioDoor onClick={onMoodPlayer} eyebrow="PLAY" title="Mood player" sub="See Roasty react"
            art={<Roasty state="correct" size={62} roast={roastyCfg.roast} hat={roastyCfg.hat} gear={roastyCfg.gear} sprout={roastyCfg.sprout}/>}/>
          )}
        </div>
      </div>
    </div>
  );
}

// ───────────────────────────────────────────────────────────
// TREE CHOOSER
// ───────────────────────────────────────────────────────────
function TreeChooserScreen({ treeId, onApply, onClose }) {
  const skins = window.TREE_SKINS || [];
  const [sel, setSel] = useStateC(treeId || 'heirloom');
  const dirty = sel !== treeId;
  const SubHeader = window.SubScreenHeader;
  const [scrolled, onScroll] = window.useScrollFlag();

  return (
    <div className="screen" data-screen-label="Tree chooser" style={{ background: 'var(--bg)' }}>
      {SubHeader && <SubHeader scrolled={scrolled} title="Choose your plant" onBack={onClose}/>}
      <div className="scroll" onScroll={onScroll} style={{ paddingTop: 108, paddingBottom: 28, display: 'flex', flexDirection: 'column' }}>
        <div className="px-24">
          <div className="smallcaps" style={{ color: 'var(--accent)' }}>YOUR GROVE</div>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.08, letterSpacing: '-0.01em', margin: '8px 0 0', color: 'var(--ink)' }}>Choose your plant</h1>
          <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: '10px 0 0', maxWidth: 320 }}>
            Every plant still grows through all ten stages, seed to harvest — only the look changes.
          </p>
        </div>

        <div className="px-24" style={{ paddingTop: 22 }}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            {skins.map(skin => {
              const isSel = sel === skin.id;
              return (
                <button key={skin.id} onClick={() => setSel(skin.id)}
                  style={{
                    appearance: 'none', cursor: 'pointer', textAlign: 'left', padding: 12,
                    background: 'var(--surface)', borderRadius: 4,
                    border: '1px solid ' + (isSel ? 'var(--accent)' : 'var(--rule)'),
                    boxShadow: isSel ? 'inset 0 0 0 1px var(--accent)' : 'none',
                    position: 'relative',
                  }}>
                  {isSel && (
                    <span style={{ position: 'absolute', top: 10, right: 10, width: 22, height: 22, borderRadius: 999, background: 'var(--accent)', display: 'grid', placeItems: 'center', zIndex: 2 }}>
                      <svg width="12" height="12" viewBox="0 0 12 12"><path d="M2 6.2l2.6 2.6L10 3" fill="none" stroke="var(--accent-ink)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
                    </span>
                  )}
                  <div style={{ height: 120, display: 'grid', placeItems: 'center' }}>
                    <CoffeePersona stage={9} size={120} animate={false} withGround={false} treatment={skin.filter === 'none' ? '' : skin.filter}/>
                  </div>
                  <div className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, letterSpacing: '-0.01em', color: 'var(--ink)', marginTop: 6 }}>{skin.name}</div>
                  <div className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.08em', textTransform: 'uppercase', color: 'var(--ink-mute)', marginTop: 3 }}>{skin.note}</div>
                </button>
              );
            })}
          </div>
        </div>

        <div style={{ flex: 1, minHeight: 18 }}/>
        <div className="px-24" style={{ paddingTop: 20 }}>
          <button className="btn btn-primary" disabled={!dirty} onClick={() => onApply(sel)}>
            {dirty ? 'Plant in my grove' : 'Already planted'}
          </button>
        </div>
      </div>
    </div>
  );
}

// ───────────────────────────────────────────────────────────
// ROASTY STUDIO
// ───────────────────────────────────────────────────────────
function OptionRow({ label, opts, value, onChange, swatches }) {
  return (
    <div style={{ paddingTop: 18 }}>
      <div className="smallcaps" style={{ marginBottom: 10 }}>{label}</div>
      <div style={{ display: 'flex', gap: 8, overflowX: 'auto', paddingBottom: 4, scrollbarWidth: 'none' }}>
        {opts.map(o => {
          const sel = value === o.id;
          return (
            <button key={o.id} onClick={() => onChange(o.id)}
              style={{
                appearance: 'none', cursor: 'pointer', flexShrink: 0,
                display: 'flex', alignItems: 'center', gap: 7,
                padding: swatches ? '8px 12px 8px 9px' : '9px 15px', borderRadius: 999,
                background: sel ? 'color-mix(in oklab, var(--accent) 12%, var(--surface))' : 'var(--surface)',
                border: '1px solid ' + (sel ? 'var(--accent)' : 'var(--rule)'),
                color: sel ? 'var(--accent)' : 'var(--ink)',
                fontFamily: 'IBM Plex Sans, sans-serif', fontSize: 'var(--t-support)', fontWeight: 500,
                whiteSpace: 'nowrap',
              }}>
              {swatches && <span style={{ width: 16, height: 16, borderRadius: 999, background: o.swatch, border: '1px solid color-mix(in oklab, var(--ink) 18%, transparent)' }}/>}
              {o.label}
            </button>
          );
        })}
      </div>
    </div>
  );
}

function RoastyStudio({ roastyCfg, onApply, onClose, onMoodPlayer, showMoodPlayer = true }) {
  const [cfg, setCfg] = useStateC({ ...DEFAULT_ROASTY, ...roastyCfg });
  const set = (k, v) => setCfg(c => ({ ...c, [k]: v }));
  const dirty = JSON.stringify(cfg) !== JSON.stringify({ ...DEFAULT_ROASTY, ...roastyCfg });
  const randomize = () => {
    const pick = arr => arr[Math.floor(Math.random() * arr.length)].id;
    setCfg({ roast: pick(window.ROAST_OPTS), hat: pick(window.HAT_OPTS), gear: pick(window.GEAR_OPTS), sprout: pick(window.SPROUT_OPTS) });
  };

  return (
    <div className="screen" data-screen-label="Roasty studio" style={{ background: 'var(--bg)' }}>
      {window.SubScreenHeader
        ? <window.SubScreenHeader scrolled={false} title="Dress up Roasty" onBack={onClose}/>
        : <StudioTopbar onBack={onClose} kind="back"/>}

      {/* Live preview — pinned feel via a tinted panel */}
      <div style={{ position: 'absolute', top: 54, left: 0, right: 0, zIndex: 5,
        background: 'linear-gradient(180deg, color-mix(in oklab, var(--accent) 10%, var(--bg)) 0%, var(--bg) 100%)',
        paddingTop: 32, paddingBottom: 14 }}>
        <div style={{ display: 'flex', justifyContent: 'center' }}>
          <Roasty state="idle" size={128} roast={cfg.roast} hat={cfg.hat} gear={cfg.gear} sprout={cfg.sprout}/>
        </div>
        <div style={{ display: 'flex', justifyContent: 'center', gap: 8, marginTop: 6 }}>
          <button onClick={randomize} className="ff-mono" style={{
            appearance: 'none', cursor: 'pointer', background: 'transparent', whiteSpace: 'nowrap',
            border: '1px solid var(--rule)', borderRadius: 999, padding: '6px 14px',
            fontSize: 'var(--t-micro)', letterSpacing: '0.14em', textTransform: 'uppercase', color: 'var(--ink-mute)',
          }}>Surprise me</button>
          {showMoodPlayer && (
          <button onClick={onMoodPlayer} className="ff-mono" style={{
            appearance: 'none', cursor: 'pointer', background: 'transparent', whiteSpace: 'nowrap',
            border: '1px solid var(--rule)', borderRadius: 999, padding: '6px 14px',
            fontSize: 'var(--t-micro)', letterSpacing: '0.14em', textTransform: 'uppercase', color: 'var(--ink-mute)',
          }}>See moods</button>
          )}
        </div>
      </div>

      <div className="scroll" style={{ paddingTop: 300, paddingBottom: 28, display: 'flex', flexDirection: 'column' }}>
        <div className="px-24">
          <OptionRow label="Roast" opts={window.ROAST_OPTS} value={cfg.roast} onChange={v => set('roast', v)} swatches/>
          <OptionRow label="Hat" opts={window.HAT_OPTS} value={cfg.hat} onChange={v => set('hat', v)}/>
          <OptionRow label="Accessory" opts={window.GEAR_OPTS} value={cfg.gear} onChange={v => set('gear', v)}/>
          <OptionRow label="Sprout" opts={window.SPROUT_OPTS} value={cfg.sprout} onChange={v => set('sprout', v)}/>
        </div>

        <div style={{ flex: 1, minHeight: 22 }}/>
        <div className="px-24" style={{ paddingTop: 18 }}>
          <button className="btn btn-primary" disabled={!dirty} onClick={() => onApply(cfg)}>
            {dirty ? 'Apply look' : 'Looking sharp'}
          </button>
        </div>
      </div>
    </div>
  );
}

// ───────────────────────────────────────────────────────────
// MOOD PLAYER — Roasty centered; tap an emotion to see them react.
// ───────────────────────────────────────────────────────────
function RoastyMoodScreen({ roastyCfg, onClose }) {
  const meta = window.ROASTY_ANIM_META || {};
  const moods = ['idle', 'correct', 'xp', 'lesson', 'module', 'card', 'wrong', 'sleep', 'awake'];
  const [mood, setMood] = useStateC('correct');
  const [k, setK] = useStateC(0);
  const [bg, setBg] = useStateC('studio');
  const backdrops = window.BACKDROPS || [];
  const bgVal = (backdrops.find(b => b.id === bg) || backdrops[0]).bg;

  // re-trigger one-shot reactions on a beat
  useEffectC(() => {
    const beat = meta[mood] && meta[mood].beat;
    if (!beat) return;
    const id = setInterval(() => setK(x => x + 1), beat);
    return () => clearInterval(id);
  }, [mood]);

  const pick = (m) => { setMood(m); setK(x => x + 1); };
  const SubHeader = window.SubScreenHeader;
  const [scrolled, onScroll] = window.useScrollFlag();

  return (
    <div className="screen" data-screen-label="Mood player" style={{ background: 'var(--bg)' }}>
      {SubHeader && <SubHeader scrolled={scrolled} title="Mood player" onBack={onClose}/>}
      <div className="scroll" onScroll={onScroll} style={{ paddingTop: 108, paddingBottom: 24, display: 'flex', flexDirection: 'column' }}>
        <div className="px-24" style={{ textAlign: 'center' }}>
          <div className="smallcaps" style={{ color: 'var(--accent)' }}>MOOD PLAYER</div>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.01em', margin: '8px 0 0', color: 'var(--ink)' }}>How's Roasty feeling?</h1>
        </div>

        {/* stage */}
        <div style={{ margin: '18px 24px 0', borderRadius: 16, border: '1px solid var(--rule)', background: bgVal,
          height: 244, display: 'grid', placeItems: 'center', transition: 'background 300ms ease', overflow: 'hidden' }}>
          <Roasty state={mood} size={188} replayKey={k}
            roast={roastyCfg.roast} hat={roastyCfg.hat} gear={roastyCfg.gear} sprout={roastyCfg.sprout}/>
        </div>
        <div className="ff-mono" style={{ textAlign: 'center', fontSize: 'var(--t-micro)', letterSpacing: '0.14em', textTransform: 'uppercase', color: 'var(--ink-mute)', marginTop: 12 }}>
          {(meta[mood] && meta[mood].label) || mood}{meta[mood] && meta[mood].note ? ' · ' + meta[mood].note : ''}
        </div>

        {/* backdrop swatches */}
        <div className="px-24" style={{ paddingTop: 16, display: 'flex', justifyContent: 'center', gap: 8 }}>
          {backdrops.map(b => (
            <button key={b.id} onClick={() => setBg(b.id)} aria-label={b.label}
              style={{ appearance: 'none', cursor: 'pointer', width: 28, height: 28, borderRadius: 999, background: b.bg,
                border: '2px solid ' + (bg === b.id ? 'var(--accent)' : 'var(--rule)') }}/>
          ))}
        </div>

        {/* mood chips */}
        <div className="px-24" style={{ paddingTop: 18 }}>
          <div className="smallcaps" style={{ marginBottom: 10 }}>REACTIONS</div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
            {moods.map(m => {
              const sel = mood === m;
              return (
                <button key={m} onClick={() => pick(m)}
                  style={{
                    appearance: 'none', cursor: 'pointer',
                    padding: '9px 14px', borderRadius: 999,
                    background: sel ? 'color-mix(in oklab, var(--accent) 12%, var(--surface))' : 'var(--surface)',
                    border: '1px solid ' + (sel ? 'var(--accent)' : 'var(--rule)'),
                    color: sel ? 'var(--accent)' : 'var(--ink)',
                    fontFamily: 'IBM Plex Sans, sans-serif', fontSize: 'var(--t-support)', fontWeight: 500,
                  }}>
                  {(meta[m] && meta[m].label) || m}
                </button>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}

// ───────────────────────────────────────────────────────────
// PLUS WELCOME — the celebratory beat right after payment.
// ───────────────────────────────────────────────────────────
function PlusWelcomeScreen({ onOpenStudio, onClose, plan, showMoodPlayer = true }) {
  return (
    <div className="screen" data-screen-label="Plus welcome" style={{ background: 'var(--bg)' }}>
      <div aria-hidden="true" style={{
        position: 'absolute', inset: 0, pointerEvents: 'none',
        background: 'radial-gradient(ellipse at 50% 28%, color-mix(in oklab, var(--accent) 20%, transparent) 0%, transparent 58%)',
      }}/>
      <div className="scroll" style={{ paddingTop: 0, paddingBottom: 24, display: 'flex', flexDirection: 'column' }}>
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center' }}>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <Roasty state="module" size={176} hat="field" sprout="flower"/>
          </div>
          <div className="px-24" style={{ textAlign: 'center', paddingTop: 2 }}>
            <h1 className="ff-display" style={{
              fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em',
              margin: 0, color: 'var(--ink)', textWrap: 'pretty',
            }}>Welcome to Plus.</h1>
            <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: '12px auto 0', maxWidth: 300, textWrap: 'pretty' }}>
              Everything's unlocked. Time to make Roasty and your grove your own.
            </p>
          </div>
        </div>

        <div className="px-24" style={{ paddingTop: 20 }}>
          <button className="btn btn-primary" onClick={onOpenStudio}>Open the Studio</button>
          <div style={{ marginTop: 10 }}>
            <a className="btn btn-ghost" href="#" style={{ display: 'block', textAlign: 'center', textDecoration: 'none' }} onClick={(e) => { e.preventDefault(); onClose(); }}>Back to learning</a>
          </div>
          <p className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.08em', color: 'color-mix(in oklab, var(--ink) 62%, var(--ink-mute))', textAlign: 'center', margin: '14px 0 0', textTransform: 'uppercase' }}>
            7 days free · cancel in Settings
          </p>
        </div>
      </div>
    </div>
  );
}

window.PaywallScreen = PaywallScreen;
window.StudioHub = StudioHub;
window.PlusWelcomeScreen = PlusWelcomeScreen;
window.TreeChooserScreen = TreeChooserScreen;
window.RoastyStudio = RoastyStudio;
window.RoastyMoodScreen = RoastyMoodScreen;
