// brew-challenge.jsx — Active Coffee Challenge feature.
// A Coffee Challenge is a small, optional real-life coffee task tied to a lesson
// or module. It never blocks learning, streaks, points, cards, or progress.
// This file owns: the challenge content model + lookups, the "challenge stamp"
// mark, the Today card (active / completed), the Log Result sheet, the lesson-
// completion suggestion block, and the full Module Coffee Challenge screen.

// ───────────────────────────────────────────────────────────
// CONTENT MODEL
// One capstone challenge per module — a real-world "try it" task, deliberately
// few so each is worth doing. Module challenges surface at module completion
// and on Path. (`cardId` can link a challenge to a collectible card's stamp;
// unused by the current module-only set.)
// ───────────────────────────────────────────────────────────
// One capstone challenge per module, plus a few important lesson challenges on
// the most hands-on lessons. `cardId` links a challenge to the collectible
// card whose "tried it for real" stamp it unlocks.
const BREW_CHALLENGES = [
  // Capstone "try it for real" challenge per module.
  { id: 'bc-m1', type: 'module', moduleId: 'm1', cardId: 'cM1',
    title: 'Two cups, two ratios',
    instruction: 'Brew the same coffee twice at two different ratios — try 1:15 and 1:17 — and compare the taste side by side.',
    effort: 'Next brews · 5 min',
    prompt: 'WHICH CUP WON?',
    reactions: ['Preferred 1:15', 'Preferred 1:17', 'Hard to tell'] },
  { id: 'bc-m2', type: 'module', moduleId: 'm2', cardId: 'cM2',
    title: 'Blind process test',
    instruction: 'Brew a washed and a natural of the same origin, then taste blind and guess which is which.',
    effort: 'Next brews · 5 min',
    prompt: 'HOW DID THE GUESS GO?',
    reactions: ['Called it', 'Got it backwards', 'Honestly a coin flip'] },
  { id: 'bc-m3', type: 'module', moduleId: 'm3', cardId: 'cM3',
    title: 'Light vs dark, same origin',
    instruction: 'Brew a light and a dark roast of a coffee you like and notice which one you reach for again.',
    effort: 'Next bags · 5 min',
    prompt: 'WHICH ONE WON?',
    reactions: ['Prefer lighter', 'Prefer darker', 'About the same'] },
  { id: 'bc-m4', type: 'module', moduleId: 'm4', cardId: 'cM4',
    title: 'One-step grind test',
    instruction: 'Brew the same coffee twice, one grind step apart, and taste which side extracts better.',
    effort: 'Next brews · 3 min',
    prompt: 'WHICH CUP WON?',
    reactions: ['Finer cup won', 'Coarser cup won', 'Hard to tell'] },
  { id: 'bc-m5', type: 'module', moduleId: 'm5', cardId: 'cM5',
    title: 'Fix one bad cup',
    instruction: 'Next time a cup is off, name it — sour and thin, or bitter and dry — and make exactly one change to fix it.',
    effort: 'Next brew · 3 min',
    prompt: 'DID THE FIX WORK?',
    reactions: ['Fixed it', 'A bit better', 'Still off'] },
  // A few important lesson challenges on the most hands-on lessons.
  { id: 'bc-m1l1', type: 'lesson', lessonId: 'm1l1', moduleId: 'm1', cardId: 'c1',
    title: 'Name the origin',
    instruction: 'Next time you open a bag of coffee, find the country it was grown in — and say it out loud.',
    effort: 'Next bag · 1 min',
    prompt: 'DID YOU FIND IT?',
    reactions: ['Found it', 'Bag didn’t say'] },
  { id: 'bc-m3l1', type: 'lesson', lessonId: 'm3l1', moduleId: 'm3', cardId: 'c-m3l1',
    title: 'Compare two roasts',
    instruction: 'Brew a light and a dark roast side by side and notice which tastes brighter and which tastes bolder.',
    effort: 'Next bags · 5 min',
    prompt: 'WHAT DID YOU NOTICE?',
    reactions: ['Lighter tasted brighter', 'Darker tasted bolder', 'About the same'] },
  { id: 'bc-m4l3', type: 'lesson', lessonId: 'm4l3', moduleId: 'm4', cardId: 'c-m4l3',
    title: 'Move one grind step',
    instruction: 'Change your grinder by one step, brew again, and see whether the cup moves the way you expected.',
    effort: 'Next brew · 3 min',
    prompt: 'DID THE CUP MOVE?',
    reactions: ['Moved as expected', 'Went the other way', 'Hard to tell'] },
  { id: 'bc-m5l1', type: 'lesson', lessonId: 'm5l1', moduleId: 'm5', cardId: 'c-m5l1',
    title: 'Dial your ratio',
    instruction: 'Brew your usual cup, then brew it again with a little more coffee. Notice which one you like better.',
    effort: 'Next brew · 3 min',
    prompt: 'WHICH DID YOU LIKE?',
    reactions: ['Preferred more coffee', 'Preferred less', 'About the same'] },
  { id: 'bc-m2l6', type: 'lesson', lessonId: 'm2l6', moduleId: 'm2', cardId: 'c-m2l6',
    title: 'Blind decaf test',
    instruction: 'Brew a decaf and a regular coffee, then taste them blind and see whether you can actually tell which is which.',
    effort: 'Next brews · 5 min',
    prompt: 'COULD YOU TELL?',
    reactions: ['Told them apart', 'Guessed wrong', 'Couldn’t tell'] },
  { id: 'bc-m4l6', type: 'lesson', lessonId: 'm4l6', moduleId: 'm4', cardId: 'c-m4l6',
    title: 'Fresh vs pre-ground',
    instruction: 'Grind half your dose now and leave the other half ground overnight. Brew both the same way tomorrow and taste them side by side.',
    effort: 'Next brews · 5 min',
    prompt: 'WHICH TASTED BETTER?',
    reactions: ['Fresh was clearly better', 'Close, but fresh won', 'Couldn’t tell'] },
  { id: 'bc-m5l6', type: 'lesson', lessonId: 'm5l6', moduleId: 'm5', cardId: 'c-m5l6',
    title: 'Brew it by the numbers',
    instruction: 'Brew one cup with a scale, a ratio and a timer — exactly as the lesson lays out. Just once, properly.',
    effort: 'Next brew · 5 min',
    prompt: 'HOW WAS THE CUP?',
    reactions: ['Best cup I’ve made', 'Better than usual', 'About the same'] },
];

