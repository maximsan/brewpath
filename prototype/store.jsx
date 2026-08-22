// store.jsx — the Courses catalogue. GATED FOR V1: only rendered when the
// "Show Courses catalogue" tweak is on, because a catalogue with one owned
// course and no second purchasable item is a shop with empty shelves. It is a
// learning catalogue, not a storefront: each substantial course is a separate
// ONE-TIME purchase with permanent access; unreleased courses show no price.
// Loaded after customize.jsx, before app.jsx.

function StoreScreen({ owned, onUnlock, onClose }) {
  const price = window.FOUNDATIONS_PRICE || '$49.99';
  const [scrolled, onScroll] = window.useScrollFlag();
  const SubHeader = window.SubScreenHeader;
  const future = [
    { id: 'advanced', title: 'Advanced Brewing', sub: 'Technique, recipes and water' },
    { id: 'espresso', title: 'Espresso', sub: 'Shots, milk and machines' },
    { id: 'origins', title: 'Coffee Origins', sub: 'The places, and what they taste like' },
  ];
  const rowStyle = {
    width: '100%', textAlign: 'left', display: 'grid', gridTemplateColumns: 'auto 1fr auto',
    alignItems: 'center', gap: 14, padding: 16, borderRadius: 16,
    background: 'var(--surface)', border: '1px solid var(--rule)',
  };
  const artBox = { width: 56, height: 56, flexShrink: 0, borderRadius: 12, border: '1px solid var(--rule)', background: 'var(--bg)', overflow: 'hidden', display: 'grid', placeItems: 'center' };
  return (
    <div className="screen" data-screen-label="Courses" style={{ background: 'var(--bg)' }}>
      {SubHeader && <SubHeader scrolled={scrolled} title="Courses" onBack={onClose}/>}
      <div className="scroll" onScroll={onScroll} style={{ paddingTop: 108, paddingBottom: 40 }}>
        <div className="px-24">
          <div className="smallcaps" style={{ color: 'var(--accent)', marginBottom: 10 }}>ONE-TIME PURCHASES</div>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>Courses</h1>
        </div>

        <div className="px-24" style={{ paddingTop: 24, display: 'flex', flexDirection: 'column', gap: 12 }}>
          {/* Foundations — the shipped course */}
          <button onClick={owned ? undefined : onUnlock} disabled={owned}
            style={{ ...rowStyle, appearance: 'none', cursor: owned ? 'default' : 'pointer', font: 'inherit', color: 'inherit', borderColor: owned ? 'var(--rule)' : 'color-mix(in oklab, var(--accent) 35%, var(--rule))' }}>
            <span style={artBox}>
              <img src="assets/modules/m1-beans.png" alt="" aria-hidden="true" style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block' }}/>
            </span>
            <span style={{ minWidth: 0 }}>
              <span className="ff-display" style={{ display: 'block', fontSize: 'var(--t-heading)', fontWeight: 400, letterSpacing: '-0.01em', color: 'var(--ink)', lineHeight: 1.05 }}>Foundations</span>
              <span style={{ display: 'block', fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 3 }}>5 modules · beans to brewing</span>
            </span>
            {owned ? (
              <span className="ff-mono" style={{ display: 'inline-flex', alignItems: 'center', gap: 7, fontSize: 'var(--t-micro)', letterSpacing: '0.14em', textTransform: 'uppercase', color: 'var(--sage)', whiteSpace: 'nowrap' }}>
                <svg width="12" height="12" viewBox="0 0 12 12"><path d="M2 6.2l2.6 2.6L10 3" fill="none" stroke="var(--sage)" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"/></svg>
                OWNED
              </span>
            ) : (
              <span style={{ display: 'inline-flex', alignItems: 'center', gap: 10 }}>
                <span className="ff-mono" style={{ fontSize: 'var(--t-support)', color: 'var(--ink)', whiteSpace: 'nowrap' }}>{price}</span>
                <window.Chevron/>
              </span>
            )}
          </button>

          {/* Future courses — HIDDEN FOR V1 (SHOW_COMING_SOON): announcing them
              is a promise we'd have to keep. Roll back if we decide to build more. */}
          {window.SHOW_COMING_SOON && future.map(c => (
            <div key={c.id} style={{ ...rowStyle, opacity: 0.72 }}>
              <span className="ff-mono" style={{ ...artBox, background: 'repeating-linear-gradient(135deg, var(--surface-2) 0 6px, transparent 6px 12px)', border: '1px dashed var(--rule)', fontSize: 'var(--t-micro)', letterSpacing: '0.1em', color: 'var(--ink-mute)' }} aria-hidden="true">ART</span>
              <span style={{ minWidth: 0 }}>
                <span className="ff-display" style={{ display: 'block', fontSize: 'var(--t-heading)', fontWeight: 400, letterSpacing: '-0.01em', color: 'var(--ink)', lineHeight: 1.05 }}>{c.title}</span>
                <span style={{ display: 'block', fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 3 }}>{c.sub}</span>
              </span>
              <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.14em', textTransform: 'uppercase', color: 'var(--ink-mute)', whiteSpace: 'nowrap' }}>COMING SOON</span>
            </div>
          ))}
        </div>

        <div className="px-24" style={{ paddingTop: 26, textAlign: 'center' }}>
          <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.12em', color: 'var(--ink-mute)', textTransform: 'uppercase', lineHeight: 1.6 }}>
            Each course is a separate one-time purchase.<br/>Buy once, keep it forever.
          </div>
        </div>
      </div>
    </div>
  );
}

window.StoreScreen = StoreScreen;
