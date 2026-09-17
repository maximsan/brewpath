// swipe.jsx — the ONE horizontal swipe. Card stacks, carousels and list rows
// share this hook so the gesture feels identical wherever it appears.
//
// DIRECTION IS A CONTRACT, app-wide:
//   left  → advance / next
//   right → go back, or set aside (the challenge card parks this way)
// Destructive actions never get a swipe. The same motion must never mean
// "keep this for later" on one screen and "destroy it" on another.
//
// ENGINEERING CONTRACT — rewritten after three failed repairs (Notes §25–27).
// A pointer gesture can complete inside one frame, so NOTHING it depends on may
// wait for React:
//   · pointerdown is a NATIVE listener on the node, attached by the ref
//     callback — not a synthetic React prop.
//   · the node takes EXPLICIT pointer capture, so every move and the release
//     are delivered to it even when its children re-render mid-gesture.
//   · origin, distance and claim state live in ONE ref, written imperatively in
//     the move handler. React state is for painting only; the commit decision
//     never reads it.
// Callers own their own visuals. Pair with a persistent affordance — see the
// Design System, Components → Horizontal swipe.
function useSwipeX({
  onNext, onPrev,
  canNext = true, canPrev = true,
  commitThreshold = 70,
  maxDragDistance = 170,
  // How far the element flies past the edge before the content changes. The
  // committed card must LEAVE, not snap back with new content inside it: a
  // reset-in-place reads as a jump cut. 0 keeps snap-back (list rows want it).
  exitDistance = 0,
  exitDurationMs = 230,
  // Degrees of tilt per 100px dragged. A card that pivots as it leaves reads as
  // a physical object being thrown; pure translation reads as a slide control.
  tiltDegreesPer100px = 0,
}) {
  const [dragX, setDragX] = React.useState(0);
  // The UNDAMPED finger distance. dragX is what the element may move, which on
  // a blocked direction is 22% of the gesture — a caption driven from that is
  // as invisible as the movement it explains (§24).
  const [rawDragX, setRawDragX] = React.useState(0);
  const [isDragging, setIsDragging] = React.useState(false);
  const [isExiting, setIsExiting] = React.useState(false);

  const nodeRef = React.useRef(null);
  const exitTimersRef = React.useRef([]);
  // Everything the native handlers read. Refreshed every render, so the
  // handlers are attached once and never need re-attaching.
  const liveRef = React.useRef(null);
  liveRef.current = {
    onNext, onPrev, canNext, canPrev, commitThreshold, maxDragDistance,
    exitDistance, exitDurationMs, tiltDegreesPer100px,
  };
  // Mutable gesture state. dragX here is the truth the release reads.
  const gestureRef = React.useRef({ active: false, pointerId: null, originX: 0, originY: 0, claimed: false, dragX: 0 });

  React.useEffect(() => () => exitTimersRef.current.forEach(clearTimeout), []);

  const transformFor = (x) => {
    const tilt = liveRef.current.tiltDegreesPer100px;
    return 'translateX(' + x + 'px)' + (tilt ? ' rotate(' + ((x / 100) * tilt).toFixed(2) + 'deg)' : '');
  };

  const resetDrag = () => {
    gestureRef.current.dragX = 0;
    setDragX(0);
    setRawDragX(0);
  };

  const commit = (direction) => {
    const { onNext: next, onPrev: prev, exitDistance: exitBy, exitDurationMs: exitMs } = liveRef.current;
    const fire = () => { if (direction < 0) { next && next(); } else { prev && prev(); } };
    const node = nodeRef.current;
    // Reduce-motion drops the flight entirely: a long tilted fling would be the
    // loudest movement in the app and the only one ignoring the preference.
    const reduced = typeof window !== 'undefined' && window.matchMedia
      && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    const distance = reduced ? 0 : exitBy;
    if (!distance || !node || typeof node.animate !== 'function') { resetDrag(); fire(); return; }
    setIsExiting(true);
    const animation = node.animate(
      [{ transform: transformFor(gestureRef.current.dragX) }, { transform: transformFor(direction * distance) }],
      { duration: exitMs, easing: 'cubic-bezier(0.32,0,0.67,0)', fill: 'forwards' }
    );
    // The animation is PRESENTATION ONLY — the content change is never hostage
    // to it finishing. Whichever lands first wins, once: a cancelled or
    // backgrounded animation would otherwise park the card forever.
    let landed = false;
    let fallbackTimer = null;
    const land = () => {
      if (landed) return;
      landed = true;
      if (fallbackTimer) clearTimeout(fallbackTimer);
      resetDrag();
      setIsExiting(false);
      fire();
      // Release the fill a frame later, after React has re-rendered at centre —
      // cancelling sooner flashes the element back at the old position.
      requestAnimationFrame(() => requestAnimationFrame(() => { try { animation.cancel(); } catch (e) {} }));
    };
    fallbackTimer = setTimeout(land, exitMs + 120);
    exitTimersRef.current.push(fallbackTimer);
    if (animation.finished && animation.finished.then) animation.finished.then(land, land);
    else animation.onfinish = land;
  };

  // One stable set of native handlers, created once.
  const handlersRef = React.useRef(null);
  if (!handlersRef.current) {
    const endGesture = () => {
      const gesture = gestureRef.current;
      if (!gesture.active) return;
      gesture.active = false;
      const node = nodeRef.current;
      // Release the capture while the node still exists and the gesture is
      // over. Releasing at pointerdown (an earlier attempt) let the engine
      // retarget the stream and the drag never started on touch; not releasing
      // at all orphaned it across the re-render the commit causes, and the next
      // gesture on a sibling was swallowed for seconds.
      if (node && gesture.pointerId != null) {
        try { if (node.hasPointerCapture && node.hasPointerCapture(gesture.pointerId)) node.releasePointerCapture(gesture.pointerId); } catch (e) {}
      }
      detachWindowFallback();
      setIsDragging(false);
      const releasedAt = gesture.dragX;
      const claimed = gesture.claimed;
      gesture.pointerId = null;
      const { canNext: allowNext, canPrev: allowPrev, commitThreshold: threshold } = liveRef.current;
      if (!claimed) { resetDrag(); return; }
      if (releasedAt <= -threshold && allowNext) commit(-1);
      else if (releasedAt >= threshold && allowPrev) commit(1);
      else resetDrag();
    };
    const onPointerMove = (event) => {
      const gesture = gestureRef.current;
      if (!gesture.active || (gesture.pointerId != null && event.pointerId !== gesture.pointerId)) return;
      const deltaX = event.clientX - gesture.originX;
      const deltaY = event.clientY - gesture.originY;
      // Claim only once clearly horizontal, so vertical scrolling still works
      // from anywhere on the element.
      if (!gesture.claimed) {
        if (Math.abs(deltaX) < 8 || Math.abs(deltaX) <= Math.abs(deltaY)) return;
        gesture.claimed = true;
      }
      const { canNext: allowNext, canPrev: allowPrev, maxDragDistance: maxDrag } = liveRef.current;
      // Where nothing lies that way the element still moves, heavily damped — a
      // dead element reads as broken, a resisting one reads as "nothing here".
      const blocked = (deltaX < 0 && !allowNext) || (deltaX > 0 && !allowPrev);
      const clamp = (v) => Math.max(-maxDrag, Math.min(maxDrag, v));
      const next = clamp(blocked ? deltaX * 0.22 : deltaX);
      gesture.dragX = next;
      setDragX(next);
      setRawDragX(clamp(deltaX));
    };
    const onPointerDown = (event) => {
      if (event.button != null && event.button > 0) return;
      const node = nodeRef.current;
      const gesture = gestureRef.current;
      gesture.active = true;
      gesture.claimed = false;
      gesture.dragX = 0;
      gesture.pointerId = event.pointerId;
      gesture.originX = event.clientX;
      gesture.originY = event.clientY;
      // EXPLICIT capture: every move and the release are delivered to this node
      // even if its children re-render mid-gesture.
      if (node) {
        try { node.setPointerCapture(event.pointerId); } catch (e) {}
        node.addEventListener('pointermove', onPointerMove);
        node.addEventListener('pointerup', endGesture);
        node.addEventListener('pointercancel', endGesture);
      }
      // Belt and braces for engines that drop the capture (or refuse it): the
      // same handlers on window, removed together with the node's.
      window.addEventListener('pointermove', onPointerMove);
      window.addEventListener('pointerup', endGesture);
      window.addEventListener('pointercancel', endGesture);
      setIsDragging(true);
    };
    const detachWindowFallback = () => {
      const node = nodeRef.current;
      if (node) {
        node.removeEventListener('pointermove', onPointerMove);
        node.removeEventListener('pointerup', endGesture);
        node.removeEventListener('pointercancel', endGesture);
      }
      window.removeEventListener('pointermove', onPointerMove);
      window.removeEventListener('pointerup', endGesture);
      window.removeEventListener('pointercancel', endGesture);
    };
    handlersRef.current = { onPointerDown, endGesture, detachWindowFallback };
  }

  // Ref callback: attaches pointerdown NATIVELY. A React synthetic prop would
  // have been fine in principle, but going native removes the whole class of
  // "did the event reach the component" doubt from a gesture that has failed
  // this way repeatedly.
  const attachRef = React.useCallback((node) => {
    const previous = nodeRef.current;
    if (previous) previous.removeEventListener('pointerdown', handlersRef.current.onPointerDown);
    nodeRef.current = node;
    if (node) node.addEventListener('pointerdown', handlersRef.current.onPointerDown);
  }, []);
  React.useEffect(() => () => handlersRef.current.detachWindowFallback(), []);

  const bind = {
    ref: attachRef,
    // A drag must not also fire the element's click (flip, open, navigate).
    onClickCapture: (event) => {
      if (gestureRef.current.claimed) {
        event.stopPropagation(); event.preventDefault();
        gestureRef.current.claimed = false;
      }
    },
    // A native drag would fire pointercancel and kill the gesture.
    onDragStart: (event) => { event.preventDefault(); },
  };
  const motion = {
    touchAction: 'pan-y',
    transform: dragX ? transformFor(dragX) : 'none',
    // No transition while exiting: the WAAPI animation owns the element then.
    transition: (isDragging || isExiting) ? 'none' : 'transform 240ms cubic-bezier(0.22,0.61,0.36,1)',
  };
  return {
    dragX,
    rawDragX,
    isDragging,
    isExiting,
    // Signed 0..1 per direction: negative while dragging toward next.
    commitProgress: Math.max(-1, Math.min(1, dragX / commitThreshold)),
    bind,
    motion,
  };
}
window.useSwipeX = useSwipeX;

