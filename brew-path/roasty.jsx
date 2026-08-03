// roasty.jsx — The Roasty mascot. Used everywhere in the app.
// Exposes <Roasty state size /> and <RoastyLoadingScreen onDone />.

const { useState: useStateRO, useEffect: useEffectRO, useRef: useRefRO } = React;

// ─── one-time CSS injection ────────────────────────────────
(function injectRoastyStyles() {
  if (document.getElementById('roasty-styles')) return;
  const css = `
.roasty-wrap { display: inline-block; line-height: 0; }
.roasty { overflow: visible; display: block; }

/* ── state→face visibility ── */
.roasty .face-default,
.roasty .face-correct,
.roasty .face-wrong,
.roasty .face-lesson,
.roasty .face-module,
.roasty .face-points,
.roasty .face-card,
.roasty .face-sleep,
.roasty .face-awake { display: none; }
.roasty[data-state="idle"]    .face-default { display: block; }
.roasty[data-state="correct"] .face-correct { display: block; }
.roasty[data-state="wrong"]   .face-wrong   { display: block; }
.roasty[data-state="lesson"]  .face-lesson  { display: block; }
.roasty[data-state="module"]  .face-module  { display: block; }
.roasty[data-state="points"]      .face-points      { display: block; }
.roasty[data-state="card"]    .face-card    { display: block; }
.roasty[data-state="sleep"]   .face-sleep   { display: block; }
.roasty[data-state="awake"]   .face-awake   { display: block; }

/* ── state→particle visibility ── */
.roasty .confetti, .roasty .sparkles, .roasty .points-burst,
.roasty .card-glow, .roasty .module-rays, .roasty .wrong-x,
.roasty .sleep-zzz { display: none; }
.roasty[data-state="correct"] .sparkles,
.roasty[data-state="lesson"]  .confetti,
.roasty[data-state="module"]  .module-rays,
.roasty[data-state="points"]      .points-burst,
.roasty[data-state="card"]    .card-glow,
.roasty[data-state="wrong"]   .wrong-x,
.roasty[data-state="sleep"]   .sleep-zzz { display: block; }

/* ── idle breath ── */
@keyframes roasty-breathe {
  0%, 100% { transform: translateY(0) scale(1, 1); }
  50%      { transform: translateY(-3px) scale(1.005, 0.995); }
}
.roasty .body-group { transform-origin: 100px 158px; transform-box: fill-box; }
.roasty[data-state="idle"] .body-group {
  animation: roasty-breathe 3.2s ease-in-out infinite;
}

/* ── leaf sway ── */
@keyframes roasty-leaf-sway {
  0%, 100% { transform: rotate(-2deg); }
  50%      { transform: rotate(2deg); }
}
.roasty .sprout-group { transform-origin: 50% 100%; transform-box: fill-box; }
.roasty[data-state="idle"] .sprout-group,
.roasty[data-state="correct"] .sprout-group,
.roasty[data-state="lesson"] .sprout-group,
.roasty[data-state="module"] .sprout-group,
.roasty[data-state="points"] .sprout-group,
.roasty[data-state="card"] .sprout-group {
  animation: roasty-leaf-sway 2.8s ease-in-out infinite;
}

/* ── correct: hop + sparkles ── */
@keyframes roasty-hop {
  0%, 100% { transform: translateY(0); }
  25%      { transform: translateY(-10px) rotate(-3deg); }
  50%      { transform: translateY(0) rotate(0); }
  75%      { transform: translateY(-10px) rotate(3deg); }
}
.roasty[data-state="correct"] .body-group {
  animation: roasty-hop 900ms ease-out;
}

/* ── wrong: shake ── */
@keyframes roasty-shake {
  0%, 100% { transform: translateX(0); }
  20% { transform: translateX(-5px); }
  40% { transform: translateX(5px); }
  60% { transform: translateX(-3px); }
  80% { transform: translateX(3px); }
}
.roasty[data-state="wrong"] .body-group {
  animation: roasty-shake 500ms ease-in-out;
}

/* ── lesson: jump ── */
@keyframes roasty-jump {
  0%   { transform: translateY(0); }
  30%  { transform: translateY(-18px) scale(1.04, 0.96); }
  50%  { transform: translateY(-8px)  scale(1, 1); }
  70%  { transform: translateY(-14px); }
  100% { transform: translateY(0); }
}
.roasty[data-state="lesson"] .body-group {
  animation: roasty-jump 1.1s cubic-bezier(.4,1.6,.5,1);
}

/* ── module: grow ── */
@keyframes roasty-grow {
  0%   { transform: scale(1); }
  55%  { transform: scale(1.08); }
  100% { transform: scale(1.04); }
}
.roasty[data-state="module"] .body-group {
  animation: roasty-grow 1300ms cubic-bezier(.34,1.1,.5,1) forwards;
}

/* ── module: rays radiate outward from the bean ── */
@keyframes roasty-ray-radiate {
  0%   { transform: scale(0.5); opacity: 0; }
  28%  { opacity: 0.7; }
  100% { transform: scale(1.2); opacity: 0; }
}
.roasty .module-rays { transform-origin: 100px 158px; transform-box: fill-box; }
.roasty[data-state="module"] .module-rays {
  animation: roasty-ray-radiate 1600ms cubic-bezier(.2,.6,.3,1) infinite;
}

/* ── Points: rise ── */
@keyframes roasty-points-rise {
  0%   { transform: translateY(0); opacity: 0; }
  20%  { opacity: 1; }
  100% { transform: translateY(-50px); opacity: 0; }
}
.roasty[data-state="points"] .points-burst {
  animation: roasty-points-rise 1.3s ease-out;
}

/* ── card: shimmer ── */
@keyframes roasty-shimmer {
  0%, 100% { filter: drop-shadow(0 0 0   var(--warn)); }
  50%      { filter: drop-shadow(0 0 12px var(--warn)); }
}
.roasty[data-state="card"] .body-group {
  animation: roasty-shimmer 1.6s ease-in-out infinite;
}

/* ── sleep: slow tilt-breathe; sprout shrunk ── */
@keyframes roasty-sleep-breathe {
  0%, 100% { transform: rotate(6deg) scale(1, 1); }
  50%      { transform: rotate(6deg) scale(1.018, 0.982); }
}
.roasty[data-state="sleep"] .body-group {
  animation: roasty-sleep-breathe 3.4s ease-in-out infinite;
}
.roasty[data-state="sleep"] .sprout-group,
.roasty[data-state="awake"] .sprout-group {
  transform: scale(0.15);
}

/* ── awake: quick blink-pop ── */
@keyframes roasty-awake-pop {
  0%   { transform: scale(0.94); }
  50%  { transform: scale(1.04); }
  100% { transform: scale(1); }
}
.roasty[data-state="awake"] .body-group {
  animation: roasty-awake-pop 400ms ease-out;
}

/* ── sparkle twinkle ── */
@keyframes roasty-twinkle {
  0%, 100% { opacity: 0; transform: scale(0.3); }
  50%      { opacity: 1; transform: scale(1); }
}
.roasty .sparkles g { animation: roasty-twinkle 1.2s ease-in-out infinite; transform-origin: center; transform-box: fill-box; }
.roasty .sparkles g:nth-child(2) { animation-delay: 0.3s; }
.roasty .sparkles g:nth-child(3) { animation-delay: 0.6s; }
.roasty .sparkles g:nth-child(4) { animation-delay: 0.9s; }

/* ── confetti ── */
@keyframes roasty-confetti {
  0%   { transform: translateY(-30px) rotate(0); opacity: 0; }
  20%  { opacity: 1; }
  100% { transform: translateY(180px) rotate(540deg); opacity: 0; }
}
.roasty .confetti rect,
.roasty .confetti circle {
  animation: roasty-confetti 1.6s ease-in infinite;
  transform-origin: center;
  transform-box: fill-box;
}
.roasty .confetti *:nth-child(1) { animation-delay: 0s;    }
.roasty .confetti *:nth-child(2) { animation-delay: 0.2s;  }
.roasty .confetti *:nth-child(3) { animation-delay: 0.4s;  }
.roasty .confetti *:nth-child(4) { animation-delay: 0.6s;  }
.roasty .confetti *:nth-child(5) { animation-delay: 0.1s;  }
.roasty .confetti *:nth-child(6) { animation-delay: 0.5s;  }
.roasty .confetti *:nth-child(7) { animation-delay: 0.3s;  }
.roasty .confetti *:nth-child(8) { animation-delay: 0.7s;  }

/* ── sleep zzz float ── */
@keyframes roasty-zzz-float {
  0%   { opacity: 0; transform: translate(0, 0); }
  30%  { opacity: 1; }
  100% { opacity: 0; transform: translate(8px, -12px); }
}
.roasty .sleep-zzz text { animation: roasty-zzz-float 2.6s ease-in-out infinite; }
.roasty .sleep-zzz text:nth-child(2) { animation-delay: 0.6s; }
.roasty .sleep-zzz text:nth-child(3) { animation-delay: 1.2s; }
  `;
  const el = document.createElement('style');
  el.id = 'roasty-styles';
  el.textContent = css;
  document.head.appendChild(el);
})();

