// Coffee bean icon — replaces the old wedge wheel.
// Same API: filled/total drives a bottom-up fill of the bean shape.

// ── Shared icon-weight tokens ────────────────────────────────
// ONE source of truth for stroke weight across the whole icon family, so the
// weight can never drift again. GLYPH_STROKE is the primary outline weight for
// every 24×24 concept glyph (nav, duel types, dictionary categories).
window.GLYPH_STROKE = 1.6;

function FlavorWheel({ size = 20, filled = 0, total = 6, color, mute, ring = true, rotate = 0, stroke = 1.8, crease }) {
  const c = color || 'var(--accent)';
  const m = mute || 'var(--ink-mute)';
  const pct = Math.max(0, Math.min(1, filled / total));
  const isFull = pct >= 1;
  const id = React.useMemo(() => 'cb-' + Math.random().toString(36).slice(2, 9), []);
  // viewBox is fixed at 24×24 so all sizes share one geometry
  // Bean: tilted oval ~ rx 7.5, ry 9.5, rotated -18deg around center.
  const beanTransform = `rotate(-18 12 12)`;
  // Crease colour. When the bean is full it would otherwise read as a solid
  // accent blob, so the centre crease flips to a light "carved groove"
  // (surface colour) that stays legible over the fill — keeping the coffee-bean
  // silhouette obvious in the pressed/selected state.
  const creaseColor = isFull ? (crease || 'var(--ink)') : (pct > 0.6 ? 'var(--ink)' : m);
  return (
    <svg width={size} height={size} viewBox="0 0 24 24"
         style={{ transform: `rotate(${rotate}deg)`, display: 'block', flexShrink: 0 }}>
      <defs>
        <clipPath id={id}>
          <ellipse cx="12" cy="12" rx="7.5" ry="9.5" transform={beanTransform}/>
        </clipPath>
      </defs>
      {/* fill, clipped to the bean and grown from the bottom up via a scaleY
          transform so unpressed→pressed animates smoothly rather than snapping. */}
      <g clipPath={`url(#${id})`}>
        <rect x="0" y="0" width="24" height="24" fill={c}
              style={{
                transformBox: 'fill-box', transformOrigin: '50% 100%',
                transform: `scaleY(${pct})`,
                transition: 'transform 300ms cubic-bezier(.34,1.18,.5,1)',
              }}/>
      </g>
      {/* outline — stays a dark ink line even when full, so the bean silhouette
          never dissolves into a same-color fill */}
      <ellipse cx="12" cy="12" rx="7.5" ry="9.5" transform={beanTransform}
               fill="none" stroke={isFull ? 'var(--ink)' : m} strokeWidth={stroke}
               style={{ transition: 'stroke 220ms ease' }}/>
      {/* center crease — wavy line; becomes a light groove when full */}
      <path d="M12 3.5 C 13.5 7, 10.5 9, 12 12 S 13.5 17, 12 20.5"
            transform={beanTransform}
            fill="none" stroke={creaseColor}
            strokeWidth={stroke * (isFull ? 1.15 : 0.9)} strokeLinecap="round"
            style={{
              opacity: isFull ? 1 : (pct > 0.6 ? 0.85 : 1),
              transition: 'stroke 220ms ease, stroke-width 220ms ease, opacity 220ms ease',
            }}/>
    </svg>
  );
}

