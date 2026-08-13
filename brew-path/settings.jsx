// settings.jsx — destinations for the Settings account/practice rows.
// Holds: ConfirmSheet (used by Reset progress), TimeSheet (Daily reminder),
// AboutScreen, AccountSyncScreen, and the on-brand SettingsToggle.
// Loaded before screens.jsx-dependent app.jsx; exports to window.

const { useState: useStateS, useEffect: useEffectS } = React;

// ── Squared, field-guide toggle ──────────────────────────────
// The one switch in the app. Per the radius rule, toggles are pills (999px) —
// kept in the terracotta accent so it still reads as part of this system.
function SettingsToggle({ on, onChange, label }) {
  return (
    <button
      role="switch"
      aria-checked={on}
      aria-label={label}
      onClick={(e) => { e.stopPropagation(); onChange(!on); }}
      style={{
        appearance: 'none', cursor: 'pointer', position: 'relative',
        width: 44, height: 26, padding: 3, flex: 'none',
        borderRadius: 999,
        border: '1px solid ' + (on ? 'var(--accent)' : 'var(--rule)'),
        background: on ? 'var(--accent)' : 'transparent',
        transition: 'background 180ms ease, border-color 180ms ease',
      }}>
      <span style={{
        display: 'block', width: 18, height: 18, borderRadius: 999,
        background: on ? 'var(--accent-ink)' : 'var(--ink-mute)',
        transform: on ? 'translateX(18px)' : 'translateX(0)',
        transition: 'transform 180ms cubic-bezier(.2,.8,.2,1), background 180ms ease',
      }}/>
    </button>
  );
}

// ── ConfirmSheet — reusable bottom-sheet confirmation ─────────
// ── Sheet — the one bottom-sheet shell ──────────────────────────
// Backdrop, panel, handle and content padding live here and nowhere else, so
// sheet behaviour is changed once. ConfirmSheet, TimeSheet and PlanSheet all
// wrap it. No sheet carries an eyebrow — each opens on its title.
function Sheet({ open, onClose, children }) {
  return (
    <>
      <div className={'sheet-backdrop' + (open ? ' open' : '')} onClick={onClose}/>
      <div className={'sheet' + (open ? ' open' : '')}>
        <div className="sheet-handle"/>
        <div className="sheet-content">{children}</div>
      </div>
    </>
  );
}

// Every sheet opens on its title, in the same display face at the same size.
function SheetTitle({ children }) {
  return (
    <h2 className="ff-display" style={{
      fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em',
      margin: 0, color: 'var(--ink)',
    }}>{children}</h2>
  );
}

// ── ConfirmSheet — reusable bottom-sheet confirmation ─────────
// Used for destructive actions (Reset progress). `lines` is an itemised
// list of exactly what the action affects, so the stakes are concrete.
function ConfirmSheet({ open, title, body, lines, confirmLabel, cancelLabel = 'Keep my progress', danger, onConfirm, onClose }) {
  return (
    <Sheet open={open} onClose={onClose}>
      <SheetTitle>{title}</SheetTitle>

          {body && (
            <p style={{ margin: '12px 0 0', fontSize: 'var(--t-support)', lineHeight: 1.55, color: 'var(--ink-mute)', textWrap: 'pretty' }}>{body}</p>
          )}

          {lines && lines.length > 0 && (
            <div style={{
              marginTop: 18, border: '1px solid var(--rule)', borderRadius: 'var(--r)',
              background: 'var(--surface)', overflow: 'hidden',
            }}>
              {lines.map((ln, i) => (
                <div key={i} style={{
                  display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 16,
                  padding: '13px 16px',
                  borderBottom: i < lines.length - 1 ? '1px solid var(--rule)' : 'none',
                }}>
                  <span style={{ fontSize: 'var(--t-support)', color: 'var(--ink)' }}>{ln.label}</span>
                  <span className="ff-mono" style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', whiteSpace: 'nowrap' }}>{ln.value}</span>
                </div>
              ))}
            </div>
          )}

          <div className="stack gap-12" style={{ marginTop: 22 }}>
            <button className="btn btn-primary" onClick={onConfirm}
              style={danger ? { background: 'var(--berry)', color: 'var(--accent-ink)' } : undefined}>{confirmLabel}</button>
            {cancelLabel && <button className="btn btn-ghost" onClick={onClose}>{cancelLabel}</button>}
          </div>
    </Sheet>
  );
}