// Total across the whole roadmap — powers the single Profile stat.
// Completed count comes from live state.
const BREW_TOTAL = BREW_CHALLENGES.length;

window.BREW_CHALLENGES = BREW_CHALLENGES;
window.BREW_TOTAL = BREW_TOTAL;
window.brewById       = (id)  => BREW_CHALLENGES.find(c => c.id === id) || null;
window.brewForLesson  = (lid) => BREW_CHALLENGES.find(c => c.type === 'lesson' && c.lessonId === lid) || null;
window.brewForModule  = (mid) => BREW_CHALLENGES.find(c => c.type === 'module' && c.moduleId === mid) || null;
window.brewForCard    = (cid) => BREW_CHALLENGES.find(c => c.cardId === cid) || null;
window.BREW_WINDOW_MS = 48 * 60 * 60 * 1000; // active on Today for 48h

// ───────────────────────────────────────────────────────────
// GLYPH — a steaming cup, the family mark for this feature.
// ───────────────────────────────────────────────────────────
function BrewCup({ size = 22, color = 'currentColor', stroke = 1.6, steam = true }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={{ flexShrink: 0 }} aria-hidden="true">
      {steam && (
        <g stroke={color} strokeWidth={stroke * 0.72} strokeLinecap="round" opacity="0.85">
          <path d="M9 5.2 Q7.6 3.6 9 2"/>
          <path d="M13.4 5.2 Q12 3.6 13.4 2"/>
        </g>
      )}
      <path d="M4.6 8.4 H17.2 l-0.9 8.1 A2.4 2.4 0 0 1 13.9 18.6 H7.9 A2.4 2.4 0 0 1 5.5 16.5 Z"
            stroke={color} strokeWidth={stroke} strokeLinejoin="round"/>
      <path d="M17.2 9.6 a2.9 2.9 0 0 1 0 5.4" stroke={color} strokeWidth={stroke} strokeLinecap="round"/>
    </svg>
  );
}
window.BrewCup = BrewCup;

// ───────────────────────────────────────────────────────────
// CHALLENGE STAMP — the postmark-style badge earned by completing a
// challenge. `done` toggles between an earned (inked) and a locked (faint,
// dashed) look. `press` runs the stamp-in animation once.
// ───────────────────────────────────────────────────────────
function BrewStamp({ size = 96, done = true, press = false }) {
  const ink = done ? 'var(--accent)' : 'var(--ink-mute)';
  const op = done ? 1 : 0.5;
  return (
    <div className={press ? 'stamp' : ''} style={{
      width: size, height: size, position: 'relative', flexShrink: 0,
      transform: 'rotate(-7deg)', opacity: op,
    }}>
      <svg width={size} height={size} viewBox="0 0 100 100" fill="none">
        <circle cx="50" cy="50" r="46" stroke={ink} strokeWidth={done ? 2 : 1.6}
                strokeDasharray={done ? 'none' : '4 5'}/>
        <circle cx="50" cy="50" r="39" stroke={ink} strokeWidth="1" opacity="0.55"/>
        {/* top + bottom arc ticks to sell the postmark */}
        <g stroke={ink} strokeWidth="1" opacity="0.7">
          <path d="M50 8 v-3 M32 12 l-1.2 -2.8 M68 12 l1.2 -2.8"/>
          <path d="M50 92 v3 M32 88 l-1.2 2.8 M68 88 l1.2 2.8"/>
        </g>
      </svg>
      <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
                    alignItems: 'center', justifyContent: 'center', gap: size * 0.03 }}>
        <BrewCup size={size * 0.34} color={ink} stroke={2} steam={done}/>
        <div className="ff-mono" style={{
          fontSize: size * 0.13, letterSpacing: '0.16em', color: ink,
          textTransform: 'uppercase', lineHeight: 1, textAlign: 'center',
        }}>{done ? 'Tried' : 'Locked'}</div>
      </div>
    </div>
  );
}
window.BrewStamp = BrewStamp;

// Compact "tried it for real" seal — sits beside the card title in the sheet.
// A quiet check-ring chip, not the full postmark.
function TriedSeal() {
  return (
    <span className="ff-mono" aria-label="Challenge tried" style={{
      display: 'inline-flex', alignItems: 'center', gap: 6, flexShrink: 0,
      border: '1px solid color-mix(in oklab, var(--accent) 50%, transparent)',
      borderRadius: 999, padding: '5px 10px 5px 7px',
      color: 'var(--accent)', fontSize: 'var(--t-micro)', letterSpacing: '0.14em',
      transform: 'rotate(-3deg)',
    }}>
      <svg width="13" height="13" viewBox="0 0 14 14" fill="none">
        <path d="M3.6 7.4 L6.1 9.8 L10.6 4.6" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
      TRIED
    </span>
  );
}
window.TriedSeal = TriedSeal;

