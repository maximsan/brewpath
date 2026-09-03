// gating.jsx — the Foundations ENTITLEMENT layer.
// Owns what a lock looks like and how a gate raises — never how Foundations is
// sold. Prices, plans and selling copy live in monetization.jsx (the config
// under experiment: onetime | subscription | hybrid); this file reads the
// active model for its CTA/footer strings only. Access checks stay boolean
// (isPlus / featureUnlocked in app.jsx) whatever the model.
//   • PLUS_FEATURES        — catalog of gated surfaces
//   • LockGlyph / LockBadge / TrialBadge — small affordances
//   • PlusGateSheet        — bottom sheet shown when a free user taps a lock
//   • RewardedAdScreen     — v2: simulated rewarded video → short PREVIEW
//   • RoastyGiftScreen     — v2: perfect-module reward → temporary Studio preview
//   • FeatureLock          — full-screen teaser lock (blur / hard / curtain)
// Loaded after duel.jsx, before app.jsx.

const { useState: useStateG, useEffect: useEffectG, useRef: useRefG } = React;

// The gated surfaces, with copy used by the sheet / locks.
const PLUS_FEATURES = {
  course:     { label: 'Foundations',       items: ['Modules 2–5, every lesson', 'The five premium practice formats', 'The complete Dictionary', 'Unlimited Saved', 'The Studio'],
                note: 'All of Module 1 stays free.',
                blurb: 'The rest of the course, and everything around it.' },
  games:      { label: 'Practice formats',  blurb: 'The five palate-training formats, included with Foundations.',
                items: ['Name the flavor notes', 'Read the green bean', 'Fix the cup', 'Dial it in', 'Put it in order'],
                note: 'True or false, Match the facts and Name the origin stay free, as do Flashcards and Guess the Term.' },
  dictionary: { label: 'Full Dictionary',   blurb: 'Every coffee term with its full entry — browse, search and Term of the Day across the whole glossary. Included with Foundations.' },
  atlas:      { label: 'Coffee Atlas',      blurb: 'Travel the coffee belt, explore origins and collect passport stamps.' },
  duel:       { label: 'Coffee Duel',       blurb: 'Challenge a friend to a quick, head-to-head coffee quiz.' },
  saved:      { label: 'Unlimited Saved',   blurb: 'Your free shelf of 5 is full. Keep saving every lesson, term and guide — without a cap.' },
  studio:     { label: 'Studio',            blurb: 'Dress up Roasty and choose which plant grows in your grove. Included with Foundations.' },
};

// The lifetime price — legacy alias (store.jsx reads it); monetization.jsx owns
// all plans and prices. Entitlement logic in this file stays model-agnostic.
const FOUNDATIONS_PRICE = (window.getPlan ? window.getPlan('lifetime').price : '$49.99');

const TRIAL_AD_MIN  = 15;        // a rewarded-ad PREVIEW lasts 15 minutes (v2)
const TRIAL_GIFT_MIN = 24 * 60;  // the perfect-module gift preview lasts 24 hours (v2)

// ── glyphs ───────────────────────────────────────────────────
function LockGlyph({ size = 14, color = 'currentColor', sw = 1.6 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 20 20" fill="none" aria-hidden="true" style={{ color }}>
      <rect x="4.5" y="8.7" width="11" height="7.8" rx="1.7" fill="none" stroke="currentColor" strokeWidth={sw}/>
      <path d="M7 8.7 V6.6 a3 3 0 0 1 6 0 V8.7" fill="none" stroke="currentColor" strokeWidth={sw} strokeLinecap="round"/>
    </svg>
  );
}

// A small lock dot pinned to the corner of a header icon.
function LockBadge() {
  return (
    <span style={{
      position: 'absolute', top: -4, right: -4, width: 18, height: 18, borderRadius: 999,
      background: 'var(--surface-2)', border: '2px solid var(--bg)',
      display: 'grid', placeItems: 'center', color: 'var(--ink-mute)',
    }}>
      <LockGlyph size={9} sw={2}/>
    </span>
  );
}