// ── TimeSheet — simple reminder time picker ───────────────────
const REMINDER_TIMES = ['6:30 AM', '7:00 AM', '7:30 AM', '8:00 AM', '8:30 AM', '12:30 PM', '6:00 PM', '8:30 PM'];
function TimeSheet({ open, value, onClose, onSave }) {
  const [sel, setSel] = useStateS(value);
  useEffectS(() => { if (open) setSel(value); }, [open, value]);
  return (
    <Sheet open={open} onClose={onClose}>
          <SheetTitle>A nudge to brew</SheetTitle>
          <p style={{ margin: '12px 0 0', fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink-mute)' }}>
            One quiet reminder a day to keep your streak alive.
          </p>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8, marginTop: 18 }}>
            {REMINDER_TIMES.map(tm => {
              const on = sel === tm;
              return (
                <button key={tm} onClick={() => setSel(tm)} className="ff-mono"
                  style={{
                    appearance: 'none', cursor: 'pointer', padding: '14px 10px', minHeight: 44,
                    borderRadius: 2, fontSize: 'var(--t-support)', letterSpacing: '0.02em',
                    border: '1px solid ' + (on ? 'var(--accent)' : 'var(--rule)'),
                    background: on ? 'var(--accent)' : 'transparent',
                    color: on ? 'var(--accent-ink)' : 'var(--ink)',
                    transition: 'background 140ms ease, border-color 140ms ease',
                  }}>{tm}</button>
              );
            })}
          </div>

          <button className="btn btn-primary" style={{ marginTop: 22 }}
            onClick={() => onSave(sel)}>Set reminder</button>
    </Sheet>
  );
}

// ── SettingsRow — THE settings/nav row for the whole app ──────
// One implementation, six trailing variants: value, chevron, external arrow,
// toggle, pending spinner, and destructive. Settings, About, Account and sync,
// Help and support and Subscription all render through this; `SettingsRow` in
// screens.jsx is an alias, so the row can never drift into two versions again.
//   value    mono text before the affordance
//   sub      second line under the label
//   accent   destructive (berry)
//   dim      inactive-but-present (a reminder row with notifications off)
//   external leaves the app → corner arrow instead of a chevron
//   toggle   carries a switch; the WHOLE row toggles (44px+ target)
//   pending  waiting on a network call; label swaps, taps refused
function NavRow({ label, sub, value, accent, dim, external, onClick, pending, pendingLabel, toggle, toggleOn, onToggle }) {
  const Toggle = window.SettingsToggle;
  const act = pending ? undefined : (toggle ? () => onToggle && onToggle(!toggleOn) : onClick);
  // A row that DOES something is a button, so it is focusable, Enter/Space
  // activated and announced as a control. Toggle rows stay a div: the switch
  // inside them is already a button, and buttons cannot nest.
  const asButton = !toggle && !!onClick;
  const Tag = asButton ? 'button' : 'div';
  const tagProps = asButton
    ? { type: 'button', onClick: act, disabled: !!pending }
    : { onClick: act };
  return (
    <Tag {...tagProps} aria-busy={pending || undefined} style={{
      display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 16,
      padding: '16px 0', borderBottom: '1px solid var(--rule)', cursor: pending ? 'default' : 'pointer',
      opacity: dim ? 0.55 : 1, transition: 'opacity 180ms ease',
      width: '100%', appearance: 'none', background: 'transparent', border: 'none',
      borderBottomWidth: 1, borderBottomStyle: 'solid', borderBottomColor: 'var(--rule)',
      textAlign: 'left', font: 'inherit', color: 'inherit', minHeight: 44,
    }}>
      <span style={{ minWidth: 0, flex: 1 }}>
        <span style={{ display: 'block', fontSize: 'var(--t-body)', color: pending ? 'var(--ink-mute)' : (accent ? 'var(--berry)' : 'var(--ink)'), whiteSpace: 'nowrap' }}>{pending ? (pendingLabel || label) : label}</span>
        {sub && <span style={{ display: 'block', fontSize: 'var(--t-label)', lineHeight: 1.45, color: 'var(--ink-mute)', marginTop: 3, textWrap: 'pretty' }}>{sub}</span>}
      </span>
      {pending ? (
        <svg className="row-spin" width="15" height="15" viewBox="0 0 15 15" aria-hidden="true"><circle cx="7.5" cy="7.5" r="5.6" fill="none" stroke="var(--rule)" strokeWidth="1.6"/><path d="M7.5 1.9a5.6 5.6 0 0 1 5.6 5.6" fill="none" stroke="var(--accent)" strokeWidth="1.6" strokeLinecap="round"/></svg>
      ) : toggle && Toggle ? (
        <Toggle on={toggleOn} onChange={onToggle} label={label}/>
      ) : (
        <span style={{ display: 'flex', alignItems: 'center', gap: 10, whiteSpace: 'nowrap', minWidth: 0, overflow: 'hidden' }}>
          {value && <span className="ff-mono" style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{value}</span>}
          {external ? (
            <svg width="13" height="13" viewBox="0 0 13 13" style={{ flex: 'none' }}><path d="M3 10 L10 3 M4.5 3 H10 V8.5" fill="none" stroke="var(--ink-mute)" strokeOpacity="0.6" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round"/></svg>
          ) : (
            <window.Chevron/>
          )}
        </span>
      )}
    </Tag>
  );
}

