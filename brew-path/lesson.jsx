// lesson.jsx — lesson player with all card kinds + completion screen

const { useState: useStateL, useEffect: useEffectL, useRef: useRefL } = React;

// How-to-play copy for each interactive card, surfaced from the "?" in the
// top bar as a bottom-sheet drawer. Mirrors the standalone mini-game intros:
// icon + blurb + numbered steps.
const GAME_HELP = {
  mcq: {
    title: 'Multiple choice',
    blurb: 'Read the question and pick the answer you think is right — an explanation follows either way.',
    steps: ['Read the question', 'Tap the answer you think is right', 'See the explanation, then continue'],
  },
  multi: {
    title: 'Select all that apply',
    blurb: 'More than one answer can be right. Tap every option you think belongs, then check them all at once.',
    steps: ['Read the question', 'Tap every correct answer', 'Check answers to grade the whole set'],
  },
  match: {
    title: 'Match pairs',
    blurb: 'Drag each trait onto the item it belongs to — or tap one then the other. Several traits can share the same answer, and the board only scores if every pair lands first time.',
    steps: ['Drag a trait onto its match (or tap both)', 'It locks in when it’s right', 'Clear the board with no wrong drops'],
  },
  slider: {
    title: 'Calibrate',
    blurb: 'Drag the slider to where you think the answer lands, then check to see how close you were.',
    steps: ['Read the question', 'Drag the slider to your best guess', 'Check to see if you hit the range'],
  },
  sequence: {
    title: 'Put in order',
    blurb: 'Tap the items in the correct order, then submit to see which spots you got right.',
    steps: ['Read the prompt', 'Tap the items in the right order', 'Submit to reveal the correct order'],
  },
  quiz: {
    title: 'True or false',
    blurb: 'Read the statement and decide whether it’s true or false — an explanation follows either way.',
    steps: ['Read the statement', 'Tap True or False', 'See the explanation, then continue'],
  },
  flavor: {
    title: 'Name the note',
    blurb: 'Read the tasting clue and pick the flavour note it describes.',
    steps: ['Read the tasting clue', 'Pick the matching note', 'See the explanation, then continue'],
  },
  tastefix: {
    title: 'Taste Fix',
    blurb: 'Your cup came out wrong. Read what\u2019s off, then pick the one change you\u2019d try first \u2014 the feedback names the cause either way.',
    steps: ['Read what the cup tastes like', 'Pick the fix you\u2019d try first', 'See why it works, then continue'],
  },
  bagpick: {
    title: 'Blind bag',
    blurb: 'An unlabelled bag of green coffee. Inspect the sample — colour, centre cut, aroma — then call how it was processed from the look alone.',
    steps: ['Tap each cue to inspect the sample', 'Weigh what the beans are telling you', 'Call the process — the tell is named either way'],
  },
  fill: {
    title: 'Complete the sentence',
    blurb: 'Key words are left blank. Fill each one from the two choices \u2014 the sentence resolves to the right answer either way, so you always leave with the correct idea.',
    steps: ['Read the sentence with its blanks', 'Tap a word to fill each blank', 'The finished sentence is the takeaway'],
  },
};

function HelpDrawer({ open, kind, help, onClose }) {
  if (!help) return null;
  return (
    <React.Fragment>
      <div className={'help-scrim' + (open ? ' open' : '')} onClick={onClose}/>
      <div className={'help-sheet' + (open ? ' open' : '')} role="dialog" aria-modal="true">
        <div className="help-grip"/>
        <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
          <div style={{
            width: 44, height: 44, borderRadius: 12, flexShrink: 0,
            border: '1px solid var(--rule)', background: 'var(--surface-2)',
            display: 'grid', placeItems: 'center',
          }}>
            {window.ReplayIcon ? <window.ReplayIcon kind={kind} size={22}/> : null}
          </div>
          <div>
            <div className="smallcaps" style={{ marginBottom: 4, color: 'var(--accent)' }}>How to play</div>
            <h3 className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.01em', margin: 0, color: 'var(--ink)' }}>{help.title}</h3>
          </div>
        </div>
        <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: '16px 0 0', textWrap: 'pretty' }}>{help.blurb}</p>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 11, marginTop: 20 }}>
          {help.steps.map((step, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'baseline', gap: 12 }}>
              <span className="ff-mono" style={{ fontSize: 'var(--t-support)', letterSpacing: '0.06em', color: 'var(--accent)', flexShrink: 0 }}>{String(i + 1).padStart(2, '0')}</span>
              <span style={{ fontSize: 'var(--t-support)', lineHeight: 1.45, color: 'var(--ink)' }}>{step}</span>
            </div>
          ))}
        </div>
        <button className="btn btn-primary" style={{ marginTop: 24 }} onClick={onClose}>Got it</button>
      </div>
    </React.Fragment>
  );
}

// Inline how-to-play cue — the game-type phrase with a "?" beside it that opens
// the how-to-play drawer for this card kind. Self-contained (owns its open
// state + drawer) so it renders identically inside the lesson player and the
// standalone mini-games, wherever a game card lives.
function GameCue({ kind, children }) {
  const [open, setOpen] = useStateL(false);
  const help = GAME_HELP[kind];
  return (
    <React.Fragment>
      <div className="smallcaps" style={{
        display: 'flex', alignItems: 'center', gap: 8, lineHeight: 1,
        marginBottom: 12, color: 'var(--accent)',
      }}>
        <span style={{ lineHeight: 1, fontSize: 'var(--t-support)' }}>{children}</span>
        {help && (
          <button onClick={() => setOpen(true)} aria-label="How to play"
                  style={{ appearance: 'none', background: 'transparent', border: 0, padding: 0, margin: '-13px -8px',
                           width: 44, height: 44, minWidth: 44, cursor: 'pointer', display: 'grid', placeItems: 'center', flexShrink: 0 }}>
            <span className="help-btn" aria-hidden="true"
                  style={{ width: 20, height: 20, minWidth: 20, fontSize: 'var(--t-label)', lineHeight: 1, pointerEvents: 'none' }}>?</span>
          </button>
        )}
      </div>
      {help && <HelpDrawer open={open} kind={kind} help={help} onClose={() => setOpen(false)}/>}
    </React.Fragment>
  );
}

