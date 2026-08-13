// screens.jsx — non-lesson screens

const { useState, useEffect, useRef } = React;

// ───────────────────────────────────────────────────────────
// ONBOARDING
// ───────────────────────────────────────────────────────────

// Screen 01 — Welcome / concept. Introduces the app and the living coffee
// tree (the engagement metaphor). No Roasty here. Tapping anywhere advances.
function OnboardingWelcome({ onNext }) {
  const videoRef = useRef(null);
  const [muted, setMuted] = useState(true);
  // React doesn't reliably set the `muted` DOM property from the JSX attribute,
  // so the video can autoplay with sound. Enforce it on mount.
  useEffect(() => { if (videoRef.current) videoRef.current.muted = true; }, []);
  const toggleSound = (e) => {
    e.stopPropagation();
    const v = videoRef.current;
    if (!v) return;
    const next = !muted;
    v.muted = next;
    if (!next) { v.play().catch(() => {}); }
    setMuted(next);
  };
  // Silence the video before advancing so unmuted audio never bleeds into the next screen.
  const advance = () => {
    const v = videoRef.current;
    if (v) { v.muted = true; v.pause(); }
    onNext();
  };
  return (
    <div className="screen" data-screen-label="01 Welcome"
         onClick={advance}
         style={{ cursor: 'pointer' }}>
      <div className="scroll" style={{ display: 'flex', flexDirection: 'column', paddingTop: 64, paddingBottom: 40 }}>
        <div className="px-24" style={{ paddingTop: 8, marginTop: 'auto' }}>
          <div style={{
            width: '100%', aspectRatio: '4/3', background: 'var(--surface)',
            border: '1px solid var(--rule)', borderRadius: 'var(--r)', overflow: 'hidden',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            position: 'relative',
          }}>
            <video ref={videoRef} src="uploads/Flowerpot_seed_to.mp4"
                   autoPlay muted loop playsInline
                   style={{ width: '100%', height: '100%', objectFit: 'cover' }}/>
            <button onClick={toggleSound}
                    aria-label={muted ? 'Turn sound on' : 'Turn sound off'}
                    style={{
                      position: 'absolute', bottom: 12, right: 12,
                      width: 44, height: 44, borderRadius: 999, border: 'none',
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      background: 'var(--scrim)',
                      backdropFilter: 'blur(8px)', WebkitBackdropFilter: 'blur(8px)',
                      color: 'var(--scrim-ink)', cursor: 'pointer',
                    }}>
              {muted ? (
                <svg width="19" height="19" viewBox="0 0 24 24" fill="none">
                  <path d="M4 9v6h4l5 4V5L8 9H4z" fill="currentColor"/>
                  <path d="M16 9l5 6M21 9l-5 6" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                </svg>
              ) : (
                <svg width="19" height="19" viewBox="0 0 24 24" fill="none">
                  <path d="M4 9v6h4l5 4V5L8 9H4z" fill="currentColor"/>
                  <path d="M16.5 8.5a5 5 0 010 7M19 6a8.5 8.5 0 010 12" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                </svg>
              )}
            </button>
          </div>
        </div>

        <div className="px-24" style={{ paddingBottom: 16, paddingTop: 28, flex: 1, display: 'flex', flexDirection: 'column', maxHeight: 340 }}>
          <div className="smallcaps" style={{ marginBottom: 14, color: 'var(--accent)' }}>BREWPATH</div>
          <h1 className="ff-display" style={{
            fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em',
            margin: 0, color: 'var(--ink)', textWrap: 'pretty',
          }}>
            Learn coffee.<br/>Grow a tree.
          </h1>
          <p style={{
            fontSize: 'var(--t-body)', lineHeight: 1.5, color: 'var(--ink-mute)',
            marginTop: 16, marginBottom: 0, fontWeight: 400, maxWidth: 330,
          }}>
            Short, hands-on lessons in the craft of coffee. Every one you finish feeds a living tree, growing from seed to harvest.
          </p>

          <div className="tap-cue" style={{ marginTop: 'auto', paddingTop: 32 }}>
            TAP ANYWHERE TO CONTINUE
          </div>
        </div>
      </div>
    </div>
  );
}

