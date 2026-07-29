// dictionary.jsx — Coffee Dictionary: home (3 layouts), term detail (2 layouts),
// the compact in-lesson term peek, and shared dictionary UI.
// Loaded after library.jsx (needs Bookmark / FavButton / FlavorWheel / FormRow),
// before app.jsx.

const { useState: useStateD, useEffect: useEffectD, useRef: useRefD, useMemo: useMemoD } = React;

// ── Pronunciation ────────────────────────────────────────────
function speakTerm(text) {
  try {
    if (window.speechSynthesis && text) {
      const u = new SpeechSynthesisUtterance(text);
      u.rate = 0.9; u.pitch = 1.0;
      window.speechSynthesis.cancel();
      window.speechSynthesis.speak(u);
      return true;
    }
  } catch (e) {}
  return false;
}

// A small pronunciation chip: phonetic respelling + tappable speaker.
function SpeakButton({ word, pron, size = 'md' }) {
  const [pulse, setPulse] = useStateD(false);
  if (!pron) return null;
  const go = (e) => {
    e && e.stopPropagation();
    speakTerm(word);
    setPulse(true);
    setTimeout(() => setPulse(false), 620);
  };
  return (
    <button onClick={go} aria-label={'Pronounce ' + word}
      style={{
        appearance: 'none', cursor: 'pointer', display: 'inline-flex', alignItems: 'center', gap: 8,
        background: 'transparent', border: '1px solid var(--rule)', borderRadius: 999,
        padding: size === 'sm' ? '4px 10px 4px 8px' : '5px 12px 5px 9px', color: 'var(--ink-mute)',
      }}>
      <span style={{ position: 'relative', display: 'inline-flex', width: 16, height: 16, alignItems: 'center', justifyContent: 'center' }}>
        <svg width="15" height="15" viewBox="0 0 20 20" fill="none" style={{ color: 'var(--accent)' }}>
          <path d="M4 8 H6.5 L10 4.5 V15.5 L6.5 12 H4 Z" fill="currentColor" stroke="currentColor" strokeWidth="1.1" strokeLinejoin="round"/>
          <path d="M13 7.5 a3.5 3.5 0 0 1 0 5" fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" style={{ opacity: pulse ? 1 : 0.7 }}/>
          {pulse && <path d="M15 5.5 a6 6 0 0 1 0 9" fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/>}
        </svg>
      </span>
      <span className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.04em' }}>{pron}</span>
    </button>
  );
}