// ─── Customization presets + accessory art ───────────────
// Roasty can be dressed up (premium feature). Each instance reads its own
// props first, then falls back to window.ROASTY_CONFIG (the applied look), so
// every <Roasty/> across the app reflects what the user customized.
const ROAST_STOPS = {
  light:    ['#C49A6C', '#A87B4F', '#855B36'],
  medium:   ['#8C5634', '#6B3E22', '#4A2B19'],
  dark:     ['#6E4329', '#4A2C19', '#2C190E'],
  espresso: ['#4A2E1C', '#2F1B10', '#180C06'],
};

function roastySproutArt(kind, u) {
  const leafFill = 'url(#gr-leaf-' + u + ')';
  if (kind === 'none') return null;
  if (kind === 'sprig') return (
    <>
      <path d="M100 88 Q100 80 100 72" stroke="#5E7148" strokeWidth="3" strokeLinecap="round" fill="none"/>
      <path d="M100 76 C 113 65, 127 67, 131 75 C 127 84, 111 82, 100 78 Z" fill={leafFill}/>
      <path d="M100 77 Q 113 74, 127 76" stroke="#5E7148" strokeWidth="1" fill="none" strokeLinecap="round" opacity="0.6"/>
      <circle cx="91" cy="70" r="5.5" fill="#B8533A"/>
      <circle cx="89" cy="68" r="1.8" fill="#E0997A"/>
      <circle cx="99" cy="65" r="4.5" fill="#9E4632"/>
    </>
  );
  if (kind === 'flower') return (
    <>
      <path d="M100 89 Q100 81 100 74" stroke="#5E7148" strokeWidth="3" strokeLinecap="round" fill="none"/>
      <path d="M100 81 C 91 75, 83 77, 81 82 C 85 87, 94 85, 100 82 Z" fill={leafFill}/>
      <path d="M100 81 C 109 75, 117 77, 119 82 C 115 87, 106 85, 100 82 Z" fill={leafFill}/>
      <g transform="translate(100 68)">
        <circle cx="0"  cy="-7" r="4.6" fill="#FBF7EE"/>
        <circle cx="7"  cy="-2" r="4.6" fill="#FBF7EE"/>
        <circle cx="4"  cy="6"  r="4.6" fill="#FBF7EE"/>
        <circle cx="-4" cy="6"  r="4.6" fill="#FBF7EE"/>
        <circle cx="-7" cy="-2" r="4.6" fill="#FBF7EE"/>
        <circle cx="0"  cy="0"  r="3.2" fill="#C8843A"/>
      </g>
    </>
  );
  // default 'leaf'
  return (
    <>
      <path d="M100 87 Q100 79 100 72" stroke="#5E7148" strokeWidth="3" strokeLinecap="round" fill="none"/>
      <path d="M100 75 C 87 64, 73 66, 69 74 C 73 83, 89 81, 100 77 Z" fill={leafFill}/>
      <path d="M100 76 Q 87 73, 73 75" stroke="#5E7148" strokeWidth="1" fill="none" strokeLinecap="round" opacity="0.6"/>
      <path d="M100 75 C 113 64, 127 66, 131 74 C 127 83, 111 81, 100 77 Z" fill={leafFill}/>
      <path d="M100 76 Q 113 73, 127 75" stroke="#5E7148" strokeWidth="1" fill="none" strokeLinecap="round" opacity="0.6"/>
    </>
  );
}