function LessonPlayer({ lessonId, onClose, onComplete, nextLessonId, isFav, onToggleFav, onTermTap, startKind, favorites, onToggleFavKey }) {
  const lesson = LESSONS[lessonId];
  // The opening `predict` card's guess, held at lesson scope so the closing
  // `recall` card can resolve it. Cleared whenever a new lesson opens.
  const [prediction, setPrediction] = useStateL(null);
  useEffectL(() => { setPrediction(null); }, [lessonId]);

  // overview routing straight to the MCQ / Match / Slider / Sequence card),
  // open the player on the first card of that kind.
  const startAt = (startKind && lesson)
    ? Math.max(0, lesson.cards.findIndex(c => c.kind === startKind))
    : 0;
  const [idx, setIdx] = useStateL(startAt);
  const [key, setKey] = useStateL(0); // re-trigger fade on advance
  const [toast, setToast] = useStateL(null); // { amount, t }
  const toastTimer = useRefL(null);
  // Track a "perfect" run: count quiz cards and how many were answered
  // correctly. Each quiz card fires onXp exactly once, and only on success.
  const correctRef = useRefL(0);

  if (!lesson) return null;
  const card = lesson.cards[idx];
  const total = lesson.cards.length;
  const quizTotal = lesson.cards.filter(c => ['mcq', 'multi', 'match', 'slider', 'sequence', 'tastefix', 'bagpick', 'decision', 'recall'].includes(c.kind)).length;

  const advance = () => {
    if (idx + 1 >= total) {
      onComplete(lesson, { total: quizTotal, quizTotal, correct: correctRef.current, perfect: quizTotal > 0 && correctRef.current >= quizTotal });
    } else {
      setIdx(idx + 1);
      setKey(k => k + 1);
    }
  };

  // A correct answer signals "count it" for the score — it no longer shows a
  // points toast. Points appear only on the result screen (effort/habit), so
  // mid-lesson feedback stays purely qualitative (Roasty's correct/wrong react).
  const showXp = () => {
    correctRef.current += 1; // an onXp call == one correctly-answered quiz card
  };

  // wedge progress (6 wedges)
  const filled = Math.round(((idx + 1) / total) * 6);

  return (
    <div className="screen" data-screen-label="Lesson Player" style={{ background: 'var(--bg)' }}>
      <div className="lesson-topbar">
        <div style={{ justifySelf: 'start', display: 'flex', alignItems: 'center', gap: 8 }}>
          <button className="close-btn" onClick={onClose} aria-label="Close">
            <window.CloseMark/>
          </button>
        </div>
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: 10 }}>
          <RoastBean done={idx + 1} total={total}/>
          <span className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.12em', color: 'var(--ink-mute)', textTransform: 'uppercase' }}>
            {String(idx + 1).padStart(2, '0')} / {String(total).padStart(2, '0')}
          </span>
        </div>
        <div style={{ justifySelf: 'end', display: 'flex', alignItems: 'center', gap: 8 }}>
          {window.TopBarFav && <window.TopBarFav active={!!isFav} onClick={() => onToggleFav && onToggleFav()} label="Save lesson"/>}
        </div>
      </div>

      <div className="scroll" style={{ paddingTop: 134, paddingBottom: 32, display: 'flex', flexDirection: 'column' }}>
        <div key={key} className="fade-up" style={{ flex: '1 0 auto', display: 'flex', flexDirection: 'column' }}>
          {card.kind === 'predict'  && window.PredictCard && <window.PredictCard card={card} onContinue={advance} onPredict={setPrediction} onTermTap={onTermTap}/>}
          {card.kind === 'decision' && window.DecisionCard && <window.DecisionCard card={card} onContinue={advance} onXp={showXp} onTermTap={onTermTap}/>}
          {card.kind === 'recall'   && window.RecallCard && <window.RecallCard card={card} onContinue={advance} onXp={showXp} prediction={prediction}/>}
          {card.kind === 'concept'  && <ConceptCard card={card} onContinue={advance} onTermTap={onTermTap}/>}
          {card.kind === 'visual'    && window.VisualLessonCard && <window.VisualLessonCard card={card} onContinue={advance}
            saved={!!(favorites && favorites.has('g:' + card.variant))}
            onToggleSave={onToggleFavKey ? () => onToggleFavKey('g:' + card.variant) : null}/>}
          {card.kind === 'tastefix'  && window.TasteFixCard && <window.TasteFixCard card={card} onContinue={advance} onXp={showXp}/>}
          {card.kind === 'bagpick'   && window.BagPickCard && <window.BagPickCard card={card} onContinue={advance} onXp={showXp}/>}
          {card.kind === 'practical' && window.PracticalCard && <window.PracticalCard card={card} onContinue={advance}/>}
          {card.kind === 'mcq'      && <MCQCard card={card} onContinue={advance} onXp={showXp}/>}
          {card.kind === 'multi'    && <MultiCard card={card} onContinue={advance} onXp={showXp}/>}
          {card.kind === 'match'    && <MatchCard card={card} onContinue={advance} onXp={showXp}/>}
          {card.kind === 'slider'   && <SliderCard card={card} onContinue={advance} onXp={showXp}/>}
          {card.kind === 'sequence' && <SequenceCard card={card} onContinue={advance} onXp={showXp}/>}
        </div>
      </div>
    </div>
  );
}

// Wrap recognised glossary terms in tappable spans when a handler is present.
function maybeLinkTerms(text, onTermTap) {
  return (onTermTap && window.linkifyTerms) ? window.linkifyTerms(text, onTermTap) : text;
}

function ConceptCard({ card, onContinue, onTermTap }) {
  if (card.fill) return <ConceptFillCard card={card} onContinue={onContinue} onTermTap={onTermTap}/>;
  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', flex: '1 0 auto', minHeight: 600 }}>
      <div className="smallcaps" style={{ marginBottom: 14 }}>{card.label}</div>
      <h2 className="ff-display" style={{
        fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.01em',
        margin: 0, color: 'var(--ink)',
      }}>{card.title}</h2>

      <div style={{ marginTop: 20 }}>
        {card.paragraphs.map((p, i) => (
          <p key={i} style={{
            fontSize: 'var(--t-body)', lineHeight: 1.6, color: 'var(--ink)',
            marginTop: i === 0 ? 0 : 16, marginBottom: 0,
            textWrap: 'pretty',
          }}>{maybeLinkTerms(p, onTermTap)}</p>
        ))}
      </div>

      {card.meta && (
        <div style={{ marginTop: 28 }}>
          {card.meta.map(([k, v], i) => (
            <FormRow key={i} label={k} value={v}/>
          ))}
        </div>
      )}

      <div style={{ flex: 1 }}/>
      <div style={{ paddingTop: 32 }}>
        <button className="btn btn-primary" onClick={onContinue}>Continue</button>
      </div>
    </div>
  );
}

// THE blank. One inline slot for every fill-in-the-blank mechanic in the app —
// concept sentences (graded) and the predict card's cloze question (a guess).
// States: empty (dashed, waiting) · guess (accent, ungraded) · filled (locked,
// unchecked) · right (sage) · wrong (berry). Set `inherit` when the slot sits
// inside display type so it keeps the sentence's own face instead of mono.
function FillSlot({ word, state = 'empty', inherit }) {
  const cls = 'fill-slot'
    + (state === 'empty' ? '' : ' filled')
    + (state === 'right' || state === 'wrong' || state === 'guess' ? ' ' + state : '')
    + (inherit ? ' inherit' : '');
  return <span className={cls}>{word != null && word !== '' ? word : '\u00a0'}</span>;
}
window.FillSlot = FillSlot;

// Concept card as a "complete the sentence" interaction. card.fill is an array of
// parts: strings render as prose, objects { a, o, label } render as an inline blank
// with a two-choice bank below. Picks lock on first tap (no retry, no scoring); the
// blank always resolves to the correct word so the finished sentence reads true.
function ConceptFillCard({ card, onContinue, onTermTap }) {
  const parts = card.fill;
  const blankIdx = parts.map((p, i) => (typeof p === 'object' ? i : -1)).filter(i => i >= 0);
  const [picks, setPicks] = useStateL({}); // part index -> chosen option
  const [checked, setChecked] = useStateL(false);
  const pick = (pi, opt) => { if (!checked) setPicks(prev => ({ ...prev, [pi]: opt })); };
  const allPicked = blankIdx.every(i => picks[i] != null);
  const allRight = blankIdx.every(i => picks[i] === parts[i].a);
  const support = (card.paragraphs || []).slice(1, 2);

  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', flex: '1 0 auto', minHeight: 600 }}>
      <GameCue kind="fill">Complete the sentence</GameCue>
      <h2 className="ff-display" style={{
        fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.01em',
        margin: '0 0 4px', color: 'var(--ink)', textWrap: 'pretty',
      }}>{card.title}</h2>

      <p style={{ fontSize: 'var(--t-lead)', lineHeight: 1.7, color: 'var(--ink)', marginTop: 20, textWrap: 'pretty' }}>
        {parts.map((p, i) => {
          if (typeof p === 'string') return <React.Fragment key={i}>{p}</React.Fragment>;
          const picked = picks[i];
          // always show the learner's own pick; after checking, colour it by correctness
          // (the option row below marks which word was right)
          const shown = picked;
          const state = checked && picked != null ? (picked === p.a ? 'right' : 'wrong') : '';
          return (
            <FillSlot key={i} word={shown} state={shown == null ? 'empty' : (state || 'filled')}/>
          );
        })}
      </p>

      <div className="fill-groups">
        {blankIdx.map(pi => {
          const b = parts[pi];
          const chosen = picks[pi];
          return (
            <div key={pi} className={'fill-group' + (checked ? ' solved' : '')}>
              {b.label && <div className="fill-rl">{b.label}</div>}
              <div className="fill-opts">
                {b.o.map((opt, j) => {
                  let cls = 'mcq-choice';
                  if (checked) {
                    if (opt === b.a) cls += ' correct';
                    else if (opt === chosen) cls += ' incorrect';
                  } else if (opt === chosen) {
                    cls += ' picked';
                  }
                  return (
                    <button key={j} className={cls} disabled={checked}
                            onClick={() => pick(pi, opt)}>{opt}</button>
                  );
                })}
              </div>
            </div>
          );
        })}
      </div>

      {checked && (
        <div className="fade-up" style={{ marginTop: 22, display: 'flex', gap: 14, alignItems: 'flex-start' }}>
          <div style={{ flexShrink: 0, marginTop: -8 }}>
            <Roasty state={allRight ? 'correct' : 'wrong'} size={72}/>
          </div>
          <div style={{ flex: 1 }}>
            <div className="ff-mono" style={{
              fontSize: 'var(--t-label)', letterSpacing: '0.14em',
              color: allRight ? 'var(--sage)' : 'var(--berry)',
              textTransform: 'uppercase', marginBottom: 8,
            }}>
              {allRight ? 'CORRECT' : 'NOT QUITE'}
            </div>
            {support.length > 0 && (
              <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: 0, textWrap: 'pretty' }}>
                {maybeLinkTerms(support[0], onTermTap)}
              </p>
            )}
          </div>
        </div>
      )}

      <div style={{ flex: 1 }}/>
      <div style={{ paddingTop: 32 }}>
        {!checked
          ? <button className="btn btn-primary" onClick={() => setChecked(true)} disabled={!allPicked}>Check answers</button>
          : <button className="btn btn-primary" onClick={onContinue}>Continue</button>}
      </div>
    </div>
  );
}

