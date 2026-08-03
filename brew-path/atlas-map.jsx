// atlas-map.jsx — the pannable Coffee Atlas world map.
//
// Stylised low-poly continents focused on the coffee belt. Pans horizontally
// across three regions (Americas · Africa · Asia). Three visual treatments are
// selectable via Tweaks: 'geo' (filled silhouette), 'dots' (stippled), and
// 'belt' (abstract equatorial band). Markers reflect exploration state.

const { useState: useStateM, useEffect: useEffectM, useRef: useRefM } = React;

// ── Continent geometry (viewBox 0 0 1000 560) ───────────────
// Hand-drawn coastlines: recognisable but softened to a field-guide style.
// Footprints are tuned so every origin marker (mx,my) lands on land.
const POLY = {
  americas: 'M124,116 C150,105 188,107 214,123 C231,134 233,156 230,178 C228,197 219,209 213,226 C208,240 205,251 214,263 C225,273 245,277 263,283 C301,295 345,305 367,333 C383,357 373,392 345,414 C323,430 296,432 280,416 C262,398 256,367 250,343 C242,313 226,299 208,289 C188,277 178,255 174,231 C170,205 162,176 156,156 C148,139 137,126 124,116 Z',
  africa: 'M500,150 C540,144 582,148 606,164 C613,153 629,151 641,162 C637,177 627,186 633,199 C645,207 654,223 650,245 C646,277 626,313 610,349 C598,379 580,415 558,417 C544,419 534,396 528,368 C520,336 508,306 498,278 C486,250 476,220 482,192 C488,168 494,158 500,150 Z',
  arabia: 'M613,150 C641,142 671,144 685,162 C693,176 687,196 671,206 C657,214 635,230 621,232 C611,224 607,208 607,190 C607,174 607,160 613,150 Z',
  asia: 'M686,150 C732,140 792,142 838,150 C884,156 920,162 932,184 C936,198 922,208 904,208 C892,208 882,208 876,218 C880,236 870,258 854,276 C846,286 838,274 838,256 C836,240 830,230 820,228 C810,226 804,236 802,250 C806,238 800,232 792,234 C786,250 778,266 766,272 C758,254 754,234 750,220 C742,236 732,242 722,240 C712,234 706,216 702,200 C696,182 690,166 686,150 Z',
};
// Indonesian archipelago — a chain of islands so it reads as a scatter.
const ISLANDS = [
  { cx: 830, cy: 345, rx: 30, ry: 8, rot: -16 },
  { cx: 872, cy: 364, rx: 17, ry: 6, rot: 8 },
  { cx: 896, cy: 333, rx: 14, ry: 11, rot: 0 },
  { cx: 918, cy: 351, rx: 8, ry: 6, rot: 0 },
  { cx: 806, cy: 327, rx: 11, ry: 6, rot: -32 },
];

// Tropic / equator guide lines in map-space y.
const LAT = { cancer: 168, equator: 300, capricorn: 432 };