function roastyGearArt(kind) {
  if (!kind || kind === 'none') return null;
  if (kind === 'glasses') return (
    <g>
      <circle cx="80"  cy="150" r="13" fill="#FBF7EE" fillOpacity="0.16" stroke="#2A1B12" strokeWidth="2.4"/>
      <circle cx="120" cy="150" r="13" fill="#FBF7EE" fillOpacity="0.16" stroke="#2A1B12" strokeWidth="2.4"/>
      <path d="M93 149 q7 -4 14 0" stroke="#2A1B12" strokeWidth="2.4" fill="none"/>
      <path d="M67 149 q-12 -2 -17 4" stroke="#2A1B12" strokeWidth="2.4" fill="none" strokeLinecap="round"/>
      <path d="M133 149 q12 -2 17 4" stroke="#2A1B12" strokeWidth="2.4" fill="none" strokeLinecap="round"/>
    </g>
  );
  if (kind === 'sunglasses') return (
    <g>
      <rect x="63"  y="142" width="31" height="17" rx="7.5" fill="#2A1B12"/>
      <rect x="106" y="142" width="31" height="17" rx="7.5" fill="#2A1B12"/>
      <path d="M94 147 h12" stroke="#2A1B12" strokeWidth="3" strokeLinecap="round"/>
      <path d="M63 146 q-12 -1 -16 4" stroke="#2A1B12" strokeWidth="2.4" fill="none" strokeLinecap="round"/>
      <path d="M137 146 q12 -1 16 4" stroke="#2A1B12" strokeWidth="2.4" fill="none" strokeLinecap="round"/>
      <ellipse cx="72"  cy="147" rx="3.2" ry="2" fill="#FBF7EE" opacity="0.28"/>
      <ellipse cx="115" cy="147" rx="3.2" ry="2" fill="#FBF7EE" opacity="0.28"/>
    </g>
  );
  if (kind === 'scarf') return (
    <g>
      <path d="M50 196 Q100 214 150 196 L150 209 Q100 227 50 209 Z" fill="#7A8471"/>
      <path d="M118 206 q11 15 5 32 q-9 2 -13 -2 q5 -15 0 -28 z" fill="#6B7563"/>
      <path d="M58 202 Q100 216 142 202" stroke="#6B7563" strokeWidth="1.4" fill="none" opacity="0.7"/>
    </g>
  );
  if (kind === 'headphones') return (
    <g>
      <path d="M48 152 a52 52 0 0 1 104 0" fill="none" stroke="#2A1B12" strokeWidth="6" strokeLinecap="round"/>
      <rect x="35"  y="142" width="19" height="28" rx="8" fill="#2A1B12"/>
      <rect x="146" y="142" width="19" height="28" rx="8" fill="#2A1B12"/>
      <rect x="39"  y="147" width="11" height="18" rx="5" fill="#B8533A"/>
      <rect x="150" y="147" width="11" height="18" rx="5" fill="#B8533A"/>
    </g>
  );
  return null;
}

function roastyHatArt(kind) {
  if (!kind || kind === 'none') return null;
  if (kind === 'beanie') return (
    <g>
      <path d="M44 120 Q48 76 100 74 Q152 76 156 120 Z" fill="#B8533A"/>
      <path d="M42 114 Q100 126 158 114 L158 129 Q100 140 42 129 Z" fill="#9E4632"/>
      <path d="M66 96 Q100 89 134 96" stroke="#9E4632" strokeWidth="2" fill="none" opacity="0.55"/>
      <path d="M64 105 Q100 98 136 105" stroke="#9E4632" strokeWidth="2" fill="none" opacity="0.4"/>
    </g>
  );
  if (kind === 'field') return (
    <g>
      <ellipse cx="100" cy="117" rx="80" ry="16" fill="#C9A35E"/>
      <ellipse cx="100" cy="117" rx="80" ry="16" fill="none" stroke="#A8823F" strokeWidth="1.5"/>
      <path d="M48 116 Q50 80 100 78 Q150 80 152 116 Z" fill="#D9B873"/>
      <path d="M62 110 Q100 119 138 110" stroke="#A8823F" strokeWidth="3.5" fill="none"/>
    </g>
  );
  if (kind === 'cap') return (
    <g>
      <path d="M54 118 Q58 80 100 78 Q142 80 146 118 Z" fill="#7A8471"/>
      <path d="M142 115 Q177 113 182 126 Q154 128 142 122 Z" fill="#5E6857"/>
      <circle cx="100" cy="80" r="3" fill="#5E6857"/>
    </g>
  );
  return null;
}