// Shared button pair used on the Today card / suggestion / module screen.
// Two buttons only, always: a primary + a quiet secondary. Never three.
function BrewActions({ primaryLabel, secondaryLabel, onPrimary, onSecondary, inline = false }) {
  if (inline) {
    return (
      <div style={{ display: 'grid', gridTemplateColumns: '1fr auto', alignItems: 'center', gap: 10 }}>
        <button onClick={onPrimary} className="ff-ui" style={{
          appearance: 'none', border: 'none', cursor: 'pointer',
          background: 'var(--accent)', color: 'var(--accent-ink)',
          borderRadius: 12, padding: '13px 16px', fontSize: 'var(--t-body)', fontWeight: 500,
        }}>{primaryLabel}</button>
        <button onClick={onSecondary} className="ff-ui" style={{
          appearance: 'none', border: 'none', cursor: 'pointer', background: 'transparent',
          color: 'var(--ink-mute)', padding: '13px 6px', fontSize: 'var(--t-support)', fontWeight: 500,
        }}>{secondaryLabel}</button>
      </div>
    );
  }
  return (
    <>
      <button className="btn btn-primary" onClick={onPrimary}>{primaryLabel}</button>
      <div style={{ marginTop: 10 }}>
        <a className="btn btn-ghost" href="#" style={{ display: 'block', textAlign: 'center', textDecoration: 'none' }} onClick={(e) => { e.preventDefault(); onSecondary(); }}>
          {secondaryLabel}
        </a>
      </div>
    </>
  );
}
window.BrewActions = BrewActions;

