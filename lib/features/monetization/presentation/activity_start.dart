/// Starting an activity, with the free day's cap asked first.
library;

import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/monetization/domain/daily_allowance.dart';
import 'package:brew_path/features/monetization/domain/daily_allowance_providers.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opening a surface that spends one of a free day's two activities (§8).
///
/// **The cap is asked at the tap, not in the router** — ADR-0020, which also
/// records what that costs.
///
/// On [BuildContext] rather than `WidgetRef`, the reason `showTermPeekSheet`
/// is: a dozen of the rows that start an activity are plain widgets deep in a
/// tree, and this is a one-shot read on a tap, not a subscription.
extension StartActivity on BuildContext {
  /// Goes to [destination], selling instead when the day has no room left.
  ///
  /// A destination that starts no activity is waved through, which is what
  /// lets the screens that navigate to a destination they were *handed* — Keep
  /// Sharp's card, a lesson ending — ask without knowing what they hold.
  Future<void> goToActivity(RouteDestination destination) async {
    if (!await _allowed(destination)) return;
    goToAfterAllowance(destination);
  }

  /// Pushes [destination] under the same rule, for a drill whose close has to
  /// return the learner to whichever screen opened it.
  Future<void> pushActivity(RouteDestination destination) async {
    if (!await _allowed(destination)) return;
    await pushAfterAllowance(destination);
  }

  /// Whether another activity may start now — and, when it may not, raises the
  /// offer in place of it.
  ///
  /// **Public because a drill restarts without navigating.** *Play again* and
  /// *Shuffle and go again* deal a fresh round on the screen the learner is
  /// already standing on, and that round records a completion exactly as the
  /// first one did. A guard that only watched navigation would have let one
  /// drill run the day out from inside itself.
  ///
  /// The allowance is **awaited, never read as a placeholder**. An unresolved
  /// gate elsewhere resolves to the locked answer because a wrong bounce
  /// corrects itself; a sheet raised on a guess does not, because nothing that
  /// re-runs can close a modal (#215).
  Future<bool> mayStartAnotherActivity() async {
    final hasRoom = await activityAllowanceNow(
      ProviderScope.containerOf(this, listen: false),
    );
    if (!mounted) return false;
    if (hasRoom) return true;

    await showPlusGate(
      this,
      const DailyAllowanceSpent(cap: freeDailyActivities),
    );
    return false;
  }

  Future<bool> _allowed(RouteDestination destination) async {
    if (!destination.startsActivity) return true;
    final hasRoom = await mayStartAnotherActivity();
    return hasRoom && mounted;
  }
}
