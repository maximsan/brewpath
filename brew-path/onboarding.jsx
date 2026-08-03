// onboarding.jsx — the Roasty-led onboarding flow.
// Adopts Duolingo patterns (talking mascot, progress, expectation-setting,
// between-step encouragement) in Brew Path's minimal dark aesthetic.
//
// Two distinct flow DIRECTIONS, switchable via the `onbFlow` tweak (or a
// ?flow= URL override used by the screens overview to compare them):
//   • guided     — Roasty is present on every question, speaking in a bubble.
//   • fieldguide — quiet, editorial. Roasty only bookends the flow.
//
// Tweakable: flow direction, Roasty's speech style (bubble-beside / bubble-
// above / caption), number of questions (depth), and the expectation-setting
// copy/number. Progress bar is always shown; Skip lives in the top-right of the
// header so it's always reachable and reads as part of the app.

const { useState: useStateONB } = React;

// ── Content ──────────────────────────────────────────────────────────────
const ONB_QUESTIONS = {
  goal: {
    topic: 'GOAL',
    prompt: 'What brings you here?',
    options: [
      { title: 'Brew better at home',        desc: 'Hands-on guidance for V60, AeroPress, and friends.' },
      { title: 'Understand what I’m tasting', desc: 'Build a vocabulary for the cup in front of you.' },
      { title: 'Just curious about coffee',   desc: 'A quiet field guide. No pressure.' },
    ],
  },
  brewer: {
    topic: 'BREWER',
    prompt: 'What do you brew with?',
    options: [
      { title: 'V60',          desc: 'Pour-over. Clean, light, articulate.' },
      { title: 'AeroPress',    desc: 'Forgiving and fast. A good first brewer.' },
      { title: 'Not sure yet', desc: 'We’ll teach what you need, when you need it.' },
    ],
  },
  commitment: {
    topic: 'RHYTHM',
    prompt: 'How much time feels right each day?',
    options: [
      { title: '5 min / day',  desc: 'A cup’s worth. Casual.' },
      { title: '10 min / day', desc: 'A steady habit. Regular.' },
      { title: '15 min / day', desc: 'Deep practice. Serious.' },
    ],
  },
  experience: {
    topic: 'LEVEL',
    prompt: 'How well do you know coffee already?',
    options: [
      { title: 'New to coffee',         desc: 'Start from the cherry. We’ll build up.' },
      { title: 'I know my way around',  desc: 'You brew most mornings.' },
      { title: 'Pretty serious',        desc: 'Scales, timers, the works.' },
    ],
  },
  motivations: {
    topic: 'WHY',
    prompt: 'What are you hoping to get from this?',
    hint: 'Pick as many as you like.',
    multi: true,
    options: [
      { title: 'Brew better at home' },
      { title: 'Understand flavour' },
      { title: 'Order with confidence' },
      { title: 'Geek out on the craft' },
      { title: 'Slow down and enjoy it' },
    ],
  },
  reminders: {
    topic: 'HABIT',
    prompt: 'Want me to nudge you to practice?',
    options: [
      { title: 'Morning',      desc: 'A nudge with your first cup.' },
      { title: 'Midday',       desc: 'A short break to learn something.' },
      { title: 'Evening',      desc: 'Wind down with a lesson.' },
      { title: 'No reminders', desc: 'I’ll come back on my own.' },
    ],
  },
};

const ONB_DEPTH = {
  essential: ['goal', 'brewer', 'commitment'],
  standard:  ['goal', 'brewer', 'commitment', 'experience'],
  full:      ['goal', 'brewer', 'commitment', 'experience', 'motivations', 'reminders'],
};

// Spell small counts as words for the expectation line; fall back to digits.
const ONB_NUM_WORDS = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight'];
function onbNumWord(n) { return ONB_NUM_WORDS[n] || String(n); }

// URL override so the screens overview can force a direction per-iframe.
function onbFlowOverride() {
  try { return new URLSearchParams(location.search).get('flow'); } catch (e) { return null; }
}

