// Self-descriptive mascot-state enum.
// ignore_for_file: public_member_api_docs

/// All visual states the Roasty mascot can render. Mirrors the
/// `data-state="…"` enum used by the design-bundle prototype
/// (prototype/roasty.jsx).
enum RoastyState {
  idle,
  correct,
  wrong,
  lesson,
  module,
  xp,
  card,
  sleep,
  awake,
}