// ── STICKY HEADER — one implementation for the whole app ──────
// Every screen-level top bar renders through StickyHeaderChrome: transparent
// at rest, then a blurred + tinted bar with a bottom hairline and a short
// gradient fade below it, so scrolling type never reads through the edge.
// Nothing else in the app is allowed to hand-roll this chrome — AppHeader
// (tabs) and the term page both compose it. Constants are exported so scroll
// containers can't drift out of sync with the bar's height.
const HEADER_H = 96;                 // subscreen bar height
const HEADER_PAD = 108;              // matching scroll paddingTop
const HEADER_FILL = 'color-mix(in oklab, var(--bg) 94%, transparent)';
const HEADER_BLUR = 'blur(16px) saturate(1.3)';

// A single threshold everywhere: the bar materialises as soon as content
// starts moving, so nothing is ever seen crossing an invisible edge.
// `resetKey` guards the failure mode this replaced: when a screen swaps its
// content inside the SAME scroller (dictionary category drill-down, term →
// term), the scroller snaps back to top while `scrolled` stayed true — leaving
// a solid bar and a compact title stacked on top of the un-scrolled large
// title. Pass the value that identifies the content and attach the returned
// ref to the scroll container; the flag and the offset then reset together.
function useScrollFlag(threshold = 40, resetKey) {
  const [scrolled, setScrolled] = useStateS(false);
  const ref = React.useRef(null);
  // currentTarget, not target: a nested scroller must never flip the page bar.
  const onScroll = (e) => setScrolled(e.currentTarget.scrollTop > threshold);
  useEffectS(() => {
    if (ref.current) ref.current.scrollTop = 0;
    setScrolled(false);
  }, [resetKey]);
  return [scrolled, onScroll, ref];
}

function StickyHeaderChrome({ scrolled, height = HEADER_H, children }) {
  return (
    <div style={{
      position: 'absolute', top: 0, left: 0, right: 0, height, zIndex: 40,
      display: 'flex', alignItems: 'flex-end', pointerEvents: 'none',
      background: scrolled ? HEADER_FILL : 'transparent',
      backdropFilter: scrolled ? HEADER_BLUR : 'none',
      WebkitBackdropFilter: scrolled ? HEADER_BLUR : 'none',
      borderBottom: '1px solid ' + (scrolled ? 'var(--rule)' : 'transparent'),
      transition: 'background 260ms ease, backdrop-filter 260ms ease, border-color 260ms ease',
    }}>
      <div aria-hidden="true" style={{
        position: 'absolute', top: '100%', left: 0, right: 0, height: 22, pointerEvents: 'none',
        background: 'linear-gradient(to bottom, color-mix(in oklab, var(--bg) 88%, transparent), transparent)',
        opacity: scrolled ? 1 : 0, transition: 'opacity 260ms ease',
      }}/>
      {children}
    </div>
  );
}

// The compact title that fades in as the large in-flow title scrolls under.
function HeaderCompactTitle({ scrolled, eyebrow, title }) {
  return (
    <div style={{
      minWidth: 0, flex: 1,
      opacity: scrolled ? 1 : 0,
      transform: scrolled ? 'translateY(0)' : 'translateY(7px)',
      transition: 'opacity 240ms ease, transform 240ms ease',
      pointerEvents: 'none',
    }}>
      {eyebrow && (
        <div className="ff-mono" style={{
          fontSize: 'var(--t-micro)', letterSpacing: '0.18em', textTransform: 'uppercase',
          color: 'var(--ink-mute)', lineHeight: 1,
        }}>{eyebrow}</div>
      )}
      <div className="ff-display" style={{
        fontSize: 'var(--t-heading)', fontWeight: 400, letterSpacing: '-0.01em', color: 'var(--ink)',
        lineHeight: 1.15, marginTop: eyebrow ? 2 : 0, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
      }}>{title}</div>
    </div>
  );
}

// Standard back top-bar. `right` takes trailing controls (e.g. the bookmark),
// `ringBack` circles the back control so both ends of the bar match weight,
// `solid` pins the bar filled with its title always shown — for screens with a
// fixed hero instead of a large in-flow title to collapse.
function SubScreenHeader({ scrolled, eyebrow, title, onBack, icon = 'back', right, ringBack, solid }) {
  const on = solid || scrolled;
  return (
    <StickyHeaderChrome scrolled={on}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '0 20px 10px', width: '100%' }}>
        {onBack && (
          <button className="close-btn" onClick={onBack} aria-label={icon === 'close' ? 'Close' : 'Back'}
            style={ringBack
              ? { pointerEvents: 'auto', flexShrink: 0, border: '1px solid var(--rule)', borderRadius: 999, width: 32, height: 32, padding: 0, color: 'var(--ink-mute)' }
              : { pointerEvents: 'auto', flexShrink: 0, marginLeft: -4 }}>
            {icon === 'close' ? <window.CloseMark/> : <window.BackMark size={ringBack ? 15 : 18}/>}
          </button>
        )}
        <HeaderCompactTitle scrolled={on} eyebrow={eyebrow} title={title}/>
        {right && <div style={{ flexShrink: 0, pointerEvents: 'auto', display: 'flex', alignItems: 'center', gap: 10 }}>{right}</div>}
      </div>
    </StickyHeaderChrome>
  );
}