// ───────────────────────────────────────────────────────────
// TODAY · ACTIVE COFFEE CHALLENGE CARD
// Placed below "Continue Learning", above "Up Next in Module".
// mode: 'active'  → live task with Log Result / Skip
//       'completed' → brief confirmation with the earned stamp + dismiss
// ───────────────────────────────────────────────────────────
// Postpone glyph — a clock, deliberately NOT the bookmark: the bookmark is the
// app-wide Favorites toggle and lands elsewhere. "Later" is temporal.
function LaterClock({ size = 18, color = 'currentColor' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 20 20" fill="none" aria-hidden="true">
      <circle cx="10" cy="10" r="7.25" stroke={color} strokeWidth="1.5"/>
      <path d="M10 6.2V10l3 2" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

function ActiveBrewCard({ challenge, mode, onLog, onSkip, onDismiss, onOpenCard, autoHide = true, showPoints = true, lessonPending = false }) {
  // Completed is a transient confirmation, not a pinned card: it lingers a few
  // seconds, fades, and clears itself. The lasting record is the Path node +
  // card stamp. The ✕ remains for immediate dismissal.
  const [leaving, setLeaving] = React.useState(false);
  React.useEffect(() => {
    if (mode !== 'completed' || !autoHide) return;
    setLeaving(false);
    const t1 = setTimeout(() => setLeaving(true), 4800);
    const t2 = setTimeout(() => onDismiss && onDismiss(), 5600);
    return () => { clearTimeout(t1); clearTimeout(t2); };
  }, [mode, challenge && challenge.id]);
  if (!challenge) return null;
  const accentTint = 'color-mix(in oklab, var(--accent) 8%, var(--surface))';
  const accentRule = 'color-mix(in oklab, var(--accent) 30%, var(--rule))';
  // Small mono metadata sits on a tinted card at 11px — pull it toward --ink so it
  // clears 4.5:1 in both moods rather than resting at the muted default.
  const metaInk = 'color-mix(in oklab, var(--ink-mute) 62%, var(--ink))';
  // Postpone: slide the card away immediately (no confirm ceremony), then hand
  // off to onSkip which parks it under For Later.
  const [parking, setParking] = React.useState(false);
  React.useEffect(() => { setParking(false); }, [challenge && challenge.id]);
  const onPostpone = () => { if (parking) return; setParking(true); setTimeout(() => { onSkip && onSkip(); setParking(false); }, 240); };

  if (mode === 'completed') {
    const card = challenge.cardId && window.findCard && window.findCard(challenge.cardId);
    return (
      <div className="px-24" style={{ paddingTop: 28 }}>
        <div className="brew-cheer" style={{
          position: 'relative', background: accentTint, border: '1px solid ' + accentRule,
          borderRadius: 14, padding: 20, display: 'flex', alignItems: 'center', gap: 18,
          opacity: leaving ? 0 : 1, transition: 'opacity 0.7s ease',
        }}>
          <button onClick={onDismiss} aria-label="Dismiss" style={{
            position: 'absolute', top: 0, right: 0, appearance: 'none', border: 'none',
            background: 'transparent', cursor: 'pointer', color: 'var(--ink-mute)',
            width: 44, height: 44, display: 'grid', placeItems: 'center', padding: 0,
          }}>
            <svg width="15" height="15" viewBox="0 0 15 15"><path d="M3 3l9 9M12 3l-9 9" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/></svg>
          </button>
          <div style={{ position: 'relative', flexShrink: 0 }}>
            <BrewStamp size={72} done press/>
            <div className="cheer-burst" aria-hidden="true">
              {[[-46, -34, '140deg'], [50, -28, '80deg'], [-30, 40, '200deg'], [42, 36, '120deg'], [0, -52, '60deg'], [-54, 4, '90deg'], [56, 6, '160deg'], [16, 50, '40deg'], [-16, -46, '110deg'], [30, -44, '70deg']].map((p, i) => (
                <span key={i} style={{ '--tx': p[0] + 'px', '--ty': p[1] + 'px', '--rot': p[2] }}></span>
              ))}
            </div>
          </div>
          <div style={{ minWidth: 0 }}>
            <div className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, letterSpacing: '-0.01em', color: 'var(--ink)', lineHeight: 1.1 }}>{challenge.title}</div>
            <div style={{ marginTop: 8, display: 'flex', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
              {showPoints && <span className="cheer-points">+5 PTS</span>}
              {card && (
                <button onClick={() => onOpenCard && onOpenCard(card)} className="ff-mono" style={{
                  appearance: 'none', border: 'none', background: 'transparent', cursor: 'pointer', padding: 0,
                  fontSize: 'var(--t-label)', letterSpacing: '0.1em', textTransform: 'uppercase',
                  color: 'var(--ink-mute)', display: 'inline-flex', alignItems: 'center', gap: 6,
                }}>
                  View card
                  <svg width="14" height="14" viewBox="0 0 16 16"><path d="M2.5 8H12M8 4l4.5 4L8 12" fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round"/></svg>
                </button>
              )}
            </div>
          </div>
        </div>
      </div>
    );
  }

  // mode === 'active'
  return (
    <div className="px-24" style={{ paddingTop: 28 }}>
      <div className="smallcaps" style={{ marginBottom: 28, color: 'var(--accent-text)', display: 'flex', alignItems: 'center', gap: 8 }}>
        <BrewCup size={15} color="var(--accent)" aria-hidden="true"/> OPTIONAL COFFEE CHALLENGE
      </div>
      <div className="card" role="group" aria-label={'Optional coffee challenge: ' + challenge.title} style={{ background: accentTint, borderColor: accentRule, position: 'relative', opacity: parking ? 0 : 1, transform: parking ? 'translateX(28px)' : 'none', transition: 'opacity 220ms ease, transform 220ms ease' }}>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr auto', alignItems: 'start', gap: 12 }}>
          {/* One step below the lesson title (26px): the challenge stays optional. */}
          <h2 className="ff-display" style={{ fontSize: 22, fontWeight: 400, lineHeight: 1.15, letterSpacing: '-0.01em', margin: 0, color: 'var(--ink)' }}>{challenge.title}</h2>
          {/* Postpone control (settled in review): clock in the app's round hairline
              button chrome (same as FavButton) so it reads as tappable. Tap slides
              the card away immediately; it lands under For Later, it is not deleted.
              Never the bookmark (that glyph = Favorites, a different destination). */}
          <button onClick={onPostpone} aria-label={'Save “' + challenge.title + '” for later'} style={{
            appearance: 'none', cursor: 'pointer', width: 38, height: 38, margin: '-8px -6px -8px 0', padding: 0,
            display: 'grid', placeItems: 'center', borderRadius: 999,
            border: '1px solid ' + accentRule, background: 'var(--surface)', color: 'var(--ink-mute)',
          }}><LaterClock size={18}/></button>
        </div>
        <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: '10px 0 0', textWrap: 'pretty' }}>{challenge.instruction}</p>
        {/* Same geometry as the Continue Learning card: one mono meta line on the
            left rail, full-width CTA below — not a stacked meta + right-hung button. */}
        {(() => {
          const segs = challenge.effort.split('·').map(s => s.trim());
          const timeSeg = segs.find(s => /min/i.test(s));
          const trigger = segs.find(s => !/min/i.test(s));
          const line = [trigger, timeSeg && '~' + timeSeg].filter(Boolean).join(' · ');
          return (
            <div className="ff-mono" aria-label={[trigger, timeSeg && 'about ' + timeSeg].filter(Boolean).join(', ')} style={{ fontSize: 'var(--t-label)', letterSpacing: '0.14em', textTransform: 'uppercase', color: metaInk, marginTop: 14 }}>
              <span aria-hidden="true">{line}</span>
            </div>
          );
        })()}
        {/* While today's lesson is still unfinished, Begin lesson owns the only filled
            orange action; the challenge is optional, so it takes the outlined rank. */}
        <button className="btn btn-primary" onClick={onLog} aria-label={'Log result for “' + challenge.title + '”'} style={{
          width: '100%', marginTop: 18, padding: '14px 24px',
          ...(lessonPending ? { background: 'transparent', color: 'var(--accent-text)', boxShadow: 'inset 0 0 0 1.5px var(--accent)' } : null),
        }}>Log result</button>
      </div>
    </div>
  );
}
window.ActiveBrewCard = ActiveBrewCard;

