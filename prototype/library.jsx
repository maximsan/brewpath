// library.jsx — Module detail screen (two layouts), Saved / Favorites screen,
// and the bookmark affordances shared across the app.
// Loaded after screens.jsx so MODULES / LESSONS / COLLECTIBLES / MINI_GAMES exist.

const { useState: useStateLib } = React;

// ── Bookmark glyph + button ──────────────────────────────────
// `style` picks the visual treatment for the filled state; falls back to a
// global set by the Tweaks panel (window.BOOKMARK_STYLE) so every call site
// stays in sync without threading a prop through every screen.
//   solid   — current: hard fill when saved (default)
//   tint    — soft accent-tint fill instead of a solid block
//   outline — never fills; a small dot marks the saved state
function Bookmark({ filled, size = 20, color = 'var(--accent)', style }) {
  const bstyle = style || (typeof window !== 'undefined' && window.BOOKMARK_STYLE) || 'solid';
  const d = "M5.5 3.5h9a1 1 0 0 1 1 1v12l-5.5-3.2-5.5 3.2v-12a1 1 0 0 1 1-1z";
  if (bstyle === 'tint') {
    return (
      <svg width={size} height={size} viewBox="0 0 20 20" fill="none" aria-hidden="true">
        <path d={d}
              fill={filled ? 'color-mix(in oklab, ' + color + ' 22%, transparent)' : 'none'}
              stroke={color} strokeWidth="1.5" strokeLinejoin="round"/>
      </svg>
    );
  }
  if (bstyle === 'outline') {
    return (
      <svg width={size} height={size} viewBox="0 0 20 20" fill="none" aria-hidden="true">
        <path d={d} fill="none" stroke={color} strokeWidth="1.5" strokeLinejoin="round"/>
        {filled && <circle cx="10" cy="8.4" r="1.5" fill={color}/>}
      </svg>
    );
  }
  return (
    <svg width={size} height={size} viewBox="0 0 20 20" fill="none" aria-hidden="true">
      <path d={d}
            fill={filled ? color : 'none'} stroke={color}
            strokeWidth="1.5" strokeLinejoin="round"/>
    </svg>
  );
}

// Round, hairline-bordered bookmark toggle used on rows, sheets and top bars.
function FavButton({ active, onClick, size = 38 }) {
  return (
    <button
      onClick={(e) => { e.stopPropagation(); onClick && onClick(); }}
      aria-pressed={active} aria-label={active ? 'Saved' : 'Save'}
      style={{
        appearance: 'none', cursor: 'pointer', background: 'transparent',
        border: '1px solid ' + (active ? 'var(--accent)' : 'var(--rule)'),
        borderRadius: 999, width: size, height: size,
        display: 'grid', placeItems: 'center', flexShrink: 0,
        transition: 'border-color 150ms ease, background 150ms ease',
      }}>
      <Bookmark filled={active} size={Math.round(size * 0.5)}
                color={active ? 'var(--accent)' : 'var(--ink-mute)'}/>
    </button>
  );
}

// Borderless (or ring, per the BOOKMARK_STYLE tweak) bookmark toggle used in
// top bars and detail headers — ONE definition so lesson, mini-game, game intro
// and dictionary headers all render an identical control under every tweak.
function TopBarFav({ active, onClick, label, style }) {
  const ring = (typeof window !== 'undefined' && window.BOOKMARK_STYLE) === 'ring';
  return (
    <button
      onClick={(e) => { e.stopPropagation(); onClick && onClick(); }}
      aria-pressed={!!active} aria-label={active ? 'Saved' : (label || 'Save')}
      style={{
        appearance: 'none', background: 'transparent', cursor: 'pointer',
        color: active ? 'var(--accent)' : 'var(--ink-mute)',
        ...(ring
          ? { border: '1px solid ' + (active ? 'var(--accent)' : 'var(--rule)'), borderRadius: 999, width: 32, height: 32, display: 'grid', placeItems: 'center' }
          : { border: 'none', padding: 4, display: 'flex', alignItems: 'center', justifyContent: 'center' }),
        ...(style || {}),
      }}>
      <Bookmark filled={!!active} size={ring ? 16 : 20} color={active ? 'var(--accent)' : 'var(--ink-mute)'}/>
    </button>
  );
}