// ─── Roasty SVG component ─────────────────────────────────
let _roastyCounter = 0;
function Roasty({ state = 'idle', size = 160, replayKey, style, roast, hat, gear, sprout, pointsAmount = 10 }) {
  const idRef = useRefRO(null);
  if (idRef.current === null) idRef.current = 'r' + (++_roastyCounter);
  const u = idRef.current;

  const cfg = window.ROASTY_CONFIG || {};
  const _roast  = roast  || cfg.roast  || 'medium';
  const _hat    = hat    || cfg.hat    || 'none';
  const _gear   = gear   || cfg.gear   || 'none';
  const _sprout = sprout || cfg.sprout || 'leaf';
  const beanStops = ROAST_STOPS[_roast] || ROAST_STOPS.medium;

  // re-mount on state OR look change so one-shot CSS animations restart
  const mountKey = state + ':' + (replayKey || 0) + ':' + _roast + _hat + _gear + _sprout;

  return (
    <span key={mountKey} className="roasty-wrap" style={{ width: size, height: size * 1.4, ...style }}>
      <svg className="roasty" data-state={state} viewBox="0 0 200 280" preserveAspectRatio="xMidYMid meet"
           style={{ width: '100%', height: '100%' }}>
        <defs>
          <radialGradient id={'gr-bean-' + u} cx="32%" cy="32%" r="75%">
            <stop offset="0%"  stopColor={beanStops[0]}/>
            <stop offset="55%" stopColor={beanStops[1]}/>
            <stop offset="100%" stopColor={beanStops[2]}/>
          </radialGradient>
          <radialGradient id={'gr-leaf-' + u} cx="35%" cy="30%" r="75%">
            <stop offset="0%"  stopColor="#B5C497"/>
            <stop offset="100%" stopColor="#5E7148"/>
          </radialGradient>
          <radialGradient id={'gr-glow-' + u} cx="50%" cy="50%" r="50%">
            <stop offset="0%"   stopColor="#E6C68A" stopOpacity="0.6"/>
            <stop offset="100%" stopColor="#E6C68A" stopOpacity="0"/>
          </radialGradient>
        </defs>

        {/* card glow */}
        <g className="card-glow">
          <ellipse cx="100" cy="160" rx="120" ry="110" fill={'url(#gr-glow-' + u + ')'}/>
        </g>

        {/* module rays */}
        <g className="module-rays" opacity="0.55">
          <g fill="none" stroke="var(--warn)" strokeWidth="2" strokeLinecap="round">
            <line x1="100" y1="40"  x2="100" y2="60"/>
            <line x1="170" y1="70"  x2="156" y2="84"/>
            <line x1="200" y1="158" x2="180" y2="158"/>
            <line x1="170" y1="230" x2="156" y2="216"/>
            <line x1="100" y1="260" x2="100" y2="240"/>
            <line x1="30"  y1="230" x2="44"  y2="216"/>
            <line x1="0"   y1="158" x2="20"  y2="158"/>
            <line x1="30"  y1="70"  x2="44"  y2="84"/>
          </g>
        </g>

        {/* confetti */}
        <g className="confetti">
          <rect x="40"  y="60"  width="6" height="8" fill="#B8533A"/>
          <rect x="158" y="50"  width="6" height="6" fill="#7A8471"/>
          <circle cx="30"  cy="120" r="3" fill="#C8843A"/>
          <rect x="170" y="100" width="5" height="9" fill="#B8533A"/>
          <circle cx="172" cy="180" r="3" fill="#7A8471"/>
          <rect x="22"  y="180" width="6" height="6" fill="#C8843A"/>
          <rect x="60"  y="40"  width="4" height="8" fill="#7A8471"/>
          <rect x="140" y="40"  width="5" height="5" fill="#B8533A"/>
        </g>

        {/* sprout — nestled on the bean when bare-headed */}
        {_hat === 'none' && (
          <g className="sprout-group">
            {roastySproutArt(_sprout, u)}
          </g>
        )}

        {/* body group */}
        <g className="body-group">
          {/* contact shadow */}
          <ellipse cx="100" cy="232" rx="56" ry="6" fill="#2F1A0E" opacity="0.18"/>

          {/* bean body */}
          <path d="
            M 100 90
            C  62 90, 38 120, 38 158
            C  38 200, 64 226, 100 226
            C 136 226, 162 200, 162 158
            C 162 120, 138 90, 100 90 Z"
            fill={'url(#gr-bean-' + u + ')'}/>

          {/* top highlight */}
          <ellipse cx="78" cy="115" rx="22" ry="14" fill="#A26945" opacity="0.45"/>

          {/* bean crease */}
          <path d="M 100 96 Q 88 130, 100 158 Q 112 186, 100 218"
                stroke="#2F1A0E" strokeWidth="2.5" strokeLinecap="round" fill="none" opacity="0.55"/>

          {/* IDLE face */}
          <g className="face-default">
            <ellipse cx="80"  cy="148" rx="10" ry="12" fill="#FBF7EE"/>
            <ellipse cx="80"  cy="151" rx="5"  ry="6"  fill="#2A1B12"/>
            <circle  cx="82"  cy="148" r="1.7" fill="#FBF7EE"/>
            <ellipse cx="120" cy="148" rx="10" ry="12" fill="#FBF7EE"/>
            <ellipse cx="120" cy="151" rx="5"  ry="6"  fill="#2A1B12"/>
            <circle  cx="122" cy="148" r="1.7" fill="#FBF7EE"/>
            <ellipse cx="68"  cy="172" rx="6" ry="3" fill="#C47654" opacity="0.45"/>
            <ellipse cx="132" cy="172" rx="6" ry="3" fill="#C47654" opacity="0.45"/>
            <path d="M 90 180 Q 100 188 110 180" stroke="#2A1B12" strokeWidth="2.5" strokeLinecap="round" fill="none"/>
          </g>

          {/* CORRECT face */}
          <g className="face-correct">
            <path d="M 70 148 Q 80 138 90 148" stroke="#2A1B12" strokeWidth="3" strokeLinecap="round" fill="none"/>
            <path d="M 110 148 Q 120 138 130 148" stroke="#2A1B12" strokeWidth="3" strokeLinecap="round" fill="none"/>
            <ellipse cx="68"  cy="170" rx="7" ry="3.5" fill="#C47654" opacity="0.55"/>
            <ellipse cx="132" cy="170" rx="7" ry="3.5" fill="#C47654" opacity="0.55"/>
            <path d="M 86 178 Q 100 192 114 178" stroke="#2A1B12" strokeWidth="3" strokeLinecap="round" fill="none"/>
          </g>

          {/* WRONG face */}
          <g className="face-wrong">
            <ellipse cx="80"  cy="148" rx="10" ry="12" fill="#FBF7EE"/>
            <ellipse cx="80"  cy="155" rx="5"  ry="5"  fill="#2A1B12"/>
            <ellipse cx="120" cy="148" rx="10" ry="12" fill="#FBF7EE"/>
            <ellipse cx="120" cy="155" rx="5"  ry="5"  fill="#2A1B12"/>
            <path d="M 71 138 L 84 135" stroke="#2A1B12" strokeWidth="2" strokeLinecap="round"/>
            <path d="M 129 138 L 116 135" stroke="#2A1B12" strokeWidth="2" strokeLinecap="round"/>
            <path d="M 91 184 Q 100 180 109 184" stroke="#2A1B12" strokeWidth="2.5" strokeLinecap="round" fill="none"/>
            <ellipse cx="68"  cy="174" rx="5" ry="2.5" fill="#C47654" opacity="0.3"/>
            <ellipse cx="132" cy="174" rx="5" ry="2.5" fill="#C47654" opacity="0.3"/>
          </g>
          <g className="wrong-x" opacity="0.85">
            <circle cx="148" cy="76" r="13" fill="#FBF7EE" stroke="var(--berry)" strokeWidth="2"/>
            <rect x="146" y="68" width="4" height="9" rx="1" fill="var(--berry)"/>
            <circle cx="148" cy="82" r="1.6" fill="var(--berry)"/>
          </g>

          {/* LESSON face */}
          <g className="face-lesson">
            <path d="M 70 148 Q 80 138 90 148" stroke="#2A1B12" strokeWidth="3" strokeLinecap="round" fill="none"/>
            <path d="M 110 148 Q 120 138 130 148" stroke="#2A1B12" strokeWidth="3" strokeLinecap="round" fill="none"/>
            <ellipse cx="68"  cy="170" rx="7" ry="3.5" fill="#C47654" opacity="0.55"/>
            <ellipse cx="132" cy="170" rx="7" ry="3.5" fill="#C47654" opacity="0.55"/>
            <path d="M 84 178 Q 100 198 116 178 Q 100 188 84 178 Z" fill="#2A1B12"/>
            <path d="M 92 186 Q 100 192 108 186 Q 100 190 92 186 Z" fill="#C47654" opacity="0.7"/>
          </g>

          {/* MODULE face — star eyes */}
          <g className="face-module">
            <g transform="translate(80 148)">
              <path d="M 0 -11 L 3 -3 L 11 -3 L 5 2 L 7 10 L 0 5 L -7 10 L -5 2 L -11 -3 L -3 -3 Z" fill="var(--warn)"/>
            </g>
            <g transform="translate(120 148)">
              <path d="M 0 -11 L 3 -3 L 11 -3 L 5 2 L 7 10 L 0 5 L -7 10 L -5 2 L -11 -3 L -3 -3 Z" fill="var(--warn)"/>
            </g>
            <ellipse cx="68"  cy="172" rx="7" ry="3.5" fill="#C47654" opacity="0.55"/>
            <ellipse cx="132" cy="172" rx="7" ry="3.5" fill="#C47654" opacity="0.55"/>
            <ellipse cx="100" cy="185" rx="8" ry="9" fill="#2A1B12"/>
            <ellipse cx="100" cy="188" rx="5" ry="4" fill="#C47654" opacity="0.7"/>
          </g>

          {/* Points face — wink */}
          <g className="face-points">
            <ellipse cx="80"  cy="148" rx="10" ry="12" fill="#FBF7EE"/>
            <ellipse cx="80"  cy="151" rx="5"  ry="6"  fill="#2A1B12"/>
            <circle  cx="82"  cy="148" r="1.7" fill="#FBF7EE"/>
            <path d="M 110 148 Q 120 142 130 148" stroke="#2A1B12" strokeWidth="3" strokeLinecap="round" fill="none"/>
            <ellipse cx="68"  cy="170" rx="6" ry="3" fill="#C47654" opacity="0.5"/>
            <ellipse cx="132" cy="170" rx="6" ry="3" fill="#C47654" opacity="0.5"/>
            <path d="M 90 180 Q 100 188 113 178" stroke="#2A1B12" strokeWidth="2.5" strokeLinecap="round" fill="none"/>
          </g>

          {/* CARD face — wide-eyed O */}
          <g className="face-card">
            <ellipse cx="80"  cy="146" rx="11" ry="13" fill="#FBF7EE"/>
            <ellipse cx="80"  cy="148" rx="6"  ry="7"  fill="#2A1B12"/>
            <circle  cx="83"  cy="145" r="2" fill="#FBF7EE"/>
            <ellipse cx="120" cy="146" rx="11" ry="13" fill="#FBF7EE"/>
            <ellipse cx="120" cy="148" rx="6"  ry="7"  fill="#2A1B12"/>
            <circle  cx="123" cy="145" r="2" fill="#FBF7EE"/>
            <ellipse cx="68"  cy="172" rx="7" ry="3.5" fill="#C47654" opacity="0.5"/>
            <ellipse cx="132" cy="172" rx="7" ry="3.5" fill="#C47654" opacity="0.5"/>
            <ellipse cx="100" cy="184" rx="5" ry="6" fill="#2A1B12"/>
          </g>

          {/* SLEEP face */}
          <g className="face-sleep">
            <path d="M 71 150 L 89 150" stroke="#2A1B12" strokeWidth="3" strokeLinecap="round"/>
            <path d="M 111 150 L 129 150" stroke="#2A1B12" strokeWidth="3" strokeLinecap="round"/>
            <ellipse cx="68"  cy="172" rx="6" ry="3" fill="#C47654" opacity="0.35"/>
            <ellipse cx="132" cy="172" rx="6" ry="3" fill="#C47654" opacity="0.35"/>
            <path d="M 95 182 Q 100 184 105 182" stroke="#2A1B12" strokeWidth="2.5" strokeLinecap="round" fill="none"/>
          </g>

          {/* AWAKE face */}
          <g className="face-awake">
            <ellipse cx="80"  cy="146" rx="11" ry="14" fill="#FBF7EE"/>
            <ellipse cx="80"  cy="148" rx="6"  ry="7"  fill="#2A1B12"/>
            <circle  cx="83"  cy="145" r="2" fill="#FBF7EE"/>
            <ellipse cx="120" cy="146" rx="11" ry="14" fill="#FBF7EE"/>
            <ellipse cx="120" cy="148" rx="6"  ry="7"  fill="#2A1B12"/>
            <circle  cx="123" cy="145" r="2" fill="#FBF7EE"/>
            <ellipse cx="68"  cy="172" rx="6" ry="3" fill="#C47654" opacity="0.4"/>
            <ellipse cx="132" cy="172" rx="6" ry="3" fill="#C47654" opacity="0.4"/>
            <ellipse cx="100" cy="184" rx="4" ry="5" fill="#2A1B12"/>
          </g>

          {/* ── accessories (customization) ── */}
          {roastyGearArt(_gear)}
          {roastyHatArt(_hat)}

          {/* sprout grows up through the hat when one is worn */}
          {_hat !== 'none' && _sprout !== 'none' && (
            <g transform="translate(0 -13)">
              <g className="sprout-group">
                {roastySproutArt(_sprout, u)}
              </g>
            </g>
          )}
        </g>

        {/* sparkles (correct) */}
        <g className="sparkles">
          <g transform="translate(36 80)">
            <path d="M 0 -6 L 1.5 -1.5 L 6 0 L 1.5 1.5 L 0 6 L -1.5 1.5 L -6 0 L -1.5 -1.5 Z" fill="var(--warn)"/>
          </g>
          <g transform="translate(168 100)">
            <path d="M 0 -5 L 1.2 -1.2 L 5 0 L 1.2 1.2 L 0 5 L -1.2 1.2 L -5 0 L -1.2 -1.2 Z" fill="#7A8471"/>
          </g>
          <g transform="translate(40 200)">
            <path d="M 0 -4 L 1 -1 L 4 0 L 1 1 L 0 4 L -1 1 L -4 0 L -1 -1 Z" fill="#B8533A"/>
          </g>
          <g transform="translate(170 200)">
            <path d="M 0 -6 L 1.5 -1.5 L 6 0 L 1.5 1.5 L 0 6 L -1.5 1.5 L -6 0 L -1.5 -1.5 Z" fill="var(--warn)"/>
          </g>
        </g>

        {/* Points burst */}
        <g className="points-burst">
          <rect x="68" y="42" width="64" height="24" rx="2" fill="var(--accent)"/>
          <text x="100" y="59" textAnchor="middle" fontFamily="IBM Plex Mono, monospace"
                fontSize="13" fontWeight="500" fill="var(--accent-ink)" letterSpacing="1">+{pointsAmount} PTS</text>
        </g>

        {/* sleep Zzz */}
        <g className="sleep-zzz" fontFamily="Fraunces, serif" fontStyle="italic" fill="var(--ink-mute)">
          <text x="148" y="80" fontSize="18">z</text>
          <text x="158" y="68" fontSize="14">z</text>
          <text x="166" y="58" fontSize="11">z</text>
        </g>
      </svg>
    </span>
  );
}

