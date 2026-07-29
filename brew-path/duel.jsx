// duel.jsx — Coffee Duel: an asynchronous, share-a-link challenge.
// One play engine, five duel types, and every social/result state.
// Exposes <DuelFlow/> (mounted by app.jsx at view==='duel') and
// <DuelHeaderButton/> (the persistent top-right entry on the main tabs).

const { useState: useStateD, useEffect: useEffectD, useRef: useRefD } = React;

// ───────────────────────────────────────────────────────────
// Persistence — lets a half-finished duel survive a refresh.
// ───────────────────────────────────────────────────────────
const DUEL_LS = 'cq-duel-progress';
function readDuelProgress() {
  try { return JSON.parse(localStorage.getItem(DUEL_LS)) || null; } catch (e) { return null; }
}
function writeDuelProgress(p) {
  try {
    if (p) localStorage.setItem(DUEL_LS, JSON.stringify(p));
    else localStorage.removeItem(DUEL_LS);
  } catch (e) {}
}

// ───────────────────────────────────────────────────────────
// Glyphs — one simple mark per duel type (kept to circles / lines).
// ───────────────────────────────────────────────────────────
function DuelGlyph({ type, size = 24, color = 'var(--accent)' }) {
  const icon = (window.duelType(type) || {}).icon;
  // Cup / Globe / Route are part of the shared nav family — pull them from the
  // single registry (window.Icons) rather than re-drawing them here. Rendering
  // them outlined in `color` (active off, mute = color) keeps one source of
  // truth and one stroke weight (1.6). Only Tiles and Drop stay duel-specific.
  const Reg = window.Icons || {};
  const fromNav = { cup: Reg.Cup, globe: Reg.Globe, route: Reg.Route };
  const NavIcon = fromNav[icon] || (icon === 'tiles' || icon === 'drop' ? null : Reg.Cup);
  if (NavIcon) return <NavIcon size={size} color={color} mute={color} active={false}/>;

  // Duel-specific marks — matched to the family via the shared stroke token.
  const sw = window.GLYPH_STROKE || 1.6;
  const common = { width: size, height: size, viewBox: '0 0 24 24', fill: 'none' };
  if (icon === 'tiles') return (
    <svg {...common}><rect x="3.5" y="7" width="7" height="10" rx="2" stroke={color} strokeWidth={sw}/>
      <rect x="13.5" y="7" width="7" height="10" rx="2" stroke={color} strokeWidth={sw}/>
      <path d="M10.5 12h3" stroke={color} strokeWidth={sw} strokeLinecap="round"/></svg>
  );
  // cherry in section — same mark as the Processing dictionary category
  return (
    <svg {...common}><path d="M13.6 5.9 Q 15.2 3.7 17.4 3.5" stroke={color} strokeWidth="1.3" strokeLinecap="round"/>
      <circle cx="11.8" cy="13.2" r="7" stroke={color} strokeWidth={sw}/>
      <ellipse cx="11.8" cy="13.2" rx="2.9" ry="4.2" transform="rotate(-18 11.8 13.2)" stroke={color} strokeWidth="1.3"/></svg>
  );
}

// ───────────────────────────────────────────────────────────
// Avatars + versus motif
// ───────────────────────────────────────────────────────────
function DuelAvatar({ who, size = 64, dim }) {
  const box = {
    width: size, height: size, borderRadius: size * 0.32, flexShrink: 0,
    display: 'grid', placeItems: 'center', overflow: 'hidden',
    border: '1px solid var(--rule)', background: 'var(--surface-2)',
    opacity: dim ? 0.55 : 1,
  };
  if (!who || who.kind === 'unknown') {
    return <div style={box}><span className="ff-display" style={{ fontSize: size * 0.42, color: 'var(--ink-mute)' }}>?</span></div>;
  }
  if (who.isRoasty || who.kind === 'roasty') {
    return <div style={{ ...box, background: 'var(--bg)' }}><Roasty state={who.state || 'correct'} size={size * 0.92} gear={who.gear || 'sunglasses'} hat="none"/></div>;
  }
  if (who.kind === 'you') {
    return <div style={{ ...box, background: 'var(--bg)' }}><Roasty state={who.state || 'correct'} size={size * 0.92}/></div>;
  }
  // initial (a friend)
  return (
    <div style={{ ...box, background: 'color-mix(in oklab, var(--accent) 12%, var(--surface))' }}>
      <span className="ff-display" style={{ fontSize: size * 0.4, color: 'var(--accent)', lineHeight: 1 }}>{who.initial || '·'}</span>
    </div>
  );
}

// You vs Them, with optional scores + a crowned winner.
function VersusRow({ left, right, leftScore, rightScore, winner, size = 72 }) {
  const Side = ({ who, score, isWin, align }) => (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10, flex: 1, minWidth: 0 }}>
      <div style={{ position: 'relative' }}>
        <DuelAvatar who={who} size={size} dim={winner && !isWin}/>
        {isWin && (
          <div style={{ position: 'absolute', top: -13, left: '50%', transform: 'translateX(-50%)' }}>
            <svg width="26" height="18" viewBox="0 0 26 18" fill="none">
              <path d="M3 15h20l1.5-10-6 4L13 2 7.5 13l-6-4L3 15Z" fill="var(--warn)" stroke="var(--warn)" strokeWidth="1.4" strokeLinejoin="round"/>
            </svg>
          </div>
        )}
      </div>
      <div style={{ textAlign: 'center' }}>
        <div style={{ fontSize: 'var(--t-support)', fontWeight: 500, color: 'var(--ink)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', maxWidth: 96 }}>{who.name}</div>
        {score != null && (
          <div className="ff-mono" style={{ fontSize: 'var(--t-title)', fontWeight: 500, lineHeight: 1, letterSpacing: '-0.01em', color: isWin ? 'var(--accent)' : 'var(--ink)', marginTop: 4 }}>{score}</div>
        )}
      </div>
    </div>
  );
  return (
    <div style={{ display: 'flex', alignItems: 'flex-start', gap: 8 }}>
      <Side who={left} score={leftScore} isWin={winner === 'left'}/>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', paddingTop: size * 0.28 }}>
        <span className="ff-display" style={{ fontSize: 'var(--t-heading)', fontStyle: 'italic', color: 'var(--ink-mute)', letterSpacing: '-0.02em' }}>vs</span>
      </div>
      <Side who={right} score={rightScore} isWin={winner === 'right'}/>
    </div>
  );
}

const YOU = { kind: 'you', name: 'You' };

// ───────────────────────────────────────────────────────────
// Shared chrome
// ───────────────────────────────────────────────────────────
function DuelTopBar({ onClose, title, back, right }) {
  return (
    <div className="lesson-topbar" style={{ borderBottom: 'none', background: 'transparent' }}>
      <button className="close-btn" onClick={onClose} aria-label={back ? 'Back' : 'Close'}>
        {back ? <window.BackMark/> : <window.CloseMark/>}
      </button>
      <div style={{ textAlign: 'center' }}>
        {title && <span className="smallcaps" style={{ color: 'var(--ink-mute)' }}>{title}</span>}
      </div>
      <div style={{ justifySelf: 'end' }}>{right || null}</div>
    </div>
  );
}

function StatBlock({ label, value, accent }) {
  return (
    <div style={{ background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 14, padding: '14px 16px' }}>
      <div className="ff-mono" style={{ fontSize: 'var(--t-lead)', fontWeight: 500, letterSpacing: '-0.01em', lineHeight: 1, color: accent ? 'var(--accent)' : 'var(--ink)' }}>{value}</div>
      <div className="smallcaps" style={{ marginTop: 8 }}>{label}</div>
    </div>
  );
}