function MCQCard({ card, onContinue, onXp }) {
  const [picked, setPicked] = useStateL(null);
  const correctIdx = card.choices.findIndex(c => c.correct);
  // Render order only — shuffled once per mount so the correct choice is not
  // always first. Grading, feedback and XP all key off the authored index.
  const [order] = useStateL(() => shuffledIdx(card.choices.length));

  const handlePick = (i) => {
    if (picked !== null) return;
    setPicked(i);
    if (i === correctIdx && onXp) onXp(2);
  };

  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', flex: '1 0 auto', minHeight: 600 }}>
      <GameCue kind="mcq">Multiple choice · pick one</GameCue>
      <h2 className="ff-display" style={{
        fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.01em',
        margin: 0, color: 'var(--ink)', textWrap: 'pretty',
      }}>{card.prompt}</h2>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 24 }}>
        {order.map((oi) => {
          let cls = 'mcq-choice';
          if (picked !== null) {
            if (oi === correctIdx) cls += ' correct';
            else if (oi === picked) cls += ' incorrect';
          }
          return (
            <button key={oi} className={cls}
                    disabled={picked !== null}
                    onClick={() => handlePick(oi)}>
              {card.choices[oi].t}
            </button>
          );
        })}
      </div>

      {picked !== null && (
        <div style={{ marginTop: 20, display: 'flex', gap: 14, alignItems: 'flex-start' }}>
          {/* Roasty reacts to the answer */}
          <div style={{ flexShrink: 0, marginTop: -8 }}>
            <Roasty state={picked === correctIdx ? 'correct' : 'wrong'} size={72}/>
          </div>
          <div style={{ flex: 1 }}>
            <div className="ff-mono" style={{
              fontSize: 'var(--t-label)', letterSpacing: '0.14em',
              color: picked === correctIdx ? 'var(--sage)' : 'var(--berry)',
              textTransform: 'uppercase', marginBottom: 8,
            }}>
              {picked === correctIdx ? 'CORRECT' : 'NOT QUITE'}
            </div>
            <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: 0 }}>
              {card.explain}
            </p>
          </div>
        </div>
      )}

      <div style={{ flex: 1 }}/>
      <div style={{ paddingTop: 32 }}>
        <button className="btn btn-primary" onClick={onContinue} disabled={picked === null}>Continue</button>
      </div>
    </div>
  );
}

function MultiCard({ card, onContinue, onXp }) {
  const [sel, setSel] = useStateL(() => new Set());
  const [submitted, setSubmitted] = useStateL(false);
  const [paidXp, setPaidXp] = useStateL(false);
  // Render order only — keeps the correct options from clustering at the top.
  const [order] = useStateL(() => shuffledIdx(card.choices.length));

  const correctSet = React.useMemo(
    () => new Set(card.choices.map((c, i) => (c.correct ? i : -1)).filter(i => i >= 0)),
    [card]
  );

  const toggle = (i) => {
    if (submitted) return;
    setSel(s => { const n = new Set(s); n.has(i) ? n.delete(i) : n.add(i); return n; });
  };

  const allRight = sel.size === correctSet.size && [...sel].every(i => correctSet.has(i));

  const submit = () => {
    if (submitted) return;
    setSubmitted(true);
    if (allRight && !paidXp) { setPaidXp(true); onXp && onXp(3); }
  };

  const CheckMark = () => (
    <svg width="13" height="13" viewBox="0 0 14 14" aria-hidden="true">
      <path d="M2 7.5 L5.5 11 L12 3.5" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
  const XMark = () => (
    <svg width="12" height="12" viewBox="0 0 12 12" aria-hidden="true">
      <path d="M2 2 L10 10 M10 2 L2 10" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
    </svg>
  );

  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', flex: '1 0 auto', minHeight: 600 }}>
      <GameCue kind="multi">Select all that apply</GameCue>
      <h2 className="ff-display" style={{
        fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.01em',
        margin: 0, color: 'var(--ink)', textWrap: 'pretty',
      }}>{card.prompt}</h2>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 24 }}>
        {order.map((oi) => {
          const c = card.choices[oi];
          const on = sel.has(oi);
          const isCorrect = correctSet.has(oi);
          let cls = 'ms-choice';
          let box = null;
          let tag = null;
          if (!submitted) {
            if (on) { cls += ' on'; box = <CheckMark/>; }
          } else if (on && isCorrect) { cls += ' correct'; box = <CheckMark/>; }
          else if (on && !isCorrect) { cls += ' incorrect'; box = <XMark/>; }
          else if (!on && isCorrect) { cls += ' missed'; box = <CheckMark/>; tag = <span className="ms-tag">Missed</span>; }
          return (
            <button key={oi} className={cls} disabled={submitted} onClick={() => toggle(oi)}>
              <span className="ms-box">{box}</span>
              <span>{c.t}</span>
              {tag}
            </button>
          );
        })}
      </div>

      {submitted && (
        <div style={{ marginTop: 20, display: 'flex', gap: 14, alignItems: 'flex-start' }}>
          <div style={{ flexShrink: 0, marginTop: -8 }}>
            <Roasty state={allRight ? 'correct' : 'wrong'} size={72}/>
          </div>
          <div style={{ flex: 1 }}>
            <div className="ff-mono" style={{
              fontSize: 'var(--t-label)', letterSpacing: '0.14em',
              color: allRight ? 'var(--sage)' : 'var(--berry)',
              textTransform: 'uppercase', marginBottom: 8,
            }}>
              {allRight ? 'ALL CORRECT' : 'NOT QUITE'}
            </div>
            <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: 0 }}>
              {card.explain}
            </p>
          </div>
        </div>
      )}

      <div style={{ flex: 1 }}/>
      <div style={{ paddingTop: 32 }}>
        {!submitted
          ? <button className="btn btn-primary" onClick={submit} disabled={sel.size === 0}>Check answers</button>
          : <button className="btn btn-primary" onClick={onContinue}>Continue</button>}
      </div>
    </div>
  );
}