function ContinentLayer({ styleMode }) {
  const land = 'var(--surface-2)';
  const edge = 'color-mix(in oklab, var(--ink) 16%, var(--rule))';
  const fill = styleMode === 'dots' ? 'url(#atlasDots)' : land;
  const show = styleMode !== 'belt';
  return (
    <>
      <defs>
        <pattern id="atlasDots" width="11" height="11" patternUnits="userSpaceOnUse">
          <rect width="11" height="11" fill="color-mix(in oklab, var(--surface-2) 55%, transparent)"/>
          <circle cx="3" cy="3" r="1.7" fill="color-mix(in oklab, var(--ink) 34%, transparent)"/>
        </pattern>
      </defs>

      {/* belt band — always present, stronger in 'belt' mode */}
      <rect x="0" y={LAT.cancer} width="1000" height={LAT.capricorn - LAT.cancer}
            fill="color-mix(in oklab, var(--accent) 7%, transparent)"/>
      <line x1="0" y1={LAT.cancer} x2="1000" y2={LAT.cancer} stroke="var(--rule)" strokeWidth="1" strokeDasharray="4 5"/>
      <line x1="0" y1={LAT.equator} x2="1000" y2={LAT.equator} stroke="color-mix(in oklab, var(--accent) 50%, var(--rule))" strokeWidth="1.4"/>
      <line x1="0" y1={LAT.capricorn} x2="1000" y2={LAT.capricorn} stroke="var(--rule)" strokeWidth="1" strokeDasharray="4 5"/>
      <text x="14" y={LAT.cancer - 7} fontSize="13" fill="var(--ink-mute)" fontFamily="IBM Plex Mono" letterSpacing="1">23.5°N · TROPIC OF CANCER</text>
      <text x="14" y={LAT.equator - 8} fontSize="13" fill="color-mix(in oklab, var(--accent) 70%, var(--ink-mute))" fontFamily="IBM Plex Mono" letterSpacing="1">0° · EQUATOR</text>
      <text x="14" y={LAT.capricorn + 18} fontSize="13" fill="var(--ink-mute)" fontFamily="IBM Plex Mono" letterSpacing="1">23.5°S · TROPIC OF CAPRICORN</text>

      {show && (
        <g stroke={edge} strokeWidth="1.4" strokeLinejoin="round" strokeLinecap="round">
          <path d={POLY.americas} fill={fill}/>
          <path d={POLY.africa} fill={fill}/>
          <path d={POLY.arabia} fill={fill}/>
          <path d={POLY.asia} fill={fill}/>
          {ISLANDS.map((is, i) => (
            <ellipse key={i} cx={is.cx} cy={is.cy} rx={is.rx} ry={is.ry} fill={fill}
                     transform={`rotate(${is.rot} ${is.cx} ${is.cy})`}/>
          ))}
        </g>
      )}

      {/* region name ghosts */}
      {show && (
        <g fontFamily="Fraunces" fontSize="19" fill="var(--ink-mute)" opacity="0.35" textAnchor="middle">
          <text x="250" y="470">The Americas</text>
          <text x="565" y="470">Africa and Arabia</text>
          <text x="838" y="430">Asia and the Pacific</text>
        </g>
      )}
    </>
  );
}

// ── Marker ──────────────────────────────────────────────────
function OriginMarker({ origin, state, fav, scale, selected, plain, dim, onTap, revealDelay }) {
  const meta = window.ATLAS_STATE_META[state] || window.ATLAS_STATE_META['not-explored'];
  const rank = meta.rank;
  const left = origin.mx * scale, top = origin.my * scale;

  // plain mode (locate activity): every marker looks identical and unexplored.
  const showLabel = !plain && (rank >= 1 || selected);
  const dotColor = plain ? 'var(--ink-mute)' : meta.color;
  const filled = !plain && rank >= 1;
  const size = selected ? 17 : (rank >= 2 ? 14 : 12);

  return (
    <button
      onClick={(e) => { e.stopPropagation(); onTap && onTap(origin); }}
      className="atlas-marker"
      style={{
        position: 'absolute', left, top, transform: 'translate(-50%,-50%)',
        appearance: 'none', border: 'none', background: 'transparent', cursor: 'pointer',
        padding: 8, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
        zIndex: selected ? 30 : (rank >= 1 ? 20 : 10),
        opacity: dim ? 0.5 : 1,
        animation: revealDelay != null ? `atlasPop 380ms cubic-bezier(.2,1.3,.4,1) ${revealDelay}ms both` : 'none',
      }}
      aria-label={plain ? 'Origin marker' : origin.name}>
      <span style={{ position: 'relative', width: size, height: size, display: 'block' }}>
        {selected && (
          <span style={{
            position: 'absolute', inset: -7, borderRadius: 999,
            border: '2px solid var(--accent)', animation: 'atlasRing 1.6s ease-out infinite',
          }}/>
        )}
        <span style={{
          position: 'absolute', inset: 0, borderRadius: 999,
          background: filled ? dotColor : 'var(--bg)',
          border: '2px solid ' + dotColor,
          boxShadow: filled ? '0 1px 4px color-mix(in oklab, var(--ink) 30%, transparent)' : 'none',
        }}/>
        {!plain && rank >= 3 && (
          <svg viewBox="0 0 12 12" style={{ position: 'absolute', inset: 0, width: '100%', height: '100%' }}>
            <path d="M3 6.2l2 2 4-4.4" fill="none" stroke="var(--accent-ink)" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        )}
        {!plain && fav && (
          <span style={{ position: 'absolute', top: -6, right: -7, width: 8, height: 8 }}>
            <svg viewBox="0 0 10 10" width="9" height="9"><path d="M5 9 L1.2 5 A2.3 2.3 0 0 1 5 2.2 A2.3 2.3 0 0 1 8.8 5 Z" fill="var(--berry)"/></svg>
          </span>
        )}
      </span>
      {showLabel && (
        <span className="ff-ui" style={{
          fontSize: 'var(--t-label)', fontWeight: 500, letterSpacing: '0.01em',
          color: selected ? 'var(--accent)' : 'var(--ink)',
          background: 'color-mix(in oklab, var(--bg) 82%, transparent)',
          padding: '1px 5px', borderRadius: 2, whiteSpace: 'nowrap',
          boxShadow: '0 1px 0 color-mix(in oklab, var(--ink) 8%, transparent)',
        }}>{origin.name}</span>
      )}
    </button>
  );
}