// Screen 01b — Meet Roasty. The smiling mascot, your talisman for the journey.
// User can begin the onboarding flow or skip straight to lessons.
function OnboardingRoasty({ onStart, onSkip, isV1 }) {
  return (
    <div className="screen" data-screen-label="01b Meet Roasty">
      <div className="scroll" style={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-between', paddingTop: 64, paddingBottom: 40 }}>
        <div className="px-24" style={{ paddingTop: 40, display: 'flex', justifyContent: 'center' }}>
          <Roasty state="correct" size={184}/>
        </div>

        <div className="px-24" style={{ paddingBottom: 16, paddingTop: 24 }}>
          <div className="smallcaps" style={{ marginBottom: 10, color: 'var(--accent)' }}>
            YOUR COMPANION
          </div>
          <h1 className="ff-display" style={{
            fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em',
            margin: 0, color: 'var(--ink)', textWrap: 'pretty',
          }}>
            Meet Roasty.
          </h1>
          <p style={{
            fontSize: 'var(--t-body)', lineHeight: 1.5, color: 'var(--ink-mute)',
            marginTop: 18, marginBottom: 28, fontWeight: 400, maxWidth: 330,
          }}>
            Your talisman for the journey. Roasty cheers your wins, marks every milestone, and keeps you company between cups.
          </p>

          <button className="btn btn-primary" onClick={onStart}>
            {isV1 ? 'Start learning' : 'Set up my path'}
          </button>

          {!isV1 && (
            <div style={{ marginTop: 10 }}>
              <a className="btn btn-ghost" href="#" style={{ display: 'block', textAlign: 'center', textDecoration: 'none' }} onClick={(e) => { e.preventDefault(); onSkip(); }}>
                Skip — take me to lessons
              </a>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

// ── Small coffee glyphs used across streak / profile / tree ──
function SteamMark({ color = 'var(--accent)', w = 26 }) {
  return (
    <svg width={w} height={w * 0.62} viewBox="0 0 26 16" fill="none" aria-hidden="true">
      <path d="M6 15 Q3 10 6 6 Q8 3 6 1"   stroke={color} strokeWidth="1.6" strokeLinecap="round"/>
      <path d="M13 15 Q10 10 13 6 Q15 3 13 1" stroke={color} strokeWidth="1.6" strokeLinecap="round"/>
      <path d="M20 15 Q17 10 20 6 Q22 3 20 1" stroke={color} strokeWidth="1.6" strokeLinecap="round"/>
    </svg>
  );
}

function ProfileBean({ size = 22, color = 'var(--accent)' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={{ flexShrink: 0 }} aria-hidden="true">
      <ellipse cx="12" cy="12" rx="6.2" ry="9" transform="rotate(32 12 12)" stroke={color} strokeWidth="1.6"/>
      <path d="M8.6 5.8 C 12.2 9, 11.8 15, 15.4 18.2" stroke={color} strokeWidth="1.6" strokeLinecap="round"/>
    </svg>
  );
}

function IconGear({ size = 18 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 20 20" fill="none" style={{ color: 'var(--ink)' }} aria-hidden="true">
      <path d="M3 6h7 M16 6h1" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
      <path d="M3 14h2 M11 14h6" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
      <circle cx="12.5" cy="6" r="2.3" fill="var(--bg)" stroke="currentColor" strokeWidth="1.5"/>
      <circle cx="7.5" cy="14" r="2.3" fill="var(--bg)" stroke="currentColor" strokeWidth="1.5"/>
    </svg>
  );
}

// Week strip — 7 day markers for the current week. Shared by the streak screen,
// the profile card and the share card. Prototype is frozen on Friday, so today
// is Friday and the weekend is still ahead. A day in `frozen` was missed and
// covered by an earned streak freeze — a third state, distinct from both a
// completed day and an empty one, so the strip can never claim a day was earned
// when it was only protected.
//
// Filled days are DERIVED from the streak, never hardcoded: the run covers the
// last `streak` days ending today, clipped to the start of the week. Without
// this the strip claimed a full Mon–Fri run no matter what the streak actually
// was — including zero, right after Reset progress.
function WeekStrip({ size = 'lg', frozen, streak = 0 }) {
  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  const todayIdx = 4;
  const runStart = todayIdx - Math.min(Math.max(streak, 0), todayIdx + 1) + 1;
  const froze = frozen instanceof Set ? frozen : new Set(frozen || []);
  const dot = size === 'lg' ? 32 : 24;
  return (
    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: size === 'lg' ? 8 : 4, width: '100%' }}>
      {days.map((d, i) => {
        const iced = froze.has(i);
        const done = i <= todayIdx && i >= runStart && !iced;
        const today = i === todayIdx;
        // Accent means earned. Today keeps a position cue either way, but it stays
        // neutral until the day is actually done — otherwise a reset streak shows
        // one glowing accent ring and reads as a credited day.
        const cue = done ? 'var(--accent)' : 'var(--ink-mute)';
        return (
          <div key={i} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: size === 'lg' ? 9 : 7 }}>
            <div className="ff-mono" style={{
              fontSize: size === 'lg' ? 11 : 9, letterSpacing: '0.1em', textTransform: 'uppercase',
              color: today ? (done ? 'var(--accent)' : 'var(--ink)') : 'var(--ink-mute)',
            }}>{d}</div>
            <div style={{
              width: dot, height: dot, borderRadius: 999,
              background: done ? 'var(--accent)' : 'transparent',
              border: '1.5px solid ' + (done ? 'var(--accent)' : iced ? 'color-mix(in oklab, var(--accent) 55%, var(--rule))' : 'var(--rule)'),
              boxShadow: today ? '0 0 0 3px color-mix(in oklab, ' + cue + ' 22%, transparent)' : 'none',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              {done && (
                <svg width={dot * 0.46} height={dot * 0.46} viewBox="0 0 12 12">
                  <path d="M2 6l3 3 5-6" fill="none" stroke="var(--accent-ink)" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"/>
                </svg>
              )}
              {iced && <FreezeMark size={dot * 0.42}/>}
            </div>
          </div>
        );
      })}
    </div>
  );
}

// The freeze mark — one dash, one meaning: a day held rather than earned. Used
// by the week strip, the lesson-complete rollup and the Learn tab notice.
function FreezeMark({ size = 12, color = 'var(--accent)', sw = 1.9 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" aria-hidden="true">
      <path d="M2.5 6h7" fill="none" stroke={color} strokeWidth={sw} strokeLinecap="round"/>
    </svg>
  );
}
window.FreezeMark = FreezeMark;

// The freezes a user is holding, as pips against the cap — scarcity you can see.
function FreezeTokens({ held = 0, cap = 2, size = 9 }) {
  return (
    <span style={{ display: 'inline-flex', gap: 5, alignItems: 'center' }} aria-label={held + ' of ' + cap + ' freezes held'}>
      {Array.from({ length: cap }).map((_, i) => (
        <span key={i} style={{
          width: size, height: size, borderRadius: 999,
          background: i < held ? 'var(--accent)' : 'transparent',
          border: '1.5px solid ' + (i < held ? 'var(--accent)' : 'var(--rule)'),
        }}/>
      ))}
    </span>
  );
}

// StreakScreen — celebration beat (Roasty), then an original streak view:
// a progress ring toward the next milestone, the week strip, and an insight
// card. No tree here — the tree lives on its own screen.
function StreakScreen({ streak, frozenDays, freezesHeld = 0, freezeCap = 2, nextFreezeIn = 7, onClose, onContinue }) {
  const [phase, setPhase] = React.useState('roasty');
  const [armed, setArmed] = React.useState(false);
  const [hdrScrolled, onHdrScroll] = window.useScrollFlag();
  const [shareOpen, setShareOpen] = React.useState(false);
  // Re-arm the progress ring every time the content view (re)appears, so a
  // Replay re-runs the fill from zero.
  React.useEffect(() => {
    if (phase !== 'content') return;
    setArmed(false);
    const t = setTimeout(() => setArmed(true), 80);
    return () => clearTimeout(t);
  }, [phase]);
  const replay = () => setPhase('roasty');
  if (phase === 'roasty') {
    return <RoastyMoment state="correct" eyebrow="STREAK" title={`${streak} days in a row.`}
                         onDone={() => setPhase('content')}/>;
  }

  const milestones = [3, 7, 14, 30, 60, 100, 180, 365];
  const nextMilestone = milestones.find(m => m > streak) || (Math.ceil((streak + 1) / 30) * 30);
  const frac = Math.max(0.04, Math.min(1, streak / nextMilestone));

  const R = 84, C = 2 * Math.PI * R;

  // Freeze status, in one line: what a freeze just covered, or what's held, or
  // when the next one lands. Never a setting — always current state.
  const DAY_NAMES = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  const iced = (frozenDays instanceof Set ? [...frozenDays] : (frozenDays || []));
  const freezeLine = iced.length
    ? `${DAY_NAMES[iced[0]]} was covered by a freeze`
    : freezesHeld > 0
      ? `${freezesHeld} freeze${freezesHeld === 1 ? '' : 's'} held · covers a missed day`
      : `Next freeze in ${nextFreezeIn} day${nextFreezeIn === 1 ? '' : 's'}`;

  return (
    <div className="screen" data-screen-label="Streak" style={{ background: 'var(--bg)' }}>
      {window.SubScreenHeader && <window.SubScreenHeader scrolled={hdrScrolled} title="Your streak" icon="close" onBack={onClose}/>}

      <div className="scroll" onScroll={onHdrScroll} style={{ paddingTop: 84, paddingBottom: 24, display: 'flex', flexDirection: 'column' }}>
        {/* hero ring */}
        <div style={{ display: 'flex', justifyContent: 'center', paddingTop: 8 }}>
          <div style={{ position: 'relative', width: 208, height: 208 }}>
            <svg width="208" height="208" viewBox="0 0 208 208" style={{ display: 'block' }}>
              <circle cx="104" cy="104" r={R} fill="none" stroke="var(--surface-2)" strokeWidth="12"/>
              <circle cx="104" cy="104" r={R} fill="none" stroke="var(--accent)" strokeWidth="12"
                      strokeLinecap="round" strokeDasharray={C}
                      strokeDashoffset={armed ? C * (1 - frac) : C}
                      transform="rotate(-90 104 104)"
                      style={{ transition: 'stroke-dashoffset 1100ms cubic-bezier(0.2,0.9,0.3,1)' }}/>
            </svg>
            <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
              <SteamMark/>
              <div className="ff-mono" style={{ fontSize: 'var(--t-hero)', fontWeight: 500, lineHeight: 0.9, letterSpacing: '-0.02em', color: 'var(--ink)', marginTop: 4 }}>{streak}</div>
              <div className="smallcaps" style={{ marginTop: 4 }}>DAY STREAK</div>
            </div>
          </div>
        </div>

        <div style={{ textAlign: 'center', paddingTop: 16 }}>
          <span className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.12em', textTransform: 'uppercase', color: 'var(--accent)' }}>
            {streak} of {nextMilestone} to your {nextMilestone}-day badge
          </span>
        </div>

        {/* week strip */}
        <div className="px-24" style={{ paddingTop: 30 }}>
          <WeekStrip size="lg" frozen={iced} streak={streak}/>
          {/* Freeze state lives here, next to the days it acts on — earned by
              keeping the streak, spent automatically, nothing to manage. */}
          <div style={{ marginTop: 16, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10 }}>
            <FreezeTokens held={freezesHeld} cap={freezeCap}/>
            <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.1em', textTransform: 'uppercase', color: iced.length ? 'var(--accent)' : 'var(--ink-mute)' }}>
              {freezeLine}
            </span>
          </div>
        </div>

        {/* insight card */}
        <div className="px-24" style={{ paddingTop: 28 }}>
          <div style={{ background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 14, padding: '18px 20px', display: 'flex', gap: 14, alignItems: 'flex-start' }}>
            <ProfileBean size={22}/>
            <p style={{ margin: 0, fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink)' }}>
              Showing up daily is how tasting notes start to stick. You've brewed knowledge <strong style={{ color: 'var(--accent)' }}>{streak} days</strong> running.
            </p>
          </div>
        </div>

        <div style={{ flex: 1, minHeight: 20 }}/>

        <div className="px-24" style={{ paddingTop: 24, paddingBottom: 8 }}>
          <button className="btn btn-primary" onClick={onContinue}>Continue</button>
          <button className="btn btn-ghost" style={{ marginTop: 10 }} onClick={() => setShareOpen(true)}>Share your streak</button>
        </div>
      </div>

      <ShareStreakSheet streak={streak} frozen={iced}
                        open={shareOpen} onClose={() => setShareOpen(false)}/>
    </div>
  );
}

// ShareStreakSheet — bottom drawer (same chrome as the card-detail sheet) that
// previews the shareable streak card and offers a few destinations.
function ShareTarget({ label, children, onClick }) {
  return (
    <button onClick={onClick} style={{
      appearance: 'none', cursor: 'pointer', background: 'transparent', border: 'none',
      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8, padding: 0,
    }}>
      <span style={{
        width: 52, height: 52, borderRadius: 999, display: 'grid', placeItems: 'center',
        border: '1px solid var(--rule)', background: 'var(--surface)', color: 'var(--ink)',
      }}>{children}</span>
      <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--ink-mute)' }}>{label}</span>
    </button>
  );
}

function ShareStreakSheet({ streak, frozen, open, onClose }) {
  const [copied, setCopied] = React.useState(false);
  React.useEffect(() => { if (!open) setCopied(false); }, [open]);
  return (
    <>
      <div className={'sheet-backdrop' + (open ? ' open' : '')} onClick={onClose}/>
      <div className={'sheet' + (open ? ' open' : '')}>
        <div className="sheet-handle"/>
        <div className="sheet-content">
          <div className="smallcaps" style={{ marginBottom: 8 }}>SHARE</div>
          <h2 className="ff-display" style={{
            fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em',
            margin: 0, color: 'var(--ink)',
          }}>Your {streak}-day streak</h2>

          {/* the shareable artifact */}
          <div style={{
            marginTop: 18, borderRadius: 16, overflow: 'hidden',
            border: '1px solid color-mix(in oklab, var(--accent) 24%, var(--rule))',
            background: 'linear-gradient(160deg, color-mix(in oklab, var(--accent) 12%, var(--surface)) 0%, var(--surface) 60%)',
            padding: '22px 22px 20px',
            boxShadow: '0 14px 34px rgba(0,0,0,0.22)',
          }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <span className="smallcaps" style={{ color: 'var(--accent)' }}>BREWPATH</span>
              <SteamMark w={22}/>
            </div>

            <div style={{ textAlign: 'center', padding: '6px 0 14px' }}>
              <div className="ff-mono" style={{ fontSize: 'var(--t-hero)', fontWeight: 500, lineHeight: 0.95, letterSpacing: '-0.02em', color: 'var(--ink)' }}>{streak}</div>
              <div className="smallcaps" style={{ marginTop: 2 }}>DAY STREAK</div>
            </div>

            <WeekStrip size="sm" frozen={frozen} streak={streak}/>

            <div className="ff-mono" style={{
              fontSize: 'var(--t-micro)', letterSpacing: '0.1em', textTransform: 'uppercase',
              color: 'var(--ink-mute)', textAlign: 'center', marginTop: 16,
            }}>Learning coffee, one cup at a time</div>
          </div>

          {/* destinations */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 12, marginTop: 22 }}>
            <ShareTarget label="Stories">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><rect x="4" y="4" width="16" height="16" rx="5" stroke="currentColor" strokeWidth="1.6"/><circle cx="12" cy="12" r="3.6" stroke="currentColor" strokeWidth="1.6"/><circle cx="16.6" cy="7.4" r="1" fill="currentColor"/></svg>
            </ShareTarget>
            <ShareTarget label="Message">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M4 6.5C4 5.4 4.9 4.5 6 4.5h12c1.1 0 2 .9 2 2v7c0 1.1-.9 2-2 2H9l-4 3.5V6.5Z" stroke="currentColor" strokeWidth="1.6" strokeLinejoin="round"/></svg>
            </ShareTarget>
            <ShareTarget label={copied ? 'Copied' : 'Copy link'} onClick={() => setCopied(true)}>
              {copied
                ? <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M5 12.5l4 4 10-10" stroke="var(--accent)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>
                : <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M9.5 14.5l5-5" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/><path d="M11 8l1.7-1.7a3.3 3.3 0 0 1 4.7 4.7L15.7 12.7" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/><path d="M13 16l-1.7 1.7a3.3 3.3 0 0 1-4.7-4.7L8.3 11.3" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/></svg>}
            </ShareTarget>
            <ShareTarget label="Save">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M12 4v10m0 0l-3.5-3.5M12 14l3.5-3.5" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/><path d="M5 17v1.5C5 19.3 5.7 20 6.5 20h11c.8 0 1.5-.7 1.5-1.5V17" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/></svg>
            </ShareTarget>
          </div>

          <div style={{ paddingTop: 22 }}>
            <button className="btn btn-ghost" onClick={onClose}>Maybe later</button>
          </div>
        </div>
      </div>
    </>
  );
}

// TreeScreen — the dedicated home of the living coffee tree, reached from the
// Profile. Shows the current growth stage, progress toward the next, and a
// 10-stage ladder. The growth animation itself plays at module completion.
function TreeScreen({ stage, coreDone, coreTotal, onClose }) {
  const s = Math.max(1, Math.min(10, stage || 1));
  const names = window.STAGE_NAMES || [];
  const pretty = (n) => n ? n.charAt(0) + n.slice(1).toLowerCase() : '';
  const name = names[s - 1] || 'GROWING';
  const total = coreTotal || (window.CORE_TOTAL || 1);
  const done = Math.max(0, Math.min(total, coreDone || 0));
  const frac = Math.max(0.03, Math.min(1, done / total));
  const nextName = s >= 10 ? null : (names[s] || 'NEXT');
  const SubHeader = window.SubScreenHeader;
  const [hdrScrolled, onHdrScroll] = window.useScrollFlag();

  return (
    <div className="screen" data-screen-label="Tree" style={{ background: 'var(--bg)' }}>
      {SubHeader && <SubHeader scrolled={hdrScrolled} title="Your coffee tree" icon="close" onBack={onClose}/>}
      <div className="scroll" onScroll={onHdrScroll} style={{ paddingTop: 84, paddingBottom: 28, display: 'flex', flexDirection: 'column' }}>
        <div className="px-24" style={{ textAlign: 'center' }}>
          <div className="smallcaps" style={{ color: 'var(--accent)' }}>YOUR COFFEE TREE</div>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em', margin: '8px 0 0', color: 'var(--ink)' }}>{pretty(name)}</h1>
        </div>

        <div style={{ display: 'flex', justifyContent: 'center', padding: '8px 0 0' }}>
          <CoffeePersona stage={s} size={236}/>
        </div>

        <div style={{ textAlign: 'center' }}>
          <div className="smallcaps">STAGE {s} OF 10</div>
        </div>

        <div className="px-24" style={{ paddingTop: 26 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 8 }}>
            <span className="smallcaps">CORE LESSONS COMPLETED</span>
            <span className="ff-mono" style={{ fontSize: 'var(--t-label)', color: 'var(--ink-mute)', letterSpacing: '0.08em' }}>{done} / {total}</span>
          </div>
          <div style={{ height: 8, background: 'var(--surface-2)', borderRadius: 999, overflow: 'hidden' }}>
            <div style={{ height: '100%', width: (frac * 100) + '%', background: 'var(--accent)', borderRadius: 999, transition: 'width 900ms cubic-bezier(0.2,0.9,0.3,1)' }}/>
          </div>
          {nextName && (
            <div className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--ink-mute)', marginTop: 8 }}>NEXT · {pretty(nextName)}</div>
          )}
        </div>

        {/* 10-stage ladder */}
        <div className="px-24" style={{ paddingTop: 24 }}>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(10, 1fr)', gap: 5 }}>
            {Array.from({ length: 10 }).map((_, i) => (
              <div key={i} style={{ height: 4, borderRadius: 999, background: (i + 1) <= s ? 'var(--accent)' : 'var(--surface-2)' }}/>
            ))}
          </div>
        </div>

        <div className="px-24" style={{ paddingTop: 24 }}>
          <p style={{ margin: 0, fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', textWrap: 'pretty' }}>
            Your tree grows when you complete new core lessons on the main path. Replaying a lesson sharpens your mastery, but the tree only grows the first time you finish one.
          </p>
        </div>

        <div style={{ flex: 1, minHeight: 16 }}/>
        <div className="px-24" style={{ paddingTop: 24 }}>
          <button className="btn btn-primary" onClick={onClose}>Back to profile</button>
        </div>
      </div>
    </div>
  );
}

// SettingsScreen — reached from the Profile. Holds theme, reminders, and
// account controls. The account rows route out to full screens (About,
// Account and sync) or open confirmation sheets (Reset progress). The practice
// rows are live toggles + a reminder-time sheet, managed locally.
function SettingsScreen({ theme, onTheme, onClose, onAbout, onAccount, onSubscription, onHelp, isPlus, inTrial = false, showDataExport, onReset, onDeleteAccount, progressSummary }) {
  const [reminder, setReminder] = useState('8:00 AM');
  const [notify, setNotify] = useState(true);
  const [sound, setSound] = useState(true);
  const [haptics, setHaptics] = useState(true);
  const [timeOpen, setTimeOpen] = useState(false);
  const [resetOpen, setResetOpen] = useState(false);
  const [dataOpen, setDataOpen] = useState(false);
  const [deleteOpen, setDeleteOpen] = useState(false);
  const ConfirmSheet = window.ConfirmSheet;
  const TimeSheet = window.TimeSheet;
  const Toggle = window.SettingsToggle;
  const SubHeader = window.SubScreenHeader;
  const [scrolled, onScroll] = window.useScrollFlag();

  return (
    <div className="screen" data-screen-label="Settings" style={{ background: 'var(--bg)' }}>
      {SubHeader && <SubHeader scrolled={scrolled} title="Settings" onBack={onClose}/>}
      <div className="scroll" onScroll={onScroll} style={{ paddingTop: 108, paddingBottom: 28 }}>
        <div className="px-24">
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>Settings</h1>
        </div>

        <div className="px-24" style={{ paddingTop: 26 }}>
          <div className="smallcaps" style={{ marginBottom: 4 }}>APPEARANCE</div>
          <ThemeRow theme={theme} onTheme={onTheme}/>
        </div>

        <div className="px-24" style={{ paddingTop: 26 }}>
          <div className="smallcaps" style={{ marginBottom: 4 }}>PRACTICE</div>
          <SettingsRow label="Notifications" toggle toggleOn={notify} onToggle={setNotify}/>
          <SettingsRow label="Daily reminder" value={notify ? reminder : 'Off'} dim={!notify} onClick={() => setTimeOpen(true)}/>
          <SettingsRow label="Sound effects" toggle toggleOn={sound} onToggle={setSound}/>
          <SettingsRow label="Haptics" toggle toggleOn={haptics} onToggle={setHaptics}/>
        </div>

        <div className="px-24" style={{ paddingTop: 26 }}>
          <div className="smallcaps" style={{ marginBottom: 4 }}>ACCOUNT</div>
          <SettingsRow label="Account and sync" value={(window.USER || {}).email} onClick={onAccount}/>
          <SettingsRow label="Subscription" value={isPlus ? (inTrial ? 'Trial' : 'Plus') : 'Free'} onClick={onSubscription}/>
          {/* Data export is deferred to v2 — rendered only in the 'everything' scope. */}
          {showDataExport && <SettingsRow label="Download my data" onClick={() => setDataOpen(true)}/>}
        </div>

        <div className="px-24" style={{ paddingTop: 26 }}>
          <div className="smallcaps" style={{ marginBottom: 4 }}>SUPPORT</div>
          <SettingsRow label="Help and support" onClick={onHelp}/>
          <SettingsRow label="About" onClick={onAbout}/>
        </div>

        <div className="px-24" style={{ paddingTop: 26 }}>
          <SettingsRow label="Reset progress" accent onClick={() => setResetOpen(true)}/>
          <SettingsRow label="Delete account" accent onClick={() => setDeleteOpen(true)}/>
        </div>

        <div className="px-24" style={{ paddingTop: 32 }}>
          <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.14em', color: 'var(--ink-mute)', textTransform: 'uppercase', textAlign: 'center' }}>
            BrewPath · v0.1 · A field guide
          </div>
        </div>
      </div>

      {TimeSheet && (
        <TimeSheet open={timeOpen} value={reminder}
          onClose={() => setTimeOpen(false)}
          onSave={(v) => { setReminder(v); setNotify(true); setTimeOpen(false); }}/>
      )}
      {ConfirmSheet && (
        <ConfirmSheet open={resetOpen} danger
          title="Start again from seed?"
          body="Your tree returns to a bare seed, every lesson locks back to the start, and your saved items are cleared. There’s no undo."
          lines={progressSummary}
          confirmLabel="Reset everything"
          onConfirm={() => { setResetOpen(false); onReset && onReset(); }}
          onClose={() => setResetOpen(false)}/>
      )}
      {ConfirmSheet && showDataExport && (
        <ConfirmSheet open={dataOpen}
          title="Get a copy of your data"
          body={'We’ll email an export of your progress, streaks and tasting notes to ' + ((window.USER || {}).email || '') + '. It usually arrives within a few minutes.'}
          confirmLabel="Email my data"
          cancelLabel="Cancel"
          onConfirm={() => setDataOpen(false)}
          onClose={() => setDataOpen(false)}/>
      )}
      {ConfirmSheet && (
        <ConfirmSheet open={deleteOpen} danger
          title="Delete account?"
          body="Your account and all associated data will be permanently deleted. This action cannot be undone."
          confirmLabel="Delete account"
          cancelLabel="Cancel"
          onConfirm={() => { setDeleteOpen(false); onDeleteAccount && onDeleteAccount(); }}
          onClose={() => setDeleteOpen(false)}/>
      )}
    </div>
  );
}

window.StreakScreen = StreakScreen;
window.TreeScreen = TreeScreen;
window.SettingsScreen = SettingsScreen;
window.WeekStrip = WeekStrip;

// ───────────────────────────────────────────────────────────
// Header entry button — access to the Coffee Dictionary. Rendered inside the
// shared AppHeader (static flow); falls back to a floating pill if used solo.
function DictHeaderButton({ onClick, locked = false, inHeader = false }) {
  return (
    <button onClick={onClick} aria-label="Coffee Dictionary" style={{
      ...(inHeader
        ? { position: 'relative' }
        : { position: 'absolute', top: 60, right: 18, zIndex: 60, boxShadow: '0 2px 8px rgba(0,0,0,0.10)' }),
      appearance: 'none', cursor: 'pointer', width: 44, height: 44, borderRadius: 999,
      background: 'var(--surface)', border: '1px solid var(--rule)',
      display: 'grid', placeItems: 'center',
    }}>
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
        {/* open book = dictionary */}
        <path d="M12 6.6C10.4 5.4 8.3 5.1 6.2 5.3A1 1 0 0 0 5 6.3v10.2a1 1 0 0 0 1.1 1c1.9-.2 3.9.1 5.4 1.2M12 6.6c1.6-1.2 3.7-1.5 5.8-1.3a1 1 0 0 1 1.1 1v10.2a1 1 0 0 1-1.1 1c-1.9-.2-3.9.1-5.4 1.2M12 6.6V19"
          stroke="var(--accent)" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
      {locked && window.LockBadge && <window.LockBadge/>}
    </button>
  );
}

// Header entry button — access to Saved (bookmarked lessons / terms / guides).
// Sits to the left of the Dictionary entry in the shared AppHeader.
function SavedHeaderButton({ onClick, locked = false, count = 0 }) {
  return (
    <button onClick={onClick} aria-label="Saved" style={{
      position: 'relative', appearance: 'none', cursor: 'pointer', width: 44, height: 44, borderRadius: 999,
      background: 'var(--surface)', border: '1px solid var(--rule)',
      display: 'grid', placeItems: 'center',
    }}>
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
        <path d="M7 4.8A1 1 0 0 1 8 3.8h8a1 1 0 0 1 1 1V20l-5-3.6L7 20V4.8Z"
          stroke="var(--accent)" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
      {!locked && count > 0 && (
        <span aria-hidden="true" style={{
          position: 'absolute', top: -1, right: -1, width: 9, height: 9, borderRadius: 999,
          background: 'var(--accent)', border: '2px solid var(--bg)', boxSizing: 'content-box',
        }}></span>
      )}
      {locked && window.LockBadge && <window.LockBadge/>}
    </button>
  );
}

// ───────────────────────────────────────────────────────────
// APP HEADER — shared sticky bar across the main tabs.
// At the top it's invisible (the tab's large title carries the screen).
// On scroll it blends in — a blurred, tinted bar with a bottom hairline —
// and the compact screen title slides in on the left, mirroring the large
// title that has just scrolled away. The Dictionary / Duel entries live on
// the right and stay put the whole time.
// ───────────────────────────────────────────────────────────
const APP_HEADER_TITLES = {
  learn: (() => {
    const d = new Date(2026, 4, 8); // Fri May 8 — frozen for the prototype
    return { eyebrow: 'TODAY', title: d.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' }) };
  })(),
  path:  { eyebrow: 'YOUR PATH', title: 'Beginner Foundations' },
  cards: { eyebrow: 'YOUR DECK', title: 'Collection' },
  profile: { eyebrow: 'PROFILE', title: 'Hello, ' + ((window.USER || {}).name || 'there') + '.' },
};

function AppHeader({ tab, variant = 'default', scrolled, dictLocked, onDict, savedLocked, onSaved, savedCount = 0, showDuel, duelLocked, duelCount = 0, onDuel, onSettings }) {
  const meta = APP_HEADER_TITLES[tab] || { eyebrow: '', title: '' };
  return (
    <window.StickyHeaderChrome scrolled={scrolled} height={116}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '0 18px 14px', width: '100%' }}>
      <window.HeaderCompactTitle scrolled={scrolled} eyebrow={meta.eyebrow} title={meta.title}/>

      {/* right entries — always visible, sit flush to the right edge */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, flexShrink: 0, marginLeft: 'auto', pointerEvents: 'auto' }}>
        {variant === 'profile' ? (
          <button onClick={onSettings} aria-label="Settings" style={{
            appearance: 'none', cursor: 'pointer', width: 44, height: 44, borderRadius: 999,
            background: 'var(--surface)', border: '1px solid var(--rule)', display: 'grid', placeItems: 'center',
          }}>
            <IconGear/>
          </button>
        ) : (
          <>
            {onSaved && (savedLocked || savedCount > 0) && <SavedHeaderButton locked={savedLocked} count={savedCount} onClick={onSaved}/>}
            <DictHeaderButton inHeader locked={dictLocked} onClick={onDict}/>
            {showDuel && window.DuelHeaderButton && (
              <window.DuelHeaderButton inHeader locked={duelLocked} count={duelCount} onClick={onDuel}/>
            )}
          </>
        )}
      </div>
      </div>
    </window.StickyHeaderChrome>
  );
}
window.AppHeader = AppHeader;

// LEARN TAB
// ───────────────────────────────────────────────────────────
function LearnTab({ freezeSaved = false, freezesHeld = 0, nextFreezeIn = 7, onDismissFreeze, onLesson, onGame, onOpenDuel, showDuel = true, isLocked, state, brewChallenge, brewMode, brewAutoHide = true, brewPointsAwarded = true, onBrewLog, onBrewSkip, onBrewDismiss, onBrewCard, brewCompleted, brewActiveId, brewSaved, onBrewUnsave, onBrewAction }) {
  const lock = isLocked || (() => false);
  const tod = window.dictTermOfDay ? window.dictTermOfDay() : null;
  const termCount = (window.DICT_TERMS || []).length;
  const today = new Date(2026, 4, 8); // Friday May 8 (frozen for prototype)
  const dayName = today.toLocaleDateString('en-US', { weekday: 'long' });
  const monthDay = today.toLocaleDateString('en-US', { month: 'long', day: 'numeric' });

  // Derive the live state from the content model rather than hard-coding.
  let curMod = MODULES[0], curLesson = MODULES[0].lessons[0];
  let foundCurrent = false;
  for (const m of MODULES) {
    const l = m.lessons.find(x => x.status === 'current');
    if (l) { curMod = m; curLesson = l; foundCurrent = true; break; }
  }
  // Every unlocked lesson finished — nothing left to "continue" until the next
  // module ships. Show a caught-up state instead of replaying a done lesson.
  const allCaughtUp = !foundCurrent;
  const curIdx = curMod.lessons.findIndex(l => l.id === curLesson.id);
  const nextLesson = curMod.lessons[curIdx + 1] || null; // next, still-locked lesson IN this module
  const lessonNum = curIdx + 1;
  const modTotal = curMod.lessons.length;

  // Completed work the user can revisit (lessons + games + finished modules).
  const completed = [];
  for (const m of MODULES) {
    for (const l of m.lessons) {
      if (l.status === 'complete') completed.push({ ...l, mod: m });
    }
  }

  return (
    <div className="screen slide-in" data-screen-label="Learn">
      <div className="scroll" style={{ paddingBottom: 120 }}>
        <div className="px-24" style={{ paddingTop: 24 }}>
          <h1 className="ff-display" style={{
            fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em',
            margin: 0, color: 'var(--ink)',
          }}>
            {dayName}, {monthDay}
          </h1>
        </div>

        {/* The save beat — shown once, on the first open after a freeze covered a
            missed day. Reassurance first, then the cost, so the scarcity lands.
            Deliberately a dismissible card and not a moment: someone returning
            after a miss is the most fragile user in the app. */}
        {freezeSaved && (
          <div className="px-24" style={{ paddingTop: 20 }}>
            <div style={{ background: 'var(--surface)', border: '1px solid color-mix(in oklab, var(--accent) 30%, var(--rule))', borderRadius: 14, padding: '15px 16px', display: 'flex', gap: 13, alignItems: 'flex-start' }}>
              <span style={{ width: 30, height: 30, borderRadius: 999, flexShrink: 0, display: 'grid', placeItems: 'center', background: 'color-mix(in oklab, var(--accent) 12%, var(--surface))' }}>
                <FreezeMark size={16}/>
              </span>
              <span style={{ minWidth: 0, flex: 1 }}>
                <span style={{ display: 'block', fontSize: 'var(--t-support)', fontWeight: 500, color: 'var(--ink)' }}>Your streak is safe.</span>
                <span style={{ display: 'block', fontSize: 'var(--t-label)', lineHeight: 1.45, color: 'var(--ink-mute)', marginTop: 3, textWrap: 'pretty' }}>
                  Yesterday was covered by a freeze. {freezesHeld > 0 ? `${freezesHeld} still held.` : `You'll earn another in ${nextFreezeIn} days.`}
                </span>
              </span>
              <button onClick={onDismissFreeze} aria-label="Dismiss" style={{ appearance: 'none', background: 'transparent', border: 0, padding: 2, cursor: 'pointer', color: 'var(--ink-mute)', flexShrink: 0 }}>
                {window.CloseMark ? <window.CloseMark size={16}/> : null}
              </button>
            </div>
          </div>
        )}

        {/* 1 · Current lesson — the first thing the user sees */}
        <div className="px-24" style={{ paddingTop: 28 }}>
          <div className="smallcaps" style={{ marginBottom: 28 }}>{allCaughtUp ? 'ALL CAUGHT UP' : 'CONTINUE LEARNING'}</div>
          {allCaughtUp ? (
            <div className="card" style={{ textAlign: 'center' }}>
              <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 6 }}>
                <Roasty state="module" size={96}/>
              </div>
              <h2 className="ff-display" style={{
                fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.12, letterSpacing: '-0.01em',
                margin: '4px 0 0', color: 'var(--ink)',
              }}>You’ve finished every lesson available.</h2>
              <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: '12px 0 20px', textWrap: 'pretty' }}>
                New modules are on the way. Revisit anything below, or review your path so far.
              </p>
            </div>
          ) : (
          <div className="card">
            <div className="smallcaps" style={{ marginBottom: 10 }}>MODULE {curMod.n} · {curMod.label}</div>
            <h2 className="ff-display" style={{
              fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.01em',
              margin: 0, color: 'var(--ink)',
            }}>{curLesson.title}</h2>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 16, marginTop: 20 }}>
              <div className="ff-mono" style={{
                fontSize: 'var(--t-label)', letterSpacing: '0.14em', color: 'var(--ink-mute)',
                textTransform: 'uppercase', display: 'flex', flexDirection: 'column', gap: 7,
              }}>
                <span>LESSON {lessonNum}/{modTotal}</span>
                <span>~{curLesson.time} MIN</span>
              </div>
              <button className="btn btn-primary" onClick={() => onLesson(curLesson.id)} style={{ flexShrink: 0, width: 'auto', minWidth: 132, padding: '12px 22px', fontSize: 'var(--t-support)' }}>
                Begin lesson
              </button>
            </div>
          </div>
          )}
        </div>

        {/* 2 · Active Brew Challenge — below Continue Learning, above Up Next */}
        {brewChallenge && brewMode && window.ActiveBrewCard && (
          <window.ActiveBrewCard challenge={brewChallenge} mode={brewMode} autoHide={brewAutoHide} showPoints={brewPointsAwarded}
            onLog={onBrewLog} onSkip={onBrewSkip} onDismiss={onBrewDismiss} onOpenCard={onBrewCard}/>
        )}

        {/* 2b · Saved challenges — the ones you parked for later */}
        {window.SavedBrewList && (
          <window.SavedBrewList saved={brewSaved} activeId={brewActiveId} completed={brewCompleted}
            onStart={(ch) => onBrewAction && onBrewAction(ch, 'available')}
            onRemove={onBrewUnsave}/>
        )}

        {/* Coffee Duel — challenge a friend */}
        {showDuel && (
        <div className="px-24" style={{ paddingTop: 32 }}>
          <button onClick={() => onOpenDuel && onOpenDuel('hub')} style={{
            width: '100%', appearance: 'none', cursor: 'pointer', textAlign: 'left',
            display: 'grid', gridTemplateColumns: 'auto 1fr auto', alignItems: 'center', gap: 14,
            background: 'color-mix(in oklab, var(--accent) 9%, var(--surface))',
            border: '1px solid color-mix(in oklab, var(--accent) 26%, var(--rule))', borderRadius: 14, padding: 16,
          }}>
            <span style={{ width: 56, height: 56, flexShrink: 0, borderRadius: 14, display: 'grid', placeItems: 'center', background: 'var(--bg)', border: '1px solid var(--rule)', overflow: 'hidden' }}>
              <Roasty state="correct" size={52} gear="sunglasses"/>
            </span>
            <span style={{ minWidth: 0 }}>
              <span className="smallcaps" style={{ color: 'var(--accent)', display: 'flex', alignItems: 'center', gap: 8 }}>
                COFFEE DUEL
                {lock('duel') && window.PlusPill && <window.PlusPill/>}
              </span>
              <span className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, letterSpacing: '-0.01em', color: 'var(--ink)', lineHeight: 1.05, display: 'block', marginTop: 4 }}>Challenge a friend</span>
              <span style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 3, display: 'block' }}>5 quick questions, head to head →</span>
            </span>
            {(() => {
              const n = window.DUEL_RECORDS ? window.DUEL_RECORDS.incoming.length : 0;
              return n > 0
                ? <span className="ff-mono" style={{ flexShrink: 0, minWidth: 22, height: 22, padding: '0 6px', borderRadius: 999, background: 'var(--accent)', color: 'var(--accent-ink)', fontSize: 'var(--t-label)', fontWeight: 500, display: 'grid', placeItems: 'center' }}>{n}</span>
                : <window.Chevron/>;
            })()}
          </button>
        </div>
        )}

        {/* 3 · Completed work to revisit — grouped by idea, each group collapsible */}
        {(() => {
          const practiceGroups = [
            {
              id: 'lessons', label: 'Lessons',
              items: completed.map(l => ({
                id: l.id, kind: 'lesson', title: l.title,
                sub: `MODULE ${l.mod.n} · ${l.mod.label}`,
                meta: `~${l.time} MIN`, lessonId: l.id,
              })),
            },
            {
              id: 'games', label: 'Mini-games',
              items: MINI_GAMES,
            },
          ].filter(g => g.items.length);

          return (
            <div className="px-24" style={{ paddingTop: 32 }}>
              <div className="smallcaps" style={{ marginBottom: 12 }}>PRACTICE AGAIN</div>
              {practiceGroups.map((g, i) => (
                <PracticeGroup key={g.id} label={g.label} count={g.items.length} defaultOpen={false}>
                  {g.items.map(it => {
                    const isGame = g.id === 'games';
                    // Mini-games draw on the whole course, not one lesson, so the row
                    // leads with the game's own name and takes its topic as the eyebrow.
                    const rowTitle = it.title;
                    const rowSub = it.sub;
                    return (
                    <ReplayRow key={it.id} icon={<ReplayIcon kind={it.kind}/>} title={rowTitle}
                               sub={rowSub} meta={it.meta}
                               onClick={() => isGame ? onGame(it) : onLesson(it.id)}/>
                    );
                  })}
                </PracticeGroup>
              ))}
            </div>
          );
        })()}
      </div>
    </div>
  );
}