// Fisher–Yates over 0..n-1 — used to randomise how game cards lay out so a
// replay never opens in the same arrangement (or, worse, the solved one).
function shuffledIdx(n) {
  const a = Array.from({ length: n }, (_, i) => i);
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

// Animated connection line — draws itself in on mount via stroke-dashoffset,
// then pops an arrowhead at the destination end.
function MatchLine({ x1, y1, x2, y2, color, dashed, animate, arrow }) {
  const len = Math.hypot(x2 - x1, y2 - y1) || 1;
  const [on, setOn] = useStateL(!animate);
  useEffectL(() => {
    if (!animate) return;
    const t = setTimeout(() => setOn(true), 20);
    return () => clearTimeout(t);
  }, []);
  const ang = Math.atan2(y2 - y1, x2 - x1);
  const size = 11, spread = 0.44;
  const ax1 = x2 - size * Math.cos(ang - spread), ay1 = y2 - size * Math.sin(ang - spread);
  const ax2 = x2 - size * Math.cos(ang + spread), ay2 = y2 - size * Math.sin(ang + spread);
  return (
    <g>
      <line x1={x1} y1={y1} x2={x2} y2={y2}
            stroke={color} strokeWidth="2.5" strokeLinecap="round"
            strokeDasharray={dashed ? '2 7' : len}
            style={dashed ? undefined : {
              strokeDashoffset: on ? 0 : len,
              transition: 'stroke-dashoffset 360ms cubic-bezier(.3,1,.4,1)',
            }}/>
      {arrow && (
        <polygon points={`${x2},${y2} ${ax1},${ay1} ${ax2},${ay2}`} fill={color}
                 style={{ opacity: on ? 1 : 0, transition: 'opacity 180ms ease 240ms' }}/>
      )}
    </g>
  );
}

function MatchCard({ card, onContinue, onXp }) {
  // Right column is the deduped set of answers, so several traits can share
  // one species and the connection lines fan clearly toward it.
  const species = React.useMemo(() => {
    const seen = [];
    card.pairs.forEach(p => { if (!seen.includes(p.r)) seen.push(p.r); });
    return seen;
  }, [card]);

  // Render order only — shuffled once per mount. Pair index and species index
  // stay the identity everything else (matching, refs, lines) keys off.
  const [leftOrder] = useStateL(() => shuffledIdx(card.pairs.length));
  const [rightOrder] = useStateL(() => shuffledIdx(species.length));

  const [matches, setMatches] = useStateL([]);   // [{ left, right }]
  const [selLeft, setSelLeft] = useStateL(null);
  const [drag, setDrag] = useStateL(null);        // { from, x, y, moved }
  const [hotRight, setHotRight] = useStateL(null);
  const [wrong, setWrong] = useStateL(null);      // { left, right }
  const [snap, setSnap] = useStateL(null);        // right idx that just locked
  const [misses, setMisses] = useStateL(0);       // wrong drops this board
  const [paidXp, setPaidXp] = useStateL(false);
  const [lines, setLines] = useStateL([]);
  const [dims, setDims] = useStateL({ w: 0, h: 0 });

  const wrapRef = useRefL(null);
  const leftRefs = useRefL([]);
  const rightRefs = useRefL([]);

  const matchedLeft = (i) => matches.some(m => m.left === i);
  const rightLinked = (j) => matches.some(m => m.right === j);
  const allDone = matches.length >= card.pairs.length;

  const anchorLeft  = (el) => ({ x: el.offsetLeft + el.offsetWidth, y: el.offsetTop + el.offsetHeight / 2 });
  const anchorRight = (el) => ({ x: el.offsetLeft, y: el.offsetTop + el.offsetHeight / 2 });

  const measure = () => {
    const wrap = wrapRef.current;
    if (!wrap) return;
    setDims({ w: wrap.offsetWidth, h: wrap.offsetHeight });
    const ls = matches.map(m => {
      const le = leftRefs.current[m.left];
      const re = rightRefs.current[m.right];
      if (!le || !re) return null;
      const a = anchorLeft(le), b = anchorRight(re);
      return { x1: a.x, y1: a.y, x2: b.x, y2: b.y, key: m.left + '-' + m.right };
    }).filter(Boolean);
    setLines(ls);
  };

  React.useLayoutEffect(() => { measure(); }, [matches, species]);
  useEffectL(() => {
    const onR = () => measure();
    window.addEventListener('resize', onR);
    return () => window.removeEventListener('resize', onR);
  });

  // A match board can't be failed — you keep going until it's cleared — so the
  // graded thing is HOW you cleared it. Zero wrong drops is a correct board;
  // anything else scores nothing, the same rule every other card follows.
  const clean = misses === 0;
  useEffectL(() => {
    if (allDone && !paidXp) { setPaidXp(true); if (clean) onXp && onXp(3); }
  }, [allDone]);

  const localScale = () => {
    const wrap = wrapRef.current;
    if (!wrap || !wrap.offsetWidth) return 1;
    return wrap.getBoundingClientRect().width / wrap.offsetWidth;
  };
  const toLocal = (cx, cy) => {
    const wrap = wrapRef.current;
    if (!wrap) return { x: 0, y: 0 };
    const r = wrap.getBoundingClientRect();
    const s = localScale();
    return { x: (cx - r.left) / s, y: (cy - r.top) / s };
  };

  const tryMatch = (leftIdx, rightIdx) => {
    if (leftIdx == null || rightIdx == null || matchedLeft(leftIdx)) return;
    if (card.pairs[leftIdx].r === species[rightIdx]) {
      setMatches(m => [...m, { left: leftIdx, right: rightIdx }]);
      setSnap(rightIdx);
      setTimeout(() => setSnap(null), 340);
    } else {
      setMisses(n => n + 1);
      setWrong({ left: leftIdx, right: rightIdx });
      setTimeout(() => setWrong(null), 480);
    }
    setSelLeft(null);
  };

  const startDrag = (e, leftIdx) => {
    if (matchedLeft(leftIdx)) return;
    const el = e.currentTarget;
    const s = localScale();
    const er = el.getBoundingClientRect();
    const p = toLocal(e.clientX, e.clientY);
    setSelLeft(leftIdx);
    setDrag({
      from: leftIdx, x: p.x, y: p.y, moved: false,
      grabX: (e.clientX - er.left) / s, grabY: (e.clientY - er.top) / s,
      w: el.offsetWidth, h: el.offsetHeight, label: card.pairs[leftIdx].l,
    });
    try { el.setPointerCapture(e.pointerId); } catch (_) {}
  };
  const moveDrag = (e) => {
    if (!drag) return;
    const p = toLocal(e.clientX, e.clientY);
    setDrag(d => (d ? { ...d, x: p.x, y: p.y, moved: true } : d));
    const el = document.elementFromPoint(e.clientX, e.clientY);
    const tgt = el && el.closest ? el.closest('[data-right-idx]') : null;
    setHotRight(tgt ? +tgt.getAttribute('data-right-idx') : null);
  };
  const endDrag = (e) => {
    if (!drag) return;
    const el = document.elementFromPoint(e.clientX, e.clientY);
    const tgt = el && el.closest ? el.closest('[data-right-idx]') : null;
    if (tgt && drag.moved) tryMatch(drag.from, +tgt.getAttribute('data-right-idx'));
    setDrag(null);
    setHotRight(null);
  };

  const tapRight = (j) => {
    if (selLeft == null) return;
    tryMatch(selLeft, j);
  };



  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', flex: '1 0 auto', minHeight: 600 }}>
      <GameCue kind="match">Match · drag to pair</GameCue>
      <h2 className="ff-display" style={{
        fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.15, letterSpacing: '-0.01em',
        margin: 0, color: 'var(--ink)', textWrap: 'pretty',
      }}>{card.prompt}</h2>

      <div ref={wrapRef} className="match-wrap"
           style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 40, marginTop: 28 }}>
        <svg className="match-lines" width={dims.w} height={dims.h}
             viewBox={`0 0 ${dims.w || 1} ${dims.h || 1}`} preserveAspectRatio="none">
          {lines.map(l => (
            <MatchLine key={l.key} x1={l.x1} y1={l.y1} x2={l.x2} y2={l.y2}
                       color="var(--sage)" animate arrow/>
          ))}
          {wrong && (() => {
            const le = leftRefs.current[wrong.left], re = rightRefs.current[wrong.right];
            if (!le || !re) return null;
            const a = anchorLeft(le), b = anchorRight(re);
            return <MatchLine x1={a.x} y1={a.y} x2={b.x} y2={b.y} color="var(--berry)" arrow/>;
          })()}
        </svg>

        {drag && drag.moved && (
          <div className="match-ghost"
               style={{ left: drag.x - drag.grabX, top: drag.y - drag.grabY,
                        width: drag.w, height: drag.h }}>
            {drag.label}
          </div>
        )}

        <div className="match-col left">
          {leftOrder.map((i) => {
            const p = card.pairs[i];
            const done = matchedLeft(i);
            const cls = 'match-item'
              + (done ? ' matched' : '')
              + (drag && drag.from === i && drag.moved ? ' dragging' : '')
              + (!done && selLeft === i ? ' selected' : '')
              + (wrong && wrong.left === i ? ' wrong' : '');
            return (
              <div key={i} className={cls}
                   ref={el => (leftRefs.current[i] = el)}
                   onPointerDown={(e) => startDrag(e, i)}
                   onPointerMove={moveDrag}
                   onPointerUp={endDrag}
                   onClick={() => { if (!done && !(drag && drag.moved)) setSelLeft(i); }}>
                {p.l}
              </div>
            );
          })}
        </div>

        <div className="match-col right">
          {rightOrder.map((j) => {
            const sp = species[j];
            const linked = rightLinked(j);
            const cls = 'match-item'
              + (linked ? ' linked' : '')
              + (hotRight === j ? ' drop-hot' : '')
              + (snap === j ? ' snap' : '')
              + (wrong && wrong.right === j ? ' wrong' : '');
            return (
              <div key={j} className={cls}
                   data-right-idx={j}
                   ref={el => (rightRefs.current[j] = el)}
                   onClick={() => tapRight(j)}
                   style={{ textAlign: 'right' }}>
                {sp}
              </div>
            );
          })}
        </div>
      </div>

      {allDone && (
        <div style={{ marginTop: 24, display: 'flex', gap: 14, alignItems: 'flex-start' }}>
          <div style={{ flexShrink: 0, marginTop: -8 }}>
            <Roasty state={clean ? 'correct' : 'wrong'} size={72}/>
          </div>
          <div style={{ flex: 1 }}>
            <div className="ff-mono" style={{
              fontSize: 'var(--t-label)', letterSpacing: '0.14em',
              color: clean ? 'var(--sage)' : 'var(--berry)',
              textTransform: 'uppercase', marginBottom: 8,
            }}>{clean ? 'CLEAN BOARD' : `${misses} WRONG ${misses === 1 ? 'DROP' : 'DROPS'}`}</div>
            <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: 0 }}>
              {clean
                ? 'Every pair first time. That is the one that counts.'
                : 'Cleared it, but not first time — the board only scores when every pair lands on the first try.'}
            </p>
          </div>
        </div>
      )}

      <div style={{ flex: 1 }}/>
      <div style={{ paddingTop: 32 }}>
        <button className="btn btn-primary" onClick={onContinue} disabled={!allDone}>Continue</button>
      </div>
    </div>
  );
}