// Small reusable "duel type" pill used in headers.
function DuelTypeTag({ type, color = 'var(--ink-mute)' }) {
  const t = window.duelType(type);
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}>
      <DuelGlyph type={type} size={16} color={color}/>
      <span className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.12em', textTransform: 'uppercase', color }}>{t.name}</span>
    </span>
  );
}

// ───────────────────────────────────────────────────────────
// Helpers for scoring a run
// ───────────────────────────────────────────────────────────
function correctIndex(q) { return q.choices.findIndex(c => c.correct); }
function scoreRun(type, answers) {
  const qs = window.DUEL_QUESTIONS[type] || [];
  let correct = 0;
  qs.forEach((q, i) => { if (answers[i] === correctIndex(q)) correct++; });
  return { correct, total: qs.length };
}

// ═══════════════════════════════════════════════════════════
// HUB — the Coffee Duel home. Empty or populated.
// ═══════════════════════════════════════════════════════════
function DuelHub({ empty, resume, onStart, onResume, onPlayIncoming, onOpenSent, onRematch, onOpenComparison, onClose }) {
  const R = window.DUEL_RECORDS;
  return (
    <div className="screen" data-screen-label="Duel · Hub" style={{ background: 'var(--bg)' }}>
      <DuelTopBar onClose={onClose}/>
      <div className="scroll" style={{ paddingTop: 112, paddingBottom: 120 }}>
        <div className="px-24">
          <div className="smallcaps" style={{ color: 'var(--accent)', marginBottom: 10 }}>COFFEE DUEL</div>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.04, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>
            {empty ? 'Challenge a friend.' : 'Who’s up?'}
          </h1>
        </div>

        {empty ? (
          <>
            <div style={{ display: 'flex', justifyContent: 'center', padding: '14px 0 0' }}>
              <Roasty state="correct" size={150} gear="sunglasses"/>
            </div>
            <div className="px-24" style={{ paddingTop: 4 }}>
              <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink-mute)', margin: '0 auto', maxWidth: 300, textAlign: 'center', textWrap: 'pretty' }}>
                Play a quick 5-question coffee challenge, then send the link to anyone. They play the same one — you compare scores. No friends here yet? Roasty will take you on.
              </p>
            </div>
            <div className="px-24" style={{ paddingTop: 26 }}>
              <button className="btn btn-primary" onClick={() => onStart()}>Start a duel</button>
              <div style={{ marginTop: 10 }}>
                <button className="btn btn-ghost" onClick={() => onStart('roasty')}
                        style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10 }}>
                  <DuelAvatar who={window.DUEL_FRIENDS.roasty} size={26}/>
                  Duel Roasty instead
                </button>
              </div>
            </div>
            <div className="px-24" style={{ paddingTop: 30 }}>
              <DuelHowItWorks/>
            </div>
          </>
        ) : (
          <>
            {resume && (
              <div className="px-24" style={{ paddingTop: 22 }}>
                <button onClick={onResume} style={rowCardStyle('accent')}>
                  <span style={{ display: 'flex', alignItems: 'center', gap: 13, minWidth: 0 }}>
                    <span style={tileStyle('accent')}><DuelGlyph type={resume.type} size={22} color="var(--accent)"/></span>
                    <span style={{ minWidth: 0 }}>
                      <span className="smallcaps" style={{ color: 'var(--accent)', display: 'block' }}>RESUME</span>
                      <span style={{ display: 'block', fontSize: 'var(--t-body)', color: 'var(--ink)', fontWeight: 500, marginTop: 2 }}>{window.duelType(resume.type).name} · Q{resume.idx + 1} of 5</span>
                    </span>
                  </span>
                  <window.Chevron/>
                </button>
              </div>
            )}

            <DuelSection label="YOUR TURN" count={R.incoming.length} hint="They’re waiting on you">
              {R.incoming.map(rec => (
                <DuelRecordRow key={rec.id} onClick={() => onPlayIncoming(rec)}
                  type={rec.type} who={rec.friend}
                  title={`${rec.friend.name} challenged you`}
                  meta={`SCORED ${rec.theirScore}/5 · ${rec.expires}`}
                  cta="play"/>
              ))}
            </DuelSection>

            <DuelSection label="WAITING ON THEM" count={R.outgoing.length} hint="Challenge sent">
              {R.outgoing.map(rec => (
                <DuelRecordRow key={rec.id} onClick={() => onOpenSent(rec)}
                  type={rec.type} who={{ kind: 'unknown' }}
                  title={rec.shared || 'Challenge sent'}
                  meta={`YOU SCORED ${rec.yourScore}/5 · ${rec.ago}`}
                  cta="pending"/>
              ))}
            </DuelSection>

            <DuelSection label="RECENT DUELS" count={R.done.length}>
              {R.done.map(rec => (
                <DuelRecordRow key={rec.id} onClick={() => onOpenComparison(rec)}
                  type={rec.type} who={rec.friend}
                  title={`${rec.won === null ? 'Tie with' : (rec.won ? 'Beat' : 'Lost to')} ${rec.friend.name}`}
                  meta={`${rec.yourScore}–${rec.theirScore} · ${rec.when}`}
                  result={rec.won === null ? 'tie' : (rec.won ? 'win' : 'loss')}
                  cta="rematch" onCta={() => onRematch(rec)}/>
              ))}
            </DuelSection>
          </>
        )}
      </div>

      {!empty && (
        <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, padding: '14px 24px 26px',
          background: 'linear-gradient(180deg, transparent, var(--bg) 32%)', zIndex: 20 }}>
          <button className="btn btn-primary" onClick={() => onStart()}>Start new duel</button>
        </div>
      )}
    </div>
  );
}