// ─── Loading screen ─────────────────────────────────────────
// Loops the wake-up sequence: sleep → drop → awake → sprout → smile → pause → repeat.
// Tap anywhere to advance past the loading screen.
function RoastyLoadingScreen({ onDone, message = 'Brewing your lesson' }) {
  // step 0: sleeping
  // step 1: water drop visible
  // step 2: awake (eyes open)
  // step 3: sprout grows + idle face
  // step 4: idle bob (smile + wave-ready)
  // step 5: hold idle for a beat, then loop back to sleep
  const [step, setStep] = useStateRO(0);
  const [cycle, setCycle] = useStateRO(0);

  useEffectRO(() => {
    // Per-step durations (ms). Step 4 holds, then we pause briefly before restarting.
    const DURATIONS = [1200, 800, 600, 700, 1800, 1400];
    const t = setTimeout(() => {
      if (step >= 5) {
        // restart the loop
        setStep(0);
        setCycle(c => c + 1);
      } else {
        setStep(step + 1);
      }
    }, DURATIONS[step]);
    return () => clearTimeout(t);
  }, [step]);

  // determine state
  const state =
    step <= 1 ? 'sleep' :
    step === 2 ? 'awake' :
    step === 3 ? 'awake' :
    'idle';

  return (
    <div className="screen" data-screen-label="00 Loading"
         style={{ background: 'var(--bg)', cursor: 'pointer' }}
         onClick={() => onDone && onDone()}>
      <style>{`
        @keyframes loading-drop-fall {
          0%   { top: 14%; opacity: 0; }
          30%  { opacity: 1; }
          75%  { top: 38%; opacity: 1; transform: translateX(-50%) scale(1, 1); }
          85%  { top: 41%; opacity: 1; transform: translateX(-50%) scale(1.6, 0.4); }
          100% { top: 41%; opacity: 0; transform: translateX(-50%) scale(1.6, 0.4); }
        }
@keyframes loading-dot-pulse {
          0%, 100% { opacity: 0.22; transform: scale(1); }
          50%      { opacity: 1;    transform: scale(1.4); }
        }
        @keyframes loading-fade-in {
          from { opacity: 0; transform: translateY(4px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        .roasty-loader { position: absolute; inset: 0; display: flex; flex-direction: column;
          align-items: center; justify-content: center; padding: 0 24px; }
        .roasty-loader .drop {
          position: absolute; top: 14%; left: 50%; transform: translateX(-50%);
          width: 12px; height: 18px; pointer-events: none; opacity: 0;
        }
        .roasty-loader[data-step="1"] .drop {
          animation: loading-drop-fall 700ms ease-in forwards;
        }
        .roasty-loader .sprout-group {
          transform: scale(0.15) !important;
          transform-origin: 50% 100% !important;
          transform-box: fill-box !important;
          transition: transform 700ms cubic-bezier(.3,1.5,.4,1);
        }
        .roasty-loader[data-step="3"] .sprout-group,
        .roasty-loader[data-step="4"] .sprout-group,
        .roasty-loader[data-step="5"] .sprout-group {
          transform: scale(1) !important;
        }
        .roasty-loader .caption {
          margin-top: 56px;
          text-align: center;
          min-height: 60px;
          opacity: 0;
          transition: opacity 300ms ease;
        }
        .roasty-loader[data-step="4"] .caption,
        .roasty-loader[data-step="5"] .caption { opacity: 1; animation: loading-fade-in 500ms ease both; }
        .roasty-loader .caption .msg {
          font-family: 'Fraunces', serif; font-style: italic; font-weight: 400;
          font-size: var(--t-heading); letter-spacing: -0.02em; color: var(--ink);
          margin-bottom: 14px;
        }
        .roasty-loader .dots { display: inline-flex; gap: 6px; }
        .roasty-loader .dots span {
          width: 5px; height: 5px; border-radius: 50%;
          background: var(--accent);
          animation: loading-dot-pulse 1.4s ease-in-out infinite;
        }
        .roasty-loader .dots span:nth-child(2) { animation-delay: 0.2s; }
        .roasty-loader .dots span:nth-child(3) { animation-delay: 0.4s; }
        .roasty-loader .brand-mark {
          position: absolute; bottom: 80px; left: 0; right: 0;
        }
      `}</style>

      <div className="roasty-loader" data-step={step}>
        {/* water drop */}
        <svg className="drop" viewBox="0 0 14 20">
          <path d="M7 0 C 9 6 13 10 13 14 A 6 6 0 0 1 1 14 C 1 10 5 6 7 0 Z" fill="var(--water)"/>
          <ellipse cx="5" cy="11" rx="1.5" ry="2.4" fill="var(--water-hi)" opacity="0.7"/>
        </svg>

        {/* Roasty — sprout grows via CSS transition tied to data-step on the loader */}
        <div className="sprout-anim">
          <Roasty state={state} size={170}/>
        </div>

        <div className="caption">
          <div className="msg">{message}</div>
          <div className="dots" aria-hidden="true"><span></span><span></span><span></span></div>
        </div>

        <div className="brand-mark tap-cue">
          {cycle === 0 ? 'BREWPATH' : 'TAP ANYWHERE TO CONTINUE'}
        </div>
      </div>
    </div>
  );
}

