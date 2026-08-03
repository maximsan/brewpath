// atlas-activities.jsx — one short interactive activity per origin.
// Four types: identify (from clues), match (region → method), locate (on the
// map), and compare (two origins). Each advances the origin to "Lesson done".

const { useState: useStateAct } = React;

// ── Shared chrome ───────────────────────────────────────────
function ActivityShell({ origin, kindLabel, children, onClose }) {
  return (
    <div className="screen" data-screen-label="Atlas activity" style={{ background: 'var(--bg)' }}>
      <div className="lesson-topbar" style={{ borderBottom: 'none', background: 'transparent' }}>
        <button className="close-btn" onClick={onClose} aria-label="Close">
          <window.CloseMark/>
        </button>
        <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.16em', textTransform: 'uppercase', color: 'var(--ink-mute)', textAlign: 'center' }}>{origin.name}</div>
        <div/>
      </div>
      <div className="scroll" style={{ paddingTop: 108, paddingBottom: 24, display: 'flex', flexDirection: 'column' }}>
        <div className="px-24" style={{ marginBottom: 6 }}>
          <div className="smallcaps" style={{ color: 'var(--accent)' }}>{kindLabel}</div>
        </div>
        {children}
      </div>
    </div>
  );
}

function ResultBar({ correct, text }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'flex-start', gap: 12, padding: '14px 16px', borderRadius: 12,
      border: '1px solid ' + (correct ? 'var(--sage)' : 'var(--berry)'),
      background: correct ? 'color-mix(in oklab, var(--sage) 12%, var(--surface))' : 'color-mix(in oklab, var(--berry) 9%, var(--surface))',
    }}>
      <span style={{ flexShrink: 0, marginTop: 1 }}>
        {correct
          ? <svg width="18" height="18" viewBox="0 0 18 18"><circle cx="9" cy="9" r="8.2" fill="none" stroke="var(--sage)" strokeWidth="1.4"/><path d="M5 9.2l2.6 2.6L13 6.4" fill="none" stroke="var(--sage)" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"/></svg>
          : <svg width="18" height="18" viewBox="0 0 18 18"><circle cx="9" cy="9" r="8.2" fill="none" stroke="var(--berry)" strokeWidth="1.4"/><path d="M9 5v5M9 12.4v.2" stroke="var(--berry)" strokeWidth="1.7" strokeLinecap="round"/></svg>}
      </span>
      <p style={{ margin: 0, fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink)' }}>{text}</p>
    </div>
  );
}

// ── 1 · Identify from clues ─────────────────────────────────
function IdentifyActivity({ origin, onSolved }) {
  const act = origin.activity;
  const [picked, setPicked] = useStateAct(null);
  const [checked, setChecked] = useStateAct(false);
  const correct = picked === act.answer;
  return (
    <>
      <div className="px-24" style={{ flex: 1 }}>
        <h1 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.12, letterSpacing: '-0.01em', margin: '4px 0 18px', color: 'var(--ink)', textWrap: 'pretty' }}>{act.prompt}</h1>

        <div style={{ border: '1px solid var(--rule)', borderRadius: 14, overflow: 'hidden', marginBottom: 22 }}>
          {act.clues.map((c, i) => (
            <div key={i} style={{ display: 'flex', gap: 12, alignItems: 'flex-start', padding: '13px 16px', borderTop: i ? '1px solid var(--rule)' : 'none', background: 'var(--surface)' }}>
              <span className="ff-mono" style={{ fontSize: 'var(--t-label)', color: 'var(--accent)', flexShrink: 0, marginTop: 1 }}>{String(i + 1).padStart(2, '0')}</span>
              <span style={{ fontSize: 'var(--t-body)', lineHeight: 1.45, color: 'var(--ink)' }}>{c}</span>
            </div>
          ))}
        </div>

        <div className="stack gap-12">
          {act.options.map((opt) => {
            let cls = 'mcq-choice';
            if (checked && opt === act.answer) cls += ' correct';
            else if (checked && opt === picked) cls += ' incorrect';
            return (
              <button key={opt} className={cls} disabled={checked} onClick={() => setPicked(opt)}
                      style={picked === opt && !checked ? { borderColor: 'var(--accent)', boxShadow: 'inset 0 0 0 1px var(--accent)' } : null}>
                {opt}
              </button>
            );
          })}
        </div>

        {checked && (
          <div style={{ marginTop: 18 }}>
            <ResultBar correct={correct} text={correct ? `Correct — these clues point to ${act.answer}.` : `Not quite — the answer is ${act.answer}. Re-read the clues and you’ll see why.`}/>
          </div>
        )}
      </div>

      <div className="px-24" style={{ paddingTop: 20 }}>
        {!checked
          ? <button className="btn btn-primary" disabled={picked === null} onClick={() => setChecked(true)}>Check answer</button>
          : <button className="btn btn-primary" onClick={onSolved}>Continue</button>}
      </div>
    </>
  );
}