function DuelHowItWorks() {
  const steps = ['Pick a duel and play 5 quick questions', 'Send the link — Messages, WhatsApp, anywhere', 'They play the same five; you compare scores'];
  return (
    <div>
      <div className="smallcaps" style={{ marginBottom: 14 }}>HOW IT WORKS</div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
        {steps.map((s, i) => (
          <div key={i} style={{ display: 'flex', alignItems: 'baseline', gap: 14 }}>
            <span className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.1em', color: 'var(--accent)', flexShrink: 0 }}>{String(i + 1).padStart(2, '0')}</span>
            <span style={{ fontSize: 'var(--t-body)', lineHeight: 1.45, color: 'var(--ink)' }}>{s}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

function DuelSection({ label, count, hint, children }) {
  if (!children || (Array.isArray(children) && children.filter(Boolean).length === 0)) return null;
  return (
    <div className="px-24" style={{ paddingTop: 30 }}>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, marginBottom: 12 }}>
        <span className="smallcaps">{label}</span>
        <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.12em', color: 'var(--ink-mute)' }}>{count}</span>
        {hint && <span style={{ marginLeft: 'auto', fontSize: 'var(--t-label)', color: 'var(--ink-mute)' }}>{hint}</span>}
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>{children}</div>
    </div>
  );
}

function DuelRecordRow({ type, who, title, meta, result, cta, onClick, onCta }) {
  const resColor = result === 'win' ? 'var(--sage)' : result === 'loss' ? 'var(--accent)' : 'var(--ink-mute)';
  return (
    <div style={{ display: 'grid', gridTemplateColumns: 'auto 1fr auto', alignItems: 'center', gap: 13,
      background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 14, padding: '13px 15px',
      cursor: 'pointer' }} onClick={onClick}>
      <DuelAvatar who={who} size={44}/>
      <div style={{ minWidth: 0 }}>
        <div style={{ fontSize: 'var(--t-body)', color: 'var(--ink)', fontWeight: 500, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{title}</div>
        <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.1em', color: result ? resColor : 'var(--ink-mute)', textTransform: 'uppercase', marginTop: 4, display: 'flex', alignItems: 'center', gap: 7 }}>
          <DuelGlyph type={type} size={13} color={result ? resColor : 'var(--ink-mute)'}/>{meta}
        </div>
      </div>
      {cta === 'play' && <span className="ff-mono" style={duelPillStyle('var(--accent)', true)}>PLAY</span>}
      {cta === 'pending' && <span className="ff-mono" style={duelPillStyle('var(--ink-mute)')}>PENDING</span>}
      {cta === 'rematch' && (
        <button onClick={(e) => { e.stopPropagation(); onCta && onCta(); }} className="ff-mono" style={{ ...duelPillStyle('var(--ink)'), cursor: 'pointer', appearance: 'none' }}>REMATCH</button>
      )}
    </div>
  );
}

function duelPillStyle(color, filled) {
  return {
    fontSize: 'var(--t-micro)', letterSpacing: '0.12em', textTransform: 'uppercase',
    padding: '6px 11px', borderRadius: 999, whiteSpace: 'nowrap',
    color: filled ? 'var(--accent-ink)' : color,
    background: filled ? 'var(--accent)' : 'transparent',
    border: filled ? 'none' : '1px solid var(--rule)',
  };
}
function rowCardStyle(variant) {
  return {
    width: '100%', appearance: 'none', cursor: 'pointer', textAlign: 'left',
    display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12,
    background: variant === 'accent' ? 'color-mix(in oklab, var(--accent) 9%, var(--surface))' : 'var(--surface)',
    border: '1px solid ' + (variant === 'accent' ? 'color-mix(in oklab, var(--accent) 28%, var(--rule))' : 'var(--rule)'),
    borderRadius: 14, padding: '13px 15px',
  };
}
function tileStyle(variant) {
  return { width: 42, height: 42, borderRadius: 12, flexShrink: 0, display: 'grid', placeItems: 'center',
    background: 'color-mix(in oklab, var(--accent) 12%, var(--surface))' };
}
// ═══════════════════════════════════════════════════════════
// PICKER — choose a duel type. Tweakable grid / list.
// ═══════════════════════════════════════════════════════════
function DuelPicker({ layout = 'grid', opponent, onPick, onClose }) {
  const types = window.DUEL_TYPES;
  return (
    <div className="screen" data-screen-label="Duel · Pick type" style={{ background: 'var(--bg)' }}>
      <DuelTopBar onClose={onClose} back/>
      <div className="scroll" style={{ paddingTop: 112, paddingBottom: 32 }}>
        <div className="px-24">
          <div className="smallcaps" style={{ color: 'var(--accent)', marginBottom: 10 }}>NEW DUEL</div>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.08, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>Pick your challenge</h1>
          {opponent && (
            <div style={{ display: 'flex', alignItems: 'center', gap: 9, marginTop: 14 }}>
              <DuelAvatar who={opponent} size={24}/>
              <span style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)' }}>Dueling <strong style={{ color: 'var(--ink)' }}>{opponent.name}</strong></span>
            </div>
          )}
        </div>

        {layout === 'grid' ? (
          <div className="px-24" style={{ paddingTop: 22, display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            {types.map(t => (
              <button key={t.id} onClick={() => onPick(t.id)} style={{
                appearance: 'none', cursor: 'pointer', textAlign: 'left',
                background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 16, padding: 16,
                display: 'flex', flexDirection: 'column', gap: 12, minHeight: 132,
              }}>
                <span style={{ width: 46, height: 46, borderRadius: 13, display: 'grid', placeItems: 'center', background: 'color-mix(in oklab, var(--accent) 11%, var(--surface))' }}>
                  <DuelGlyph type={t.id} size={24} color="var(--accent)"/>
                </span>
                <span style={{ marginTop: 'auto' }}>
                  <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.14em', color: 'var(--ink-mute)', textTransform: 'uppercase', display: 'block' }}>{t.tag}</span>
                  <span className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, letterSpacing: '-0.01em', color: 'var(--ink)', lineHeight: 1.05, display: 'block', marginTop: 4 }}>{t.name}</span>
                </span>
              </button>
            ))}
          </div>
        ) : (
          <div className="px-24" style={{ paddingTop: 22, display: 'flex', flexDirection: 'column', gap: 10 }}>
            {types.map(t => (
              <button key={t.id} onClick={() => onPick(t.id)} style={{
                appearance: 'none', cursor: 'pointer', textAlign: 'left', width: '100%',
                background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 14, padding: '14px 16px',
                display: 'grid', gridTemplateColumns: 'auto 1fr auto', alignItems: 'center', gap: 14,
              }}>
                <span style={{ width: 44, height: 44, borderRadius: 12, display: 'grid', placeItems: 'center', background: 'color-mix(in oklab, var(--accent) 11%, var(--surface))' }}>
                  <DuelGlyph type={t.id} size={22} color="var(--accent)"/>
                </span>
                <span style={{ minWidth: 0 }}>
                  <span className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, letterSpacing: '-0.01em', color: 'var(--ink)', display: 'block', lineHeight: 1.1 }}>{t.name}</span>
                  <span style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', display: 'block', marginTop: 3 }}>{t.blurb}</span>
                </span>
                <window.Chevron/>
              </button>
            ))}
          </div>
        )}
        <div className="px-24" style={{ paddingTop: 20 }}>
          <div className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.08em', color: 'var(--ink-mute)', textTransform: 'uppercase', textAlign: 'center' }}>
            5 questions · ~1 minute · low pressure
          </div>
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════
// PLAY — the 5-question challenge. Times each answer.
// ═══════════════════════════════════════════════════════════
function DuelPlay({ type, opponent, resumeState, onProgress, onDone, onQuit }) {
  const qs = window.DUEL_QUESTIONS[type] || [];
  const [idx, setIdx] = useStateD(resumeState ? resumeState.idx : 0);
  const [answers, setAnswers] = useStateD(resumeState ? resumeState.answers : []);
  const [perQ, setPerQ] = useStateD(resumeState ? (resumeState.perQ || []) : []);
  const [picked, setPicked] = useStateD(null);
  const qStart = useRefD(Date.now());
  const [now, setNow] = useStateD(Date.now());

  // running clock for the live timer chip
  useEffectD(() => {
    const id = setInterval(() => setNow(Date.now()), 250);
    return () => clearInterval(id);
  }, [idx]);
  useEffectD(() => { qStart.current = Date.now(); setNow(Date.now()); }, [idx]);

  const q = qs[idx];
  const cIdx = correctIndex(q);
  const elapsed = ((now - qStart.current) / 1000);

  const pick = (i) => {
    if (picked !== null) return;
    setPicked(i);
    const dt = Math.max(0.4, (Date.now() - qStart.current) / 1000);
    const nextAnswers = [...answers]; nextAnswers[idx] = i;
    const nextPerQ = [...perQ]; nextPerQ[idx] = dt;
    setAnswers(nextAnswers); setPerQ(nextPerQ);
    onProgress && onProgress({ type, idx, answers: nextAnswers, perQ: nextPerQ });
  };

  const advance = () => {
    if (idx + 1 >= qs.length) {
      const totalTime = perQ.reduce((a, b) => a + (b || 0), 0);
      const sc = scoreRun(type, answers);
      onDone({ type, answers, perQ, timeSec: Math.round(totalTime), correct: sc.correct, total: sc.total });
    } else {
      const ni = idx + 1;
      setIdx(ni); setPicked(null);
      onProgress && onProgress({ type, idx: ni, answers, perQ });
    }
  };

  const filledWedge = Math.round(((idx + 1) / qs.length) * 6);

  return (
    <div className="screen" data-screen-label="Duel · Play" style={{ background: 'var(--bg)' }}>
      <div className="lesson-topbar">
        <button className="close-btn" onClick={onQuit} aria-label="Quit duel">
          <window.CloseMark/>
        </button>
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: 10 }}>
          <RoastBean done={idx + 1} total={qs.length}/>
          <span className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.12em', color: 'var(--ink-mute)', textTransform: 'uppercase' }}>
            {String(idx + 1).padStart(2, '0')} / {String(qs.length).padStart(2, '0')}
          </span>
        </div>
        <span className="ff-mono" style={{ justifySelf: 'end', fontSize: 'var(--t-label)', color: picked === null ? 'var(--accent)' : 'var(--ink-mute)', letterSpacing: '0.06em', minWidth: 38, textAlign: 'right' }}>
          {elapsed.toFixed(1)}s
        </span>
      </div>

      <div className="scroll" style={{ paddingTop: 110, paddingBottom: 28 }}>
        <div key={idx} className="px-24" style={{ display: 'flex', flexDirection: 'column', minHeight: 600 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 9, marginBottom: 16 }}>
            <DuelGlyph type={type} size={16} color="var(--accent)"/>
            <span className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.14em', color: 'var(--ink-mute)', textTransform: 'uppercase' }}>{window.duelType(type).name}</span>
          </div>
          <h2 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.12, letterSpacing: '-0.01em', margin: 0, color: 'var(--ink)', textWrap: 'pretty' }}>{q.q}</h2>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 24 }}>
            {q.choices.map((c, i) => {
              let cls = 'mcq-choice';
              if (picked !== null) {
                if (i === cIdx) cls += ' correct';
                else if (i === picked) cls += ' incorrect';
              }
              return (
                <button key={i} className={cls} disabled={picked !== null} onClick={() => pick(i)}
                  style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
                  <span>{c.t}</span>
                  {picked !== null && i === cIdx && <window.CheckMark/>}
                  {picked !== null && i === picked && i !== cIdx && <CrossMark/>}
                </button>
              );
            })}
          </div>

          {picked !== null && (
            <div style={{ marginTop: 20, display: 'flex', gap: 14, alignItems: 'flex-start' }}>
              <div style={{ flexShrink: 0, marginTop: -8 }}><Roasty state={picked === cIdx ? 'correct' : 'wrong'} size={64}/></div>
              <div style={{ flex: 1 }}>
                <div className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.14em', color: picked === cIdx ? 'var(--sage)' : 'var(--berry)', textTransform: 'uppercase', marginBottom: 8 }}>
                  {picked === cIdx ? 'CORRECT' : 'NOT QUITE'}
                </div>
                <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: 0 }}>{q.explain}</p>
              </div>
            </div>
          )}

          <div style={{ flex: 1 }}/>
          <div style={{ paddingTop: 28 }}>
            <button className="btn btn-primary" onClick={advance} disabled={picked === null}>
              {idx + 1 >= qs.length ? 'See your score' : 'Next question'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

function CrossMark() {
  return <svg width="16" height="16" viewBox="0 0 16 16" style={{ flexShrink: 0 }}><path d="M3 3l10 10M13 3L3 13" stroke="var(--berry)" strokeWidth="2" strokeLinecap="round"/></svg>;
}

// ═══════════════════════════════════════════════════════════
// RESULT — your own score after playing, before the friend answers.
// ═══════════════════════════════════════════════════════════
function DuelResult({ run, reveal = 'tally', opponent, onSend, onClose }) {
  const [phase, setPhase] = useStateD('roasty');
  const acc = Math.round((run.correct / run.total) * 100);
  const xp = window.duelXp(run.correct, run.total);
  const [showReview, setShowReview] = useStateD(false);
  if (phase === 'roasty') {
    return <RoastyMoment state={run.correct >= 4 ? 'correct' : 'idle'} eyebrow="ROUND COMPLETE"
      title={run.correct >= 4 ? 'Sharp.' : 'Nice round.'} onDone={() => setPhase('content')}/>;
  }
  return (
    <div className="screen" data-screen-label="Duel · Your result" style={{ background: 'var(--bg)' }}>
      <DuelTopBar onClose={onClose} title={window.duelType(run.type).name}/>
      <div className="scroll" style={{ paddingTop: 86, paddingBottom: 0, display: 'flex', flexDirection: 'column' }}>
        <div className="px-24" style={{ textAlign: 'center' }}>
          <div className="smallcaps" style={{ color: 'var(--accent)' }}>YOUR SCORE</div>
          <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'center', gap: 6, marginTop: 8 }}>
            <ScoreCount value={run.correct} animate={reveal === 'tally'}/>
            <span className="ff-mono" style={{ fontSize: 'var(--t-lead)', fontWeight: 500, color: 'var(--ink-mute)', letterSpacing: '-0.01em' }}>/ {run.total}</span>
          </div>
        </div>

        <div className="px-24" style={{ paddingTop: 22 }}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10 }}>
            <StatBlock label="ACCURACY" value={acc + '%'}/>
            <StatBlock label="TIME" value={run.timeSec + 's'}/>
            <StatBlock label="REWARD" value={'+' + xp} accent/>
          </div>
        </div>

        {/* Correct answers / review */}
        <div className="px-24" style={{ paddingTop: 18 }}>
          <button onClick={() => setShowReview(s => !s)} style={{
            width: '100%', appearance: 'none', cursor: 'pointer', background: 'transparent',
            border: '1px solid var(--rule)', borderRadius: 12, padding: '13px 15px',
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          }}>
            <span style={{ fontSize: 'var(--t-support)', color: 'var(--ink)', fontWeight: 500 }}>Review the answers</span>
            <svg width="18" height="18" viewBox="0 0 20 20" style={{ color: 'var(--ink-mute)', transform: showReview ? 'rotate(180deg)' : 'none', transition: 'transform 220ms' }}><path d="M5 8 L10 13 L15 8" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/></svg>
          </button>
          {showReview && <DuelReview type={run.type} answers={run.answers} style={{ marginTop: 12 }}/>}
        </div>

        <div style={{ flex: 1, minHeight: 18 }}/>

        <div className="px-24" style={{ position: 'sticky', bottom: 0, paddingTop: 20, paddingBottom: 24, background: 'linear-gradient(to top, var(--bg) 74%, transparent)' }}>
          <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', textAlign: 'center', margin: '0 auto 14px', maxWidth: 280, textWrap: 'pretty' }}>
            Now send it on. Whoever you challenge plays these same five.
          </p>
          <button className="btn btn-primary" onClick={() => onSend(run)}>Send the challenge</button>
          <div style={{ marginTop: 10 }}>
            <a className="btn btn-ghost" href="#" style={{ display: 'block', textAlign: 'center', textDecoration: 'none' }} onClick={(e) => { e.preventDefault(); onClose(); }}>Back to duels</a>
          </div>
        </div>
      </div>
    </div>
  );
}

