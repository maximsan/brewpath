// customize.jsx — Premium customization (behind the "BrewPath Plus" paywall):
//   • PaywallScreen     — the gate. Teaser + plan + free-trial CTA.
//   • StudioHub         — landing with three doors once unlocked.
//   • TreeChooserScreen — pick which plant grows in your grove (variety + light).
//   • RoastyStudio      — dress Roasty up: roast, hat, gear, sprout.
//   • RoastyMoodScreen  — Roasty centered; tap an emotion to see them react.
//
// Customization is held in App state, mirrored to window.ROASTY_CONFIG /
// window.TREE_CONFIG so every <Roasty/> and <CoffeePersona/> in the app
// reflects the applied look, and persisted to localStorage.

const { useState: useStateC, useEffect: useEffectC } = React;

// ── The grove has two axes. PLANT is which coffee species you own — a real
//    plant with its own silhouette. LIGHT is what it stands in — mood only,
//    applied over any plant.
//    Three species, no taxonomy lesson required: Arabica, Robusta and Liberica
//    are all species, so the list is factually parallel and a beginner can read
//    it top to bottom without a hierarchy. (Varieties within Arabica — Typica,
//    Bourbon, Geisha — are a later layer, if ever.)
//    Ship art is bespoke per plant per stage; until it exists each carries a
//    silhouette transform + leaf tone over the shared frames, so the three read
//    apart without relying on hue alone.
//    No per-plant gating: the Studio door itself is behind the paywall, so
//    everything inside it is owned. `drop` is a rollout note for the art
//    pipeline, not an entitlement.
//    One field per idea, one place each: `share` is prevalence (spec strip
//    only), `use` is what the bean gets brewed as — the same question for all
//    three, never prevalence in words (row subtitle only), `cup` is the spec
//    strip's Tastes like, and `tell` covers what none of them can: the plant's
//    body plus one consequence worth remembering. ──
window.TREE_VARIETIES = [
  { id: 'arabica', name: 'Arabica', latin: 'Coffea arabica', share: '~60%', use: 'Filter & pour-over',
    origin: 'Ethiopia', grows: 'High and cool', cup: 'Sweet, fruity, delicate',
    tell: 'Tall and slim, with glossy leaves on flat tiered branches — and fussy enough that one bad season moves the price of your morning cup.',
    shape: 'none', leaf: '', drop: 'launch' },
  { id: 'robusta', name: 'Robusta', latin: 'Coffea canephora', share: '~35%', use: 'Espresso & instant',
    origin: 'West Africa · Vietnam', grows: 'Low and warm', cup: 'Bold, chocolatey, bitter',
    tell: 'Broader and bushier, with much larger leaves and cherries in tight clusters along the branch. Twice the caffeine of Arabica, and the reason a good espresso carries a thick crema.',
    shape: 'scale(1.2, 0.9)', leaf: 'saturate(1.2) hue-rotate(-8deg) brightness(0.94)', drop: 'launch' },
  { id: 'liberica', name: 'Liberica', latin: 'Coffea liberica', share: '<1%', use: 'Local brews in SE Asia',
    origin: 'Philippines · Malaysia', grows: 'Low and humid', cup: 'Smoky, jackfruit, savoury',
    tell: 'Enormous leathery leaves and the biggest cherries of any coffee, on a tree that can grow twice as tall as the others — tall enough that picking it often needs a ladder.',
    shape: 'scale(1.1, 1.12)', leaf: 'saturate(0.95) hue-rotate(6deg) brightness(0.96)', drop: 'later' },
];

// Light sits on top of whichever variety is planted. Three treatments plus the
// unfiltered default — enough to change the mood, not enough to pretend to be
// a different plant.
window.GROVE_LIGHT = [
  { id: 'daylight',   name: 'Daylight',    note: 'No filter',      swatch: '#6B7F5A', filter: '' },
  { id: 'goldenhour', name: 'Golden Hour', note: 'Late sun',       swatch: '#C98A3C', filter: 'sepia(0.45) saturate(1.5) hue-rotate(-12deg) brightness(1.05)' },
  { id: 'moonlit',    name: 'Moonlit',     note: 'Cool night',     swatch: '#7E93A8', filter: 'saturate(0.6) hue-rotate(150deg) brightness(0.96) contrast(1.06)' },
  { id: 'frost',      name: 'First Frost', note: 'Cold morning',   swatch: '#D9DEE0', filter: 'saturate(0.5) brightness(1.12) contrast(0.94)' },
];