// ROAST METER — position inside a run of questions (lesson mini-games, duel
// rounds, flashcards, vocab). One solid bean that ROASTS as you advance: raw
// green at the first question, espresso at the last. It has no fill state at
// all, so it can never be read as the mastery gauge — this is where you are,
// not how well you did. Roast colours are literal coffee, so they are the same
// in both moods, like the illustration fills.
// Kept as hex because roastAt() interpolates between the stops — these are the
// literal values of --art-raw / --art-roast-light / -mid / -deep / -dark.
const ROAST_RAMP = ['#9FB088', '#C79A63', '#A2703C', '#7A4526', '#54301C'];
function roastAt(t) {
  const p = Math.max(0, Math.min(1, t)) * (ROAST_RAMP.length - 1);
  const i = Math.min(ROAST_RAMP.length - 2, Math.floor(p));
  const f = p - i;
  const hex = (s) => [1, 3, 5].map(k => parseInt(s.slice(k, k + 2), 16));
  const a = hex(ROAST_RAMP[i]), b = hex(ROAST_RAMP[i + 1]);
  return '#' + a.map((v, k) => Math.round(v + (b[k] - v) * f).toString(16).padStart(2, '0')).join('');
}
function RoastBean({ done = 0, total = 0, size = 22 }) {
  if (!total) return null;
  const t = Math.max(0, Math.min(total, done)) / total;
  const fill = roastAt(t);
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" style={{ display: 'block', flexShrink: 0 }} aria-hidden="true">
      <g transform="rotate(-18 12 12)">
        <ellipse cx="12" cy="12" rx="7.5" ry="9.5" fill={fill}
                 style={{ transition: 'fill 420ms cubic-bezier(.34,1.18,.5,1)' }}/>
        <ellipse cx="12" cy="12" rx="7.5" ry="9.5" fill="none" stroke="var(--ink-mute)" strokeWidth="1"/>
        <path d="M12 3.5 C 13.5 7, 10.5 9, 12 12 S 13.5 17, 12 20.5"
              fill="none" stroke="#FBF7EE" strokeOpacity="0.34" strokeWidth="1.5" strokeLinecap="round"/>
      </g>
    </svg>
  );
}
window.RoastBean = RoastBean;
window.roastAt = roastAt;

// POINTS MARK — the currency bean. A solid silhouette with a carved crease and
// NO fill state: points are a quantity, not a level, so this mark can never be
// mistaken for the mastery gauge above (whose whole meaning is how full it is).
function PointsBean({ size = 18, color = 'var(--accent)', crease = 'var(--surface)' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" style={{ display: 'block', flexShrink: 0 }} aria-hidden="true">
      <g transform="rotate(-18 12 12)">
        <ellipse cx="12" cy="12" rx="7.5" ry="9.5" fill={color}/>
        <path d="M12 3.5 C 13.5 7, 10.5 9, 12 12 S 13.5 17, 12 20.5"
              fill="none" stroke={crease} strokeWidth="1.9" strokeLinecap="round"/>
      </g>
    </svg>
  );
}
window.PointsBean = PointsBean;

// Larger stamp version — used on collection cards + completion screen.
// Circular hand-stamp framing with a coffee bean centered inside.
function FlavorStamp({ size = 96, rotate = -8 }) {
  const r = size / 2;
  const cx = r, cy = r;
  const Rout = r - 2;
  const Rin  = Rout - 8;

  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}
         style={{ transform: `rotate(${rotate}deg)`, display: 'block' }}>
      <circle cx={cx} cy={cy} r={Rout} fill="none" stroke="var(--accent)" strokeWidth="1.4"/>
      <circle cx={cx} cy={cy} r={Rin}  fill="none" stroke="var(--accent)" strokeWidth="0.8" opacity="0.5"/>
      {/* coffee bean: oval + wavy crease */}
      <g transform={`translate(${cx} ${cy}) rotate(-18)`}>
        <ellipse cx="0" cy="0" rx={Rin * 0.55} ry={Rin * 0.78}
                 fill="var(--accent)" fillOpacity="0.85"
                 stroke="var(--accent)" strokeWidth="1"/>
        <path d={`M 0 ${-Rin * 0.7} C ${Rin * 0.18} ${-Rin * 0.35}, ${-Rin * 0.18} ${-Rin * 0.05}, 0 0 S ${Rin * 0.18} ${Rin * 0.35}, 0 ${Rin * 0.7}`}
              fill="none" stroke="var(--surface)" strokeOpacity="0.6"
              strokeWidth="1.4" strokeLinecap="round"/>
      </g>
    </svg>
  );
}