// ── Roasty speech — three styles, driven by the `roastyVoice` tweak ────────
function OnbSpeech({ text, voice = 'bubble-top', state = 'idle', size }) {
  const Bubble = ({ dir }) => (
    <div style={{
      position: 'relative', background: 'var(--surface)', border: '1px solid var(--rule)',
      borderRadius: 12, padding: '13px 16px', color: 'var(--ink)',
      fontFamily: "'IBM Plex Sans', sans-serif", fontSize: 'var(--t-body)', lineHeight: 1.45,
      maxWidth: dir === 'left' ? 230 : 330, textWrap: 'pretty',
    }}>
      {text}
      <span style={{
        position: 'absolute', width: 11, height: 11, background: 'var(--surface)',
        borderLeft: '1px solid var(--rule)', borderBottom: '1px solid var(--rule)',
        ...(dir === 'left'
          ? { left: -6, top: 22, transform: 'rotate(45deg)' }
          : { bottom: -6, left: 38, transform: 'rotate(-45deg)' }),
      }}/>
    </div>
  );

  if (voice === 'caption') {
    return (
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
        <Roasty state={state} size={size || 150}/>
        <div style={{
          fontFamily: "'Fraunces', serif", fontStyle: 'italic', fontSize: 'var(--t-heading)',
          color: 'var(--ink-mute)', textAlign: 'center', maxWidth: 300, lineHeight: 1.35,
          textWrap: 'pretty',
        }}>{text}</div>
      </div>
    );
  }
  if (voice === 'bubble-side') {
    return (
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 6 }}>
        <Roasty state={state} size={size || 84} style={{ flexShrink: 0, marginTop: -8 }}/>
        <div style={{ marginTop: 10 }}><Bubble dir="left"/></div>
      </div>
    );
  }
  // bubble-top (default)
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
      <Bubble dir="down"/>
      <Roasty state={state} size={size || 148}/>
    </div>
  );
}

// ── Top header: back chevron + progress bar + skip ─────────────────────────
function OnbHeader({ onBack, frac, showProgress, onSkip, showSkip }) {
  return (
    <div style={{
      paddingTop: 60, paddingBottom: 14, paddingLeft: 18, paddingRight: 12,
      display: 'flex', alignItems: 'center', gap: 14, background: 'var(--bg)',
      borderBottom: '1px solid var(--rule)',
    }}>
      <button className="close-btn" onClick={onBack} aria-label="Back" style={{ flexShrink: 0 }}>
        <svg width="20" height="20" viewBox="0 0 20 20">
          <path d="M12 4 L6 10 L12 16" fill="none" stroke="currentColor" strokeWidth="1.6"
                strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      </button>
      {showProgress && (
        <div style={{ flex: 1, height: 6, borderRadius: 999, background: 'var(--surface-2)', overflow: 'hidden' }}>
          <div style={{
            height: '100%', width: `${Math.round(frac * 100)}%`, background: 'var(--accent)',
            borderRadius: 999, transition: 'width 360ms cubic-bezier(.4,0,.2,1)',
          }}/>
        </div>
      )}
      {showSkip && (
        <button className="btn btn-link" onClick={onSkip} aria-label="Skip onboarding for now"
                style={{ flexShrink: 0, padding: '6px 6px', letterSpacing: '0.02em' }}>
          Skip
        </button>
      )}
    </div>
  );
}

