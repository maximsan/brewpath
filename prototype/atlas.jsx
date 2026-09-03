// atlas.jsx — Coffee Atlas screens: the map tab, the origin peek sheet, the
// full origin profile (two layouts), and the region overview.

const { useState: useStateAt, useEffect: useEffectAt } = React;

// ── Small shared bits ───────────────────────────────────────
function StateChip({ state, size = 'md' }) {
  const m = window.ATLAS_STATE_META[state] || window.ATLAS_STATE_META['not-explored'];
  const sm = size === 'sm';
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: sm ? '2px 7px' : '4px 9px', borderRadius: 999,
      border: '1px solid ' + (state === 'not-explored' ? 'var(--rule)' : 'color-mix(in oklab, ' + m.color + ' 45%, var(--rule))'),
      background: state === 'not-explored' ? 'transparent' : 'color-mix(in oklab, ' + m.color + ' 12%, var(--surface))',
    }}>
      <span style={{ width: sm ? 6 : 7, height: sm ? 6 : 7, borderRadius: 999, background: m.color, border: state === 'not-explored' ? '1px solid var(--ink-mute)' : 'none', boxSizing: 'border-box' }}/>
      <span className="ff-mono" style={{ fontSize: sm ? 8.5 : 9.5, letterSpacing: '0.12em', textTransform: 'uppercase', color: state === 'not-explored' ? 'var(--ink-mute)' : 'color-mix(in oklab, ' + m.color + ' 70%, var(--ink))' }}>{m.short}</span>
    </span>
  );
}

function Chip({ children, accent }) {
  return (
    <span style={{
      display: 'inline-block', padding: '6px 11px', borderRadius: 999, fontSize: 'var(--t-support)',
      border: '1px solid ' + (accent ? 'color-mix(in oklab, var(--accent) 40%, var(--rule))' : 'var(--rule)'),
      background: accent ? 'color-mix(in oklab, var(--accent) 9%, var(--surface))' : 'var(--surface)',
      color: accent ? 'color-mix(in oklab, var(--accent) 75%, var(--ink))' : 'var(--ink)', whiteSpace: 'nowrap',
    }}>{children}</span>
  );
}

function ChipRow({ items, accent }) {
  return <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>{items.map((it, i) => <Chip key={i} accent={accent}>{it}</Chip>)}</div>;
}

function SectionLabel({ children, style }) {
  return <div className="smallcaps" style={{ marginBottom: 12, ...style }}>{children}</div>;
}

