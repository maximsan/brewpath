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
// sheet behaviour is changed once. ConfirmSheet and TimeSheet wrap it.
// No sheet carries an eyebrow — each opens on its title.
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

// ── TextField — THE free-text input for the whole app ─────────
// The dictionary search field without the glyph: surface fill, 1px rule,
// 12px radius, body Plex Sans. Focus swaps the border to accent — no glow.
function TextField({ value, onChange, placeholder, maxLength, autoFocus, ariaLabel, onSubmit }) {
  const ref = React.useRef(null);
  const [focus, setFocus] = useStateS(false);
  useEffectS(() => { if (autoFocus && ref.current) { const t = setTimeout(() => ref.current.focus(), 120); return () => clearTimeout(t); } }, [autoFocus]);
  return (
    <div style={{ display: 'flex', alignItems: 'center', background: 'var(--surface)', border: '1px solid ' + (focus ? 'var(--accent)' : 'var(--rule)'), borderRadius: 12, padding: '13px 16px', transition: 'border-color 140ms ease' }}>
      <input ref={ref} value={value} maxLength={maxLength} aria-label={ariaLabel || placeholder}
        onChange={(e) => onChange(e.target.value)}
        onKeyDown={(e) => { if (e.key === 'Enter' && onSubmit) onSubmit(); }}
        onFocus={() => setFocus(true)} onBlur={() => setFocus(false)}
        placeholder={placeholder}
        style={{ flex: 1, minWidth: 0, appearance: 'none', border: 'none', outline: 'none', background: 'transparent', font: 'inherit', fontFamily: 'IBM Plex Sans, sans-serif', fontSize: 'var(--t-body)', color: 'var(--ink)' }}/>
    </div>
  );
}