// "FOUNDATIONS" pill — labels a purchase-gated entry on cards and sheets.
function PlusPill() {
  return (
    <span className="ff-mono" style={{
      fontSize: 'var(--t-micro)', letterSpacing: '0.16em', color: 'var(--accent)',
      border: '1px solid color-mix(in oklab, var(--accent) 45%, var(--rule))',
      borderRadius: 999, padding: '2px 7px', textTransform: 'uppercase', whiteSpace: 'nowrap',
    }}>FOUNDATIONS</span>
  );
}

// Live "Preview · 14:32" countdown shown while a temporary unlock is active (v2).
function TrialBadge({ until, floating = true }) {
  const [, force] = useStateG(0);
  useEffectG(() => {
    const id = setInterval(() => force(n => n + 1), 1000);
    return () => clearInterval(id);
  }, []);
  const ms = Math.max(0, (until || 0) - Date.now());
  if (ms <= 0) return null;
  const totalSec = Math.round(ms / 1000);
  const h = Math.floor(totalSec / 3600);
  const m = Math.floor((totalSec % 3600) / 60);
  const s = totalSec % 60;
  const txt = h > 0 ? `${h}h ${String(m).padStart(2, '0')}m`
                    : `${m}:${String(s).padStart(2, '0')}`;
  const inner = (
    <span className="ff-mono" style={{
      display: 'inline-flex', alignItems: 'center', gap: 7,
      fontSize: 'var(--t-label)', letterSpacing: '0.14em', textTransform: 'uppercase',
      color: 'var(--accent)', background: 'color-mix(in oklab, var(--accent) 12%, var(--surface))',
      border: '1px solid color-mix(in oklab, var(--accent) 30%, var(--rule))',
      borderRadius: 999, padding: '6px 12px', whiteSpace: 'nowrap',
      boxShadow: '0 2px 10px rgba(0,0,0,0.18)',
    }}>
      <span style={{ width: 6, height: 6, borderRadius: 999, background: 'var(--accent)' }}/>
      Preview · {txt} left
    </span>
  );
  if (!floating) return inner;
  return (
    <div style={{ position: 'absolute', top: 62, left: 0, right: 0, zIndex: 58, display: 'flex', justifyContent: 'center', pointerEvents: 'none' }}>
      {inner}
    </div>
  );
}