function IconLock() {
  return (
    <svg width="18" height="18" viewBox="0 0 20 20" style={{ color: 'var(--ink-mute)' }}>
      <rect x="4.5" y="8.5" width="11" height="8" rx="1.6" fill="none" stroke="currentColor" strokeWidth="1.5"/>
      <path d="M7 8.5 V6.5 a3 3 0 0 1 6 0 V8.5" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
    </svg>
  );
}

function FormRow({ label, value }) {
  return (
    <div className="form-row">
      <span className="lbl">{label}</span>
      <span className="val">{value}</span>
    </div>
  );
}

function PracticeGroup({ label, count, defaultOpen, children }) {
  const [open, setOpen] = React.useState(!!defaultOpen);
  return (
    <div style={{ borderBottom: '1px solid var(--rule)' }}>
      <button onClick={() => setOpen(o => !o)} aria-expanded={open}
        style={{
          width: '100%', appearance: 'none', border: 'none', background: 'transparent',
          cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          padding: '16px 0',
        }}>
        <span style={{ display: 'flex', alignItems: 'baseline', gap: 10 }}>
          <span style={{ fontSize: 'var(--t-body)', color: 'var(--ink)', fontWeight: 500 }}>{label}</span>
          <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.12em', color: 'var(--ink-mute)' }}>{count}</span>
        </span>
        <svg width="18" height="18" viewBox="0 0 20 20" style={{ color: 'var(--ink-mute)', transform: open ? 'rotate(180deg)' : 'none', transition: 'transform 240ms cubic-bezier(.4,0,.2,1)' }}>
          <path d="M5 8 L10 13 L15 8" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      </button>
      {open && <div style={{ paddingBottom: 6 }}>{children}</div>}
    </div>
  );
}

function ReplayIcon({ kind, size = 20 }) {
  if (kind === 'lesson') return <FlavorWheel size={size} filled={1} stroke={1}/>;
  const s = { color: 'var(--ink-mute)' };
  if (kind === 'flavor') {
    // cupping bowl with aroma rising — naming what you smell and taste.
    // Deliberately NOT the flavour wheel: that glyph means lesson progress.
    return (
      <svg width={size} height={size} viewBox="0 0 20 20" style={s}>
        <path d="M3.5 11.5h13a6.5 6.5 0 0 1-13 0Z" fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinejoin="round"/>
        <path d="M2.5 11.5h15" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/>
        <path d="M7 8.2c0-1.2 1.1-1.4 1.1-2.6 0-.7-.4-1.1-.8-1.4" fill="none" stroke="var(--accent)" strokeWidth="1.2" strokeLinecap="round"/>
        <path d="M10.4 8.2c0-1.5 1.3-1.8 1.3-3.3 0-.9-.5-1.4-1-1.8" fill="none" stroke="var(--accent)" strokeWidth="1.2" strokeLinecap="round"/>
      </svg>
    );
  }
  if (kind === 'module') {
    return (
      <svg width={size} height={size} viewBox="0 0 20 20" style={s}>
        <path d="M10 3 L17 6.5 L10 10 L3 6.5 Z" fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinejoin="round"/>
        <path d="M3 10.5 L10 14 L17 10.5" fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinejoin="round"/>
      </svg>
    );
  }
  if (kind === 'match') {
    // two tiles joined — pairing
    return (
      <svg width={size} height={size} viewBox="0 0 20 20" style={s}>
        <rect x="2.5" y="6" width="6" height="8" rx="1.6" fill="none" stroke="currentColor" strokeWidth="1.4"/>
        <rect x="11.5" y="6" width="6" height="8" rx="1.6" fill="none" stroke="currentColor" strokeWidth="1.4"/>
        <path d="M8.5 10 H11.5" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/>
      </svg>
    );
  }
  if (kind === 'quiz') {
    // check + cross — true / false
    return (
      <svg width={size} height={size} viewBox="0 0 20 20" style={s}>
        <path d="M2.5 6.5 L4.2 8.2 L7.5 4.5" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
        <path d="M12.5 4.8 L16.5 8.8 M16.5 4.8 L12.5 8.8" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
        <path d="M3 14 H17" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/>
      </svg>
    );
  }
  if (kind === 'mcq') {
    // stacked options with a check on the first
    return (
      <svg width={size} height={size} viewBox="0 0 20 20" style={s}>
        <rect x="3" y="4" width="14" height="4.5" rx="2.2" fill="none" stroke="currentColor" strokeWidth="1.4"/>
        <rect x="3" y="11.5" width="14" height="4.5" rx="2.2" fill="none" stroke="currentColor" strokeWidth="1.4"/>
        <path d="M5.2 6.2 L6.2 7.2 L8 5.4" fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
    );
  }
  if (kind === 'slider') {
    return (
      <svg width={size} height={size} viewBox="0 0 20 20" style={s}>
        <path d="M3 10 H17" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/>
        <circle cx="12.5" cy="10" r="3" fill="var(--bg)" stroke="currentColor" strokeWidth="1.4"/>
      </svg>
    );
  }
  if (kind === 'tastefix') {
    // cup with a corrective arrow curving back — diagnose and dial in
    return (
      <svg width={size} height={size} viewBox="0 0 20 20" style={s}>
        <path d="M4 8h9v3a3 3 0 0 1-3 3H7a3 3 0 0 1-3-3V8Z" fill="none" stroke="currentColor" strokeWidth="1.3"/>
        <path d="M13 9h2a1.5 1.5 0 0 1 0 3h-1.2" fill="none" stroke="currentColor" strokeWidth="1.3"/>
        <path d="M6.5 17.2c1.6.9 5.4.9 7 0" fill="none" stroke="var(--accent)" strokeWidth="1.3" strokeLinecap="round"/>
        <path d="M12.2 16.2l1.6 1 -1 1.6" fill="none" stroke="var(--accent)" strokeWidth="1.3" strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
    );
  }
  if (kind === 'bagpick') {
    // an unlabelled bag with a bean inside — read the sample, name the process
    return (
      <svg width={size} height={size} viewBox="0 0 20 20" style={s}>
        <path d="M5.5 6.5 L14.5 6.5 L15.5 17 L4.5 17 Z" fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinejoin="round"/>
        <path d="M7 6.5 L7 4.2 L13 4.2 L13 6.5" fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinejoin="round"/>
        <ellipse cx="10" cy="12.4" rx="2.5" ry="3.2" fill="none" stroke="var(--accent)" strokeWidth="1.3"/>
        <path d="M10 9.4 Q11 11.4 10 12.4 Q9 13.4 10 15.6" fill="none" stroke="var(--accent)" strokeWidth="1.1" strokeLinecap="round"/>
      </svg>
    );
  }
  if (kind === 'sequence') {
    return (
      <svg width={size} height={size} viewBox="0 0 20 20" style={s}>
        <circle cx="4.5" cy="5.5" r="1.1" fill="currentColor"/>
        <circle cx="4.5" cy="10" r="1.1" fill="currentColor"/>
        <circle cx="4.5" cy="14.5" r="1.1" fill="currentColor"/>
        <path d="M8 5.5 H16 M8 10 H16 M8 14.5 H13" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/>
      </svg>
    );
  }
  // generic game fallback
  return (
    <svg width={size} height={size} viewBox="0 0 20 20" style={s}>
      <circle cx="10" cy="10" r="6.5" fill="none" stroke="currentColor" strokeWidth="1.4"/>
      <circle cx="10" cy="10" r="2.4" fill="none" stroke="currentColor" strokeWidth="1.4"/>
    </svg>
  );
}

function ReplayRow({ icon, title, sub, meta, onClick }) {
  return (
    <button
      onClick={onClick}
      style={{
        width: '100%', appearance: 'none', border: 'none', background: 'transparent',
        cursor: 'pointer', textAlign: 'left',
        display: 'grid', gridTemplateColumns: '24px 1fr auto', alignItems: 'center',
        gap: 14, padding: '12px 0',
      }}>
      {icon}
      <div>
        <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.14em', color: 'var(--ink-mute)', textTransform: 'uppercase' }}>{sub}</div>
        <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink)', fontWeight: 500, marginTop: 2 }}>{title}</div>
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
        {meta && (
          <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.12em', color: 'var(--ink-mute)', textTransform: 'uppercase', textAlign: 'right' }}>
            {meta}
          </span>
        )}
        <svg width="18" height="18" viewBox="0 0 20 20" style={{ color: 'var(--ink-mute)', flexShrink: 0 }} aria-label="Replay">
          <path d="M15.5 6.5 A6 6 0 1 0 16 10" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
          <path d="M15.8 4 L16 6.8 L13.2 6.6" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      </div>
    </button>
  );
}

// ───────────────────────────────────────────────────────────
// COMING SOON — future modules teaser at the foot of the path.
// Deliberately NOT the locked-module pattern: no padlocks, no
// "finish X to unlock". A dotted trail continues the path spine
// into a light, sage-toned set of preview cards so the MVP reads
// as "more is planned" rather than "blocked".
// ───────────────────────────────────────────────────────────
function SoonGlyph({ cat, size = 20, color = 'currentColor' }) {
  // Milk drinks has no entry in the shared CatGlyph set, so draw a
  // simple latte glass + foam line here; everything else reuses CatGlyph.
  if (cat === 'milk') {
    const sw = window.GLYPH_STROKE || 1.6;
    return (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={{ color, flexShrink: 0 }} aria-hidden="true">
        <path d="M6.5 6 H17.5 L16.2 17.6 A2.2 2.2 0 0 1 14 19.6 H10 A2.2 2.2 0 0 1 7.8 17.6 Z" stroke="currentColor" strokeWidth={sw} strokeLinejoin="round"/>
        <path d="M7 11 Q9.5 9.4 12 11 T17 11" stroke="currentColor" strokeWidth={sw} strokeLinecap="round"/>
      </svg>
    );
  }
  return window.CatGlyph
    ? <window.CatGlyph cat={cat} size={size} color={color}/>
    : null;
}