// ── Atlas map tab ───────────────────────────────────────────
function AtlasMapScreen({ states, favs, styleMode, holdLoading, onOpenOrigin, onOpenActivity, onOpenPassport, onToggleFav, onMarkTasted }) {
  const [loading, setLoading] = useStateAt(true);
  const [region, setRegion] = useStateAt('americas');
  const [peek, setPeek] = useStateAt(null);          // slug
  const [filterOpen, setFilterOpen] = useStateAt(false);
  const [filter, setFilter] = useStateAt('all');     // all | not-explored | discovered | lesson | tasted | favourites
  const prog = window.atlasProgress(states);

  useEffectAt(() => { if (holdLoading) return; const t = setTimeout(() => setLoading(false), 900); return () => clearTimeout(t); }, []);

  const matches = (o) => {
    if (filter === 'all') return true;
    if (filter === 'favourites') return favs.indexOf(o.slug) >= 0;
    return (states[o.slug] || 'not-explored') === filter;
  };
  const filtered = window.ATLAS_ORIGINS.filter(matches);
  const filterActive = filter !== 'all';
  const peekOrigin = peek ? window.atlasOrigin(peek) : null;

  return (
    <div className="screen" data-screen-label="Atlas · Map">
      {/* header */}
      <div className="px-24" style={{ paddingTop: 62, paddingBottom: 12 }}>
        <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12 }}>
          <div>
            <div className="smallcaps" style={{ marginBottom: 8 }}>COFFEE ATLAS</div>
            <h1 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.02, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>Origins of<br/>the world</h1>
          </div>
          <button onClick={() => setFilterOpen(true)} aria-label="Filter"
                  style={{ appearance: 'none', cursor: 'pointer', flexShrink: 0, width: 42, height: 42, borderRadius: 999, display: 'grid', placeItems: 'center',
                           border: '1px solid ' + (filterActive ? 'var(--accent)' : 'var(--rule)'), background: filterActive ? 'color-mix(in oklab, var(--accent) 12%, var(--surface))' : 'transparent' }}>
            <svg width="18" height="18" viewBox="0 0 20 20" style={{ color: filterActive ? 'var(--accent)' : 'var(--ink)' }}>
              <path d="M3 5h14M6 10h8M8.5 15h3" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/>
            </svg>
          </button>
        </div>

        {/* progress + passport */}
        <button onClick={onOpenPassport} style={{
          width: '100%', marginTop: 16, appearance: 'none', cursor: 'pointer', textAlign: 'left',
          display: 'grid', gridTemplateColumns: '1fr auto', alignItems: 'center', gap: 12,
          background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 12, padding: '11px 14px',
        }}>
          <div>
            <div className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.06em', color: 'var(--ink)', marginBottom: 7 }}>
              <strong style={{ color: 'var(--accent)' }}>{prog.explored}</strong> of {prog.total} origins explored
            </div>
            <div style={{ height: 5, background: 'var(--surface-2)', borderRadius: 999, overflow: 'hidden' }}>
              <div style={{ height: '100%', width: (prog.explored / prog.total * 100) + '%', background: 'var(--accent)', borderRadius: 999 }}/>
            </div>
          </div>
          <span style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.14em', textTransform: 'uppercase', color: 'var(--ink-mute)' }}>Passport</span>
            <window.Chevron opacity={1}/>
          </span>
        </button>
      </div>

      {/* map */}
      <div style={{ flex: 1, position: 'relative', borderTop: '1px solid var(--rule)' }}>
        <window.WorldMap origins={filtered} states={states} favs={favs} styleMode={styleMode}
                         loading={loading} activeRegion={region} selectedSlug={peek}
                         onRegionSettle={setRegion} onSelectOrigin={(o) => setPeek(o.slug)}/>

        {/* filter empty state */}
        {!loading && filtered.length === 0 && (
          <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', padding: 32, background: 'color-mix(in oklab, var(--bg) 86%, transparent)' }}>
            <svg width="40" height="40" viewBox="0 0 24 24" style={{ color: 'var(--ink-mute)', opacity: 0.6, marginBottom: 14 }}><circle cx="11" cy="11" r="7" fill="none" stroke="currentColor" strokeWidth="1.6"/><path d="M16 16l4 4" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/></svg>
            <p style={{ margin: 0, fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink-mute)', maxWidth: 250, textWrap: 'pretty' }}>
              No origins match this filter yet. Keep exploring the map to fill it in.
            </p>
            <button className="btn btn-ghost" style={{ width: 'auto', marginTop: 18, padding: '10px 20px' }} onClick={() => setFilter('all')}>Clear filter</button>
          </div>
        )}
      </div>

      {/* legend / filter status footer above tab bar */}
      <div style={{ flexShrink: 0, height: 84 }}/>

      {window.AtlasFilterSheet && <window.AtlasFilterSheet open={filterOpen} value={filter} counts={states} favs={favs}
                        onPick={(v) => { setFilter(v); setFilterOpen(false); }} onClose={() => setFilterOpen(false)}/>}

      <OriginPeekSheet origin={peekOrigin} state={peekOrigin ? (states[peekOrigin.slug] || 'not-explored') : null}
                       fav={peekOrigin ? favs.indexOf(peekOrigin.slug) >= 0 : false}
                       onOpen={() => { const slug = peek; setPeek(null); onOpenOrigin(slug); }}
                       onActivity={() => { const slug = peek; setPeek(null); onOpenActivity(slug); }}
                       onToggleFav={() => peekOrigin && onToggleFav(peekOrigin.slug)}
                       onTasted={() => peekOrigin && onMarkTasted(peekOrigin.slug)}
                       onClose={() => setPeek(null)}/>
    </div>
  );
}

