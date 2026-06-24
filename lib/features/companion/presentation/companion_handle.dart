import 'package:coffee_quest/features/companion/domain/companion_reaction.dart';
import 'package:flutter/foundation.dart';

/// A per-instance trigger for companion reactions. A host screen creates a
/// handle, passes it to a `Companion`, and calls [react] at the right moment so
/// the celebration animates only that companion (no app-wide cross-firing).
///
/// The host owns the handle's lifecycle and must [dispose] it.
class CompanionHandle extends ChangeNotifier {
  CompanionReaction? _reaction;
  int _replay = 0;

  /// The reaction currently requested, or null when the companion should rest
  /// at its mood.
  CompanionReaction? get reaction => _reaction;

  /// A monotonically increasing token that changes on every [react] call, so a
  /// repeat of the same reaction still restarts the one-shot animation.
  int get replay => _replay;

  /// Requests [reaction] as a one-shot. A new request interrupts any in-flight
  /// reaction (no queueing).
  void react(CompanionReaction reaction) {
    _reaction = reaction;
    _replay++;
    notifyListeners();
  }

  /// Clears the active reaction, returning the companion to its mood. Called by
  /// the companion when a one-shot animation completes.
  void clear() {
    if (_reaction == null) return;
    _reaction = null;
    notifyListeners();
  }
}
