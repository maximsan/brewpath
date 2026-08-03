// dictionary-extras.jsx — Term of the Day, saved-term Flashcards, Vocab mini-game.
// Loaded after dictionary.jsx, before app.jsx.
// The two Practice screens (Flashcards, Vocab game) share the app's standard
// drill chrome: a lesson-topbar with the roasting-bean counter — the same
// pattern MiniGamePlayer uses — and a Roasty results screen at the end.

const { useState: useStateX, useEffect: useEffectX, useRef: useRefX } = React;

// ════════════════════════════════════════════════════════════
// TERM OF THE DAY
// ════════════════════════════════════════════════════════════
function TermOfDayScreen({ onOpenFull, onOpenTerm, isFav, onToggleFav, onClose }) {
  const term = window.dictTermOfDay ? window.dictTermOfDay() : null;
  const cat = term ? (window.DICT_CAT_BY_ID || {})[term.cat] : null;
  const today = new Date(2026, 5, 18);
  const dateStr = today.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' });
  if (!term) return null;
  return (
    <div className="screen" data-screen-label="Term of the Day" style={{ background: 'var(--bg)' }}>
      <div className="lesson-topbar" style={{ borderBottom: 'none', background: 'transparent' }}>
        <button className="close-btn" onClick={onClose} aria-label="Close">
          <window.CloseMark/>
        </button>
        <div/>
        {window.TopBarFav && <window.TopBarFav active={!!isFav} onClick={onToggleFav} label="Save term" style={{ justifySelf: 'end' }}/>}
      </div>
      <div className="scroll" style={{ paddingTop: 84, display: 'flex', flexDirection: 'column' }}>
        <div className="px-24" style={{ textAlign: 'center' }}>
          <div className="smallcaps" style={{ color: 'var(--accent)' }}>TERM OF THE DAY</div>
          <div className="ff-mono" style={{ fontSize: 'var(--t-label)', color: 'var(--ink-mute)', letterSpacing: '0.1em', textTransform: 'uppercase', marginTop: 8 }}>{dateStr}</div>
        </div>

        <div style={{ display: 'flex', justifyContent: 'center', padding: '14px 0 4px' }}>
          {window.Roasty && <Roasty state="correct" size={120}/>}
        </div>

        <div className="px-24" style={{ textAlign: 'center', paddingTop: 6 }}>
          <span className="smallcaps" style={{ color: 'var(--ink-mute)', display: 'inline-flex', alignItems: 'center', gap: 8 }}>
            <CatGlyph cat={term.cat} size={15} color="var(--ink-mute)"/>{cat ? cat.label : ''}
          </span>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.02, letterSpacing: '-0.03em', margin: '10px 0 0', color: 'var(--ink)' }}>{term.term}</h1>
          {term.pron && <div style={{ marginTop: 14, display: 'flex', justifyContent: 'center' }}><SpeakButton word={term.term} pron={term.pron}/></div>}
        </div>

        <div className="px-24" style={{ paddingTop: 20 }}>
          <p style={{ fontSize: 'var(--t-lead)', lineHeight: 1.5, color: 'var(--ink)', margin: 0, textAlign: 'center', textWrap: 'pretty' }}>{term.short}</p>
        </div>

        <div style={{ flex: 1, minHeight: 24 }}></div>

        <div className="px-24" style={{ position: 'sticky', bottom: 0, paddingTop: 16, paddingBottom: 24, background: 'linear-gradient(to top, var(--bg) 74%, transparent)' }}>
          <button className="btn btn-primary" onClick={() => onOpenFull(term.id)}>Read the full entry</button>
          <div style={{ marginTop: 10 }}>
            <a className="btn btn-ghost" href="#" style={{ display: 'block', textAlign: 'center', textDecoration: 'none' }} onClick={(e) => { e.preventDefault(); onClose(); }}>Back</a>
          </div>
        </div>
      </div>
    </div>
  );
}