function ComingSoonPath({ compact = false }) {
  const cards = [
    { id: 'espresso', glyph: 'espresso',  title: 'Espresso Basics' },
    { id: 'milk',     glyph: 'milk',      title: 'Milk Drinks' },
    { id: 'gear',     glyph: 'equipment', title: 'Brewing Gear' },
    { id: 'tasting',  glyph: 'sensory',   title: 'Coffee Tasting' },
  ];
  if (compact) {
    return (
      <div className="px-24" style={{ marginTop: 28, marginBottom: 8 }}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <span aria-hidden="true" style={{ width: 13, height: 13, borderRadius: '50%', border: '1.5px dashed var(--sage)', background: 'var(--bg)', flexShrink: 0 }}/>
            <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.12em', textTransform: 'uppercase', color: 'var(--sage)' }}>More coming soon</span>
          </div>
          <div style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', marginTop: 4, textWrap: 'pretty' }}>
            {cards.map(c => c.title).join(' · ')}
          </div>
        </div>
      </div>
    );
  }
  return (
    <div className="px-24" style={{ marginTop: 4, marginBottom: 8 }}>
      {/* dotted trail — the path spine keeps growing past the last module */}
      <div style={{ position: 'relative', height: 44, marginLeft: 15.5 }} aria-hidden="true">
        <div style={{ position: 'absolute', left: 0, top: -8, bottom: 12, borderLeft: '2px dotted var(--rule)' }}/>
        <span style={{
          position: 'absolute', left: -6, bottom: 0, width: 13, height: 13,
          borderRadius: '50%', border: '1.5px dashed var(--sage)', background: 'var(--bg)',
        }}/>
      </div>

      <div className="smallcaps" style={{ color: 'var(--sage)', marginBottom: 9 }}>ON THE HORIZON</div>
      <h2 className="ff-display" style={{
        fontSize: 'var(--t-heading)', fontWeight: 400, lineHeight: 1.14, letterSpacing: '-0.01em',
        margin: 0, color: 'var(--ink)', textWrap: 'pretty',
      }}>More coffee adventures coming soon</h2>
      <p style={{
        fontSize: 'var(--t-body)', lineHeight: 1.5, color: 'var(--ink-mute)',
        margin: '10px 0 0', maxWidth: 306, textWrap: 'pretty',
      }}>New modules on espresso, milk drinks, brewing gear, and tasting skills are planned.</p>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, marginTop: 20 }}>
        {cards.map((c) => (
          <div key={c.id} style={{
            background: 'color-mix(in oklab, var(--surface) 55%, var(--bg))',
            border: '1px dashed var(--rule)',
            borderRadius: 18,
            padding: '15px 15px 16px',
            display: 'flex', flexDirection: 'column', gap: 12,
          }}>
            <span style={{
              width: 38, height: 38, borderRadius: '50%', flexShrink: 0,
              display: 'grid', placeItems: 'center',
              background: 'color-mix(in oklab, var(--sage) 15%, var(--surface))',
            }}>
              <SoonGlyph cat={c.glyph} size={20} color="var(--sage)"/>
            </span>
            <div>
              <div style={{ fontSize: 'var(--t-body)', fontWeight: 500, color: 'var(--ink)', lineHeight: 1.2 }}>{c.title}</div>
              <span className="ff-mono" style={{
                display: 'inline-block', marginTop: 9,
                fontSize: 'var(--t-micro)', letterSpacing: '0.14em', textTransform: 'uppercase',
                color: 'var(--sage)',
                background: 'color-mix(in oklab, var(--sage) 14%, transparent)',
                padding: '3px 8px', borderRadius: 999,
              }}>Coming soon</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ───────────────────────────────────────────────────────────
// PATH TAB
// ───────────────────────────────────────────────────────────
// A collapsed module on the Focused path: one tappable row instead of an
// expanded lesson list. Completed modules review; locked modules just wait.
function CompactModuleRow({ mod, prereq }) {
  const locked = mod.locked;
  const n = mod.lessons.length;
  const complete = !locked && mod.lessons.every(l => l.status === 'complete');
  // Always static: the Path shows these as a summary row, never a destination.
  const interactive = false;
  return (
    <div className="px-24" style={{ marginBottom: 20 }}>
      <button
        disabled
        style={{
          width: '100%', appearance: 'none', border: 'none', background: 'transparent',
          cursor: interactive ? 'pointer' : 'default', textAlign: 'left', padding: 0, display: 'block',
        }}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 12 }}>
          <span data-mglyph="" style={{ display: 'inline-flex', justifyContent: 'center', width: 32, flexShrink: 0 }}>
            {window.CatGlyph && <window.CatGlyph cat={mod.glyph} size={26} color={locked ? 'var(--ink-mute)' : 'var(--accent)'}/>}
          </span>
          <h2 className="ff-display" style={{
            flex: 1, minWidth: 0,
            fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.01em',
            margin: 0, color: locked ? 'var(--ink-mute)' : 'var(--ink)',
          }}>{mod.title}</h2>
          {complete ? null : locked ? (
            <span className="trail"><window.LockMark size={13}/></span>
          ) : (
            <span className="trail"><window.Chevron/></span>
          )}
        </div>
        {!complete && (
          <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.1em', color: 'var(--ink-mute)', textTransform: 'uppercase', marginTop: 8, marginLeft: 44 }}>
            {locked && prereq ? `Finish ${prereq.title} to unlock` : `${n} lessons`}
          </div>
        )}
      </button>
    </div>
  );
}

function PathTab({ onLesson, brewCompleted, brewActiveId, brewSaved, brewPathMode, onBrewAction }) {
  const totalLessons = MODULES.reduce((a, m) => a + m.lessons.length, 0);
  const done = MODULES.flatMap(m => m.lessons).filter(l => l.status === 'complete').length;
  const unlocked = MODULES.filter(m => !m.locked).reduce((a, m) => a + m.lessons.length, 0);

  // The concept glyphs are drawn in a shared 24×24 box but their ink fills it
  // unevenly (the flame is tall, the cone short), so at one size they look
  // inconsistent. After render, crop each module glyph's viewBox to its actual
  // ink and render it at the title's cap height — so every icon reads the same
  // visual size as the first letter, with strokes kept constant via
  // non-scaling-stroke, and its ink bottom sitting on the text baseline.
  const listRef = useRef(null);
  // Expanded modules survive tab switches / navigation (start a challenge,
  // come back, the module is still open). Session-scoped, not persisted.
  const [expandedMods, setExpandedMods] = React.useState(() => window.__pathExpandedMods || {});
  const toggleMod = (id) => setExpandedMods(m => { const next = { ...m, [id]: !m[id] }; window.__pathExpandedMods = next; return next; });
  useEffect(() => {
    const host = listRef.current;
    if (!host) return;
    const CAP = 16; // ≈ cap height of the 24px Fraunces title
    host.querySelectorAll('[data-mglyph] > svg').forEach((svg) => {
      let bb; try { bb = svg.getBBox(); } catch (e) { return; }
      if (!bb || !bb.height) return;
      const p = 1; // small pad so non-scaling strokes never clip at the edge
      const vbW = bb.width + p * 2, vbH = bb.height + p * 2;
      svg.setAttribute('viewBox', `${(bb.x - p).toFixed(2)} ${(bb.y - p).toFixed(2)} ${vbW.toFixed(2)} ${vbH.toFixed(2)}`);
      const h = CAP * vbH / bb.height;
      const w = CAP * vbW / bb.height;
      svg.setAttribute('height', h.toFixed(1)); svg.style.height = h.toFixed(1) + 'px';
      svg.setAttribute('width', w.toFixed(1));  svg.style.width  = w.toFixed(1) + 'px';
      svg.querySelectorAll('path,circle,rect,ellipse,line,polyline,polygon')
         .forEach((el) => { el.style.vectorEffect = 'non-scaling-stroke'; });
    });
  });

  const header = (
    <React.Fragment>
      <div className="px-24" style={{ paddingTop: 64, paddingBottom: 8 }}>
        <h1 className="ff-display" style={{
          fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em',
          margin: 0, color: 'var(--ink)',
        }}>Beginner Foundations</h1>
        <div className="ff-mono" style={{
          fontSize: 'var(--t-label)', color: 'var(--ink-mute)', marginTop: 10,
          letterSpacing: '0.08em', textTransform: 'uppercase',
        }}>
          {done} of {unlocked} lessons complete
        </div>
      </div>

      <div style={{ height: 24 }}/>
    </React.Fragment>
  );
  const list = (
    <React.Fragment>

        {MODULES.map((mod, mi) => {
          const prereq = mi > 0 ? MODULES[mi - 1] : null;
          const allDone = mod.lessons.every(l => l.status === 'complete');
          const isActive = !mod.locked && !allDone;
          // Focused density: collapse locked/upcoming modules into a static
          // row, and completed modules into a tappable accordion row (expand to
          // review lessons, replay, and reach challenges).
          if (!isActive && !allDone) {
            return <CompactModuleRow key={mod.id} mod={mod} prereq={prereq}/>;
          }
          // Module Brew Challenge — the only challenge shown on Path.
          const moduleChallenge = window.brewForModule ? window.brewForModule(mod.id) : null;
          let challengeState = 'locked';
          if (moduleChallenge) {
            const allDone = mod.lessons.every(l => l.status === 'complete');
            // Active wins over completed: a replay of an already-earned
            // challenge shows live progress on the Path, not the recap state.
            if (brewActiveId === moduleChallenge.id) challengeState = 'active';
            else if (brewCompleted && brewCompleted.has(moduleChallenge.id)) challengeState = 'completed';
            else if (allDone) challengeState = 'available';
            if (brewPathMode && brewPathMode !== 'auto' && mod.id === 'm1') challengeState = brewPathMode;
          }
          const canCollapse = allDone && !mod.locked;
          const open = !canCollapse || !!expandedMods[mod.id];
          return (
          <div key={mod.id} className="px-24" style={{ marginBottom: 20 }}>
            <button
              onClick={() => { if (canCollapse) { toggleMod(mod.id); return; } }}
              disabled={mod.locked || !canCollapse}
              style={{
                width: '100%', appearance: 'none', border: 'none', background: 'transparent',
                cursor: 'default', textAlign: 'left', padding: 0, marginBottom: 0,
                display: 'block',
              }}>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 12 }}>
                <span data-mglyph="" style={{ display: 'inline-flex', justifyContent: 'center', width: 32, flexShrink: 0 }}>
                {window.CatGlyph
                  ? <window.CatGlyph cat={mod.glyph} size={26} color={mod.locked ? 'var(--ink-mute)' : 'var(--accent)'}/>
                  : <FlavorWheel size={22} filled={0} stroke={1}/>}
                </span>
                <h2 className="ff-display" style={{
                  flex: 1, minWidth: 0,
                  fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.01em',
                  margin: 0, color: mod.locked ? 'var(--ink-mute)' : 'var(--ink)',
                }}>{mod.title}</h2>
                {mod.locked ? (
                  <span className="trail"><window.LockMark size={13}/></span>
                ) : canCollapse ? (
                  <span style={{ display: 'inline-flex', alignItems: 'center', gap: 9, flexShrink: 0 }}>
                    <span className="trail"><svg width="11" height="7" viewBox="0 0 12 8" aria-hidden="true" style={{ transition: 'transform 320ms cubic-bezier(0.4, 0, 0.2, 1)', transform: open ? 'rotate(180deg)' : 'none' }}><path d="M1 1l5 5 5-5" fill="none" stroke="var(--ink-mute)" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg></span>
                  </span>
                ) : null}
              </div>
              {mod.locked && prereq && (
                <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.1em', color: 'var(--ink-mute)', textTransform: 'uppercase', marginTop: 8, marginLeft: 44 }}>Finish {prereq.title} to unlock</div>
              )}
            </button>

            <div style={{ display: 'grid', gridTemplateRows: open ? '1fr' : '0fr', transition: 'grid-template-rows 320ms cubic-bezier(0.4, 0, 0.2, 1)' }}>
              <div style={{ overflow: 'hidden', minHeight: 0, paddingTop: 8 }}>
              {mod.lessons.map((lesson) => {
                const status = lesson.status;
                const isLocked = status === 'locked' || mod.locked;
                const isCurrent = status === 'current' && !mod.locked;
                const isComplete = status === 'complete';
                // Only a lesson with a stored score can claim mastery. Done-but-
                // unscored (imported / legacy progress) stays deliberately neutral:
                // an empty muted bean, never a full sage one.
                const scored = isComplete && lesson.masteryPct != null;
                const mastery = scored ? (lesson.mastery || 'mastered') : null;
                const mMeta = (window.LESSON_STATES || {})[mastery] || null;
                const needsPractice = mastery === 'needs-practice';
                // The bean node IS the gauge: it fills to the best-score ratio, so
                // mastery reads as "how full" instead of a word in the margin.
                const filled = scored ? Math.max(12, Math.round(lesson.masteryPct * 100))
                  : (isCurrent ? 45 : 0);
                const nodeColor = isComplete && !scored ? 'var(--ink-mute)'
                  : (isCurrent || needsPractice ? 'var(--accent)' : 'var(--sage)');
                return (
                  <React.Fragment key={lesson.id}>
                  <button type="button"
                       className={'lesson-row' + (isLocked ? ' locked' : '') + (isCurrent ? ' current' : '')}
                       disabled={isLocked}
                       onClick={() => !isLocked && onLesson(lesson.id)}>
                    <span className="path-node">
                      <FlavorWheel size={20} filled={filled} total={100} stroke={1}
                                   color={nodeColor}/>
                    </span>
                    <div style={{ minWidth: 0, position: 'relative' }}>
                      <div className="title">{lesson.title}</div>
                      {isCurrent && (
                        <div className="ff-mono" style={{ position: 'absolute', top: '100%', left: 0, fontSize: 'var(--t-micro)', letterSpacing: '0.18em', color: 'var(--accent)', textTransform: 'uppercase', marginTop: 2, lineHeight: 1 }}>CURRENT</div>
                      )}
                    </div>
                    {isLocked ? (
                      <div className="meta" style={{ justifySelf: 'end' }}>
                        <span className="trail"><window.LockMark size={13} label="Locked"/></span>
                      </div>
                    ) : needsPractice && mMeta ? (
                      <div className="meta" style={{ color: 'var(--accent)', justifySelf: 'end' }}>{mMeta.short}</div>
                    ) : isCurrent ? (
                      <div className="meta continue">
                        <span className="trail"><window.Chevron w={6} h={10} color="currentColor" opacity={1}/></span>
                      </div>
                    ) : null}
                  </button>
                  {(() => {
                    // Lesson Brew Challenge sub-row: only once the lesson is done
                    // and the challenge is in play (active / saved / completed).
                    const lc = window.brewForLesson ? window.brewForLesson(lesson.id) : null;
                    if (!lc || !isComplete) return null;
                    let lcState = null;
                    if (brewActiveId === lc.id) lcState = 'active';
                    else if (brewCompleted && brewCompleted.has(lc.id)) lcState = 'completed';
                    else if (brewSaved && brewSaved.has(lc.id)) lcState = 'saved';
                    else lcState = 'available';
                    return window.PathChallengeNode
                      ? <window.PathChallengeNode challenge={lc} state={lcState} onAction={onBrewAction}/>
                      : null;
                  })()}
                  </React.Fragment>
                );
              })}
              {moduleChallenge && challengeState !== 'locked' && window.PathChallengeNode && (
                <window.PathChallengeNode challenge={moduleChallenge} state={challengeState} onAction={onBrewAction}/>
              )}
              </div>
            </div>
          </div>
          );
        })}

        <ComingSoonPath compact />
    </React.Fragment>
  );
  return (
    <div className="screen slide-in" data-screen-label="Path">
      <div className="scroll" ref={listRef} style={{ paddingBottom: 120 }}>
        {header}
        {list}
      </div>
    </div>
  );
}

// ───────────────────────────────────────────────────────────
// CARDS TAB
// ───────────────────────────────────────────────────────────
function CardsTab({ onOpen, brewCompleted }) {
  // COLLECTION is collectibles only — the training guides live in TRAINING_CARDS.
  const collectibles = COLLECTION;
  const earned = collectibles.filter(c => c.earned).length;
  const stampedFor = (c) => {
    const ch = c.earned && window.brewForCard ? window.brewForCard(c.id) : null;
    return !!(ch && brewCompleted && brewCompleted.has(ch.id));
  };
  // A challenge is on offer when the card is earned, has a linked challenge, and it isn't stamped yet.
  const challengeOpen = (c) => {
    const ch = c.earned && window.brewForCard ? window.brewForCard(c.id) : null;
    return !!(ch && !(brewCompleted && brewCompleted.has(ch.id)));
  };
  return (
    <div className="screen slide-in" data-screen-label="Cards">
      <div className="scroll" style={{ paddingBottom: 120 }}>
        <div className="px-24" style={{ paddingTop: 24 }}>
          <h1 className="ff-display" style={{
            fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em',
            margin: 0, color: 'var(--ink)',
          }}>Collection</h1>
          <div className="ff-mono" style={{
            fontSize: 'var(--t-label)', color: 'var(--ink-mute)', marginTop: 8,
            letterSpacing: '0.08em', textTransform: 'uppercase',
          }}>
            {earned} of {collectibles.length}
          </div>
        </div>

        <div className="px-24" style={{ paddingTop: 24 }}>
          <div className="cards-grid">
            {(() => {
              const firstLockedIdx = collectibles.findIndex(c => !c.earned);
              return collectibles.map((c, i) => {
                if (c.earned) return <CollectionCard key={c.id} card={c} index={i} total={collectibles.length} onOpen={onOpen} stamped={stampedFor(c)} challengeOpen={challengeOpen(c)}/>;
                // Preview the very next card as a locked teaser so the grid stays consistent.
                if (i === firstLockedIdx) return <CollectionCard key={c.id} card={c} index={i} total={collectibles.length} onOpen={onOpen} stamped={false}/>;
                return null;
              });
            })()}
          </div>
          {(collectibles.length - earned) > 0 && (
            <div style={{
              marginTop: 16, padding: '20px 18px',
              border: '1px dashed var(--rule)', borderRadius: 14,
              display: 'flex', alignItems: 'center', gap: 14,
              background: 'color-mix(in oklab, var(--surface) 55%, var(--bg))',
            }}>
              <span style={{ width: 40, height: 40, flexShrink: 0, borderRadius: 12, display: 'grid', placeItems: 'center', background: 'var(--bg)', border: '1px solid var(--rule)' }}>
                <IconLock/>
              </span>
              <div style={{ minWidth: 0 }}>
                <div style={{ fontSize: 'var(--t-body)', fontWeight: 500, color: 'var(--ink)' }}>{collectibles.length - earned} more to collect</div>
                <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 2, textWrap: 'pretty' }}>Finish lessons to reveal new cards.</div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

// ── Card artwork variants ──────────────────────────────────
function CardArtBotanical() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      {/* stem */}
      <path d="M50 16 Q49 30 47 50" fill="none" stroke="var(--sage)" strokeWidth="1.4" strokeLinecap="round"/>
      {/* leaf */}
      <path d="M50 22 Q63 16 70 22 Q66 32 50 30 Z"
            fill="var(--sage)" fillOpacity="0.32"
            stroke="var(--sage)" strokeWidth="1.2" strokeLinejoin="round"/>
      <path d="M50 25 L68 23" stroke="var(--sage)" strokeWidth="0.7" opacity="0.6"/>
      {/* cherry */}
      <circle cx="44" cy="62" r="16" fill="var(--berry)"/>
      <ellipse cx="38" cy="56" rx="6" ry="3.5" fill="var(--berry)" fillOpacity="0.55"/>
      <ellipse cx="39" cy="55" rx="3" ry="1.6" fill="var(--cream)" fillOpacity="0.55"/>
      {/* twig nub */}
      <circle cx="47" cy="50" r="2" fill="var(--sage)"/>
    </svg>
  );
}

function CardArtMap() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      {/* latitude lines */}
      <path d="M4 30 L96 30" stroke="var(--rule)" strokeWidth="1" strokeDasharray="3 3"/>
      <path d="M4 50 L96 50" stroke="var(--accent)" strokeWidth="1.6"/>
      <path d="M4 70 L96 70" stroke="var(--rule)" strokeWidth="1" strokeDasharray="3 3"/>
      {/* labels */}
      <text x="6" y="27" fontSize="6" fill="var(--ink-mute)" fontFamily="IBM Plex Mono">25°N</text>
      <text x="6" y="48" fontSize="6" fill="var(--accent)" fontFamily="IBM Plex Mono">EQ</text>
      <text x="6" y="78" fontSize="6" fill="var(--ink-mute)" fontFamily="IBM Plex Mono">25°S</text>
      {/* "continent" blobs along equator */}
      <path d="M22 44 Q28 38 34 44 Q38 53 32 58 Q24 58 22 52 Z" fill="var(--sage)" opacity="0.65"/>
      <path d="M52 42 Q62 38 66 48 Q62 56 54 56 Q48 50 52 42 Z" fill="var(--sage)" opacity="0.6"/>
      <path d="M76 44 Q86 42 88 50 Q84 58 78 56 Q72 50 76 44 Z" fill="var(--sage)" opacity="0.55"/>
      {/* pins */}
      <circle cx="28" cy="50" r="1.8" fill="var(--accent)"/>
      <circle cx="58" cy="50" r="1.8" fill="var(--accent)"/>
      <circle cx="82" cy="50" r="1.8" fill="var(--accent)"/>
    </svg>
  );
}

function CardArtSpecimen() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      {/* double border */}
      <rect x="5" y="10" width="90" height="80" fill="none" stroke="var(--rule)" strokeWidth="1"/>
      <rect x="9" y="14" width="82" height="72" fill="none" stroke="var(--cream)" strokeWidth="0.6" opacity="0.35"/>
      {/* big type-as-art */}
      <text x="50" y="46" fontSize="26" fill="var(--ink)" fontFamily="Fraunces"
            textAnchor="middle" fontStyle="italic">Coffea</text>
      <text x="50" y="60" fontSize="11" fill="var(--accent)" fontFamily="IBM Plex Mono"
            textAnchor="middle" letterSpacing="2.4">ARABICA</text>
      <text x="50" y="76" fontSize="9" fill="var(--ink-mute)" fontFamily="IBM Plex Mono"
            textAnchor="middle" letterSpacing="1.6">SPEC. NO. 03</text>
      {/* corner stamp marks */}
      <circle cx="14" cy="20" r="2.6" fill="none" stroke="var(--accent)" strokeWidth="0.7"/>
      <circle cx="86" cy="20" r="2.6" fill="none" stroke="var(--accent)" strokeWidth="0.7"/>
      <circle cx="14" cy="80" r="2.6" fill="none" stroke="var(--accent)" strokeWidth="0.7"/>
      <circle cx="86" cy="80" r="2.6" fill="none" stroke="var(--accent)" strokeWidth="0.7"/>
    </svg>
  );
}