// ───────────────────────────────────────────────────────────
// DeckStack — the standing affordance for a swipeable deck, extracted from the
// flashcard deck so the reward carousel cannot drift from it. A card sits
// visibly behind on each side that HAS a card, and rises into place as the drag
// goes its way, so the current card visibly LEAVES.
//
// Render it inside a `position: relative` box THE SIZE OF THE CARD, as a
// sibling of — never a child of — the element carrying the swipe transform: a
// stack inside the moving element travels with the card and never reads as
// something left behind.
//
// Full opacity with an accent edge, never a dimmed copy of the card: at low
// alpha over this ground it measures ~1.1:1 and disappears (§24). Depth comes
// from the offset and scale, which cost no contrast.
// ───────────────────────────────────────────────────────────
function DeckStack({
  swipe, canPrev, canNext,
  radius = 20, inset = 13, restScale = 0.955, riseDistance = 104,
  shadow = '0 10px 26px rgba(0,0,0,0.18)', style,
}) {
  const dragX = (swipe && swipe.dragX) || 0;
  const isDragging = !!(swipe && swipe.isDragging);
  const isExiting = !!(swipe && swipe.isExiting);
  const sides = [canPrev ? -1 : 0, canNext ? 1 : 0].filter(Boolean);
  return (
    <>
      {sides.map(side => {
        // The card on `side` is revealed by dragging the OTHER way.
        const toward = -side;
        const rise = isExiting && Math.sign(dragX) === toward
          ? 1
          : Math.max(0, Math.min(1, (dragX * toward) / riseDistance));
        return (
          <div key={side} aria-hidden="true" style={{
            position: 'absolute', left: 0, right: 0, top: 0, bottom: 0, zIndex: 0,
            pointerEvents: 'none', borderRadius: radius,
            border: '1px solid color-mix(in oklab, var(--accent) 52%, var(--rule))',
            background: 'color-mix(in oklab, var(--accent) 10%, var(--surface))',
            boxShadow: shadow,
            transformOrigin: side > 0 ? 'center right' : 'center left',
            transform: 'translateX(' + (side * (inset - inset * rise)) + 'px) scale(' + (restScale + (1 - restScale) * rise) + ')',
            transition: isDragging ? 'none' : 'transform 300ms cubic-bezier(0.22,0.61,0.36,1)',
            ...style,
          }}/>
        );
      })}
    </>
  );
}
window.DeckStack = DeckStack;