function BackBar({ onClose, title, scrolled }) {
  return <SubScreenHeader scrolled={scrolled} title={title} onBack={onClose}/>;
}

// ── AboutScreen ───────────────────────────────────────────────
function AboutScreen({ onClose }) {
  const Roasty = window.Roasty;
  const [scrolled, onScroll] = useScrollFlag();
  return (
    <div className="screen" data-screen-label="About" style={{ background: 'var(--bg)' }}>
      <BackBar onClose={onClose} title="About" scrolled={scrolled}/>
      <div className="scroll" onScroll={onScroll} style={{ paddingTop: HEADER_PAD, paddingBottom: 40 }}>
        {/* Brand block */}
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', padding: '8px 24px 0' }}>
          {Roasty && <Roasty state="idle" size={132}/>}
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1, letterSpacing: '-0.025em', margin: '14px 0 0', color: 'var(--ink)' }}>BrewPath</h1>
          <div className="smallcaps" style={{ marginTop: 10 }}>A FIELD GUIDE TO COFFEE</div>
        </div>

        <div className="px-24" style={{ paddingTop: 26 }}>
          <p style={{ margin: 0, fontSize: 'var(--t-body)', lineHeight: 1.6, color: 'var(--ink-mute)', textWrap: 'pretty', textAlign: 'center' }}>
            A quiet place to learn coffee — one short lesson at a time. No noise, no pressure. Just you, a growing tree, and Roasty for company.
          </p>
        </div>

        <div className="px-24" style={{ paddingTop: 30 }}>
          <div className="smallcaps" style={{ marginBottom: 4 }}>THE FINE PRINT</div>
          <NavRow label="Privacy policy" external onClick={() => {}}/>
          <NavRow label="Terms of use" external onClick={() => {}}/>
          <NavRow label="Acknowledgements" onClick={() => {}}/>
          <NavRow label="Open-source licenses" onClick={() => {}}/>
        </div>

        <div className="px-24" style={{ paddingTop: 26 }}>
          <div className="smallcaps" style={{ marginBottom: 4 }}>SAY SOMETHING</div>
          <NavRow label="Rate BrewPath" external onClick={() => {}}/>
          <NavRow label="Say hello" value="hi@brewpath.app" external onClick={() => {}}/>
        </div>

        <div className="px-24" style={{ paddingTop: 34, textAlign: 'center' }}>
          <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.14em', color: 'var(--ink-mute)', textTransform: 'uppercase' }}>
            Version 0.1 · build 240618
          </div>
          <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.14em', color: 'var(--ink-mute)', textTransform: 'uppercase', marginTop: 6, opacity: 0.7 }}>
            Brewed slowly, like the good stuff
          </div>
        </div>
      </div>
    </div>
  );
}

