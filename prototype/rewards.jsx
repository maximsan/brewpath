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

  // Lesson state (mastery). Needs Practice shows no chip here — the accent
  // practice button below carries both the verdict and the action, and the
  // Path row wears the persistent chip. Saying it twice on one screen is noise.
  const weak = lessonState === 'needs-practice';

  const earned = newPoints - prevPoints;
  // The challenge offer joins the reward list only while it is live.
  const offerLive = !!(brewChallenge && window.ChallengeSuggestion && brewChallengeState !== 'completed' && brewChallengeState !== 'active');

  const [phase, setPhase] = useStateR('roasty');
  // Card peek = the same flip grammar as the module screen: the card lives on
  // the back of the screen. Flip on demand here; modules flip as the reward beat.
  const [flipped, setFlipped] = useStateR(false);
  const [half, setHalf] = useStateR(false);   // toggles at the flip midpoint so exactly one face shows
  const flipTo = (v) => { setFlipped(v); setTimeout(() => setHalf(v), 410); };
  const [tbScrolled, onTbScroll] = window.useScrollFlag();
  if (phase === 'roasty') {
    const rtitle = weak ? 'Good start.' : lessonState === 'perfect' ? 'Perfect run!' : lessonState === 'mastered' ? 'Mastered it.' : 'Nice work.';
    return <RoastyMoment state="lesson" eyebrow="LESSON COMPLETE" title={rtitle}
                         onDone={() => setPhase('content')}/>;
  }

  const faceBase = {
    position: 'absolute', inset: 0,
    backfaceVisibility: 'hidden', WebkitBackfaceVisibility: 'hidden',
    overflow: 'hidden', borderRadius: 'inherit',
  };

  return (
    <div className="screen" data-screen-label="Lesson Complete" style={{ background: 'var(--bg)' }}>
      <div style={{ position: 'absolute', inset: 0, perspective: 1800, perspectiveOrigin: '50% 42%' }}>
        <div style={{
          position: 'absolute', inset: 0, transformStyle: 'preserve-3d',
          transition: 'transform 820ms cubic-bezier(.62,.04,.2,1)',
          transform: flipped ? 'rotateY(180deg)' : 'none',
        }}>

      {/* ───── FRONT · report ───── */}
      <div style={{ ...faceBase, visibility: half ? 'hidden' : 'visible' }}>
      <RewardTopbar scrolled={tbScrolled} onBack={onBack}/>

      <div className="scroll" onScroll={onTbScroll} style={{ paddingTop: 90, paddingBottom: 0, display: 'flex', flexDirection: 'column', height: '100%' }}>
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center' }}>
          <div className="px-24" style={{ textAlign: 'center' }}>
            <div className="smallcaps">LESSON COMPLETE</div>
            <h1 className="ff-display" style={{
              fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.01em',
              margin: '10px 0 0', color: 'var(--ink)',
            }}>
              {lesson.title}
            </h1>
            {result && (
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', marginTop: 14 }}>
                <span className="ff-mono" style={{ fontSize: 'var(--t-body)', letterSpacing: '0.04em', color: 'var(--ink)', fontVariantNumeric: 'tabular-nums', whiteSpace: 'nowrap' }}>
                  {result.correct} / {result.total} correct
                </span>
              </div>
            )}
          </div>

          <div style={{ display: 'flex', justifyContent: 'center', padding: '36px 0 0', position: 'relative' }}>
            <AnimatedTree fromStage={prevStage} toStage={newStage} size={240}/>
          </div>
          {/* Points land under the tree — what you earned feeds what grows.
              Their own beat, not a fragment sharing the score's line. */}
          {earned > 0 && (
            <div className="ff-mono" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, marginTop: 14, fontSize: 'var(--t-support)', fontWeight: 500, letterSpacing: '0.06em', textTransform: 'uppercase', color: 'var(--ink)', fontVariantNumeric: 'tabular-nums' }}>
              <PointsBean size={18}/> +{earned} PTS
            </div>
          )}
          {/* Most completions do not cross a stage threshold. Say how far the next
              one is, so a still tree reads as progress rather than nothing. */}
          {newStage === prevStage && toNextStage > 0 && (
            <div className="ff-mono" style={{
              textAlign: 'center', marginTop: 8, fontSize: 'var(--t-label)', letterSpacing: '0.12em',
              textTransform: 'uppercase', color: 'color-mix(in oklab, var(--ink-mute) 76%, var(--ink))',
            }}>{toNextStage} {toNextStage === 1 ? 'lesson' : 'lessons'} to the next stage</div>
          )}
          {/* Occasional beats — one list, one row anatomy (label + muted
              detail, one trailing icon at most), hairlines between. */}
          {(freezeEarned || (lesson.reward && lesson.reward.title) || offerLive) && (
            <div className="px-24" style={{ width: '100%', marginTop: 26 }}>
              <div>
                {freezeEarned && (
                  <div className="rw-li">
                    <RewardRow label="Freeze earned" detail="One missed day is covered."/>
                  </div>
                )}
                {lesson.reward && lesson.reward.title && (
                  <div className="rw-li">
                    <RewardRow label="New card" detail={lesson.reward.title} onPress={() => flipTo(true)}/>
                  </div>
                )}
                {offerLive && (
                  <div className="rw-li">
                    <window.ChallengeSuggestion challenge={brewChallenge} realState={brewChallengeState} onStart={onStartChallenge}/>
                  </div>
                )}
              </div>
            </div>
          )}
        </div>

        <RewardExitFooter label={nextPlayable ? 'Next lesson' : 'Back to Path'} onContinue={onContinue}
          ghostRow={onDuel ? (
            <div style={{ marginTop: 10 }}>
              <a className="btn btn-link" href="#" style={{ display: 'block', textAlign: 'center', textDecoration: 'none' }} onClick={(e) => { e.preventDefault(); onDuel(); }}>
                Duel a friend
              </a>
            </div>
          ) : null}
          alwaysRow={weak && onPractice ? (
            <div style={{ marginTop: 10 }}>
              <a className="btn btn-ghost" href="#" onClick={(e) => { e.preventDefault(); onPractice(); }}
                 style={{ display: 'block', textAlign: 'center', textDecoration: 'none', color: 'var(--accent)', borderColor: 'color-mix(in oklab, var(--accent) 45%, var(--rule))' }}>
                Practice this lesson again
              </a>
            </div>
          ) : null}/>
      </div>
      </div>

      {/* ───── BACK · the card ───── */}
      {lesson.reward && (
        <div style={{ ...faceBase, visibility: half ? 'visible' : 'hidden', transform: 'rotateY(180deg)' }}>
          <div aria-hidden="true" style={{
            position: 'absolute', inset: 0, pointerEvents: 'none',
            background: 'radial-gradient(ellipse at 50% 30%, color-mix(in oklab, var(--accent) 18%, transparent) 0%, transparent 55%)',
          }}/>
          <RewardTopbar scrolled={false} onBack={() => flipTo(false)} back label="Flip back"/>
          <div className="scroll" style={{ paddingTop: 90, paddingBottom: 32, display: 'flex', flexDirection: 'column', height: '100%' }}>
            <div className="px-24" style={{ display: 'flex', justifyContent: 'center', flex: 1, alignItems: 'center' }}>
              {half && <RewardCard reward={lesson.reward}/>}
            </div>
          </div>
        </div>
      )}

        </div>
      </div>
    </div>
  );
}