// ── World map (pannable) ────────────────────────────────────
function WorldMap({
  origins, states, favs, styleMode = 'geo', loading = false,
  activeRegion = null, focusRegion = null, selectedSlug = null,
  plain = false, dimUnselected = false,
  onSelectOrigin, onRegionSettle,
}) {
  const wrapRef = useRefM(null);
  const [box, setBox] = useStateM({ w: 393, h: 520 });
  const [tx, setTx] = useStateM(0);
  const drag = useRefM({ active: false, startX: 0, startTx: 0, moved: 0 });

  // Measure viewport.
  useEffectM(() => {
    const el = wrapRef.current; if (!el) return;
    const measure = () => setBox({ w: el.clientWidth, h: el.clientHeight });
    measure();
    const ro = new ResizeObserver(measure); ro.observe(el);
    return () => ro.disconnect();
  }, []);

  const scale = box.h / window.ATLAS_MAP.h;           // fit to height
  const scaledW = window.ATLAS_MAP.w * scale;
  const minTx = Math.min(0, box.w - scaledW);
  const clamp = (x) => Math.max(minTx, Math.min(0, x));

  // Center a region by its cx.
  const centerOn = (cx) => clamp(box.w / 2 - cx * scale);

  // Initial / programmatic focus.
  useEffectM(() => {
    if (loading) return;
    const r = focusRegion && window.ATLAS_REGIONS[focusRegion];
    setTx(r ? centerOn(r.cx) : clamp(box.w / 2 - 235 * scale));
    // eslint-disable-next-line
  }, [focusRegion, box.w, box.h, loading]);

  // Which region is centered now (for the chip highlight).
  useEffectM(() => {
    if (!onRegionSettle || scaledW <= 0) return;
    const centerX = (box.w / 2 - tx) / scale;
    let best = null, bestD = Infinity;
    Object.values(window.ATLAS_REGIONS).forEach(r => {
      const d = Math.abs(r.cx - centerX);
      if (d < bestD) { bestD = d; best = r.id; }
    });
    onRegionSettle(best);
    // eslint-disable-next-line
  }, [tx, scale]);

  // Pointer drag.
  const onDown = (e) => {
    const x = e.touches ? e.touches[0].clientX : e.clientX;
    drag.current = { active: true, startX: x, startTx: tx, moved: 0 };
  };
  const onMove = (e) => {
    if (!drag.current.active) return;
    const x = e.touches ? e.touches[0].clientX : e.clientX;
    const dx = x - drag.current.startX;
    drag.current.moved = Math.max(drag.current.moved, Math.abs(dx));
    setTx(clamp(drag.current.startTx + dx));
  };
  const onUp = () => { drag.current.active = false; };

  const jumpTo = (rid) => {
    const r = window.ATLAS_REGIONS[rid]; if (!r) return;
    setTx(centerOn(r.cx));
  };

  // Stagger reveal order: explored first.
  const order = origins
    .map((o, i) => ({ o, rank: window.atlasRank(states[o.slug]) }))
    .sort((a, b) => b.rank - a.rank);

  return (
    <div style={{ position: 'relative', width: '100%', height: '100%', overflow: 'hidden', background: 'var(--bg)' }}>
      <style>{`
        @keyframes atlasPop { from { transform: translate(-50%,-50%) scale(.55);} 60%{ transform: translate(-50%,-50%) scale(1.08);} to { transform: translate(-50%,-50%) scale(1);} }
        @keyframes atlasRing { 0%{transform:scale(.8);opacity:.9} 100%{transform:scale(1.7);opacity:0} }
        @keyframes atlasShimmer { 0%{opacity:.4} 50%{opacity:.7} 100%{opacity:.4} }
        .atlas-marker:active { transform: translate(-50%,-50%) scale(.92) !important; }
      `}</style>

      {/* region quick-jump chips */}
      {!plain && (
        <div style={{
          position: 'absolute', top: 12, left: 0, right: 0, zIndex: 60,
          display: 'flex', justifyContent: 'center', gap: 6, pointerEvents: 'none',
        }}>
          {Object.values(window.ATLAS_REGIONS).map(r => {
            const on = activeRegion === r.id;
            return (
              <button key={r.id} onClick={() => jumpTo(r.id)} style={{
                pointerEvents: 'auto', appearance: 'none', cursor: 'pointer',
                fontFamily: 'IBM Plex Mono, monospace', fontSize: 'var(--t-micro)', letterSpacing: '0.12em',
                textTransform: 'uppercase', padding: '7px 11px', borderRadius: 999,
                border: '1px solid ' + (on ? 'var(--accent)' : 'var(--rule)'),
                background: on ? 'var(--accent)' : 'color-mix(in oklab, var(--bg) 80%, transparent)',
                color: on ? 'var(--accent-ink)' : 'var(--ink-mute)',
                backdropFilter: 'blur(6px)',
              }}>{r.short || r.label.split(' ')[0]}</button>
            );
          })}
        </div>
      )}

      <div
        ref={wrapRef}
        onMouseDown={onDown} onMouseMove={onMove} onMouseUp={onUp} onMouseLeave={onUp}
        onTouchStart={onDown} onTouchMove={onMove} onTouchEnd={onUp}
        style={{ position: 'absolute', inset: 0, cursor: drag.current.active ? 'grabbing' : 'grab', touchAction: 'pan-y' }}>

        <div style={{
          position: 'absolute', top: 0, left: 0, width: scaledW, height: box.h,
          transform: `translateX(${tx}px)`,
          transition: drag.current.active ? 'none' : 'transform 520ms cubic-bezier(.2,.8,.2,1)',
        }}>
          <svg width={scaledW} height={box.h} viewBox={`0 0 ${window.ATLAS_MAP.w} ${window.ATLAS_MAP.h}`}
               style={{ display: 'block', opacity: loading ? 0.5 : 1, animation: loading ? 'atlasShimmer 1.1s ease-in-out infinite' : 'none' }}>
            <ContinentLayer styleMode={styleMode}/>
          </svg>

          {!loading && origins.map((o) => {
            const idx = order.findIndex(x => x.o.slug === o.slug);
            return (
              <OriginMarker key={o.slug} origin={o} scale={scale}
                state={states[o.slug] || 'not-explored'}
                fav={favs && favs.indexOf(o.slug) >= 0}
                selected={selectedSlug === o.slug}
                plain={plain}
                dim={dimUnselected && selectedSlug && selectedSlug !== o.slug}
                revealDelay={40 + idx * 35}
                onTap={onSelectOrigin}/>
            );
          })}
        </div>
      </div>

      {/* drag affordance */}
      {!plain && !loading && (
        <div className="ff-mono" style={{
          position: 'absolute', bottom: 10, left: 0, right: 0, textAlign: 'center',
          fontSize: 'var(--t-micro)', letterSpacing: '0.18em', textTransform: 'uppercase',
          color: 'var(--ink-mute)', opacity: 0.6, pointerEvents: 'none',
        }}>‹ drag to explore ›</div>
      )}

      {loading && (
        <div style={{
          position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center', gap: 14, pointerEvents: 'none',
        }}>
          <svg width="30" height="30" viewBox="0 0 24 24" style={{ animation: 'atlasSpin 1s linear infinite' }}>
            <circle cx="12" cy="12" r="9" fill="none" stroke="var(--rule)" strokeWidth="2.4"/>
            <path d="M12 3 a9 9 0 0 1 9 9" fill="none" stroke="var(--accent)" strokeWidth="2.4" strokeLinecap="round"/>
          </svg>
          <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.18em', textTransform: 'uppercase', color: 'var(--ink-mute)' }}>Charting origins…</div>
          <style>{`@keyframes atlasSpin{to{transform:rotate(360deg)}}`}</style>
        </div>
      )}
    </div>
  );
}

window.WorldMap = WorldMap;
window.ContinentLayer = ContinentLayer;
