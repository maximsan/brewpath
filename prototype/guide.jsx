// guide.jsx — lightweight onboarding: the first-run Today tour, event-driven
// micro-tips (coach cards), and the Settings → Help → App Guide reference.
// The whole layer sits behind the `guide` tweak; app.jsx owns state + triggers.

// ── Today tour ──────────────────────────────────────────────
// Four steps over the primary flow only. Targets are [data-guide] anchors in
// screens.jsx plus the tab bar. No tab navigation — everything highlighted is
// on (or framing) the Today screen.
const TOUR_STEPS = [
  { target: '[data-guide="today-lesson"]', title: 'Today starts here', body: 'Your next lesson always waits in this card. One short lesson a day is the whole habit.' },
  { target: '[data-guide="today-practice"]', title: 'Practice again, any time', body: 'Lessons you finish collect here, with quick practice formats beside them. Replays sharpen you but never change your points.' },
  { target: '[data-guide="today-header"]', title: 'Saved and Dictionary', scrollTop: true, body: 'Anything you bookmark lands behind the ribbon; every coffee term you meet joins the book beside it.' },
  { target: '.tabbar', title: 'Find your way', scrollTop: true, body: 'Path holds the whole course, Collection your earned cards, Profile your streak and coffee tree.' },
];

function TodayTour({ onFinish }) {
  const [i, setI] = React.useState(0);
  const [rect, setRect] = React.useState(null);
  const step = TOUR_STEPS[i];
  const measure = React.useCallback(() => {
    const area = document.getElementById('screenArea');
    const el = document.querySelector(TOUR_STEPS[i].target);
    if (!area || !el) { setRect(null); return; }
    const a = area.getBoundingClientRect();
    const scale = (a.width / area.offsetWidth) || 1;
    const r = el.getBoundingClientRect();
    setRect({ x: (r.left - a.left) / scale, y: (r.top - a.top) / scale, w: r.width / scale, h: r.height / scale, areaH: area.offsetHeight });
  }, [i]);
  // Bring the step's target into view (plain scrollTop math — no scrollIntoView),
  // then measure. Steps that frame fixed chrome ask for the top of the feed.
  React.useEffect(() => {
    const area = document.getElementById('screenArea');
    const el = document.querySelector(TOUR_STEPS[i].target);
    const scroller = document.querySelector('#screenArea .screen .scroll');
    if (scroller && TOUR_STEPS[i].scrollTop) scroller.scrollTop = 0;
    else if (area && el && scroller && scroller.contains(el)) {
      const scale = (area.getBoundingClientRect().width / area.offsetWidth) || 1;
      const sr = scroller.getBoundingClientRect(), er = el.getBoundingClientRect();
      const topGap = (er.top - sr.top) / scale;               // px below the scroller's top edge
      const botOver = (er.bottom - sr.bottom) / scale + 250;  // keep ~250px clear for the tip card
      let delta = 0;
      if (topGap < 140) delta = topGap - 140;
      else if (botOver > 0) delta = Math.min(botOver, topGap - 140);
      if (delta) scroller.scrollTop += delta;
    }
    const t1 = setTimeout(measure, 30);
    const t2 = setTimeout(measure, 260);
    window.addEventListener('resize', measure);
    return () => { clearTimeout(t1); clearTimeout(t2); window.removeEventListener('resize', measure); };
  }, [i, measure]);
  const last = i === TOUR_STEPS.length - 1;
  const below = rect ? (rect.y + rect.h) < (rect.areaH - 330) : true;
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 92 }} role="dialog" aria-label="Introduction to Today">
      {/* click shield — the page underneath is frozen while the tour runs */}
      <div style={{ position: 'absolute', inset: 0 }}/>
      {rect && (
        <div style={{
          position: 'absolute', left: rect.x - 6, top: rect.y - 6, width: rect.w + 12, height: rect.h + 12,
          borderRadius: 18, pointerEvents: 'none', boxShadow: '0 0 0 1400px var(--dim-modal)',
          border: '1px solid color-mix(in oklab, var(--accent) 55%, transparent)',
          transition: 'left 320ms cubic-bezier(.3,.8,.3,1), top 320ms cubic-bezier(.3,.8,.3,1), width 320ms cubic-bezier(.3,.8,.3,1), height 320ms cubic-bezier(.3,.8,.3,1)',
        }}/>
      )}
      <div key={i} className="fade-up" style={{
        position: 'absolute', left: 20, right: 20,
        ...(rect ? (below ? { top: rect.y + rect.h + 20 } : { bottom: rect.areaH - rect.y + 20 }) : { bottom: 140 }),
        background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 16,
        padding: '18px 18px 14px', boxShadow: '0 18px 44px rgba(0,0,0,0.24)',
      }}>
        <div className="smallcaps-mono">{(i + 1) + ' of ' + TOUR_STEPS.length}</div>
        <div className="ff-display" style={{ fontSize: 'var(--t-heading)', letterSpacing: '-0.01em', color: 'var(--ink)', marginTop: 7, lineHeight: 1.15 }}>{step.title}</div>
        <p style={{ margin: '7px 0 0', fontSize: 'var(--t-support)', lineHeight: 1.55, color: 'var(--ink-mute)', textWrap: 'pretty' }}>{step.body}</p>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12, marginTop: 12 }}>
          <button className="btn" onClick={onFinish} aria-label="Skip the introduction" style={{ background: 'transparent', color: 'var(--ink-mute)', padding: '12px 6px', fontSize: 'var(--t-support)' }}>Skip</button>
          <div style={{ display: 'flex', gap: 5 }} aria-hidden="true">
            {TOUR_STEPS.map((_, d) => (
              <span key={d} style={{ width: 5, height: 5, borderRadius: 999, background: d === i ? 'var(--accent)' : 'var(--rule)' }}></span>
            ))}
          </div>
          <button className="btn" onClick={() => last ? onFinish() : setI(i + 1)} style={{ background: 'var(--accent)', color: 'var(--accent-ink)', borderRadius: 999, padding: '11px 20px', fontSize: 'var(--t-support)' }}>{last ? 'Done' : 'Next'}</button>
        </div>
      </div>
    </div>
  );
}