// ───────────────────────────────────────────────────────────
// LOG RESULT SHEET — lightweight logging. One optional taste reaction,
// then Mark as done. Explicitly non-punitive.
// ───────────────────────────────────────────────────────────
function LogResultSheet({ challenge, open, onClose, onComplete }) {
  const [pick, setPick] = React.useState(null);
  React.useEffect(() => { if (!open) setPick(null); }, [open]);
  const reactions = (challenge && challenge.reactions) || [];

  const markDone = () => {
    if (onComplete) onComplete(pick); // parent records completion + awards points
    onClose();                        // close straight back to the completed card on Learn
  };

  return (
    <>
      <div className={'sheet-backdrop' + (open ? ' open' : '')} onClick={onClose}/>
      <div className={'sheet' + (open ? ' open' : '')}>
        <div className="sheet-handle"/>
        <div className="sheet-content">
          <>
              <h2 className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, lineHeight: 1.12, letterSpacing: '-0.01em', margin: 0, color: 'var(--ink)' }}>
                {challenge ? challenge.title : ''}
              </h2>

              {reactions.length > 0 && (
                <>
                  <div className="smallcaps" style={{ margin: '28px 0 16px' }}>{(challenge && challenge.prompt) || 'HOW DID IT TASTE?'}</div>
                  <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
                    {reactions.map((r, i) => {
                      const on = pick === i;
                      return (
                        <button key={i} onClick={() => setPick(on ? null : i)} className="ff-ui" style={{
                          appearance: 'none', cursor: 'pointer', fontSize: 'var(--t-support)', fontWeight: 500,
                          padding: '8px 13px', borderRadius: 999,
                          border: '1px solid ' + (on ? 'transparent' : 'var(--rule)'),
                          background: on ? 'color-mix(in oklab, var(--accent) 22%, var(--surface))' : 'var(--surface)',
                          color: 'var(--ink)',
                        }}>{r}</button>
                      );
                    })}
                  </div>
                </>
              )}

              <div style={{ paddingTop: 20 }}>
                <button className="btn btn-primary" onClick={markDone} disabled={reactions.length > 0 && pick === null}
                  style={reactions.length > 0 && pick === null ? { opacity: 0.4, cursor: 'default' } : undefined}>Mark as done</button>
              </div>
            </>
        </div>
      </div>
    </>
  );
}
window.LogResultSheet = LogResultSheet;

// ───────────────────────────────────────────────────────────
// BREW RECAP SHEET — opened by tapping an already-completed challenge (e.g.
// the module challenge node on the Path). Acknowledges the earned stamp and
// lets the user deliberately REPLAY it. A completed challenge never resurfaces
// on Today on its own — only when the user chooses "Brew it again" here.
// ───────────────────────────────────────────────────────────
function BrewRecapSheet({ challenge, open, onClose, onReplay }) {
  return (
    <>
      <div className={'sheet-backdrop' + (open ? ' open' : '')} onClick={onClose}/>
      <div className={'sheet' + (open ? ' open' : '')}>
        <div className="sheet-handle"/>
        <div className="sheet-content">
          <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12 }}>
            <div style={{ minWidth: 0 }}>
              <h2 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.08, letterSpacing: '-0.01em', margin: 0, color: 'var(--ink)' }}>
                {challenge ? challenge.title : ''}
              </h2>
              {challenge && (
                <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: '8px 0 0', textWrap: 'pretty' }}>
                  {challenge.instruction}
                </p>
              )}
            </div>
            <div style={{ paddingTop: 4 }}><TriedSeal/></div>
          </div>

          <div style={{ paddingTop: 26 }}>
            <button className="btn btn-primary" onClick={() => onReplay && onReplay(challenge)}>Brew it again</button>
            <div style={{ marginTop: 10 }}>
              <a className="btn btn-ghost" href="#" style={{ display: 'block', textAlign: 'center', textDecoration: 'none' }} onClick={(e) => { e.preventDefault(); onClose(); }}>Done</a>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
window.BrewRecapSheet = BrewRecapSheet;