// ───────────────────────────────────────────────────────────
// Module Complete — tree growth with a stronger emotional beat.
// Continue → module reward card.
// ───────────────────────────────────────────────────────────
function ModuleCompleteScreen({ module, fromStage, toStage, prevPoints, newPoints, onContinue, onBack, reward, hasNext, freezeEarned = false, brewChallenge, brewChallengeState, onStartChallenge, startFlipped = false }) {
  // Tree stages come from CORE-LESSON progress only (single source of truth).
  const prevStage = fromStage != null ? fromStage : 1;
  const newStage  = toStage   != null ? toStage   : 1;
  const earned = newPoints - prevPoints;

  const [phase, setPhase] = useStateR(startFlipped ? 'content' : 'roasty');
  const [flipped, setFlipped] = useStateR(startFlipped);
  const [half, setHalf] = useStateR(startFlipped);   // toggles at the flip midpoint so exactly one face shows
  const flipTo = (v) => {
    setFlipped(v);
    setTimeout(() => setHalf(v), 410);
  };
  const [frontScrolled, onFrontScroll] = window.useScrollFlag();
  const [backScrolled, onBackScroll] = window.useScrollFlag();
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
            <RewardTopbar scrolled={frontScrolled} onBack={onBack} label="Close"/>

            <div className="scroll" onScroll={onFrontScroll} style={{ paddingTop: 84, paddingBottom: 32, display: 'flex', flexDirection: 'column', position: 'relative', height: '100%' }}>
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

                <div className="px-24" style={{ textAlign: 'center', marginTop: 14 }}>
                  {/* Same borderless points line as Lesson Complete — no pill. */}
                  <div className="ff-mono" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, fontSize: 'var(--t-support)', fontWeight: 500, letterSpacing: '0.06em', textTransform: 'uppercase', color: 'var(--ink)', fontVariantNumeric: 'tabular-nums' }}>
                    <PointsBean size={18}/> +{earned} PTS
                  </div>
                  {/* Freeze earned on the module-closing lesson — Lesson Complete is
                      skipped on this path, so the earn beat must land here or nowhere. */}
                  {freezeEarned && (
                    <div style={{ marginTop: 12, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8 }}>
                      {window.FreezeMark ? <window.FreezeMark size={14}/> : null}
                      <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.16em', textTransform: 'uppercase', color: 'var(--accent)' }}>FREEZE EARNED · ONE MISSED DAY COVERED</span>
                    </div>
                  )}
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
            <RewardTopbar scrolled={backScrolled} onBack={() => flipTo(false)} back label="Flip back"/>

            <div className="scroll" onScroll={onBackScroll} style={{ paddingTop: 90, paddingBottom: 32, display: 'flex', flexDirection: 'column', position: 'relative', height: '100%' }}>
              <div className="px-24" style={{ paddingTop: 34, display: 'flex', justifyContent: 'center', position: 'relative' }}>
                {half && <RewardCard reward={reward}/>}
              </div>

              <div style={{ flex: 1, minHeight: 24 }}/>

              <RewardExitFooter label={hasNext ? 'Begin next module' : 'Back to Path'} onContinue={onContinue}
                offer={brewChallenge && window.ChallengeSuggestion && brewChallengeState !== 'completed' && brewChallengeState !== 'active'
                  ? <window.ChallengeSuggestion challenge={brewChallenge} realState={brewChallengeState} onStart={onStartChallenge}/>
                  : null}/>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}