function ScoreCount({ value, animate }) {
  const [n, setN] = useStateD(animate ? 0 : value);
  useEffectD(() => {
    if (!animate) { setN(value); return; }
    let cur = 0; setN(0);
    const id = setInterval(() => { cur += 1; setN(cur); if (cur >= value) clearInterval(id); }, 260);
    return () => clearInterval(id);
  }, [value, animate]);
  return <span className="ff-mono" style={{ fontSize: 'var(--t-hero)', fontWeight: 500, lineHeight: 0.9, letterSpacing: '-0.02em', color: 'var(--accent)' }}>{n}</span>;
}

// Per-question review list — the learning-reinforcement payload.
function DuelReview({ type, answers, them, style }) {
  const qs = window.DUEL_QUESTIONS[type] || [];
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 10, ...style }}>
      {qs.map((q, i) => {
        const cIdx = correctIndex(q);
        const youOk = answers[i] === cIdx;
        const themOk = them ? them[i] === cIdx : null;
        return (
          <div key={i} style={{ background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 12, padding: '13px 15px' }}>
            <div style={{ display: 'flex', alignItems: 'flex-start', gap: 10 }}>
              <span className="ff-mono" style={{ fontSize: 'var(--t-label)', color: 'var(--ink-mute)', marginTop: 2 }}>{String(i + 1).padStart(2, '0')}</span>
              <span style={{ fontSize: 'var(--t-support)', color: 'var(--ink)', lineHeight: 1.4, flex: 1 }}>{q.q}</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 10, paddingLeft: 22 }}>
              <window.CheckMark/>
              <span style={{ fontSize: 'var(--t-support)', color: 'var(--ink)', fontWeight: 500 }}>{q.choices[cIdx].t}</span>
            </div>
            <div style={{ display: 'flex', gap: 14, marginTop: 8, paddingLeft: 22 }}>
              <ReviewTag who="You" ok={youOk}/>
              {them && <ReviewTag who="Them" ok={themOk}/>}
            </div>
          </div>
        );
      })}
    </div>
  );
}
function ReviewTag({ who, ok }) {
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
      <span style={{ width: 7, height: 7, borderRadius: 999, background: ok ? 'var(--sage)' : 'var(--accent)' }}/>
      <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--ink-mute)' }}>{who} {ok ? 'got it' : 'missed'}</span>
    </span>
  );
}