// ── NameSheet — edit the display name (Settings → Name) ──────
function NameSheet({ open, value, onClose, onSave }) {
  const [name, setName] = useStateS(value || '');
  useEffectS(() => { if (open) setName(value || ''); }, [open, value]);
  const clean = name.trim();
  const save = () => { if (clean) { onSave(clean); onClose(); } };
  return (
    <Sheet open={open} onClose={onClose}>
          <SheetTitle>Your name</SheetTitle>
          <p style={{ margin: '12px 0 0', fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink-mute)' }}>
            How Roasty greets you, here and anywhere the app speaks to you.
          </p>
          <div style={{ marginTop: 18 }}>
            <TextField value={name} onChange={setName} placeholder="Your first name" maxLength={24} autoFocus={open} ariaLabel="Your name" onSubmit={save}/>
          </div>
          <button className="btn btn-primary" style={{ marginTop: 22 }} disabled={!clean} onClick={save}>Save name</button>
    </Sheet>
  );
}

// ── SettingsRow — THE settings/nav row for the whole app ──────
// One implementation, six trailing variants: value, chevron, external arrow,
// toggle, pending spinner, and destructive. Settings, About, Account and sync,
// Help and support and Purchases all render through this; `SettingsRow` in
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

// Floating close/back over full-bleed screens (reward ceremonies, paywall,
// atlas pages): transparent at rest, standard header chrome on scroll.
function FloatTopbar({ scrolled, onBack, back = false, label, right = null }) {
  return (
    <div className="lesson-topbar" style={{
      background: scrolled ? HEADER_FILL : 'transparent',
      backdropFilter: scrolled ? HEADER_BLUR : 'none', WebkitBackdropFilter: scrolled ? HEADER_BLUR : 'none',
      borderBottom: '1px solid ' + (scrolled ? 'var(--rule)' : 'transparent'),
      transition: 'background 260ms ease, backdrop-filter 260ms ease, border-color 260ms ease',
    }}>
      <button className="close-btn" onClick={onBack} aria-label={label || (back ? 'Back' : 'Close')}>
        {back ? <window.BackMark/> : <window.CloseMark/>}
      </button>
      <div/>
      {right ? <div style={{ justifySelf: 'end' }}>{right}</div> : <div/>}
    </div>
  );
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
function AccountSyncScreen({ isPlus, onClose, onPurchases, onSignOut }) {
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
            }}>{(window.USER || {}).initial || '·'}</div>
            <div style={{ minWidth: 0 }}>
              <div style={{ fontSize: 'var(--t-body)', color: 'var(--ink)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{(window.USER || {}).email}</div>
              <div className="smallcaps" style={{ marginTop: 4 }}>{isPlus ? 'FOUNDATIONS · PURCHASED' : 'FREE'}</div>
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
          <div className="smallcaps" style={{ marginBottom: 4 }}>PURCHASES</div>
          <NavRow label={isPlus ? 'Foundations' : 'Unlock Foundations'} value={isPlus ? 'Purchased' : null} onClick={onPurchases}/>
        </div>

        <div className="px-24" style={{ paddingTop: 26 }}>
          <NavRow label="Sign out" accent onClick={onSignOut}/>
        </div>
      </div>
    </div>
  );
}

// ── PurchasesScreen ────────────────────────────────────────
// What's owned (or active), what's on offer, and Restore. Model-driven:
// monetization.jsx supplies the offer copy; the owned card renders from the
// PLAN that granted the entitlement (a lifetime purchase keeps its receipt
// even if the live model flips to subscription). Restore lives only where a
// purchase is on offer (the free state; the paywall carries its own link):
// the owned branch renders only when the app already knows the entitlement.
function PurchasesScreen({ owned, planId = 'lifetime', purchased = '8 May 2026', onClose, onUnlock, restoreOutcome = 'owned', onRestored }) {
  const mon = window.getMonetization();
  const plan = window.getPlan(planId);
  // Restore purchases is a split responsibility: iOS owns the Apple ID auth
  // sheet, StoreKit hands back a result, and it shows the user NOTHING. So the
  // three outcomes below are ours to state plainly — otherwise the row looks
  // broken on the two paths that don't end in an entitlement.
  const [restoring, setRestoring] = useStateS(false);
  const [restoreDone, setRestoreDone] = useStateS(null); // 'owned' | 'none' | 'error'
  const runRestore = () => {
    if (restoring) return;
    setRestoring(true);
    setTimeout(() => {
      setRestoring(false);
      const outcome = restoreOutcome === 'plus' ? 'owned' : restoreOutcome; // legacy tweak value
      setRestoreDone(outcome);
      if (outcome === 'owned' && onRestored) onRestored();
    }, 1500);
  };
  const RESTORE_RESULT = {
    owned: { title: 'Foundations is yours again.',
             body: 'We found your purchase on this Apple ID and restored it. Every module, the full Dictionary, unlimited Saved and the Studio are open on this device.' },
    none:  { title: 'No purchase on this Apple ID.',
             body: 'If you bought Foundations with a different Apple ID, sign in with that one and try again.' },
    error: { title: 'We couldn’t reach the store.',
             body: 'Check your connection and try again.' },
  };
  const ConfirmSheet = window.ConfirmSheet;
  // Matches the paywall's pitch exactly — the contents of the one purchase.
  const benefits = ['Modules 2–5, every lesson', 'The five premium practice formats', 'The complete Dictionary', 'Unlimited Saved', 'The Studio'];
  const [scrolled, onScroll] = useScrollFlag();

  return (
    <div className="screen" data-screen-label="Purchases" style={{ background: 'var(--bg)' }}>
      <BackBar onClose={onClose} title="Purchases" scrolled={scrolled}/>
      <div className="scroll" onScroll={onScroll} style={{ paddingTop: 108, paddingBottom: 40 }}>
        <div className="px-24">
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>Purchases</h1>
        </div>

        {/* Status. The card is a container for purchase facts — date, price,
            permanence — so it renders only when there IS a purchase. Free has
            none, so it uses the screen's own section grammar instead. */}
        {owned ? (
          <div className="px-24" style={{ paddingTop: 22 }}>
            <div style={{
              border: '1px solid color-mix(in oklab, var(--accent) 30%, var(--rule))',
              borderRadius: 2, padding: '18px 20px',
              background: 'linear-gradient(160deg, color-mix(in oklab, var(--accent) 12%, var(--surface)) 0%, var(--surface) 62%)',
            }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
                <span className="smallcaps" style={{ color: 'var(--accent)' }}>FOUNDATIONS{plan.kind === 'sub' ? ' · ' + plan.name.toUpperCase() : ''}</span>
                <span style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  <span style={{ width: 7, height: 7, borderRadius: 999, background: 'var(--sage)' }}/>
                  <span className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.08em', color: 'var(--ink-mute)', textTransform: 'uppercase' }}>{plan.ownedChip}</span>
                </span>
              </div>
              {/* One receipt line — date and price. "Owned" is the status chip's
                  job, permanence is the footer's; a card that says each once is
                  a receipt, one that says them thrice is a poster. */}
              <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 10 }}>
                {plan.receipt(purchased)}
              </div>
            </div>
          </div>
        ) : (
          <div className="px-24" style={{ paddingTop: 26 }}>
            <div className="smallcaps" style={{ marginBottom: 4 }}>FREE</div>
            <div style={{ fontSize: 'var(--t-body)', color: 'var(--ink)', padding: '16px 0' }}>All of Module 1, True or false, Match the facts and Name the origin, Flashcards and Guess the Term, and a Saved shelf of 5.</div>
          </div>
        )}

        {owned ? (
          <>
            {/* A subscription is manageable; a purchase is a fact. The manage
                row exists only where there IS a plan to manage. */}
            {plan.kind === 'sub' && (
              <div className="px-24" style={{ paddingTop: 12 }}>
                <NavRow label="Manage subscription" external onClick={() => {}}/>
              </div>
            )}
            <div className="px-24" style={{ paddingTop: 26 }}>
              <div className="smallcaps" style={{ marginBottom: 4 }}>INCLUDED</div>
              {benefits.map((b, i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 0', borderBottom: i < benefits.length - 1 ? '1px solid var(--rule)' : 'none' }}>
                  <svg width="15" height="15" viewBox="0 0 15 15"><path d="M3 8 L6.2 11 L12 4" fill="none" stroke="var(--sage)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>
                  <span style={{ fontSize: 'var(--t-body)', color: 'var(--ink)' }}>{b}</span>
                </div>
              ))}
            </div>

            <div className="px-24" style={{ paddingTop: 26, textAlign: 'center' }}>
              <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.12em', color: 'var(--ink-mute)', textTransform: 'uppercase', lineHeight: 1.6 }}>
                {plan.ownedFooter[0]}<br/>{plan.ownedFooter[1]}
              </div>
            </div>
          </>
        ) : (
          <>
            {/* No inline paywall: this screen manages purchases, it doesn't sell.
                Row register throughout — Unlock is a row to the paywall, Restore
                a row beside it. One group, one heading, no duplicate pitch. */}
            <div className="px-24" style={{ paddingTop: 26 }}>
              <div className="smallcaps" style={{ marginBottom: 4 }}>AVAILABLE</div>
              <NavRow label="Unlock Foundations" value={mon.offerValue} onClick={onUnlock}/>
              <NavRow label="Restore purchases" pending={restoring} pendingLabel="Restoring…" onClick={runRestore}/>
            </div>

            {/* Subject is the course, not the reader: a free user owns nothing and
                is billed nothing, so this cannot be phrased as their status. */}
            <div className="px-24" style={{ paddingTop: 26, textAlign: 'center' }}>
              <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.12em', color: 'var(--ink-mute)', textTransform: 'uppercase', lineHeight: 1.6 }}>
                {mon.purchasesFooter[0]}<br/>{mon.purchasesFooter[1]}
              </div>
            </div>
          </>
        )}
      </div>

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
// two contact routes. FAQ answers open inline — no dead-end rows. A function,
// not a const: the Foundations answer's tail comes from the active
// monetization model, so it must re-read on every render.
const FAQ_ITEMS = () => [
  { q: 'How does my streak work?', a: 'Finish at least one lesson a day to keep it alive. Every 7 days in a row you earn a streak freeze — you hold one at a time, and if you miss a day it\u2019s spent automatically, so your streak survives and that day shows as covered in your week. Nothing to switch on.' },
  { q: 'How does my tree grow?', a: 'Your tree tracks the core course only — it moves up a stage as you complete core lessons, through ten stages from bare seed to full harvest. Points from practice and reviews don’t grow it, and it never shrinks unless you reset your progress.' },
  { q: 'What does Foundations include?', a: 'Modules 2–5, the five premium practice formats, the complete Dictionary, unlimited Saved and the Studio. All of Module 1, True or false, Match the facts, Name the origin, Flashcards, Guess the Term and your streak are free. ' + window.getMonetization().faq },
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

function HelpSupportScreen({ onClose, onAppGuide }) {
  const [openIdx, setOpenIdx] = useStateS(-1);
  const [scrolled, onScroll] = useScrollFlag();
  return (
    <div className="screen" data-screen-label="Help and support" style={{ background: 'var(--bg)' }}>
      <BackBar onClose={onClose} title="Help and support" scrolled={scrolled}/>
      <div className="scroll" onScroll={onScroll} style={{ paddingTop: 108, paddingBottom: 40 }}>
        <div className="px-24">
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>Help and support</h1>
        </div>

        {onAppGuide && (
          <div className="px-24" style={{ paddingTop: 26 }}>
            <div className="smallcaps" style={{ marginBottom: 4 }}>LEARN THE APP</div>
            <NavRow label="App Guide" sub="What each part does, plus the Today intro" onClick={onAppGuide}/>
          </div>
        )}
        <div className="px-24" style={{ paddingTop: 26 }}>
          <div className="smallcaps" style={{ marginBottom: 4 }}>COMMON QUESTIONS</div>
          {FAQ_ITEMS().map((it, i) => (
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
window.FloatTopbar = FloatTopbar;
window.HeaderCompactTitle = HeaderCompactTitle;
window.HEADER_H = HEADER_H;
window.HEADER_PAD = HEADER_PAD;
window.useScrollFlag = useScrollFlag;
window.NavRow = NavRow;
window.ConfirmSheet = ConfirmSheet;
window.Sheet = Sheet;
window.SheetTitle = SheetTitle;
window.TimeSheet = TimeSheet;
window.NameSheet = NameSheet;
window.TextField = TextField;
window.AboutScreen = AboutScreen;
window.HelpSupportScreen = HelpSupportScreen;
window.AccountSyncScreen = AccountSyncScreen;
window.PurchasesScreen = PurchasesScreen;
window.REMINDER_TIMES = REMINDER_TIMES;