// Generic hand-grinder illustration used by the grind-size calibrate card.
// Grind-adjustment dial, drawn as a numbered click ring tilted back in
// perspective (an ellipse) so it reads as a real part you look down onto —
// the way you sight the setting on a hand grinder's base collar. The current
// click count reads large inside the ring, and an accent marker sweeps the
// front arc live as the user drags. Minimal on purpose: no full grinder body.
function GrinderDial({ val, clicks }) {
  const cx = 110, cy = 96, rx = 82, ry = 50, th = 15;
  // Marker sweeps a 240° gauge arc across the near (front) edge of the tilted
  // disc: fine at upper-left, coarse at upper-right, passing the bottom.
  const START = 150, SWEEP = 240;
  const pt = (deg, fx = 1, fy = 1) => {
    const r = deg * Math.PI / 180;
    return [cx + rx * fx * Math.cos(r), cy + ry * fy * Math.sin(r)];
  };
  const markerDeg = START + (val / 100) * SWEEP;
  const [mx, my] = pt(markerDeg, 0.9, 0.9);
  const ticks = Array.from({ length: 13 }, (_, i) => START + (i / 12) * SWEEP);

  return (
    <svg viewBox="0 0 220 200" width="100%" style={{ maxWidth: 300, display: 'block', margin: '0 auto' }}>
      {/* soft contact shadow */}
      <ellipse cx={cx} cy={cy + th + 16} rx={rx * 0.82} ry={13} fill="var(--ink)" opacity="0.07"/>

      {/* cylinder rim (thickness of the dial) */}
      <path d={`M ${cx - rx} ${cy} L ${cx - rx} ${cy + th}
               A ${rx} ${ry} 0 0 0 ${cx + rx} ${cy + th}
               L ${cx + rx} ${cy} Z`}
            fill="var(--surface-2)" stroke="var(--ink)" strokeWidth="2.5" strokeLinejoin="round"/>

      {/* top face */}
      <ellipse cx={cx} cy={cy} rx={rx} ry={ry} fill="var(--surface)" stroke="var(--ink)" strokeWidth="2.5"/>
      <ellipse cx={cx} cy={cy} rx={rx - 12} ry={ry - 8} fill="none" stroke="var(--rule)" strokeWidth="1.5"/>

      {/* gauge ticks along the front arc */}
      {ticks.map((deg, i) => {
        const [x1, y1] = pt(deg, 1, 1);
        const [x2, y2] = pt(deg, 0.86, 0.86);
        const passed = deg <= markerDeg + 0.5;
        return <line key={i} x1={x1} y1={y1} x2={x2} y2={y2}
                     stroke={passed ? 'var(--accent)' : 'var(--ink-mute)'}
                     strokeWidth={passed ? 2.5 : 2} opacity={passed ? 0.9 : 0.55}/>;
      })}

      {/* live marker riding the rim */}
      <circle cx={mx} cy={my} r="7" fill="var(--accent)" stroke="var(--surface)" strokeWidth="2.5"/>

      {/* click number inside the ring */}
      <text x={cx} y={cy - 2} textAnchor="middle" className="ff-display"
            fontSize="36" fontWeight="400" fill="var(--ink)">{clicks}</text>
      <text x={cx} y={cy + 20} textAnchor="middle" className="ff-mono"
            fontSize="10" letterSpacing="0.22em" fill="var(--ink-mute)">CLICKS</text>
    </svg>
  );
}

// The target readout under a slider card's verdict. Three treatments (Tweaks →
// Roasty's reaction to a slider answer: verdict + feedback only. The target
// itself is stated above the track, next to the zone it highlights — see
// SliderCard. Status colour stays on the verdict alone.

function SliderCard({ card, onContinue, onXp }) {
  const [val, setVal] = useStateL(50);
  const [touched, setTouched] = useStateL(false);
  const [checked, setChecked] = useStateL(false);
  const [paidXp, setPaidXp] = useStateL(false);
  const within = Math.abs(val - card.target) <= card.tolerance;
  const isGrinder = card.leftLabel === 'FINER' && card.rightLabel === 'COARSER';

  const handleCheck = () => {
    setChecked(true);
    if (within && !paidXp) { setPaidXp(true); onXp && onXp(3); }
  };

  // Simple 5-band descriptive scale so the raw 0–100 value always reads as
  // something concrete (e.g. "kosher salt") instead of a bare number.
  const bands = card.scale || ['Very ' + card.leftLabel, card.leftLabel, 'Middle', card.rightLabel, 'Very ' + card.rightLabel];
  const bandOf = (v) => Math.min(bands.length - 1, Math.floor(v / (100 / bands.length)));
  const bandIdx = bandOf(val);
  const targetBandIdx = bandOf(card.target);
  const clicks = Math.round((val / 100) * 30);

  // Acceptable target range, as track percentages, revealed after checking.
  const zoneLeft = Math.max(0, card.target - card.tolerance);
  const zoneWidth = Math.min(100, card.target + card.tolerance) - zoneLeft;

  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', flex: '1 0 auto', minHeight: 600 }}>
      <GameCue kind="slider">Calibrate · dial to the target</GameCue>
      <h2 className="ff-display" style={{
        fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.15, letterSpacing: '-0.01em',
        margin: 0, color: 'var(--ink)', textWrap: 'pretty',
      }}>{card.prompt}</h2>

      {isGrinder && (
        <div style={{ marginTop: 24 }}>
          <GrinderDial val={val} clicks={clicks}/>
        </div>
      )}

      <div style={{ marginTop: isGrinder ? 20 : 40 }}>
        {/* One fixed-height slot, bottom-aligned, so the track never moves when the
            answer is checked. Both states are label + value: before checking it
            reads back the learner's own band in accent (accent = a committed
            claim); after, it states the target in sage, keyed to the sage zone
            drawn on the track directly below — so the answer is read where the
            eye already is, and the range is never stated twice on the screen. */}
        <div style={{ minHeight: 58, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end', marginBottom: 6 }}>
          <div className="smallcaps" style={{ color: checked ? 'var(--sage)' : 'var(--ink-mute)', marginBottom: 3 }}>
            {checked ? 'Target' : 'Your setting'}
          </div>
          <p style={{
            fontSize: 'var(--t-body)', lineHeight: 1.35, margin: 0, textWrap: 'pretty',
            color: checked ? 'var(--ink)' : 'var(--accent)',
          }}>{checked ? bands[targetBandIdx] : bands[bandIdx]}</p>
        </div>

        <div className="slider-track-wrap">
          {checked && (
            <div className="slider-zone" style={{ left: `${zoneLeft}%`, width: `${zoneWidth}%` }}/>
          )}
          <input type="range" className="brew-slider" min={0} max={100} value={val}
                 disabled={checked}
                 style={{ '--fill': `${val}%` }}
                 onChange={(e) => { setVal(+e.target.value); setTouched(true); }}/>
        </div>

        <div style={{
          display: 'flex', justifyContent: 'space-between', marginTop: 8,
        }}>
          <span className="smallcaps" style={{ color: 'var(--ink)', display: 'inline-flex', alignItems: 'center', gap: 6 }}><span style={{ display: 'inline-flex', transform: 'rotate(180deg)' }}><window.ArrowMark/></span>{card.leftLabel}</span>
          <span className="smallcaps" style={{ color: 'var(--ink)', display: 'inline-flex', alignItems: 'center', gap: 6 }}>{card.rightLabel}<window.ArrowMark/></span>
        </div>
      </div>

      {checked && (
        <div style={{ marginTop: 24, display: 'flex', gap: 14, alignItems: 'flex-start' }}>
          <div style={{ flexShrink: 0, marginTop: -8 }}>
            <Roasty state={within ? 'correct' : 'wrong'} size={72}/>
          </div>
          <div style={{ flex: 1 }}>
          <div className="smallcaps" style={{
              letterSpacing: '0.14em',
              color: within ? 'var(--sage)' : 'var(--berry)',
              marginBottom: 8,
            }}>
              {within ? 'DIALED IN' : 'NOT QUITE'}
            </div>
            <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: 0 }}>
              {card.feedback}
            </p>
          </div>
        </div>
      )}

      <div style={{ flex: 1 }}/>
      <div style={{ paddingTop: 32 }}>
        {!checked
          ? <button className="btn btn-primary" onClick={handleCheck} disabled={!touched}>Check answer</button>
          : <button className="btn btn-primary" onClick={onContinue}>Continue</button>}
      </div>
    </div>
  );
}

