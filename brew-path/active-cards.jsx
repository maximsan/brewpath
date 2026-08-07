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

// Fisher–Yates over 0..n-1 — choice display order, shuffled once per mount, so a
// card authored answer-first never renders its answer first.
// 'AT THE SHELF' → 'At the shelf'. Scene labels are authored in caps for the
// mono eyebrow style; cards that promote the label to a Fraunces heading need
// it back in sentence case.
function acSentenceCase(s) {
  const str = String(s || '').toLowerCase();
  return str.charAt(0).toUpperCase() + str.slice(1);
}

function acShuffle(n) {
  const a = Array.from({ length: n }, (_, i) => i);
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

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
  // Cloze questions carry a `___` blank. Once a tile is picked the word drops
  // into the sentence so the learner reads their own guess back as a claim —
  // that's what the recall card later confirms or overturns. Questions without
  // a blank render untouched.
  const questionNode = (() => {
    const parts = String(card.question).split(/_{2,}/);
    if (parts.length < 2) return card.question;
    return parts.map((seg, i) => (
      <React.Fragment key={i}>
        {seg}
        {i < parts.length - 1 && window.FillSlot && (
          <window.FillSlot word={pick} state={pick ? 'guess' : 'empty'}/>
        )}
      </React.Fragment>
    ));
  })();
  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', flex: '1 0 auto', minHeight: 600 }}>
      {/* No eyebrow: the label is the lesson number, which the top bar and the
          Path already carry. The card opens on its own title. */}
      <h1 className="ff-display" style={{
        fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.08, letterSpacing: '-0.02em',
        margin: 0, color: 'var(--ink)', textWrap: 'pretty',
      }}>{card.title}</h1>
      {/* Reading copy, not a caption — full ink at 1.6, matching concept
          paragraphs. The Fraunces question below is contrast enough; no rule. */}
      <p style={{ fontSize: 'var(--t-lead)', lineHeight: 1.55, color: 'var(--ink)', marginTop: 18, textWrap: 'pretty' }}>
        {window.linkifyTerms && onTermTap ? window.linkifyTerms(card.body, onTermTap) : card.body}
      </p>

      {/* The guess moment as its own section — mono eyebrow, then the
          question in the same sans lead as the description above. One text
          voice; the mono slot and Fraunces tiles carry the emphasis. */}
      <div className="smallcaps-mono" style={{ margin: '30px 0 0' }}>First guess</div>
      <p style={{
        fontSize: 'var(--t-lead)', lineHeight: 1.5,
        color: 'var(--ink)', margin: '12px 0 0', textWrap: 'pretty',
      }}>{questionNode}</p>

      <div className="pick-tiles">
        {card.options.map((opt) => (
          <button key={opt} className={'pick-tile' + (pick === opt ? ' chosen' : '') + (pick && pick !== opt ? ' faded' : '')}
                  onClick={() => choose(opt)}>
            <span className="pick-tile-t">{opt}</span>
          </button>
        ))}
      </div>

      {pick && (
        <window.AnswerFeedback state="card" size={64} bodySize="body"
          label={'Your guess \u00B7 ' + pick} text={card.hold}/>
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
function DecisionCard({ card, onContinue, onCorrect}) {
  const [pick, setPick] = useStateAC(null);
  const [order] = useStateAC(() => acShuffle(card.options.length));
  const chosen = pick == null ? null : card.options[pick];
  const right = chosen && chosen.correct;
  const choose = (i) => {
    if (pick != null) return;
    setPick(i);
    if (card.options[i].correct && onCorrect) onCorrect();
  };
  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', flex: '1 0 auto', minHeight: 600 }}>
      {/* One header line, not two: the scene label IS the title here. The mono
          eyebrow plus a written title said the same thing twice, and the
          scenario below already carries the specifics. */}
      <h2 className="ff-display" style={{
        fontSize: 'var(--t-heading)', fontWeight: 400, lineHeight: 1.25, letterSpacing: '-0.015em',
        margin: '0 0 18px', color: 'var(--ink)', textWrap: 'pretty',
      }}>{acSentenceCase(card.label)}</h2>

      {/* Left-rule aside, same treatment as the dictionary's IN PRACTICE block.
          A boxed card here competed with the choice tiles below — the scenario
          sets up the decision, it is not the thing being chosen. Unlabelled: the
          scene label above is already the heading. */}
      <div style={{ borderLeft: '2px solid var(--accent)', paddingLeft: 16 }}>
        <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.6, color: 'var(--ink)', margin: 0, textWrap: 'pretty' }}>
          {card.scenario}
        </p>
      </div>

      <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink)', margin: '22px 0 0', textWrap: 'pretty' }}>
        {card.question}
      </p>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 14 }}>
        {order.map((oi) => {
          const o = card.options[oi];
          let cls = 'bag-opt';
          if (pick != null) {
            if (o.correct) cls += ' correct';
            else if (oi === pick) cls += ' incorrect';
            else cls += ' faded';
          }
          return (
            <button key={oi} className={cls} disabled={pick != null} onClick={() => choose(oi)}>
              <span className="bag-opt-t">{o.t}</span>
              <span className="bag-opt-s ff-mono">{o.sub}</span>
            </button>
          );
        })}
      </div>

      {pick != null && (
        <window.AnswerFeedback correct={right} bodySize="body"
          label={right ? 'Good call' : 'That would backfire'}
          text={right ? card.right : card.wrong}/>
      )}

      {pick != null && card.note && (
        <window.CardTakeaway text={card.note}/>
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
function RecallCard({ card, onContinue, onCorrect, prediction }) {
  const [pick, setPick] = useStateAC(null);
  const [order] = useStateAC(() => acShuffle(card.choices.length));
  const correctIdx = card.choices.findIndex(c => c.correct);
  const answered = pick != null;
  const choose = (i) => {
    if (answered) return;
    setPick(i);
    if (i === correctIdx && onCorrect) onCorrect();
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
        {order.map((oi) => {
          let cls = 'mcq-choice';
          if (answered) {
            if (oi === correctIdx) cls += ' correct';
            else if (oi === pick) cls += ' incorrect';
          }
          return (
            <button key={oi} className={cls} disabled={answered} onClick={() => choose(oi)}>{card.choices[oi].t}</button>
          );
        })}
      </div>

      {answered && (
        <window.AnswerFeedback correct={pick === correctIdx} bodySize="body"
          label={pick === correctIdx ? 'Correct' : 'Not quite'}
          text={card.explain}/>
      )}

      {/* Prediction payoff — closes the loop opened on the first card. Artless:
          it is a reply to the guess, not a second verdict on this answer. */}
      {answered && prediction && (
        <window.AnswerFeedback art={false} borderTop marginTop={18} bodySize="body"
          state={guessedRight ? 'correct' : 'card'}
          label={guessedRight ? 'You called it' : 'Your opening guess'}
          text={guessedRight
            ? 'You guessed ' + prediction.pick + ' before the lesson started — and you were right.'
            : 'You guessed ' + prediction.pick + ' before the lesson started. It\u2019s ' + prediction.a + ' \u2014 now you know why.'}/>
      )}

      {answered && (
        <div className="fade-up" style={{
          marginTop: 32, marginLeft: -24, marginRight: -24,
          padding: '30px 24px 32px', background: 'var(--surface-2)', textAlign: 'center',
        }}>
          <h1 className="ff-display" style={{
            fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.08, letterSpacing: '-0.02em',
            margin: 0, color: 'var(--ink)', textWrap: 'balance',
          }}>
            {/* Each sentence takes its own row. These lines are two-beat aphorisms
                ("Coffee is fruit. Everything else follows from that.") and the
                parallel only reads if the break lands on the full stop. */}
            {String(card.line).split(/(?<=[.?!])\s+/).map((s, i) => (
              <span key={i} style={{ display: 'block' }}>{s}</span>
            ))}
          </h1>
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
