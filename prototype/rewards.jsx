// rewards.jsx — Reward states: lesson complete, module complete, module reward card.

const { useState: useStateR, useEffect: useEffectR } = React;

// ───────────────────────────────────────────────────────────
// Lesson Complete — full screen, tree animates from previous
// points state to new points state. Continue → next lesson.
// ───────────────────────────────────────────────────────────
function LessonCompleteScreen({ lesson, result, freezeEarned = false, lessonState, onPractice, fromStage, toStage, toNextStage, prevPoints, newPoints, nextPlayable = true, onContinue, onBack, onDuel, brewChallenge, brewChallengeState, onStartChallenge, onNotNowChallenge}) {
  // Tree stages come from CORE-LESSON progress only (fromStage/toStage,
  // via treeStageFromCore). No points-derived fallback — single source of truth.
  const prevStage = fromStage != null ? fromStage : 1;
  const newStage  = toStage   != null ? toStage   : 1;

  // Lesson state (mastery) + its presentation. Only Needs Practice earns a
  // chip — the score above it already says how the run went. It wears the
  // action colour, because it is an invitation to replay, never a failure red.
  const stateMeta = (window.LESSON_STATES || {})[lessonState] || null;
  const weak = lessonState === 'needs-practice';
  const stateTone = weak
    ? { fg: 'var(--accent)', bg: 'color-mix(in oklab, var(--accent) 12%, var(--surface))', bd: 'color-mix(in oklab, var(--accent) 40%, var(--rule))' }
    : null;

  const earned = newPoints - prevPoints;

  const [phase, setPhase] = useStateR('roasty');
  const [preview, setPreview] = useStateR(false);
  const [cState, setCState] = useStateR('suggested');
  const startCh  = () => { setCState('started');   setTimeout(() => onStartChallenge && onStartChallenge(), 900); };
  const notNowCh = () => { setCState('dismissed'); setTimeout(() => onNotNowChallenge && onNotNowChallenge(), 850); };
  if (phase === 'roasty') {
    const rtitle = weak ? 'Good start.' : lessonState === 'perfect' ? 'Perfect run!' : lessonState === 'mastered' ? 'Mastered it.' : 'Nice work.';
    return <RoastyMoment state="lesson" eyebrow="LESSON COMPLETE" title={rtitle}
                         onDone={() => setPhase('content')}/>;
  }

  return (
    <div className="screen" data-screen-label="Lesson Complete"
         style={{ background: 'var(--bg)', position: 'relative', height: '100%' }}>
      <div className="lesson-topbar" style={{ borderBottom: 'none', background: 'transparent' }}>
        <button className="close-btn" onClick={onBack} aria-label="Back">
          <window.CloseMark/>
        </button>
        <div/><div/>
      </div>

      <div className="scroll" style={{ paddingTop: 90, paddingBottom: 0, display: 'flex', flexDirection: 'column' }}>
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center' }}>
          <div className="px-24" style={{ textAlign: 'center' }}>
            <div className="smallcaps">LESSON COMPLETE</div>
            <h1 className="ff-display" style={{
              fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.01em',
              margin: '10px 0 0', color: 'var(--ink)',
            }}>
              {lesson.title}
            </h1>
            {(result || (weak && stateMeta)) && (
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 12, marginTop: 14 }}>
                {result && (
                  <span className="ff-mono" style={{ fontSize: 'var(--t-body)', letterSpacing: '0.04em', color: 'var(--ink)', fontVariantNumeric: 'tabular-nums', whiteSpace: 'nowrap' }}>
                    {result.correct} / {result.total}
                  </span>
                )}
                {result && weak && stateMeta && <span style={{ width: 3, height: 3, borderRadius: 999, background: 'var(--ink-mute)', opacity: 0.6 }}/>}
                {weak && stateMeta && stateTone && (
                  <span className="ff-mono" style={{
                    fontSize: 'var(--t-label)', letterSpacing: '0.14em', textTransform: 'uppercase',
                    color: stateTone.fg, background: stateTone.bg, border: '1px solid ' + stateTone.bd,
                    borderRadius: 999, padding: '5px 11px', whiteSpace: 'nowrap',
                  }}>{stateMeta.label}</span>
                )}
              </div>
            )}
          </div>

          <div style={{ display: 'flex', justifyContent: 'center', padding: '36px 0 0', position: 'relative' }}>
            <AnimatedTree fromStage={prevStage} toStage={newStage} size={240}/>
          </div>
          {/* Most completions do not cross a stage threshold. Say how far the next
              one is, so a still tree reads as progress rather than nothing. */}
          {newStage === prevStage && toNextStage > 0 && (
            <div className="ff-mono" style={{
              textAlign: 'center', marginTop: 10, fontSize: 'var(--t-label)', letterSpacing: '0.12em',
              textTransform: 'uppercase', color: 'color-mix(in oklab, var(--ink-mute) 76%, var(--ink))',
            }}>{toNextStage} {toNextStage === 1 ? 'lesson' : 'lessons'} to the next stage</div>
          )}
          <div className="px-24" style={{ width: '100%', marginTop: 28 }}>
            <div style={{
              background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 16, overflow: 'hidden',
            }}>
              {/* points earned */}
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10, padding: '14px 18px' }}>
                <PointsBean size={18}/>
                <span className="ff-mono" style={{ fontSize: 'var(--t-support)', fontWeight: 500, letterSpacing: '0.06em', textTransform: 'uppercase', whiteSpace: 'nowrap' }}>
                  +{earned} PTS
                </span>
              </div>

              {/* Keeping the streak finally pays out something concrete. This is
                  the first time most users meet the word "freeze" — before they
                  ever need one, not at the moment they're told they lost a day. */}
              {freezeEarned && (
                <>
                  <div style={{ height: 1, background: 'var(--rule)' }}/>
                  <div style={{ padding: '13px 16px', display: 'flex', alignItems: 'center', gap: 12 }}>
                    <span style={{ width: 34, height: 34, borderRadius: 12, flexShrink: 0, display: 'grid', placeItems: 'center', background: 'color-mix(in oklab, var(--accent) 12%, var(--surface))' }}>
                      {window.FreezeMark ? <window.FreezeMark size={18}/> : null}
                    </span>
                    <span style={{ minWidth: 0, flex: 1 }}>
                      <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.16em', textTransform: 'uppercase', color: 'var(--accent)', display: 'block' }}>FREEZE EARNED</span>
                      <span style={{ fontSize: 'var(--t-support)', fontWeight: 500, color: 'var(--ink)', display: 'block', marginTop: 2 }}>You're covered for one missed day.</span>
                    </span>
                  </div>
                </>
              )}

              {lesson.reward && lesson.reward.title && (
                <>
                  <div style={{ height: 1, background: 'var(--rule)' }}/>
                  <button onClick={() => setPreview(true)} style={{
                    width: '100%', appearance: 'none', cursor: 'pointer', textAlign: 'left', background: 'transparent', border: 0,
                    padding: '13px 16px', display: 'flex', alignItems: 'center', gap: 12,
                  }}>
                    <span style={{ width: 34, height: 34, borderRadius: 12, flexShrink: 0, display: 'grid', placeItems: 'center', background: 'color-mix(in oklab, var(--accent) 12%, var(--surface))' }}>
                      <FlavorStamp size={26} rotate={-8}/>
                    </span>
                    <span style={{ minWidth: 0, flex: 1 }}>
                      <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.16em', textTransform: 'uppercase', color: 'var(--accent)', display: 'block' }}>NEW CARD UNLOCKED</span>
                      <span style={{ fontSize: 'var(--t-support)', fontWeight: 500, color: 'var(--ink)', display: 'block', marginTop: 2 }}>{lesson.reward.title}</span>
                    </span>
                    <window.Chevron/>
                  </button>
                </>
              )}
            </div>
          </div>
        </div>

        <div className="px-24" style={{ position: 'sticky', bottom: 0, marginTop: 'auto', paddingTop: 16, paddingBottom: 24, background: 'linear-gradient(to top, var(--bg) 74%, transparent)' }}>
          {brewChallenge && window.ChallengeSuggestion && brewChallengeState !== 'completed' ? (
            <>
              <window.ChallengeSuggestion challenge={brewChallenge} state={cState} realState={brewChallengeState} onStart={startCh} onNotNow={notNowCh}/>
              {/* The offer's own Start/Save advance the flow only while it's a
                  live, un-acted suggestion. Once the challenge is already
                  completed/active, or the user has started/dismissed it, the
                  card is informational — so give an explicit way forward. */}
              {!(cState === 'suggested' && brewChallengeState !== 'completed' && brewChallengeState !== 'active') && (
                <button className="btn btn-primary" style={{ marginTop: 14 }} onClick={onContinue}>{nextPlayable ? 'Next lesson' : 'Back to Path'}</button>
              )}
            </>
          ) : (
            <>
              <button className="btn btn-primary" onClick={onContinue}>{nextPlayable ? 'Next lesson' : 'Back to Path'}</button>
              {(onDuel || (nextPlayable && !weak)) && (
                <div style={{ display: 'flex', alignItems: 'stretch', gap: 10, marginTop: 10 }}>
                  {onDuel && (
                    <a className="btn btn-ghost" href="#" style={{ flex: 1, textAlign: 'center', textDecoration: 'none' }} onClick={(e) => { e.preventDefault(); onDuel(); }}>
                      Duel a friend
                    </a>
                  )}
                  {nextPlayable && !weak && (
                    <a className="btn btn-ghost" href="#" style={{ flex: 1, textAlign: 'center', textDecoration: 'none' }} onClick={(e) => { e.preventDefault(); onBack(); }}>
                      Back to Path
                    </a>
                  )}
                </div>
              )}
            </>
          )}
          {weak && onPractice && (
            <div style={{ marginTop: 10 }}>
              <a className="btn btn-ghost" href="#" onClick={(e) => { e.preventDefault(); onPractice(); }}
                 style={{ display: 'block', textAlign: 'center', textDecoration: 'none', color: 'var(--accent)', borderColor: 'color-mix(in oklab, var(--accent) 45%, var(--rule))' }}>
                Practice this lesson again
              </a>
            </div>
          )}
        </div>
      </div>

      {preview && lesson.reward && (
        <div onClick={() => setPreview(false)} style={{
          position: 'absolute', inset: 0, zIndex: 20, display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center', padding: '0 24px',
          background: 'var(--veil-strong)', backdropFilter: 'blur(3px)',
          overflowY: 'auto',
          animation: 'tfFade .18s ease-out',
        }}>
          <style>{`@keyframes tfFade{from{opacity:0}to{opacity:1}}`}</style>
          <button onClick={(e) => { e.stopPropagation(); setPreview(false); }} aria-label="Close preview" style={{
            position: 'absolute', top: 16, right: 16, width: 40, height: 40, borderRadius: 999,
            appearance: 'none', cursor: 'pointer', display: 'grid', placeItems: 'center',
            background: 'var(--surface)', border: '1px solid var(--rule)', color: 'var(--ink)',
          }}>
            <window.CloseMark size={16}/>
          </button>
          <div onClick={(e) => e.stopPropagation()} style={{ width: '100%', display: 'flex', justifyContent: 'center' }}>
            <RewardCard reward={lesson.reward}/>
          </div>
        </div>
      )}
    </div>
  );
}