// ── Origin peek sheet ───────────────────────────────────────
function OriginPeekSheet({ origin, state, fav, onOpen, onActivity, onToggleFav, onTasted, onClose }) {
  const open = !!origin;
  return (
    <>
      <div className={'sheet-backdrop' + (open ? ' open' : '')} onClick={onClose}/>
      <div className={'sheet' + (open ? ' open' : '')} style={{ maxHeight: '70%' }}>
        <div className="sheet-handle"/>
        <div className="sheet-content">
          {origin && (
            <>
              <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12 }}>
                <div style={{ minWidth: 0 }}>
                  <div className="smallcaps" style={{ color: 'var(--accent)', marginBottom: 7 }}>{window.ATLAS_REGIONS[origin.region].label}</div>
                  <h2 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.02, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>{origin.name}</h2>
                  <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 5 }}>{origin.tag}</div>
                </div>
                {window.FavButton && <window.FavButton active={fav} onClick={onToggleFav}/>}
              </div>

              <div style={{ marginTop: 14 }}><StateChip state={state}/></div>

              <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink)', margin: '16px 0 16px' }}>{origin.intro}</p>

              <div style={{ marginBottom: 18 }}>
                <SectionLabel style={{ marginBottom: 9 }}>OFTEN ASSOCIATED WITH</SectionLabel>
                <ChipRow items={origin.flavour.tags} accent/>
              </div>

              <button className="btn btn-primary" onClick={onOpen}>Open origin profile</button>
              <div style={{ display: 'flex', gap: 10, marginTop: 10 }}>
                <button className="btn btn-ghost" onClick={onActivity} style={{ flex: 1 }}>Try activity</button>
                <button className="btn btn-ghost" onClick={onTasted} style={{ flex: 1, color: state === 'tasted' ? 'var(--accent)' : 'var(--ink)', borderColor: state === 'tasted' ? 'var(--accent)' : 'var(--rule)' }}>
                  {state === 'tasted' ? '✓ Tasted' : 'I tasted this'}
                </button>
              </div>
            </>
          )}
        </div>
      </div>
    </>
  );
}

// ── Profile section blocks (shared by both layouts) ─────────
function ProfileSections({ origin, only }) {
  const wrap = (id, node) => (!only || only.indexOf(id) >= 0) ? node : null;
  return (
    <>
      {wrap('regions', (
        <Block key="regions" label="MAIN GROWING REGIONS">
          <ChipRow items={origin.growing}/>
        </Block>
      ))}
      {wrap('climate', (
        <Block key="climate" label="ALTITUDE AND CLIMATE">
          <div style={{ border: '1px solid var(--rule)', borderRadius: 12, overflow: 'hidden' }}>
            <DataRow k="Altitude" v={origin.altitude}/>
            <DataRow k="Climate" v={origin.climate} wrap/>
          </div>
        </Block>
      ))}
      {wrap('species', (
        <Block key="species" label="SPECIES AND VARIETIES">
          <div style={{ marginBottom: 10 }}><ChipRow items={origin.species} accent/></div>
          <ChipRow items={origin.varieties}/>
        </Block>
      ))}
      {wrap('processing', (
        <Block key="processing" label="PROCESSING TRADITIONS">
          <Body>{origin.processing}</Body>
        </Block>
      ))}
      {wrap('harvest', (
        <Block key="harvest" label="HARVEST PERIOD">
          <div style={{ border: '1px solid var(--rule)', borderRadius: 12, overflow: 'hidden' }}>
            <DataRow k="Typical harvest" v={origin.harvest} wrap/>
          </div>
        </Block>
      ))}
      {wrap('flavour', (
        <Block key="flavour" label="FLAVOUR TENDENCIES">
          <Body>{origin.flavour.note}</Body>
          <div style={{ marginTop: 12 }}><ChipRow items={origin.flavour.tags} accent/></div>
          <p className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.06em', color: 'var(--ink-mute)', margin: '12px 0 0', lineHeight: 1.5, textTransform: 'none' }}>
            Tendencies vary by farm, lot &amp; preparation — a guide, not a guarantee.
          </p>
        </Block>
      ))}
      {wrap('history', (
        <Block key="history" label="COFFEE HISTORY">
          <Body>{origin.history}</Body>
        </Block>
      ))}
      {wrap('sources', (
        <Block key="sources" label="SOURCES AND REVIEW">
          <div style={{ display: 'flex', flexDirection: 'column', gap: 7 }}>
            {origin.sources.map((s, i) => (
              <div key={i} style={{ display: 'flex', gap: 9, alignItems: 'flex-start' }}>
                <span style={{ width: 5, height: 5, borderRadius: 999, background: 'var(--ink-mute)', marginTop: 7, flexShrink: 0 }}/>
                <span style={{ fontSize: 'var(--t-support)', lineHeight: 1.45, color: 'var(--ink-mute)' }}>{s}</span>
              </div>
            ))}
          </div>
          <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--ink-mute)', marginTop: 14, paddingTop: 12, borderTop: '1px solid var(--rule)' }}>
            Last reviewed · {origin.reviewed}
          </div>
        </Block>
      ))}
    </>
  );
}

