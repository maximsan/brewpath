import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/learn/presentation/learn_list_view.dart';
import 'package:brew_path/features/tour/domain/tour_providers.dart';
import 'package:brew_path/features/tour/presentation/tour_intro_overlay.dart';
import 'package:brew_path/features/tour/presentation/tour_runner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Learn tab: today's lesson, the module list, and practice sections.
///
/// Also where the Tour auto-runs. Stateful for that alone: the offer is made
/// once per app launch at most, and only a `State` can remember that it has
/// already been made across the rebuilds the tab's providers cause.
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
      // No intro overlay and no write: someone asking to see the Tour again
      // has already answered the question the overlay asks, and the flag
      // records that answer, not how many times the Tour has run.
      startTourStops(ref);
    });
  }

  /// Whether this screen has already put the intro overlay on screen.
  ///
  /// `tourSeen` is not enough on its own: it is written *asynchronously* when
  /// the overlay is answered, so between the tap and the write landing the
  /// provider still reads false and a rebuild would offer the Tour a second
  /// time. This is the latch that closes immediately.
  bool _offered = false;

  /// Offers the Tour once the tab is showing real data and the flag is unset.
  ///
  /// Gated on data rather than on the screen mounting, because the Tour points
  /// at a Today card and a module list — spotlighting a loading spinner would
  /// explain nothing. [seen] is null while the flag is still loading, which is
  /// treated as "already seen": the offer is deferred to the rebuild the
  /// resolved flag causes, never made against an unknown.
  void _offerTourIfDue(bool? seen) {
    if (_offered || (seen ?? true)) return;

    _offered = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final accepted = await TourIntroOverlay.show(context);
      if (accepted == null || !mounted) return;

      // Either answer writes the flag: the Tour is offered once, and declining
      // is an answer. Mid-tour abandonment never re-arms it, because the write
      // has already happened by then.
      await markTourSeen(ref);
      if (!mounted || !accepted) return;
      startTourStops(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final modules = ref.watch(modulesWithProgressProvider);
    // Watched, not read: the flag resolves on its own schedule, and the offer
    // has to survive it landing after the module data.
    final tourSeen = ref.watch(tourSeenProvider);

    return Scaffold(
      body: modules.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(message: '$e'),
        data: (list) {
          _offerTourIfDue(tourSeen.value);
          return LearnListView(modules: list);
        },
      ),
    );
  }
}
