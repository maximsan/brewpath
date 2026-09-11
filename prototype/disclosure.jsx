// disclosure.jsx — the ONE disclosure. Owns the header button, the glyph, the
// open/close animation and the keyboard/ARIA contract for every expandable
// section in the app. Before this, seven sites hand-rolled the row around the
// DS Caret icon and drifted into three dialects.
//
// Two glyphs, on purpose:
//   caret — LISTS. Things that were already countable before you opened them
//           (practice groups, modules, a review set). The caret says "more of
//           the same, below".
//   plus  — PROSE. An FAQ answer, where nothing was hidden until you asked.
//           The plus says "there is an answer here", not "there are N things".
// Everything else — timing, easing, focus, the collapsed-content trap — is shared.

const DISC_MS = 240;
const DISC_EASE_PANEL = 'cubic-bezier(.2,.8,.2,1)';
const DISC_EASE_GLYPH = 'cubic-bezier(.4,0,.2,1)';

function DisclosureGlyph({ glyph = 'caret', open, size, color = 'var(--ink-mute)', duration = DISC_MS }) {
  if (glyph === 'none') return null;
  const tr = { transform: open ? (glyph === 'plus' ? 'rotate(45deg)' : 'rotate(180deg)') : 'none', transition: 'transform ' + duration + 'ms ' + DISC_EASE_GLYPH };
  if (glyph === 'plus') {
    const s = size || 12;
    return (
      <svg width={s} height={s} viewBox="0 0 12 12" aria-hidden="true" style={{ flex: 'none', ...tr }}>
        <path d="M6 1v10M1 6h10" stroke={color} strokeOpacity="0.7" strokeWidth="1.4" strokeLinecap="round"/>
      </svg>
    );
  }
  const s = size || 18;
  return (
    <svg width={s} height={s} viewBox="0 0 20 20" aria-hidden="true" style={{ flex: 'none', color, ...tr }}>
      <path d="M5 8 L10 13 L15 8" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

function Disclosure({
  label, header, below, trailing,
  glyph = 'caret', glyphSize, glyphColor, trailingGap = 9,
  open: openProp, defaultOpen = false, onToggle, openSignal,
  // collapsible=false renders the header as a plain div and leaves the panel
  // open: Path's active module is a section heading, not a toggle, and a
  // disabled button that never does anything is a focus stop for nothing.
  collapsible = true,
  animate = true, duration = DISC_MS,
  divider = false, ariaLabel, headerAlign = 'center', headerPad = '16px 0',
  style, headerStyle, panelStyle, children,
}) {
  const [openS, setOpenS] = React.useState(!!defaultOpen);
  React.useEffect(() => { if (openSignal) setOpenS(true); }, [openSignal]);
  const controlled = openProp !== undefined;
  const open = !collapsible ? true : (controlled ? !!openProp : openS);
  const toggle = () => { if (controlled) { onToggle && onToggle(); } else { setOpenS(o => !o); } };

  const row = (
    <React.Fragment>
      <div style={{ display: 'flex', alignItems: headerAlign, justifyContent: 'space-between', gap: 12, width: '100%' }}>
        {header || <span style={{ fontSize: 'var(--t-body)', color: 'var(--ink)' }}>{label}</span>}
        {(trailing || collapsible) && (
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: trailingGap, flexShrink: 0 }}>
            {trailing}
            {collapsible && <DisclosureGlyph glyph={glyph} open={open} size={glyphSize} color={glyphColor} duration={duration}/>}
          </span>
        )}
      </div>
      {below}
    </React.Fragment>
  );

  const baseHead = { width: '100%', appearance: 'none', border: 'none', background: 'transparent', textAlign: 'left', padding: headerPad, display: 'block', font: 'inherit', color: 'inherit', ...headerStyle };

  const panelInner = { overflow: 'hidden', minHeight: 0 };

  return (
    <div style={{ borderBottom: divider ? '1px solid var(--rule)' : undefined, ...style }}>
      {collapsible
        ? <button type="button" onClick={toggle} aria-expanded={open} aria-label={ariaLabel} style={{ ...baseHead, cursor: 'pointer' }}>{row}</button>
        : <div style={baseHead}>{row}</div>}
      {animate ? (
        <div style={{ display: 'grid', gridTemplateRows: open ? '1fr' : '0fr', transition: 'grid-template-rows ' + duration + 'ms ' + DISC_EASE_PANEL }}>
          {/* panelStyle padding sits INSIDE the clipped box, so a collapsed
              panel contributes no height — the old `{open && …}` sites removed
              the node outright and must not gain a few dead pixels here.
              visibility (delayed until the collapse finishes) keeps collapsed
              content out of the tab order — a 0fr grid row still focuses. */}
          <div style={{ ...panelInner, visibility: open ? 'visible' : 'hidden', transition: 'visibility 0s linear ' + (open ? 0 : duration) + 'ms' }}><div style={panelStyle}>{children}</div></div>
        </div>
      ) : (open ? <div style={panelStyle}>{children}</div> : null)}
    </div>
  );
}

window.Disclosure = Disclosure;
window.DisclosureGlyph = DisclosureGlyph;
window.DISCLOSURE_MS = DISC_MS;
