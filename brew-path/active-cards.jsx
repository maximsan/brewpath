// active-cards.jsx — the three card kinds that replace the lesson's read-only beats.
//
//   predict   (was intro)     — commit to a guess BEFORE being taught
//   decision  (was practical) — apply it as a real choice at the shelf
//   recall    (was takeaway)  — retrieve it, then close the prediction loop
//
// Together they turn a lesson from read → quiz → read into
// predict → learn → practice → apply → recall.
//
// TYPE SYSTEM — three styles only, no exceptions:
//   Label    .smallcaps-mono           (mono 11, uppercase, ink-mute)
//   Display  .ff-display 32 / 22       (Fraunces 400, tight tracking, ink)
//   Body     15px / 1.55               (sans 400, ink or ink-mute)
// No intermediate sans-500 sizes, no colored label text — state is carried by
// the mascot and the option chrome, not by the typography.

const { useState: useStateAC } = React;

// ── PREDICT ────────────────────────────────────────────────
// Opens the lesson with a question it does NOT answer. The learner commits,
// the guess is sealed, and the curiosity gap stays open until the recall card
// pays it off. Never graded — a wrong guess is the point, not a failure.
function PredictCard({ card, onContinue, onPredict, onTermTap }) {
  const [pick, setPick] = useStateAC(null);
  // Ungraded guess — the learner can switch it right up until they commit with
  // "Find out", so a mis-tap never traps them on the card.
  const choose = (opt) => {
    if (pick === opt) return;
    setPick(opt);
    onPredict && onPredict({ q: card.question, pick: opt, a: card.a });
  };
  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', flex: '1 0 auto', minHeight: 600 }}>
      <div className="smallcaps-mono" style={{ marginBottom: 14 }}>{card.label}</div>
      <h1 className="ff-display" style={{
        fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.08, letterSpacing: '-0.02em',
        margin: 0, color: 'var(--ink)', textWrap: 'pretty',
      }}>{card.title}</h1>
      <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink-mute)', marginTop: 18, textWrap: 'pretty' }}>
        {window.linkifyTerms && onTermTap ? window.linkifyTerms(card.body, onTermTap) : card.body}
      </p>

      <div style={{ height: 1, background: 'var(--rule)', margin: '26px 0 0' }}/>

      <p className="ff-display" style={{
        fontSize: 'var(--t-heading)', fontWeight: 400, lineHeight: 1.25, letterSpacing: '-0.015em',
        color: 'var(--ink)', margin: '24px 0 0', textWrap: 'pretty',
      }}>{card.question}</p>

      <div className="pick-tiles">
        {card.options.map((opt) => (
          <button key={opt} className={'pick-tile' + (pick === opt ? ' chosen' : '') + (pick && pick !== opt ? ' faded' : '')}
                  onClick={() => choose(opt)}>
            <span className="pick-tile-t">{opt}</span>
          </button>
        ))}
      </div>

      {pick && (
        <div className="fade-up" style={{ marginTop: 22, display: 'flex', gap: 13, alignItems: 'flex-start' }}>
          <div style={{ flexShrink: 0, marginTop: -6 }}>
            <window.Roasty state="card" size={64}/>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div className="smallcaps-mono" style={{ marginBottom: 7 }}>Your guess · {pick}</div>
            <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink-mute)', margin: 0, textWrap: 'pretty' }}>
              {card.hold}
            </p>
          </div>
        </div>
      )}

      <div style={{ flex: 1 }}/>
      <div style={{ paddingTop: 30 }}>
        <button className="btn btn-primary" onClick={onContinue} disabled={!pick}>
          {pick ? 'Find out' : 'Make a guess'}
        </button>
      </div>
    </div>
  );
}