// ── PURCHASE GATE SHEET ──────────────────────────────────────
// Shown when a free user taps any locked surface. One real path out — buy
// Foundations once — plus, in v2 only, a rewarded-ad preview of the feature.
function PlusGateSheet({ featureKey, game, open, onClose, onUpgrade, onWatchAd, showAd = true }) {
  // A locked mini-game gates on the MODULE that teaches its topic — a targeted
  // course pitch at peak intent, not the generic formats list. Falls back to
  // the static catalog when no game rode in (e.g. a routed gate).
  const gmod = featureKey === 'games' && game && game.mod
    ? (window.MODULES || []).find(m => m.id === game.mod) : null;
  const f = gmod
    ? { label: game.title,
        // Eyebrow already says "Taught in Module N" — the blurb pitches the
        // module itself, never restates the lock.
        blurb: (((window.MODULE_REWARDS || {})[gmod.id] || {}).summary || `Unlock Foundations to take Module ${gmod.n} — the game opens with it.`) }
    : (PLUS_FEATURES[featureKey] || { label: 'This feature', blurb: '' });
  const mon = window.getMonetization();
  return (
    <>
      {/* Interrupt layer: the gate can fire from inside another sheet (saving a
          term from the in-lesson peek hits the free Saved cap), so it sits one
          step above the base sheet layer (95/96) instead of tying on z-index and
          losing to whichever sheet renders later. */}
      <div className={'sheet-backdrop' + (open ? ' open' : '')} style={{ zIndex: 97 }} onClick={onClose}/>
      <div className={'sheet' + (open ? ' open' : '')} style={{ zIndex: 98 }} role="dialog" aria-label={'Unlock ' + f.label}>
        <div className="sheet-handle"/>
        <div className="sheet-content">
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 14 }}>
            <span style={{
              width: 40, height: 40, borderRadius: 999, flexShrink: 0, display: 'grid', placeItems: 'center',
              background: 'color-mix(in oklab, var(--accent) 13%, var(--surface))', color: 'var(--accent)',
            }}>
              <LockGlyph size={18}/>
            </span>
            <div>
              {/* The whole product can't be "part of" itself — the eyebrow renders
                  only when the gated feature is narrower than Foundations. */}
              {gmod && (
                <div className="smallcaps" style={{ color: 'var(--accent)', marginBottom: 6 }}>TAUGHT IN {gmod.label}</div>
              )}
              <div className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, letterSpacing: '-0.01em', color: 'var(--ink)', lineHeight: 1.05 }}>{f.label}</div>
            </div>
          </div>

          {/* With an items list the blurb is skipped — the list says WHAT; a
              summary sentence above it would only paraphrase it. */}
          {!f.items && <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink-mute)', margin: '0 0 20px', textWrap: 'pretty' }}>
            {f.blurb}
          </p>}
          {/* Multi-item purchases list their contents as rows — the paywall's
              benefit grammar, compacted for a sheet — instead of a prose run-on. */}
          {f.items && (
            <div style={{ margin: '8px 0 20px' }}>
              {f.items.map((b, i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '6px 0' }}>
                  <svg width="13" height="13" viewBox="0 0 15 15" style={{ flexShrink: 0 }}><path d="M3 8 L6.2 11 L12 4" fill="none" stroke="var(--accent)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>
                  <span style={{ fontSize: 'var(--t-support)', color: 'var(--ink)' }}>{b}</span>
                </div>
              ))}
              {f.note && <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: '8px 0 0', textWrap: 'pretty' }}>{f.note}</p>}
            </div>
          )}

          <button className="btn btn-primary" onClick={onUpgrade}>{mon.gateCta}</button>

          {showAd && (<>
          <button onClick={onWatchAd} style={{
            width: '100%', marginTop: 10, appearance: 'none', cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
            background: 'transparent', border: '1px solid var(--rule)', borderRadius: 2,
            padding: '14px 16px', color: 'var(--ink)', font: 'inherit',
          }}>
            <svg width="18" height="18" viewBox="0 0 20 20" fill="none" style={{ flexShrink: 0 }}>
              <circle cx="10" cy="10" r="8" stroke="var(--accent)" strokeWidth="1.5"/>
              <path d="M8.2 6.8 L13.4 10 L8.2 13.2 Z" fill="var(--accent)"/>
            </svg>
            <span style={{ fontSize: 'var(--t-body)', fontWeight: 500 }}>Watch a short ad — preview {TRIAL_AD_MIN} min free</span>
          </button>
          </>)}
          <div style={{ marginTop: showAd ? 8 : 10 }}>
            <a className="btn btn-ghost" href="#" style={{ display: 'block', textAlign: 'center', textDecoration: 'none' }} onClick={(e) => { e.preventDefault(); onClose(); }}>Not now</a>
          </div>
          {/* Footer caption — the DS gate sheet closes on a centered micro line
              under the actions; purchase facts live here, never in the stack. */}
          <div className="ff-mono" style={{ marginTop: 14, textAlign: 'center', fontSize: 'var(--t-micro)', letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--ink-mute)' }}>{mon.gateFooter}</div>
        </div>
      </div>
    </>
  );
}