// ── One question screen (single- or multi-select) ──────────────────────────
function OnbQuestion({ q, value, onChange, flow, voice, qPos, qCount }) {
  const isGuided = flow === 'guided';
  const toggle = (i) => {
    if (q.multi) {
      const cur = new Set(value || []);
      cur.has(i) ? cur.delete(i) : cur.add(i);
      onChange([...cur]);
    } else {
      onChange(i);
    }
  };
  return (
    <div className="px-24" style={{ display: 'flex', flexDirection: 'column', gap: 22, paddingTop: 18 }}>
      {isGuided ? (
        <div style={{ paddingTop: 4 }}>
          <OnbSpeech voice={voice} state="idle" text={q.prompt}
                     size={voice === 'bubble-side' ? 70 : 104}/>
          {q.hint && (
            <div className="smallcaps" style={{ textAlign: 'center', marginTop: 12, color: 'var(--ink-mute)' }}>
              {q.hint}
            </div>
          )}
        </div>
      ) : (
        <div>
          <div className="smallcaps" style={{ marginBottom: 12 }}>
            QUESTION {String(qPos + 1).padStart(2, '0')} / {String(qCount).padStart(2, '0')} · {q.topic}
          </div>
          <h1 className="ff-display" style={{
            fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.01em',
            margin: 0, color: 'var(--ink)', textWrap: 'pretty',
          }}>{q.prompt}</h1>
          {q.hint && (
            <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 8 }}>{q.hint}</div>
          )}
        </div>
      )}

      <div className="stack gap-12">
        {q.options.map((opt, i) => {
          const sel = q.multi ? (value || []).includes(i) : value === i;
          return (
            <div key={i} className={'pick-card' + (sel ? ' selected' : '')} onClick={() => toggle(i)}>
              <div>
                <div className="pc-title">{opt.title}</div>
                {opt.desc && <div className="pc-desc">{opt.desc}</div>}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

// ── Expectation screen — Roasty tells you how many questions to expect ──────
function OnbExpectation({ voice, count, copyTemplate }) {
  const tmpl = copyTemplate || 'Just {n} quick questions, then your first lesson.';
  const text = tmpl
    .replace('{n}', onbNumWord(count))
    .replace('{N}', String(count));
  return (
    <div className="px-24" style={{
      flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center',
      justifyContent: 'center', textAlign: 'center', paddingBottom: 24, gap: 8,
    }}>
      <OnbSpeech voice={voice} state="awake" text={text}/>
    </div>
  );
}

// ── Closing hand-off — a small celebratory Roasty moment ────────────────────
function OnbClosing({ voice }) {
  return (
    <div className="px-24" style={{
      flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center',
      justifyContent: 'center', textAlign: 'center', paddingBottom: 12, gap: 18,
    }}>
      <div>
        <h1 className="ff-display" style={{
          fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em',
          margin: 0, color: 'var(--ink)',
        }}>You’re all set.</h1>
        <p style={{
          fontSize: 'var(--t-body)', lineHeight: 1.5, color: 'var(--ink-mute)', marginTop: 12,
          marginBottom: 0, maxWidth: 300,
        }}>Your first lesson is brewing. Plant the seed and let’s grow your tree.</p>
      </div>
    </div>
  );
}

// ── Flow driver ────────────────────────────────────────────────────────────
function OnboardingFlow({ initialSlug = 'expectation', t = {}, onExit, onBack }) {
  const flow = onbFlowOverride() || t.onbFlow || 'guided';
  const voice = t.roastyVoice || 'bubble-top';
  const depth = t.flowDepth || 'full';

  const qSlugs = ONB_DEPTH[depth] || ONB_DEPTH.full;
  const steps = ['expectation', ...qSlugs, 'onboarding-done'];
  const startIdx = Math.max(0, steps.indexOf(initialSlug));

  const [idx, setIdx] = useStateONB(startIdx);
  const [answers, setAnswers] = useStateONB({});
  const [doneSeen, setDoneSeen] = useStateONB(false);

  // Before the closing screen, Roasty gets a send-off styled to the flow.
  const doneRoasty = flow === 'fieldguide'
    ? { state: 'module', eyebrow: 'FIELD GUIDE READY', title: 'Your guide is open.' }
    : { state: 'lesson',  eyebrow: 'ALL SET',          title: 'Let’s grow your tree.' };

  const slug = steps[idx];
  const qCount = qSlugs.length;
  const qPos = qSlugs.indexOf(slug);
  const isQuestion = qPos !== -1;

  const next = () => { if (idx < steps.length - 1) setIdx(idx + 1); else onExit && onExit(); };
  const back = () => { if (idx > 0) setIdx(idx - 1); else onBack && onBack(); };
  const setAnswer = (v) => setAnswers(a => ({ ...a, [slug]: v }));

  // progress fraction: questions advance it; bookends sit at the edges.
  let frac = 0;
  if (slug === 'expectation') frac = 0;
  else if (slug === 'onboarding-done') frac = 1;
  else frac = (qPos + 1) / (qCount + 1);

  // can we continue?
  let canContinue = true;
  if (isQuestion) {
    const q = ONB_QUESTIONS[slug];
    const v = answers[slug];
    canContinue = q.multi ? (v && v.length > 0) : (v != null);
  }

  // CTA label
  let cta = 'Continue';
  if (slug === 'expectation') cta = 'Let’s go';
  else if (slug === 'onboarding-done') cta = 'Start my first lesson';

  // body
  let body;
  if (slug === 'expectation') {
    body = <OnbExpectation voice={voice} count={qCount} copyTemplate={t.expectCopy}/>;
  } else if (slug === 'onboarding-done') {
    body = <OnbClosing voice={voice}/>;
  } else {
    body = <OnbQuestion q={ONB_QUESTIONS[slug]} value={answers[slug]} onChange={setAnswer}
                        flow={flow} voice={voice} qPos={qPos} qCount={qCount}/>;
  }

  const label = slug === 'expectation' ? '02 Get ready'
    : slug === 'onboarding-done' ? 'All set'
    : `Q${qPos + 1} ${ONB_QUESTIONS[slug].topic}`;

  // header is shown for question screens (and bookends get a bare back row).
  if (slug === 'onboarding-done' && !doneSeen) {
    return <RoastyMoment state={doneRoasty.state} eyebrow={doneRoasty.eyebrow} title={doneRoasty.title}
                         autoMs={2100} onDone={() => setDoneSeen(true)}/>;
  }
  return (
    <div className="screen" data-screen-label={label}>
      <OnbHeader onBack={back} frac={frac}
                 showProgress={slug !== 'onboarding-done'}
                 showSkip={slug !== 'onboarding-done'} onSkip={onExit}/>
      <div className="scroll" style={{ paddingTop: 0, display: 'flex', flexDirection: 'column' }}>
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
          {body}
        </div>
        <div className="px-24" style={{ paddingTop: 24, paddingBottom: 18 }}>
          <button className="btn btn-primary" disabled={!canContinue} onClick={next}>{cta}</button>
        </div>
      </div>
    </div>
  );
}

window.OnboardingFlow = OnboardingFlow;
window.ONB_DEPTH = ONB_DEPTH;