// ── Category glyphs — simple line marks ──────────────────────
function CatGlyph({ cat, size = 22, color = 'currentColor' }) {
  const p = { width: size, height: size, viewBox: '0 0 24 24', fill: 'none', style: { color, flexShrink: 0 }, 'aria-hidden': true };
  // Primary outline weight comes from the shared token so it can't drift from
  // the rest of the family. Interior accent lines stay lighter (see below).
  const sw = window.GLYPH_STROKE || 1.6;
  switch (cat) {
    case 'beans': // two cherries + stem
      return (<svg {...p}><path d="M11 4 Q12 9 9 12" stroke="currentColor" strokeWidth={sw} strokeLinecap="round"/><circle cx="8" cy="15" r="4.2" stroke="currentColor" strokeWidth={sw}/><circle cx="15.5" cy="14" r="4.2" stroke="currentColor" strokeWidth={sw}/></svg>);
    case 'processing': // Cherry in section — the seed inside the fruit. Neutral across washed / natural / honey; water is not the category.
      return (<svg {...p}><path d="M13.6 5.9 Q 15.2 3.7 17.4 3.5" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/><circle cx="11.8" cy="13.2" r="7" stroke="currentColor" strokeWidth={sw}/><ellipse cx="11.8" cy="13.2" rx="2.9" ry="4.2" transform="rotate(-18 11.8 13.2)" stroke="currentColor" strokeWidth="1.3"/></svg>);
    case 'roasting': // Roast curve — temperature over time, with first crack marked. Heat plus change, and it leaves the flame to the streak.
      return (<svg {...p}><path d="M4.8 4.5 V19.2 H19.6" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" opacity="0.55"/><path d="M6.2 17.2 Q 10 16.6 12.4 11.4 T 19.4 6.8" stroke="currentColor" strokeWidth={sw} strokeLinecap="round"/><circle cx="12.4" cy="11.4" r="2" fill="currentColor"/></svg>);
    case 'brewing': // cone + drips
      return (<svg {...p}><path d="M6 6 H18 L13 14 H11 L6 6 Z" stroke="currentColor" strokeWidth={sw} strokeLinejoin="round"/><path d="M12 16.5 v2.5" stroke="currentColor" strokeWidth={sw} strokeLinecap="round"/></svg>);
    case 'espresso': // demitasse
      return (<svg {...p}><path d="M5.5 8 H16 V12 a4 4 0 0 1 -4 4 H9.5 a4 4 0 0 1 -4 -4 Z" stroke="currentColor" strokeWidth={sw} strokeLinejoin="round"/><path d="M16 9 h2 a2 2 0 0 1 0 4 h-2" stroke="currentColor" strokeWidth={sw}/><path d="M8 4.5 v1.5 M11.5 4.5 v1.5" stroke="currentColor" strokeWidth="1.2" strokeLinecap="round" opacity="0.6"/></svg>);
    case 'sensory': // Tasting wheel — the flavour wheel, one wedge picked. The words for what you taste, not a mood face.
      return (<svg {...p}><path d="M12 12 L12 4 A 8 8 0 0 1 18.93 8 Z" fill="currentColor" opacity="0.9"/><circle cx="12" cy="12" r="8" stroke="currentColor" strokeWidth={sw}/><path d="M12 4 V20 M5.07 8 L18.93 16 M5.07 16 L18.93 8" stroke="currentColor" strokeWidth="1.3"/></svg>);
    case 'equipment': // Gooseneck kettle — the most recognisable tool on the counter. A gear says settings, not coffee gear.
      return (<svg {...p}><path d="M8.4 11.2 C 8.4 8.2 13.2 8.2 13.2 11.2" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/><path d="M6.2 11.2 H15 V16.6 A3 3 0 0 1 12 19.6 H9.2 A3 3 0 0 1 6.2 16.6 Z" stroke="currentColor" strokeWidth={sw} strokeLinejoin="round"/><path d="M15 12.6 C 18.1 12.1 18.7 8.6 17 6.2" stroke="currentColor" strokeWidth={sw} strokeLinecap="round"/></svg>);
    case 'grind': // Hand grinder with its crank, burr line across the body. The Grind module’s own mark — it used to borrow the Equipment gear.
      return (<svg {...p}><path d="M12 9.4 V6.6 H15.8 A1.7 1.7 0 0 1 15.8 10" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" strokeLinejoin="round"/><path d="M7.6 9.4 H16.4 V18 A2.4 2.4 0 0 1 14 20.4 H10 A2.4 2.4 0 0 1 7.6 18 Z" stroke="currentColor" strokeWidth={sw} strokeLinejoin="round"/><path d="M9.4 14.2 H14.6" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/></svg>);
    case 'trade': // Balance scales — what a lot is worth and who gets paid. Exchange arrows read as sync, not trade.
      return (<svg {...p}><path d="M12 5.4 V18" stroke="currentColor" strokeWidth={sw} strokeLinecap="round"/><path d="M4.6 8.6 H19.4" stroke="currentColor" strokeWidth={sw} strokeLinecap="round"/><path d="M8.6 18.4 H15.4" stroke="currentColor" strokeWidth={sw} strokeLinecap="round"/><path d="M7 8.6 V10.2 M17 8.6 V10.2" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/><path d="M4.4 10.2 A 2.6 2.6 0 0 0 9.6 10.2" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/><path d="M14.4 10.2 A 2.6 2.6 0 0 0 19.6 10.2" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/></svg>);
    default:
      return (<svg {...p}><circle cx="12" cy="12" r="7" stroke="currentColor" strokeWidth={sw}/></svg>);
  }
}

// ── Learned / locked status glyph ────────────────────────────
function StatusGlyph({ learned, size = 20 }) {
  if (learned) {
    return (
      <span style={{
        width: size, height: size, borderRadius: 999, flexShrink: 0,
        background: 'color-mix(in oklab, var(--sage) 22%, var(--surface))',
        border: '1px solid color-mix(in oklab, var(--sage) 55%, var(--rule))',
        display: 'grid', placeItems: 'center',
      }}>
        <svg width={size * 0.5} height={size * 0.5} viewBox="0 0 12 12">
          <path d="M2 6.2 L5 9 L10 3" fill="none" stroke="var(--sage)" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      </span>
    );
  }
  return (
    <span style={{
      width: size, height: size, borderRadius: 999, flexShrink: 0,
      border: '1.5px dashed var(--rule)', display: 'grid', placeItems: 'center',
    }}>
      <span style={{ width: 4, height: 4, borderRadius: 999, background: 'var(--ink-mute)', opacity: 0.5 }}/>
    </span>
  );
}

function StatusChipMini({ learned }) {
  const [label, color] = learned ? ['LEARNED', 'var(--sage)'] : ['TO LEARN', 'var(--ink-mute)'];
  return (
    <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.16em', textTransform: 'uppercase', color, display: 'inline-flex', alignItems: 'center', gap: 6 }}>
      <span style={{ width: 6, height: 6, borderRadius: 999, background: learned ? color : 'transparent', border: '1px solid ' + (learned ? color : 'var(--rule)') }}/>
      {label}
    </span>
  );
}

// ── In-lesson term linking ───────────────────────────────────
// Wrap recognised glossary terms in tappable spans. Returns an array of React
// children (strings + spans). One link per term id per text; capped overall.
const _aliasRe = (() => {
  const aliases = (window.GLOSSARY_INDEX || []).map(g => g.alias.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'));
  if (!aliases.length) return null;
  return new RegExp('\\b(' + aliases.join('|') + ')\\b', 'gi');
})();

function linkifyTerms(text, onTap, opts) {
  if (!text || !_aliasRe || !onTap) return text;
  const cap = (opts && opts.cap) || 4;
  const used = new Set();
  const out = [];
  let last = 0, count = 0, m;
  _aliasRe.lastIndex = 0;
  while ((m = _aliasRe.exec(text)) !== null) {
    const matchTxt = m[0];
    const hit = (window.GLOSSARY_INDEX || []).find(g => g.alias === matchTxt.toLowerCase());
    if (!hit || used.has(hit.id) || count >= cap) continue;
    used.add(hit.id); count++;
    if (m.index > last) out.push(text.slice(last, m.index));
    const id = hit.id;
    out.push(
      React.createElement('span', {
        key: 'lt' + m.index, role: 'button', tabIndex: 0,
        onClick: (e) => { e.stopPropagation(); onTap(id); },
        style: {
          color: 'var(--accent)', cursor: 'pointer',
          borderBottom: '1.5px dotted color-mix(in oklab, var(--accent) 60%, transparent)',
          fontWeight: 500,
        },
      }, matchTxt)
    );
    last = m.index + matchTxt.length;
  }
  if (last < text.length) out.push(text.slice(last));
  return out.length ? out : text;
}

// ── Search bar ───────────────────────────────────────────────
function DictSearchBar({ value, onChange, onClear, autoFocus, placeholder }) {
  const ref = useRefD(null);
  useEffectD(() => { if (autoFocus && ref.current) { const t = setTimeout(() => ref.current.focus(), 120); return () => clearTimeout(t); } }, [autoFocus]);
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10, background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 12, padding: '11px 14px' }}>
      <svg width="17" height="17" viewBox="0 0 20 20" fill="none" style={{ flexShrink: 0 }}>
        <circle cx="9" cy="9" r="6" stroke="var(--ink-mute)" strokeWidth="1.6"/>
        <path d="M13.5 13.5 L17 17" stroke="var(--ink-mute)" strokeWidth="1.6" strokeLinecap="round"/>
      </svg>
      <input ref={ref} value={value} onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder || 'Search terms, e.g. crema, bloom…'}
        style={{
          flex: 1, minWidth: 0, appearance: 'none', border: 'none', outline: 'none', background: 'transparent',
          font: 'inherit', fontFamily: 'IBM Plex Sans, sans-serif', fontSize: 'var(--t-body)', color: 'var(--ink)',
        }}/>
      {value && (
        <button onClick={onClear} aria-label="Clear" style={{ appearance: 'none', background: 'transparent', border: 'none', cursor: 'pointer', padding: 2, color: 'var(--ink-mute)', display: 'flex' }}>
          <svg width="16" height="16" viewBox="0 0 18 18"><path d="M4 4l10 10M14 4L4 14" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/></svg>
        </button>
      )}
    </div>
  );
}