window.getVariety = (id) => (window.TREE_VARIETIES || []).find(v => v.id === id) || window.TREE_VARIETIES[0];
window.getLight   = (id) => (window.GROVE_LIGHT || []).find(l => l.id === id) || window.GROVE_LIGHT[0];
// Leaf tone and light compose into one CSS filter; silhouette is a separate transform.
window.groveFilter = (varietyId, lightId) =>
  [window.getVariety(varietyId).leaf, window.getLight(lightId).filter].filter(f => f && f !== 'none').join(' ');
window.groveShape = (varietyId) => {
  const s = window.getVariety(varietyId).shape;
  return s && s !== 'none' ? s : '';
};
// Old saves stored a single "skin" id that conflated both axes. Split it.
window.migrateGrove = (saved) => {
  saved = saved || {};
  if (saved.variety) {
    // Varieties from the earlier draft collapse into their species.
    const v = { typica: 'arabica', bourbon: 'arabica', geisha: 'arabica' }[saved.variety] || saved.variety;
    return { variety: v, light: saved.light || 'daylight' };
  }
  const legacy = { heirloom: 'daylight', goldenhour: 'goldenhour', moonlit: 'moonlit', blossom: 'daylight', verdant: 'daylight' };
  return { variety: 'arabica', light: legacy[saved.tree] || 'daylight' };
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

// ───────────────────────────────────────────────────────────
// PAYWALL
// ───────────────────────────────────────────────────────────
function PaywallScreen({ onSubscribe, onClose, showMoodPlayer = true }) {
  const [plan, setPlan] = useStateC('yearly');

  const benefits = [
    ['Unlimited Saved', 'Keep every lesson, term and guide — past the free shelf of 10'],
    ['Dress up Roasty', 'Hats, glasses, scarves, roast level and more'],
    ['Choose your plant', 'Grow Arabica, Robusta or Liberica \u2014 real coffee species, each its own shape'],
    showMoodPlayer
      ? ['Mood player', "Tap through Roasty’s reactions any time"]
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
                  padding: '16px 18px', borderRadius: 2, background: 'var(--surface)',
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
          {/* Store review requires restore + legal on the purchase screen itself.
              Micro type, but still real targets: padding carries each link to 44px
              and the row's negative margin keeps the original 12px optical gap. */}
          <div style={{ display: 'flex', justifyContent: 'center', gap: 4, marginTop: 12, marginBottom: -14 }}>
            {['Restore purchases', 'Terms', 'Privacy'].map(l => (
              <a key={l} href="#" onClick={(e) => e.preventDefault()} className="ff-mono"
                 style={{ display: 'inline-block', padding: '15px 8px', margin: '-15px 0', fontSize: 'var(--t-micro)', letterSpacing: '0.08em', textTransform: 'uppercase', color: 'var(--ink-mute)', textDecoration: 'none' }}>{l}</a>
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

function StudioHub({ roastyCfg, treeId, lightId, showMoodPlayer = true, chrome = true, onChooseTree, onDressRoasty, onMoodPlayer, onClose }) {
  const variety = window.getVariety(treeId);
  const light = window.getLight(lightId);
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
          <StudioDoor onClick={onChooseTree} eyebrow="GROVE" title="Choose your plant" sub={variety.name + (light.id === 'daylight' ? '' : ' · ' + light.name)}
            art={<div style={{ width: 64, height: 64 }}><CoffeePersona stage={9} size={64} animate={false} withGround={false}
              treatment={window.groveFilter(treeId, lightId)} shape={window.groveShape(treeId)}/></div>}/>
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
// Three plants, so a full-width row beats a grid: thumbnail, name, and the
// positioning line — no odd empty cell, and nothing the detail block above
// already says. No locks: the whole Studio is past the paywall, so everything
// in it is owned.
// GROVE_SELECTED is the one selected-state recipe on this screen, shared by the
// plant rows and the light chips so "picked" looks identical in both.
const GROVE_SELECTED = {
  on:  { background: 'color-mix(in oklab, var(--accent) 10%, var(--surface))', border: '1px solid var(--accent)' },
  off: { background: 'var(--surface)', border: '1px solid var(--rule)' },
};

function PlantRow({ variety, selected, lightId, onSelect }) {
  return (
    <button onClick={onSelect} aria-pressed={selected} className="ff-ui"
      style={{
        appearance: 'none', cursor: 'pointer', textAlign: 'left', width: '100%',
        display: 'flex', alignItems: 'center', gap: 12, padding: '10px 12px', minHeight: 72,
        borderRadius: 2, ...(selected ? GROVE_SELECTED.on : GROVE_SELECTED.off),
      }}>
      <span style={{ width: 52, height: 52, display: 'grid', placeItems: 'center', flexShrink: 0 }}>
        <CoffeePersona stage={9} size={52} animate={false} withGround={false}
          treatment={window.groveFilter(variety.id, lightId)} shape={window.groveShape(variety.id)}/>
      </span>
      <span style={{ flex: 1, minWidth: 0 }}>
        <span className="ff-display" style={{ display: 'block', fontSize: 'var(--t-heading)', fontWeight: 400, letterSpacing: '-0.01em', color: 'var(--ink)', lineHeight: 1.1 }}>{variety.name}</span>
        <span className="smallcaps-mono" style={{ display: 'block', fontSize: 'var(--t-micro)', color: selected ? 'var(--accent)' : 'var(--ink-mute)', marginTop: 4 }}>{variety.use}</span>
      </span>
      {selected && (
        <span style={{ width: 22, height: 22, borderRadius: 999, background: 'var(--accent)', display: 'grid', placeItems: 'center', flexShrink: 0 }}>
          <svg width="12" height="12" viewBox="0 0 12 12"><path d="M2 6.2l2.6 2.6L10 3" fill="none" stroke="var(--accent-ink)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
        </span>
      )}
    </button>
  );
}

function TreeChooserScreen({ treeId, lightId, onApply, onClose }) {
  const varieties = window.TREE_VARIETIES || [];
  const lights = window.GROVE_LIGHT || [];
  const [selV, setSelV] = useStateC(treeId || 'arabica');
  const [selL, setSelL] = useStateC(lightId || 'daylight');
  const variety = window.getVariety(selV);
  const dirty = selV !== treeId || selL !== lightId;
  const SubHeader = window.SubScreenHeader;
  const [scrolled, onScroll] = window.useScrollFlag();

  return (
    <div className="screen" data-screen-label="Grove — choose your plant" style={{ background: 'var(--bg)' }}>
      {SubHeader && <SubHeader scrolled={scrolled} title="Your grove" onBack={onClose}/>}
      <div className="scroll" onScroll={onScroll} style={{ paddingTop: 100, paddingBottom: 28, display: 'flex', flexDirection: 'column' }}>

        {/* Live preview of the current pick — plant silhouette under the chosen light */}
        <div style={{ height: 176, display: 'grid', placeItems: 'center' }}>
          <CoffeePersona key={selV} stage={10} size={176} withGround
            treatment={window.groveFilter(selV, selL)} shape={window.groveShape(selV)}/>
        </div>

        {/* Name and binomial only — one display line, one mono line. The
            positioning fact moved into the spec strip below, where it has to
            answer the same question for all three plants. */}
        <div className="px-24" style={{ paddingTop: 4 }}>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.08, letterSpacing: '-0.01em', margin: 0, color: 'var(--ink)' }}>{variety.name}</h1>
          <div className="ff-mono" style={{ fontSize: 'var(--t-support)', letterSpacing: '0.02em', color: 'var(--ink-mute)', marginTop: 4 }}>{variety.latin}</div>
        </div>

        {/* Plain-language spec strip — same shape a dictionary term page would carry */}
        <div className="px-24" style={{ paddingTop: 16 }}>
          <div className="form-row"><span className="lbl">Share of cups</span><span className="val">{variety.share}</span></div>
          <div className="form-row"><span className="lbl">Home</span><span className="val">{variety.origin}</span></div>
          <div className="form-row"><span className="lbl">Grows</span><span className="val">{variety.grows}</span></div>
          <div className="form-row"><span className="lbl">Tastes like</span><span className="val">{variety.cup}</span></div>
        </div>

        <div className="px-24" style={{ paddingTop: 14 }}>
          <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink-mute)', margin: 0, textWrap: 'pretty' }}>{variety.tell}</p>
        </div>

        <div className="px-24" style={{ paddingTop: 26 }}>
          <div className="smallcaps" style={{ marginBottom: 10 }}>PLANT</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {varieties.map(v => (
              <PlantRow key={v.id} variety={v} lightId={selL}
                selected={selV === v.id}
                onSelect={() => setSelV(v.id)}/>
            ))}
          </div>
        </div>

        <div className="px-24" style={{ paddingTop: 24 }}>
          <div className="smallcaps" style={{ marginBottom: 10 }}>LIGHT</div>
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            {lights.map(l => {
              const sel = selL === l.id;
              return (
                <button key={l.id} onClick={() => setSelL(l.id)} aria-pressed={sel} className="ff-ui"
                  style={{
                    appearance: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 7,
                    padding: '9px 14px 9px 11px', borderRadius: 999, minHeight: 44,
                    ...(sel ? GROVE_SELECTED.on : GROVE_SELECTED.off),
                  }}>
                  <span style={{ width: 14, height: 14, borderRadius: 999, background: l.swatch, border: '1px solid color-mix(in oklab, var(--ink) 22%, transparent)', flexShrink: 0 }}/>
                  <span style={{ fontSize: 'var(--t-support)', fontWeight: sel ? 500 : 400, color: 'var(--ink)', whiteSpace: 'nowrap' }}>{l.name}</span>
                </button>
              );
            })}
          </div>
        </div>

        <div style={{ flex: 1, minHeight: 20 }}/>
        <div className="px-24" style={{ paddingTop: 22 }}>
          <button className="btn btn-primary" disabled={!dirty} onClick={() => onApply(selV, selL)}>
            {dirty ? 'Plant in my grove' : 'Already planted'}
          </button>
          <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: '12px 0 0', textAlign: 'center', textWrap: 'pretty' }}>
            Every plant grows through all ten stages, seed to harvest.
          </p>
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
        ? <window.SubScreenHeader solid title="Dress up Roasty" onBack={onClose}/>
        : <StudioTopbar onBack={onClose} kind="back"/>}

      {/* Live preview — pinned panel, seated directly below the solid header */}
      <div style={{ position: 'absolute', top: window.HEADER_H || 96, left: 0, right: 0, zIndex: 5,
        background: 'linear-gradient(180deg, color-mix(in oklab, var(--accent) 10%, var(--bg)) 0%, var(--bg) 100%)',
        paddingTop: 20, paddingBottom: 14 }}>
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
  const moods = ['idle', 'correct', 'points', 'lesson', 'module', 'card', 'wrong', 'sleep', 'awake'];
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
        <div className="px-24" style={{ paddingTop: 8, display: 'flex', justifyContent: 'center', gap: 0 }}>
          {backdrops.map(b => (
            <button key={b.id} onClick={() => setBg(b.id)} aria-label={b.label}
              style={{ appearance: 'none', cursor: 'pointer', width: 44, height: 44, padding: 0, background: 'transparent', border: 'none', display: 'grid', placeItems: 'center' }}>
              <span style={{ width: 28, height: 28, borderRadius: 999, background: b.bg, boxSizing: 'border-box',
                border: '2px solid ' + (bg === b.id ? 'var(--accent)' : 'var(--rule)') }}></span>
            </button>
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
