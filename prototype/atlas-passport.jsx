// atlas-passport.jsx — the Coffee Passport preview, the map filter sheet,
// and their empty states.

const { useState: useStateP, useEffect: useEffectP } = React;

// ── Stamp-collection animation keyframes (shared) ───────────
function StampAnimStyles() {
  return (
    <style>{`
      @keyframes atlasStampIn { 0%{transform:translateY(14px) scale(.94)} 100%{transform:none} }
      @keyframes atlasFreshPulse { 0%{box-shadow:0 0 0 0 color-mix(in oklab, var(--accent) 55%, transparent)} 100%{box-shadow:0 0 0 13px transparent} }
      @keyframes atlasStampSlam { 0%{transform:rotate(-7deg) scale(2.7);opacity:0} 48%{opacity:1} 66%{transform:rotate(-7deg) scale(.9)} 82%{transform:rotate(-7deg) scale(1.05)} 100%{transform:rotate(-7deg) scale(1);opacity:1} }
      @keyframes atlasStampRing { 0%{transform:scale(.55);opacity:0} 58%{opacity:0} 68%{opacity:.85} 100%{transform:scale(1.55);opacity:0} }
      @keyframes atlasOvFade { from{opacity:0} to{opacity:1} }
      @keyframes atlasOvShake { 0%,60%{transform:translate(0,0)} 65%{transform:translate(-4px,3px)} 70%{transform:translate(4px,-3px)} 75%{transform:translate(-3px,2px)} 80%{transform:translate(2px,-1px)} 85%,100%{transform:translate(0,0)} }
      @keyframes atlasOvCaption { from{opacity:0;transform:translateY(8px)} to{opacity:1;transform:none} }
      @media (prefers-reduced-motion: reduce){
        .atlas-pp-stamp{ animation:none !important }
        .atlas-stamp-ov, .atlas-stamp-ov *{ animation:none !important }
      }
    `}</style>
  );
}

// ── Stamp-press celebration (plays when an origin is tasted) ─
function StampPressOverlay({ origin, state, hold, onDone }) {
  const m = (window.ATLAS_STATE_META && window.ATLAS_STATE_META[state]) || { color: 'var(--accent)', short: 'TASTED' };
  const region = window.ATLAS_REGIONS[origin.region];
  const caption = { discovered: 'New origin discovered', lesson: 'Lesson complete', tasted: 'Stamped in your passport' }[state] || 'Stamped in your passport';
  useEffectP(() => { if (hold) return; const t = setTimeout(onDone, 2200); return () => clearTimeout(t); }, []);
  return (
    <div className="atlas-stamp-ov" onClick={onDone} style={{
      position: 'absolute', inset: 0, zIndex: 140, display: 'grid', placeItems: 'center', cursor: 'pointer',
      background: 'color-mix(in oklab, var(--ink) 58%, transparent)', animation: 'atlasOvFade 220ms ease',
    }}>
      <StampAnimStyles/>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 24, animation: 'atlasOvShake 820ms ease' }}>
        <div style={{ position: 'relative', width: 200, height: 200, display: 'grid', placeItems: 'center' }}>
          <span style={{ position: 'absolute', width: 188, height: 188, borderRadius: 999, border: '2px solid ' + m.color, animation: 'atlasStampRing 820ms ease-out' }}/>
          <span style={{ position: 'absolute', width: 188, height: 188, borderRadius: 999, border: '2px solid ' + m.color, animation: 'atlasStampRing 820ms ease-out 120ms', opacity: 0 }}/>
          <div style={{
            position: 'relative', width: 184, height: 184, borderRadius: 999, display: 'grid', placeItems: 'center',
            border: '2.5px solid ' + m.color, boxShadow: 'inset 0 0 0 5px color-mix(in oklab, ' + m.color + ' 20%, transparent)',
            transform: 'rotate(-7deg)', animation: 'atlasStampSlam 700ms cubic-bezier(.2,.9,.3,1.05)',
            background: 'color-mix(in oklab, ' + m.color + ' 10%, var(--surface))',
          }}>
            <div style={{ textAlign: 'center', padding: '0 18px' }}>
              <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.22em', color: m.color, opacity: 0.85 }}>★ ORIGIN ★</div>
              <div className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, letterSpacing: '-0.02em', color: m.color, lineHeight: 1, margin: '9px 0 9px' }}>{origin.name}</div>
              <div style={{ height: 1, background: 'color-mix(in oklab, ' + m.color + ' 40%, transparent)', margin: '0 auto 9px', width: '70%' }}/>
              <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.18em', color: m.color }}>{m.short}</div>
            </div>
          </div>
        </div>
        <div style={{ textAlign: 'center', animation: 'atlasOvCaption 460ms ease 340ms both' }}>
          <div className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, color: '#fff', letterSpacing: '-0.01em' }}>{caption}</div>
          <div className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.14em', textTransform: 'uppercase', color: 'rgba(255,255,255,.7)', marginTop: 9 }}>{region.label} · tap to continue</div>
        </div>
      </div>
    </div>
  );
}