// Stylized coffee tree — small mark used on welcome (echoes landing-page hero)
function CoffeeTree({ size = 120 }) {
  return (
    <svg width={size} height={size * 1.15} viewBox="0 0 120 138" style={{ display: 'block' }}>
      <path d="M60 138 Q60 110 60 80 Q58 60 56 40 Q55 28 54 18"
            fill="none" stroke="var(--ink)" strokeWidth="1.6" strokeLinecap="round"/>
      <path d="M56 40 Q40 36 24 30" fill="none" stroke="var(--ink)" strokeWidth="1.2" strokeLinecap="round"/>
      <path d="M58 60 Q42 58 26 56" fill="none" stroke="var(--ink)" strokeWidth="1.2" strokeLinecap="round"/>
      <path d="M60 80 Q46 80 30 86" fill="none" stroke="var(--ink)" strokeWidth="1.2" strokeLinecap="round"/>
      <path d="M55 28 Q70 24 86 18" fill="none" stroke="var(--ink)" strokeWidth="1.2" strokeLinecap="round"/>
      <path d="M57 50 Q74 48 90 46" fill="none" stroke="var(--ink)" strokeWidth="1.2" strokeLinecap="round"/>
      <path d="M59 70 Q76 70 92 76" fill="none" stroke="var(--ink)" strokeWidth="1.2" strokeLinecap="round"/>
      {[
        [22, 28], [26, 54], [30, 84], [88, 16], [92, 44], [94, 74],
        [40, 34], [44, 56], [48, 84], [72, 22], [78, 48], [82, 72],
      ].map(([x, y], i) => (
        <ellipse key={'l' + i} cx={x} cy={y} rx="6.5" ry="2.4"
                 transform={`rotate(${(i % 2 === 0 ? -28 : 28)} ${x} ${y})`}
                 fill="none" stroke="var(--ink)" strokeWidth="1"/>
      ))}
      {[
        [20, 30], [28, 56], [32, 86], [86, 18], [94, 46], [92, 74],
      ].map(([x, y], i) => (
        <circle key={'c' + i} cx={x} cy={y} r="2.2" fill="var(--accent)"/>
      ))}
    </svg>
  );
}

// CoffeePersona — your tree, painted as a hand-illustrated PNG that
// advances through 10 growth stages as you earn points.
//   1 sprout · 2 small sprout · 3 sapling-with-flowerbuds · 4 sapling-fruit
//   5 yellow-green cherries · 6 mid bush yellow · 7 yellow-orange
//   8 orange · 9 red · 10 deep-red full canopy
window.STAGE_NAMES = [
  'SEED', 'SPROUT', 'SAPLING', 'BUDDING', 'FLOWERING',
  'GREEN CHERRY', 'TURNING', 'RIPENING', 'NEAR HARVEST', 'HARVEST',
];
function CoffeePersona({ stage = 1, size = 200, animate = true, withGround = true, treatment, shape }) {
  // Stage 1..10 (1-indexed for human alignment with the asset filenames).
  const s = Math.max(1, Math.min(10, stage || 1));
  const _treat = treatment != null ? treatment : ((window.TREE_CONFIG || {}).treatment || '');
  // Silhouette differs per botanical variety. Held on a wrapper so it can't
  // fight the sway animation, which owns transform on the img itself.
  const _shape = shape != null ? shape : ((window.TREE_CONFIG || {}).shape || '');
  return (
    <div style={{
      width: size, height: size, display: 'flex',
      alignItems: 'center', justifyContent: 'center',
      transformOrigin: '50% 80%',
      position: 'relative',
    }}>
      <style>{`
        @keyframes personaSway { 0%,100% { transform: rotate(-0.8deg); } 50% { transform: rotate(0.8deg); } }
        @keyframes personaFade { from { opacity: 0; transform: scale(0.96); } to { opacity: 1; transform: scale(1); } }
        .persona-img { animation: personaFade 360ms ease-out both${animate ? ', personaSway 6s ease-in-out infinite 360ms' : ''}; transform-origin: 50% 86%; }
        .persona-ground {
          position: absolute; inset: 0; pointer-events: none;
          background: radial-gradient(ellipse at 50% 62%,
            color-mix(in oklab, var(--surface) 96%, var(--accent) 4%) 0%,
            color-mix(in oklab, var(--surface) 60%, transparent) 38%,
            transparent 64%);
          border-radius: 999px;
        }
      `}</style>
      {withGround && <div className="persona-ground"/>}
      <div style={{ width: '100%', height: '100%', transform: _shape || 'none', transformOrigin: '50% 86%' }}>
      <img key={s}
           className="persona-img"
           src={`assets/trees/${s}.png`}
           alt={`Coffee tree, stage ${s}`}
           style={{
             width: '100%', height: '100%', objectFit: 'contain',
             display: 'block', position: 'relative',
             filter: _treat || 'none',
           }}/>
      </div>
    </div>
  );
}