// ── AccountSyncScreen ─────────────────────────────────────────
function AccountSyncScreen({ isPlus, inTrial = false, onClose, onManagePlan, onSignOut }) {
  const [cellular, setCellular] = useStateS(false);
  const [scrolled, onScroll] = useScrollFlag();
  return (
    <div className="screen" data-screen-label="Account and sync" style={{ background: 'var(--bg)' }}>
      <BackBar onClose={onClose} title="Account and sync" scrolled={scrolled}/>
      <div className="scroll" onScroll={onScroll} style={{ paddingTop: 108, paddingBottom: 40 }}>
        <div className="px-24">
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>Account and sync</h1>
        </div>

        {/* Identity card */}
        <div className="px-24" style={{ paddingTop: 22 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14, padding: 18, border: '1px solid var(--rule)', borderRadius: 2, background: 'var(--surface)' }}>
            <div className="ff-display" style={{
              flex: 'none', width: 52, height: 52, borderRadius: 2,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              background: 'var(--accent)', color: 'var(--accent-ink)',
              fontSize: 'var(--t-title)', fontWeight: 400, letterSpacing: '-0.02em',
            }}>{(window.USER || {}).initial || 'm'}</div>
            <div style={{ minWidth: 0 }}>
              <div style={{ fontSize: 'var(--t-body)', color: 'var(--ink)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{(window.USER || {}).email}</div>
              <div className="smallcaps" style={{ marginTop: 4 }}>{isPlus ? (inTrial ? 'BREWPATH PLUS · TRIAL' : 'BREWPATH PLUS') : 'FREE PLAN'}</div>
            </div>
          </div>
        </div>

        <div className="px-24" style={{ paddingTop: 26 }}>
          <div className="smallcaps" style={{ marginBottom: 4 }}>CLOUD SYNC</div>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 16, padding: '16px 0', borderBottom: '1px solid var(--rule)' }}>
            <span style={{ fontSize: 'var(--t-body)', color: 'var(--ink)', whiteSpace: 'nowrap' }}>Sync progress</span>
            <span style={{ display: 'flex', alignItems: 'center', gap: 8, whiteSpace: 'nowrap' }}>
              <span style={{ width: 7, height: 7, borderRadius: 999, background: 'var(--sage)' }}/>
              <span className="ff-mono" style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)' }}>Just now</span>
            </span>
          </div>
          <div onClick={() => setCellular(!cellular)} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 16, padding: '16px 0', borderBottom: '1px solid var(--rule)', cursor: 'pointer' }}>
            <span style={{ fontSize: 'var(--t-body)', color: 'var(--ink)', whiteSpace: 'nowrap' }}>Sync over cellular</span>
            <SettingsToggle on={cellular} onChange={setCellular} label="Sync over cellular"/>
          </div>
          <NavRow label="This iPhone" value="Active" onClick={() => {}}/>
        </div>

        <div className="px-24" style={{ paddingTop: 26 }}>
          <div className="smallcaps" style={{ marginBottom: 4 }}>SUBSCRIPTION</div>
          <NavRow label={isPlus ? 'Manage Plus' : 'Upgrade to Plus'} value={isPlus ? (inTrial ? 'Trial' : 'Yearly') : null} onClick={onManagePlan}/>
        </div>

        <div className="px-24" style={{ paddingTop: 26 }}>
          <NavRow label="Sign out" accent onClick={onSignOut}/>
        </div>
      </div>
    </div>
  );
}

