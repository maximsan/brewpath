import 'dart:async';

import 'package:brew_path/app/app_router.dart';
import 'package:brew_path/core/widgets/overlay_barrier.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/tour/domain/micro_tip.dart';
import 'package:brew_path/features/tour/domain/micro_tip_candidate.dart';
import 'package:brew_path/features/tour/domain/micro_tip_pacing.dart';
import 'package:brew_path/features/tour/domain/micro_tip_place.dart';
import 'package:brew_path/features/tour/domain/micro_tip_providers.dart';
import 'package:brew_path/features/tour/domain/tour_providers.dart';
import 'package:brew_path/features/tour/presentation/micro_tip_card.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Owns the micro-tip layer for the whole app: which tip is up, and when the
/// next one may be.
///
/// **Above the router, not inside a screen.** A tip can land on the Learn tab,
/// on the Path tab, in the dictionary, on Today's term and in the Studio — and
/// the last two are pushed over the tab bar, so no single screen or shell can
/// host them all. One host above everything also makes "one tip at a time" true
/// by construction rather than by agreement between surfaces.
///
/// Because it draws over the navigator, it has to be told when to keep out of
/// the way: [anyOverlayBarrierOpen] covers every sheet and dialog, and
/// `tourRunningProvider` covers the Tour.
class MicroTipHost extends ConsumerStatefulWidget {
  /// Creates a [MicroTipHost] over [child].
  const MicroTipHost({required this.child, super.key});

  /// The app the tips are drawn over.
  final Widget child;

  @override
  ConsumerState<MicroTipHost> createState() => _MicroTipHostState();
}

class _MicroTipHostState extends ConsumerState<MicroTipHost> {
  /// `NavigationBar`'s own default height, which the app's `tabBarTheme` does
  /// not override. Read from the theme first, so it stays right if it ever
  /// does.
  static const double _navigationBarHeight = 80;

  /// The tip on screen, or null.
  MicroTip? _showing;

  /// The address the layer last saw. Null until the first frame, which is what
  /// makes a launch count as arriving somewhere.
  String? _screen;

  /// Running while the layer owes the learner silence, and null otherwise.
  ///
  /// The wait is a timer rather than a deadline compared against the clock, so
  /// the whole rule is expressed in one place and the layer never has to ask
  /// what time it is — which also means a test can advance it.
  Timer? _quiet;

  @override
  void initState() {
    super.initState();
    anyOverlayBarrierOpen.addListener(_onOverlayChanged);
    // The Tour finishing counts as "something was just shown", so the first tip
    // after it does not read as a fifth stop.
    ref.listenManual(tourRunningProvider, (wasRunning, isRunning) {
      if ((wasRunning ?? false) && !isRunning) {
        _stayQuietFor(MicroTipPacing.afterDismissal);
      }
    });
  }

  @override
  void dispose() {
    anyOverlayBarrierOpen.removeListener(_onOverlayChanged);
    _quiet?.cancel();
    super.dispose();
  }

  /// A route installs itself while the navigator flushes its history, which can
  /// happen inside a build — so the rebuild waits for the frame in that case,
  /// the same guard the shell's scroll listener carries.
  void _onOverlayChanged() {
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  void _stayQuietFor(Duration wait) {
    _quiet?.cancel();
    _quiet = Timer(wait, () {
      _quiet = null;
      if (mounted) setState(() {});
    });
  }

  void _dismiss() {
    _stayQuietFor(MicroTipPacing.afterDismissal);
    setState(() => _showing = null);
  }

  /// Applies the layer's rules to [moment], after the frame it was read from.
  ///
  /// Deferred rather than done in `build` because both outcomes write state:
  /// leaving a screen retires the card, and showing one records the tip as
  /// seen. Neither belongs in a build that may run more than once a frame.
  void _settle(_TipMoment moment) {
    if (!mounted) return;
    if (_screen != moment.screen) {
      _leave(moment.screen);
    }
    if (_showing != null || moment.candidate == null || _quiet != null) return;

    final tip = moment.candidate!;
    setState(() => _showing = tip);
    // Seen on show, not on dismissal: a tip the learner has read and walked
    // away from has done its job.
    unawaited(markMicroTipSeen(ref, tip));
  }

  /// Retires whatever was up and buys the new screen some silence, longer when
  /// something was actually retired so two tips never read as a chain.
  void _leave(String screen) {
    final wasShowing = _showing != null;
    _screen = screen;
    _stayQuietFor(MicroTipPacing.afterLeaving(tipWasShowing: wasShowing));
    if (wasShowing) setState(() => _showing = null);
  }

  /// How far above the bottom the card sits.
  ///
  /// The design places it 112 from the foot of the screen where the tab bar
  /// shows and 40 where it does not, over a frame that reserves 28 for the home
  /// indicator. Here the phone's own inset stands in for that 28, the bar's
  /// real height stands in for the design's 88, and what is left is the
  /// clearance the design draws: a section gap over the bar, a hairline gap
  /// over the screen edge.
  double _bottomInset(BuildContext context, {required bool raised}) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    if (!raised) return safeBottom + AppSpacing.sm;
    final barHeight =
        Theme.of(context).navigationBarTheme.height ?? _navigationBarHeight;
    return safeBottom + barHeight + AppSpacing.lg;
  }