// Helper: a stage frame that fades + lifts in via class toggle so we sidestep
// CSS-animation timing quirks (animation `both` was holding the FROM state).
function AnimatedStage({ stageNum, treatment }) {
  const [shown, setShown] = React.useState(false);
  React.useEffect(() => {
    setShown(false);
    // Use a timer so React's render commit happens before the class flip
    // (rAF was being cancelled before firing in some flow combinations).
    const t = setTimeout(() => setShown(true), 30);
    return () => clearTimeout(t);
  }, [stageNum]);
  return (
    <div className={'at-stage' + (shown ? ' shown' : '')}>
      <img src={`assets/trees/${stageNum}.png`} alt="" style={{ filter: treatment || 'none' }}/>
    </div>
  );
}

// AnimatedTree — animates from one growth stage to another with overlapping
// crossfades, a final soft bounce, an expanding glow ring, and drifting leaf
// particles. Mounts and self-runs on first render; calls onDone when finished.
function AnimatedTree({ fromStage = 1, toStage = 2, size = 240, onDone, delay = 250, treatment }) {
  const [step, setStep] = React.useState(0); // 0..(stages.length-1)
  const [bounced, setBounced] = React.useState(false);
  const [showParticles, setShowParticles] = React.useState(false);

  const from = Math.max(1, Math.min(10, fromStage));
  const to   = Math.max(1, Math.min(10, toStage));
  const stages = React.useMemo(() => {
    if (to <= from) return [from];
    const seq = [];
    for (let i = from; i <= to; i++) seq.push(i);
    return seq;
  }, [from, to]);

  // Slot each stage swap. If we have 1 stage there's no transition, just bounce.
  React.useEffect(() => {
    let cancelled = false;
    const swaps = Math.max(0, stages.length - 1);
    const perSwap = swaps > 0 ? Math.min(420, 1100 / swaps) : 0;
    const timers = [];
    timers.push(setTimeout(() => {
      if (cancelled) return;
      // Run swap sequence
      stages.forEach((_, i) => {
        if (i === 0) return;
        timers.push(setTimeout(() => !cancelled && setStep(i), i * perSwap));
      });
      // After last swap, bounce + particles + glow + onDone
      const total = swaps * perSwap;
      timers.push(setTimeout(() => !cancelled && setBounced(true), total));
      timers.push(setTimeout(() => !cancelled && setShowParticles(true), total + 80));
      timers.push(setTimeout(() => !cancelled && onDone && onDone(), total + 900));
    }, delay));
    return () => { cancelled = true; timers.forEach(clearTimeout); };
  }, []);

  const current = stages[step];

  return (
    <div style={{
      position: 'relative', width: size, height: size,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      <style>{`
        @keyframes treeGlow {
          0%   { opacity: 0; transform: scale(0.6); }
          40%  { opacity: 0.8; }
          100% { opacity: 0; transform: scale(2.2); }
        }
        @keyframes treeBounce {
          0%   { transform: scale(0.85); }
          55%  { transform: scale(1.06); }
          80%  { transform: scale(0.98); }
          100% { transform: scale(1); }
        }
@keyframes leafDrift {
          0%   { opacity: 0; transform: translate(0,0) rotate(0deg); }
          15%  { opacity: 1; }
          100% { opacity: 0; transform: translate(var(--lx), var(--ly)) rotate(var(--lr)); }
        }
        .at-ground {
          position: absolute; inset: 0; border-radius: 999px;
          background: radial-gradient(ellipse at 50% 62%,
            color-mix(in oklab, var(--surface) 96%, var(--accent) 4%) 0%,
            color-mix(in oklab, var(--surface) 70%, transparent) 40%,
            transparent 66%);
          pointer-events: none;
        }
        .at-stage { position: absolute; inset: 0; display:flex; align-items:center; justify-content:center;
          opacity: 0; transform: translateY(8px) scale(0.94); transform-origin: 50% 86%;
          transition: opacity 360ms ease-out, transform 360ms cubic-bezier(0.2, 0.9, 0.3, 1.0);
        }
        .at-stage.shown { opacity: 1; transform: translateY(0) scale(1); }
        .at-stage img { width: 100%; height: 100%; object-fit: contain; display: block; }
        .at-bounce { animation: treeBounce 600ms cubic-bezier(0.2, 1.4, 0.4, 1.0) both; transform-origin: 50% 86%; }
        .at-glow {
          position: absolute; inset: 8%; border-radius: 999px;
          background: radial-gradient(circle, color-mix(in oklab, var(--accent) 45%, transparent) 0%, transparent 70%);
          animation: treeGlow 900ms ease-out both;
          pointer-events: none;
        }
        .at-leaf { position: absolute; left: 50%; top: 30%; width: 12px; height: 5px;
          border-radius: 60% 40% 60% 40% / 100% 100% 0 0;
          background: var(--sage); animation: leafDrift 1200ms ease-out both; opacity: 0;
          transform-origin: 0 100%; pointer-events: none; }
      `}</style>

      <div className="at-ground"/>
      {bounced && <div className="at-glow"/>}

      <div className={bounced ? 'at-bounce' : ''} style={{ width: '100%', height: '100%', position: 'relative' }}>
        <AnimatedStage stageNum={current} treatment={treatment != null ? treatment : ((window.TREE_CONFIG || {}).treatment || '')}/>
      </div>

      {showParticles && Array.from({ length: 7 }).map((_, i) => {
        const angle = (i / 7) * Math.PI * 2 + 0.3;
        const dist = 70 + Math.random() * 50;
        const lx = Math.cos(angle) * dist;
        const ly = Math.sin(angle) * dist - 30;
        const lr = (Math.random() * 360 - 180) + 'deg';
        return (
          <span key={i} className="at-leaf" style={{
            '--lx': lx + 'px', '--ly': ly + 'px', '--lr': lr,
            animationDelay: (i * 60) + 'ms',
            background: i % 3 === 0 ? 'var(--accent)' : 'var(--sage)',
            width: i % 3 === 0 ? 6 : 12,
            height: i % 3 === 0 ? 6 : 5,
            borderRadius: i % 3 === 0 ? '999px' : '60% 40% 60% 40% / 100% 100% 0 0',
          }}/>
        );
      })}
    </div>
  );
}

window.FlavorWheel = FlavorWheel;
window.FlavorStamp = FlavorStamp;
window.CoffeeTree = CoffeeTree;
window.CoffeePersona = CoffeePersona;
window.AnimatedTree = AnimatedTree;

// ───────────────────────────────────────────────────────────────
// Tab icons — one shape per tab, each coffee-vocabulary aware.
// Filled in accent when active, otherwise outlined in ink-mute.
// All share viewBox 24×24 and stroke 1.6 so the set reads as a family.
// ───────────────────────────────────────────────────────────────
function IconCup({ size = 24, active, color = 'var(--accent)', mute = 'var(--ink-mute)' }) {
  const stroke = active ? color : mute;
  const fill   = active ? color : 'none';
  const steam  = active ? color : mute;
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={{ flexShrink: 0 }}>
      <path d="M9 3 Q10 4.5 9 6 Q8 7.5 9 9"  stroke={steam} strokeWidth="1.4" strokeLinecap="round" opacity={active ? '0.55' : '0.85'}/>
      <path d="M12 3 Q13 4.5 12 6 Q11 7.5 12 9" stroke={steam} strokeWidth="1.4" strokeLinecap="round" opacity={active ? '0.55' : '0.85'}/>
      <path d="M15 3 Q16 4.5 15 6 Q14 7.5 15 9" stroke={steam} strokeWidth="1.4" strokeLinecap="round" opacity={active ? '0.55' : '0.85'}/>
      <path d="M5 10.5 L19 10.5 L18 19 Q17.5 20.5 16 20.5 L8 20.5 Q6.5 20.5 6 19 Z"
            fill={fill} stroke={stroke} strokeWidth="1.6" strokeLinejoin="round"/>
      <path d="M19 12.5 Q22 12.5 22 15.5 Q22 18 19 18"
            fill="none" stroke={stroke} strokeWidth="1.6" strokeLinecap="round"/>
    </svg>
  );
}

function IconRoute({ size = 24, active, color = 'var(--accent)', mute = 'var(--ink-mute)' }) {
  const c    = active ? color : mute;
  const fill = active ? color : 'var(--surface)';
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={{ flexShrink: 0 }}>
      <path d="M4 20 Q8 18 9 14 Q10 8 14 7 Q18 6 20 4"
            stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeDasharray="0.1 3.4"/>
      <circle cx="4" cy="20" r="2.1" fill={fill} stroke={c} strokeWidth="1.6"/>
      <circle cx="10" cy="13" r="2.1" fill={fill} stroke={c} strokeWidth="1.6"/>
      <circle cx="20" cy="4"  r="2.4" fill={active ? color : fill} stroke={c} strokeWidth="1.6"/>
    </svg>
  );
}