// ───────────────────────────────────────────────────────────
// Module Complete — tree growth with a stronger emotional beat.
// Continue → module reward card.
// ───────────────────────────────────────────────────────────
function ModuleCompleteScreen({ module, fromStage, toStage, prevPoints, newPoints, onContinue, onBack, reward, hasNext }) {
  // Tree stages come from CORE-LESSON progress only (single source of truth).
  const prevStage = fromStage != null ? fromStage : 1;
  const newStage  = toStage   != null ? toStage   : 1;
  const earned = newPoints - prevPoints;

  const [phase, setPhase] = useStateR('roasty');
  const [flipped, setFlipped] = useStateR(false);
  const [half, setHalf] = useStateR(false);   // toggles at the flip midpoint so exactly one face shows
  const flipTo = (v) => {
    setFlipped(v);
    setTimeout(() => setHalf(v), 410);
  };
  if (phase === 'roasty') {
    return <RoastyMoment state="module" eyebrow="MODULE COMPLETE" title="Look how far you’ve come."
                         autoMs={2200} onDone={() => setPhase('content')}/>;
  }

  const faceBase = {
    position: 'absolute', inset: 0,
    backfaceVisibility: 'hidden', WebkitBackfaceVisibility: 'hidden',
    overflow: 'hidden', borderRadius: 'inherit',
  };

  return (
    <div className="screen" data-screen-label="Module Complete"
         style={{ background: 'var(--bg)' }}>
      {/* perspective wrapper so the whole screen can turn over */}
      <div style={{ position: 'absolute', inset: 0, perspective: 1800, perspectiveOrigin: '50% 42%' }}>
        <div style={{
          position: 'absolute', inset: 0, transformStyle: 'preserve-3d',
          transition: 'transform 820ms cubic-bezier(.62,.04,.2,1)',
          transform: flipped ? 'rotateY(180deg)' : 'none',
        }}>

          {/* ───── FRONT · celebration ───── */}
          <div style={{ ...faceBase, visibility: half ? 'hidden' : 'visible' }}>
            <div aria-hidden="true" style={{
              position: 'absolute', inset: 0, pointerEvents: 'none',
              background: 'radial-gradient(circle at 50% 40%, color-mix(in oklab, var(--accent) 14%, transparent) 0%, transparent 60%)',
            }}/>
            <div className="lesson-topbar" style={{ borderBottom: 'none', background: 'transparent' }}>
              <button className="close-btn" onClick={onBack} aria-label="Back">
                <window.CloseMark/>
              </button>
              <div/><div/>
            </div>

            <div className="scroll" style={{ paddingTop: 84, paddingBottom: 32, display: 'flex', flexDirection: 'column', position: 'relative', height: '100%' }}>
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center' }}>
                <div className="px-24" style={{ textAlign: 'center' }}>
                  <div className="smallcaps" style={{ color: 'var(--accent)' }}>MODULE COMPLETE</div>
                  <h1 className="ff-display" style={{
                    fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em',
                    margin: '10px 0 0', color: 'var(--ink)',
                  }}>
                    {module.title}
                  </h1>
                </div>

                <div style={{ display: 'flex', justifyContent: 'center', padding: '36px 0 0', position: 'relative' }}>
                  <AnimatedTree fromStage={prevStage} toStage={newStage} size={250}/>
                </div>

                <div className="px-24" style={{ textAlign: 'center', marginTop: 28 }}>
                  <div style={{
                    display: 'inline-flex', alignItems: 'center', gap: 10,
                    background: 'var(--surface)',
                    border: '1px solid var(--rule)',
                    padding: '10px 18px', borderRadius: 999,
                  }}>
                    <PointsBean size={18}/>
                    <span className="ff-mono" style={{ fontSize: 'var(--t-support)', fontWeight: 500, letterSpacing: '0.06em', textTransform: 'uppercase', whiteSpace: 'nowrap' }}>
                      +{earned} PTS
                    </span>
                  </div>
                </div>
              </div>

              <div className="px-24">
                <p style={{
                  fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)',
                  margin: '0 auto 16px', textAlign: 'center', maxWidth: 280, textWrap: 'pretty',
                }}>
                  A reward card is waiting on the other side.
                </p>
                <button className="btn btn-primary" onClick={() => flipTo(true)}
                        style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10 }}>
                  Turn it over
                  <svg width="18" height="18" viewBox="0 0 20 20" aria-hidden="true">
                    <path d="M4 10a6 6 0 0 1 10.5-4M16 10a6 6 0 0 1-10.5 4" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/>
                    <path d="M14.5 3v3.2h-3.2M5.5 17v-3.2h3.2" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
                  </svg>
                </button>
              </div>
            </div>
          </div>

          {/* ───── BACK · reward card ───── */}
          <div style={{ ...faceBase, visibility: half ? 'visible' : 'hidden', transform: 'rotateY(180deg)' }}>
            <div aria-hidden="true" style={{
              position: 'absolute', inset: 0, pointerEvents: 'none',
              background: 'radial-gradient(ellipse at 50% 30%, color-mix(in oklab, var(--accent) 18%, transparent) 0%, transparent 55%)',
            }}/>
            <div className="lesson-topbar" style={{ borderBottom: 'none', background: 'transparent' }}>
              <button className="close-btn" onClick={() => flipTo(false)} aria-label="Flip back">
                <window.BackMark/>
              </button>
              <div/><div/>
            </div>

            <div className="scroll" style={{ paddingTop: 90, paddingBottom: 32, display: 'flex', flexDirection: 'column', position: 'relative', height: '100%' }}>
              <div className="px-24" style={{ textAlign: 'center' }}>
                <div className="smallcaps" style={{ color: 'var(--accent)' }}>REWARD UNLOCKED</div>
                <h1 className="ff-display" style={{
                  fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.01em',
                  margin: '8px 0 0', color: 'var(--ink)',
                }}>
                  New collectible card
                </h1>
              </div>

              <div className="px-24" style={{ paddingTop: 22, display: 'flex', justifyContent: 'center', position: 'relative' }}>
                {half && <RewardCard reward={reward}/>}
              </div>

              <div style={{ flex: 1, minHeight: 24 }}/>

              <div className="px-24" style={{ position: 'sticky', bottom: 0, paddingTop: 16, paddingBottom: 24, background: 'linear-gradient(to top, var(--bg) 74%, transparent)' }}>
                <button className="btn btn-primary" onClick={onContinue}>
                  {hasNext ? 'Begin next module' : 'Back to Path'}
                </button>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}