function SequenceCard({ card, onContinue, onXp }) {
  const [order, setOrder] = useStateL([]); // array of indices in tap order
  // Display order is shuffled on mount so a card authored in its correct order
  // never opens pre-solved. Grading still reads item.order, so this is cosmetic.
  const [displayOrder] = useStateL(() => {
    const n = card.items.length;
    const solved = (o) => o.every((idx, pos) => card.items[idx].order === pos + 1);
    let o = shuffledIdx(n);
    if (solved(o)) o = shuffledIdx(n);
    if (solved(o)) o = [...o].reverse();
    return o;
  });
  const [submitted, setSubmitted] = useStateL(false);
  const [paidXp, setPaidXp] = useStateL(false);
  const allTapped = order.length === card.items.length;

  function tap(i) {
    if (submitted) return;
    // Toggle: tapping an already-selected item removes it (the remaining
    // items keep their relative order and renumber automatically).
    if (order.includes(i)) { setOrder(order.filter(x => x !== i)); return; }
    setOrder([...order, i]);
  }
  function reset() { if (!submitted) setOrder([]); }

  // Did the user tap them in the correct sequence?
  const isCorrect = allTapped && order.every((itemIdx, pos) => card.items[itemIdx].order === pos + 1);

  const handleSubmit = () => {
    setSubmitted(true);
    if (isCorrect && onXp && !paidXp) { setPaidXp(true); onXp(3); }
  };

  // Correct sequence as a readable string for the reveal.
  const correctSeq = [...card.items].sort((a, b) => a.order - b.order).map(x => x.label).join('  →  ');

  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', flex: '1 0 auto', minHeight: 600 }}>
      <GameCue kind="sequence">Put in order · tap in sequence</GameCue>
      <h2 className="ff-display" style={{
        fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.15, letterSpacing: '-0.01em',
        margin: 0, color: 'var(--ink)', textWrap: 'pretty',
      }}>{card.prompt}</h2>

      <div style={{ marginTop: 24 }}>
        {displayOrder.map((i) => {
          const it = card.items[i];
          const pos = order.indexOf(i);
          const posRight = submitted && pos >= 0 && it.order === pos + 1;
          const posWrong = submitted && pos >= 0 && it.order !== pos + 1;
          const cls = 'seq-item'
            + (pos >= 0 && !submitted ? ' assigned' : '')
            + (posRight ? ' correct' : '')
            + (posWrong ? ' wrong' : '');
          return (
            <div key={i} className={cls} onClick={() => tap(i)}>
              <div className="num">{pos >= 0 ? pos + 1 : ''}</div>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 10 }}>
                <span>{it.label}</span>
                {posWrong && <span className="seq-hint">Goes #{it.order}</span>}
              </div>
            </div>
          );
        })}
      </div>

      {allTapped && !submitted && (
        <div style={{ marginTop: 8, textAlign: 'right' }}>
          <button className="btn btn-link" onClick={reset}>Reset</button>
        </div>
      )}

      {submitted && (
        <div style={{ marginTop: 20, display: 'flex', gap: 14, alignItems: 'flex-start' }}>
          <div style={{ flexShrink: 0, marginTop: -8 }}>
            <Roasty state={isCorrect ? 'correct' : 'wrong'} size={72}/>
          </div>
          <div style={{ flex: 1 }}>
            <div className="ff-mono" style={{
              fontSize: 'var(--t-label)', letterSpacing: '0.14em',
              color: isCorrect ? 'var(--sage)' : 'var(--berry)',
              textTransform: 'uppercase', marginBottom: 8,
            }}>
              {isCorrect ? 'IN ORDER' : 'NOT QUITE'}
            </div>
            <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: 0 }}>
              {isCorrect ? 'Nailed the sequence.' : 'Not the right order this time.'}
            </p>
            <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink)', margin: '10px 0 0' }}>
              <span className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.14em', textTransform: 'uppercase', color: 'var(--sage)' }}>Correct order</span>
              <br/>{correctSeq}
            </p>
          </div>
        </div>
      )}

      <div style={{ flex: 1 }}/>
      <div style={{ paddingTop: 32 }}>
        {!submitted
          ? <button className="btn btn-primary" onClick={handleSubmit} disabled={!allTapped}>Submit</button>
          : <button className="btn btn-primary" onClick={onContinue}>Continue</button>}
      </div>
    </div>
  );
}

// Old CompletionScreen replaced by LessonCompleteScreen + ModuleCompleteScreen
// + ModuleRewardCardScreen in rewards.jsx.