// ── SAVED / FAVORITES SCREEN ──────────────────────────────────
function SavedIcon({ kind, cat, size = 22 }) {
  // Outline only: partial/full fill is reserved for the mastery gauge.
  if (kind === 'lesson') return <FlavorWheel size={size} filled={0} stroke={1} mute="var(--ink-mute)"/>;
  if (kind === 'term') {
    return window.CatGlyph ? <window.CatGlyph cat={cat} size={size} color="var(--ink-mute)"/> : null;
  }
  if (kind === 'visualGuide') {
    return window.TuneMark ? <window.TuneMark size={size - 2} color="var(--ink-mute)"/> : null;
  }
  if (kind === 'card') {
    // Canonical "cards" mark — the rotated two-card stack from the nav family
    // (window.IconCards), reused so a card collection reads the same everywhere.
    return window.IconCards
      ? <window.IconCards size={size} active={false} mute="var(--ink-mute)"/>
      : null;
  }
  // game
  return (
    <svg width={size} height={size} viewBox="0 0 20 20" fill="none" style={{ color: 'var(--ink-mute)' }} aria-hidden="true">
      <circle cx="10" cy="10" r="6.5" stroke="currentColor" strokeWidth="1.4"/>
      <circle cx="10" cy="10" r="2.4" stroke="currentColor" strokeWidth="1.4"/>
    </svg>
  );
}