// ───────────────────────────────────────────────────────────
// Module Reward Card — celebratory unlock screen for the
// collectible card you earn by finishing a module.
// ───────────────────────────────────────────────────────────
function ModuleRewardCardScreen({ module, reward, onContinue, onBack, hasNext }) {
  const [phase, setPhase] = useStateR('roasty');
  if (phase === 'roasty') {
    return <RoastyMoment state="card" eyebrow="REWARD UNLOCKED" title="You earned a card."
                         onDone={() => setPhase('content')}/>;
  }
  return (
    <div className="screen" data-screen-label="Module Reward"
         style={{ background: 'var(--bg)', position: 'relative' }}>
      <div aria-hidden="true" style={{
        position: 'absolute', inset: 0, pointerEvents: 'none',
        background: 'radial-gradient(ellipse at 50% 30%, color-mix(in oklab, var(--accent) 18%, transparent) 0%, transparent 55%)',
      }}/>

      <div className="lesson-topbar" style={{ borderBottom: 'none', background: 'transparent' }}>
        <button className="close-btn" onClick={onBack} aria-label="Back">
          <window.CloseMark/>
        </button>
        <div/><div/>
      </div>

      <div className="scroll" style={{ paddingTop: 96, paddingBottom: 0, display: 'flex', flexDirection: 'column', position: 'relative', height: '100%' }}>
        <div className="px-24" style={{ textAlign: 'center' }}>
          <div className="smallcaps" style={{ color: 'var(--accent)' }}>REWARD UNLOCKED</div>
          <h1 className="ff-display" style={{
            fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.01em',
            margin: '8px 0 0', color: 'var(--ink)',
          }}>
            New collectible card
          </h1>
        </div>

        <div className="px-24" style={{ paddingTop: 24, display: 'flex', justifyContent: 'center', position: 'relative' }}>
          <RewardCard reward={reward}/>
        </div>

        <div style={{ flex: 1, minHeight: 24 }}/>

        <div className="px-24" style={{ position: 'sticky', bottom: 0, paddingTop: 16, paddingBottom: 24, background: 'linear-gradient(to top, var(--bg) 74%, transparent)' }}>
          <button className="btn btn-primary" onClick={onContinue}>
            {hasNext ? 'Begin next module' : 'Back to Path'}
          </button>
        </div>
      </div>
    </div>
  );
}