// ───────────────────────────────────────────────────────────
// LESSON-COMPLETION SUGGESTION — "Try this in real life" block shown on the
// lesson reward screen. Two buttons: Start Challenge / Not Now.
// state: 'suggested' | 'started' | 'dismissed'
// ───────────────────────────────────────────────────────────
function ChallengeSuggestion({ challenge, state, realState, onStart, onNotNow }) {
  if (!challenge) return null;
  // If the challenge is already completed or currently active in real state,
  // never offer Start / Save for later — show its true status instead, so a
  // done challenge can't be "saved" into a contradictory state.
  if (realState === 'completed' || realState === 'active') {
    const isDone = realState === 'completed';
    return (
      <div style={{
        border: '1px solid ' + (isDone ? 'color-mix(in oklab, var(--sage) 34%, var(--rule))' : 'color-mix(in oklab, var(--accent) 30%, var(--rule))'),
        borderRadius: 14, padding: '18px 20px', display: 'flex', alignItems: 'center', gap: 14,
        background: isDone ? 'color-mix(in oklab, var(--sage) 8%, var(--surface))' : 'color-mix(in oklab, var(--accent) 8%, var(--surface))',
      }}>
        <span style={{ width: 34, height: 34, borderRadius: 999, flexShrink: 0, display: 'grid', placeItems: 'center', background: isDone ? 'var(--sage)' : 'var(--accent)' }}>
          {isDone
            ? <svg width="17" height="17" viewBox="0 0 20 20"><path d="M4 10.5l3.5 3.5L16 5.5" fill="none" stroke="var(--surface)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>
            : <BrewCup size={18} color="var(--accent-ink)"/>}
        </span>
        <div style={{ minWidth: 0 }}>
          <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.16em', textTransform: 'uppercase', color: isDone ? 'var(--sage)' : 'var(--accent)' }}>{isDone ? 'CHALLENGE COMPLETED' : 'ON TODAY'}</div>
          <div style={{ fontSize: 'var(--t-support)', lineHeight: 1.35, color: 'var(--ink)', marginTop: 3 }}>
            <strong>{challenge.title}</strong>{isDone ? ' — nice work.' : ' is waiting on Today.'}
          </div>
        </div>
      </div>
    );
  }
  if (state === 'started' || state === 'dismissed') {
    const started = state === 'started';
    return (
      <div style={{
        border: '1px solid ' + (started ? 'color-mix(in oklab, var(--accent) 30%, var(--rule))' : 'var(--rule)'),
        borderRadius: 14, padding: '18px 20px', display: 'flex', alignItems: 'center', gap: 14,
        background: started ? 'color-mix(in oklab, var(--accent) 8%, var(--surface))' : 'var(--surface)',
      }}>
        <span style={{
          width: 34, height: 34, borderRadius: 999, flexShrink: 0, display: 'grid', placeItems: 'center',
          background: started ? 'var(--accent)' : 'var(--surface-2)',
        }}>
          {started
            ? <svg width="17" height="17" viewBox="0 0 20 20"><path d="M4 10.5l3.5 3.5L16 5.5" fill="none" stroke="var(--accent-ink)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>
            : <BrewCup size={18} color="var(--ink-mute)"/>}
        </span>
        <div style={{ fontSize: 'var(--t-support)', lineHeight: 1.4, color: 'var(--ink)' }}>
          {started
            ? <>Added to <strong>Today</strong>. Log it whenever you next brew.</>
            : <>Kept under <strong>For Later</strong> on Today, and on the Path.</>}
        </div>
      </div>
    );
  }
  return (
    <div style={{
      border: '1px solid color-mix(in oklab, var(--accent) 26%, var(--rule))', borderRadius: 14,
      padding: 20, background: 'color-mix(in oklab, var(--accent) 7%, var(--surface))',
    }}>
      <div className="smallcaps" style={{ color: 'var(--accent)', display: 'flex', alignItems: 'center', gap: 8, marginBottom: 12 }}>
        <BrewCup size={16} color="var(--accent)"/> COFFEE CHALLENGE UNLOCKED
      </div>
      <h3 className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, lineHeight: 1.12, letterSpacing: '-0.01em', margin: 0, color: 'var(--ink)' }}>{challenge.title}</h3>
      <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: '8px 0 14px', textWrap: 'pretty' }}>{challenge.instruction}</p>
      <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.12em', textTransform: 'uppercase', color: 'var(--ink-mute)', marginBottom: 18 }}>{challenge.effort}</div>
      <BrewActions inline primaryLabel="Start Challenge" secondaryLabel="Save for later" onPrimary={onStart} onSecondary={onNotNow}/>
    </div>
  );
}
window.ChallengeSuggestion = ChallengeSuggestion;

// ───────────────────────────────────────────────────────────
// MODULE COFFEE CHALLENGE SCREEN — the larger, practical final task shown after
// the module reward card. Optional. Two buttons: Start / Not Now.
// state: 'suggested' | 'started' | 'dismissed'
// ───────────────────────────────────────────────────────────
function ModuleChallengeScreen({ module, challenge, onStart, onNotNow, onBack }) {
  const [state, setState] = React.useState('suggested');
  if (!challenge) { // safety — no module challenge, skip straight on
    React.useEffect(() => { onNotNow && onNotNow(); }, []);
    return null;
  }
  const start = () => { setState('started'); setTimeout(() => onStart(), 900); };
  const notNow = () => { setState('dismissed'); setTimeout(() => onNotNow(), 850); };

  return (
    <div className="screen" data-screen-label="Module Coffee Challenge" style={{ background: 'var(--bg)' }}>
      <div aria-hidden="true" style={{
        position: 'absolute', inset: 0, pointerEvents: 'none',
        background: 'radial-gradient(ellipse at 50% 26%, color-mix(in oklab, var(--accent) 14%, transparent) 0%, transparent 58%)',
      }}/>
      <div className="lesson-topbar" style={{ borderBottom: 'none', background: 'transparent' }}>
        <button className="close-btn" onClick={onBack} aria-label="Back">
          <window.BackMark/>
        </button>
        <div/><div/>
      </div>

      <div className="scroll" style={{ paddingTop: 92, paddingBottom: 28, display: 'flex', flexDirection: 'column', position: 'relative' }}>
        <div className="px-24" style={{ textAlign: 'center' }}>
          <div className="smallcaps" style={{ color: 'var(--accent)', display: 'inline-flex', alignItems: 'center', gap: 8 }}>
            <BrewCup size={15} color="var(--accent)"/> MODULE COFFEE CHALLENGE
          </div>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.06, letterSpacing: '-0.02em', margin: '12px 0 0', color: 'var(--ink)', textWrap: 'pretty' }}>{challenge.title}</h1>
        </div>

        <div style={{ display: 'flex', justifyContent: 'center', padding: '24px 0 0' }}>
          <Roasty state="correct" size={128} gear="glasses"/>
        </div>

        <div className="px-24" style={{ paddingTop: 22 }}>
          <div style={{ background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 14, padding: '20px 22px' }}>
            <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: 10 }}>
              <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.14em', textTransform: 'uppercase', color: 'var(--ink-mute)', border: '1px solid var(--rule)', borderRadius: 999, padding: '3px 9px', whiteSpace: 'nowrap' }}>Optional</span>
            </div>
            <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.5, color: 'var(--ink)', margin: 0, textWrap: 'pretty' }}>{challenge.instruction}</p>
            <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.12em', textTransform: 'uppercase', color: 'var(--ink-mute)', marginTop: 16 }}>{challenge.effort}</div>
          </div>
        </div>

        <div style={{ flex: 1, minHeight: 20 }}/>

        {state === 'suggested' && (
          <div className="px-24" style={{ paddingTop: 24 }}>
            <BrewActions primaryLabel="Start Module Challenge" secondaryLabel="Not Now" onPrimary={start} onSecondary={notNow}/>
          </div>
        )}
        {state !== 'suggested' && (
          <div className="px-24" style={{ paddingTop: 24 }}>
            <ChallengeSuggestion challenge={challenge} state={state} onStart={() => {}} onNotNow={() => {}}/>
          </div>
        )}
      </div>
    </div>
  );
}
window.ModuleChallengeScreen = ModuleChallengeScreen;