// ═══════════════════════════════════════════════════════════
// INVITE — the shareable artifact + native share sheet.
// ═══════════════════════════════════════════════════════════
function DuelInvite({ run, opponent, onShared, onClose }) {
  const [sheetOpen, setSheetOpen] = useStateD(false);
  const link = 'brewpath.app/d/7K2P9';
  return (
    <div className="screen" data-screen-label="Duel · Invite" style={{ background: 'var(--bg)' }}>
      <DuelTopBar onClose={onClose} back/>
      <div className="scroll" style={{ paddingTop: 112, paddingBottom: 32, display: 'flex', flexDirection: 'column' }}>
        <div className="px-24">
          <h1 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.08, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>Your challenge is ready</h1>
        </div>

        <div className="px-24" style={{ paddingTop: 20 }}>
          <InviteCard run={run}/>
        </div>

        <div className="px-24" style={{ paddingTop: 20 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 12, padding: '12px 14px' }}>
            <svg width="17" height="17" viewBox="0 0 20 20" fill="none" style={{ flexShrink: 0 }}><path d="M9 11l5-5M8 5l1.5-1.5a3 3 0 0 1 4.2 4.2L12 9.4" stroke="var(--ink-mute)" strokeWidth="1.5" strokeLinecap="round"/><path d="M11 9l-1.5 1.5a3 3 0 0 1-4.2-4.2L7 4.6" stroke="var(--ink-mute)" strokeWidth="1.5" strokeLinecap="round"/></svg>
            <span className="ff-mono" style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', flex: 1, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{link}</span>
            <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.1em', color: 'var(--ink-mute)' }}>EXPIRES 7d</span>
          </div>
        </div>

        <div style={{ flex: 1, minHeight: 20 }}/>

        <div className="px-24" style={{ paddingTop: 20 }}>
          <button className="btn btn-primary" onClick={() => setSheetOpen(true)}
            style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10 }}>
            <svg width="18" height="18" viewBox="0 0 20 20" fill="none"><path d="M10 13V3M10 3L6.5 6.5M10 3l3.5 3.5" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"/><path d="M4 12v3.5C4 16.3 4.7 17 5.5 17h9c.8 0 1.5-.7 1.5-1.5V12" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round"/></svg>
            Share challenge
          </button>
          <div style={{ marginTop: 10 }}>
            <a className="btn btn-ghost" href="#" style={{ display: 'block', textAlign: 'center', textDecoration: 'none' }} onClick={(e) => { e.preventDefault(); onShared('skip'); }}>I’ll send it later</a>
          </div>
        </div>
      </div>

      <DuelShareSheet open={sheetOpen} link={link} onClose={() => setSheetOpen(false)} onDone={() => { setSheetOpen(false); onShared('sent'); }}/>
    </div>
  );
}

function InviteCard({ run }) {
  const t = window.duelType(run.type);
  return (
    <div style={{
      borderRadius: 18, overflow: 'hidden', position: 'relative',
      border: '1px solid color-mix(in oklab, var(--accent) 26%, var(--rule))',
      background: 'linear-gradient(158deg, color-mix(in oklab, var(--accent) 13%, var(--surface)) 0%, var(--surface) 62%)',
      padding: '22px 22px 24px', boxShadow: '0 16px 36px rgba(0,0,0,0.24)',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span className="smallcaps" style={{ color: 'var(--accent)' }}>COFFEE DUEL</span>
        <DuelGlyph type={run.type} size={20} color="var(--accent)"/>
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginTop: 18 }}>
        <Roasty state="correct" size={92} gear="sunglasses"/>
        <div style={{ minWidth: 0 }}>
          <div className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em', color: 'var(--ink)' }}>Cane you bean me?</div>
          <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 6 }}>{t.name} · 5 questions</div>
        </div>
      </div>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, marginTop: 18, paddingTop: 16, borderTop: '1px solid color-mix(in oklab, var(--accent) 18%, var(--rule))' }}>
        <span className="smallcaps">SCORE TO BEAT</span>
        <span className="ff-mono" style={{ fontSize: 'var(--t-lead)', fontWeight: 500, lineHeight: 1, letterSpacing: '-0.01em', color: 'var(--accent)', marginLeft: 'auto' }}>{run.correct}/{run.total}</span>
      </div>
    </div>
  );
}