// ════════════════════════════════════════════════════════════
// SHARED DRILL CHROME — same topbar as the lesson mini-games:
// close on the left, RoastBean + zero-padded counter centered.
// ════════════════════════════════════════════════════════════
function DrillTopbar({ onClose, pos = 0, total = 0, done, right }) {
  const filled = total ? (done ? 6 : Math.round(((pos + 1) / total) * 6)) : 0;
  const n = (x) => String(x).padStart(2, '0');
  return (
    <div className="lesson-topbar">
      <div style={{ justifySelf: 'start', display: 'flex', alignItems: 'center', gap: 8 }}>
        <button className="close-btn" onClick={onClose} aria-label="Close">
          <window.CloseMark/>
        </button>
      </div>
      {total > 0 ? (
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: 10 }}>
          <RoastBean done={done ? total : pos + 1} total={total}/>
          <span className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.12em', color: 'var(--ink-mute)', textTransform: 'uppercase' }}>
            {n(done ? total : pos + 1)} / {n(total)}
          </span>
        </div>
      ) : <div/>}
      <div style={{ justifySelf: 'end', display: 'flex', alignItems: 'center' }}>{right || null}</div>
    </div>
  );
}

// Roasty results layout shared by both drills (mirrors MiniGamePlayer's).
function DrillResults({ roastyState, kicker, big, bigSub, note, msg, primaryLabel, onPrimary, secondaryLabel, onSecondary }) {
  return (
    <div className="scroll" style={{ paddingTop: 134, paddingBottom: 32, display: 'flex', flexDirection: 'column' }}>
      <div className="px-24" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', flex: '1 0 auto', minHeight: 560 }}>
        <div style={{ paddingTop: 8 }}>
          {window.Roasty && <Roasty state={roastyState} size={150}/>}
        </div>
        <div className="smallcaps" style={{ margin: '24px 0 12px' }}>{kicker}</div>
        <div className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1, color: 'var(--ink)' }}>
          {big}{bigSub && <span style={{ color: 'var(--ink-mute)', fontSize: 'var(--t-title)' }}> {bigSub}</span>}
        </div>
        {note && <div className="smallcaps" style={{ marginTop: 12 }}>{note}</div>}
        <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: '18px 0 0', maxWidth: 300, textWrap: 'pretty' }}>{msg}</p>
        <div style={{ flex: 1 }}/>
        <div style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: 10, paddingTop: 32 }}>
          <button className="btn btn-primary" onClick={onPrimary}>{primaryLabel}</button>
          <button className="btn btn-ghost" onClick={onSecondary}>{secondaryLabel}</button>
        </div>
      </div>
    </div>
  );
}

