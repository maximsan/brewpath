// library.jsx — Module detail screen (two layouts), Saved / Favorites screen,
// and the bookmark affordances shared across the app.
// Loaded after screens.jsx so MODULES / LESSONS / COLLECTION / MINI_GAMES exist.

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

// ── Status helper ─────────────────────────────────────────────
function moduleLessonStatus(module, lesson, completedSet) {
  if (module.locked) return 'locked';
  if ((completedSet && completedSet.has(lesson.id)) || lesson.status === 'complete') return 'complete';
  if (lesson.status === 'current') return 'current';
  return 'locked';
}

// A small status pill. A finished lesson at or above the pass mark gets NO chip
// — its bean node already says how full the run was; the only lesson label left
// is the one you can act on.
function StatusChip({ st, mastery }) {
  const key = st === 'complete'
    ? (mastery === 'needs-practice' ? 'practice' : null)
    : st;
  if (!key) return null;
  const map = {
    practice: ['PRACTICE', 'var(--accent)'],
    current:  ['CURRENT',  'var(--accent)'],
    locked:   ['LOCKED',   'var(--ink-mute)'],
  };
  const [label, color] = map[key] || map.locked;
  return (
    <span className="ff-mono" style={{
      fontSize: 'var(--t-micro)', letterSpacing: '0.16em', textTransform: 'uppercase',
      color, display: 'inline-flex', alignItems: 'center', gap: 6,
    }}>
      <span style={{ width: 6, height: 6, borderRadius: 999,
        background: key === 'locked' ? 'transparent' : color,
        border: '1px solid ' + color }}/>
      {label}
    </span>
  );
}

function IconLockSmall({ color = 'var(--ink-mute)' }) {
  return (
    <svg width="16" height="16" viewBox="0 0 20 20" style={{ color }} aria-hidden="true">
      <rect x="4.5" y="8.5" width="11" height="8" rx="1.6" fill="none" stroke="currentColor" strokeWidth="1.5"/>
      <path d="M7 8.5 V6.5 a3 3 0 0 1 6 0 V8.5" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
    </svg>
  );
}

// ── Module reward preview ─────────────────────────────────────
// The collectible "field guide" card you earn for finishing the module.
// Earned → tinted, with the badge. Not yet → dashed, locked note.
function ModuleRewardPreview({ reward, earned, total, onOpen }) {
  if (!reward) return null;
  if (earned) {
    const Tag = onOpen ? 'button' : 'div';
    return (
      <Tag
        onClick={onOpen || undefined}
        style={{
          display: 'block', width: '100%', textAlign: 'left', appearance: 'none', font: 'inherit',
          cursor: onOpen ? 'pointer' : 'default',
          borderRadius: 14, overflow: 'hidden',
          border: '1px solid color-mix(in oklab, var(--accent) 26%, var(--rule))',
          background: 'linear-gradient(160deg, color-mix(in oklab, var(--accent) 12%, var(--surface)) 0%, var(--surface) 62%)',
          padding: '20px 20px 18px',
          boxShadow: '0 14px 34px rgba(0,0,0,0.18)',
        }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <span className="smallcaps" style={{ color: 'var(--accent)' }}>CARD UNLOCKED</span>
          <FlavorStamp size={30} rotate={-6}/>
        </div>
        <h3 className="ff-display" style={{
          fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em',
          margin: '12px 0 0', color: 'var(--ink)',
        }}>{reward.title}</h3>
        <p style={{ margin: '8px 0 0', fontSize: 'var(--t-body)', lineHeight: 1.5, color: 'var(--ink-mute)', textWrap: 'pretty' }}>
          {reward.summary}
        </p>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12, marginTop: 14 }}>
          <span className="ff-mono" style={{
            fontSize: 'var(--t-micro)', letterSpacing: '0.16em', textTransform: 'uppercase',
            color: 'var(--accent)',
            border: '1px solid color-mix(in oklab, var(--accent) 40%, var(--rule))',
            borderRadius: 999, padding: '5px 11px',
          }}>{reward.badge}</span>
          {onOpen && (
            <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.12em', textTransform: 'uppercase', color: 'var(--ink-mute)', whiteSpace: 'nowrap', display: 'flex', alignItems: 'center', gap: 6 }}>
              View in collection
              <window.Chevron color="currentColor" opacity={1}/>
            </span>
          )}
        </div>
      </Tag>
    );
  }
  return (
    <div style={{
      borderRadius: 14, border: '1.5px dashed var(--rule)', background: 'transparent',
      padding: '20px', display: 'flex', alignItems: 'center', gap: 16,
    }}>
      <div style={{ flexShrink: 0, opacity: 0.6 }}><FlavorStamp size={42} rotate={-6}/></div>
      <div>
        <div className="smallcaps" style={{ marginBottom: 6 }}>MODULE REWARD</div>
        <div className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, letterSpacing: '-0.01em', color: 'var(--ink)', lineHeight: 1.1 }}>
          {reward.title}
        </div>
        <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 5 }}>
          Finish all {total} lessons to collect this card.
        </div>
      </div>
    </div>
  );
}