// ── Filter sheet (used by the map) ──────────────────────────
function AtlasFilterSheet({ open, value, counts, favs, onPick, onClose }) {
  const states = counts || {};
  const tally = (key) => {
    if (key === 'all') return window.ATLAS_ORIGINS.length;
    if (key === 'favourites') return (favs || []).length;
    return window.ATLAS_ORIGINS.filter(o => (states[o.slug] || 'not-explored') === key).length;
  };
  const rows = [
    { id: 'all', label: 'All origins' },
    { id: 'not-explored', label: 'Not explored' },
    { id: 'discovered', label: 'Discovered' },
    { id: 'lesson', label: 'Lesson done' },
    { id: 'tasted', label: 'Coffee tasted' },
    { id: 'favourites', label: 'Favourites' },
  ];
  return (
    <>
      <div className={'sheet-backdrop' + (open ? ' open' : '')} onClick={onClose}/>
      <div className={'sheet' + (open ? ' open' : '')} style={{ maxHeight: '72%' }}>
        <div className="sheet-handle"/>
        <div className="sheet-content">
          <div className="smallcaps" style={{ marginBottom: 14 }}>FILTER ORIGINS</div>
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            {rows.map((r, i) => {
              const on = value === r.id;
              const m = window.ATLAS_STATE_META[r.id];
              return (
                <button key={r.id} onClick={() => onPick(r.id)} style={{
                  appearance: 'none', cursor: 'pointer', textAlign: 'left', background: 'transparent',
                  border: 'none', borderTop: i ? '1px solid var(--rule)' : 'none',
                  display: 'grid', gridTemplateColumns: 'auto 1fr auto', alignItems: 'center', gap: 12, padding: '16px 2px',
                }}>
                  <span style={{ width: 12, height: 12, borderRadius: 999, flexShrink: 0,
                    background: r.id === 'favourites' ? 'var(--berry)' : (m ? m.color : 'var(--ink)'),
                    border: r.id === 'all' ? '2px solid var(--ink)' : 'none', boxSizing: 'border-box',
                    opacity: r.id === 'all' ? 0.5 : 1 }}/>
                  <span style={{ fontSize: 'var(--t-body)', color: on ? 'var(--accent)' : 'var(--ink)', fontWeight: on ? 600 : 400 }}>{r.label}</span>
                  <span style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                    <span className="ff-mono" style={{ fontSize: 'var(--t-label)', color: 'var(--ink-mute)' }}>{tally(r.id)}</span>
                    {on && <svg width="16" height="16" viewBox="0 0 16 16"><path d="M3 8.4l3 3 7-7.5" fill="none" stroke="var(--accent)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>}
                  </span>
                </button>
              );
            })}
          </div>
        </div>
      </div>
    </>
  );
}

// ── Passport stamp ──────────────────────────────────────────
function PassportStamp({ origin, state, fav, idx = 0, fresh, onClick }) {
  const m = window.ATLAS_STATE_META[state] || window.ATLAS_STATE_META['not-explored'];
  const explored = m.rank >= 1;
  const tilt = ((origin.slug.charCodeAt(0) + origin.slug.length) % 5) - 2;   // -2..2 deg
  const anim = 'atlasStampIn 460ms cubic-bezier(.2,1,.4,1) ' + (Math.min(idx, 11) * 38) + 'ms both'
             + (fresh && explored ? ', atlasFreshPulse 1.5s ease-out 560ms 2' : '');
  return (
    <button className="atlas-pp-stamp" onClick={() => explored && onClick(origin.slug)} disabled={!explored} style={{
      appearance: 'none', cursor: explored ? 'pointer' : 'default', textAlign: 'left',
      background: explored ? 'var(--surface)' : 'transparent',
      border: '1.5px ' + (explored ? 'solid' : 'dashed') + ' ' + (explored ? 'color-mix(in oklab, ' + m.color + ' 50%, var(--rule))' : 'var(--rule)'),
      borderRadius: 14, padding: '14px 14px 13px', position: 'relative', overflow: 'hidden',
      opacity: explored ? 1 : 0.5, minHeight: 128, animation: anim,
      display: 'flex', flexDirection: 'column', justifyContent: 'space-between', gap: 10,
    }}>
      {/* stamp ring */}
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
        <div style={{
          transform: `rotate(${tilt}deg)`, border: '1.5px solid ' + (explored ? m.color : 'var(--ink-mute)'),
          borderRadius: 999, padding: '3px 9px',
        }}>
          <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.14em', textTransform: 'uppercase', color: explored ? m.color : 'var(--ink-mute)' }}>{explored ? m.short : 'LOCKED'}</span>
        </div>
        {explored && fav && <svg viewBox="0 0 14 14" width="13" height="13"><path d="M7 13 L1.8 7.4 A3.2 3.2 0 0 1 7 3.1 A3.2 3.2 0 0 1 12.2 7.4 Z" fill="var(--berry)"/></svg>}
      </div>

      <div>
        <div className="ff-display" style={{ fontSize: explored ? 21 : 18, fontWeight: 400, letterSpacing: '-0.01em', lineHeight: 1.0, color: explored ? 'var(--ink)' : 'var(--ink-mute)' }}>
          {explored ? origin.name : '— — —'}
        </div>
        <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--ink-mute)', marginTop: 6 }}>
          {window.ATLAS_REGIONS[origin.region].label}
        </div>
      </div>
    </button>
  );
}