// The card is the module reward, not a receipt. It carries the guide itself —
// badge, title, summary, spec rows, memorable fact — and deliberately no points
// total: points are paid per lesson and reported by the completion chip.
function RewardCard({ reward}) {
  const [shown, setShown] = useStateR(false);
  const rows = (reward && reward.meta) || [];
  useEffectR(() => {
    const t = setTimeout(() => setShown(true), 50);
    return () => clearTimeout(t);
  }, []);
  return (
    <div className={'reward-card ' + (shown ? 'in' : '')} style={{
      width: '100%', maxWidth: 320, position: 'relative',
      padding: '32px 24px 24px',
      background: 'var(--surface)',
      border: '1px solid color-mix(in oklab, var(--accent) 22%, var(--rule))',
      borderRadius: 2,
      boxShadow: '0 18px 40px rgba(0,0,0,0.35), 0 0 0 1px color-mix(in oklab, var(--accent) 10%, transparent)',
      opacity: 0,
      transform: 'translateY(16px) scale(0.94) rotate(-2deg)',
      transition: 'opacity 480ms ease-out, transform 600ms cubic-bezier(0.2, 1.2, 0.4, 1.0)',
    }}>
      <style>{`
        @keyframes rewardRing {
          0%   { box-shadow: 0 0 0 0 color-mix(in oklab, var(--accent) 55%, transparent); }
          100% { box-shadow: 0 0 0 80px transparent; }
        }
        .reward-card.in { opacity: 1 !important; transform: translateY(0) scale(1) rotate(0) !important; }
        .rc-ring { animation: rewardRing 900ms ease-out 250ms both; }
      `}</style>

      <div className="rc-ring" style={{
        position: 'absolute', inset: 0, borderRadius: 2, pointerEvents: 'none',
      }}/>

      {/* The stamp is absolutely positioned in the top-right corner, so the
          badge and title reserve its gutter with padding rather than a fixed
          maxWidth — a hard cap let long titles ("Field Guide · Processing")
          run under the stamp's ring. 14px inset + 68px stamp + 10px breathing. */}
      <div style={{ paddingRight: 92 }}>
        <div className="smallcaps" style={{ marginBottom: 8 }}>{reward.badge || 'COFFEE CARD'}</div>
        <h2 className="ff-display" style={{
          fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em',
          margin: 0, color: 'var(--ink)', textWrap: 'pretty',
        }}>{reward.title}</h2>
      </div>

      <div style={{ position: 'absolute', top: 14, right: 14 }}>
        <FlavorStamp size={68} rotate={-12}/>
      </div>

      <p style={{
        fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)',
        margin: '20px 0 0', textWrap: 'pretty',
      }}>{reward.summary}</p>

      <div style={{ marginTop: 20 }}>
        {rows.map(([k, v], i) => (
          <FormRow key={i} label={k} value={v}/>
        ))}
      </div>

      <hr className="rule" style={{ marginTop: 16 }}/>
      <div style={{ paddingTop: 14 }}>
        <div className="smallcaps" style={{ marginBottom: 6 }}>MEMORABLE</div>
        <p className="ff-display" style={{
          fontSize: 'var(--t-heading)', lineHeight: 1.4, fontWeight: 400,
          margin: 0, color: 'var(--ink)', textWrap: 'pretty',
        }}>{reward.fact}</p>
      </div>
    </div>
  );
}

