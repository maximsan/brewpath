import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_link.g.dart';

/// The deep-link target a learner arrived on, held across onboarding.
///
/// The redirect sends anyone who has not onboarded to Welcome, and without
/// this the target they tapped is discarded there — so someone who installs
/// the app *because* a card was shared with them never sees that card
/// (#171, and the failure #34 named as the likeliest in the feature).
///
/// **Deliberately a plain object, not notifier state.** The redirect both
/// reads and writes it while go_router is resolving a location; provider
/// state mutated there would tick `refreshListenable` and re-enter the
/// redirect it was called from. Nothing rebuilds when this changes, which is
/// the point — the router asks for it at the one moment it matters.
class PendingLink {
  String? _target;

  /// Remembers [location] as the place to resume once onboarding finishes.
  ///
  /// **The first hold wins.** The redirect cannot tell an arrival from the app
  /// navigating on its own, and the app does navigate: finishing onboarding
  /// writes the row, invalidates the gate and pushes to Learn without waiting
  /// for the recompute, so `/learn` reaches this method while the gate still
  /// reads incomplete. Last-wins would let that hop overwrite the card the
  /// learner actually tapped — the exact loss this class exists to prevent.
  void hold(String location) {
    if (_target != null) return;
    _target = location;
  }

  /// Returns the held target and forgets it, or null when none is held.
  ///
  /// One-shot by design: a target that survived being taken would pull the
  /// learner back to it every time they navigated away.
  String? take() {
    final target = _target;
    _target = null;
    return target;
  }
}

/// Provides the app-lifetime [PendingLink].
///
/// Function-style despite holding mutable state, because the mutation is the
/// object's own and must not rebuild the router — see [PendingLink].
@Riverpod(keepAlive: true)
PendingLink pendingLink(Ref ref) => PendingLink();