function SavedRow({ kind, cat, sub, title, meta, onOpen, onToggleFav }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 0', borderBottom: '1px solid var(--rule)' }}>
      <button onClick={onOpen} style={{
        flex: 1, minWidth: 0, appearance: 'none', border: 'none', background: 'transparent',
        cursor: 'pointer', textAlign: 'left', padding: 0,
        display: 'grid', gridTemplateColumns: '24px 1fr auto', alignItems: 'center', gap: 14,
      }}>
        <SavedIcon kind={kind} cat={cat}/>
        <span style={{ minWidth: 0 }}>
          <span className="ff-mono" style={{ display: 'block', fontSize: 'var(--t-micro)', letterSpacing: '0.14em', color: 'var(--ink-mute)', textTransform: 'uppercase' }}>{sub}</span>
          <span style={{ display: 'block', fontSize: 'var(--t-body)', color: 'var(--ink)', fontWeight: 500, marginTop: 2, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{title}</span>
        </span>
        {meta && (
          <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.1em', color: 'var(--ink-mute)', textTransform: 'uppercase', whiteSpace: 'nowrap' }}>{meta}</span>
        )}
      </button>
      {/* Keeps the RING. Every row here is saved by definition, so a mark would
          state the obvious — and this is the curation screen, the one place
          removal must stay reachable (dictionary rows gave theirs up, §14).
          Stripping the ring was tried and reverted: it made this control look
          identical to that non-interactive mark — same glyph, colour and size,
          different behaviour. One appearance must not carry two meanings. */}
      <FavButton size={34} active onClick={onToggleFav}/>
    </div>
  );
}

function SavedScreen({ favorites, savedMax, isPlus, onUpgrade, onToggleFav, onLesson, onOpenTerm, onOpenGuide, onFlashcards, onClose }) {
  const [scrolled, onScroll] = window.useScrollFlag(72);
  const favs = favorites || new Set();
  const lessons = [];
  (window.MODULES || []).forEach(m => m.lessons.forEach(l => {
    if (favs.has('l:' + l.id)) lessons.push({ ...l, mod: m });
  }));
  const terms = (window.DICT_TERMS || []).filter(t => favs.has('t:' + t.id));
  const guides = Object.values(window.VISUAL_GUIDE_CONTENT || {}).filter(t => favs.has('g:' + t.id));
  const totalCount = lessons.length + terms.length + guides.length;
  // Free users see their shelf against the cap; owners just see a count.
  const capped = !isPlus && savedMax != null;
  const atCap = capped && totalCount >= savedMax;

  const groups = [
    { id: 'terms', label: 'Dictionary terms', items: terms.map(t => ({
        key: 't:' + t.id, kind: 'term', title: t.term, cat: t.cat,
        sub: ((window.DICT_CAT_BY_ID || {})[t.cat] || {}).label || 'TERM', meta: '', onOpen: () => onOpenTerm(t.id),
      })) },
    { id: 'lessons', label: 'Lessons', items: lessons.map(l => ({
        key: 'l:' + l.id, kind: 'lesson', title: l.title,
        sub: 'MODULE ' + l.mod.n + ' · ' + l.mod.label,
        meta: '', onOpen: () => onLesson(l.id),
      })) },
    { id: 'guides', label: 'Visual guides', items: guides.map(t => ({
        key: 'g:' + t.id, kind: 'visualGuide', title: t.title,
        sub: 'VISUAL GUIDE · ' + t.label,
        meta: '', onOpen: () => onOpenGuide && onOpenGuide(t.id),
      })) },
  ].filter(g => g.items.length);

  return (
    <div className="screen" data-screen-label="Saved" style={{ background: 'var(--bg)' }}>
      {window.SubScreenHeader && <window.SubScreenHeader scrolled={scrolled} title="Favorites" onBack={onClose}/>}
      <div className="scroll" onScroll={onScroll} style={{ paddingTop: 108, paddingBottom: 28 }}>
        <div className="px-24">
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>Favorites</h1>
          {/* Only the CAPPED form earns this line. "6 items to revisit" is the
              sum of the per-group counts already on screen, dressed in filler —
              it restates what the page shows. "3 of 5 saved" is the free shelf
              limit, which nothing else states and which the upgrade prompt
              below depends on. */}
          {capped && (
            <div className="ff-mono" style={{ fontSize: 'var(--t-label)', color: 'var(--ink-mute)', marginTop: 8, letterSpacing: '0.08em', textTransform: 'uppercase' }}>
              {totalCount <= savedMax
                ? totalCount + ' of ' + savedMax + ' saved'
                : totalCount + ' saved \u00b7 free limit ' + savedMax}
            </div>
          )}
          {atCap && (
            <button onClick={onUpgrade} style={{
              marginTop: 16, width: '100%', appearance: 'none', cursor: 'pointer', textAlign: 'left',
              display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12,
              background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 12, padding: '13px 15px',
            }}>
              <span style={{ fontSize: 'var(--t-support)', lineHeight: 1.45, color: 'var(--ink-mute)', textWrap: 'pretty' }}>
                Your shelf is full. <span style={{ color: 'var(--ink)', fontWeight: 500 }}>Unlock Foundations</span> to save without a limit.
              </span>
              <window.Chevron color="var(--accent)" opacity={1}/>
            </button>
          )}

        </div>

        {totalCount === 0 ? (
          <div className="px-24" style={{ paddingTop: 60, display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center' }}>
            <div style={{ opacity: 0.55, marginBottom: 18 }}><Bookmark size={44} color="var(--ink-mute)"/></div>
            <p style={{ margin: 0, fontSize: 'var(--t-body)', lineHeight: 1.6, color: 'var(--ink-mute)', maxWidth: 280, textWrap: 'pretty' }}>
              Nothing saved yet. Tap the bookmark on any lesson, term or visual guide and it lands here for quick review.
            </p>
          </div>
        ) : (
          <div className="px-24" style={{ paddingTop: 22 }}>
            {groups.map((g, gi) => (
              <div key={g.id} style={{ marginTop: gi === 0 ? 0 : 26 }}>
                {/* The flashcards route lives on the TERMS group header, not on
                    the page title: the deck is built from saved terms only, so
                    beside "Favorites" it read as covering lessons and guides too
                    — and it already appears and disappears with terms existing.
                    Demoted from a full-width accent banner, which outweighed the
                    rows it sat above for a secondary route. The count stays on
                    the label, so the button only has to name the destination. */}
                {/* STICKY, seated directly under the nav bar. At 6 saved terms
                    the header is decoration; at 25 the group runs several
                    screens and both the count AND which group you are in scroll
                    away — pinning the header answers both without adding an
                    element, and keeps the Flashcards route reachable from
                    anywhere in the list. Preferred over a paginated-looking
                    footer count: everything here is already rendered, so a
                    pagination affordance would promise a page that never comes.
                    Count INSIDE the label — "Dictionary terms · 6", the app's
                    standing form (FOR LATER · n, LESSONS · 1, §3); a loose digit
                    in its own type style read as a stray value. Label and action
                    are the two flex children, so the action is pinned right
                    structurally, not by a margin. */}
                {/* top: 0, NOT HEADER_H. Sticky resolves its offset against the
                    scroll container's padding box, and .scroll already carries
                    paddingTop: HEADER_PAD (108) to clear the 96px bar — so
                    top: 96 double-counted it, pinning at 204 and shoving the
                    header 42px DOWN out of flow at rest, on top of row 1. At
                    top: 0 it pins 108 from the scrollport (12px under the bar)
                    and stays put until the group actually scrolls. */}
                <div style={{
                  // DERIVED, never hand-picked: window.STICKY_SECTION_TOP is
                  // (bar + its fade) − the scroll container's paddingTop, which
                  // is exactly the fade's bottom edge. Picking a number by eye
                  // failed twice — 0 pinned the header inside the fade (dimmed,
                  // previous row showing through) and 22 overshot it, stranding
                  // a clean 12px slice of the scrolling row above the header.
                  position: 'sticky', top: (window.STICKY_SECTION_TOP != null ? window.STICKY_SECTION_TOP : -12), zIndex: 20,
                  // Equal air above and below the label. It previously pinned at
                  // the FADE's bottom edge, which left the 22px fade band above
                  // the header as dead space: 30px over the label against 6px
                  // under it, reading as two stacked header sections divided by
                  // the bar's rule. Seating flush under the bar and padding
                  // symmetrically makes it one block.
                  background: 'var(--bg)', paddingTop: 12, paddingBottom: 12,
                  // The pinned header seats at the FADE's bottom edge, which
                  // leaves the band between the bar and the fade showing raw
                  // scrolling rows — a slice of the previous row floating above
                  // the header. This upward solid shadow paints that band in
                  // page background: it covers the gap without touching layout,
                  // so nothing shifts at rest and no numeric offset changes.
                  boxShadow: '0 -' + ((window.HEADER_FADE_H || 22) + 2) + 'px 0 var(--bg)',
                  display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: 10 }}>
                  <span className="smallcaps" style={{ minWidth: 0 }}>{g.label} · {g.items.length}</span>
                  {g.id === 'terms' && onFlashcards && (
                    <button onClick={onFlashcards} aria-label={'Study ' + g.items.length + ' saved terms as flashcards'} style={{
                      appearance: 'none', cursor: 'pointer', flexShrink: 0,
                      background: 'transparent', border: 'none', color: 'var(--accent-text)',
                      // Type-weight, not object-weight: a pill with a border and
                      // an icon outweighed the smallcaps label it sits beside,
                      // so the secondary route read louder than the group it
                      // belongs to. Now it matches the label exactly and differs
                      // only in colour. Padding buys the tap target back without
                      // adding visible mass; negative margins keep the baseline
                      // and the right edge aligned with the rows below.
                      padding: '10px 0 10px 14px', margin: '-10px 0',
                      display: 'inline-flex', alignItems: 'baseline', gap: 7,
                    }}>
                      <span className="smallcaps" style={{ color: 'inherit' }}>FLASHCARDS</span>
                      <svg width="13" height="9" viewBox="0 0 14 10" aria-hidden="true" style={{ alignSelf: 'center' }}><path d="M1 5h11M8 1l4 4-4 4" fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round"/></svg>
                    </button>
                  )}
                </div>
                {g.items.map(it => (
                  <SavedRow key={it.key} kind={it.kind} cat={it.cat} sub={it.sub} title={it.title} meta={it.meta}
                            onOpen={it.onOpen} onToggleFav={() => onToggleFav(it.key)}/>
                ))}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

window.Bookmark = Bookmark;
window.FavButton = FavButton;
window.TopBarFav = TopBarFav;
window.SavedScreen = SavedScreen;