// ── Event-driven micro-tips ─────────────────────────────────
// One small coach card per secondary feature, shown the first time it becomes
// relevant. app.jsx decides WHEN (the trigger conditions); this is the WHAT.
const GUIDE_TIPS = {
  path:       { eyebrow: 'YOUR PATH',        title: 'The whole course, in order', body: 'Each finished lesson unlocks the next, top to bottom. The diamonds branching off the line are hands-on Coffee Challenges.' },
  brew:       { eyebrow: 'COFFEE CHALLENGE', title: 'A real brew, not a quiz', body: 'Make it at your own pace within 48 hours, then log the result here on Today. Logging it earns the challenge\u2019s stamp.' },
  tree:       { eyebrow: 'COFFEE TREE',      title: 'Your tree just grew', body: 'Completing that lesson pushed it toward harvest. Only core lessons grow it \u2014 see it any time from your Profile.' },
  saved:      { eyebrow: 'SAVED',            title: 'Kept for later', body: 'Everything you save waits behind the ribbon at the top of Today \u2014 lessons, terms and guides on one shelf.' },
  dictionary: { eyebrow: 'DICTIONARY',       title: 'Every term you\u2019ve met', body: 'Terms join your Dictionary as lessons introduce them. Search them here, or drill them with flashcards.' },
  freeze:     { eyebrow: 'STREAK FREEZE',    title: 'A safety net you\u2019ve earned', body: 'Every 7 streak days in a row earns a freeze; you hold one at a time. Miss a day and it\u2019s spent for you \u2014 your streak survives.' },
  studio:     { eyebrow: 'STUDIO',           title: 'Make it yours', body: 'Dress Roasty and choose your tree\u2019s variety and light. The look you set here applies everywhere in the app.' },
};

// Shows at most one tip at a time, each id once ever. "Never consecutive"
// means never back to back on the SAME surface (full gap after a dismissal);
// navigating to a new surface is a natural boundary — its tip shows after a
// short beat, not after the full cooldown.
const GUIDE_TIP_GAP_MS = 12000;
function useGuideTip({ enabled, candidateId, seen, markSeen, contextKey }) {
  const [active, setActive] = React.useState(null);
  const holdUntil = React.useRef(0);
  const [, force] = React.useState(0);
  const ctxRef = React.useRef(contextKey);
  React.useEffect(() => {
    if (ctxRef.current !== contextKey) {
      ctxRef.current = contextKey;
      // Retire a visible tip (it was seen); hold longer if one was just showing
      // so two never read as a chain across the transition.
      holdUntil.current = Date.now() + (active ? 6000 : 1600);
      if (active) setActive(null);
    }
  }, [contextKey, active]);
  React.useEffect(() => {
    if (!enabled) { if (active) setActive(null); return; }
    if (active || !candidateId || seen.indexOf(candidateId) >= 0) return;
    const wait = holdUntil.current - Date.now();
    if (wait > 0) { const t = setTimeout(() => force(n => n + 1), wait + 60); return () => clearTimeout(t); }
    setActive(candidateId);
    markSeen(candidateId);
  });
  const dismiss = React.useCallback(() => { holdUntil.current = Date.now() + GUIDE_TIP_GAP_MS; setActive(null); }, []);
  // Lets the tour count as "something was just shown", so no tip chains off it.
  const pause = React.useCallback(() => { holdUntil.current = Date.now() + GUIDE_TIP_GAP_MS; }, []);
  return [active, dismiss, pause];
}