function DuelShareSheet({ open, link, onClose, onDone }) {
  const [copied, setCopied] = useStateD(false);
  useEffectD(() => { if (!open) setCopied(false); }, [open]);
  const targets = [
    { label: 'Messages', tint: '#4CAF50', icon: <path d="M4 6.5C4 5.4 4.9 4.5 6 4.5h12c1.1 0 2 .9 2 2v7c0 1.1-.9 2-2 2H9l-4 3.5V6.5Z" stroke="currentColor" strokeWidth="1.6" strokeLinejoin="round"/> },
    { label: 'WhatsApp', tint: '#25D366', icon: <><circle cx="12" cy="12" r="8.4" stroke="currentColor" strokeWidth="1.6"/><path d="M8.5 9c0 4 2.5 6 6 6.2" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/></> },
    { label: 'Mail', tint: 'var(--ink-mute)', icon: <><rect x="3.5" y="6" width="17" height="12" rx="2" stroke="currentColor" strokeWidth="1.6"/><path d="M4.5 7.5l7.5 5 7.5-5" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/></> },
    { label: 'More', tint: 'var(--ink-mute)', icon: <><circle cx="6" cy="12" r="1.4" fill="currentColor"/><circle cx="12" cy="12" r="1.4" fill="currentColor"/><circle cx="18" cy="12" r="1.4" fill="currentColor"/></> },
  ];
  return (
    <>
      <div className={'sheet-backdrop' + (open ? ' open' : '')} onClick={onClose}/>
      <div className={'sheet' + (open ? ' open' : '')}>
        <div className="sheet-handle"/>
        <div className="sheet-content">
          <div className="smallcaps" style={{ marginBottom: 8 }}>SHARE TO</div>
          <h2 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>Send your duel</h2>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 12, marginTop: 20 }}>
            {targets.map(t => (
              <button key={t.label} onClick={onDone} style={{ appearance: 'none', cursor: 'pointer', background: 'transparent', border: 'none', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8, padding: 0 }}>
                <span style={{ width: 54, height: 54, borderRadius: 16, display: 'grid', placeItems: 'center', border: '1px solid var(--rule)', background: 'var(--surface)', color: t.tint }}>
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none">{t.icon}</svg>
                </span>
                <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.08em', textTransform: 'uppercase', color: 'var(--ink-mute)' }}>{t.label}</span>
              </button>
            ))}
          </div>

          <button onClick={() => setCopied(true)} style={{
            width: '100%', marginTop: 18, appearance: 'none', cursor: 'pointer', textAlign: 'left',
            display: 'flex', alignItems: 'center', gap: 12, background: 'var(--surface)',
            border: '1px solid var(--rule)', borderRadius: 12, padding: '14px 16px',
          }}>
            <span style={{ color: copied ? 'var(--sage)' : 'var(--ink-mute)' }}>
              {copied
                ? <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M5 12.5l4 4 10-10" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>
                : <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M9.5 14.5l5-5" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/><path d="M11 8l1.7-1.7a3.3 3.3 0 0 1 4.7 4.7L15.7 12.7" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/><path d="M13 16l-1.7 1.7a3.3 3.3 0 0 1-4.7-4.7L8.3 11.3" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/></svg>}
            </span>
            <span style={{ flex: 1, minWidth: 0 }}>
              <span style={{ display: 'block', fontSize: 'var(--t-support)', color: 'var(--ink)', fontWeight: 500 }}>{copied ? 'Link copied' : 'Copy link'}</span>
              <span className="ff-mono" style={{ display: 'block', fontSize: 'var(--t-label)', color: 'var(--ink-mute)', marginTop: 2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{link}</span>
            </span>
          </button>

          <div style={{ paddingTop: 18 }}>
            <button className="btn btn-primary" onClick={onDone}>Done — I’ve sent it</button>
          </div>
        </div>
      </div>
    </>
  );
}

// ═══════════════════════════════════════════════════════════
// SENT — confirmation / pending state after sharing.
// ═══════════════════════════════════════════════════════════
function DuelSent({ run, onDone, onClose }) {
  return (
    <div className="screen" data-screen-label="Duel · Sent" style={{ background: 'var(--bg)' }}>
      <DuelTopBar onClose={onClose}/>
      <div className="scroll" style={{ paddingTop: 90, paddingBottom: 32, display: 'flex', flexDirection: 'column' }}>
        <div style={{ display: 'flex', justifyContent: 'center', paddingTop: 12 }}><Roasty state="idle" size={150}/></div>
        <div className="px-24" style={{ textAlign: 'center', paddingTop: 4 }}>
          <div className="smallcaps" style={{ color: 'var(--accent)' }}>CHALLENGE SENT</div>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.02em', margin: '10px 0 0', color: 'var(--ink)' }}>Now we wait.</h1>
          <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink-mute)', margin: '14px auto 0', maxWidth: 290, textWrap: 'pretty' }}>
            When they play, you’ll get a nudge and the results land in your duels. The link works for 7 days.
          </p>
        </div>

        <div className="px-24" style={{ paddingTop: 26 }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 14, background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 14, padding: '16px' }}>
            <DuelAvatar who={YOU} size={48}/>
            <span className="ff-display" style={{ fontSize: 'var(--t-heading)', fontStyle: 'italic', color: 'var(--ink-mute)' }}>vs</span>
            <DuelAvatar who={{ kind: 'unknown' }} size={48}/>
          </div>
        </div>

        <div style={{ flex: 1, minHeight: 18 }}/>
        <div className="px-24" style={{ paddingTop: 20 }}>
          <button className="btn btn-primary" onClick={onDone}>Back to duels</button>
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════
// RECEIVED — a friend opens the link and sees the challenge.
// ═══════════════════════════════════════════════════════════
function DuelReceived({ rec, onAccept, onClose }) {
  return (
    <div className="screen" data-screen-label="Duel · Received" style={{ background: 'var(--bg)' }}>
      <DuelTopBar onClose={onClose}/>
      <div className="scroll" style={{ paddingTop: 86, paddingBottom: 32, display: 'flex', flexDirection: 'column' }}>
        <div className="px-24" style={{ textAlign: 'center' }}>
          <div className="smallcaps" style={{ color: 'var(--accent)' }}>YOU’VE BEEN CHALLENGED</div>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.02em', margin: '10px 0 0', color: 'var(--ink)' }}>
            {rec.friend.name} dares you to a duel
          </h1>
        </div>

        <div className="px-24" style={{ paddingTop: 24 }}>
          <VersusRow left={{ kind: 'initial', name: rec.friend.name, initial: rec.friend.initial }} right={{ kind: 'unknown', name: 'You' }} leftScore={rec.theirScore} size={76}/>
        </div>

        <div className="px-24" style={{ paddingTop: 22 }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10, background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 12, padding: '12px 16px' }}>
            <DuelGlyph type={rec.type} size={18} color="var(--accent)"/>
            <span style={{ fontSize: 'var(--t-support)', color: 'var(--ink)' }}>{window.duelType(rec.type).name}</span>
            <span aria-hidden="true" style={{ opacity: 0.9 }}>·</span>
            <span className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.08em', color: 'var(--ink-mute)', textTransform: 'uppercase' }}>5 questions</span>
          </div>
        </div>

        <div className="px-24" style={{ paddingTop: 18 }}>
          <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.55, color: 'var(--ink-mute)', textAlign: 'center', margin: '0 auto', maxWidth: 290, textWrap: 'pretty' }}>
            {rec.friend.name} scored <strong style={{ color: 'var(--ink)' }}>{rec.theirScore}/5</strong>. Play the same five and see if you can top it. Expires {rec.expires}.
          </p>
        </div>

        <div style={{ flex: 1, minHeight: 20 }}/>
        <div className="px-24" style={{ paddingTop: 20 }}>
          <button className="btn btn-primary" onClick={onAccept}>Accept &amp; play</button>
          <div style={{ marginTop: 10 }}>
            <a className="btn btn-ghost" href="#" style={{ display: 'block', textAlign: 'center', textDecoration: 'none' }} onClick={(e) => { e.preventDefault(); onClose(); }}>Maybe later</a>
          </div>
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════
// COMPARISON — the head-to-head reveal. The hero moment.
// ═══════════════════════════════════════════════════════════
function DuelComparison({ youRun, friendRun, friend, onRematch, onClose }) {
  const [phase, setPhase] = useStateD('roasty');
  const youWon = youRun.correct > friendRun.correct;
  const tie = youRun.correct === friendRun.correct;
  const diff = Math.abs(youRun.correct - friendRun.correct);
  const fastYou = Math.min(...youRun.perQ);
  const fastThem = Math.min(...friendRun.perQ);
  const fastestIsYou = fastYou <= fastThem;
  const [showReview, setShowReview] = useStateD(false);

  if (phase === 'roasty') {
    return <RoastyMoment state={youWon ? 'module' : tie ? 'idle' : 'wrong'}
      eyebrow={tie ? 'DEAD HEAT' : (youWon ? 'YOU WON' : 'SO CLOSE')}
      title={tie ? 'A perfect tie.' : (youWon ? 'You took it.' : `${friend.name} edged it.`)}
      autoMs={2000} onDone={() => setPhase('content')}/>;
  }
  return (
    <div className="screen" data-screen-label="Duel · Comparison" style={{ background: 'var(--bg)' }}>
      <DuelTopBar onClose={onClose}/>
      <div className="scroll" style={{ paddingTop: 84, paddingBottom: 120, display: 'flex', flexDirection: 'column' }}>
        <div className="px-24" style={{ textAlign: 'center' }}>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.03, letterSpacing: '-0.02em', margin: 0, color: tie ? 'var(--ink)' : (youWon ? 'var(--sage)' : 'var(--accent)') }}>
            {tie ? 'Tie' : (youWon ? 'You win' : `${friend.name} wins`)}
          </h1>
          <div style={{ fontSize: 'var(--t-body)', fontWeight: 500, color: 'var(--ink-mute)', marginTop: 7 }}>
            {tie ? 'Evenly matched' : `By ${diff} ${diff === 1 ? 'point' : 'points'}`}
          </div>
        </div>

        <div className="px-24" style={{ paddingTop: 22 }}>
          <VersusRow
            left={{ kind: 'you', name: 'You', state: youWon ? 'correct' : 'idle' }}
            right={{ kind: friend.isRoasty ? 'roasty' : 'initial', name: friend.name, initial: friend.initial, isRoasty: friend.isRoasty }}
            leftScore={youRun.correct} rightScore={friendRun.correct}
            winner={tie ? null : (youWon ? 'left' : 'right')} size={80}/>
        </div>

        {/* head-to-head stats */}
        <div className="px-24" style={{ paddingTop: 26 }}>
          <CompareRow label="Score" you={`${youRun.correct}/5`} them={`${friendRun.correct}/5`} youWin={youRun.correct >= friendRun.correct}/>
          <CompareRow label="Accuracy" you={`${Math.round(youRun.correct / 5 * 100)}%`} them={`${Math.round(friendRun.correct / 5 * 100)}%`} youWin={youRun.correct >= friendRun.correct}/>
          <CompareRow label="Total time" you={`${youRun.timeSec}s`} them={`${friendRun.timeSec}s`} youWin={youRun.timeSec <= friendRun.timeSec} lowerWins/>
          <CompareRow label="Fastest answer" you={`${fastYou.toFixed(1)}s`} them={`${fastThem.toFixed(1)}s`} youWin={fastestIsYou} lowerWins last/>
        </div>

        {/* fastest-answer callout */}
        <div className="px-24" style={{ paddingTop: 18 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, background: 'color-mix(in oklab, var(--warn) 10%, var(--surface))', border: '1px solid color-mix(in oklab, var(--warn) 26%, var(--rule))', borderRadius: 14, padding: '13px 16px' }}>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" style={{ flexShrink: 0 }}><path d="M13 2L4 13h6l-1 9 9-12h-6l1-8Z" stroke="var(--warn)" strokeWidth="1.6" strokeLinejoin="round"/></svg>
            <span style={{ fontSize: 'var(--t-support)', color: 'var(--ink)', lineHeight: 1.45 }}>
              Fastest answer of the duel: <strong>{fastestIsYou ? 'you' : friend.name}</strong> at <strong>{Math.min(fastYou, fastThem).toFixed(1)}s</strong>.
            </span>
          </div>
        </div>

        {/* missed questions / review */}
        <div className="px-24" style={{ paddingTop: 18 }}>
          <button onClick={() => setShowReview(s => !s)} style={{
            width: '100%', appearance: 'none', cursor: 'pointer', background: 'transparent',
            border: '1px solid var(--rule)', borderRadius: 12, padding: '13px 15px',
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          }}>
            <span style={{ fontSize: 'var(--t-support)', color: 'var(--ink)', fontWeight: 500 }}>Missed questions &amp; answers</span>
            <svg width="18" height="18" viewBox="0 0 20 20" style={{ color: 'var(--ink-mute)', transform: showReview ? 'rotate(180deg)' : 'none', transition: 'transform 220ms' }}><path d="M5 8 L10 13 L15 8" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/></svg>
          </button>
          {showReview && <DuelReview type={youRun.type} answers={youRun.answers} them={friendRun.answers} style={{ marginTop: 12 }}/>}
        </div>
      </div>

      <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, padding: '14px 24px 26px', background: 'linear-gradient(180deg, transparent, var(--bg) 34%)', zIndex: 20 }}>
        <button className="btn btn-primary" onClick={onRematch}
          style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10 }}>
          <svg width="18" height="18" viewBox="0 0 20 20" fill="none"><path d="M4 10a6 6 0 0 1 10.5-4M16 10a6 6 0 0 1-10.5 4" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/><path d="M14.5 3v3.2h-3.2M5.5 17v-3.2h3.2" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/></svg>
          Rematch {friend.name}
        </button>
        <div style={{ marginTop: 10 }}>
          <a className="btn btn-ghost" href="#" style={{ display: 'block', textAlign: 'center', textDecoration: 'none' }} onClick={(e) => { e.preventDefault(); onClose(); }}>Back to duels</a>
        </div>
      </div>
    </div>
  );
}

