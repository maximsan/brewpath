import 'dart:async';

import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Parks a Coffee Challenge whose window has run out.
///
/// Three moments: a cold start, a resume, and the day turning over under an
/// app left open — the last by watching the day the rollover refreshes, so one
/// midnight moves the challenge window and the calendar surfaces together
/// (ADR-0030). A widget, not a provider: a read that writes is a side effect.
class ChallengeExpiryWatcher extends ConsumerStatefulWidget {
  /// Creates a [ChallengeExpiryWatcher].
  const ChallengeExpiryWatcher({required this.child, super.key});

  /// The app this wraps.
  final Widget child;

  @override
  ConsumerState<ChallengeExpiryWatcher> createState() =>
      _ChallengeExpiryWatcherState();
}

class _ChallengeExpiryWatcherState
    extends ConsumerState<ChallengeExpiryWatcher> {
  AppLifecycleListener? _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _check);
    // A cold start is an open too: the window may well have run out while the
    // app was not running at all, which is the common case.
    unawaited(_check());
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final parked = await parkExpiredChallenge(
      ref.read(snapshotRepositoryProvider),
      now: ref.read(appClockProvider)(),
    );
    // Nothing lapsed: no write happened, so nothing downstream is stale.
    if (!parked || !mounted) return;
    ref
      ..invalidate(activeChallengeProvider)
      ..invalidate(savedChallengesProvider);
  }

  @override
  Widget build(BuildContext context) {
    // The rollover refreshes this day; a window that lapsed with it has to be
    // parked without waiting for a resume that may never come.
    ref.listen(currentDayProvider, (_, _) => unawaited(_check()));
    return widget.child;
  }
}
