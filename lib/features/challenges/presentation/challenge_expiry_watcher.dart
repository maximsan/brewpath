import 'dart:async';

import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Parks a Coffee Challenge whose window has run out, on open and on resume.
///
/// **No timer.** A challenge's window is elapsed wall clock, so the only
/// moments that matter are the ones where the app can act: a cold start and a
/// return to the foreground. A ticking timer would burn cycles to notice
/// something a single read answers.
///
/// It wraps the app rather than living on the Learn tab because all four shell
/// tabs stay mounted: a learner who resumes on Profile would otherwise never
/// run the check. And it is a widget rather than a provider because a read
/// that writes is a side effect on a pure read path — and Riverpod would not
/// re-run one on resume anyway.
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
      now: DateTime.now(),
    );
    // Nothing lapsed: no write happened, so nothing downstream is stale.
    if (!parked || !mounted) return;
    ref
      ..invalidate(activeChallengeProvider)
      ..invalidate(savedChallengesProvider);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
