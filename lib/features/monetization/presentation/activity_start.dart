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
/// **The cap is asked here rather than in the router.** Every other gate is a
/// gate→destination decision and lives in `redirectFor`; this one cannot,
/// because a completion is recorded while the learner is still standing on the
/// route that recorded it. A redirect re-run at that moment — and one is due,
/// since the same write invalidates what the redirect reads — would throw them
/// off the results of the activity they had just finished. Asked at the tap,
/// the question is only ever about a surface nobody is on yet.
///
/// Nothing outside the app can reach an activity route: the universal-link
/// claim is `/card/*` and nothing else (`AppLinks`), so these taps are the
/// whole way in. `BuildContext.goTo` asserts against the ones that belong
/// here, so a new call site that reaches for the plain navigator fails loudly
/// rather than quietly handing out a third activity.
///
/// On [BuildContext] rather than `WidgetRef` — the reason `showTermPeekSheet`
/// is: a dozen of the rows that start an activity are plain widgets deep in a
/// tree, and this is a one-shot read on a tap, not a subscription. Converting
/// them all to consumers would buy nothing back.
extension StartActivity on BuildContext {
  /// Goes to [destination], selling instead when the day has no room left.
  Future<void> goToActivity(RouteDestination destination) async {
    final hasRoom = await _hasRoomForActivity(destination);
    if (!mounted || !hasRoom) return;
    goToAfterAllowance(destination);
  }

  /// Pushes [destination] under the same rule, for a drill whose close has to
  /// return the learner to whichever screen opened it.
  Future<void> pushActivity(RouteDestination destination) async {
    final hasRoom = await _hasRoomForActivity(destination);
    if (!mounted || !hasRoom) return;
    await pushAfterAllowance(destination);
  }

  /// Whether [destination] may be opened now — and, when it may not, raises
  /// the offer in place of the surface.
  ///
  /// A destination that starts no activity is waved through, which is what
  /// lets the two screens that navigate to a destination they were *handed* —
  /// Keep Sharp's card and a lesson ending — ask without knowing what they
  /// hold.
  ///
  /// The allowance is **awaited, never read as a placeholder**. An unresolved
  /// gate elsewhere resolves to the locked answer because a wrong bounce
  /// corrects itself; a sheet raised on a guess does not, because nothing that
  /// re-runs can close a modal (#215).
  Future<bool> _hasRoomForActivity(RouteDestination destination) async {
    if (!destination.startsActivity) return true;

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
}