// ── REWARDED AD SCREEN (v2) ──────────────────────────────────
// A simulated rewarded video. Counts down, then grants a short preview —
// never a trial of the purchase; the purchase itself has no trial.
function RewardedAdScreen({ featureKey, minutes = TRIAL_AD_MIN, onClaim, onClose }) {
  const f = PLUS_FEATURES[featureKey] || { label: 'this feature' };
  const TOTAL = 6;
  const [left, setLeft] = useStateG(TOTAL);
  useEffectG(() => {
    if (left <= 0) return;
    const id = setTimeout(() => setLeft(l => l - 1), 1000);
    return () => clearTimeout(id);
  }, [left]);
  const done = left <= 0;
  const frac = (TOTAL - left) / TOTAL;
  const R = 17, C = 2 * Math.PI * R;
  // The ad canvas is fixed near-black (#0b0908) in BOTH moods, so the ring deliberately
  // keeps the dark-roast accent — var(--accent) would go too dark in cupping.
  const AD_RING = '#E07A4F';

  return (
    <div className="screen" data-screen-label="Rewarded Ad" style={{ background: '#0b0908' }}>
      {/* top bar — sponsor label + countdown ring + close */}
      <div style={{
        position: 'absolute', top: 54, left: 0, right: 0, zIndex: 10,
        display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '14px 18px',
      }}>
        <span className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.18em', textTransform: 'uppercase', color: 'rgba(255,255,255,0.6)' }}>
          Ad · Rewarded
        </span>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <span style={{ position: 'relative', width: 40, height: 40, display: 'grid', placeItems: 'center' }}>
            <svg width="40" height="40" viewBox="0 0 40 40" style={{ position: 'absolute', transform: 'rotate(-90deg)' }}>
              <circle cx="20" cy="20" r={R} fill="none" stroke="rgba(255,255,255,0.18)" strokeWidth="2.5"/>
              <circle cx="20" cy="20" r={R} fill="none" stroke={AD_RING} strokeWidth="2.5" strokeLinecap="round"
                      strokeDasharray={C} strokeDashoffset={C * (1 - frac)} style={{ transition: 'stroke-dashoffset 1s linear' }}/>
            </svg>
            <span className="ff-mono" style={{ fontSize: 'var(--t-label)', color: '#fff', fontVariantNumeric: 'tabular-nums' }}>{done ? '✓' : left}</span>
          </span>
          <button onClick={onClose} aria-label="Close ad" style={{
            appearance: 'none', cursor: 'pointer', width: 44, height: 44, margin: -7, padding: 0, borderRadius: 999,
            background: 'transparent', border: 'none', color: '#fff', display: 'grid', placeItems: 'center',
            opacity: done ? 1 : 0.5,
          }}>
            <span style={{ width: 30, height: 30, borderRadius: 999, background: 'rgba(255,255,255,0.12)', display: 'grid', placeItems: 'center' }}>
              <svg width="13" height="13" viewBox="0 0 14 14"><path d="M2 2l10 10M12 2L2 12" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/></svg>
            </span>
          </button>
        </div>
      </div>

      {/* ad creative — striped placeholder per house style */}
      <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column' }}>
        <div style={{ flex: 1, display: 'grid', placeItems: 'center', padding: '90px 24px 0' }}>
          <div style={{
            width: '100%', maxWidth: 320, aspectRatio: '4 / 5', borderRadius: 12, overflow: 'hidden', position: 'relative',
            background: 'repeating-linear-gradient(135deg, #1c1714 0 14px, #221a15 14px 28px)',
            border: '1px solid rgba(255,255,255,0.08)', display: 'flex', flexDirection: 'column', justifyContent: 'space-between', padding: 20,
          }}>
            <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.18em', textTransform: 'uppercase', color: 'rgba(255,255,255,0.45)' }}>
              SPONSORED · VIDEO
            </div>
            <div style={{ textAlign: 'center' }}>
              <div className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, letterSpacing: '-0.02em', color: '#F0DCB8', lineHeight: 1.05 }}>
                Daily Grind Co.
              </div>
              <div style={{ fontSize: 'var(--t-support)', color: 'rgba(240,220,184,0.7)', marginTop: 8, lineHeight: 1.4 }}>
                Fresh-roasted beans, delivered weekly.
              </div>
            </div>
            <div className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.16em', textTransform: 'uppercase', color: 'rgba(255,255,255,0.4)', textAlign: 'center' }}>
              [ ad creative placeholder ]
            </div>
          </div>
        </div>

        {/* reward dock */}
        <div style={{
          background: '#161210', borderTop: '1px solid rgba(255,255,255,0.08)',
          padding: '20px 24px 30px', textAlign: 'center',
        }}>
          <div className="smallcaps" style={{ color: 'rgba(255,255,255,0.5)', marginBottom: 6 }}>YOUR REWARD</div>
          <div className="ff-display" style={{ fontSize: 'var(--t-heading)', fontWeight: 400, letterSpacing: '-0.01em', color: '#fff', lineHeight: 1.1 }}>
            {minutes} minutes of {f.label}
          </div>
          {done ? (
            <button className="btn btn-primary" style={{ marginTop: 16 }} onClick={onClaim}>
              Claim {minutes} min preview
            </button>
          ) : (
            <div className="ff-mono" style={{
              marginTop: 16, padding: '15px 16px', borderRadius: 2,
              background: 'rgba(255,255,255,0.06)', color: 'rgba(255,255,255,0.7)',
              fontSize: 'var(--t-label)', letterSpacing: '0.1em', textTransform: 'uppercase',
            }}>
              Reward in {left}s…
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

// ── ROASTY GIFT SCREEN ───────────────────────────────────────
// Shown after a *perfect* module (every lesson, every quiz correct) to a free
// user — a one-time, time-limited Roasty Studio unlock as a thank-you.
function RoastyGiftScreen({ module, minutes = TRIAL_GIFT_MIN, onPersonalize, onLater }) {
  const hrs = Math.round(minutes / 60);
  return (
    <div className="screen" data-screen-label="Roasty Gift" style={{ background: 'var(--bg)' }}>
      <div aria-hidden="true" style={{
        position: 'absolute', inset: 0, pointerEvents: 'none',
        background: 'radial-gradient(ellipse at 50% 20%, color-mix(in oklab, var(--accent) 18%, transparent) 0%, transparent 60%)',
      }}/>
      <div className="scroll" style={{ paddingTop: 80, paddingBottom: 28, display: 'flex', flexDirection: 'column' }}>
        <div className="px-24" style={{ textAlign: 'center' }}>
          <div className="smallcaps" style={{ color: 'var(--accent)' }}>PERFECT MODULE</div>
          <h1 className="ff-display" style={{ fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.06, letterSpacing: '-0.02em', margin: '10px 0 0', color: 'var(--ink)', textWrap: 'pretty' }}>
            A little gift<br/>from us.
          </h1>
        </div>

        <div style={{ display: 'flex', justifyContent: 'center', paddingTop: 10 }}>
          {window.Roasty
            ? <Roasty state="module" size={150} hat="field" gear="glasses" sprout="flower"/>
            : <div style={{ width: 150, height: 150 }}/>}
        </div>

        <div className="px-24" style={{ textAlign: 'center', paddingTop: 6 }}>
          <p style={{ fontSize: 'var(--t-body)', lineHeight: 1.55, color: 'var(--ink-mute)', margin: '0 auto', maxWidth: 300, textWrap: 'pretty' }}>
            You aced every question in <strong style={{ color: 'var(--ink)' }}>{module ? module.title : 'this module'}</strong>. Here’s {hrs} hours in <strong style={{ color: 'var(--ink)' }}>Roasty Studio</strong> — dress Roasty up, on the house.
          </p>
          <div style={{ display: 'inline-flex', marginTop: 16 }}>
            <TrialBadge until={Date.now() + minutes * 60000} floating={false}/>
          </div>
        </div>

        <div style={{ flex: 1, minHeight: 18 }}/>

        <div className="px-24" style={{ paddingTop: 24 }}>
          <button className="btn btn-primary" onClick={onPersonalize}>Personalize Roasty</button>
          <div style={{ marginTop: 10 }}>
            <a className="btn btn-ghost" href="#" style={{ display: 'block', textAlign: 'center', textDecoration: 'none' }} onClick={(e) => { e.preventDefault(); onLater(); }}>Maybe later</a>
          </div>
        </div>
      </div>
    </div>
  );
}

// ── FEATURE LOCK (full-screen teaser) ────────────────────────
// Wraps a whole gated tab. `style` selects the visual direction:
//   'blur'    — frosted peek at the real screen
//   'hard'    — opaque locked panel, no preview
//   'curtain' — content visible up top, a rising curtain + lock card
function LockCard({ featureKey, onUnlock, glass, showAd = true }) {
  const f = PLUS_FEATURES[featureKey] || { label: 'This feature', blurb: '' };
  return (
    <div style={{
      width: '100%', maxWidth: 320, borderRadius: 16, padding: '22px 22px 22px', textAlign: 'center',
      background: glass ? 'color-mix(in oklab, var(--surface) 82%, transparent)' : 'var(--surface)',
      border: '1px solid var(--rule)',
      boxShadow: '0 24px 60px rgba(0,0,0,0.32)',
      backdropFilter: glass ? 'blur(6px)' : 'none', WebkitBackdropFilter: glass ? 'blur(6px)' : 'none',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10 }}>
        <span style={{
          width: 30, height: 30, borderRadius: 999, display: 'grid', placeItems: 'center', flexShrink: 0,
          background: 'color-mix(in oklab, var(--accent) 14%, var(--surface))', color: 'var(--accent)',
        }}>
          <LockGlyph size={15}/>
        </span>
        <h2 className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, letterSpacing: '-0.015em', color: 'var(--ink)', lineHeight: 1.08, margin: 0 }}>
          {f.label}
        </h2>
        <span aria-hidden="true" style={{ width: 30, flexShrink: 0 }}/>
      </div>
      <p style={{ fontSize: 'var(--t-support)', lineHeight: 1.5, color: 'var(--ink-mute)', margin: '10px auto 20px', maxWidth: 260, textWrap: 'pretty' }}>
        {f.blurb}
      </p>
      <button className="btn btn-primary" onClick={onUnlock}>Unlock Foundations</button>
      {showAd && (
        <p className="ff-mono" style={{ fontSize: 'var(--t-micro)', letterSpacing: '0.06em', color: 'var(--ink-mute)', textTransform: 'uppercase', margin: '12px 0 0' }}>
          Or watch a short ad to preview
        </p>
      )}
    </div>
  );
}