// useSwipeHint — the first-run hint contract, one implementation. Nudges the
// element twice with a caption EVERY time the surface opens until the gesture is
// actually used (never "once ever", never capped at N showings), replays on the
// Tweaks panel's reset event, and respects reduced motion by keeping the
// caption and dropping the movement.
//
// It also returns `used`, which is what a STANDING affordance dims against: an
// affordance that has taught its gesture steps back, it does not disappear
// (the challenge card's chevron — bright under the hint, 0.7 unused, 0.35
// after). Kept in state as well as storage so it settles without a reload.
function useSwipeHint({ storageKey, enabled = true, nudge = -34, replayEvent = 'cq-replay-swipe-hint' }) {
  const [hint, setHint] = React.useState(false);
  const [hintDx, setHintDx] = React.useState(0);
  const [replay, setReplay] = React.useState(0);
  const [used, setUsed] = React.useState(() => {
    try { return !!window.localStorage.getItem(storageKey); } catch (e) { return false; }
  });
  React.useEffect(() => {
    // The Tweaks reset clears the storage keys before dispatching, so the
    // effect below re-reads an empty flag and the hint runs again.
    const onReplay = () => { setUsed(false); setReplay(n => n + 1); };
    window.addEventListener(replayEvent, onReplay);
    return () => window.removeEventListener(replayEvent, onReplay);
  }, [replayEvent]);
  React.useEffect(() => {
    if (!enabled) return;
    let used = null;
    try { used = window.localStorage.getItem(storageKey); } catch (e) {}
    if (used) return;
    const reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    setHint(true);
    const ts = [];
    if (!reduced) {
      const second = Math.round(nudge * 0.65);
      ts.push(setTimeout(() => setHintDx(nudge), 900), setTimeout(() => setHintDx(0), 1650),
              setTimeout(() => setHintDx(second), 2050), setTimeout(() => setHintDx(0), 2650));
    }
    ts.push(setTimeout(() => setHint(false), reduced ? 5600 : 4500));
    return () => ts.forEach(clearTimeout);
  }, [enabled, storageKey, nudge, replay]);
  const markUsed = React.useCallback(() => {
    setHint(false); setHintDx(0); setUsed(true);
    try { window.localStorage.setItem(storageKey, '1'); } catch (e) {}
  }, [storageKey]);
  return { hint, hintDx, used, markUsed };
}
window.useSwipeHint = useSwipeHint;

// SwipeHintCaption — the hint's words. Transient: it rides in with the nudge and
// leaves with it, so what remains is the standing affordance.
function SwipeHintCaption({ show, label, direction = -1 }) {
  return (
    <div aria-hidden="true" className="ff-mono" style={{
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7,
      fontSize: 'var(--t-micro)', letterSpacing: '0.14em', textTransform: 'uppercase',
      color: 'var(--ink-mute)', overflow: 'hidden',
      height: show ? 40 : 0, opacity: show ? 1 : 0,
      transition: 'height 280ms ease, opacity 280ms ease',
    }}>
      <svg width="22" height="9" viewBox="0 0 22 9" fill="none" style={{ color: 'var(--accent-text)', transform: direction < 0 ? 'scaleX(-1)' : 'none' }}>
        <path d="M1 4.5h15M12 1l4 3.5-4 3.5" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
      {label}
    </div>
  );
}
window.SwipeHintCaption = SwipeHintCaption;