// ════════════════════════════════════════════════════════════
// FLASHCARDS — saved terms, flippable deck with a finish state
// ════════════════════════════════════════════════════════════
function FlashcardsScreen({ favorites, onToggleFav, onOpenTerm, onBrowse, onClose }) {
  const favs = favorites || new Set();
  const allDeck = (window.DICT_TERMS || []).filter(t => favs.has('t:' + t.id));
  const [order, setOrder] = useStateX(() => allDeck.map((_, i) => i));
  const [pos, setPos] = useStateX(0);
  const [flipped, setFlipped] = useStateX(false);
  const [done, setDone] = useStateX(false);

  // Keep order valid if the saved set shrinks (e.g. user un-saves the last card).
  useEffectX(() => {
    setOrder(prev => {
      const valid = prev.filter(i => i < allDeck.length);
      return valid.length === allDeck.length ? valid : allDeck.map((_, i) => i);
    });
  }, [allDeck.length]);

  const total = allDeck.length;
  const shuffle = () => {
    const arr = allDeck.map((_, i) => i);
    for (let i = arr.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [arr[i], arr[j]] = [arr[j], arr[i]]; }
    setOrder(arr); setPos(0); setFlipped(false); setDone(false);
  };

  // ── empty state ──
  if (!total) {
    return (
      <div className="screen" data-screen-label="Flashcards" style={{ background: 'var(--bg)' }}>
        <DrillTopbar onClose={onClose} total={0}/>
        <div className="scroll" style={{ paddingTop: 134, paddingBottom: 32, display: 'flex', flexDirection: 'column' }}>
          <div className="px-24">
            <div className="smallcaps" style={{ marginBottom: 10 }}>STUDY</div>
            <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>Flashcards</h1>
          </div>
          <div className="px-24" style={{ paddingTop: 60, display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center' }}>
            <div style={{ opacity: 0.5, marginBottom: 18 }}>{window.Bookmark && <window.Bookmark size={44} color="var(--ink-mute)"/>}</div>
            <p style={{ margin: 0, fontSize: 'var(--t-body)', lineHeight: 1.6, color: 'var(--ink-mute)', maxWidth: 280, textWrap: 'pretty' }}>
              Bookmark terms in the dictionary and they become a flashcard deck here — flip to test yourself.
            </p>
            <div style={{ marginTop: 26, width: '100%', maxWidth: 280 }}>
              <button className="btn btn-primary" onClick={onBrowse}>Browse the dictionary</button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // ── deck complete ──
  if (done) {
    return (
      <div className="screen" data-screen-label="Flashcards" style={{ background: 'var(--bg)' }}>
        <DrillTopbar onClose={onClose} pos={total - 1} total={total} done/>
        <DrillResults
          roastyState="correct"
          kicker="FLASHCARDS"
          big={total}
          note={total === 1 ? 'TERM REVIEWED' : 'TERMS REVIEWED'}
          msg="That’s every term you’ve saved. Run it back shuffled, or bookmark more in the dictionary."
          primaryLabel="Shuffle and go again" onPrimary={shuffle}
          secondaryLabel="Done" onSecondary={onClose}/>
      </div>
    );
  }

  const idx = order[Math.min(pos, order.length - 1)];
  const term = allDeck[idx];
  const cat = (window.DICT_CAT_BY_ID || {})[term.cat];
  const go = (d) => {
    setFlipped(false);
    if (d > 0 && pos >= total - 1) { setDone(true); return; }
    setPos(p => Math.max(0, Math.min(total - 1, p + d)));
  };

  const faceStyle = (back) => ({
    position: 'absolute', inset: 0, backfaceVisibility: 'hidden', WebkitBackfaceVisibility: 'hidden',
    transform: back ? 'rotateY(180deg)' : 'none',
    border: '1px solid ' + (back ? 'var(--rule)' : 'color-mix(in oklab, var(--accent) 22%, var(--rule))'),
    borderRadius: 20, padding: '26px 24px',
    background: back
      ? 'var(--surface)'
      : 'linear-gradient(158deg, color-mix(in oklab, var(--accent) 11%, var(--surface)) 0%, var(--surface) 64%)',
    boxShadow: '0 16px 36px rgba(0,0,0,0.18)', display: 'flex', flexDirection: 'column',
  });
  const faceHead = (label) => (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
      <span className="smallcaps" style={{ color: 'var(--accent)', display: 'inline-flex', alignItems: 'center', gap: 8 }}>
        <CatGlyph cat={term.cat} size={15} color="var(--accent)"/>{cat ? cat.label : ''}
      </span>
      <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.16em', textTransform: 'uppercase', color: 'var(--ink-mute)' }}>{label}</span>
    </div>
  );
  const faceFoot = (label) => (
    <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.16em', textTransform: 'uppercase', color: 'var(--ink-mute)', textAlign: 'center', marginTop: 'auto' }}>{label}</div>
  );

  const shuffleBtn = total > 1 ? (
    <button className="close-btn" onClick={shuffle} aria-label="Shuffle deck" style={{ color: 'var(--ink-mute)' }}>
      <svg width="17" height="17" viewBox="0 0 24 24" fill="none"><path d="M16 3h5v5" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"/><path d="M4 20L21 3" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round"/><path d="M21 16v5h-5" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"/><path d="M15 15l6 6" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round"/><path d="M4 4l5 5" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round"/></svg>
    </button>
  ) : null;

  return (
    <div className="screen" data-screen-label="Flashcards" style={{ background: 'var(--bg)' }}>
      <DrillTopbar onClose={onClose} pos={pos} total={total} right={shuffleBtn}/>
      <div className="scroll" style={{ paddingTop: 134, paddingBottom: 24, display: 'flex', flexDirection: 'column' }}>
        <div className="px-24">
          <div className="smallcaps">STUDY · {total} SAVED {total === 1 ? 'TERM' : 'TERMS'}</div>
        </div>

        {/* the card — real 3D flip */}
        <div className="px-24" style={{ paddingTop: 16, flex: 1, display: 'flex', flexDirection: 'column' }}>
          <button onClick={() => setFlipped(f => !f)} aria-label={flipped ? 'Show term' : 'Reveal definition'} style={{
            appearance: 'none', border: 'none', background: 'transparent', padding: 0, cursor: 'pointer',
            display: 'block', width: '100%', flex: 1, minHeight: 380, perspective: '1400px', textAlign: 'left',
          }}>
            <div style={{
              position: 'relative', width: '100%', height: '100%', minHeight: 380,
              transformStyle: 'preserve-3d', transform: flipped ? 'rotateY(180deg)' : 'rotateY(0deg)',
              transition: 'transform 480ms cubic-bezier(0.34, 1.1, 0.4, 1)',
            }}>
              {/* front — term */}
              <div style={faceStyle(false)}>
                {faceHead('TERM')}
                <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', gap: 14 }}>
                  <h2 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.04, letterSpacing: '-0.03em', margin: 0, color: 'var(--ink)' }}>{term.term}</h2>
                  {term.pron && <div className="ff-mono" style={{ fontSize: 'var(--t-label)', color: 'var(--ink-mute)' }}>{term.pron}</div>}
                </div>
                {faceFoot('TAP TO REVEAL')}
              </div>
              {/* back — definition */}
              <div style={faceStyle(true)}>
                {faceHead('DEFINITION')}
                <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
                  <h3 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, letterSpacing: '-0.01em', margin: '0 0 14px', color: 'var(--ink)' }}>{term.term}</h3>
                  <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink)', margin: 0, textWrap: 'pretty' }}>{term.short}</p>
                </div>
                {faceFoot('TAP TO SEE TERM')}
              </div>
            </div>
          </button>

          <div style={{ display: 'flex', alignItems: 'stretch', gap: 10, paddingTop: 16 }}>
            <button className="btn btn-ghost" style={{ width: 'auto', flex: 1, padding: '16px 24px' }} disabled={pos === 0} onClick={() => go(-1)}>‹ Prev</button>
            <button className="btn btn-primary" style={{ width: 'auto', flex: 1 }} onClick={() => go(1)}>{pos >= total - 1 ? 'Finish' : 'Next ›'}</button>
          </div>
          <div style={{ textAlign: 'center', paddingTop: 6 }}>
            <button className="btn btn-link" onClick={() => onOpenTerm(term.id)}>View full entry →</button>
          </div>
        </div>
      </div>
    </div>
  );
}