function FeatureLock({ featureKey, style = 'blur', preview, onUnlock, showAd = true }) {
  if (style === 'hard') {
    return (
      <div className="screen" data-screen-label="Locked" style={{ background: 'var(--bg)' }}>
        <div className="scroll" style={{ display: 'grid', placeItems: 'center', padding: '24px' }}>
          <LockCard featureKey={featureKey} onUnlock={onUnlock} glass={false} showAd={showAd}/>
        </div>
      </div>
    );
  }
  // blur and curtain both render the real screen behind a treatment.
  const curtain = style === 'curtain';
  return (
    <div className="screen" data-screen-label="Locked" style={{ background: 'var(--bg)', position: 'absolute', inset: 0, overflow: 'hidden' }}>
      <div aria-hidden="true" style={{
        position: 'absolute', inset: 0, pointerEvents: 'none',
        filter: curtain ? 'none' : 'blur(3px) saturate(0.9)',
        transform: curtain ? 'none' : 'scale(1.06)',
        opacity: curtain ? 1 : 0.9,
      }}>
        {preview}
      </div>
      {/* dimming / curtain overlay */}
      <div aria-hidden="true" style={{
        position: 'absolute', inset: 0, pointerEvents: 'none',
        background: curtain
          ? 'linear-gradient(180deg, transparent 0%, color-mix(in oklab, var(--bg) 30%, transparent) 34%, var(--bg) 70%)'
          : 'var(--veil)',
      }}/>
      <div style={{
        position: 'absolute', inset: 0, display: 'flex',
        alignItems: 'flex-end', justifyContent: 'center',
        padding: curtain ? '0 20px 40px' : '0 20px 32px',
      }}>
        <LockCard featureKey={featureKey} onUnlock={onUnlock} glass={!curtain} showAd={showAd}/>
      </div>
    </div>
  );
}

window.PLUS_FEATURES = PLUS_FEATURES;
window.FOUNDATIONS_PRICE = FOUNDATIONS_PRICE;
window.TRIAL_AD_MIN = TRIAL_AD_MIN;
window.TRIAL_GIFT_MIN = TRIAL_GIFT_MIN;
window.LockGlyph = LockGlyph;
window.LockBadge = LockBadge;
window.PlusPill = PlusPill;
window.TrialBadge = TrialBadge;
window.PlusGateSheet = PlusGateSheet;
window.RewardedAdScreen = RewardedAdScreen;
window.RoastyGiftScreen = RoastyGiftScreen;
window.FeatureLock = FeatureLock;