function IconCards({ size = 24, active, color = 'var(--accent)', mute = 'var(--ink-mute)' }) {
  const c    = active ? color : mute;
  const fill = active ? color : 'none';
  const innerStroke = active ? 'var(--accent-ink)' : c;
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={{ flexShrink: 0 }}>
      <rect x="5" y="6" width="11" height="14" rx="1.6"
            transform="rotate(-8 10.5 13)"
            fill={active ? 'var(--surface-2)' : 'none'} stroke={c} strokeWidth="1.6"/>
      <rect x="8" y="5" width="11" height="14" rx="1.6"
            fill={fill} stroke={c} strokeWidth="1.6"/>
      <ellipse cx="13.5" cy="12" rx="1.7" ry="2.4"
               transform="rotate(-18 13.5 12)"
               fill="none" stroke={innerStroke} strokeWidth="1.3"/>
    </svg>
  );
}

function IconLeaf({ size = 24, active, color = 'var(--accent)', mute = 'var(--ink-mute)' }) {
  const c    = active ? color : mute;
  const fill = active ? color : 'none';
  const vein = active ? 'var(--accent-ink)' : c;
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={{ flexShrink: 0 }}>
      {/* leaf: pointed at top-right, rounded at bottom-left */}
      <path d="M20 4 Q20 13 14 18 Q9 21 6 19 Q3 16 5 11 Q9 5 20 4 Z"
            fill={fill} stroke={c} strokeWidth="1.6" strokeLinejoin="round"/>
      <path d="M20 4 L7 18" stroke={vein} strokeWidth="1.2" strokeLinecap="round" opacity="0.75"/>
      <path d="M14 9 L11 11" stroke={vein} strokeWidth="1" strokeLinecap="round" opacity="0.6"/>
      <path d="M12 13 L8.5 14.5" stroke={vein} strokeWidth="1" strokeLinecap="round" opacity="0.6"/>
    </svg>
  );
}