window.Roasty = Roasty;
window.RoastyLoadingScreen = RoastyLoadingScreen;

// ─── Roasty Moment ────────────────────────────────────────
// A brief, full-screen beat where Roasty appears alone with a
// short line, then hands off to the screen that follows
// (lesson complete, reward, streak…). Keeps the mascot out of
// the content screens so they stay calm and legible.
function RoastyMoment({ state = 'lesson', size = 184, eyebrow, title, autoMs = 2000, onDone }) {
  const doneRef = useRefRO(false);
  const finish = () => { if (!doneRef.current) { doneRef.current = true; onDone && onDone(); } };
  useEffectRO(() => {
    const t = setTimeout(finish, autoMs);
    return () => clearTimeout(t);
  }, []);

  return (
    <div className="screen" data-screen-label="Roasty"
         onClick={finish}
         style={{
           background: 'var(--bg)', cursor: 'pointer',
           display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
           textAlign: 'center', padding: '0 32px',
         }}>
      <style>{`
        @keyframes roastyMomentIn {
          from { opacity: 0; transform: translateY(10px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes roastyMomentBar { from { transform: scaleX(0); } to { transform: scaleX(1); } }
        .rm-in   { animation: roastyMomentIn 460ms cubic-bezier(.2,.9,.3,1) both; }
        .rm-in-2 { animation: roastyMomentIn 460ms cubic-bezier(.2,.9,.3,1) 140ms both; }
      `}</style>

      <div className="rm-in"><Roasty state={state} size={size}/></div>

      {eyebrow && (
        <div className="smallcaps rm-in-2" style={{ marginTop: 8, color: 'var(--accent)' }}>{eyebrow}</div>
      )}
      {title && (
        <h1 className="ff-display rm-in-2" style={{
          fontSize: 'var(--t-display)', fontWeight: 400, lineHeight: 1.1, letterSpacing: '-0.02em',
          margin: '12px 0 0', color: 'var(--ink)', maxWidth: 320, textWrap: 'pretty',
        }}>{title}</h1>
      )}

      <div style={{
        position: 'absolute', left: 32, right: 32, bottom: 40,
        height: 3, background: 'var(--surface-2)', borderRadius: 999, overflow: 'hidden',
      }}>
        <div style={{
          height: '100%', background: 'var(--accent)', borderRadius: 999, transformOrigin: 'left',
          animation: `roastyMomentBar ${autoMs}ms linear both`,
        }}/>
      </div>
    </div>
  );
}