function GuideTipCard({ tipId, raised, onDismiss }) {
  const tip = GUIDE_TIPS[tipId];
  if (!tip) return null;
  return (
    <div className="fade-up" role="status" style={{
      position: 'absolute', left: 16, right: 16, bottom: raised ? 112 : 40, zIndex: 88,
      background: 'var(--surface)', border: '1px solid color-mix(in oklab, var(--accent) 30%, var(--rule))',
      borderRadius: 14, padding: '14px 16px', boxShadow: '0 14px 34px rgba(0,0,0,0.2)',
      display: 'flex', gap: 12, alignItems: 'flex-start',
    }}>
      <span style={{ minWidth: 0, flex: 1 }}>
        <span className="smallcaps" style={{ color: 'var(--accent-text)' }}>{tip.eyebrow}</span>
        <span style={{ display: 'block', fontSize: 'var(--t-support)', fontWeight: 500, color: 'var(--ink)', marginTop: 5 }}>{tip.title}</span>
        <span style={{ display: 'block', fontSize: 'var(--t-label)', lineHeight: 1.5, color: 'var(--ink-mute)', marginTop: 3, textWrap: 'pretty' }}>{tip.body}</span>
      </span>
      <button onClick={onDismiss} aria-label="Dismiss" style={{ appearance: 'none', background: 'transparent', border: 0, padding: 6, margin: -6, cursor: 'pointer', color: 'var(--ink-mute)', flexShrink: 0 }}>
        {window.CloseMark ? <window.CloseMark size={15}/> : <span className="ff-mono" aria-hidden="true">{'\u00d7'}</span>}
      </button>
    </div>
  );
}

// ── App Guide (Settings → Help) ─────────────────────────────
const APP_GUIDE_SECTIONS = [
  { title: 'Today', body: 'Your daily start: the next lesson, any active Coffee Challenge, and practice worth revisiting.' },
  { title: 'Learning Path', body: 'The whole course in order. Each finished lesson unlocks the next; diamonds along the line are Coffee Challenges.' },
  { title: 'Practice', body: 'Replay finished lessons or drill the practice formats from Today. Reviews sharpen you but never change your points.' },
  { title: 'Brew Challenges', body: 'Real-world brewing tasks. Start one, make it within 48 hours, then log the result on Today to earn its stamp.' },
  { title: 'Dictionary & Saved', body: 'Terms join the Dictionary as lessons introduce them. Anything you bookmark waits in Saved, at the top of Today.' },
  { title: 'Coffee Tree', body: 'Grows a stage as you complete core lessons, from seed to harvest. Only lessons grow it \u2014 it lives on your Profile.' },
  { title: 'Streak', body: 'One lesson a day keeps it alive. Every 7 days in a row earns a streak freeze (you hold one at a time); it covers a missed day automatically.' },
];

function AppGuideScreen({ onClose, onReplay }) {
  const [scrolled, onScroll] = window.useScrollFlag();
  const Header = window.SubScreenHeader;
  const NavRowC = window.NavRow;
  return (
    <div className="screen" data-screen-label="App Guide" style={{ background: 'var(--bg)' }}>
      <Header scrolled={scrolled} title="App Guide" onBack={onClose}/>
      <div className="scroll" onScroll={onScroll} style={{ paddingTop: 108, paddingBottom: 40 }}>
        <div className="px-24">
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>App Guide</h1>
          <p style={{ margin: '10px 0 0', fontSize: 'var(--t-support)', lineHeight: 1.55, color: 'var(--ink-mute)', textWrap: 'pretty' }}>What each part of BrewPath does, in a line or two.</p>
        </div>
        <div className="px-24" style={{ paddingTop: 14 }}>
          {APP_GUIDE_SECTIONS.map((s, idx) => (
            <div key={s.title} style={{ padding: '15px 0', borderBottom: idx < APP_GUIDE_SECTIONS.length - 1 ? '1px solid var(--rule)' : 'none' }}>
              <div style={{ fontSize: 'var(--t-body)', fontWeight: 500, color: 'var(--ink)' }}>{s.title}</div>
              <p style={{ margin: '5px 0 0', fontSize: 'var(--t-support)', lineHeight: 1.55, color: 'var(--ink-mute)', textWrap: 'pretty' }}>{s.body}</p>
            </div>
          ))}
        </div>
        <div className="px-24" style={{ paddingTop: 26 }}>
          <div className="smallcaps" style={{ marginBottom: 4 }}>INTRODUCTION</div>
          <NavRowC label="Replay Today introduction" sub="Runs the short first-open tour again" onClick={onReplay}/>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { TodayTour, GuideTipCard, AppGuideScreen, useGuideTip, GUIDE_TIPS });