// ── PlanSheet — switch billing cycle ─────────────────────────
const PLAN_OPTS = [
  { id: 'yearly',  title: 'Yearly',  price: '$29.99 / yr', note: '$2.50 / mo · save 50%' },
  { id: 'monthly', title: 'Monthly', price: '$4.99 / mo',  note: 'Billed monthly' },
];
function PlanSheet({ open, value, onClose, onSave }) {
  const [sel, setSel] = useStateS(value);
  useEffectS(() => { if (open) setSel(value); }, [open, value]);
  return (
    <Sheet open={open} onClose={onClose}>
          <SheetTitle>Change your plan</SheetTitle>
          <p style={{ margin: '12px 0 0', fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink-mute)' }}>
            Switches take effect at your next renewal. Nothing changes today.
          </p>
          <div className="stack gap-12" style={{ marginTop: 18 }}>
            {PLAN_OPTS.map(p => {
              const on = sel === p.id;
              return (
                <button key={p.id} onClick={() => setSel(p.id)}
                  style={{
                    appearance: 'none', cursor: 'pointer', textAlign: 'left',
                    display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 14,
                    padding: '16px 18px', borderRadius: 2,
                    border: '1px solid ' + (on ? 'var(--accent)' : 'var(--rule)'),
                    background: on ? 'color-mix(in oklab, var(--accent) 10%, transparent)' : 'transparent',
                  }}>
                  <span>
                    <span style={{ display: 'block', fontSize: 'var(--t-body)', color: 'var(--ink)' }}>{p.title}</span>
                    <span style={{ display: 'block', fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 2 }}>{p.note}</span>
                  </span>
                  <span className="ff-mono" style={{ fontSize: 'var(--t-support)', color: 'var(--ink)', whiteSpace: 'nowrap' }}>{p.price}</span>
                </button>
              );
            })}
          </div>
          <button className="btn btn-primary" style={{ marginTop: 22 }}
            onClick={() => onSave(sel)}>{sel === value ? 'Keep current plan' : 'Switch plan'}</button>
    </Sheet>
  );
}

// ── SubscriptionScreen ────────────────────────────────────────
// Shows the current plan state and the levers to manage it. Plus members
// get billing detail + change/cancel; free members get a compact upgrade.
// A trial is its own state, not a decorated Plus state: the salient fact is how
// long is left and what happens at the end, so the card leads with the countdown
// and every "renews / next charge / cancel" string flips to first-charge language.
function SubscriptionScreen({ isPlus, plan = 'yearly', renews = '18 Jun 2027', trialDaysLeft = 0, chargeDate, onClose, onUpgrade, onChangePlan, onCancel, restoreOutcome = 'plus', onRestored }) {
  const [planOpen, setPlanOpen] = useStateS(false);
  const [cancelOpen, setCancelOpen] = useStateS(false);
  // Restore purchases is a split responsibility: iOS owns the Apple ID auth
  // sheet, StoreKit hands back a result, and it shows the user NOTHING. So the
  // three outcomes below are ours to state plainly — otherwise the row looks
  // broken on the two paths that don't end in a subscription.
  const [restoring, setRestoring] = useStateS(false);
  const [restoreDone, setRestoreDone] = useStateS(null); // 'plus' | 'none' | 'error'
  const runRestore = () => {
    if (restoring) return;
    setRestoring(true);
    setTimeout(() => {
      setRestoring(false);
      setRestoreDone(restoreOutcome);
      if (restoreOutcome === 'plus' && onRestored) onRestored();
    }, 1500);
  };
  const RESTORE_RESULT = {
    plus:  { title: 'Your Plus is back.',
             body: 'We found your subscription on this Apple ID and reactivated it. Saved is unlimited again, and Roasty and your plant are yours to dress.' },
    none:  { title: 'No purchase on this Apple ID.',
             body: 'If you bought Plus with a different Apple ID, sign in with that one and try again.' },
    error: { title: 'We couldn’t reach the store.',
             body: 'Check your connection and try again.' },
  };
  const PlanSheetC = window.PlanSheet;
  const ConfirmSheet = window.ConfirmSheet;
  const meta = PLAN_OPTS.find(p => p.id === plan) || PLAN_OPTS[0];
  const inTrial = isPlus && trialDaysLeft > 0;
  const firstCharge = chargeDate || renews;
  // Matches the paywall's pitch exactly — the two levers, not the old cosmetics list.
  const benefits = ['Unlimited Saved', 'Dress up Roasty', 'Choose your plant'];
  const [scrolled, onScroll] = useScrollFlag();

  return (
    <div className="screen" data-screen-label="Subscription" style={{ background: 'var(--bg)' }}>
      <BackBar onClose={onClose} title="Subscription" scrolled={scrolled}/>
      <div className="scroll" onScroll={onScroll} style={{ paddingTop: 108, paddingBottom: 40 }}>
        <div className="px-24">
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>Subscription</h1>
        </div>

        {/* Status. The card is a billing container — price, renewal, days left — so
            it renders only when there IS billing. Free has none, so it uses the
            screen's own section grammar instead: smallcaps label + a plain line,
            the same shape as WITH PLUS and MANAGE below it. */}
        {isPlus ? (
          <div className="px-24" style={{ paddingTop: 22 }}>
            <div style={{
              border: '1px solid color-mix(in oklab, var(--accent) 30%, var(--rule))',
              borderRadius: 2, padding: 22,
              background: 'linear-gradient(160deg, color-mix(in oklab, var(--accent) 12%, var(--surface)) 0%, var(--surface) 62%)',
            }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
                <span className="smallcaps" style={{ color: 'var(--accent)' }}>{inTrial ? 'FREE TRIAL' : 'BREWPATH PLUS'}</span>
                <span style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  <span style={{ width: 7, height: 7, borderRadius: 999, background: inTrial ? 'var(--accent)' : 'var(--sage)' }}/>
                  <span className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.08em', color: 'var(--ink-mute)', textTransform: 'uppercase' }}>{inTrial ? 'Trialling' : 'Active'}</span>
                </span>
              </div>
              <div className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em', color: 'var(--ink)', marginTop: 12 }}>
                {inTrial ? (trialDaysLeft + (trialDaysLeft === 1 ? ' day left' : ' days left')) : meta.price.replace(' / ', '/')}
              </div>
              <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 6 }}>
                {inTrial ? ('Then ' + meta.price.replace(' / ', '/') + ' on ' + firstCharge + ' \u00b7 cancel before then and you won\u2019t be charged')
                  : ('Renews ' + renews + ' \u00b7 ' + meta.title.toLowerCase())}
              </div>
            </div>
          </div>
        ) : (
          <div className="px-24" style={{ paddingTop: 26 }}>
            <div className="smallcaps" style={{ marginBottom: 4 }}>FREE PLAN</div>
            <div style={{ fontSize: 'var(--t-body)', color: 'var(--ink)', padding: '16px 0' }}>Every lesson and the dictionary, included.</div>
          </div>
        )}

        {isPlus ? (
          <>
            <div className="px-24" style={{ paddingTop: 26 }}>
              <div className="smallcaps" style={{ marginBottom: 4 }}>BILLING</div>
              <NavRow label="Plan" value={meta.title} onClick={() => setPlanOpen(true)}/>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 16, padding: '16px 0', borderBottom: '1px solid var(--rule)' }}>
                <span style={{ fontSize: 'var(--t-body)', color: 'var(--ink)', whiteSpace: 'nowrap' }}>{inTrial ? 'First charge' : 'Next charge'}</span>
                <span className="ff-mono" style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', whiteSpace: 'nowrap' }}>{meta.price.split(' / ')[0]} · {inTrial ? firstCharge : renews}</span>
              </div>
              <NavRow label="Payment method" value="Apple ID" onClick={() => {}}/>
            </div>

            <div className="px-24" style={{ paddingTop: 26 }}>
              <div className="smallcaps" style={{ marginBottom: 4 }}>INCLUDED</div>
              {benefits.map((b, i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 0', borderBottom: i < benefits.length - 1 ? '1px solid var(--rule)' : 'none' }}>
                  <svg width="15" height="15" viewBox="0 0 15 15"><path d="M3 8 L6.2 11 L12 4" fill="none" stroke="var(--sage)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>
                  <span style={{ fontSize: 'var(--t-body)', color: 'var(--ink)' }}>{b}</span>
                </div>
              ))}
            </div>

            {/* No restore row here: restore recovers an entitlement the app doesn't
                know about, and this branch only renders when it already does. It
                lives on the surfaces where a purchase is offered — the paywall and
                this screen's free state. MANAGE keeps only what acts. */}
            <div className="px-24" style={{ paddingTop: 26 }}>
              <div className="smallcaps" style={{ marginBottom: 4 }}>MANAGE</div>
              <NavRow label={inTrial ? 'Cancel trial' : 'Cancel subscription'} accent onClick={() => setCancelOpen(true)}/>
            </div>

            <div className="px-24" style={{ paddingTop: 26, textAlign: 'center' }}>
              <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.12em', color: 'var(--ink-mute)', textTransform: 'uppercase', lineHeight: 1.6 }}>
                Billed through the App Store.<br/>Manage or cancel anytime in your Apple ID.
              </div>
            </div>
          </>
        ) : (
          <>
            <div className="px-24" style={{ paddingTop: 26 }}>
              <div className="smallcaps" style={{ marginBottom: 4 }}>WITH PLUS</div>
              {benefits.map((b, i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 0', borderBottom: i < benefits.length - 1 ? '1px solid var(--rule)' : 'none' }}>
                  <svg width="15" height="15" viewBox="0 0 15 15"><path d="M3 8 L6.2 11 L12 4" fill="none" stroke="var(--accent)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>
                  <span style={{ fontSize: 'var(--t-body)', color: 'var(--ink)' }}>{b}</span>
                </div>
              ))}
            </div>
            <div className="px-24" style={{ paddingTop: 26 }}>
              <button className="btn btn-primary" onClick={onUpgrade}>See Plus</button>
            </div>

            {/* Restore lives here because this is a surface where a purchase is on
                offer. The CTA above stands alone so the row can't read as attached
                to it, and the group is labelled so it isn't an orphaned list item. */}
            <div className="px-24" style={{ paddingTop: 26 }}>
              <div className="smallcaps" style={{ marginBottom: 4 }}>MANAGE</div>
              <NavRow label="Restore purchases" pending={restoring} pendingLabel="Restoring…" onClick={runRestore}/>
            </div>

            {/* Subject is Plus, not the reader: a free user is not being billed and
                has nothing to cancel, so this cannot be phrased as their status. */}
            <div className="px-24" style={{ paddingTop: 26, textAlign: 'center' }}>
              <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.12em', color: 'var(--ink-mute)', textTransform: 'uppercase', lineHeight: 1.6 }}>
                Plus is billed through the App Store.<br/>Cancel anytime.
              </div>
            </div>
          </>
        )}
      </div>

      {PlanSheetC && (
        <PlanSheetC open={planOpen} value={plan}
          onClose={() => setPlanOpen(false)}
          onSave={(v) => { setPlanOpen(false); onChangePlan && onChangePlan(v); }}/>
      )}
      {ConfirmSheet && (
        <ConfirmSheet open={cancelOpen} danger
          title={inTrial ? 'Cancel your free trial?' : 'Cancel your subscription?'}
          body={inTrial
            ? ('You won’t be billed. Plus stays open until ' + firstCharge + ', then the Studio locks and Saved returns to 10 items.')
            : ('Plus stays open until ' + renews + '. After that the Studio locks and Saved returns to 10 items. Your progress and points stay as they are.')}
          confirmLabel={inTrial ? 'Cancel trial' : 'Cancel subscription'}
          cancelLabel={inTrial ? 'Keep trialling' : 'Keep Plus'}
          onConfirm={() => { setCancelOpen(false); onCancel && onCancel(); }}
          onClose={() => setCancelOpen(false)}/>
      )}
      {ConfirmSheet && restoreDone && (
        <ConfirmSheet open={!!restoreDone}
          title={RESTORE_RESULT[restoreDone].title}
          body={RESTORE_RESULT[restoreDone].body}
          confirmLabel={restoreDone === 'error' ? 'Try again' : 'Done'}
          cancelLabel={null}
          onConfirm={() => { setRestoreDone(null); if (restoreDone === 'error') runRestore(); }}
          onClose={() => setRestoreDone(null)}/>
      )}
    </div>
  );
}