window.RoastyMoment = RoastyMoment;

// ─── Replay button ────────────────────────────────────────
// A small, unobtrusive pill for any screen with a one-shot entrance
// animation (reward celebrations, streak ring). Sits top-right, out of the
// way of the top-left close/back control. Tapping it re-runs the screen's
// animation — each host wires onClick to reset its own animation state.
function ReplayButton({ onClick, label = 'Replay', style }) {
  return (
    <button onClick={onClick} aria-label="Replay animation" className="ff-mono"
      style={{
        position: 'absolute', top: 62, right: 18, zIndex: 45,
        appearance: 'none', cursor: 'pointer',
        display: 'inline-flex', alignItems: 'center', gap: 7,
        background: 'var(--surface)', border: '1px solid var(--rule)',
        color: 'var(--ink-mute)', borderRadius: 999, padding: '7px 13px',
        fontSize: 'var(--t-micro)', letterSpacing: '0.14em', textTransform: 'uppercase',
        boxShadow: '0 2px 8px rgba(0,0,0,0.12)',
        ...style,
      }}>
      <svg width="13" height="13" viewBox="0 0 20 20" aria-hidden="true">
        <path d="M15.5 6.5 A6 6 0 1 0 16 10" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round"/>
        <path d="M15.8 4 L16 6.8 L13.2 6.6" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
      {label}
    </button>
  );
}