// ── DECISION ───────────────────────────────────────────────
// The applied beat: a scenario with two plausible real-world buys. Feedback is
// framed as consequence rather than score, because neither option is wrong in
// the abstract — only wrong for THIS cup.
function DecisionCard({ card, onContinue, onXp, onTermTap }) {
  const [pick, setPick] = useStateAC(null);
  const chosen = pick == null ? null : card.options[pick];
  const right = chosen && chosen.correct;
  const choose = (i) => {
    if (pick != null) return;
    setPick(i);
    if (card.options[i].correct && onXp) onXp();
  };
  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', flex: '1 0 auto', minHeight: 600 }}>
      <div className="smallcaps-mono" style={{ marginBottom: 14 }}>{card.label}</div>

      <h2 className="ff-display" style={{
        fontSize: 'var(--t-heading)', fontWeight: 400, lineHeight: 1.25, letterSpacing: '-0.015em',
        margin: '0 0 18px', color: 'var(--ink)', textWrap: 'pretty',
      }}>{card.title}</h2>

      <div style={{
        background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 14,
        padding: '16px 17px', display: 'flex', gap: 13, alignItems: 'flex-start',
      }}>
        <svg width="17" height="17" viewBox="0 0 17 17" style={{ flexShrink: 0, marginTop: 2 }} aria-hidden="true">
          <path d="M8.5 15.5c3.9 0 6.7-2.8 6.7-6.4S12.4 2.7 8.5 2.7 1.8 5.5 1.8 9.1c0 1.3.4 2.5 1.1 3.5l-.6 2.6 2.7-.7c1 .6 2.2 1 3.5 1z"
                fill="none" stroke="var(--accent)" strokeWidth="1.3" strokeLinejoin="round"/>
        </svg>
        <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink)', margin: 0, textWrap: 'pretty' }}>
          {card.scenario}
        </p>
      </div>

      <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink)', margin: '22px 0 0', textWrap: 'pretty' }}>
        {card.question}
      </p>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 14 }}>
        {card.options.map((o, i) => {
          let cls = 'bag-opt';
          if (pick != null) {
            if (o.correct) cls += ' correct';
            else if (i === pick) cls += ' incorrect';
            else cls += ' faded';
          }
          return (
            <button key={i} className={cls} disabled={pick != null} onClick={() => choose(i)}>
              <span className="bag-opt-t">{o.t}</span>
              <span className="bag-opt-s ff-mono">{o.sub}</span>
            </button>
          );
        })}
      </div>

      {pick != null && (
        <div className="fade-up" style={{ marginTop: 20, display: 'flex', gap: 14, alignItems: 'flex-start' }}>
          <div style={{ flexShrink: 0, marginTop: -8 }}>
            <window.Roasty state={right ? 'correct' : 'wrong'} size={72}/>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div className="smallcaps-mono" style={{ marginBottom: 8 }}>
              {right ? 'Good call' : 'That would backfire'}
            </div>
            <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink-mute)', margin: 0, textWrap: 'pretty' }}>
              {right ? card.right : card.wrong}
            </p>
          </div>
        </div>
      )}

      {pick != null && card.note && (
        <p className="fade-up" style={{
          fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink-mute)', margin: '18px 0 0',
          paddingTop: 16, borderTop: '1px solid var(--rule)', textWrap: 'pretty',
        }}>{card.note}</p>
      )}

      <div style={{ flex: 1 }}/>
      <div style={{ paddingTop: 30 }}>
        <button className="btn btn-primary" onClick={onContinue} disabled={pick == null}>Continue</button>
      </div>
    </div>
  );
}

// ── RECALL ─────────────────────────────────────────────────
// The close. One transfer question (applied, not definitional), and once it's
// answered the card resolves the guess made on the very first screen and lands
// the takeaway as something earned rather than announced.
function RecallCard({ card, onContinue, onXp, prediction }) {
  const [pick, setPick] = useStateAC(null);
  const correctIdx = card.choices.findIndex(c => c.correct);
  const answered = pick != null;
  const choose = (i) => {
    if (answered) return;
    setPick(i);
    if (i === correctIdx && onXp) onXp();
  };
  const guessedRight = prediction && prediction.pick === prediction.a;

  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', flex: '1 0 auto', minHeight: 620 }}>
      <div className="smallcaps-mono" style={{ marginBottom: 14 }}>{card.label}</div>

      <p className="ff-display" style={{
        fontSize: 'var(--t-heading)', fontWeight: 400, lineHeight: 1.25, letterSpacing: '-0.015em',
        color: 'var(--ink)', margin: 0, textWrap: 'pretty',
      }}>{card.question}</p>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 20 }}>
        {card.choices.map((c, i) => {
          let cls = 'mcq-choice';
          if (answered) {
            if (i === correctIdx) cls += ' correct';
            else if (i === pick) cls += ' incorrect';
          }
          return (
            <button key={i} className={cls} disabled={answered} onClick={() => choose(i)}>{c.t}</button>
          );
        })}
      </div>

      {answered && (
        <p className="fade-up" style={{ fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink-mute)', margin: '18px 0 0', textWrap: 'pretty' }}>
          {card.explain}
        </p>
      )}

      {/* Prediction payoff — closes the loop opened on the first card. */}
      {answered && prediction && (
        <div className="fade-up" style={{
          marginTop: 22, paddingTop: 18, borderTop: '1px solid var(--rule)',
          display: 'flex', gap: 13, alignItems: 'flex-start',
        }}>
          <div style={{ flexShrink: 0, marginTop: -6 }}>
            <window.Roasty state={guessedRight ? 'xp' : 'card'} size={64}/>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div className="smallcaps-mono" style={{ marginBottom: 7 }}>
              {guessedRight ? 'You called it' : 'Your opening guess'}
            </div>
            <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink-mute)', margin: 0, textWrap: 'pretty' }}>
              {guessedRight
                ? 'You guessed ' + prediction.pick + ' before the lesson started — and you were right.'
                : 'You guessed ' + prediction.pick + ' before the lesson started. It\u2019s ' + prediction.a + ' \u2014 now you know why.'}
            </p>
          </div>
        </div>
      )}

      {answered && (
        <div className="fade-up" style={{
          marginTop: 32, marginLeft: -24, marginRight: -24,
          padding: '30px 24px 32px', background: 'var(--surface-2)',
        }}>
          <h1 className="ff-display" style={{
            fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.08, letterSpacing: '-0.02em',
            margin: 0, color: 'var(--ink)', textWrap: 'balance',
          }}>{card.line}</h1>
        </div>
      )}

      <div style={{ flex: 1 }}/>
      <div style={{ paddingTop: 26 }}>
        <button className="btn btn-primary" onClick={onContinue} disabled={!answered}>Finish lesson</button>
      </div>
    </div>
  );
}

Object.assign(window, { PredictCard, DecisionCard, RecallCard });