// ════════════════════════════════════════════════════════════
// VOCAB MINI-GAME — definition → guess the term
// ════════════════════════════════════════════════════════════
// Questions come from `pool` (saved terms or the whole glossary); distractors
// always come from the full glossary, preferring the answer's own category
// (2 of 3) so wrong choices stay plausible.
function buildVocabRounds(n, pool) {
  const all = (window.DICT_TERMS || []).filter(t => t.short);
  const src = (pool && pool.length >= 4) ? pool : all;
  const picks = [...src].sort(() => Math.random() - 0.5).slice(0, Math.min(n, src.length));
  return picks.map(answer => {
    const sameCat = all.filter(t => t.id !== answer.id && t.cat === answer.cat).sort(() => Math.random() - 0.5);
    const others = all.filter(t => t.id !== answer.id && t.cat !== answer.cat).sort(() => Math.random() - 0.5);
    const distractors = [...sameCat.slice(0, 2), ...others].slice(0, 3);
    const choices = [...distractors, answer].sort(() => Math.random() - 0.5);
    return { answer, choices };
  });
}

const VOCAB_LENGTHS = [[5, 'Quick'], [8, 'Standard'], [12, 'Deep']];
const VOCAB_MIN_SAVED = 4;
const VOCAB_MISS_KEY = 'bp-vocab-misses';
function readMisses() {
  try { const v = JSON.parse(localStorage.getItem(VOCAB_MISS_KEY) || '[]'); return new Set(Array.isArray(v) ? v : []); } catch (e) { return new Set(); }
}
function writeMisses(set) {
  try { localStorage.setItem(VOCAB_MISS_KEY, JSON.stringify([...set])); } catch (e) {}
}