// ───────────────────────────────────────────────────────────
// CARD STAMP SECTION — rendered inside the card-detail sheet. Shows the
// challenge stamp state for a card: completed (earned), or locked with a
// "Try challenge" action that activates it.
// ───────────────────────────────────────────────────────────
function CardStampSection({ card, completed, active, onTry }) {
  const challenge = card && card.id ? window.brewForCard(card.id) : null;
  // Unearned cards (the locked teaser opens this same sheet) never offer the
  // challenge — earning the card is the gate.
  if (!challenge || !card.earned) return null;
  return (
    <>
      {completed ? (
        <div style={{ padding: '0 0 4px' }}>
          <div className="smallcaps" style={{ marginBottom: 10 }}>CHALLENGE</div>
          <div className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, color: 'var(--ink)', lineHeight: 1.15 }}>{challenge.title}</div>
          {active ? (
            <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 8 }}>Active again on Today — log it when you brew.</div>
          ) : (
            <button onClick={() => onTry(challenge)} className="btn btn-ghost" style={{ marginTop: 16, color: 'var(--accent)' }}>Brew it again</button>
          )}
        </div>
      ) : (
        <div style={{ padding: '0 0 4px' }}>
          <div className="smallcaps" style={{ marginBottom: 10 }}>CHALLENGE</div>
          <div className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, color: 'var(--ink)', lineHeight: 1.15, marginBottom: 8 }}>{challenge.title}</div>
          <div style={{ fontSize: 'var(--t-support)', lineHeight: 1.45, color: 'var(--ink-mute)', textWrap: 'pretty' }}>
            {active ? 'Active on Today — log it when you brew.' : challenge.instruction}
          </div>
          {!active && (
            <button onClick={() => onTry(challenge)} className="btn btn-ghost" style={{ marginTop: 16, color: 'var(--accent)' }}>Try challenge</button>
          )}
        </div>
      )}
    </>
  );
}
window.CardStampSection = CardStampSection;

// ───────────────────────────────────────────────────────────
// PATH · MODULE CHALLENGE NODE — the only challenge shown on Path, after the
// final lesson of a module. state: 'locked' | 'available' | 'active' | 'completed'
// ───────────────────────────────────────────────────────────
function PathChallengeNode({ challenge, state, onAction }) {
  if (!challenge) return null;
  const done = state === 'completed';
  const active = state === 'active';
  const locked = state === 'locked';
  const available = state === 'available';
  const saved = state === 'saved';
  const clickable = !locked;
  // Kicker: label + the short effort estimate ("1 min" out of "Next bag · 1 min")
  const effortBits = (challenge.effort || '').split('·').map(s => s.trim());
  const time = effortBits[effortBits.length - 1] || '';
  const kicker =
    done || active ? 'CHALLENGE' :
    saved ? 'FOR LATER' :
    'CHALLENGE · ' + time;
  const pill =
    done ? { cls: 'done', body: <><svg width="11" height="11" viewBox="0 0 12 12"><path d="M2 6.5l2.5 2.5L10 3.5" fill="none" stroke="var(--sage)" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/></svg>Done</> } :
    active ? { cls: 'live', body: <><span className="pulse-dot"></span>Active</> } :
    saved ? { cls: 'resume', body: 'Resume' } :
    { cls: 'start', body: 'Start' };
  return (
    <button type="button" disabled={locked}
      onClick={() => clickable && onAction(challenge, saved ? 'available' : state)}
      className={'lesson-row challenge-sub cq-' + state + (locked ? ' locked' : '')}>
      <span className="path-node challenge-junction"><span className="challenge-diamond"></span></span>
      <div className="challenge-card">
        <span className="challenge-badge">
          <BrewCup size={15} color={done ? 'var(--sage)' : locked ? 'var(--ink-mute)' : 'var(--accent)'} steam={!locked && !done}/>
        </span>
        <div style={{ minWidth: 0 }}>
          <div className="challenge-kicker" style={locked ? { color: 'var(--ink-mute)' } : undefined}>{kicker}</div>
          <div className="challenge-title">{challenge.title}</div>
        </div>
      </div>
      <div className="challenge-trail">
        {locked
          ? <span className="trail"><window.LockMark size={13} label="Locked"/></span>
          : done
            ? null
            : <span className={'challenge-pill ' + pill.cls}>{pill.body}</span>}
      </div>
    </button>
  );
}
window.PathChallengeNode = PathChallengeNode;