function Block({ label, children }) {
  return (
    <div style={{ marginBottom: 26 }}>
      <SectionLabel>{label}</SectionLabel>
      {children}
    </div>
  );
}
function Body({ children }) {
  return <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.6, color: 'var(--ink)', margin: 0, textWrap: 'pretty' }}>{children}</p>;
}
function DataRow({ k, v, wrap }) {
  return (
    <div style={{ display: 'grid', gridTemplateColumns: wrap ? '1fr' : 'auto 1fr', gap: wrap ? 4 : 16, alignItems: 'baseline', padding: '13px 15px', borderTop: '0' , borderBottom: 'none', background: 'var(--surface)', boxShadow: 'inset 0 -1px 0 var(--rule)' }}>
      <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.14em', textTransform: 'uppercase', color: 'var(--ink-mute)' }}>{k}</span>
      <span style={{ fontSize: 'var(--t-support)', color: 'var(--ink)', textAlign: wrap ? 'left' : 'right', lineHeight: 1.45 }}>{v}</span>
    </div>
  );
}

// ── Full origin profile ─────────────────────────────────────
const PROFILE_TABS = [
  { id: 'overview', label: 'Overview', sections: ['regions', 'climate'] },
  { id: 'coffee', label: 'The coffee', sections: ['species', 'processing', 'harvest', 'flavour'] },
  { id: 'story', label: 'Story', sections: ['history', 'sources'] },
];

function OriginProfile({ slug, state, fav, layout = 'scroll', states, favs, onActivity, onToggleFav, onMarkTasted, onClose }) {
  const origin = window.atlasOrigin(slug);
  const [tab, setTab] = useStateAt('overview');
  if (!origin) return null;
  const tabbed = layout === 'tabbed';
  const activeTab = PROFILE_TABS.find(t => t.id === tab) || PROFILE_TABS[0];
  const [tbScrolled, onTbScroll] = window.useScrollFlag();

  return (
    <div className="screen" data-screen-label="Atlas · Origin" style={{ background: 'var(--bg)' }}>
      <window.FloatTopbar scrolled={tbScrolled} onBack={onClose} back label="Back"
        right={window.FavButton ? <window.FavButton active={fav} onClick={() => onToggleFav(slug)}/> : null}/>

      <div className="scroll" onScroll={onTbScroll} style={{ paddingTop: 108, paddingBottom: 28 }}>
        {/* hero */}
        <div className="px-24">
          <div className="smallcaps" style={{ color: 'var(--accent)', marginBottom: 8 }}>{window.ATLAS_REGIONS[origin.region].label}</div>
          <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', gap: 12 }}>
            <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 0.98, letterSpacing: '-0.025em', margin: 0, color: 'var(--ink)' }}>{origin.name}</h1>
            <StateChip state={state}/>
          </div>
          <div style={{ fontSize: 'var(--t-body)', color: 'var(--ink-mute)', marginTop: 8 }}>{origin.tag}</div>
        </div>

        {/* locator */}
        <div className="px-24" style={{ paddingTop: 18 }}>
          <div style={{ height: 150, borderRadius: 12, overflow: 'hidden', border: '1px solid var(--rule)', position: 'relative' }}>
            <window.WorldMap origins={window.ATLAS_ORIGINS} states={states} favs={favs} styleMode="geo"
                             selectedSlug={slug} dimUnselected focusRegion={origin.region}/>
          </div>
        </div>

        {/* intro */}
        <div className="px-24" style={{ paddingTop: 20 }}>
          <p className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, lineHeight: 1.4, letterSpacing: '-0.01em', color: 'var(--ink)', margin: 0, textWrap: 'pretty' }}>{origin.intro}</p>
        </div>

        <hr className="rule" style={{ margin: '24px 24px' }}/>

        {tabbed ? (
          <>
            <div className="px-24" style={{ marginBottom: 22 }}>
              <div style={{ display: 'flex', gap: 4, background: 'var(--surface-2)', borderRadius: 999, padding: 4 }}>
                {PROFILE_TABS.map(t => (
                  <button key={t.id} onClick={() => setTab(t.id)} className="ff-ui" style={{
                    flex: 1, appearance: 'none', cursor: 'pointer', border: 'none', borderRadius: 999, padding: '9px 6px',
                    fontSize: 'var(--t-support)', fontWeight: 500, background: tab === t.id ? 'var(--accent)' : 'transparent',
                    color: tab === t.id ? 'var(--accent-ink)' : 'var(--ink-mute)',
                  }}>{t.label}</button>
                ))}
              </div>
            </div>
            <div className="px-24"><ProfileSections origin={origin} only={activeTab.sections}/></div>
          </>
        ) : (
          <div className="px-24"><ProfileSections origin={origin}/></div>
        )}

        {/* activity CTA */}
        <div className="px-24" style={{ paddingTop: 4 }}>
          <button onClick={() => onActivity(slug)} style={{
            width: '100%', appearance: 'none', cursor: 'pointer', textAlign: 'left',
            display: 'grid', gridTemplateColumns: 'auto 1fr auto', alignItems: 'center', gap: 14,
            background: 'color-mix(in oklab, var(--accent) 9%, var(--surface))',
            border: '1px solid color-mix(in oklab, var(--accent) 30%, var(--rule))', borderRadius: 14, padding: '16px 16px',
          }}>
            <span style={{ width: 44, height: 44, borderRadius: 12, display: 'grid', placeItems: 'center', background: 'var(--surface)', border: '1px solid var(--rule)', flexShrink: 0 }}>
              <svg width="22" height="22" viewBox="0 0 22 22" style={{ color: 'var(--accent)' }}><path d="M5 11l4 4 8-9" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"/></svg>
            </span>
            <span>
              <span className="smallcaps" style={{ color: 'var(--accent)', display: 'block', marginBottom: 3 }}>QUICK ACTIVITY</span>
              <span style={{ fontSize: 'var(--t-body)', color: 'var(--ink)', fontWeight: 500 }}>{state === 'not-explored' || state === 'discovered' ? 'Test what you learned' : 'Practise again'}</span>
            </span>
            <window.Chevron color="var(--accent)" opacity={1}/>
          </button>
        </div>

        {/* tasted action */}
        <div className="px-24" style={{ paddingTop: 14 }}>
          <button className="btn btn-ghost" onClick={() => onMarkTasted(slug)}
                  style={{ color: state === 'tasted' ? 'var(--accent)' : 'var(--ink)', borderColor: state === 'tasted' ? 'var(--accent)' : 'var(--rule)' }}>
            {state === 'tasted' ? '✓ Tasted · tap to remove' : 'Mark “I tasted this”'}
          </button>
        </div>
      </div>
    </div>
  );
}