// ── HelpSupportScreen ───────────────────────────────────────
// Reached from Settings → Help and support. A short expandable FAQ plus the
// two contact routes. FAQ answers open inline — no dead-end rows.
const FAQ_ITEMS = [
  { q: 'How does my streak work?', a: 'Finish at least one lesson a day to keep it alive. Every 7 days you earn a streak freeze, and you can hold two at once — miss a day and one is spent automatically, so your streak survives and that day shows as covered in your week. Nothing to switch on.' },
  { q: 'How does my tree grow?', a: 'Your tree tracks the core course only — it moves up a stage as you complete core lessons, through ten stages from bare seed to full harvest. Points from practice and reviews don’t grow it, and it never shrinks unless you reset your progress.' },
  { q: 'What do I get with Plus?', a: 'Two things: an unlimited Saved shelf (free keeps 10 items), and the Studio — dress up Roasty and choose which plant grows in your grove. Learning content is always free, and so is your streak.' },
  { q: 'Can I learn offline?', a: 'Yes — modules you\u2019ve opened are kept on your phone. Progress syncs the next time you\u2019re online.' },
];

function FaqRow({ q, a, open, onToggle }) {
  return (
    <div style={{ borderBottom: '1px solid var(--rule)' }}>
      <div onClick={onToggle} style={{
        display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 16,
        padding: '16px 0', cursor: 'pointer',
      }}>
        <span style={{ fontSize: 'var(--t-body)', color: 'var(--ink)' }}>{q}</span>
        <svg width="12" height="12" viewBox="0 0 12 12" style={{ flex: 'none', transform: open ? 'rotate(45deg)' : 'none', transition: 'transform 200ms ease' }}>
          <path d="M6 1v10M1 6h10" stroke="var(--ink-mute)" strokeOpacity="0.7" strokeWidth="1.4" strokeLinecap="round"/>
        </svg>
      </div>
      <div style={{
        display: 'grid', gridTemplateRows: open ? '1fr' : '0fr',
        transition: 'grid-template-rows 240ms cubic-bezier(.2,.8,.2,1)',
      }}>
        <div style={{ overflow: 'hidden' }}>
          <p style={{ margin: '0 0 16px', fontSize: 'var(--t-support)', lineHeight: 1.55, color: 'var(--ink-mute)', textWrap: 'pretty', maxWidth: '92%' }}>{a}</p>
        </div>
      </div>
    </div>
  );
}