// ───────────────────────────────────────────────────────────
// STANDALONE MINI-GAMES
// Each mini-game plays ONLY content of its own type — never a mixed lesson.
// Content is authored here, one homogeneous set per game id.
// ───────────────────────────────────────────────────────────
const MINI_GAME_CONTENT = {
  // Match the facts — Arabica vs Robusta. Only 'match' cards.
  'g-match': [
    { kind: 'match', prompt: 'Match each trait to its species',
      pairs: [
        { l: 'Sweeter, more aromatic', r: 'Arabica' },
        { l: 'Almost twice the caffeine', r: 'Robusta' },
        { l: 'Grown 900–2000m', r: 'Arabica' },
        { l: 'Heavier body, more bitter', r: 'Robusta' },
      ] },
    { kind: 'match', prompt: 'Which species? Pair each fact',
      pairs: [
        { l: '~60% of world coffee', r: 'Arabica' },
        { l: 'Hardier, disease-resistant', r: 'Robusta' },
        { l: 'More delicate acidity', r: 'Arabica' },
        { l: 'Thrives at low elevation', r: 'Robusta' },
      ] },
    { kind: 'match', prompt: 'Pair each cue with its species',
      pairs: [
        { l: 'Oval bean, curved crease', r: 'Arabica' },
        { l: 'Rounder bean, straight crease', r: 'Robusta' },
        { l: 'Frost-sensitive, needs altitude', r: 'Arabica' },
        { l: 'Tolerates heat and humidity', r: 'Robusta' },
      ] },
    { kind: 'match', prompt: 'Which species does each belong to?',
      pairs: [
        { l: 'Caffeine around 1.2%', r: 'Arabica' },
        { l: 'Caffeine around 2.4%', r: 'Robusta' },
        { l: 'Prized for florals and fruit', r: 'Arabica' },
        { l: 'Adds crema and punch to espresso', r: 'Robusta' },
      ] },
    { kind: 'match', prompt: 'Match each shelf cue to its species',
      pairs: [
        { l: 'Most specialty single origins', r: 'Arabica' },
        { l: 'The backbone of instant coffee', r: 'Robusta' },
        { l: 'Costs more per kilo at origin', r: 'Arabica' },
        { l: 'Cheaper to grow, higher yield', r: 'Robusta' },
      ] },
  ],
  // Name the flavor notes — tasting. Only 'flavor' cards.
  'g-flavor': [
    { kind: 'flavor', clue: 'A sharp, tangy brightness that makes your mouth water',
      prompt: 'Name the note',
      choices: [{ t: 'Citrus' }, { t: 'Caramel' }, { t: 'Cedar' }, { t: 'Tobacco' }],
      answer: 0, explain: 'That mouth-watering snap is acidity — most often citrus in a bright coffee.' },
    { kind: 'flavor', clue: 'Deep, roasty and bittersweet — like dark baking cocoa',
      prompt: 'Name the note',
      choices: [{ t: 'Floral' }, { t: 'Chocolate' }, { t: 'Berry' }, { t: 'Grassy' }],
      answer: 1, explain: 'Bittersweet and roasty reads as chocolate — a classic note in darker roasts.' },
    { kind: 'flavor', clue: 'Delicate and perfumed, like jasmine or orange blossom',
      prompt: 'Name the note',
      choices: [{ t: 'Nutty' }, { t: 'Smoky' }, { t: 'Floral' }, { t: 'Malty' }],
      answer: 2, explain: 'Perfumed and light on the nose — that is a floral note, common in Ethiopian coffees.' },
    { kind: 'flavor', clue: 'Sweet and jammy, like ripe strawberry or blueberry',
      prompt: 'Name the note',
      choices: [{ t: 'Berry' }, { t: 'Earthy' }, { t: 'Spicy' }, { t: 'Woody' }],
      answer: 0, explain: 'Jammy sweetness points to berry — often found in natural-process coffees.' },
    { kind: 'flavor', clue: 'Warm and toasted, like almonds or hazelnut skins',
      prompt: 'Name the note',
      choices: [{ t: 'Winey' }, { t: 'Nutty' }, { t: 'Herbal' }, { t: 'Fruity' }],
      answer: 1, explain: 'Toasted and warm is the nutty family — think almond, hazelnut, pecan.' },
  ],
  // True or false — what coffee is. Only 'quiz' cards.
  'g-quiz': [
    { kind: 'quiz', statement: 'A coffee bean is actually the seed of a fruit',
      answer: true, explain: 'True — it is the seed of the coffee cherry.' },
    { kind: 'quiz', statement: "Most of the world's coffee grows in a band near the equator",
      answer: true, explain: 'True — the "bean belt" runs roughly 25°N to 25°S.' },
    { kind: 'quiz', statement: 'Espresso beans are a special species grown only for espresso',
      answer: false, explain: 'False — espresso is a brewing method, not a species. Any bean can be pulled as espresso.' },
    { kind: 'quiz', statement: 'A coffee cherry usually contains two seeds',
      answer: true, explain: 'True — two flat-faced seeds sit pressed together inside each cherry.' },
    { kind: 'quiz', statement: 'Robusta has less caffeine than Arabica',
      answer: false, explain: 'False — Robusta has almost twice the caffeine of Arabica.' },
    { kind: 'quiz', statement: 'Dark roasts always have far more caffeine than light roasts',
      answer: false, explain: 'False — roast level barely changes caffeine; by volume light roasts can edge ahead.' },
  ],
  // Blind bag — call the process from the look of the green bean. Only 'bagpick' cards.
  'g-bagpick': (typeof BAGPICK_ROUNDS !== 'undefined' ? BAGPICK_ROUNDS : []),
  // Taste Fix — diagnose the cup and pick the fix. Only 'tastefix' cards.
  'g-tastefix': [
    { kind: 'tastefix', tags: ['SOUR', 'THIN'],
      scenario: 'Grind’s dialled in and the beans are fresh.',
      prompt: 'Your pour-over came out off. What would you try first?',
      choices: [{ t: 'Grind finer', correct: true }, { t: 'Grind coarser' }, { t: 'Use colder water' }, { t: 'Brew for less time' }],
      explain: 'Sour and thin is under-extraction — a finer grind pulls more sweetness and rounds the cup toward balanced.' },
    { kind: 'tastefix', tags: ['BITTER', 'DRY'],
      scenario: 'Same beans, same ratio as before.',
      prompt: 'Now it’s off the other way. What would you try first?',
      choices: [{ t: 'Grind coarser', correct: true }, { t: 'Grind finer' }, { t: 'Use hotter water' }, { t: 'Add more coffee' }],
      explain: 'Bitter and dry is over-extraction — a coarser grind slows the pull and eases the harshness back toward balanced.' },
    { kind: 'tastefix', tags: ['WEAK', 'WATERY'],
      scenario: 'It tastes clean, just faint — not sour.',
      prompt: 'The cup is thin but not sour. What first?',
      choices: [{ t: 'Use more coffee', correct: true }, { t: 'Grind finer' }, { t: 'Brew longer' }, { t: 'Use hotter water' }],
      explain: 'Thin but not sour points at strength, not extraction — nudge the ratio (more coffee per cup) before touching grind.' },
    { kind: 'tastefix', tags: ['HARSH', 'RUBBERY'],
      scenario: 'Fresh beans, dialled grind, espresso.',
      prompt: 'Your espresso still tastes harsh. What would you try first?',
      choices: [{ t: 'Try a different bean', correct: true }, { t: 'Grind finer' }, { t: 'Pull a longer shot' }, { t: 'Tamp harder' }],
      explain: 'When grind and freshness are already right, harsh and rubbery usually traces back to the bean itself — swap it.' },
    { kind: 'tastefix', tags: ['FLAT', 'LIFELESS'],
      scenario: 'The bag was opened six weeks ago.',
      prompt: 'Nothing tastes wrong — it just tastes like nothing. What first?',
      choices: [{ t: 'Buy a fresher bag', correct: true }, { t: 'Grind finer' }, { t: 'Use hotter water' }, { t: 'Add more coffee' }],
      explain: 'Flat and lifeless is staling, not extraction. No dial-in puts back aromatics that have already gone — start with fresher beans.' },
  ],
  // Dial it in — calibrate the number. Only 'slider' cards.
  'g-calibrate': [
    { kind: 'slider',
      prompt: 'How fine should you grind for espresso?',
      leftLabel: 'FINER', rightLabel: 'COARSER',
      target: 28, tolerance: 11,
      scale: [
        'Powder — chokes the machine',
        'Fine — espresso',
        'Table salt — moka, AeroPress',
        'Sea salt — pour-over',
        'Breadcrumbs — French press',
      ],
      feedback: 'Espresso lives at the fine end, just above powder. Too fine and the machine chokes; too coarse and the shot gushes.' },
    { kind: 'slider',
      prompt: 'And how coarse for a French press?',
      leftLabel: 'FINER', rightLabel: 'COARSER',
      target: 88, tolerance: 11,
      scale: [
        'Powder — silt in every sip',
        'Fine — espresso',
        'Table salt — moka, AeroPress',
        'Sea salt — pour-over',
        'Breadcrumbs — French press',
      ],
      feedback: 'Four minutes of full immersion needs the coarsest setting on the dial — anything finer over-extracts and muddies the cup.' },
    { kind: 'slider',
      prompt: 'What brew ratio for a filter cup?',
      leftLabel: 'STRONGER', rightLabel: 'WEAKER',
      target: 50, tolerance: 13,
      scale: [
        '1:12 — espresso-adjacent',
        '1:14 — punchy',
        '1:16 — the filter standard',
        '1:18 — light and long',
        '1:20 — tea-like',
      ],
      feedback: 'Most filter recipes land near 1:16. Pick one, weigh it, and change a single thing at a time from there.' },
    { kind: 'slider',
      prompt: 'How hot should the brew water be?',
      leftLabel: 'COOLER', rightLabel: 'HOTTER',
      target: 72, tolerance: 13,
      scale: [
        'Below 80 °C — sour and flat',
        '85 °C — under-extracts easily',
        '90 °C — safe for dark roasts',
        '93–96 °C — just off the boil',
        'Rolling boil — scorches the bed',
      ],
      feedback: 'Just off the boil, around 93 to 96 °C. A rolling boil scorches the bed; much cooler and the sweetness never comes out.' },
    { kind: 'slider',
      prompt: 'How long should a single pour-over run?',
      leftLabel: 'FASTER', rightLabel: 'SLOWER',
      target: 50, tolerance: 13,
      scale: [
        'Under 2 min — thin and sour',
        '2:30 — fast, under-extracted',
        '3:00–3:30 — the target window',
        '4:00 — slow, edging bitter',
        'Over 5 min — stalled and harsh',
      ],
      feedback: 'Three to three and a half minutes, start to drawdown. Much faster is under-extracted; much slower means the bed has clogged.' },
  ],
  // Bean to cup — put the steps in order. Only 'sequence' cards.
  'g-sequence': [
    { kind: 'sequence', prompt: 'Order the journey from farm to cup',
      items: [
        { label: 'Pick the cherry', order: 1 },
        { label: 'Process and dry', order: 2 },
        { label: 'Roast', order: 3 },
        { label: 'Grind', order: 4 },
        { label: 'Brew', order: 5 },
      ] },
    { kind: 'sequence', prompt: 'Order the layers of a cherry, skin inwards',
      items: [
        { label: 'Skin', order: 1 },
        { label: 'Pulp', order: 2 },
        { label: 'Mucilage', order: 3 },
        { label: 'Parchment', order: 4 },
        { label: 'Seed', order: 5 },
      ] },
    { kind: 'sequence', prompt: 'Order a pour-over, first step to last',
      items: [
        { label: 'Weigh the beans', order: 1 },
        { label: 'Grind', order: 2 },
        { label: 'Bloom', order: 3 },
        { label: 'Pour in stages', order: 4 },
        { label: 'Drawdown', order: 5 },
      ] },
    { kind: 'sequence', prompt: 'Order these roasts, lightest to darkest',
      items: [
        { label: 'Light — bright, acidic', order: 1 },
        { label: 'Medium — balanced, sweet', order: 2 },
        { label: 'Medium-dark — first oils', order: 3 },
        { label: 'Dark — smoky, bitter', order: 4 },
      ] },
    { kind: 'sequence', prompt: 'Order these brewers by grind, finest to coarsest',
      items: [
        { label: 'Espresso', order: 1 },
        { label: 'AeroPress', order: 2 },
        { label: 'Pour-over', order: 3 },
        { label: 'Drip machine', order: 4 },
        { label: 'French press', order: 5 },
      ] },
  ],
};