// ── Region overview ─────────────────────────────────────────
function RegionScreen({ regionId, states, favs, onOpenOrigin, onClose }) {
  const region = window.ATLAS_REGIONS[regionId];
  const list = window.atlasByRegion(regionId);
  if (!region) return null;
  const prog = list.reduce((a, o) => a + (window.atlasRank(states[o.slug]) >= 1 ? 1 : 0), 0);
  const [tbScrolled, onTbScroll] = window.useScrollFlag();

  return (
    <div className="screen" data-screen-label="Atlas · Region" style={{ background: 'var(--bg)' }}>
      <window.FloatTopbar scrolled={tbScrolled} onBack={onClose} back label="Back"/>
      <div className="scroll" onScroll={onTbScroll} style={{ paddingTop: 108, paddingBottom: 28 }}>
        <div className="px-24">
          <div className="smallcaps" style={{ color: 'var(--accent)', marginBottom: 8 }}>REGION</div>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.02, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>{region.label}</h1>
          <div className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.08em', textTransform: 'uppercase', color: 'var(--ink-mute)', marginTop: 10 }}>{prog} of {list.length} explored</div>
          <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.6, color: 'var(--ink-mute)', margin: '16px 0 0', textWrap: 'pretty' }}>{region.blurb}</p>
        </div>

        <div className="px-24" style={{ paddingTop: 18 }}>
          <div style={{ height: 160, borderRadius: 12, overflow: 'hidden', border: '1px solid var(--rule)' }}>
            <window.WorldMap origins={list} states={states} favs={favs} styleMode="geo" focusRegion={regionId}/>
          </div>
        </div>

        <div className="px-24" style={{ paddingTop: 22 }}>
          {list.map((o, i) => (
            <button key={o.slug} onClick={() => onOpenOrigin(o.slug)} style={{
              width: '100%', appearance: 'none', cursor: 'pointer', textAlign: 'left',
              display: 'grid', gridTemplateColumns: '1fr auto', alignItems: 'center', gap: 12,
              padding: '16px 0', borderTop: i ? '1px solid var(--rule)' : 'none', background: 'transparent', border: 'none',
            }}>
              <div>
                <div style={{ fontSize: 'var(--t-body)', fontWeight: 500, color: 'var(--ink)' }}>{o.name}</div>
                <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 2 }}>{o.tag}</div>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                <StateChip state={states[o.slug] || 'not-explored'} size="sm"/>
                <window.Chevron opacity={1}/>
              </div>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}

window.AtlasMapScreen = AtlasMapScreen;
window.OriginProfile = OriginProfile;
window.RegionScreen = RegionScreen;