// Reward screens use the shared FloatTopbar (settings.jsx) — transparent at
// rest, standard header chrome on scroll.
const RewardTopbar = (props) => <window.FloatTopbar {...props}/>;

// ── Reward list row — the one anatomy for every occasional beat on a reward
// screen: label + muted detail, at most one trailing affordance. The challenge
// offer row (ChallengeSuggestion) follows the same anatomy.
function RewardRow({ label, detail, onPress }) {
  const inner = (
    <>
      <div style={{ minWidth: 0, flex: 1, textAlign: 'left' }}>
        <div style={{ fontSize: 'var(--t-support)', fontWeight: 500, color: 'var(--ink)' }}>{label}</div>
        {detail && <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{detail}</div>}
      </div>
      {/* Same go-button anatomy as the challenge row — one affordance style
          for every actionable reward row. Span, not button: the row itself
          is the button. */}
      {onPress && (
        <span aria-hidden="true" style={{ width: 38, height: 38, borderRadius: 999, flexShrink: 0, display: 'grid', placeItems: 'center', background: 'var(--accent)', color: 'var(--accent-ink)' }}>
          <svg width="16" height="16" viewBox="0 0 20 20"><path d="M4 10h11M11 5.5 16.5 10 11 14.5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>
        </span>
      )}
    </>
  );
  const base = { display: 'flex', alignItems: 'center', gap: 12, padding: onPress ? '10px 0' : '12px 0', width: '100%' };
  return onPress
    ? <button onClick={onPress} style={{ ...base, appearance: 'none', cursor: 'pointer', background: 'transparent', border: 0, font: 'inherit', color: 'inherit' }}>{inner}</button>
    : <div style={base}>{inner}</div>;
}

// ───────────────────────────────────────────────────────────
// Shared sticky footer for ALL reward screens: the exit CTA over the standard
// gradient, with optional quiet rows. The challenge offer lives in the screen's
// reward LIST (or, on the module card back, in `offer` above the CTA) — the
// footer itself owns nothing but exits.
function RewardExitFooter({ label, onContinue, offer = null, ghostRow = null, alwaysRow = null }) {
  return (
    <>
      {/* The offer lives in the scroll flow — it moves with the content.
          Only the exit CTA floats: declining IS the CTA. */}
      {offer && (
        <div className="px-24" style={{ marginTop: 'auto', paddingTop: 8 }}>{offer}</div>
      )}
      <div className="px-24" style={{ position: 'sticky', bottom: 0, marginTop: offer ? undefined : 'auto', paddingTop: 16, paddingBottom: 24, background: 'linear-gradient(to top, var(--bg) 74%, transparent)' }}>
        <button className="btn btn-primary" onClick={onContinue}>{label}</button>
        {!offer && ghostRow}
        {alwaysRow}
      </div>
    </>
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
window.RewardCard = RewardCard;
window.CourseCompleteScreen = CourseCompleteScreen;