// One padlock for the whole app: module headers, lesson rows, brew rows.
// Row locks are always muted ink at hairline weight; gating.jsx's LockGlyph
// is the larger accent-tinted variant used inside paywall affordances.
function LockMark({ size = 14, color = 'var(--ink-mute)', sw = 1.4, label }) {
  return (
    <svg width={size} height={size * 15 / 13} viewBox="0 0 13 15" fill="none"
         aria-hidden={label ? undefined : 'true'} aria-label={label || undefined}>
      <rect x="1" y="6" width="11" height="8" rx="1.5" fill="none" stroke={color} strokeWidth={sw}/>
      <path d="M3.5 6V4a3 3 0 0 1 6 0v2" fill="none" stroke={color} strokeWidth={sw} strokeLinecap="round"/>
    </svg>
  );
}
window.LockMark = LockMark;

// The rest of the chrome family. Same rule as the lock: ONE definition, so a
// stroke weight or an opacity can never drift between screens again.
//   Chevron  — trailing "drill in" affordance on a tappable row
//   BackMark — returns up a level, in a top bar
//   CloseMark— dismisses a lesson, game or sheet
//   CheckMark— correct / learned / done. Always sage.
function Chevron({ w = 8, h = 14, color = 'var(--ink-mute)', opacity = 0.7 }) {
  return (
    <svg width={w} height={h} viewBox="0 0 8 14" style={{ flexShrink: 0 }} aria-hidden="true">
      <path d="M1 1l6 6-6 6" fill="none" stroke={color} strokeOpacity={opacity}
            strokeWidth="1.5" strokeLinecap="round"/>
    </svg>
  );
}
// ArrowMark — a directional axis mark: shaft plus head, unlike Chevron which is
// a head alone. Use it where the icon states a DIRECTION along a scale (slider
// endpoints, ranges); use Chevron where it states "there is more this way"
// (rows, drill-ins). Drawn on a 14×10 box at stroke 1.5 so it sits at exactly
// the same weight as Chevron beside it. Rotate 180° for the left end.
function ArrowMark({ w = 14, h = 10, color = 'currentColor', opacity = 1 }) {
  return (
    <svg width={w} height={h} viewBox="0 0 14 10" style={{ flexShrink: 0 }} aria-hidden="true">
      <path d="M1.25 5h10.5M8.6 1.9L11.75 5 8.6 8.1" fill="none" stroke={color} strokeOpacity={opacity}
            strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}
function BackMark({ size = 18, color = 'currentColor' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 18 18" aria-hidden="true">
      <path d="M11 3 L5 9 L11 15" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}
function CloseMark({ size = 18, color = 'currentColor' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 18 18" aria-hidden="true">
      <path d="M3 3l12 12M15 3L3 15" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round"/>
    </svg>
  );
}
function CheckMark({ size = 18, color = 'var(--sage)', sw = 2 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 18 18" style={{ flexShrink: 0 }} aria-hidden="true">
      <path d="M3 9.5l3.5 3.5L15 5" fill="none" stroke={color} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}
Object.assign(window, { Chevron, ArrowMark, BackMark, CloseMark, CheckMark });

window.IconCup    = IconCup;
window.IconRoute  = IconRoute;
window.IconCards  = IconCards;
window.IconLeaf   = IconLeaf;

// Tree growth has a single source of truth: completed core-lesson count,
// via window.treeStageFromCore (see data.jsx). The old points-threshold
// stageFromPoints has been retired so the tree never tells two stories.