  @override
  Widget build(BuildContext context) {
    // Every watch happens here, in the state's own build. The location does
    // not: it comes from the router's delegate, which is a listenable rather
    // than a provider.
    final router = ref.watch(appRouterProvider);
    final inputs = _TipInputs(
      // Unresolved reads as "everything seen" — a tip is never spent against a
      // list the layer has not read yet.
      seen: ref.watch(microTipsSeenProvider).asData?.value,
      suppressed: ref.watch(tourRunningProvider) || anyOverlayBarrierOpen.value,
      signals: MicroTipSignals(
        savedJustHappened: ref.watch(saveMadeThisSessionProvider),
        studioUnlocked:
            ref.watch(courseEntitlementProvider).asData?.value ?? false,
        challengeActive:
            ref.watch(activeChallengeProvider).asData?.value != null,
        lessonJustCompleted: ref.watch(lessonFinishedThisSessionProvider),
        freezeHeld:
            ref.watch(streakStatusProvider).asData?.value.freezeHeld ?? false,
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        ListenableBuilder(
          listenable: router.routerDelegate,
          builder: (context, _) => _layer(context, inputs, router),
        ),
      ],
    );
  }

  Widget _layer(BuildContext context, _TipInputs inputs, GoRouter router) {
    // `router.state`, not `currentConfiguration.uri`: the latter reports the
    // last *matched* address, which still says `/learn` while the dictionary is
    // pushed on top of it. The state is the topmost match, which is the screen
    // the learner is actually looking at.
    final matches = router.routerDelegate.currentConfiguration;
    final location = matches.isEmpty ? '' : router.state.uri.path;
    final place = tipPlaceFor(location);
    final welcome = !inputs.suppressed && place.takesTips;
    final moment = _TipMoment(
      screen: location,
      candidate: microTipCandidate(
        place: place,
        signals: inputs.signals,
        seen: inputs.seen ?? const {},
        suppressed: inputs.suppressed || inputs.seen == null,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _settle(moment));

    final tip = _showing;
    if (tip == null || !welcome) return const SizedBox.shrink();
    return Positioned(
      left: AppSpacing.md,
      right: AppSpacing.md,
      bottom: _bottomInset(context, raised: place.showsTabBar),
      child: _FadeUp(
        key: ValueKey(tip),
        child: MicroTipCard(tip: tip, onDismiss: _dismiss),
      ),
    );
  }
}

/// What the layer reads from providers, gathered once so the location — which
/// comes from a listenable rather than a provider — can be added on top.
@immutable
class _TipInputs {
  const _TipInputs({
    required this.seen,
    required this.suppressed,
    required this.signals,
  });

  final Set<String>? seen;
  final bool suppressed;
  final MicroTipSignals signals;
}

/// One frame's answer: where the learner is, and what could be said there.
@immutable
class _TipMoment {
  const _TipMoment({required this.screen, required this.candidate});

  final String screen;
  final MicroTip? candidate;
}

/// The design's `fade-up`: 260ms ease-out, from four pixels down.
///
/// Reduced motion gets no animator at all rather than a zero-duration one —
/// the honest reading of "no animation", and the app's rule elsewhere.
class _FadeUp extends StatelessWidget {
  const _FadeUp({required this.child, super.key});

  static const Duration _duration = Duration(milliseconds: 260);
  static const double _rise = 4;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: _duration,
      curve: Curves.easeOut,
      builder: (context, progress, child) => Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, _rise * (1 - progress)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