// Locked-card silhouettes — three subtly different placeholder marks so the
// grid doesn't feel like 21 of the same tile.
function LockedSilhouette({ kind }) {
  if (kind === 'silhouette') {
    return (
      <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
        <ellipse cx="50" cy="55" rx="14" ry="18" transform="rotate(-18 50 55)"
                 fill="none" stroke="var(--ink-mute)" strokeWidth="1.2" strokeDasharray="3 4" opacity="0.5"/>
      </svg>
    );
  }
  if (kind === 'dot') {
    return (
      <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
        <circle cx="35" cy="55" r="3" fill="var(--ink-mute)" opacity="0.45"/>
        <circle cx="50" cy="55" r="3" fill="var(--ink-mute)" opacity="0.45"/>
        <circle cx="65" cy="55" r="3" fill="var(--ink-mute)" opacity="0.45"/>
      </svg>
    );
  }
  return (
    <div style={{
      width: '100%', height: '100%', display: 'flex',
      alignItems: 'center', justifyContent: 'center',
      color: 'var(--ink-mute)', fontFamily: 'IBM Plex Mono, monospace',
      fontSize: 'var(--t-title)', fontWeight: 400, opacity: 0.45,
    }}>?</div>
  );
}

// ── New custom card art ──
function CardArtDryingBed() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      <path d="M24 60 L20 82 M76 56 L80 82 M42 61 L40 82 M60 59 L62 82" fill="none" stroke="var(--rule)" strokeWidth="1.1" strokeLinecap="round" opacity="0.7"/>
      <path d="M18 56 L82 48 L82 56 L18 64 Z" fill="var(--surface-2)" stroke="var(--rule)" strokeWidth="1.3" strokeLinejoin="round"/>
      <g stroke="var(--rule)" strokeWidth="0.6" opacity="0.5">
        <line x1="28" y1="55" x2="26" y2="63"/><line x1="40" y1="53" x2="38" y2="61"/><line x1="52" y1="52" x2="50" y2="60"/><line x1="64" y1="50" x2="62" y2="58"/><line x1="76" y1="49" x2="74" y2="57"/>
      </g>
      <circle cx="34" cy="54" r="3" fill="var(--berry)"/><circle cx="46" cy="53" r="3" fill="var(--berry)" fillOpacity="0.85"/><circle cx="58" cy="51" r="3" fill="var(--art-ripe)"/><circle cx="69" cy="50" r="3" fill="var(--sage)"/>
    </svg>
  );
}
function CardArtFerment() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      <path d="M38 26 L38 32 Q30 48 30 68 Q30 82 50 82 Q70 82 70 68 Q70 48 62 32 L62 26 Z" fill="none" stroke="var(--ink-mute)" strokeWidth="1.4" strokeLinejoin="round"/>
      <path d="M31 56 Q30 82 50 82 Q70 82 69 56 Z" fill="var(--sage)" fillOpacity="0.3"/>
      <line x1="35" y1="26" x2="65" y2="26" stroke="var(--ink-mute)" strokeWidth="1.8" strokeLinecap="round"/>
      <g fill="none" stroke="var(--sage)" strokeWidth="1">
        <circle cx="44" cy="66" r="2.6"/><circle cx="55" cy="60" r="1.9"/><circle cx="47" cy="52" r="1.3"/><circle cx="58" cy="70" r="1.6"/>
      </g>
    </svg>
  );
}
function CardArtLabel() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      <path d="M32 28 L68 28 L70 82 L30 82 Z" fill="var(--surface-2)" stroke="var(--rule)" strokeWidth="1.3" strokeLinejoin="round"/>
      <path d="M32 28 L38 21 L62 21 L68 28 Z" fill="none" stroke="var(--rule)" strokeWidth="1.2" strokeLinejoin="round"/>
      <circle cx="50" cy="40" r="3" fill="none" stroke="var(--accent)" strokeWidth="1"/>
      <g strokeLinecap="round">
        <line x1="39" y1="54" x2="61" y2="54" stroke="var(--accent)" strokeWidth="1.8"/>
        <line x1="39" y1="62" x2="59" y2="62" stroke="var(--ink-mute)" strokeWidth="1"/>
        <line x1="39" y1="68" x2="61" y2="68" stroke="var(--ink-mute)" strokeWidth="1"/>
        <line x1="39" y1="74" x2="53" y2="74" stroke="var(--ink-mute)" strokeWidth="1"/>
      </g>
    </svg>
  );
}
function CardArtRoastScale() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      <line x1="18" y1="72" x2="82" y2="72" stroke="var(--rule)" strokeWidth="1"/>
      <ellipse cx="28" cy="52" rx="8" ry="11" fill="var(--art-roast-light)" stroke="var(--art-roast-light)" strokeWidth="1.2"/>
      <ellipse cx="50" cy="52" rx="8" ry="11" fill="var(--art-roast-mid)" stroke="var(--art-roast-mid)" strokeWidth="1.2"/>
      <ellipse cx="72" cy="52" rx="8" ry="11" fill="var(--art-roast-dark)" stroke="var(--art-roast-dark)" strokeWidth="1.2"/>
      <g stroke="var(--ink)" strokeWidth="0.8" opacity="0.4"><line x1="28" y1="43" x2="28" y2="61"/><line x1="50" y1="43" x2="50" y2="61"/><line x1="72" y1="43" x2="72" y2="61"/></g>
    </svg>
  );
}
function CardArtCrack() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      <g transform="rotate(-14 42 54)">
        <ellipse cx="42" cy="54" rx="15" ry="20" fill="var(--sage)" fillOpacity="0.25" stroke="var(--sage)" strokeWidth="1.4"/>
        <path d="M42 36 Q37 54 42 72" fill="none" stroke="var(--sage)" strokeWidth="1.2"/>
      </g>
      <g fill="none" stroke="var(--accent)" strokeLinecap="round">
        <path d="M64 44 Q70 54 64 64" strokeWidth="1.4"/>
        <path d="M72 38 Q82 54 72 70" strokeWidth="1.1" opacity="0.7"/>
        <path d="M80 33 Q92 54 80 75" strokeWidth="0.9" opacity="0.45"/>
      </g>
    </svg>
  );
}
function CardArtCalendar() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      <rect x="24" y="28" width="52" height="50" rx="3" fill="var(--surface)" stroke="var(--rule)" strokeWidth="1.3"/>
      <path d="M24 38 L24 31 Q24 28 27 28 L73 28 Q76 28 76 31 L76 38 Z" fill="var(--accent)" opacity="0.85"/>
      <line x1="36" y1="22" x2="36" y2="32" stroke="var(--ink-mute)" strokeWidth="1.6" strokeLinecap="round"/>
      <line x1="64" y1="22" x2="64" y2="32" stroke="var(--ink-mute)" strokeWidth="1.6" strokeLinecap="round"/>
      <g fill="var(--ink-mute)" opacity="0.4">
        <circle cx="34" cy="50" r="1.6"/><circle cx="43" cy="50" r="1.6"/><circle cx="52" cy="50" r="1.6"/><circle cx="61" cy="50" r="1.6"/>
        <circle cx="34" cy="60" r="1.6"/><circle cx="52" cy="60" r="1.6"/><circle cx="61" cy="60" r="1.6"/>
        <circle cx="34" cy="70" r="1.6"/><circle cx="43" cy="70" r="1.6"/>
      </g>
      <circle cx="43" cy="60" r="5" fill="none" stroke="var(--accent)" strokeWidth="1.5"/>
    </svg>
  );
}
function CardArtGauge() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      <line x1="40" y1="76" x2="60" y2="76" stroke="var(--ink-mute)" strokeWidth="1.4" strokeLinecap="round"/>
      <path d="M50 60 L44 76 L56 76 Z" fill="var(--ink-mute)" opacity="0.55"/>
      <line x1="24" y1="52" x2="76" y2="46" stroke="var(--ink)" strokeWidth="1.6" strokeLinecap="round"/>
      <line x1="50" y1="49" x2="50" y2="60" stroke="var(--ink)" strokeWidth="1.3"/>
      <circle cx="26" cy="55" r="5" fill="var(--accent)"/>
      <circle cx="74" cy="43" r="9" fill="none" stroke="var(--accent)" strokeWidth="1.4"/>
      <text x="50" y="90" fontSize="8" fill="var(--ink-mute)" fontFamily="IBM Plex Mono" textAnchor="middle" letterSpacing="1.5">1:16</text>
    </svg>
  );
}
function CardArtDroplet() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      <path d="M50 24 C60 42 67 52 67 62 A17 17 0 0 1 33 62 C33 52 40 42 50 24 Z" fill="var(--accent)" fillOpacity="0.2" stroke="var(--accent)" strokeWidth="1.4" strokeLinejoin="round"/>
      <path d="M43 60 A9 9 0 0 1 49 50" fill="none" stroke="var(--cream)" strokeWidth="1.1" strokeLinecap="round" opacity="0.7"/>
      <g fill="none" stroke="var(--ink-mute)" strokeLinecap="round" opacity="0.4">
        <path d="M28 84 Q50 77 72 84" strokeWidth="1"/>
        <path d="M36 91 Q50 86 64 91" strokeWidth="0.8"/>
      </g>
    </svg>
  );
}
function CardArtSpectrum() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      <path d="M22 68 A30 30 0 0 1 78 68" fill="none" stroke="var(--rule)" strokeWidth="2" strokeLinecap="round"/>
      <path d="M22 68 A30 30 0 0 1 41 41" fill="none" stroke="var(--art-sour)" strokeWidth="2.4" strokeLinecap="round"/>
      <path d="M59 41 A30 30 0 0 1 78 68" fill="none" stroke="var(--berry)" strokeWidth="2.4" strokeLinecap="round"/>
      <line x1="50" y1="68" x2="50" y2="40" stroke="var(--ink)" strokeWidth="1.6" strokeLinecap="round"/>
      <circle cx="50" cy="68" r="3" fill="var(--ink)"/>
      <text x="20" y="82" fontSize="6" fill="var(--art-sour)" fontFamily="IBM Plex Mono" letterSpacing="0.6">SOUR</text>
      <text x="63" y="82" fontSize="6" fill="var(--berry)" fontFamily="IBM Plex Mono" letterSpacing="0.6">BITTER</text>
    </svg>
  );
}

function CardArtScales() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      <line x1="50" y1="28" x2="50" y2="78" stroke="var(--ink-mute)" strokeWidth="1.4" strokeLinecap="round"/>
      <line x1="38" y1="82" x2="62" y2="82" stroke="var(--ink-mute)" strokeWidth="1.4" strokeLinecap="round"/>
      <line x1="24" y1="38" x2="76" y2="31" stroke="var(--ink)" strokeWidth="1.4" strokeLinecap="round"/>
      <circle cx="50" cy="34.5" r="2.4" fill="var(--accent)"/>
      <path d="M24 38 L18 54 M24 38 L30 54" fill="none" stroke="var(--ink-mute)" strokeWidth="0.8"/>
      <path d="M16 54 A8.5 8.5 0 0 0 32 54" fill="var(--surface-2)" stroke="var(--rule)" strokeWidth="1.2"/>
      <circle cx="21.5" cy="53" r="2" fill="var(--accent)"/><circle cx="26.5" cy="53" r="2" fill="var(--accent)" fillOpacity="0.7"/>
      <path d="M76 31 L70 47 M76 31 L82 47" fill="none" stroke="var(--ink-mute)" strokeWidth="0.8"/>
      <path d="M68 47 A8.5 8.5 0 0 0 84 47" fill="var(--surface-2)" stroke="var(--rule)" strokeWidth="1.2"/>
      <circle cx="76" cy="45" r="2.8" fill="none" stroke="var(--sage)" strokeWidth="1"/>
    </svg>
  );
}
function CardArtHourglass() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      <line x1="34" y1="24" x2="66" y2="24" stroke="var(--ink-mute)" strokeWidth="1.8" strokeLinecap="round"/>
      <line x1="34" y1="80" x2="66" y2="80" stroke="var(--ink-mute)" strokeWidth="1.8" strokeLinecap="round"/>
      <path d="M38 24 Q38 42 48 51 Q38 60 38 80 M62 24 Q62 42 52 51 Q62 60 62 80" fill="none" stroke="var(--ink-mute)" strokeWidth="1.4"/>
      <path d="M42 30 L58 30 L50.5 44 Z" fill="var(--accent)" fillOpacity="0.3"/>
      <line x1="50" y1="52" x2="50" y2="70" stroke="var(--accent)" strokeWidth="1.1" strokeDasharray="2 2.5"/>
      <path d="M41 78 Q50 64 59 78 Z" fill="var(--accent)" fillOpacity="0.55"/>
      <g fill="var(--ink-mute)" opacity="0.5"><circle cx="26" cy="88" r="1.3"/><circle cx="72" cy="87" r="1.1"/><circle cx="79" cy="90" r="1.4"/></g>
    </svg>
  );
}
function CardArtBurrs() {
  const spokes = (cx, cy) => Array.from({ length: 8 }).map((_, i) => {
    const a = i * Math.PI / 4 + Math.PI / 8;
    return <line key={i} x1={cx + Math.cos(a) * 7} y1={cy + Math.sin(a) * 7} x2={cx + Math.cos(a) * 13} y2={cy + Math.sin(a) * 13} stroke="var(--ink-mute)" strokeWidth="1.1" strokeLinecap="round"/>;
  });
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      <circle cx="37" cy="38" r="16" fill="var(--surface-2)" stroke="var(--ink-mute)" strokeWidth="1.3"/>
      {spokes(37, 38)}
      <circle cx="37" cy="38" r="4" fill="none" stroke="var(--ink-mute)" strokeWidth="1.1"/>
      <circle cx="63" cy="64" r="16" fill="var(--surface-2)" stroke="var(--ink-mute)" strokeWidth="1.3"/>
      {spokes(63, 64)}
      <circle cx="63" cy="64" r="4" fill="var(--accent)"/>
      <g fill="var(--accent)" opacity="0.7"><circle cx="55" cy="46" r="1.4"/><circle cx="60" cy="41" r="1.1"/><circle cx="51" cy="53" r="1.2"/></g>
    </svg>
  );
}

function CardArtGuide() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      <rect x="28" y="22" width="44" height="58" rx="5" fill="var(--surface-2)" stroke="var(--rule)" strokeWidth="1.3"/>
      <line x1="34" y1="23" x2="34" y2="79" stroke="var(--rule)" strokeWidth="1"/>
      <line x1="66" y1="22" x2="66" y2="80" stroke="var(--accent)" strokeWidth="1.6"/>
      <circle cx="50" cy="42" r="7" fill="none" stroke="var(--sage)" strokeWidth="1.2"/>
      <path d="M50 37 Q47.5 42 50 47" fill="none" stroke="var(--sage)" strokeWidth="1"/>
      <g stroke="var(--ink-mute)" strokeWidth="1" strokeLinecap="round" opacity="0.55">
        <line x1="40" y1="58" x2="60" y2="58"/><line x1="40" y1="64" x2="56" y2="64"/><line x1="40" y1="70" x2="60" y2="70"/>
      </g>
    </svg>
  );
}