// ── 2 · Match (region → method / fact) ──────────────────────
function MatchActivity({ origin, onSolved }) {
  const act = origin.activity;
  const lefts = act.pairs.map((p, i) => ({ ...p, i }));
  const [rights] = useStateAct(() => act.pairs.map((p, i) => ({ r: p.r, i })).sort(() => Math.random() - 0.5));
  const [selL, setSelL] = useStateAct(null);
  const [matched, setMatched] = useStateAct({});   // leftIndex -> true
  const [wrong, setWrong] = useStateAct(null);
  const done = Object.keys(matched).length === act.pairs.length;

  const tapRight = (r) => {
    if (selL == null) return;
    if (act.pairs[selL].r === r.r) { setMatched(m => ({ ...m, [selL]: true })); setSelL(null); setWrong(null); }
    else { setWrong(r.i); setTimeout(() => setWrong(null), 480); }
  };

  return (
    <>
      <div className="px-24" style={{ flex: 1 }}>
        <h1 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.12, letterSpacing: '-0.01em', margin: '4px 0 20px', color: 'var(--ink)', textWrap: 'pretty' }}>{act.prompt}</h1>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14 }}>
          <div className="match-col">
            {lefts.map(l => {
              const isM = matched[l.i];
              return (
                <button key={l.i} className={'match-item' + (isM ? ' matched' : '') + (selL === l.i ? ' selected' : '')}
                        disabled={isM} onClick={() => setSelL(l.i)} style={{ textAlign: 'left' }}>{l.l}</button>
              );
            })}
          </div>
          <div className="match-col">
            {rights.map(r => {
              const isM = Object.keys(matched).some(li => act.pairs[li].r === r.r);
              return (
                <button key={r.i} className={'match-item' + (isM ? ' matched' : '')}
                        disabled={isM}
                        onClick={() => tapRight(r)}
                        style={wrong === r.i ? { borderColor: 'var(--berry)', boxShadow: 'inset 0 0 0 1px var(--berry)' } : { textAlign: 'left' }}>{r.r}</button>
              );
            })}
          </div>
        </div>

        <p className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--ink-mute)', marginTop: 18 }}>
          {done ? 'All matched' : (selL != null ? 'Now tap its match →' : 'Tap a tile on the left to start')}
        </p>

        {done && <div style={{ marginTop: 14 }}><ResultBar correct text="Nicely paired — that’s the lot."/></div>}
      </div>

      <div className="px-24" style={{ paddingTop: 20 }}>
        <button className="btn btn-primary" disabled={!done} onClick={onSolved}>Continue</button>
      </div>
    </>
  );
}

// ── 3 · Locate on the map ───────────────────────────────────
function LocateActivity({ origin, states, favs, onSolved }) {
  const act = origin.activity;
  const [result, setResult] = useStateAct(null);   // null | 'hit' | 'miss'
  const WorldMap = window.WorldMap;

  const guess = (o) => {
    if (result === 'hit') return;
    setResult(o.slug === origin.slug ? 'hit' : 'miss');
    if (o.slug !== origin.slug) setTimeout(() => setResult(null), 700);
  };

  return (
    <>
      <div className="px-24" style={{ marginBottom: 12 }}>
        <h1 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.12, letterSpacing: '-0.01em', margin: '4px 0 8px', color: 'var(--ink)' }}>{act.prompt}</h1>
        <p style={{ margin: 0, fontSize: 'var(--t-body)', lineHeight: 1.5, color: 'var(--ink-mute)' }}>{act.hint}</p>
      </div>

      <div style={{ flex: 1, position: 'relative', minHeight: 300, margin: '4px 0', borderTop: '1px solid var(--rule)', borderBottom: '1px solid var(--rule)' }}>
        <WorldMap origins={window.ATLAS_ORIGINS} states={states} favs={favs}
                  styleMode="geo" plain={result !== 'hit'} selectedSlug={result === 'hit' ? origin.slug : null}
                  dimUnselected={result === 'hit'} focusRegion={origin.region}
                  onSelectOrigin={guess}/>
        {result && (
          <div style={{
            position: 'absolute', left: 16, right: 16, bottom: 16, zIndex: 70,
          }}>
            <ResultBar correct={result === 'hit'} text={result === 'hit' ? `That’s ${origin.name}. Spot on.` : 'Not there — try again.'}/>
          </div>
        )}
      </div>

      <div className="px-24" style={{ paddingTop: 16 }}>
        <button className="btn btn-primary" disabled={result !== 'hit'} onClick={onSolved}>Continue</button>
      </div>
    </>
  );
}