// ── MODULE SCREEN ─────────────────────────────────────────────
// A dedicated screen for one module: header + progress, the reward card,
// and the lesson list. Two layouts, switchable via the Tweaks panel:
//   'cover' — editorial, card-forward
// A dedicated screen for one module: header + progress, the lesson list,
// then the collectible reward card.
function ModuleScreen({ module, completedSet, favorites, onToggleFav, onLesson, onClose, onOpenReward, variant = 'current' }) {
  const reward = (window.MODULE_REWARDS || {})[module.id];
  const lessons = module.lessons.map(l => ({ ...l, st: moduleLessonStatus(module, l, completedSet) }));
  const done = lessons.filter(l => l.st === 'complete').length;
  const total = lessons.length;
  const earned = total > 0 && done === total;
  const frac = total ? done / total : 0;
  const num = String(module.n).padStart(2, '0');
  const isFav = (id) => !!(favorites && favorites.has('l:' + id));

  const topbar = (
    <div className="lesson-topbar" style={{ borderBottom: 'none', background: 'transparent' }}>
      <button className="close-btn" onClick={onClose} aria-label="Back">
        <window.BackMark/>
      </button>
      <div/><div/>
    </div>
  );

  // ───────── SLIM / repurposed layout ─────────
  // Job: peek at a module you're not in (what you'll learn + the card you'll
  // earn) or review a finished one. No per-lesson points/time/bookmark noise.
  if (variant === 'focused') {
    const allLocked = lessons.every(l => l.st === 'locked');
    return (
      <div className="screen" data-screen-label="Module" style={{ background: 'var(--bg)' }}>
        {topbar}
        <div className="scroll" style={{ paddingTop: 108, paddingBottom: 28 }}>
          <div className="px-24">
            <div className="smallcaps" style={{ color: 'var(--accent)', marginBottom: 8 }}>MODULE {num}</div>
            <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.04, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>{module.title}</h1>
            <div className="ff-mono" style={{ fontSize: 'var(--t-label)', color: 'var(--ink-mute)', marginTop: 10, letterSpacing: '0.08em', textTransform: 'uppercase' }}>
              {earned ? 'Module complete' : allLocked ? `${total} lessons · locked` : `${done} of ${total} lessons`}
            </div>
          </div>

          {!allLocked && !earned && (
            <div className="px-24" style={{ paddingTop: 20 }}>
              <div style={{ height: 8, background: 'var(--surface-2)', borderRadius: 999, overflow: 'hidden' }}>
                <div style={{ height: '100%', width: (frac * 100) + '%', background: 'var(--accent)', borderRadius: 999, transition: 'width 800ms cubic-bezier(.2,.9,.3,1)' }}/>
              </div>
            </div>
          )}

          {/* the motivating hook — the card this module earns you */}
          <div className="px-24" style={{ paddingTop: 26 }}>
            <ModuleRewardPreview reward={reward} earned={earned} total={total} onOpen={earned ? onOpenReward : undefined}/>
          </div>

          {/* lessons — title + status only */}
          <div className="px-24" style={{ paddingTop: 30 }}>
            <div className="smallcaps" style={{ marginBottom: 6 }}>{allLocked ? 'WHAT YOU’LL LEARN' : 'LESSONS'}</div>
            <div>
              {lessons.map((l) => {
                const locked = l.st === 'locked';
                const scored = l.st === 'complete' && l.masteryPct != null;
                const weak = scored && l.mastery === 'needs-practice';
                // Same gauge as the Path: the bean fills to the best-score ratio,
                // and an unscored completion reads neutral rather than perfect.
                const filled = scored ? Math.max(12, Math.round(l.masteryPct * 100))
                  : (l.st === 'current' ? 45 : 0);
                const beanColor = l.st === 'complete' && !scored ? 'var(--ink-mute)'
                  : (l.st === 'current' || weak ? 'var(--accent)' : 'var(--sage)');
                return (
                  <button key={l.id} type="button"
                    onClick={() => !locked && onLesson(l.id)} disabled={locked}
                    style={{
                      width: '100%', display: 'grid', gridTemplateColumns: '30px 1fr auto', alignItems: 'center', gap: 14,
                      padding: '15px 0', borderBottom: '1px solid var(--rule)', appearance: 'none', borderLeft: 'none', borderRight: 'none', borderTop: 'none',
                      background: 'transparent', cursor: locked ? 'default' : 'pointer', textAlign: 'left', opacity: locked ? 0.5 : 1,
                    }}>
                    <FlavorWheel size={28} filled={filled} total={100} stroke={1} color={beanColor}/>
                    <span style={{ minWidth: 0 }}>
                      <span style={{ display: 'block', fontSize: 'var(--t-body)', color: 'var(--ink)', fontWeight: 500, lineHeight: 1.25 }}>{l.title}</span>
                      {(l.st === 'current' || weak) && (
                        <span style={{ display: 'block', marginTop: 5 }}><StatusChip st={l.st} mastery={l.mastery}/></span>
                      )}
                    </span>
                    {locked
                      ? <IconLockSmall/>
                      : false
                        ? null
                        : <window.Chevron/>}
                  </button>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    );
  }

  // ───────── COVER layout ─────────
  return (
    <div className="screen" data-screen-label="Module" style={{ background: 'var(--bg)' }}>
      {topbar}
      <div className="scroll" style={{ paddingTop: 108, paddingBottom: 28 }}>
        {/* module number + title */}
        <div className="px-24">
          <div className="smallcaps" style={{ color: 'var(--accent)', marginBottom: 8 }}>MODULE</div>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 12 }}>
            <span className="ff-mono" style={{ fontSize: 'var(--t-title)', fontWeight: 500, lineHeight: 1, letterSpacing: '-0.01em', color: 'color-mix(in oklab, var(--accent) 75%, var(--ink))' }}>{num}</span>
            <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>{module.title}</h1>
          </div>
        </div>

        {/* progress meter */}
        <div className="px-24" style={{ paddingTop: 26 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 8 }}>
            <span className="smallcaps">{earned ? 'MODULE COMPLETE' : 'PROGRESS'}</span>
            <span className="ff-mono" style={{ fontSize: 'var(--t-label)', color: 'var(--ink-mute)', letterSpacing: '0.08em' }}>{done} of {total} lessons</span>
          </div>
          <div style={{ height: 8, background: 'var(--surface-2)', borderRadius: 999, overflow: 'hidden' }}>
            <div style={{ height: '100%', width: (frac * 100) + '%', background: 'var(--accent)', borderRadius: 999, transition: 'width 800ms cubic-bezier(.2,.9,.3,1)' }}/>
          </div>
        </div>

        {/* lessons — placed before the reward */}
        <div className="px-24" style={{ paddingTop: 26 }}>
          <div className="smallcaps" style={{ marginBottom: 6 }}>LESSONS</div>
          <div>
            {lessons.map((l) => {
              const locked = l.st === 'locked';
              const scored = l.st === 'complete' && l.masteryPct != null;
              const weak = scored && l.mastery === 'needs-practice';
              const filled = scored ? Math.max(12, Math.round(l.masteryPct * 100))
                : (l.st === 'current' ? 45 : 0);
              const beanColor = l.st === 'complete' && !scored ? 'var(--ink-mute)'
                : (l.st === 'current' || weak ? 'var(--accent)' : 'var(--sage)');
              return (
                <div key={l.id} style={{
                  display: 'grid', gridTemplateColumns: '30px 1fr auto', alignItems: 'center', gap: 14,
                  padding: '16px 0', borderBottom: '1px solid var(--rule)', opacity: locked ? 0.42 : 1,
                }}>
                  <button
                    onClick={() => !locked && onLesson(l.id)}
                    disabled={locked}
                    style={{ display: 'contents', appearance: 'none', border: 'none', background: 'transparent', cursor: locked ? 'not-allowed' : 'pointer', textAlign: 'left', font: 'inherit', color: 'inherit' }}>
                    <FlavorWheel size={30} filled={filled} total={100} stroke={1} color={beanColor}/>
                    <span style={{ minWidth: 0 }}>
                      <span style={{ display: 'block', fontSize: 'var(--t-body)', color: 'var(--ink)', fontWeight: 500, lineHeight: 1.25 }}>{l.title}</span>
                      <span style={{ display: 'flex', alignItems: 'center', gap: 12, marginTop: 5 }}>
                        <StatusChip st={l.st} mastery={l.mastery}/>
                      </span>
                    </span>
                  </button>
                  {locked
                    ? <IconLockSmall/>
                    : <FavButton size={36} active={isFav(l.id)} onClick={() => onToggleFav('l:' + l.id)}/>}
                </div>
              );
            })}
          </div>
        </div>

        {/* reward card — below the lessons */}
        <div className="px-24" style={{ paddingTop: 30 }}>
          <ModuleRewardPreview reward={reward} earned={earned} total={total} onOpen={earned ? onOpenReward : undefined}/>
        </div>
      </div>
    </div>
  );
}

// ── SAVED / FAVORITES SCREEN ──────────────────────────────────
function SavedIcon({ kind, cat, size = 22 }) {
  // Outline only: partial/full fill is reserved for the mastery gauge.
  if (kind === 'lesson') return <FlavorWheel size={size} filled={0} stroke={1} mute="var(--ink-mute)"/>;
  if (kind === 'term') {
    return window.CatGlyph ? <window.CatGlyph cat={cat} size={size} color="var(--ink-mute)"/> : null;
  }
  if (kind === 'guide') {
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
  const guides = Object.values(window.TRAINING || {}).filter(t => favs.has('g:' + t.id));
  const totalCount = lessons.length + terms.length + guides.length;
  // Free users see their shelf against the cap; Plus users just see a count.
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
        key: 'g:' + t.id, kind: 'guide', title: t.title,
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
          <div className="ff-mono" style={{ fontSize: 'var(--t-label)', color: 'var(--ink-mute)', marginTop: 8, letterSpacing: '0.08em', textTransform: 'uppercase' }}>
            {capped
              ? (totalCount <= savedMax
                  ? totalCount + ' of ' + savedMax + ' saved'
                  : totalCount + ' saved \u00b7 free limit ' + savedMax)
              : totalCount + ' ' + (totalCount === 1 ? 'item' : 'items') + ' to revisit'}
          </div>
          {atCap && (
            <button onClick={onUpgrade} style={{
              marginTop: 16, width: '100%', appearance: 'none', cursor: 'pointer', textAlign: 'left',
              display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12,
              background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 12, padding: '13px 15px',
            }}>
              <span style={{ fontSize: 'var(--t-support)', lineHeight: 1.45, color: 'var(--ink-mute)', textWrap: 'pretty' }}>
                Your shelf is full. <span style={{ color: 'var(--ink)', fontWeight: 500 }}>Unlock Plus</span> to save without a limit.
              </span>
              <window.Chevron color="var(--accent)" opacity={1}/>
            </button>
          )}
          {terms.length > 0 && onFlashcards && (
            <button onClick={onFlashcards} style={{
              marginTop: 16, width: '100%', appearance: 'none', cursor: 'pointer', textAlign: 'left',
              display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12,
              background: 'color-mix(in oklab, var(--accent) 9%, var(--surface))',
              border: '1px solid color-mix(in oklab, var(--accent) 24%, var(--rule))', borderRadius: 12, padding: '13px 15px',
            }}>
              <span style={{ display: 'flex', alignItems: 'center', gap: 11 }}>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" style={{ color: 'var(--accent)' }}><rect x="3" y="6" width="14" height="12" rx="2" stroke="currentColor" strokeWidth="1.6"/><path d="M7 9.5h6M7 12.5h4" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/><path d="M9 4.5h9a2 2 0 0 1 2 2v9" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" opacity="0.5"/></svg>
                <span style={{ fontSize: 'var(--t-support)', color: 'var(--ink)', fontWeight: 500 }}>Study {terms.length} {terms.length === 1 ? 'term' : 'terms'} as flashcards</span>
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
                <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, marginBottom: 4 }}>
                  <span className="smallcaps">{g.label}</span>
                  <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.12em', color: 'var(--ink-mute)' }}>{g.items.length}</span>
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
window.ModuleScreen = ModuleScreen;
window.SavedScreen = SavedScreen;