// ── Passport screen ─────────────────────────────────────────
function PassportScreen({ states, favs, empty, freshSlug, onOpenOrigin, onExplore, onClose }) {
  const [view, setView] = useStateP('all');   // all | tasted | saved
  const liveStates = empty ? {} : states;
  const liveFavs = empty ? [] : favs;
  const prog = window.atlasProgress(liveStates);

  let list = window.ATLAS_ORIGINS.slice().sort((a, b) => window.atlasRank(liveStates[b.slug]) - window.atlasRank(liveStates[a.slug]));
  if (view === 'tasted') list = list.filter(o => liveStates[o.slug] === 'tasted');
  else if (view === 'saved') list = list.filter(o => liveFavs.indexOf(o.slug) >= 0);

  const stats = [
    { k: 'Explored', v: prog.explored, color: 'color-mix(in oklab, var(--accent) 40%, var(--ink-mute))' },
    { k: 'Lessons', v: prog.lessons, color: 'var(--sage)' },
    { k: 'Tasted', v: prog.tasted, color: 'var(--accent)' },
  ];
  const isEmpty = prog.explored === 0;
  const [tbScrolled, onTbScroll] = window.useScrollFlag();

  return (
    <div className="screen" data-screen-label="Atlas · Passport" style={{ background: 'var(--bg)' }}>
      <window.FloatTopbar scrolled={tbScrolled} onBack={onClose} back label="Back"/>

      <div className="scroll" onScroll={onTbScroll} style={{ paddingTop: 108, paddingBottom: 28 }}>
        <StampAnimStyles/>
        <div className="px-24">
          <div className="smallcaps" style={{ color: 'var(--accent)', marginBottom: 8 }}>YOUR COFFEE PASSPORT</div>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.0, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>
            {prog.explored} of {prog.total}<br/>origins explored
          </h1>
        </div>

        {/* progress bar */}
        <div className="px-24" style={{ paddingTop: 18 }}>
          <div style={{ height: 8, background: 'var(--surface-2)', borderRadius: 999, overflow: 'hidden', display: 'flex' }}>
            <div style={{ width: (prog.tasted / prog.total * 100) + '%', background: 'var(--accent)' }}/>
            <div style={{ width: ((prog.lessons - prog.tasted) / prog.total * 100) + '%', background: 'var(--sage)' }}/>
            <div style={{ width: ((prog.explored - prog.lessons) / prog.total * 100) + '%', background: 'color-mix(in oklab, var(--accent) 40%, var(--ink-mute))' }}/>
          </div>
        </div>

        {/* stat tiles */}
        <div className="px-24" style={{ paddingTop: 16 }}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10 }}>
            {stats.map(s => (
              <div key={s.k} style={{ background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 12, padding: '14px 12px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  <span style={{ width: 8, height: 8, borderRadius: 999, background: s.color }}/>
                  <span className="ff-mono" style={{ fontSize: 'var(--t-lead)', fontWeight: 500, letterSpacing: '-0.01em', color: 'var(--ink)', lineHeight: 1 }}>{s.v}</span>
                </div>
                <div className="smallcaps" style={{ marginTop: 8 }}>{s.k}</div>
              </div>
            ))}
          </div>
        </div>

        {isEmpty ? (
          /* empty passport */
          <div className="px-24" style={{ paddingTop: 48, display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center' }}>
            <div style={{ width: 92, height: 92, borderRadius: 18, border: '2px dashed var(--rule)', display: 'grid', placeItems: 'center', marginBottom: 20 }}>
              <svg width="40" height="40" viewBox="0 0 40 40" style={{ color: 'var(--ink-mute)' }}>
                <rect x="8" y="6" width="24" height="28" rx="3" fill="none" stroke="currentColor" strokeWidth="1.6"/>
                <circle cx="20" cy="19" r="5" fill="none" stroke="currentColor" strokeWidth="1.6"/>
                <path d="M14 28h12" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/>
              </svg>
            </div>
            <h2 className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, margin: 0, color: 'var(--ink)' }}>No stamps yet</h2>
            <p style={{ margin: '10px 0 0', fontSize: 'var(--t-body)', lineHeight: 1.6, color: 'var(--ink-mute)', maxWidth: 270, textWrap: 'pretty' }}>
              Open any origin on the map to discover it. Finish its activity and log a tasting to fill your passport.
            </p>
            <button className="btn btn-primary" style={{ width: 'auto', marginTop: 24, padding: '15px 28px' }} onClick={onExplore}>Explore the map</button>
          </div>
        ) : (
          <>
            {/* segmented */}
            <div className="px-24" style={{ paddingTop: 26 }}>
              <div style={{ display: 'flex', gap: 4, background: 'var(--surface-2)', borderRadius: 999, padding: 4 }}>
                {[['all', 'All'], ['tasted', 'Tasted'], ['saved', 'Saved']].map(([id, label]) => (
                  <button key={id} onClick={() => setView(id)} className="ff-ui" style={{
                    flex: 1, appearance: 'none', cursor: 'pointer', border: 'none', borderRadius: 999, padding: '9px 6px',
                    fontSize: 'var(--t-support)', fontWeight: 500, background: view === id ? 'var(--accent)' : 'transparent',
                    color: view === id ? 'var(--accent-ink)' : 'var(--ink-mute)',
                  }}>{label}</button>
                ))}
              </div>
            </div>

            <div className="px-24" style={{ paddingTop: 20 }}>
              {list.length === 0 ? (
                <div style={{ padding: '40px 0', textAlign: 'center' }}>
                  <p style={{ margin: 0, fontSize: 'var(--t-support)', lineHeight: 1.6, color: 'var(--ink-mute)', textWrap: 'pretty' }}>
                    {view === 'saved' ? 'No favourites yet — tap the bookmark on any origin to save it here.' : 'No tasted origins yet. Log a tasting from any origin profile.'}
                  </p>
                </div>
              ) : (
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
                  {list.map((o, i) => (
                    <PassportStamp key={o.slug} origin={o} idx={i} fresh={o.slug === freshSlug}
                                   state={liveStates[o.slug] || 'not-explored'}
                                   fav={liveFavs.indexOf(o.slug) >= 0} onClick={onOpenOrigin}/>
                  ))}
                </div>
              )}
            </div>

            {view === 'all' && (
              <div className="px-24" style={{ paddingTop: 22 }}>
                <p className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--ink-mute)', textAlign: 'center', lineHeight: 1.7 }}>
                  {prog.total - prog.explored} origins still to discover
                </p>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}

window.AtlasFilterSheet = AtlasFilterSheet;
window.PassportScreen = PassportScreen;
window.PassportStamp = PassportStamp;
window.StampPressOverlay = StampPressOverlay;