// ── 4 · Compare two origins ─────────────────────────────────
function CompareActivity({ origin, onSolved }) {
  const act = origin.activity;
  const [picked, setPicked] = useStateAct(null);
  const [checked, setChecked] = useStateAct(false);
  const correct = picked === act.answer;
  const Opt = ({ name }) => {
    const sel = picked === name;
    let bd = 'var(--rule)', bg = 'var(--surface)';
    if (checked && name === act.answer) { bd = 'var(--sage)'; bg = 'color-mix(in oklab, var(--sage) 12%, var(--surface))'; }
    else if (checked && sel) { bd = 'var(--berry)'; bg = 'color-mix(in oklab, var(--berry) 8%, var(--surface))'; }
    else if (sel) { bd = 'var(--accent)'; }
    return (
      <button disabled={checked} onClick={() => setPicked(name)} style={{
        appearance: 'none', cursor: checked ? 'default' : 'pointer', textAlign: 'center',
        border: '1px solid ' + bd, boxShadow: sel && !checked ? 'inset 0 0 0 1px var(--accent)' : 'none',
        background: bg, borderRadius: 14, padding: '26px 14px', flex: 1,
      }}>
        <div className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, letterSpacing: '-0.01em', color: 'var(--ink)' }}>{name}</div>
        <div className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.14em', textTransform: 'uppercase', color: 'var(--ink-mute)', marginTop: 8 }}>Origin</div>
      </button>
    );
  };
  return (
    <>
      <div className="px-24" style={{ flex: 1 }}>
        <h1 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.12, letterSpacing: '-0.01em', margin: '4px 0 22px', color: 'var(--ink)', textWrap: 'pretty' }}>{act.prompt}</h1>
        <div style={{ display: 'flex', gap: 12, alignItems: 'stretch' }}>
          <Opt name={act.a}/>
          <div style={{ display: 'flex', alignItems: 'center' }}>
            <span className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.1em', color: 'var(--ink-mute)' }}>VS</span>
          </div>
          <Opt name={act.b}/>
        </div>
        {checked && <div style={{ marginTop: 20 }}><ResultBar correct={correct} text={(correct ? '' : `The answer is ${act.answer}. `) + act.because}/></div>}
      </div>
      <div className="px-24" style={{ paddingTop: 20 }}>
        {!checked
          ? <button className="btn btn-primary" disabled={picked === null} onClick={() => setChecked(true)}>Check answer</button>
          : <button className="btn btn-primary" onClick={onSolved}>Continue</button>}
      </div>
    </>
  );
}

const ACT_LABEL = {
  identify: 'Identify the origin',
  match:    'Match them up',
  locate:   'Locate on the map',
  compare:  'Compare two origins',
};

// ── Flow wrapper: play → celebrate → complete ───────────────
function AtlasActivity({ origin, states, favs, onComplete, onClose }) {
  if (!origin) return null;
  const type = origin.activity.type;

  const solved = () => onComplete(origin.slug);
  let body;
  if (type === 'identify') body = <IdentifyActivity origin={origin} onSolved={solved}/>;
  else if (type === 'match') body = <MatchActivity origin={origin} onSolved={solved}/>;
  else if (type === 'locate') body = <LocateActivity origin={origin} states={states} favs={favs} onSolved={solved}/>;
  else body = <CompareActivity origin={origin} onSolved={solved}/>;

  return <ActivityShell origin={origin} kindLabel={ACT_LABEL[type]} onClose={onClose}>{body}</ActivityShell>;
}

window.AtlasActivity = AtlasActivity;