function HelpSupportScreen({ onClose }) {
  const [openIdx, setOpenIdx] = useStateS(-1);
  const [scrolled, onScroll] = useScrollFlag();
  return (
    <div className="screen" data-screen-label="Help and support" style={{ background: 'var(--bg)' }}>
      <BackBar onClose={onClose} title="Help and support" scrolled={scrolled}/>
      <div className="scroll" onScroll={onScroll} style={{ paddingTop: 108, paddingBottom: 40 }}>
        <div className="px-24">
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>Help and support</h1>
        </div>

        <div className="px-24" style={{ paddingTop: 26 }}>
          <div className="smallcaps" style={{ marginBottom: 4 }}>COMMON QUESTIONS</div>
          {FAQ_ITEMS.map((it, i) => (
            <FaqRow key={i} q={it.q} a={it.a} open={openIdx === i} onToggle={() => setOpenIdx(openIdx === i ? -1 : i)}/>
          ))}
        </div>

        <div className="px-24" style={{ paddingTop: 26 }}>
          <div className="smallcaps" style={{ marginBottom: 4 }}>GET IN TOUCH</div>
          <NavRow label="Email support" value="hi@brewpath.app" external onClick={() => {}}/>
          <NavRow label="Report a problem" external onClick={() => {}}/>
        </div>

        <div className="px-24" style={{ paddingTop: 34, textAlign: 'center' }}>
          <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.14em', color: 'var(--ink-mute)', textTransform: 'uppercase' }}>
            We reply within a day — usually faster
          </div>
        </div>
      </div>
    </div>
  );
}

window.SettingsToggle = SettingsToggle;
window.SubScreenHeader = SubScreenHeader;
window.StickyHeaderChrome = StickyHeaderChrome;
window.HeaderCompactTitle = HeaderCompactTitle;
window.HEADER_H = HEADER_H;
window.HEADER_PAD = HEADER_PAD;
window.useScrollFlag = useScrollFlag;
window.NavRow = NavRow;
window.ConfirmSheet = ConfirmSheet;
window.Sheet = Sheet;
window.SheetTitle = SheetTitle;
window.TimeSheet = TimeSheet;
window.AboutScreen = AboutScreen;
window.HelpSupportScreen = HelpSupportScreen;
window.AccountSyncScreen = AccountSyncScreen;
window.PlanSheet = PlanSheet;
window.SubscriptionScreen = SubscriptionScreen;
window.REMINDER_TIMES = REMINDER_TIMES;