// ───────────────────────────────────────────────────────────
// TODAY · FOR LATER — the queue of challenges parked with "Save for later".
// Collapsed to a single "For Later · n" row by default so it never competes
// with today's lesson; taps open it. Excludes the currently active one and any
// already completed. Starting one from here makes it the single active
// challenge (the current active one moves back into this list).
// ───────────────────────────────────────────────────────────
function SavedBrewList({ saved, activeId, completed, onStart, onRemove }) {
  const [open, setOpen] = React.useState(false);
  const ids = saved ? [...saved].filter(id => id !== activeId && !(completed && completed.has(id))) : [];
  if (ids.length === 0) return null;
  // Only surface a saved challenge once its source lesson has actually been
  // reached — never advertise one tied to a lesson still ahead on the path.
  const reached = (ch) => {
    if (!ch) return false;
    if (ch.type === 'module') { const mod = (window.MODULES || []).find(m => m.id === ch.moduleId); return !!mod && mod.lessons.every(l => l.status === 'complete'); }
    if (!ch.lessonId) return false;
    const ctx = window.findLessonContext && window.findLessonContext(ch.lessonId);
    if (!ctx) return false;
    return ctx.lesson.status === 'complete';
  };
  const items = ids.map(id => window.brewById && window.brewById(id)).filter(Boolean).filter(reached);
  if (items.length === 0) return null;
  const accentTint = 'color-mix(in oklab, var(--accent) 6%, var(--surface))';
  const accentRule = 'color-mix(in oklab, var(--accent) 24%, var(--rule))';
  const metaInk = 'color-mix(in oklab, var(--ink-mute) 62%, var(--ink))';
  return (
    <div className="px-24" style={{ paddingTop: 24 }}>
      <button onClick={() => setOpen(o => !o)} aria-expanded={open}
        aria-label={'For later, ' + items.length + ' challenge' + (items.length === 1 ? '' : 's')} style={{
        width: '100%', minHeight: 44, appearance: 'none', border: 'none', background: 'transparent',
        cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        gap: 10, padding: '4px 0',
      }}>
        <span className="smallcaps" aria-hidden="true" style={{ color: 'var(--accent-text)', display: 'flex', alignItems: 'center', gap: 8 }}>
          <LaterClock size={15} color="var(--accent)"/> FOR LATER · {items.length}
        </span>
        <svg width="18" height="18" viewBox="0 0 20 20" aria-hidden="true" style={{ color: 'var(--ink-mute)', flexShrink: 0, transform: open ? 'rotate(180deg)' : 'none', transition: 'transform 240ms cubic-bezier(.4,0,.2,1)' }}>
          <path d="M5 8 L10 13 L15 8" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      </button>
      {open && (
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, paddingTop: 12 }}>
        {items.map(ch => (
          // No cup glyph per row — the section header already carries the mark.
          <div key={ch.id} style={{
            display: 'grid', gridTemplateColumns: '1fr auto auto', alignItems: 'center', gap: 12,
            background: accentTint, border: '1px solid ' + accentRule, borderRadius: 14, padding: '13px 8px 13px 14px',
          }}>
            <div style={{ minWidth: 0 }}>
              <div style={{ fontSize: 'var(--t-body)', fontWeight: 500, color: 'var(--ink)', lineHeight: 1.2, textWrap: 'pretty' }}>{ch.title}</div>
              <div className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.12em', textTransform: 'uppercase', color: metaInk, marginTop: 4 }}>{ch.effort}</div>
            </div>
            <button onClick={() => onStart && onStart(ch)} className="ff-ui" aria-label={'Start “' + ch.title + '”'} style={{
              appearance: 'none', border: '1.5px solid var(--accent)', cursor: 'pointer', background: 'transparent', color: 'var(--accent-text)',
              borderRadius: 12, padding: '0 14px', minHeight: 44, fontSize: 'var(--t-support)', fontWeight: 500,
            }}>Start</button>
            <button onClick={() => onRemove && onRemove(ch.id)} aria-label={'Remove ' + ch.title} style={{
              appearance: 'none', border: 'none', background: 'transparent', cursor: 'pointer',
              color: 'var(--ink-mute)', width: 44, height: 44, display: 'grid', placeItems: 'center', padding: 0,
            }}>
              <svg width="14" height="14" viewBox="0 0 15 15" aria-hidden="true"><path d="M3 3l9 9M12 3l-9 9" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/></svg>
            </button>
          </div>
        ))}
      </div>
      )}
    </div>
  );
}
window.SavedBrewList = SavedBrewList;

// ───────────────────────────────────────────────────────────
// PROFILE · COFFEE CHALLENGES STAT — one lightweight progress row.
// ───────────────────────────────────────────────────────────
function BrewChallengeStat({ done, total, onOpen }) {
  const frac = total ? Math.max(0.02, Math.min(1, done / total)) : 0;
  const Tag = onOpen ? 'button' : 'div';
  return (
    <Tag onClick={onOpen}
         style={{ background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 16, padding: 16,
                  display: 'grid', gridTemplateColumns: '1fr auto', alignItems: 'center', gap: 16, width: '100%', textAlign: 'left',
                  appearance: 'none', font: 'inherit', color: 'inherit',
                  cursor: onOpen ? 'pointer' : 'default' }}>
      <div style={{ minWidth: 0, width: '100%' }}>
        <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: 10 }}>
          <span className="smallcaps">COFFEE CHALLENGES</span>
          <span className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.06em', color: 'var(--ink-mute)', whiteSpace: 'nowrap' }}>{done} / {total}</span>
        </div>
        <div style={{ height: 8, background: 'var(--bg)', borderRadius: 999, overflow: 'hidden', marginTop: 12 }}>
          <div style={{ height: '100%', width: (frac * 100) + '%', background: 'var(--accent)', borderRadius: 999 }}/>
        </div>
      </div>
      {onOpen && (
        <window.Chevron/>
      )}
    </Tag>
  );
}
window.BrewChallengeStat = BrewChallengeStat;