function CompareRow({ label, you, them, youWin, lowerWins, last }) {
  return (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr auto 1fr', alignItems: 'center', gap: 12, padding: '13px 0', borderBottom: last ? 'none' : '1px solid var(--rule)' }}>
      <span className="ff-mono" style={{ fontSize: 'var(--t-body)', textAlign: 'right', color: youWin ? 'var(--accent)' : 'var(--ink-mute)', fontWeight: youWin ? 600 : 400 }}>{you}</span>
      <span className="smallcaps" style={{ textAlign: 'center', minWidth: 96 }}>{label}</span>
      <span className="ff-mono" style={{ fontSize: 'var(--t-body)', textAlign: 'left', color: !youWin ? 'var(--ink)' : 'var(--ink-mute)' }}>{them}</span>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════
// EXPIRED + ERROR — the unhappy paths, kept friendly.
// ═══════════════════════════════════════════════════════════
function DuelMessage({ state, eyebrow, title, body, primary, onPrimary, secondary, onSecondary, onClose }) {
  return (
    <div className="screen" data-screen-label={'Duel · ' + (eyebrow || 'Message')} style={{ background: 'var(--bg)' }}>
      <DuelTopBar onClose={onClose}/>
      <div className="scroll" style={{ paddingTop: 90, paddingBottom: 32, display: 'flex', flexDirection: 'column' }}>
        <div style={{ flex: 1 }}/>
        <div style={{ display: 'flex', justifyContent: 'center' }}><Roasty state={state} size={150}/></div>
        <div className="px-24" style={{ textAlign: 'center', paddingTop: 8 }}>
          <div className="smallcaps" style={{ color: 'var(--ink-mute)' }}>{eyebrow}</div>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.02em', margin: '10px 0 0', color: 'var(--ink)' }}>{title}</h1>
          <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink-mute)', margin: '14px auto 0', maxWidth: 300, textWrap: 'pretty' }}>{body}</p>
        </div>
        <div style={{ flex: 1 }}/>
        <div className="px-24" style={{ paddingTop: 20 }}>
          <button className="btn btn-primary" onClick={onPrimary}>{primary}</button>
          {secondary && (
            <div style={{ marginTop: 10 }}>
              <a className="btn btn-ghost" href="#" style={{ display: 'block', textAlign: 'center', textDecoration: 'none' }} onClick={(e) => { e.preventDefault(); onSecondary(); }}>{secondary}</a>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════
// DuelFlow — the state machine that ties it all together.
// ═══════════════════════════════════════════════════════════
function DuelFlow({ initialStage = 'hub', tweaks = {}, onExit }) {
  // Seed demo data for deep-linked stages so every screen renders populated.
  const seedFriendRec = window.DUEL_RECORDS.incoming[0];
  const isLoss = initialStage === 'comparison-loss';
  const [stage, setStage] = useStateD(isLoss ? 'comparison' : (initialStage === 'hub-empty' ? 'hub' : initialStage));
  const [empty, setEmpty] = useStateD(initialStage === 'hub-empty');
  const [type, setType] = useStateD('basics');
  const [opponent, setOpponent] = useStateD(null);
  const [youRun, setYouRun] = useStateD(isLoss ? window.DEMO_YOU_LOSS : window.DEMO_YOU_RUN);
  const [friendRun, setFriendRun] = useStateD(isLoss ? window.DEMO_FRIEND_WIN : window.DEMO_FRIEND_RUN);
  const [activeFriend, setActiveFriend] = useStateD(window.DUEL_FRIENDS.sam);
  const [incomingRec, setIncomingRec] = useStateD(seedFriendRec);
  const [resume, setResume] = useStateD(() => readDuelProgress());

  const close = () => { if (onExit) onExit(); };

  // Persist in-progress play so a refresh can resume it.
  const handleProgress = (p) => { writeDuelProgress(p); setResume(p); };
  const clearProgress = () => { writeDuelProgress(null); setResume(null); };

  const startNew = (opp) => {
    setOpponent(opp === 'roasty' ? window.DUEL_FRIENDS.roasty : null);
    setStage('pick');
  };
  const pickType = (id) => { setType(id); setStage('play'); };

  const finishPlay = (run) => {
    clearProgress();
    setYouRun(run);
    // Against a known opponent (received/rematch/roasty) → straight to comparison.
    if (opponent) {
      const fr = opponent.isRoasty ? roastyRun(run.type) : (incomingRun(run.type) || window.DEMO_FRIEND_RUN);
      setFriendRun(fr); setActiveFriend(opponent);
      setStage('comparison');
    } else {
      setStage('result');
    }
  };

  // A plausible Roasty run, tuned so it's beatable.
  const roastyRun = (t) => {
    const qs = window.DUEL_QUESTIONS[t] || [];
    const answers = qs.map((q, i) => i === 2 || i === 4 ? (correctIndex(q) + 1) % q.choices.length : correctIndex(q));
    const sc = scoreRun(t, answers);
    return { type: t, answers, perQ: qs.map(() => 7 + Math.random() * 6), timeSec: 49, correct: sc.correct, total: sc.total };
  };
  const incomingRun = (t) => {
    if (incomingRec && incomingRec.type === t) {
      const qs = window.DUEL_QUESTIONS[t] || [];
      // Build a friend run hitting their recorded score.
      const target = incomingRec.theirScore;
      const answers = qs.map((q, i) => i < target ? correctIndex(q) : (correctIndex(q) + 1) % q.choices.length);
      return { type: t, answers, perQ: qs.map(() => 8 + Math.random() * 6), timeSec: incomingRec.theirTime, correct: target, total: qs.length };
    }
    return null;
  };

  switch (stage) {
    case 'pick':
      return <DuelPicker layout={tweaks.picker || 'grid'} opponent={opponent}
        onPick={pickType} onClose={() => setStage('hub')}/>;
    case 'play':
      return <DuelPlay type={type} opponent={opponent}
        resumeState={null}
        onProgress={handleProgress}
        onDone={finishPlay}
        onQuit={() => { setStage('hub'); }}/>;
    case 'resume':
      return <DuelPlay type={resume.type} resumeState={resume}
        onProgress={handleProgress} onDone={finishPlay} onQuit={() => setStage('hub')}/>;
    case 'result':
      return <DuelResult run={youRun} reveal={tweaks.reveal || 'tally'} opponent={opponent}
        onSend={(run) => { setYouRun(run); setStage('invite'); }}
        onClose={() => setStage('hub')}/>;
    case 'invite':
      return <DuelInvite run={youRun} opponent={opponent}
        onShared={() => setStage('sent')} onClose={() => setStage('result')}/>;
    case 'sent':
      return <DuelSent run={youRun} onDone={() => setStage('hub')} onClose={() => setStage('hub')}/>;
    case 'received':
      return <DuelReceived rec={incomingRec}
        onAccept={() => { setType(incomingRec.type); setOpponent(incomingRec.friend); setActiveFriend(incomingRec.friend); setStage('play'); }}
        onClose={() => setStage('hub')}/>;
    case 'comparison':
      return <DuelComparison youRun={youRun} friendRun={friendRun} friend={activeFriend}
        onRematch={() => { setType(youRun.type); setOpponent(activeFriend); setStage('rematch'); }}
        onClose={() => setStage('hub')}/>;
    case 'rematch':
      return <DuelMessage state="awake" eyebrow="REMATCH"
        title={`Round two vs ${activeFriend.name}`}
        body={`Same duel — ${window.duelType(type).name}, five fresh questions. Beat your ${youRun.correct}/5 and settle it.`}
        primary="Play the rematch" onPrimary={() => setStage('play')}
        secondary="Not now" onSecondary={() => setStage('hub')} onClose={() => setStage('hub')}/>;
    case 'expired':
      return <DuelMessage state="sleep" eyebrow="CHALLENGE EXPIRED"
        title="This duel has expired"
        body="Challenges stay open for 7 days. This one timed out before it was played — but you can start a fresh one in seconds."
        primary="Start a new duel" onPrimary={() => { setEmpty(false); setStage('pick'); }}
        secondary="Back to duels" onSecondary={() => setStage('hub')} onClose={close}/>;
    case 'error':
      return <DuelMessage state="wrong" eyebrow="LINK UNAVAILABLE"
        title="We can’t open this duel"
        body="This challenge link is broken, already played, or was cancelled. Nothing’s lost — start your own and send it on."
        primary="Go to Coffee Duel" onPrimary={() => setStage('hub')}
        secondary="Start a duel" onSecondary={() => { setEmpty(false); setStage('pick'); }} onClose={close}/>;
    case 'hub':
    default:
      return <DuelHub empty={empty} resume={resume}
        onStart={startNew}
        onResume={() => setStage('resume')}
        onPlayIncoming={(rec) => { setIncomingRec(rec); setStage('received'); }}
        onOpenSent={(rec) => { setType(rec.type); setYouRun({ ...window.DEMO_YOU_RUN, type: rec.type, correct: rec.yourScore }); setStage('sent'); }}
        onOpenComparison={(rec) => {
          setActiveFriend(rec.friend);
          const yr = { ...window.DEMO_YOU_RUN, type: rec.type, correct: rec.yourScore };
          const frr = { ...window.DEMO_FRIEND_RUN, type: rec.type, correct: rec.theirScore };
          setYouRun(yr); setFriendRun(frr); setStage('comparison');
        }}
        onRematch={(rec) => { setType(rec.type); setActiveFriend(rec.friend); setOpponent(rec.friend); setYouRun({ ...window.DEMO_YOU_RUN, type: rec.type, correct: rec.yourScore }); setStage('rematch'); }}
        onClose={close}/>;
  }
}

// ───────────────────────────────────────────────────────────
// Header entry button — persistent top-right access on main tabs.
// ───────────────────────────────────────────────────────────
function DuelHeaderButton({ count = 0, onClick, locked = false, inHeader = false }) {
  return (
    <button onClick={onClick} aria-label="Coffee Duel" style={{
      ...(inHeader
        ? { position: 'relative' }
        : { position: 'absolute', top: 60, right: 18, zIndex: 60, boxShadow: '0 2px 8px rgba(0,0,0,0.10)' }),
      appearance: 'none', cursor: 'pointer', width: 42, height: 42, borderRadius: 999,
      background: 'var(--surface)', border: '1px solid var(--rule)',
      display: 'grid', placeItems: 'center',
    }}>
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
        {/* crossed coffee-stir motif = duel */}
        <path d="M7 5.5l10 13M17 5.5l-10 13" stroke="var(--accent)" strokeWidth="1.6" strokeLinecap="round"/>
        <circle cx="7" cy="5.5" r="1.7" fill="var(--accent)"/>
        <circle cx="17" cy="5.5" r="1.7" fill="var(--accent)"/>
      </svg>
      {locked
        ? (window.LockBadge ? <window.LockBadge/> : null)
        : (count > 0 && (
          <span className="ff-mono" style={{
            position: 'absolute', top: -4, right: -4, minWidth: 18, height: 18, padding: '0 4px',
            borderRadius: 999, background: 'var(--accent)', color: 'var(--accent-ink)',
            fontSize: 'var(--t-micro)', fontWeight: 500, display: 'grid', placeItems: 'center',
            border: '2px solid var(--bg)',
          }}>{count}</span>
        ))}
    </button>
  );
}

window.DuelFlow = DuelFlow;
window.DuelHeaderButton = DuelHeaderButton;