// ── Bespoke art for the 15 later-lesson collectible cards ──
// Each radiates its single idea so no two tiles read the same.
function CardArtParticles() {
  // Grind-size gradient: boulders → dust, left to right — the speed dial itself.
  const col = (x, r, n) => Array.from({ length: n }).map((_, i) => (
    <circle key={x + '-' + i} cx={x + (i % 2) * r * 1.6 - r * 0.8} cy={30 + i * (44 / (n - 1))} r={r} fill="var(--art-roast-mid)" fillOpacity="0.8"/>
  ));
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      {col(24, 5, 3)}
      {col(44, 3.2, 5)}
      {col(62, 2, 7)}
      {col(78, 1.1, 10)}
      <path d="M22 86 L78 86" stroke="var(--accent)" strokeWidth="1.2" strokeLinecap="round"/>
      <path d="M78 86 L73 83 M78 86 L73 89" stroke="var(--accent)" strokeWidth="1.2" strokeLinecap="round"/>
      <text x="50" y="96" fontSize="5.5" fill="var(--accent)" fontFamily="IBM Plex Mono" textAnchor="middle" letterSpacing="0.5">MORE SURFACE</text>
    </svg>
  );
}
function CardArtBurrBlade() {
  // Burr's even grounds vs blade's dust-and-boulders — the comparison IS the idea.
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      {/* burr cone — ridged */}
      <path d="M18 26 L42 26 L34 48 L26 48 Z" fill="var(--surface-2)" stroke="var(--ink-mute)" strokeWidth="1.3" strokeLinejoin="round"/>
      <g stroke="var(--ink-mute)" strokeWidth="0.8" opacity="0.6"><line x1="24" y1="28" x2="28" y2="46"/><line x1="30" y1="28" x2="30" y2="46"/><line x1="36" y1="28" x2="32" y2="46"/></g>
      {/* its even output */}
      <g fill="var(--sage)">{Array.from({ length: 9 }).map((_, i) => <circle key={i} cx={22 + (i % 3) * 8} cy={60 + Math.floor(i / 3) * 8} r="1.8"/>)}</g>
      {/* blade propeller */}
      <circle cx="70" cy="36" r="13" fill="var(--surface-2)" stroke="var(--ink-mute)" strokeWidth="1.3"/>
      <path d="M70 36 Q62 30 60 36 Q68 39 70 36 Q78 42 80 36 Q72 33 70 36" fill="var(--ink-mute)" opacity="0.8"/>
      <circle cx="70" cy="36" r="1.6" fill="var(--accent)"/>
      {/* its uneven output: dust + boulders */}
      <g fill="var(--berry)"><circle cx="62" cy="62" r="3.6"/><circle cx="74" cy="66" r="2.8"/><circle cx="68" cy="74" r="0.9"/><circle cx="78" cy="58" r="0.8"/><circle cx="60" cy="72" r="0.7"/><circle cx="80" cy="73" r="1"/></g>
      <text x="28" y="90" fontSize="5.5" fill="var(--sage)" fontFamily="IBM Plex Mono" textAnchor="middle">EVEN</text>
      <text x="70" y="90" fontSize="5.5" fill="var(--berry)" fontFamily="IBM Plex Mono" textAnchor="middle">UNEVEN</text>
    </svg>
  );
}
function CardArtGrindDial() {
  // The grinder as the cup's first dial — a hand mill with an adjustment dial swept
  // fine→coarse. Distinct from CardArtBurrs (bare burr pair) by being the tool + dial.
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      {/* crank */}
      <path d="M50 22 Q66 14 74 22" fill="none" stroke="var(--ink-mute)" strokeWidth="1.6" strokeLinecap="round"/>
      <circle cx="76" cy="24" r="3" fill="var(--surface-2)" stroke="var(--ink-mute)" strokeWidth="1.2"/>
      <circle cx="50" cy="24" r="2.4" fill="var(--ink-mute)"/>
      {/* mill body */}
      <path d="M36 28 L64 28 L61 66 L39 66 Z" fill="var(--surface-2)" stroke="var(--ink-mute)" strokeWidth="1.4" strokeLinejoin="round"/>
      <line x1="37.5" y1="46" x2="62.5" y2="46" stroke="var(--rule)" strokeWidth="1"/>
      {/* adjustment dial — the point of the card */}
      <path d="M28 84 A22 22 0 0 1 72 84" fill="none" stroke="var(--rule)" strokeWidth="1.2"/>
      <g stroke="var(--ink-mute)" strokeWidth="1" strokeLinecap="round" opacity="0.7">
        <line x1="30" y1="78" x2="33" y2="81"/><line x1="50" y1="70" x2="50" y2="74"/><line x1="70" y1="78" x2="67" y2="81"/>
      </g>
      <path d="M50 84 L38 74" stroke="var(--accent)" strokeWidth="1.8" strokeLinecap="round"/>
      <circle cx="50" cy="84" r="2.6" fill="var(--accent)"/>
      <text x="24" y="94" fontSize="5.5" fill="var(--ink-mute)" fontFamily="IBM Plex Mono" textAnchor="middle">FINE</text>
      <text x="76" y="94" fontSize="5.5" fill="var(--ink-mute)" fontFamily="IBM Plex Mono" textAnchor="middle">COARSE</text>
    </svg>
  );
}
function CardArtAltitude() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      {/* peak */}
      <path d="M18 78 L44 30 L60 54 L70 40 L84 78 Z" fill="var(--surface-2)" stroke="var(--ink-mute)" strokeWidth="1.3" strokeLinejoin="round"/>
      {/* snow cap */}
      <path d="M44 30 L36 45 Q44 41 51 46 L44 30 Z" fill="var(--cream)" opacity="0.6"/>
      {/* specialty elevation band */}
      <rect x="8" y="50" width="84" height="14" fill="var(--sage)" fillOpacity="0.16"/>
      <line x1="8" y1="50" x2="92" y2="50" stroke="var(--sage)" strokeWidth="1" strokeDasharray="3 3"/>
      <line x1="8" y1="64" x2="92" y2="64" stroke="var(--sage)" strokeWidth="1" strokeDasharray="3 3"/>
      <text x="10" y="48" fontSize="6" fill="var(--sage)" fontFamily="IBM Plex Mono">2200m</text>
      <text x="10" y="73" fontSize="6" fill="var(--sage)" fontFamily="IBM Plex Mono">1200m</text>
    </svg>
  );
}
function CardArtVarieties() {
  const sprig = (x, s, fill) => (
    <g transform={`translate(${x} 0)`}>
      <path d="M0 78 L0 44" stroke="var(--sage)" strokeWidth="1.2" strokeLinecap="round"/>
      <path d={`M0 ${58} Q${-7 * s} ${52} ${-11 * s} ${58} Q${-6 * s} ${64} 0 ${62} Z`} fill={fill} fillOpacity="0.4" stroke="var(--sage)" strokeWidth="1"/>
      <path d={`M0 ${50} Q${7 * s} ${44} ${11 * s} ${50} Q${6 * s} ${56} 0 ${54} Z`} fill={fill} fillOpacity="0.4" stroke="var(--sage)" strokeWidth="1"/>
      <circle cx="0" cy="42" r="2.4" fill="var(--berry)"/>
    </g>
  );
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      <line x1="14" y1="78" x2="86" y2="78" stroke="var(--rule)" strokeWidth="1"/>
      {sprig(28, 0.85, 'var(--sage)')}
      {sprig(50, 1, 'var(--sage)')}
      {sprig(72, 1.15, 'var(--art-ripe)')}
      <text x="50" y="90" fontSize="5.5" fill="var(--ink-mute)" fontFamily="IBM Plex Mono" textAnchor="middle" letterSpacing="0.4">TYPICA · BOURBON · GEISHA</text>
    </svg>
  );
}
function CardArtDrying() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      {/* sun */}
      <circle cx="72" cy="30" r="9" fill="var(--art-ripe)" fillOpacity="0.85"/>
      <g stroke="var(--art-ripe)" strokeWidth="1.1" strokeLinecap="round">
        <line x1="72" y1="13" x2="72" y2="18"/><line x1="88" y1="30" x2="83" y2="30"/><line x1="84" y1="42" x2="80" y2="38"/><line x1="60" y1="42" x2="64" y2="38"/>
      </g>
      {/* raised bed */}
      <path d="M14 70 L86 62 L86 70 L14 78 Z" fill="var(--surface-2)" stroke="var(--rule)" strokeWidth="1.2" strokeLinejoin="round"/>
      <path d="M22 78 L20 90 M46 75 L45 90 M70 71 L71 90" stroke="var(--rule)" strokeWidth="1" strokeLinecap="round" opacity="0.6"/>
      {/* cherries drying */}
      <g><circle cx="26" cy="66" r="2.6" fill="var(--berry)"/><circle cx="38" cy="65" r="2.6" fill="var(--berry)" fillOpacity="0.8"/><circle cx="50" cy="64" r="2.6" fill="var(--art-ripe)"/><circle cx="62" cy="63" r="2.6" fill="var(--sage)"/><circle cx="74" cy="62" r="2.6" fill="var(--sage)" fillOpacity="0.7"/></g>
      <text x="14" y="52" fontSize="6" fill="var(--ink-mute)" fontFamily="IBM Plex Mono">10–25 DAYS</text>
    </svg>
  );
}
function CardArtAnaerobic() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      {/* sealed tank */}
      <rect x="34" y="30" width="32" height="48" rx="5" fill="var(--surface-2)" stroke="var(--ink-mute)" strokeWidth="1.4"/>
      <rect x="38" y="26" width="24" height="8" rx="3" fill="var(--surface)" stroke="var(--ink-mute)" strokeWidth="1.3"/>
      {/* airlock valve */}
      <line x1="50" y1="26" x2="50" y2="16" stroke="var(--ink-mute)" strokeWidth="1.4" strokeLinecap="round"/>
      <circle cx="50" cy="14" r="3.4" fill="none" stroke="var(--accent)" strokeWidth="1.3"/>
      {/* liquid */}
      <path d="M35 56 Q50 60 65 56 L65 73 Q50 76 35 73 Z" fill="var(--sage)" fillOpacity="0.28"/>
      {/* bubbles rising */}
      <g fill="none" stroke="var(--sage)" strokeWidth="1">
        <circle cx="45" cy="62" r="2.4"/><circle cx="55" cy="55" r="1.8"/><circle cx="48" cy="48" r="1.2"/><circle cx="57" cy="66" r="1.5"/>
      </g>
      <text x="50" y="90" fontSize="6" fill="var(--ink-mute)" fontFamily="IBM Plex Mono" textAnchor="middle" letterSpacing="1">NO OXYGEN</text>
    </svg>
  );
}
function CardArtDecaf() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      {/* bean */}
      <ellipse cx="42" cy="56" rx="16" ry="21" transform="rotate(-16 42 56)" fill="var(--art-roast-mid)" fillOpacity="0.85" stroke="var(--art-roast-dark)" strokeWidth="1.2"/>
      <path d="M42 37 Q36 56 42 75" transform="rotate(-16 42 56)" fill="none" stroke="var(--art-roast-dark)" strokeWidth="1.2"/>
      {/* caffeine molecules leaving */}
      <g fill="none" stroke="var(--accent)" strokeWidth="1.1">
        <circle cx="66" cy="40" r="3"/><circle cx="76" cy="52" r="2.4"/><circle cx="70" cy="64" r="2"/>
      </g>
      <g stroke="var(--accent)" strokeWidth="0.8" strokeDasharray="2 2" opacity="0.6">
        <path d="M56 46 L63 42"/><path d="M58 54 L73 52"/><path d="M56 62 L68 63"/>
      </g>
      <text x="50" y="90" fontSize="7" fill="var(--accent)" fontFamily="IBM Plex Mono" textAnchor="middle" letterSpacing="1">~97% OUT</text>
    </svg>
  );
}
function CardArtRoastCurve() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      {/* axes */}
      <line x1="18" y1="20" x2="18" y2="78" stroke="var(--rule)" strokeWidth="1"/>
      <line x1="18" y1="78" x2="86" y2="78" stroke="var(--rule)" strokeWidth="1"/>
      {/* temperature curve */}
      <path d="M18 74 Q40 70 56 50 Q70 34 84 26" fill="none" stroke="var(--art-roast-mid)" strokeWidth="2" strokeLinecap="round"/>
      {/* first crack marker */}
      <circle cx="56" cy="50" r="3" fill="var(--accent)"/>
      <g stroke="var(--accent)" strokeWidth="1" strokeLinecap="round"><line x1="56" y1="42" x2="56" y2="38"/><line x1="63" y1="47" x2="67" y2="45"/><line x1="49" y1="47" x2="45" y2="45"/></g>
      <text x="60" y="36" fontSize="6" fill="var(--accent)" fontFamily="IBM Plex Mono">1st crack</text>
      <text x="20" y="16" fontSize="6" fill="var(--ink-mute)" fontFamily="IBM Plex Mono">°C</text>
    </svg>
  );
}
function CardArtLightDark() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      <defs>
        <clipPath id="beanClipLD"><ellipse cx="50" cy="52" rx="20" ry="26"/></clipPath>
      </defs>
      <g clipPath="url(#beanClipLD)">
        <rect x="30" y="26" width="20" height="52" fill="var(--art-roast-light)"/>
        <rect x="50" y="26" width="20" height="52" fill="var(--art-roast-dark)"/>
      </g>
      <ellipse cx="50" cy="52" rx="20" ry="26" fill="none" stroke="var(--ink-mute)" strokeWidth="1.3"/>
      <path d="M50 26 Q44 52 50 78" fill="none" stroke="var(--cream)" strokeWidth="1.2" opacity="0.7"/>
      <text x="30" y="90" fontSize="6" fill="var(--art-roast-mid)" fontFamily="IBM Plex Mono" textAnchor="middle">LIGHT</text>
      <text x="70" y="90" fontSize="6" fill="var(--art-roast-dark)" fontFamily="IBM Plex Mono" textAnchor="middle">DARK</text>
    </svg>
  );
}
function CardArtCaffeine() {
  const cup = (cx, w, h, y, label, mg) => (
    <g>
      <path d={`M${cx - w} ${y} L${cx + w} ${y} L${cx + w - 2} ${y + h} L${cx - w + 2} ${y + h} Z`} fill="var(--surface-2)" stroke="var(--ink-mute)" strokeWidth="1.2" strokeLinejoin="round"/>
      <path d={`M${cx - w + 2} ${y + h * 0.35} L${cx + w - 2} ${y + h * 0.35} L${cx + w - 2} ${y + h} L${cx - w + 2} ${y + h} Z`} fill="var(--art-roast-mid)" fillOpacity="0.5"/>
      <text x={cx} y={y + h + 9} fontSize="6" fill="var(--ink-mute)" fontFamily="IBM Plex Mono" textAnchor="middle">{label}</text>
      <text x={cx} y={y - 4} fontSize="7" fill="var(--accent)" fontFamily="IBM Plex Mono" textAnchor="middle">{mg}</text>
    </g>
  );
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      {cup(32, 8, 16, 46, 'ESPRESSO', '63mg')}
      {cup(66, 13, 26, 36, 'DRIP', '95mg')}
    </svg>
  );
}
function CardArtGrindBrewer() {
  const dots = (cx, cy, n, r) => Array.from({ length: n }).map((_, i) => {
    const cols = Math.ceil(Math.sqrt(n));
    const dx = (i % cols - (cols - 1) / 2) * (r * 2.4);
    const dy = (Math.floor(i / cols) - (cols - 1) / 2) * (r * 2.4);
    return <circle key={i} cx={cx + dx} cy={cy + dy} r={r} fill="var(--art-roast-mid)" fillOpacity="0.8"/>;
  });
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      {/* fine */}
      <circle cx="28" cy="40" r="13" fill="var(--surface-2)" stroke="var(--rule)" strokeWidth="1"/>
      {dots(28, 40, 12, 1.4)}
      <text x="28" y="62" fontSize="5.5" fill="var(--ink-mute)" fontFamily="IBM Plex Mono" textAnchor="middle">ESPRESSO</text>
      {/* coarse */}
      <circle cx="72" cy="40" r="13" fill="var(--surface-2)" stroke="var(--rule)" strokeWidth="1"/>
      {dots(72, 40, 4, 3)}
      <text x="72" y="62" fontSize="5.5" fill="var(--ink-mute)" fontFamily="IBM Plex Mono" textAnchor="middle">PRESS</text>
      {/* contact-time arrow */}
      <path d="M30 76 L70 76" stroke="var(--accent)" strokeWidth="1.2" strokeLinecap="round"/>
      <path d="M70 76 L65 73 M70 76 L65 79" stroke="var(--accent)" strokeWidth="1.2" strokeLinecap="round"/>
      <text x="50" y="90" fontSize="5.5" fill="var(--accent)" fontFamily="IBM Plex Mono" textAnchor="middle" letterSpacing="0.5">LONGER CONTACT</text>
    </svg>
  );
}
function CardArtExtraction() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      {/* beaker */}
      <path d="M38 24 L38 40 L28 74 Q27 80 34 80 L66 80 Q73 80 72 74 L62 40 L62 24 Z" fill="none" stroke="var(--ink-mute)" strokeWidth="1.4" strokeLinejoin="round"/>
      <line x1="34" y1="24" x2="66" y2="24" stroke="var(--ink-mute)" strokeWidth="1.8" strokeLinecap="round"/>
      {/* target extraction band */}
      <path d="M31 62 Q50 65 69 62 L72 74 Q73 80 66 80 L34 80 Q27 80 28 74 Z" fill="var(--accent)" fillOpacity="0.28"/>
      <line x1="30" y1="62" x2="70" y2="62" stroke="var(--accent)" strokeWidth="1"/>
      <line x1="33" y1="52" x2="67" y2="52" stroke="var(--rule)" strokeWidth="0.8" strokeDasharray="2 2"/>
      <text x="50" y="49" fontSize="8" fill="var(--accent)" fontFamily="IBM Plex Mono" textAnchor="middle" letterSpacing="1">18–22%</text>
    </svg>
  );
}
function CardArtFilter() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      {/* cone dripper */}
      <path d="M28 26 L72 26 L52 62 L48 62 Z" fill="var(--surface-2)" stroke="var(--ink-mute)" strokeWidth="1.4" strokeLinejoin="round"/>
      {/* paper ridges */}
      <g stroke="var(--rule)" strokeWidth="0.7" opacity="0.6"><line x1="38" y1="30" x2="45" y2="58"/><line x1="50" y1="30" x2="50" y2="59"/><line x1="62" y1="30" x2="55" y2="58"/></g>
      {/* bed of grounds */}
      <path d="M34 34 Q50 40 66 34 L60 46 Q50 49 40 46 Z" fill="var(--art-roast-mid)" fillOpacity="0.5"/>
      {/* drip */}
      <path d="M50 62 C53 68 55 71 55 74 A5 5 0 0 1 45 74 C45 71 47 68 50 62 Z" fill="var(--accent)" fillOpacity="0.3" stroke="var(--accent)" strokeWidth="1.1"/>
      <text x="50" y="90" fontSize="6" fill="var(--ink-mute)" fontFamily="IBM Plex Mono" textAnchor="middle" letterSpacing="1">PAPER · METAL</text>
    </svg>
  );
}
function CardArtFirstCup() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      {/* saucer */}
      <ellipse cx="50" cy="80" rx="30" ry="5" fill="var(--rule)" opacity="0.5"/>
      {/* cup */}
      <path d="M30 46 L70 46 L65 72 Q64 76 58 76 L42 76 Q36 76 35 72 Z" fill="var(--surface-2)" stroke="var(--ink-mute)" strokeWidth="1.4" strokeLinejoin="round"/>
      {/* handle */}
      <path d="M70 50 Q80 52 79 60 Q78 67 68 67" fill="none" stroke="var(--ink-mute)" strokeWidth="1.4"/>
      {/* coffee + bloom */}
      <ellipse cx="50" cy="47" rx="19" ry="4.5" fill="var(--art-roast-dark)"/>
      <ellipse cx="50" cy="46" rx="11" ry="2.6" fill="var(--art-roast-light)" fillOpacity="0.6"/>
      {/* steam */}
      <g fill="none" stroke="var(--accent)" strokeWidth="1.1" strokeLinecap="round" opacity="0.7">
        <path d="M43 38 Q39 33 43 28 Q47 23 43 18"/>
        <path d="M57 38 Q53 33 57 28 Q61 23 57 18"/>
      </g>
    </svg>
  );
}

function CardArtShot() {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      {/* pressure arc + needle: the one thing that makes it espresso */}
      <path d="M26 34 A24 24 0 0 1 74 34" fill="none" stroke="var(--rule)" strokeWidth="1.4" strokeLinecap="round"/>
      <g stroke="var(--rule)" strokeWidth="1"><path d="M26 34 v-4"/><path d="M50 10 v-0"/><path d="M74 34 v-4"/></g>
      <path d="M50 34 L64 22" fill="none" stroke="var(--accent)" strokeWidth="1.8" strokeLinecap="round"/>
      <circle cx="50" cy="34" r="2.4" fill="var(--accent)"/>
      {/* portafilter spout */}
      <path d="M38 42 L62 42 L57 54 L43 54 Z" fill="var(--surface-2)" stroke="var(--ink-mute)" strokeWidth="1.4" strokeLinejoin="round"/>
      <path d="M47 54 L53 54 L52 60 L48 60 Z" fill="var(--ink-mute)" opacity="0.55"/>
      {/* stream */}
      <path d="M50 60 L50 70" stroke="var(--art-roast-dark)" strokeWidth="2.2" strokeLinecap="round"/>
      {/* glass with crema band on top */}
      <path d="M36 70 L64 70 L60 88 Q59 90 56 90 L44 90 Q41 90 40 88 Z" fill="var(--surface-2)" stroke="var(--ink-mute)" strokeWidth="1.4" strokeLinejoin="round"/>
      <path d="M37.5 74 L62.5 74 L60.5 82 L39.5 82 Z" fill="var(--art-roast-dark)"/>
      <path d="M36.5 70.6 L63.5 70.6 L62.7 74 L37.3 74 Z" fill="var(--art-roast-light)" fillOpacity="0.85"/>
    </svg>
  );
}

