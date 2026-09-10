import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/learn/presentation/learn_list_view.dart';
import 'package:brew_path/features/tour/domain/tour_providers.dart';
import 'package:brew_path/features/tour/presentation/tour_runner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Learn tab: today's lesson and the practice sections.
///
/// The course itself is Path's (#394) — this tab is today's work, which is
/// what the design calls it. Also where the Tour runs unasked, and stateful for
/// that alone: the first run starts once per launch at most, and only a `State`
/// remembers that across the rebuilds the tab's providers cause.
class LearnScreen extends ConsumerStatefulWidget {
  /// Creates a [LearnScreen].
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  @override
  void initState() {
    super.initState();
    // Listened for the whole life of the tab rather than watched in `build`,
    // because a replay is an *event*: Profile raises it, this tab acts on it
    // once, and no rebuild should be able to replay the Tour a second time.
    // Learn is the shell's initial branch and so is always mounted by the time
    // Profile can be reached, which is what makes a listener sufficient.
    ref.listenManual(tourReplayRequestProvider, (_, requested) {
      if (!requested || !mounted) return;
      ref.read(tourReplayRequestProvider.notifier).consume();
      startTour(ref, TourRun.replay);
    });
  }

  /// Whether this screen has already started the first run.
  ///
  /// `tourSeen` is not enough on its own: it is written when the run finishes,
  /// so while the Tour is up — and after a run ended by leaving the tab, which
  /// writes nothing — the provider still reads false, and a rebuild would start
  /// it again. This is the latch that closes as the run starts.
  bool _started = false;

  /// Starts the first run once the tab shows real data and the flag is unset.
  ///
  /// No offer first: the design draws the Tour as soon as Today does (#537).
  /// Gated on the day's lesson having resolved, because the first stop is the
  /// Today card, and framing a card that has not decided what it says explains
  /// nothing. A null [seen] is the flag still loading, treated as seen.
  void _runTourIfDue(bool? seen) {
    if (_started || (seen ?? true)) return;

    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) startTour(ref, TourRun.first);
    });
  }

  @override
  Widget build(BuildContext context) {
    // The day's lesson — the Tour's first stop, so its arrival is the signal
    // that there is something to point at.
    //
    // The tab is not gated on it: every section degrades on its own while its
    // provider is pending, so the day's card can settle last without holding a
    // spinner over a tab that is otherwise ready.
    final today = ref.watch(todayLessonProvider);
    // Watched, not read: the flag resolves on its own schedule, and the run
    // has to survive it landing after the lesson.
    final tourSeen = ref.watch(tourSeenProvider);

    if (today.hasValue) _runTourIfDue(tourSeen.value);

    return const Scaffold(body: LearnListView());
  }
}