function VocabGameScreen({ favorites, onClose, onOpenTerm }) {
  const favs = favorites || new Set();
  const glossary = (window.DICT_TERMS || []).filter(t => t.short);
  const savedPool = glossary.filter(t => favs.has('t:' + t.id));
  const canSaved = savedPool.length >= VOCAB_MIN_SAVED;
  const [misses, setMisses] = useStateX(readMisses);
  const missPool = glossary.filter(t => misses.has(t.id));
  const canMisses = missPool.length >= VOCAB_MIN_SAVED;
  const [logged, setLogged] = useStateX(0);

  const [deck, setDeck] = useStateX(canSaved ? 'saved' : 'all');
  const [len, setLen] = useStateX(5);
  const [phase, setPhase] = useStateX('setup');
  const [rounds, setRounds] = useStateX([]);
  const [i, setI] = useStateX(0);
  const [picked, setPicked] = useStateX(null);
  const [score, setScore] = useStateX(0);
  const [done, setDone] = useStateX(false);

  const poolFor = (d) => d === 'saved' ? savedPool : d === 'misses' ? missPool : glossary;
  // A deck the UI marks unavailable must never stay the selection: fall back to
  // the glossary when the saved/miss pool drops below the minimum mid-session.
  const activeDeck = (deck === 'saved' && !canSaved) || (deck === 'misses' && !canMisses) ? 'all' : deck;
  const activePool = poolFor(activeDeck);
  const fits = VOCAB_LENGTHS.filter(([n]) => n <= activePool.length).map(([n]) => n);
  const activeLen = len <= activePool.length ? len : (fits.length ? Math.max(...fits) : null);
  const start = () => {
    const pool = activePool;
    setRounds(buildVocabRounds(Math.min(activeLen || len, pool.length), pool));
    setI(0); setPicked(null); setScore(0); setLogged(0); setDone(false); setPhase('play');
  };
  const restart = start;

  // ── round setup ──
  if (phase === 'setup') {
    const pool = activePool;
    // On-system selection: the global .pick-card component (Fraunces title,
    // 2px radius, selected = accent border + inset stroke — never a fill).
    const dim = (disabled) => disabled ? { opacity: 0.45, cursor: 'default' } : { cursor: 'pointer' };
    return (
      <div className="screen" data-screen-label="Vocab game setup" style={{ background: 'var(--bg)' }}>
        <DrillTopbar onClose={onClose} total={0}/>
        <div className="scroll" style={{ paddingTop: 110, paddingBottom: 28, display: 'flex', flexDirection: 'column' }}>
          <div className="px-24">
            <div className="smallcaps" style={{ marginBottom: 10 }}>PRACTICE</div>
            <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>Vocab game</h1>
            <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink-mute)', margin: '12px 0 0', textWrap: 'pretty' }}>Read a definition, pick the term. Choose your deck and how long a round you want.</p>
          </div>
          <div className="px-24" style={{ paddingTop: 26 }}>
            <div className="smallcaps" style={{ marginBottom: 10 }}>DECK</div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              {[
                { id: 'saved', title: 'Saved terms', note: canSaved ? 'The terms you\u2019ve bookmarked' : 'Save ' + VOCAB_MIN_SAVED + '+ terms to unlock', count: savedPool.length, disabled: !canSaved },
                { id: 'all', title: 'Whole glossary', note: 'Every term in the dictionary', count: glossary.length, disabled: false },
                { id: 'misses', title: 'Review misses', note: canMisses ? 'Terms you’ve missed before' : 'Miss a few first', count: missPool.length, disabled: !canMisses },
              ].map(d => (
                <div key={d.id} className={'pick-card' + (activeDeck === d.id ? ' selected' : '')} style={dim(d.disabled)} onClick={() => !d.disabled && setDeck(d.id)}>
                  <div>
                    <div className="pc-title">{d.title}</div>
                    <div className="pc-desc">{d.note}</div>
                  </div>
                  <span className="ff-mono" style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', whiteSpace: 'nowrap' }}>{d.count}</span>
                </div>
              ))}
            </div>
          </div>
          <div className="px-24" style={{ paddingTop: 24 }}>
            <div className="smallcaps" style={{ marginBottom: 10 }}>ROUND LENGTH</div>
            {fits.length === 0 ? (
              <div className="pick-card selected" style={{ display: 'block', textAlign: 'center', padding: '16px 8px', cursor: 'default' }}>
                <div className="pc-title ff-mono" style={{ fontSize: 'var(--t-title)' }}>{pool.length}</div>
                <div className="pc-desc">Every term in this deck</div>
              </div>
            ) : (
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10 }}>
              {VOCAB_LENGTHS.map(([n, label]) => {
                const capped = n > pool.length;
                return (
                  <div key={n} className={'pick-card' + (activeLen === n ? ' selected' : '')} style={{ ...dim(capped), display: 'block', textAlign: 'center', padding: '16px 8px' }} onClick={() => !capped && setLen(n)}>
                    <div className="pc-title" style={{ fontSize: 'var(--t-title)' }}>{n}</div>
                    <div className="pc-desc">{label}</div>
                  </div>
                );
              })}
            </div>
            )}
            {activeDeck !== 'all' && pool.length < 12 && (
              <p style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', margin: '12px 0 0', lineHeight: 1.5 }}>{activeDeck === 'misses' ? 'Longer rounds unlock as you log more misses.' : 'Longer rounds unlock as you bookmark more terms.'}</p>
            )}
          </div>
          <div style={{ flex: 1, minHeight: 20 }}/>
          <div className="px-24" style={{ paddingTop: 22 }}>
            <button className="btn btn-primary" onClick={start}>Start round</button>
          </div>
        </div>
      </div>
    );
  }

  if (done) {
    const pct = Math.round((score / rounds.length) * 100);
    const msg = pct >= 80 ? 'Sharp palate. You know this one cold.'
      : pct >= 50 ? 'Solid round — run it back to sharpen up.'
      : 'Worth another pass. Try again?';
    const tail = logged > 0 ? ' The ' + logged + (logged === 1 ? ' term you missed was' : ' terms you missed were') + ' added to your review deck.' : '';
    return (
      <div className="screen" data-screen-label="Vocab game" style={{ background: 'var(--bg)' }}>
        <DrillTopbar onClose={onClose} pos={rounds.length - 1} total={rounds.length} done/>
        <DrillResults
          roastyState={pct >= 80 ? 'module' : 'correct'}
          kicker="VOCAB GAME"
          big={score} bigSub={'/ ' + rounds.length}
          note="TERMS MATCHED"
          msg={msg + tail}
          primaryLabel="Play again" onPrimary={restart}
          secondaryLabel="Change round" onSecondary={() => setPhase('setup')}/>
      </div>
    );
  }

  const round = rounds[i];
  const correctIdx = round.choices.findIndex(c => c.id === round.answer.id);
  const cat = (window.DICT_CAT_BY_ID || {})[round.answer.cat];

  const pick = (idx) => {
    if (picked !== null) return;
    setPicked(idx);
    const next = new Set(misses);
    if (idx === correctIdx) { setScore(s => s + 1); next.delete(round.answer.id); }
    else { next.add(round.answer.id); setLogged(n => n + 1); }
    setMisses(next); writeMisses(next);
  };
  const next = () => {
    if (i + 1 >= rounds.length) setDone(true);
    else { setI(i + 1); setPicked(null); }
  };

  return (
    <div className="screen" data-screen-label="Vocab game" style={{ background: 'var(--bg)' }}>
      <DrillTopbar onClose={onClose} pos={i} total={rounds.length}/>
      <div className="scroll" style={{ paddingTop: 134, paddingBottom: 28, display: 'flex', flexDirection: 'column' }}>
        <div key={i} className="fade-up" style={{ flex: '1 0 auto', display: 'flex', flexDirection: 'column' }}>
          <div className="px-24">
            <span className="smallcaps" style={{ color: 'var(--ink-mute)', display: 'inline-flex', alignItems: 'center', gap: 8 }}>
              <CatGlyph cat={round.answer.cat} size={15} color="var(--ink-mute)"/>{cat ? cat.label : ''}
            </span>
            <div className="smallcaps" style={{ margin: '16px 0 10px', color: 'var(--accent)' }}>WHICH TERM MEANS…</div>
            <p className="ff-display" style={{ fontSize: 'var(--t-title)', lineHeight: 1.25, fontWeight: 400, letterSpacing: '-0.01em', margin: 0, color: 'var(--ink)', textWrap: 'pretty' }}>{round.answer.short}</p>
          </div>

          <div className="px-24" style={{ paddingTop: 24, display: 'flex', flexDirection: 'column', gap: 10 }}>
            {round.choices.map((c, idx) => {
              let cls = 'mcq-choice';
              if (picked !== null) { if (idx === correctIdx) cls += ' correct'; else if (idx === picked) cls += ' incorrect'; }
              return (
                <button key={c.id} className={cls} disabled={picked !== null} onClick={() => pick(idx)}>
                  {c.term}
                </button>
              );
            })}
          </div>

          {picked !== null && (
            <div className="px-24" style={{ paddingTop: 18, display: 'flex', gap: 12, alignItems: 'flex-start' }}>
              <div style={{ flexShrink: 0, marginTop: -4 }}>{window.Roasty && <Roasty state={picked === correctIdx ? 'correct' : 'wrong'} size={48}/>}</div>
              <div style={{ flex: 1 }}>
                <div className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.14em', textTransform: 'uppercase', color: picked === correctIdx ? 'var(--sage)' : 'var(--accent)', marginBottom: 6 }}>
                  {picked === correctIdx ? 'CORRECT' : 'NOT QUITE — IT’S ' + round.answer.term.toUpperCase()}
                </div>
                <button onClick={() => onOpenTerm(round.answer.id)} className="btn btn-link" style={{ padding: 0, fontSize: 'var(--t-support)' }}>See the full entry →</button>
              </div>
            </div>
          )}

          <div style={{ flex: 1, minHeight: 16 }}/>
          <div className="px-24" style={{ paddingTop: 20 }}>
            <button className="btn btn-primary" onClick={next} disabled={picked === null}>
              {i + 1 >= rounds.length ? 'See score' : 'Next question'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

window.TermOfDayScreen = TermOfDayScreen;
window.FlashcardsScreen = FlashcardsScreen;
window.VocabGameScreen = VocabGameScreen;