window.ReplayButton = ReplayButton;

// ─── Roasty Anim Screen ───────────────────────────────────
// A dedicated, full-screen review surface for a single mascot
// state — Roasty centered both axes, animation looping forever.
// One-shot reactions re-trigger on a beat; ambient states (idle,
// sleep, card) loop natively. Used by ?screen=anim-<state> and
// surfaced as tiles in the screens overview.
const ROASTY_ANIM_META = {
  idle:    { label: 'Idle',            note: 'Resting · breathes, leaf sways', beat: null },
  correct: { label: 'Correct answer',  note: 'Hop + sparkles',                 beat: 1750 },
  wrong:   { label: 'Wrong answer',    note: 'Soft wobble',                    beat: 1350 },
  points:  { label: 'Points earned',   note: 'Wink + points rise',             beat: 2150 },
  lesson:  { label: 'Lesson complete', note: 'Jump + confetti',                beat: 1950 },
  module:  { label: 'Module complete', note: 'Grow + rays',                   beat: 1850 },
  card:    { label: 'Card unlocked',   note: 'Shimmer + glow',                 beat: null },
  sleep:   { label: 'Sleeping',        note: 'Slow breathe + Zzz',             beat: null },
  awake:   { label: 'Awake',           note: 'Pop open',                       beat: 1400 },
};

function RoastyAnimScreen({ state = 'idle', size = 220 }) {
  const meta = ROASTY_ANIM_META[state] || { label: state, note: '', beat: 1800 };
  const [k, setK] = useStateRO(0);
  useEffectRO(() => {
    if (!meta.beat) return;                       // native loop, no retrigger
    const id = setInterval(() => setK(x => x + 1), meta.beat);
    return () => clearInterval(id);
  }, [state]);

  return (
    <div className="screen" data-screen-label={`Anim · ${meta.label}`}
         style={{
           background: 'var(--bg)',
           display: 'flex', flexDirection: 'column',
           alignItems: 'center', justifyContent: 'center',
         }}>
      {/* state name, top */}
      <div style={{ position: 'absolute', top: 28, left: 0, right: 0, textAlign: 'center' }}>
        <div className="smallcaps" style={{ color: 'var(--accent)' }}>MASCOT · ANIMATION</div>
      </div>

      {/* Roasty — centered both axes */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Roasty state={state} size={size} replayKey={k}/>
      </div>

      {/* caption, bottom */}
      <div style={{ position: 'absolute', bottom: 40, left: 0, right: 0, textAlign: 'center', padding: '0 32px' }}>
        <div className="ff-display" style={{ fontSize: 'var(--t-title)', fontWeight: 400, letterSpacing: '-0.02em', color: 'var(--ink)' }}>
          {meta.label}
        </div>
        {meta.note && (
          <div className="ff-mono" style={{
            fontSize: 'var(--t-label)', letterSpacing: '0.12em', textTransform: 'uppercase',
            color: 'var(--ink-mute)', marginTop: 8,
          }}>{meta.note}{meta.beat ? '' : ' · loops'}</div>
        )}
      </div>
    </div>
  );
}

window.RoastyAnimScreen = RoastyAnimScreen;
window.ROASTY_ANIM_META = ROASTY_ANIM_META;