// ── Filter segmented control (All / Learned / Locked) ────────
function DictFilter({ value, onChange, counts }) {
  const opts = [['all', 'All'], ['learned', 'Learned'], ['locked', 'To learn']];
  return (
    <div style={{ display: 'flex', gap: 0, border: '1px solid var(--rule)', borderRadius: 999, overflow: 'hidden', background: 'var(--surface)' }}>
      {opts.map(([k, l]) => {
        const on = value === k;
        return (
          <button key={k} onClick={() => onChange(k)}
            style={{
              flex: 1, appearance: 'none', border: 'none', cursor: 'pointer',
              background: on ? 'var(--accent)' : 'transparent',
              color: on ? 'var(--accent-ink)' : 'var(--ink-mute)',
              fontFamily: 'IBM Plex Sans, sans-serif', fontSize: 'var(--t-label)', fontWeight: 500,
              letterSpacing: '0.1em', textTransform: 'uppercase', padding: '9px 4px',
            }}>
            {l}
          </button>
        );
      })}
    </div>
  );
}

// ── A term row in a list ─────────────────────────────────────
function DictTermRow({ term, learned, isFav, onOpen, onToggleFav, snippet }) {
  const cat = (window.DICT_CAT_BY_ID || {})[term.cat];
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 0', borderBottom: '1px solid var(--rule)' }}>
      <button onClick={() => onOpen(term.id)} style={{
        flex: 1, minWidth: 0, appearance: 'none', border: 'none', background: 'transparent', cursor: 'pointer', textAlign: 'left', padding: 0,
        display: 'grid', gridTemplateColumns: '22px 1fr', alignItems: 'center', gap: 13,
      }}>
        <StatusGlyph learned={learned}/>
        <span style={{ minWidth: 0 }}>
          <span style={{ display: 'flex', alignItems: 'baseline', gap: 8, flexWrap: 'wrap' }}>
            <span style={{ fontSize: 'var(--t-body)', color: 'var(--ink)', fontWeight: 500, lineHeight: 1.2 }}>{term.term}</span>
            {term.pron && <span className="ff-mono" style={{ fontSize: 'var(--t-label)', color: 'var(--ink-mute)', letterSpacing: '0.02em' }}>{term.pron}</span>}
          </span>
          <span style={{ display: 'block', fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 3, lineHeight: 1.4, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: snippet ? 'normal' : 'nowrap' }}>
            {snippet ? term.short : (cat ? cat.label : '')}
          </span>
        </span>
      </button>
      <FavButton size={32} active={!!isFav} onClick={onToggleFav}/>
    </div>
  );
}