// ───────────────────────────────────────────────────────────
// Course Complete — the single biggest moment in the app, shown ONCE: after
// the final lesson's reward chain, before landing back on Learn. Deliberately
// NOT ModuleComplete with new copy (that reuse was ruled out): it reads as
// RoastyMoment's bigger sibling, with two deliberate differences — it never
// auto-dismisses (stays until the CTA), and it carries content no other beat
// has: Roasty's spoken line, the course ledger, the Keep Sharp hand-off.
// It GRANTS nothing — no points, no growth, no 38th card. The celebration is
// the content. Reduced motion: entrances settle instantly (the passport-stamp
// treatment). Content centers when it fits, scrolls when it doesn't.
function CourseCompleteScreen({ lessons = 32, cards = 37, streak = 0, onStart }) {
  const rows = [
    ['Lessons completed', String(lessons)],
    ['Cards collected', String(cards)],
    ['Day streak', String(streak)],
  ];
  return (
    <div className="screen cc-moment" data-screen-label="Course Complete" style={{ background: 'var(--bg)' }}>
      <style>{`
        @keyframes ccIn { from { opacity: 0; transform: translateY(12px); } to { opacity: 1; transform: none; } }
        .cc-1 { animation: ccIn 520ms cubic-bezier(.2,.9,.3,1) both; }
        .cc-2 { animation: ccIn 520ms cubic-bezier(.2,.9,.3,1) 180ms both; }
        .cc-3 { animation: ccIn 520ms cubic-bezier(.2,.9,.3,1) 360ms both; }
        @media (prefers-reduced-motion: reduce) { .cc-moment, .cc-moment * { animation: none !important; transition: none !important; } }
      `}</style>
      <div className="scroll" style={{ display: 'flex', flexDirection: 'column' }}>
        {/* margin:auto centering is overflow-safe: small screens / large text scroll instead of clipping */}
        <div style={{ margin: 'auto 0', padding: '20px 0 8px' }}>
          <div className="cc-1" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 14 }}>
            <div style={{ position: 'relative', background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 12, padding: '13px 16px', color: 'var(--ink)', fontSize: 'var(--t-body)', lineHeight: 1.45, maxWidth: 260, textAlign: 'center', textWrap: 'pretty' }}>
              Beans to brew — you did the whole thing.
              <span aria-hidden="true" style={{ position: 'absolute', width: 11, height: 11, background: 'var(--surface)', borderLeft: '1px solid var(--rule)', borderBottom: '1px solid var(--rule)', bottom: -6, left: '50%', marginLeft: -6, transform: 'rotate(-45deg)' }}/>
            </div>
            <Roasty state="module" size={190}/>
          </div>
          {/* No eyebrow, deliberately: the headline carries the verb, so a
              "COURSE COMPLETE" label above it said the same thing twice.
              Recorded drift from the shipped screen (which shows both). */}
          <div className="px-24 cc-2" style={{ textAlign: 'center', marginTop: 16 }}>
            <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 600, lineHeight: 1.08, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)', textWrap: 'pretty' }}>You finished Foundations</h1>
          </div>
          <div className="px-24 cc-3" style={{ marginTop: 26 }}>
            <div style={{ maxWidth: 320, margin: '0 auto' }}>
              {rows.map(([k, v], i) => (
                <div key={k} style={{ display: 'grid', gridTemplateColumns: '1fr auto', alignItems: 'baseline', gap: 16, padding: '13px 2px', borderBottom: i < rows.length - 1 ? '1px solid var(--rule)' : 'none' }}>
                  <span className="smallcaps">{k}</span>
                  <span className="ff-mono" style={{ fontSize: 'var(--t-lead)', fontWeight: 500, color: 'var(--ink)', fontVariantNumeric: 'tabular-nums', whiteSpace: 'nowrap' }}>{v}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
        <div className="px-24" style={{ position: 'sticky', bottom: 0, flexShrink: 0, paddingTop: 16, paddingBottom: 24, background: 'linear-gradient(to top, var(--bg) 74%, transparent)' }}>
          <button className="btn btn-primary cc-3" onClick={onStart}>Start Keep Sharp</button>
        </div>
      </div>
    </div>
  );
}

window.LessonCompleteScreen = LessonCompleteScreen;
window.ModuleCompleteScreen = ModuleCompleteScreen;
window.ModuleRewardCardScreen = ModuleRewardCardScreen;
window.RewardCard = RewardCard;
window.CourseCompleteScreen = CourseCompleteScreen;