// ── Module Field Guides — one cohesive booklet family, a distinct
// emblem + spine colour per module so all five read uniquely. ──
function GuideCard({ tint, num, children }) {
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      <rect x="33" y="20" width="42" height="60" rx="4" fill="var(--surface)" stroke="var(--rule)" strokeWidth="1" opacity="0.55"/>
      <rect x="27" y="22" width="44" height="58" rx="4" fill="var(--surface-2)" stroke="var(--rule)" strokeWidth="1.3"/>
      <path d="M27 25 Q27 22 30 22 L34 22 L34 80 L30 80 Q27 80 27 77 Z" fill={tint} fillOpacity="0.9"/>
      <line x1="34" y1="22" x2="34" y2="80" stroke="var(--rule)" strokeWidth="0.8"/>
      <g transform="translate(52.5 45)">{children}</g>
      <text x="52.5" y="73" fontSize="6.5" fill="var(--ink-mute)" fontFamily="IBM Plex Mono" textAnchor="middle" letterSpacing="1.5">FIELD GUIDE {num}</text>
    </svg>
  );
}
function CardArtGuideBeans() {
  return (
    <GuideCard tint="var(--sage)" num="01">
      <ellipse cx="0" cy="0" rx="9" ry="12" fill="var(--sage)" fillOpacity="0.28" stroke="var(--sage)" strokeWidth="1.4"/>
      <path d="M0 -11 Q-3.5 0 0 11" fill="none" stroke="var(--sage)" strokeWidth="1.2"/>
      <circle cx="0" cy="-15" r="2" fill="var(--berry)"/>
    </GuideCard>
  );
}
function CardArtGuideProcess() {
  return (
    <GuideCard tint="var(--accent)" num="02">
      <path d="M0 -13 C6 -3 10 3 10 8 A10 10 0 0 1 -10 8 C-10 3 -6 -3 0 -13 Z" fill="var(--accent)" fillOpacity="0.2" stroke="var(--accent)" strokeWidth="1.3" strokeLinejoin="round"/>
      <path d="M-5 8 A6.5 6.5 0 0 1 -1 1.5" fill="none" stroke="var(--cream)" strokeWidth="1" strokeLinecap="round" opacity="0.7"/>
    </GuideCard>
  );
}
function CardArtGuideRoast() {
  return (
    <GuideCard tint="var(--art-roast-mid)" num="03">
      <ellipse cx="0" cy="0" rx="9" ry="12" fill="var(--art-roast-mid)" stroke="var(--art-roast-dark)" strokeWidth="1.2"/>
      <path d="M0 -11 Q-3.5 0 0 11" fill="none" stroke="var(--art-roast-dark)" strokeWidth="1.2"/>
      <g stroke="var(--accent)" strokeWidth="1" strokeLinecap="round" opacity="0.75"><path d="M0 -17 Q-3 -20 0 -23"/><path d="M6 -15 Q3 -18 6 -21"/></g>
    </GuideCard>
  );
}
function CardArtGuideGrind() {
  const spokes = Array.from({ length: 8 }).map((_, i) => {
    const a = i * Math.PI / 4 + Math.PI / 8;
    return <line key={i} x1={Math.cos(a) * 6} y1={Math.sin(a) * 6} x2={Math.cos(a) * 11} y2={Math.sin(a) * 11} stroke="var(--ink-mute)" strokeWidth="1.1" strokeLinecap="round"/>;
  });
  return (
    <GuideCard tint="var(--ink-mute)" num="04">
      <circle cx="0" cy="0" r="12" fill="var(--surface)" stroke="var(--ink-mute)" strokeWidth="1.3"/>
      {spokes}
      <circle cx="0" cy="0" r="3.4" fill="var(--accent)"/>
    </GuideCard>
  );
}
function CardArtGuideBrew() {
  return (
    <GuideCard tint="var(--berry)" num="05">
      <path d="M-11 -3 L11 -3 L8 12 Q7 15 3 15 L-3 15 Q-7 15 -8 12 Z" fill="var(--surface)" stroke="var(--ink-mute)" strokeWidth="1.3" strokeLinejoin="round"/>
      <path d="M11 0 Q18 2 17 8 Q16 12 9 12" fill="none" stroke="var(--ink-mute)" strokeWidth="1.2"/>
      <ellipse cx="0" cy="-3" rx="10" ry="2.6" fill="var(--art-roast-dark)"/>
      <g fill="none" stroke="var(--accent)" strokeWidth="1" strokeLinecap="round" opacity="0.7"><path d="M-4 -9 Q-7 -13 -4 -17"/><path d="M4 -9 Q7 -13 4 -17"/></g>
    </GuideCard>
  );
}

function CardArtLayers() {
  // The cherry in section — six concentric layers, seed split down the middle.
  const rings = [['var(--art-cherry-skin)', 40], ['var(--art-cherry-pulp)', 36.5], ['var(--art-cherry-gel)', 29],
    ['var(--art-cherry-parchment)', 25.5], ['var(--art-cherry-silverskin)', 22], ['var(--art-cherry-seed)', 19.5]];
  return (
    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%' }}>
      {rings.map(([c, r], i) => (
        <circle key={i} cx="50" cy="48" r={r} fill={c} stroke="rgba(27,22,20,0.24)" strokeWidth="0.7"/>
      ))}
      <line x1="50" y1="29" x2="50" y2="67" stroke="var(--art-seed-crease)" strokeWidth="1.6"/>
      <text x="50" y="96" fontSize="5.5" fill="var(--ink-mute)" fontFamily="IBM Plex Mono" textAnchor="middle" letterSpacing="0.4">SKIN · PULP · GEL · SEED</text>
    </svg>
  );
}

const CARD_ART = {
  botanical: CardArtBotanical,
  layers:    CardArtLayers,
  map:       CardArtMap,
  specimen:  CardArtSpecimen,
  dryingbed: CardArtDryingBed,
  ferment:   CardArtFerment,
  label:     CardArtLabel,
  roastscale:CardArtRoastScale,
  crack:     CardArtCrack,
  calendar:  CardArtCalendar,
  gauge:     CardArtGauge,
  droplet:   CardArtDroplet,
  spectrum:  CardArtSpectrum,
  scales:    CardArtScales,
  hourglass: CardArtHourglass,
  burrs:     CardArtBurrs,
  guide:     CardArtGuide,
  particles: CardArtParticles,
  burrblade: CardArtBurrBlade,
  grinddial: CardArtGrindDial,
  altitude:  CardArtAltitude,
  varieties: CardArtVarieties,
  drying:    CardArtDrying,
  anaerobic: CardArtAnaerobic,
  decaf:     CardArtDecaf,
  roastcurve:CardArtRoastCurve,
  lightdark: CardArtLightDark,
  caffeine:  CardArtCaffeine,
  grindbrewer:CardArtGrindBrewer,
  extraction:CardArtExtraction,
  filter:    CardArtFilter,
  firstcup:  CardArtFirstCup,
  shot:      CardArtShot,
  guideBeans:  CardArtGuideBeans,
  guideProcess:CardArtGuideProcess,
  guideRoast:  CardArtGuideRoast,
  guideGrind:  CardArtGuideGrind,
  guideBrew:   CardArtGuideBrew,
};

const CARD_TINT = {
  botanical: 'color-mix(in oklab, var(--surface) 88%, var(--sage) 12%)',
  layers:    'color-mix(in oklab, var(--surface) 90%, var(--berry) 10%)',
  map:       'color-mix(in oklab, var(--surface) 92%, var(--accent) 8%)',
  specimen:  'var(--surface-2)',
  training:  'color-mix(in oklab, var(--surface) 90%, var(--accent) 10%)',
  dryingbed: 'color-mix(in oklab, var(--surface) 88%, var(--sage) 12%)',
  ferment:   'color-mix(in oklab, var(--surface) 89%, var(--sage) 11%)',
  label:     'color-mix(in oklab, var(--surface) 91%, var(--accent) 9%)',
  roastscale:'color-mix(in oklab, var(--surface) 90%, var(--art-roast-mid) 10%)',
  crack:     'color-mix(in oklab, var(--surface) 90%, var(--sage) 10%)',
  calendar:  'color-mix(in oklab, var(--surface) 92%, var(--accent) 8%)',
  gauge:     'color-mix(in oklab, var(--surface) 90%, var(--accent) 10%)',
  droplet:   'color-mix(in oklab, var(--surface) 90%, var(--accent) 10%)',
  spectrum:  'color-mix(in oklab, var(--surface) 90%, var(--art-ripe) 10%)',
  scales:    'color-mix(in oklab, var(--surface) 91%, var(--accent) 9%)',
  hourglass: 'color-mix(in oklab, var(--surface) 90%, var(--art-roast-mid) 10%)',
  burrs:     'color-mix(in oklab, var(--surface) 92%, var(--ink) 8%)',
  guide:     'color-mix(in oklab, var(--surface) 88%, var(--sage) 12%)',
  particles: 'color-mix(in oklab, var(--surface) 90%, var(--art-roast-mid) 10%)',
  burrblade: 'color-mix(in oklab, var(--surface) 92%, var(--ink) 8%)',
  grinddial: 'color-mix(in oklab, var(--surface) 91%, var(--accent) 9%)',
  altitude:  'color-mix(in oklab, var(--surface) 90%, var(--sage) 10%)',
  varieties: 'color-mix(in oklab, var(--surface) 89%, var(--sage) 11%)',
  drying:    'color-mix(in oklab, var(--surface) 90%, var(--art-ripe) 10%)',
  anaerobic: 'color-mix(in oklab, var(--surface) 89%, var(--sage) 11%)',
  decaf:     'color-mix(in oklab, var(--surface) 90%, var(--art-roast-mid) 10%)',
  roastcurve:'color-mix(in oklab, var(--surface) 90%, var(--art-roast-mid) 10%)',
  lightdark: 'color-mix(in oklab, var(--surface) 90%, var(--art-roast-mid) 10%)',
  caffeine:  'color-mix(in oklab, var(--surface) 91%, var(--accent) 9%)',
  grindbrewer:'color-mix(in oklab, var(--surface) 92%, var(--ink) 8%)',
  extraction:'color-mix(in oklab, var(--surface) 90%, var(--accent) 10%)',
  filter:    'color-mix(in oklab, var(--surface) 90%, var(--accent) 10%)',
  firstcup:  'color-mix(in oklab, var(--surface) 90%, var(--art-roast-mid) 10%)',
  shot:      'color-mix(in oklab, var(--surface) 90%, var(--art-roast-dark) 10%)',
  guideBeans:  'color-mix(in oklab, var(--surface) 88%, var(--sage) 12%)',
  guideProcess:'color-mix(in oklab, var(--surface) 88%, var(--accent) 12%)',
  guideRoast:  'color-mix(in oklab, var(--surface) 88%, var(--art-roast-mid) 12%)',
  guideGrind:  'color-mix(in oklab, var(--surface) 90%, var(--ink) 10%)',
  guideBrew:   'color-mix(in oklab, var(--surface) 89%, var(--berry) 11%)',
};

function CollectionCard({ card, index, total, onOpen, stamped, challengeOpen }) {
  // `index` is the card's place in the whole catalogue, not in this grid — cards
  // unlock out of catalogue order, so the grid shows gaps (01, 04, 21). Printing
  // the total makes the number read as "where this sits in the set".
  const num = String(index + 1).padStart(2, '0') + (total ? ' / ' + total : '');
  if (!card.earned) {
    return (
      <div className="collect-card locked">
        <div className="cc-sub" style={{ opacity: 0.55 }}>—</div>
        <div style={{
          flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center',
          padding: '6px 4px',
        }}>
          <LockedSilhouette kind={card.kind || 'q'}/>
        </div>
        <div className="cc-sub" style={{ opacity: 0.55 }}>{num}</div>
      </div>
    );
  }
  const Art = CARD_ART[card.kind] || null;
  const isTraining = card.kind === 'training' && window.TrainingThumb;
  // Tint the card surface for variety — never too far from the base.
  const surfaceTint = CARD_TINT[card.kind] || 'var(--surface)';
  return (
    <div className="collect-card" onClick={() => onOpen(card)}
         style={{ background: surfaceTint }}>
      {stamped && (
        <span title="Challenge tried" style={{
          position: 'absolute', top: 10, right: 10, zIndex: 2,
          width: 26, height: 26, borderRadius: 999, display: 'grid', placeItems: 'center',
          background: 'color-mix(in oklab, var(--accent) 16%, var(--surface))',
          border: '1px solid color-mix(in oklab, var(--accent) 40%, var(--rule))',
        }}>
          <svg width="13" height="13" viewBox="0 0 14 14" fill="none">
            <path d="M3.6 7.4 L6.1 9.8 L10.6 4.6" stroke="var(--accent)" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </span>
      )}
      {!stamped && challengeOpen && (
        <span title="Challenge to earn — tap the card" className="ff-mono" style={{
          position: 'absolute', top: 10, right: 10, zIndex: 2,
          height: 20, padding: '0 8px', borderRadius: 999, display: 'grid', placeItems: 'center',
          fontSize: 'var(--t-micro)', letterSpacing: '0.1em', textTransform: 'uppercase', fontWeight: 500,
          color: 'var(--accent)',
          background: 'color-mix(in oklab, var(--accent) 8%, var(--surface))',
          border: '1px dashed color-mix(in oklab, var(--accent) 45%, var(--rule))',
        }}>Challenge</span>
      )}
      <div className="cc-sub">{isTraining ? 'TRAINING' : 'CARD ' + num}</div>
      <div style={{
        flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center',
        padding: '4px 0',
      }}>
        {isTraining ? <window.TrainingThumb variant={card.train}/> : (Art ? <Art/> : <FlavorStamp size={64} rotate={-6 + (index % 3) * 4}/>)}
      </div>
      <div>
        <div className="cc-title">{card.title}</div>
      </div>
    </div>
  );
}