// Term of the Day compact banner.
function TermOfDayBanner({ term, onOpen, big }) {
  if (!term) return null;
  const cat = (window.DICT_CAT_BY_ID || {})[term.cat];
  if (big) {
    return (
      <button onClick={onOpen} style={{
        width: '100%', appearance: 'none', cursor: 'pointer', textAlign: 'left',
        borderRadius: 16, overflow: 'hidden', border: '1px solid color-mix(in oklab, var(--accent) 24%, var(--rule))',
        background: 'linear-gradient(158deg, color-mix(in oklab, var(--accent) 13%, var(--surface)) 0%, var(--surface) 62%)',
        padding: '20px 20px 18px', boxShadow: '0 14px 34px rgba(0,0,0,0.18)',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <span className="smallcaps" style={{ color: 'var(--accent)' }}>TERM OF THE DAY</span>
          <CatGlyph cat={term.cat} size={22} color="var(--accent)"/>
        </div>
        <h2 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.04, letterSpacing: '-0.02em', margin: '14px 0 0', color: 'var(--ink)' }}>{term.term}</h2>
        {term.pron && <div className="ff-mono" style={{ fontSize: 'var(--t-label)', color: 'var(--ink-mute)', marginTop: 6, letterSpacing: '0.02em' }}>{term.pron}</div>}
        <p style={{ margin: '12px 0 0', fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink-mute)', textWrap: 'pretty' }}>{term.short}</p>
        <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.16em', textTransform: 'uppercase', color: 'var(--accent)', marginTop: 16, display: 'flex', alignItems: 'center', gap: 8 }}>
          OPEN ENTRY <svg width="14" height="10" viewBox="0 0 14 10"><path d="M1 5h11M8 1l4 4-4 4" fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round"/></svg>
        </div>
      </button>
    );
  }
  return (
    <button onClick={onOpen} style={{
      width: '100%', appearance: 'none', cursor: 'pointer', textAlign: 'left',
      display: 'grid', gridTemplateColumns: 'auto 1fr auto', alignItems: 'center', gap: 14,
      background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 14, padding: '14px 16px',
    }}>
      <span style={{ width: 40, height: 40, borderRadius: 12, flexShrink: 0, display: 'grid', placeItems: 'center', background: 'color-mix(in oklab, var(--accent) 10%, var(--surface))' }}>
        <CatGlyph cat={term.cat} size={21} color="var(--accent)"/>
      </span>
      <span style={{ minWidth: 0 }}>
        <span className="smallcaps" style={{ color: 'var(--accent)', display: 'block' }}>TERM OF THE DAY</span>
        <span style={{ display: 'block', fontSize: 'var(--t-body)', color: 'var(--ink)', fontWeight: 500, marginTop: 3 }}>{term.term}</span>
      </span>
      <window.Chevron/>
    </button>
  );
}

// Quick-access chips (flashcards + vocab game) — one slim row.
function DictQuickChips({ savedTermCount, onFlashcards, onVocabGame }) {
  const chip = (label, sub, onClick, icon) => (
    <button onClick={onClick} style={{
      flex: 1, minWidth: 0, appearance: 'none', cursor: 'pointer', textAlign: 'left',
      background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 12, padding: '11px 14px',
      display: 'flex', alignItems: 'center', gap: 10,
    }}>
      <span style={{ color: 'var(--accent)', display: 'flex', flexShrink: 0 }}>{icon}</span>
      <span style={{ fontSize: 'var(--t-support)', fontWeight: 500, color: 'var(--ink)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{label}</span>
      {sub != null && <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.08em', color: 'var(--ink-mute)', marginLeft: 'auto', flexShrink: 0 }}>{sub}</span>}
    </button>
  );
  return (
    <div style={{ display: 'flex', gap: 10 }}>
      {chip('Flashcards', String(savedTermCount || 0), onFlashcards,
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><rect x="3" y="6" width="14" height="12" rx="2" stroke="currentColor" strokeWidth="1.6"/><path d="M7 9.5h6M7 12.5h4" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/><path d="M9 4.5h9a2 2 0 0 1 2 2v9" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" opacity="0.5"/></svg>)}
      {chip('Vocab game', null, onVocabGame,
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="8" stroke="currentColor" strokeWidth="1.6"/><path d="M9.5 9.8a2.5 2.5 0 1 1 3.2 2.4c-.5.2-.7.6-.7 1.1v.4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/><circle cx="12" cy="16.3" r="0.9" fill="currentColor"/></svg>)}
    </div>
  );
}

// Recently-opened horizontal strip. Postponed for v2 — kept in the codebase
// but not currently rendered by DictionaryHome.
function DictRecentStrip({ recent, onOpen }) {
  if (!recent || !recent.length) return null;
  return (
    <div>
      <div className="smallcaps" style={{ marginBottom: 12 }}>RECENTLY OPENED</div>
      <div style={{ display: 'flex', gap: 10, overflowX: 'auto', paddingBottom: 4, scrollbarWidth: 'none' }}>
        {recent.map(id => {
          const t = (window.DICT_BY_ID || {})[id];
          if (!t) return null;
          return (
            <button key={id} onClick={() => onOpen(id)} style={{
              flexShrink: 0, appearance: 'none', cursor: 'pointer', textAlign: 'left',
              background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 12, padding: '11px 13px',
              display: 'flex', alignItems: 'center', gap: 9, maxWidth: 200,
            }}>
              <CatGlyph cat={t.cat} size={17} color="var(--ink-mute)"/>
              <span style={{ fontSize: 'var(--t-support)', color: 'var(--ink)', fontWeight: 500, whiteSpace: 'nowrap' }}>{t.term}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ════════════════════════════════════════════════════════════
// DICTIONARY HOME
// ════════════════════════════════════════════════════════════
function DictionaryHome({ name = 'Coffee Dictionary', learnedSet, favorites, recent,
                          savedTermCount, initialQuery, focusSearch, onOpenTerm, onToggleFav,
                          onTermOfDay, onFlashcards, onVocabGame, onClose }) {
  const [query, setQuery] = useStateD(initialQuery || '');
  const [filter, setFilter] = useStateD('all');
  const [cat, setCat] = useStateD(null);
  // Same sticky-header contract as every other subscreen: useScrollFlag +
  // SubScreenHeader, so the large in-flow title collapses into the shared
  // blurred bar with the compact title beside the back chevron.
  const [scrolled, onScroll] = window.useScrollFlag(72);
  // The compact title tracks context: category drill-down shows the category.
  const compactTitle = cat ? ((window.DICT_CAT_BY_ID || {})[cat] || {}).label || name : name;

  const terms = window.DICT_TERMS || [];
  const cats = window.DICT_CATEGORIES || [];
  const counts = window.dictCatCounts ? window.dictCatCounts() : {};
  const tod = window.dictTermOfDay ? window.dictTermOfDay() : null;
  const isLearned = (t) => learnedSet && learnedSet.has(t.id);
  const isFav = (id) => favorites && favorites.has('t:' + id);
  const passFilter = (t) => filter === 'all' || (filter === 'learned' ? isLearned(t) : !isLearned(t));

  const q = query.trim().toLowerCase();
  const searchResults = q
    ? terms.filter(t => {
        const hay = (t.term + ' ' + (t.aliases || []).join(' ') + ' ' + t.short).toLowerCase();
        return hay.indexOf(q) >= 0;
      }).filter(passFilter)
    : null;

  const filterCounts = (list) => ({
    all: list.length,
    learned: list.filter(isLearned).length,
    locked: list.filter(t => !isLearned(t)).length,
  });

  const SubHeader = window.SubScreenHeader;
  const topbar = SubHeader
    ? <SubHeader scrolled={scrolled} title={compactTitle} onBack={() => (cat ? setCat(null) : onClose())}/>
    : null;

  // ── Term list (used by search, category, A–Z) ──
  const renderList = (list, opts) => (
    <div>
      {list.map(t => (
        <DictTermRow key={t.id} term={t} learned={isLearned(t)} isFav={isFav(t.id)}
          snippet={!!q || !!(opts && opts.snippet)}
          onOpen={onOpenTerm} onToggleFav={() => onToggleFav('t:' + t.id)}/>
      ))}
    </div>
  );

  // ── SEARCH MODE ──
  let body;
  if (q) {
    const fc = filterCounts(terms.filter(t => {
      const hay = (t.term + ' ' + (t.aliases || []).join(' ') + ' ' + t.short).toLowerCase();
      return hay.indexOf(q) >= 0;
    }));
    body = (
      <div className="px-24" style={{ paddingTop: 18 }}>
        <DictFilter value={filter} onChange={setFilter} counts={fc}/>
        <div className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.12em', textTransform: 'uppercase', color: 'var(--ink-mute)', margin: '18px 0 4px' }}>
          {searchResults.length} {searchResults.length === 1 ? 'RESULT' : 'RESULTS'}
        </div>
        {searchResults.length ? renderList(searchResults) : (
          <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.6, color: 'var(--ink-mute)', marginTop: 24, textWrap: 'pretty' }}>
            No terms match “{query}”. Try a broader word — or browse by category.
          </p>
        )}
      </div>
    );
  } else if (cat) {
    // ── CATEGORY DRILL-DOWN ──
    const meta = (window.DICT_CAT_BY_ID || {})[cat];
    const list = terms.filter(t => t.cat === cat).filter(passFilter);
    const fc = filterCounts(terms.filter(t => t.cat === cat));
    body = (
      <div className="px-24" style={{ paddingTop: 4 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 14 }}>
          <span style={{ width: 40, height: 40, borderRadius: 12, display: 'grid', placeItems: 'center', background: 'color-mix(in oklab, var(--accent) 10%, var(--surface))' }}>
            <CatGlyph cat={cat} size={22} color="var(--accent)"/>
          </span>
          <div>
            <h2 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, letterSpacing: '-0.01em', margin: 0, color: 'var(--ink)', lineHeight: 1.05 }}>{meta.label}</h2>
            <div style={{ fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 3 }}>{meta.short}</div>
          </div>
        </div>
        <DictFilter value={filter} onChange={setFilter} counts={fc}/>
        <div style={{ marginTop: 14 }}>{renderList(list, { snippet: true })}</div>
      </div>
    );
  } else {
    // ── DISCOVER ──
    body = (
      <div className="px-24" style={{ paddingTop: 6 }}>
        <TermOfDayBanner term={tod} onOpen={onTermOfDay} big/>
        <div style={{ marginTop: 24 }}>
          <DictQuickChips savedTermCount={savedTermCount} onFlashcards={onFlashcards} onVocabGame={onVocabGame}/>
        </div>
        <div className="smallcaps" style={{ margin: '28px 0 10px' }}>ALL CATEGORIES</div>
        <div style={{ borderTop: '1px solid var(--rule)' }}>
          {cats.map(c => (
            <button key={c.id} onClick={() => { setFilter('all'); setCat(c.id); }} style={{
              width: '100%', appearance: 'none', cursor: 'pointer', textAlign: 'left',
              display: 'grid', gridTemplateColumns: 'auto 1fr auto', alignItems: 'center', gap: 14,
              padding: '15px 0', background: 'transparent', border: 'none',
              borderBottom: '1px solid var(--rule)',
            }}>
              <CatGlyph cat={c.id} size={22} color="var(--ink-mute)"/>
              <span style={{ minWidth: 0 }}>
                <span style={{ display: 'block', fontSize: 'var(--t-body)', color: 'var(--ink)', fontWeight: 500 }}>{c.label}</span>
                <span style={{ display: 'block', fontSize: 'var(--t-support)', color: 'var(--ink-mute)', marginTop: 2 }}>{c.short}</span>
              </span>
              <span className="ff-mono" style={{ fontSize: 'var(--t-label)', color: 'var(--ink-mute)', letterSpacing: '0.06em' }}>{counts[c.id]}</span>
            </button>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="screen" data-screen-label="Dictionary" style={{ background: 'var(--bg)' }}>
      {topbar}
      <div className="scroll" onScroll={onScroll} style={{ paddingTop: 108, paddingBottom: 120 }}>
        <div className="px-24">
          <div className="smallcaps" style={{ marginBottom: 10, color: 'var(--accent)' }}>REFERENCE · {terms.length} TERMS</div>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.05, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>{name}</h1>
        </div>
        <div className="px-24" style={{ paddingTop: 18 }}>
          <DictSearchBar value={query} onChange={setQuery} onClear={() => setQuery('')} autoFocus={!!focusSearch || !!initialQuery}/>
        </div>
        <div style={{ paddingTop: 6 }}>{body}</div>
      </div>
    </div>
  );
}

// ════════════════════════════════════════════════════════════
// SHARED DETAIL PIECES
// ════════════════════════════════════════════════════════════

// Interactive knowledge check (compact MCQ).
function TermCheck({ check }) {
  const [picked, setPicked] = useStateD(null);
  if (!check) return null;
  const correctIdx = check.choices.findIndex(c => c.correct);
  return (
    <div style={{ background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 14, padding: 18 }}>
      <div className="smallcaps" style={{ marginBottom: 12 }}>KNOWLEDGE CHECK</div>
      <div style={{ fontSize: 'var(--t-body)', color: 'var(--ink)', fontWeight: 500, lineHeight: 1.3, marginBottom: 14, textWrap: 'pretty' }}>{check.q}</div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        {check.choices.map((c, i) => {
          let cls = 'mcq-choice';
          if (picked !== null) { if (i === correctIdx) cls += ' correct'; else if (i === picked) cls += ' incorrect'; }
          return (
            <button key={i} className={cls} disabled={picked !== null} onClick={() => setPicked(i)} style={{ fontSize: 'var(--t-support)', padding: '14px 16px' }}>
              {c.t}
            </button>
          );
        })}
      </div>
      {picked !== null && (
        <div style={{ marginTop: 14, display: 'flex', gap: 12, alignItems: 'flex-start' }}>
          <div style={{ flexShrink: 0, marginTop: -4 }}>{window.Roasty && <Roasty state={picked === correctIdx ? 'correct' : 'wrong'} size={48}/>}</div>
          <div>
            <div className="ff-mono" style={{ fontSize: 'var(--t-label)', letterSpacing: '0.14em', textTransform: 'uppercase', color: picked === correctIdx ? 'var(--sage)' : 'var(--accent)', marginBottom: 6 }}>
              {picked === correctIdx ? 'CORRECT' : 'NOT QUITE'}
            </div>
            <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: 0 }}>{check.explain}</p>
          </div>
        </div>
      )}
    </div>
  );
}

function RelatedChips({ ids, onOpen, currentId }) {
  const list = (ids || []).map(id => (window.DICT_BY_ID || {})[id]).filter(Boolean).filter(t => t.id !== currentId);
  if (!list.length) return null;
  return (
    <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
      {list.map(t => (
        <button key={t.id} onClick={() => onOpen(t.id)} style={{
          appearance: 'none', cursor: 'pointer', background: 'var(--surface)', border: '1px solid var(--rule)',
          borderRadius: 999, padding: '8px 14px', display: 'inline-flex', alignItems: 'center', gap: 8,
          fontFamily: 'IBM Plex Sans, sans-serif', fontSize: 'var(--t-support)', color: 'var(--ink)',
        }}>
          <CatGlyph cat={t.cat} size={15} color="var(--ink-mute)"/>
          {t.term}
        </button>
      ))}
    </div>
  );
}

// Related lesson reference. Tappable only when the lesson body is playable.
function LessonRefCard({ lessonId, onLesson }) {
  const ctx = window.findLessonContext ? window.findLessonContext(lessonId) : null;
  if (!ctx) return null;
  const unlocked = !ctx.module.locked && ctx.lesson.status !== 'locked';
  const playable = unlocked && !!(window.LESSONS && window.LESSONS[lessonId]);
  const inner = (
    <>
      <FlavorWheel size={28} filled={ctx.lesson.status === 'complete' ? 6 : ctx.lesson.status === 'current' ? 3 : 0} stroke={1}
        color={ctx.lesson.status === 'current' ? 'var(--accent)' : 'var(--sage)'}/>
      <span style={{ minWidth: 0 }}>
        <span className="ff-mono" style={{ display: 'block', fontSize: 'var(--t-micro)', letterSpacing: '0.14em', color: 'var(--ink-mute)', textTransform: 'uppercase' }}>MODULE {ctx.module.n} · {ctx.module.label}</span>
        <span style={{ display: 'block', fontSize: 'var(--t-body)', color: 'var(--ink)', fontWeight: 500, marginTop: 2 }}>{ctx.lesson.title}</span>
      </span>
      <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.12em', textTransform: 'uppercase', color: playable ? 'var(--accent)' : 'var(--ink-mute)', whiteSpace: 'nowrap' }}>
        {playable ? 'OPEN →' : 'SOON'}
      </span>
    </>
  );
  const style = {
    width: '100%', display: 'grid', gridTemplateColumns: '28px 1fr auto', alignItems: 'center', gap: 14,
    background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 12, padding: '14px 16px', textAlign: 'left',
  };
  if (!playable) return <div style={{ ...style, opacity: 0.75 }}>{inner}</div>;
  return <button onClick={() => onLesson(lessonId)} style={{ ...style, appearance: 'none', cursor: 'pointer' }}>{inner}</button>;
}

function SourcesList({ sources }) {
  if (!sources || !sources.length) return null;
  return (
    <div>
      <div className="smallcaps" style={{ marginBottom: 10 }}>SOURCES</div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        {sources.map((s, i) => {
          const row = (
            <>
              <span style={{ color: 'var(--accent)' }}>{String(i + 1).padStart(2, '0')}</span>
              <span>{s.label}{s.note ? ' — ' + s.note : ''}</span>
              {s.url && (
                <svg width="10" height="10" viewBox="0 0 10 10" style={{ flexShrink: 0, marginTop: 3 }} aria-hidden="true">
                  <path d="M2.5 1.5 h6 v6 M8.5 1.5 L1.5 8.5" fill="none" stroke="currentColor" strokeWidth="1.2" strokeLinecap="round" strokeLinejoin="round"/>
                </svg>
              )}
            </>
          );
          const rowStyle = { fontSize: 'var(--t-label)', lineHeight: 1.5, letterSpacing: '0.01em', display: 'flex', gap: 8, alignItems: 'flex-start' };
          return s.url ? (
            <a key={i} className="ff-mono" href={s.url} target="_blank" rel="noopener noreferrer"
               style={{ ...rowStyle, color: 'var(--ink-mute)', textDecoration: 'none', cursor: 'pointer' }}
               onMouseEnter={(e) => { e.currentTarget.style.color = 'var(--accent)'; }}
               onMouseLeave={(e) => { e.currentTarget.style.color = 'var(--ink-mute)'; }}>
              {row}
            </a>
          ) : (
            <div key={i} className="ff-mono" style={{ ...rowStyle, color: 'var(--ink-mute)' }}>{row}</div>
          );
        })}
      </div>
    </div>
  );
}

// ════════════════════════════════════════════════════════════
// TERM DETAIL — 2 layouts
// ════════════════════════════════════════════════════════════
function TermDetail({ termId, variant = 'entry', learned, isFav, onToggleFav, onOpenTerm, onLesson, onClose }) {
  const term = (window.DICT_BY_ID || {})[termId];
  // Collapsing sticky header — same pattern as SubScreenHeader (settings.jsx)
  // and the dictionary home: transparent at rest; blurred + hairlined with a
  // compact title once the large title scrolls behind it.
  const [scrolled, setScrolled] = useStateD(false);
  const onDetailScroll = (e) => setScrolled(e.target.scrollTop > 96);
  useEffectD(() => { const el = document.querySelector('#dict-detail-scroll'); if (el) el.scrollTop = 0; setScrolled(false); }, [termId]);
  if (!term) return null;
  const cat = (window.DICT_CAT_BY_ID || {})[term.cat];

  const topbar = (
    <div style={{
      position: 'absolute', top: 0, left: 0, right: 0, height: 96, zIndex: 40,
      display: 'flex', alignItems: 'flex-end', pointerEvents: 'none',
      background: scrolled ? 'color-mix(in oklab, var(--bg) 78%, transparent)' : 'transparent',
      backdropFilter: scrolled ? 'blur(16px) saturate(1.3)' : 'none',
      WebkitBackdropFilter: scrolled ? 'blur(16px) saturate(1.3)' : 'none',
      borderBottom: '1px solid ' + (scrolled ? 'var(--rule)' : 'transparent'),
      transition: 'background 260ms ease, backdrop-filter 260ms ease, border-color 260ms ease',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '0 20px 10px', width: '100%' }}>
        <button className="close-btn" onClick={onClose} aria-label="Back" style={{ pointerEvents: 'auto', marginLeft: -4 }}>
          <window.BackMark/>
        </button>
        <div style={{
          minWidth: 0, flex: 1,
          opacity: scrolled ? 1 : 0,
          transform: scrolled ? 'translateY(0)' : 'translateY(7px)',
          transition: 'opacity 240ms ease, transform 240ms ease',
          pointerEvents: 'none',
        }}>
          {cat && (
            <div className="ff-mono" style={{
              fontSize: 'var(--t-micro)', letterSpacing: '0.18em', textTransform: 'uppercase',
              color: 'var(--ink-mute)', lineHeight: 1,
            }}>{cat.label}</div>
          )}
          <div className="ff-display" style={{
            fontSize: 'var(--t-heading)', fontWeight: 400, letterSpacing: '-0.01em', color: 'var(--ink)',
            lineHeight: 1.15, marginTop: cat ? 2 : 0, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
          }}>{term.term}</div>
        </div>
        {window.TopBarFav && <window.TopBarFav active={!!isFav} onClick={onToggleFav} label="Save term" style={{ pointerEvents: 'auto' }}/>}
      </div>
    </div>
  );

  const sections = (
    <>
      {term.deep && (
        <div>
          <div className="smallcaps" style={{ marginBottom: 10 }}>IN DEPTH</div>
          <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.6, color: 'var(--ink)', margin: 0, textWrap: 'pretty' }}>{term.deep}</p>
        </div>
      )}
      {term.example && (
        <div style={{ background: 'var(--surface)', border: '1px solid var(--rule)', borderRadius: 14, padding: 18 }}>
          <div className="smallcaps" style={{ marginBottom: 10, color: 'var(--accent)' }}>IN PRACTICE</div>
          <p className="ff-display" style={{ fontSize: 'var(--t-heading)', lineHeight: 1.4, fontWeight: 400, margin: 0, color: 'var(--ink)', textWrap: 'pretty' }}>{term.example}</p>
        </div>
      )}
      {term.check && <TermCheck check={term.check}/>}
      {term.related && term.related.length > 0 && (
        <div>
          <div className="smallcaps" style={{ marginBottom: 10 }}>RELATED TERMS</div>
          <RelatedChips ids={term.related} onOpen={onOpenTerm} currentId={term.id}/>
        </div>
      )}
      {term.lesson && (
        <div>
          <div className="smallcaps" style={{ marginBottom: 10 }}>{learned ? 'WHERE YOU LEARNED IT' : 'WHERE YOU’LL LEARN IT'}</div>
          <LessonRefCard lessonId={term.lesson} onLesson={onLesson}/>
        </div>
      )}
      {term.sources && term.sources.length > 0 && <SourcesList sources={term.sources}/>}
    </>
  );

  // ── ENTRY (editorial) ──
  return (
    <div className="screen" data-screen-label="Term" style={{ background: 'var(--bg)' }}>
      {topbar}
      <div id="dict-detail-scroll" className="scroll" onScroll={onDetailScroll} style={{ paddingTop: 108, paddingBottom: 36 }}>
        <div className="px-24">
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
            <span className="smallcaps" style={{ color: 'var(--accent)', display: 'inline-flex', alignItems: 'center', gap: 8 }}>
              <CatGlyph cat={term.cat} size={16} color="var(--accent)"/>{cat ? cat.label : ''}
            </span>
            <StatusChipMini learned={learned}/>
          </div>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.02, letterSpacing: '-0.03em', margin: '14px 0 0', color: 'var(--ink)', textWrap: 'pretty' }}>{term.term}</h1>
          {term.pron && <div style={{ marginTop: 14 }}><SpeakButton word={term.term} pron={term.pron}/></div>}
          <p style={{ fontSize: 'var(--t-lead)', lineHeight: 1.5, color: 'var(--ink)', margin: '20px 0 0', fontWeight: 400, textWrap: 'pretty' }}>{term.short}</p>
        </div>
        <div className="px-24" style={{ paddingTop: 28, display: 'flex', flexDirection: 'column', gap: 26 }}>
          {sections}
        </div>
      </div>
    </div>
  );
}

// ════════════════════════════════════════════════════════════
// IN-LESSON TERM PEEK — compact bottom sheet
// ════════════════════════════════════════════════════════════
function TermPeekSheet({ termId, open, learned, isFav, onToggleFav, onOpenFull, onOpenTerm, onClose }) {
  const term = termId ? (window.DICT_BY_ID || {})[termId] : null;
  const cat = term ? (window.DICT_CAT_BY_ID || {})[term.cat] : null;
  return (
    <>
      <div className={'sheet-backdrop' + (open ? ' open' : '')} onClick={onClose}/>
      <div className={'sheet' + (open ? ' open' : '')} style={{ maxHeight: '56%' }}>
        <div className="sheet-handle"/>
        <div className="sheet-content" style={{ paddingTop: 14 }}>
          {term && (
            <>
              <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12 }}>
                <span className="smallcaps" style={{ color: 'var(--accent)', display: 'inline-flex', alignItems: 'center', gap: 8 }}>
                  <CatGlyph cat={term.cat} size={15} color="var(--accent)"/>{cat ? cat.label : ''}
                </span>
                {window.FavButton && <window.FavButton size={34} active={!!isFav} onClick={onToggleFav}/>}
              </div>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 12, flexWrap: 'wrap', marginTop: 10 }}>
                <h2 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, lineHeight: 1.04, letterSpacing: '-0.02em', margin: 0, color: 'var(--ink)' }}>{term.term}</h2>
                <StatusChipMini learned={learned}/>
              </div>
              {term.pron && <div style={{ marginTop: 12 }}><SpeakButton word={term.term} pron={term.pron}/></div>}
              <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink)', margin: '16px 0 0', textWrap: 'pretty' }}>{term.short}</p>

              {term.related && term.related.length > 0 && (
                <div style={{ marginTop: 18 }}>
                  <div className="smallcaps" style={{ marginBottom: 10 }}>RELATED</div>
                  <RelatedChips ids={term.related} onOpen={onOpenTerm} currentId={term.id}/>
                </div>
              )}

              <div style={{ display: 'flex', gap: 10, marginTop: 22 }}>
                <button className="btn btn-ghost" style={{ flex: 1 }} onClick={onClose}>Got it</button>
                <button className="btn btn-primary" style={{ flex: 1 }} onClick={() => onOpenFull(term.id)}>Full entry</button>
              </div>
            </>
          )}
        </div>
      </div>
    </>
  );
}

window.speakTerm = speakTerm;
window.SpeakButton = SpeakButton;
window.CatGlyph = CatGlyph;
window.StatusGlyph = StatusGlyph;
window.StatusChipMini = StatusChipMini;
window.linkifyTerms = linkifyTerms;
window.TermCheck = TermCheck;
window.RelatedChips = RelatedChips;
window.DictionaryHome = DictionaryHome;
window.TermDetail = TermDetail;
window.TermPeekSheet = TermPeekSheet;