// True / false statement card.
function TrueFalseCard({ card, onContinue, onScore }) {
  const [picked, setPicked] = useStateL(null); // true | false
  const pick = (val) => {
    if (picked !== null) return;
    setPicked(val);
    onScore && onScore(val === card.answer);
  };
  const isRight = picked !== null && picked === card.answer;
  const btnCls = (val) => {
    let cls = 'mcq-choice';
    if (picked !== null) {
      if (val === card.answer) cls += ' correct';
      else if (val === picked) cls += ' incorrect';
    }
    return cls;
  };
  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', flex: '1 0 auto', minHeight: 600 }}>
      <GameCue kind="quiz">True or false</GameCue>
      <h2 className="ff-display" style={{
        fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.18, letterSpacing: '-0.01em',
        margin: 0, color: 'var(--ink)', textWrap: 'pretty',
      }}>{card.statement}</h2>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 24 }}>
        <button className={btnCls(true)} disabled={picked !== null} onClick={() => pick(true)}>True</button>
        <button className={btnCls(false)} disabled={picked !== null} onClick={() => pick(false)}>False</button>
      </div>

      {picked !== null && (
        <div style={{ marginTop: 20, display: 'flex', gap: 14, alignItems: 'flex-start' }}>
          <div style={{ flexShrink: 0, marginTop: -8 }}>
            <Roasty state={isRight ? 'correct' : 'wrong'} size={72}/>
          </div>
          <div style={{ flex: 1 }}>
            <div className="ff-mono" style={{
              fontSize: 'var(--t-label)', letterSpacing: '0.14em',
              color: isRight ? 'var(--sage)' : 'var(--berry)',
              textTransform: 'uppercase', marginBottom: 8,
            }}>{isRight ? 'CORRECT' : 'NOT QUITE'}</div>
            <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: 0 }}>{card.explain}</p>
          </div>
        </div>
      )}

      <div style={{ flex: 1 }}/>
      <div style={{ paddingTop: 32 }}>
        <button className="btn btn-primary" onClick={onContinue} disabled={picked === null}>Continue</button>
      </div>
    </div>
  );
}

// Flavor-note card — read the tasting clue, pick the matching note.
function FlavorNoteCard({ card, onContinue, onScore }) {
  const [picked, setPicked] = useStateL(null);
  const correctIdx = card.answer;
  // Render order only — card.answer stays the identity for grading.
  const [order] = useStateL(() => shuffledIdx(card.choices.length));
  const pick = (i) => {
    if (picked !== null) return;
    setPicked(i);
    onScore && onScore(i === correctIdx);
  };
  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', flex: '1 0 auto', minHeight: 600 }}>
      <GameCue kind="flavor">Tasting · name the note</GameCue>
      <h2 className="ff-display" style={{
        fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.01em',
        margin: 0, color: 'var(--ink)', textWrap: 'pretty',
      }}>{card.prompt}</h2>
      <p style={{
        fontSize: 'var(--t-body)', lineHeight: 1.5, color: 'var(--ink-mute)',
        margin: '16px 0 0', fontStyle: 'italic', textWrap: 'pretty',
      }}>“{card.clue}”</p>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 24 }}>
        {order.map((oi) => {
          let cls = 'mcq-choice';
          if (picked !== null) {
            if (oi === correctIdx) cls += ' correct';
            else if (oi === picked) cls += ' incorrect';
          }
          return (
            <button key={oi} className={cls} disabled={picked !== null} onClick={() => pick(oi)}>{card.choices[oi].t}</button>
          );
        })}
      </div>

      {picked !== null && (
        <div style={{ marginTop: 20, display: 'flex', gap: 14, alignItems: 'flex-start' }}>
          <div style={{ flexShrink: 0, marginTop: -8 }}>
            <Roasty state={picked === correctIdx ? 'correct' : 'wrong'} size={72}/>
          </div>
          <div style={{ flex: 1 }}>
            <div className="ff-mono" style={{
              fontSize: 'var(--t-label)', letterSpacing: '0.14em',
              color: picked === correctIdx ? 'var(--sage)' : 'var(--berry)',
              textTransform: 'uppercase', marginBottom: 8,
            }}>{picked === correctIdx ? 'CORRECT' : 'NOT QUITE'}</div>
            <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: 0 }}>{card.explain}</p>
          </div>
        </div>
      )}

      <div style={{ flex: 1 }}/>
      <div style={{ paddingTop: 32 }}>
        <button className="btn btn-primary" onClick={onContinue} disabled={picked === null}>Continue</button>
      </div>
    </div>
  );
}

// MiniGamePlayer — runs one standalone game to completion. Plays ONLY the
// cards authored for that game (all one kind), scores them, and ends on a
// self-contained results screen. Never touches lesson XP / progression.
function MiniGamePlayer({ game, onClose }) {
  const content = (MINI_GAME_CONTENT[game.id]) || [];
  const total = content.length;
  const [idx, setIdx] = useStateL(0);
  const [key, setKey] = useStateL(0);
  const [score, setScore] = useStateL(0);
  const [done, setDone] = useStateL(false);
  const scoredRef = useRefL(false);

  if (!total) return null;

  const advance = () => {
    if (idx + 1 >= total) { setDone(true); return; }
    scoredRef.current = false;
    setIdx(idx + 1);
    setKey(k => k + 1);
  };
  const scoreOnce = (ok) => {
    if (scoredRef.current) return;
    scoredRef.current = true;
    if (ok) setScore(s => s + 1);
  };
  const replay = () => {
    scoredRef.current = false;
    setScore(0); setIdx(0); setKey(k => k + 1); setDone(false);
  };

  const filled = Math.round(((idx + 1) / total) * 6);
  const card = content[idx];

  const topbar = (progressed) => (
    <div className="lesson-topbar">
      <div style={{ justifySelf: 'start', display: 'flex', alignItems: 'center', gap: 8 }}>
        <button className="close-btn" onClick={onClose} aria-label="Close">
          <window.CloseMark/>
        </button>
      </div>
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: 10 }}>
        <RoastBean done={progressed ? total : idx + 1} total={total}/>
        <span className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.12em', color: 'var(--ink-mute)', textTransform: 'uppercase' }}>
          {progressed ? `${String(total).padStart(2, '0')} / ${String(total).padStart(2, '0')}` : `${String(idx + 1).padStart(2, '0')} / ${String(total).padStart(2, '0')}`}
        </span>
      </div>
      <div style={{ justifySelf: 'end', display: 'flex', alignItems: 'center', gap: 8 }}/>
    </div>
  );

  if (done) {
    const pct = Math.round((score / total) * 100);
    const great = pct >= 80;
    return (
      <div className="screen" data-screen-label="Mini-game complete" style={{ background: 'var(--bg)' }}>
        {topbar(true)}
        <div className="scroll" style={{ paddingTop: 134, paddingBottom: 32, display: 'flex', flexDirection: 'column' }}>
          <div className="px-24" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', flex: '1 0 auto', minHeight: 560 }}>
            <div style={{ paddingTop: 8 }}>
              <Roasty state={great ? 'module' : 'correct'} size={150}/>
            </div>
            <div className="smallcaps" style={{ margin: '24px 0 12px' }}>{game.title}</div>
            <div className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1, color: 'var(--ink)' }}>
              {score}<span style={{ color: 'var(--ink-mute)', fontSize: 'var(--t-title)' }}> / {total}</span>
            </div>
            <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: '18px 0 0', maxWidth: 300, textWrap: 'pretty' }}>
              {great ? 'Sharp palate. You know this one cold.' : pct >= 50 ? 'Solid round — run it back to sharpen up.' : 'Worth another pass. Try again?'}
            </p>
            <div style={{ flex: 1 }}/>
            <div style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: 10, paddingTop: 32 }}>
              <button className="btn btn-primary" onClick={replay}>Play again</button>
              <button className="btn btn-ghost" onClick={onClose}>Done</button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="screen" data-screen-label="Mini-game" style={{ background: 'var(--bg)' }}>
      {topbar(false)}
      <div className="scroll" style={{ paddingTop: 134, paddingBottom: 32, display: 'flex', flexDirection: 'column' }}>
        <div key={key} className="fade-up" style={{ flex: '1 0 auto', display: 'flex', flexDirection: 'column' }}>
          {card.kind === 'match'  && <MatchCard card={card} onContinue={advance} onXp={() => scoreOnce(true)}/>}
          {card.kind === 'tastefix' && window.TasteFixCard && <window.TasteFixCard card={card} onContinue={advance} onXp={() => scoreOnce(true)}/>}
          {card.kind === 'bagpick' && window.BagPickCard && <window.BagPickCard card={card} onContinue={advance} onXp={() => scoreOnce(true)}/>}
          {card.kind === 'quiz'   && <TrueFalseCard card={card} onContinue={advance} onScore={scoreOnce}/>}
          {card.kind === 'flavor' && <FlavorNoteCard card={card} onContinue={advance} onScore={scoreOnce}/>}
          {card.kind === 'slider' && <SliderCard card={card} onContinue={advance} onXp={() => scoreOnce(true)}/>}
          {card.kind === 'sequence' && <SequenceCard card={card} onContinue={advance} onXp={() => scoreOnce(true)}/>}
        </div>
      </div>
    </div>
  );
}

window.MINI_GAME_CONTENT = MINI_GAME_CONTENT;
window.MiniGamePlayer = MiniGamePlayer;
window.LessonPlayer = LessonPlayer;