function CardSheet({ card, open, onClose, brewCompleted, brewActive, onBrewTry, guideSaved, onToggleGuideSave }) {
  const isGuide = !!(card && card.kind === 'training');
  return (
    <>
      <div className={'sheet-backdrop' + (open ? ' open' : '')} onClick={onClose}/>
      <div className={'sheet' + (open ? ' open' : '')}>
        <div className="sheet-handle"/>
        <div className="sheet-content">
          {card && (
            <>
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
                <div style={{ flex: 1, minWidth: 0 }}>
                  {isGuide && <div className="smallcaps" style={{ marginBottom: 8 }}>VISUAL GUIDE</div>}
                  <h2 className="ff-display" style={{
                    fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em',
                    margin: 0, color: 'var(--ink)',
                  }}>{card.title}</h2>
                </div>
                {!isGuide && brewCompleted && window.TriedSeal && (
                  <div style={{ paddingTop: 6 }}><window.TriedSeal/></div>
                )}
                {isGuide && onToggleGuideSave && window.FavButton && (
                  <window.FavButton active={!!guideSaved} onClick={onToggleGuideSave}/>
                )}
              </div>

              {card.train && window.TrainingCard ? (
                <div style={{ margin: '18px 0 20px' }}>
                  <window.TrainingCard variant={card.train} inSheet/>
                </div>
              ) : (() => {
                const Art = CARD_ART[card.kind];
                return (
                  <div style={{
                    margin: '16px 0 20px',
                    height: 150,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    overflow: 'hidden',
                    background: CARD_TINT[card.kind] || 'var(--surface-2)',
                    borderRadius: 2,
                  }}>
                    <div style={{ width: '100%', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', transform: 'scale(1.15)' }}>
                      {Art ? <Art/> : <FlavorStamp size={72} rotate={-8}/>}
                    </div>
                  </div>
                );
              })()}

              <p style={{
                fontSize: 'var(--t-body)', lineHeight: 1.5, color: 'var(--ink-mute)',
                margin: '0 0 20px',
              }}>{card.summary}</p>

              {card.meta && (
                <div style={{ marginBottom: 24, display: 'flex', flexDirection: 'column', gap: 12 }}>
                  {card.meta.map(([k, v], i) => (
                    <div key={i} style={{ display: 'grid', gridTemplateColumns: '1fr auto', alignItems: 'baseline', gap: 16 }}>
                      <span className="smallcaps" style={{ color: 'var(--ink-mute)' }}>{k}</span>
                      <span className="ff-mono" style={{ fontSize: 'var(--t-body)', fontVariantNumeric: 'tabular-nums', color: 'var(--accent)' }}>{v}</span>
                    </div>
                  ))}
                </div>
              )}

              <div style={{ padding: '0 0 24px' }}>
                <div className="smallcaps" style={{ marginBottom: 8 }}>FACT</div>
                <p className="ff-display" style={{
                  fontSize: 'var(--t-heading)', lineHeight: 1.4, fontWeight: 400,
                  margin: 0, color: 'var(--ink)', textWrap: 'pretty',
                }}>{card.fact}</p>
              </div>

              {window.CardStampSection && (
                <window.CardStampSection card={card} completed={brewCompleted} active={brewActive} onTry={onBrewTry}/>
              )}
            </>
          )}
        </div>
      </div>
    </>
  );
}

// ───────────────────────────────────────────────────────────
// PROFILE TAB
// ───────────────────────────────────────────────────────────
function ProfileTab({ state, brewDone, brewTotal, frozenDays, onOpenStreak, onOpenTree, onOpenCustomize, onOpenSaved, onOpenDuel, onOpenBrew, onPractice, showDuel = true, savedCount, isLocked}) {
  const lock = isLocked || (() => false);
  const names = window.STAGE_NAMES || [];
  const pretty = (n) => n ? n.charAt(0) + n.slice(1).toLowerCase() : '';
  const allLessons = (window.MODULES || []).flatMap(m => m.lessons);
  const lessonsDone = allLessons.filter(l => l.status === 'complete').length;
  // Tree stage is core-course progress, not points.
  const stage = window.treeStageFromCore ? window.treeStageFromCore(lessonsDone) : 3;
  const stageName = pretty(names[stage - 1] || 'GROWING');
  const collection = window.COLLECTION || [];
  const cardsDone = collection.filter(c => c.earned).length;
  const modules = window.MODULES || [];
  const modulesDone = modules.filter(m => m.lessons.length && m.lessons.every(l => l.status === 'complete')).length;
  // Mastery rollup — a persistent home for what the moment-of-earning shows once.
  // Two states only: solid (best score at or above MASTERY_PASS) vs needs practice.
  const playedLessons = allLessons.filter(l => l.status === 'complete');
  const needPracticeCount = playedLessons.filter(l => l.mastery === 'needs-practice').length;
  return (
    <div className="screen slide-in" data-screen-label="Profile">
      <div className="scroll" style={{ paddingBottom: 120 }}>
        <div className="px-24" style={{ paddingTop: 24 }}>
          <h1 className="ff-display" style={{
            fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em',
            margin: 0, color: 'var(--ink)',
          }}>Hello, {(window.USER || {}).name || 'there'}.</h1>
        </div>

        {/* Tree hero — one clear “I’m growing” signal */}
        {(() => {
          const total = allLessons.length || 1;
          const pct = Math.max(0, Math.min(100, Math.round((lessonsDone / total) * 100)));
          return (
            <div className="px-24" style={{ paddingTop: 24 }}>
              <button onClick={onOpenTree} style={{
                width: '100%', appearance: 'none', textAlign: 'left', cursor: 'pointer',
                background: 'var(--surface)', border: '1px solid var(--rule)',
                borderRadius: 20, padding: 18,
                display: 'grid', gridTemplateColumns: 'auto 1fr', alignItems: 'center', gap: 18,
              }}>
                <div style={{ width: 96, height: 96, display: 'grid', placeItems: 'center', background: 'var(--bg)', border: '1px solid var(--rule)', borderRadius: 16, overflow: 'hidden', flexShrink: 0 }}>
                  <CoffeePersona stage={stage} size={82} animate={false} withGround={false}/>
                </div>
                <div style={{ minWidth: 0 }}>
                  <div className="smallcaps" style={{ color: 'var(--accent)', marginBottom: 6 }}>YOUR COFFEE TREE</div>
                  <div className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, letterSpacing: '-0.01em', color: 'var(--ink)', lineHeight: 1.05 }}>Stage {stage} · {stageName}</div>
                  <div style={{ height: 6, borderRadius: 999, background: 'var(--rule)', marginTop: 14, overflow: 'hidden' }}>
                    <div style={{ width: pct + '%', height: '100%', borderRadius: 999, background: 'var(--accent)' }}></div>
                  </div>
                  <div className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--ink-mute)', marginTop: 9 }}>
                    {lessonsDone >= total ? 'Fully grown' : `${lessonsDone} / ${total} core lessons`}
                  </div>
                </div>
              </button>
            </div>
          );
        })()}

        {/* Streak card — taps through to the full streak screen */}
        <div className="px-24" style={{ paddingTop: 24 }}>
          <button onClick={onOpenStreak}
                  style={{
                    width: '100%', appearance: 'none', textAlign: 'left', cursor: 'pointer',
                    background: 'var(--surface)', border: '1px solid var(--rule)',
                    borderRadius: 16, padding: 18,
                  }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 18 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 13 }}>
                <div style={{
                  width: 46, height: 46, borderRadius: 999,
                  background: state.streak > 0
                    ? 'color-mix(in oklab, var(--accent) 13%, var(--surface))'
                    : 'color-mix(in oklab, var(--ink-mute) 10%, var(--surface))',
                  display: 'grid', placeItems: 'center', flexShrink: 0,
                }}>
                  {/* Same mark the Streak screen puts inside its ring — the card is a preview of that screen, so it cannot invent its own glyph. */}
                  <SteamMark w={22} color={state.streak > 0 ? 'var(--accent)' : 'var(--ink-mute)'}/>
                </div>
                <div>
                  <div className="ff-mono" style={{ fontSize: 'var(--t-title)', fontWeight: 500, lineHeight: 1, letterSpacing: '-0.01em', color: 'var(--ink)' }}>{state.streak} days</div>
                  <div className="smallcaps" style={{ marginTop: 5 }}>CURRENT STREAK</div>
                </div>
              </div>
              <window.Chevron/>
            </div>
            <WeekStrip size="sm" frozen={frozenDays} streak={state.streak}/>
          </button>
        </div>

        {/* Progress summary — one quiet line under the tree hero. */}
        <div className="px-24" style={{ paddingTop: 14 }}>
          <div className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.06em', color: 'var(--ink-mute)', textTransform: 'uppercase', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7 }}>
            <PointsBean size={13} crease="var(--bg)"/>
            {`${lessonsDone} lesson${lessonsDone === 1 ? '' : 's'} · ${state.points} points`}
          </div>
        </div>

        {/* Mastery rollup — a home for mastery outside the moment it's earned. Deep-links to the Path to practice weak lessons. */}
        {playedLessons.length > 0 && (() => {
          const doneN = playedLessons.length;
          const solidN = doneN - needPracticeCount;
          const segs = [
            { n: solidN, c: 'var(--sage)' },
            { n: needPracticeCount, c: 'var(--accent)' },
          ].filter(s => s.n > 0);
          return (
          <div className="px-24" style={{ paddingTop: 12 }}>
            <button onClick={onPractice} style={{
              width: '100%', appearance: 'none', textAlign: 'left', cursor: 'pointer',
              background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 16,
              padding: 16, display: 'grid', gridTemplateColumns: '1fr auto', alignItems: 'center', gap: 16,
            }}>
              <div style={{ minWidth: 0, width: '100%' }}>
                <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: 10 }}>
                  <div className="smallcaps">LESSON PROGRESS</div>
                  <div className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.06em', color: 'var(--ink-mute)', whiteSpace: 'nowrap' }}>{doneN} / {allLessons.length} DONE</div>
                </div>
                <div style={{ display: 'flex', marginTop: 12, height: 8, borderRadius: 999, overflow: 'hidden', background: 'var(--bg)' }}>
                  {segs.map((s, i) => (
                    <div key={i} style={{ flex: s.n, background: s.c, borderRight: '1.5px solid var(--surface)' }}></div>
                  ))}
                  {allLessons.length - doneN > 0 && <div style={{ flex: allLessons.length - doneN }}></div>}
                </div>
                <div style={{ display: 'flex', gap: 16, marginTop: 12, flexWrap: 'nowrap' }}>
                  <span style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 'var(--t-support)', color: 'var(--ink)', whiteSpace: 'nowrap' }}>
                    <span style={{ width: 8, height: 8, borderRadius: 999, background: 'var(--sage)' }}></span>
                    <b style={{ fontWeight: 500 }}>{solidN}</b> solid
                  </span>
                  <span style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 'var(--t-support)', color: needPracticeCount > 0 ? 'var(--ink)' : 'var(--ink-mute)', whiteSpace: 'nowrap' }}>
                    <span style={{ width: 8, height: 8, borderRadius: 999, background: 'var(--accent)' }}></span>
                    <b style={{ fontWeight: 500 }}>{needPracticeCount}</b> need practice
                  </span>
                </div>
              </div>
              <window.Chevron/>
            </button>
          </div>
          );
        })()}

        {/* Brew Challenges — single lightweight progress stat */}
        {window.BrewChallengeStat && (
          <div className="px-24" style={{ paddingTop: 12 }}>
            <window.BrewChallengeStat done={brewDone || 0} total={brewTotal || 0} onOpen={onOpenBrew}/>
          </div>
        )}

        {/* Customize card — entry to the premium studio */}
        <div className="px-24" style={{ paddingTop: 12 }}>
          <button onClick={onOpenCustomize}
                  style={{
                    width: '100%', appearance: 'none', textAlign: 'left', cursor: 'pointer',
                    background: 'var(--surface)', border: '1px solid var(--rule)',
                    borderRadius: 16, padding: 16,
                    display: 'grid', gridTemplateColumns: 'auto 1fr auto', alignItems: 'center', gap: 14,
                  }}>
            <div style={{ width: 64, height: 64, flexShrink: 0, display: 'grid', placeItems: 'center', background: 'var(--bg)', border: '1px solid var(--rule)', borderRadius: 12, overflow: 'hidden' }}>
              {/* Locked: a dressed-up teaser. Unlocked: the user's own applied look. */}
              {lock('studio')
                ? <Roasty state="correct" size={56} hat="field" gear="glasses"/>
                : <Roasty state="correct" size={56}/>}
            </div>
            <div>
              <div className="smallcaps" style={{ color: 'var(--accent)', marginBottom: 5, display: 'flex', alignItems: 'center', gap: 8 }}>
                STUDIO
                {lock('studio') && window.PlusPill && <window.PlusPill/>}
              </div>
              <div className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, letterSpacing: '-0.01em', color: 'var(--ink)', lineHeight: 1.05 }}>Dress up Roasty</div>
              <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 3 }}>Hats, outfits and your plant</div>
            </div>
            <window.Chevron/>
          </button>
        </div>

        {/* Coffee Duel card — entry to the challenge flow */}
        {showDuel && (
        <div className="px-24" style={{ paddingTop: 12 }}>
          <button onClick={() => onOpenDuel && onOpenDuel('hub')}
                  style={{
                    width: '100%', appearance: 'none', textAlign: 'left', cursor: 'pointer',
                    background: 'var(--surface)', border: '1px solid var(--rule)',
                    borderRadius: 16, padding: 16,
                    display: 'grid', gridTemplateColumns: 'auto 1fr auto', alignItems: 'center', gap: 14,
                  }}>
            <div style={{ width: 64, height: 64, flexShrink: 0, display: 'grid', placeItems: 'center', background: 'var(--bg)', border: '1px solid var(--rule)', borderRadius: 12, overflow: 'hidden' }}>
              <Roasty state="correct" size={58} gear="sunglasses"/>
            </div>
            <div>
              <div className="smallcaps" style={{ color: 'var(--accent)', marginBottom: 5, display: 'flex', alignItems: 'center', gap: 8 }}>
                COFFEE DUEL
                {lock('duel') && window.PlusPill && <window.PlusPill/>}
              </div>
              <div className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, letterSpacing: '-0.01em', color: 'var(--ink)', lineHeight: 1.05 }}>Challenge a friend</div>
              <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 3 }}>Quick head-to-head quizzes</div>
            </div>
            <window.Chevron/>
          </button>
        </div>
        )}

        {/* Saved card — quick access to favorites */}
        <div className="px-24" style={{ paddingTop: 12 }}>
          <button onClick={onOpenSaved}
                  style={{
                    width: '100%', appearance: 'none', textAlign: 'left', cursor: 'pointer',
                    background: 'var(--surface)', border: '1px solid var(--rule)',
                    borderRadius: 16, padding: 16,
                    display: 'grid', gridTemplateColumns: 'auto 1fr auto', alignItems: 'center', gap: 14,
                  }}>
            <div style={{ width: 64, height: 64, flexShrink: 0, display: 'grid', placeItems: 'center', background: 'var(--bg)', border: '1px solid var(--rule)', borderRadius: 12 }}>
              {window.Bookmark && <window.Bookmark size={26} filled={true} color="var(--accent)"/>}
            </div>
            <div>
              <div className="smallcaps" style={{ color: 'var(--accent)', marginBottom: 5, display: 'flex', alignItems: 'center', gap: 8 }}>
                SAVED
                {lock('saved') && window.PlusPill && <window.PlusPill/>}
              </div>
              <div className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, letterSpacing: '-0.01em', color: 'var(--ink)', lineHeight: 1.05 }}>Your favorites</div>
              <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 3 }}>{savedCount || 0} saved to revisit</div>
            </div>
            <window.Chevron/>
          </button>
        </div>

        <div className="px-24" style={{ paddingTop: 22 }}>
          <div className="ff-mono" style={{
            fontSize: 'var(--t-micro)', letterSpacing: '0.14em', color: 'var(--ink-mute)',
            textTransform: 'uppercase',
          }}>
            Joined May 2026
          </div>
        </div>
      </div>
    </div>
  );
}

function ThemeRow({ theme, onTheme }) {
  return (
    <div style={{
      padding: '16px 0',
      borderBottom: '1px solid var(--rule)',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span style={{ fontSize: 'var(--t-body)', color: 'var(--ink)' }}>Theme</span>
      </div>
      <div style={{ display: 'flex', gap: 6, marginTop: 12 }}>
        {[['light', 'Light'], ['system', 'System'], ['dark', 'Dark']].map(([k, l]) => (
          <button key={k}
                  onClick={() => onTheme(k)}
                  className="ff-ui"
                  style={{
                    flex: 1,
                    appearance: 'none',
                    border: '1px solid ' + (theme === k ? 'var(--accent)' : 'var(--rule)'),
                    background: theme === k ? 'var(--accent)' : 'transparent',
                    color: theme === k ? 'var(--accent-ink)' : 'var(--ink)',
                    padding: '14px 8px', minHeight: 44,
                    borderRadius: 2,
                    fontSize: 'var(--t-label)',
                    fontWeight: 500,
                    letterSpacing: '0.08em',
                    textTransform: 'uppercase',
                    cursor: 'pointer',
                  }}>
            {l}
          </button>
        ))}
      </div>
    </div>
  );
}

// SettingsRow — alias of the one row component (NavRow, settings.jsx). Kept as a
// name because Settings call sites read better with it; it adds no behaviour, so
// the two can never drift apart again.
function SettingsRow(props) {
  const Row = window.NavRow;
  return Row ? <Row {...props}/> : null;
}

// ───────────────────────────────────────────────────────────
// TAB BAR
// ───────────────────────────────────────────────────────────
function TabBar({ active, onChange, isV1 = true }) {
  const tabs = [
    { id: 'learn',   label: 'TODAY',   Icon: IconCup   },
    { id: 'path',    label: 'PATH',    Icon: IconRoute },
    { id: 'atlas',   label: 'ATLAS',   Icon: IconGlobe },
    { id: 'cards',   label: 'CARDS',   Icon: IconCards },
    { id: 'profile', label: 'PROFILE', Icon: IconLeaf  },
  ].filter(t => !isV1 || t.id !== 'atlas'); // Atlas defers to v2
  return (
    <div className="tabbar" style={{ gridTemplateColumns: 'repeat(' + tabs.length + ', 1fr)' }}>
      {tabs.map(t => {
        const isActive = active === t.id;
        const Icon = t.Icon;
        return (
          <div key={t.id} className={'tab' + (isActive ? ' active' : '')}
               onClick={() => onChange(t.id)}>
            <Icon size={24} active={isActive}/>
            <span className="label">{t.label}</span>
          </div>
        );
      })}
    </div>
  );
}

// Globe / atlas tab glyph — matches the 24×24, stroke-1.6 icon family.
function IconGlobe({ size = 24, active, color = 'var(--accent)', mute = 'var(--ink-mute)' }) {
  const c = active ? color : mute;
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <circle cx="12" cy="12" r="8.5" stroke={c} strokeWidth="1.6"/>
      <ellipse cx="12" cy="12" rx="3.6" ry="8.5" stroke={c} strokeWidth="1.6"/>
      <path d="M3.6 9.5h16.8M3.6 14.5h16.8" stroke={c} strokeWidth="1.6" strokeLinecap="round"/>
      {active && <circle cx="12" cy="12" r="1.7" fill={c}/>}
    </svg>
  );
}
window.IconGlobe = IconGlobe;

// ───────────────────────────────────────────────────────────
// Shared nav icon family — ONE source of truth for the marks that
// recur across the app (Cup / Globe / Route / Cards / Leaf). Anything
// that needs one of these (e.g. DuelGlyph) pulls from here instead of
// re-drawing it, so the same concept is never drawn twice or at a
// different stroke weight. All are 24×24, stroke 1.6.
// ───────────────────────────────────────────────────────────
window.Icons = {
  Cup:   window.IconCup,
  Globe: IconGlobe,
  Route: window.IconRoute,
  Cards: window.IconCards,
  Leaf:  window.IconLeaf,
};

// ───────────────────────────────────────────────────────────
// MINI-GAMES — replayable, each with its own intro flow
// ───────────────────────────────────────────────────────────
const MINI_GAMES = [
  {
    id: 'g-match', kind: 'match', title: 'Match the facts',
    sub: 'ARABICA VS ROBUSTA', meta: '~2 MIN',
    blurb: 'Pair every fact with the right species before the board clears.',
    steps: ['Read a fact on the left', 'Tap the species it belongs to', 'Clear the board with no wrong drops'],
  },
  {
    id: 'g-flavor', kind: 'flavor', title: 'Name the flavor notes',
    sub: 'TASTING NOTES', meta: '~2 MIN',
    blurb: 'Read each tasting clue and name what you taste — pick the note that fits the cup.',
    steps: ['Read the tasting clue', 'Weigh the four notes', 'Pick the one that fits'],
  },
  {
    id: 'g-quiz', kind: 'quiz', title: 'True or false',
    sub: 'COFFEE BASICS', meta: '~1 MIN',
    blurb: 'Quick-fire statements about coffee. Decide whether each one is true or false.',
    steps: ['Read the statement', 'Choose true or false', 'See why it lands that way'],
  },
  {
    id: 'g-bagpick', kind: 'bagpick', title: 'Read the green bean',
    sub: 'WASHED, HONEY OR NATURAL', meta: '~2 MIN',
    blurb: 'Five unlabelled bags. Draw a sample, inspect the beans, and call the process from the look alone.',
    steps: ['Draw a sample from the bag', 'Inspect colour, centre cut and aroma', 'Call it — washed, honey or natural'],
  },
  {
    id: 'g-tastefix', kind: 'tastefix', title: 'Fix the cup',
    sub: 'DIAGNOSE AND DIAL IN', meta: '~2 MIN',
    blurb: 'A cup comes out wrong — read what’s off and pick the one change that pulls it back to balanced.',
    steps: ['Read what the cup tastes like', 'Pick the fix that balances it', 'Watch the cup react'],
  },
  {
    id: 'g-calibrate', kind: 'slider', title: 'Dial it in',
    sub: 'GRIND, RATIO, WATER, TIME', meta: '~2 MIN',
    blurb: 'Grind, ratio, temperature, time — drag each dial to where the answer actually lands.',
    steps: ['Read what you are setting', 'Drag the dial to your answer', 'Check it against the target zone'],
  },
  {
    id: 'g-sequence', kind: 'sequence', title: 'Put it in order',
    sub: 'BEAN TO CUP', meta: '~2 MIN',
    blurb: 'Five things, one right order. Farm to cup, skin to seed, first pour to drawdown.',
    steps: ['Read what is being ordered', 'Tap the items in sequence', 'Submit to see the right order'],
  },
];

// First screen of the game flow: what it is, how to play, then Play.
function GameIntroScreen({ game, onStart, onClose }) {
  if (!game) return null;
  return (
    <div className="screen slide-in" data-screen-label="Game intro" style={{ background: 'var(--bg)' }}>
      <div className="lesson-topbar" style={{ borderBottom: 'none', background: 'transparent' }}>
        <button className="close-btn" onClick={onClose} aria-label="Close">
          <window.CloseMark/>
        </button>
        <div/>
        <div/>
      </div>
      <div className="scroll" style={{ paddingTop: 108, display: 'flex', flexDirection: 'column' }}>
        <div className="px-24" style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
          <div className="smallcaps" style={{ marginBottom: 20 }}>MINI-GAME</div>

          <div style={{ display: 'flex', alignItems: 'center', gap: 18 }}>
            <div style={{
              width: 68, height: 68, borderRadius: 20, flexShrink: 0,
              border: '1px solid var(--rule)', background: 'var(--surface-2)',
              display: 'grid', placeItems: 'center',
            }}>
              <ReplayIcon kind={game.kind} size={34}/>
            </div>
            <h1 className="ff-display" style={{
              fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em',
              margin: 0, color: 'var(--ink)',
            }}>{game.title}</h1>
          </div>

          <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: '22px 0 0' }}>
            {game.blurb}
          </p>

          <div className="ff-mono" style={{
            fontSize: 'var(--t-label)', letterSpacing: '0.14em', color: 'var(--ink-mute)',
            textTransform: 'uppercase', marginTop: 18,
            display: 'flex', alignItems: 'center', gap: 12,
          }}>
            <span>{game.meta}</span>
            <span aria-hidden="true" style={{ opacity: 0.9 }}>·</span>
            <span>{((window.MINI_GAME_CONTENT || {})[game.id] || []).length} ROUNDS</span>
          </div>

          <div className="smallcaps" style={{ margin: '30px 0 14px' }}>HOW TO PLAY</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            {game.steps.map((s, i) => (
              <div key={i} style={{ display: 'flex', alignItems: 'baseline', gap: 14 }}>
                <span className="ff-mono" style={{
                  fontSize: 'var(--t-label)', letterSpacing: '0.1em', color: 'var(--accent)', flexShrink: 0,
                }}>{String(i + 1).padStart(2, '0')}</span>
                <span style={{ fontSize: 'var(--t-body)', lineHeight: 1.45, color: 'var(--ink)' }}>{s}</span>
              </div>
            ))}
          </div>

        </div>

        <div className="px-24" style={{ paddingTop: 20, paddingBottom: 24 }}>
          <button className="btn btn-primary" onClick={onStart}>Play</button>
        </div>
      </div>
    </div>
  );
}

window.ReplayIcon = ReplayIcon;
window.MINI_GAMES = MINI_GAMES;
window.GameIntroScreen = GameIntroScreen;
window.OnboardingWelcome = OnboardingWelcome;
window.OnboardingRoasty = OnboardingRoasty;
window.LearnTab = LearnTab;
window.DictHeaderButton = DictHeaderButton;
window.PathTab = PathTab;
window.CardsTab = CardsTab;
window.CardSheet = CardSheet;
window.ProfileTab = ProfileTab;
window.TabBar = TabBar;
window.FormRow = FormRow;
