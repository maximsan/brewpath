import 'dart:async';
import 'package:brew_path/core/constants/app_links.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/header_chrome.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/sub_screen_scaffold.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/companion_celebration.dart';
import 'package:brew_path/features/progress/domain/freeze_status_line.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/domain/streak_milestone_providers.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:brew_path/features/progress/domain/streak_week.dart';
import 'package:brew_path/features/progress/presentation/share_card_renderer.dart';
import 'package:brew_path/features/progress/presentation/streak_ring.dart';
import 'package:brew_path/features/progress/presentation/streak_share_card.dart';
import 'package:brew_path/features/progress/presentation/week_strip.dart';
import 'package:brew_path/services/share/share_provider.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// How far below the status bar the design opens this page.
///
/// 84 rather than 108: the ring starts where a large title would have,
/// because there is no large title.
const double _designScrollPad = 84;

/// The streak screen — a milestone beat when one is due, then the day count
/// at hero size inside the ring that fills over its week, the week strip, and
/// the one-line freeze status.
///
/// Everything shown is read from the derived streak state; the screen invents
/// no rules (#232, #236). The share button arrives with #237.
class StreakScreen extends ConsumerStatefulWidget {
  /// Creates a [StreakScreen].
  const StreakScreen({super.key});

  @override
  ConsumerState<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends ConsumerState<StreakScreen> {
  /// Whether the milestone beat is on screen. Local state, not derived:
  /// presenting writes the acknowledgement, which flips the due gate off, and
  /// the beat must survive its own acknowledgement.
  bool _showBeat = false;

  /// One presentation per mount, however often the due provider rebuilds.
  bool _presented = false;

  void _presentMilestone({required bool reducedMotion}) {
    if (_presented || !mounted) return;
    _presented = true;
    // Acknowledgement is about presentation, not animation: reduced motion
    // skips the beat but still marks the milestone seen, or the same moment
    // would be re-offered forever (#26).
    unawaited(
      ackStreakMilestone(
        ref.read(snapshotRepositoryProvider),
        DateTime.now(),
      ).then((_) {
        if (mounted) ref.invalidate(streakMilestoneDueProvider);
      }),
    );
    if (!reducedMotion) setState(() => _showBeat = true);
  }

  /// Renders the fixed-size card and hands it to the share presenter — the
  /// screen never touches the plugin (#237).
  Future<void> _share() async {
    final status = await ref.read(streakStatusProvider.future);
    final weekDays = await ref.read(weekStripDaysProvider.future);
    if (!mounted) return;
    final bytes = await renderCardPng(
      card: StreakShareCard(streak: status.streak, days: weekDays),
      logicalSize: StreakShareCard.logicalSize,
      pixelRatio: StreakShareCard.exportPixelRatio,
      mood: context.mood,
    );
    await ref
        .read(sharePresenterProvider)
        .sharePng(
          bytes: bytes,
          fileName: 'brewpath-streak.png',
          // The site, not a streak of its own: there is nothing for a
          // stranger to render at `/streak/<n>` (#34).
          link: AppLinks.site,
        );
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(streakStatusProvider);
    final due = ref.watch(streakMilestoneDueProvider);
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if ((due.asData?.value ?? false) && !_presented) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _presentMilestone(reducedMotion: reducedMotion),
      );
    }
    // The beat is the whole screen while it plays, chrome included — the
    // design renders it *instead of* the streak page rather than inside it, so
    // there is no bar over a celebration and nothing to go back to mid-beat.
    final beat = _showBeat ? status.asData?.value : null;
    if (beat != null) {
      return Scaffold(
        body: _MilestoneBeat(
          streak: beat.streak,
          onContinue: () => setState(() => _showBeat = false),
        ),
      );
    }

    // Close, not back: the design gives this screen an X. No `PageLargeTitle`
    // either — it opens on the ring, which is the subject, and the design puts
    // no display heading over it.
    return SubScreenScaffold(
      title: 'Your streak',
      mark: AppIcon.close,
      scrollPad: HeaderChrome.belowDesignStatusBar(_designScrollPad),
      onBack: () => context.pop(),
      body: (context, scrollPadding) => status.when(
        loading: () => Semantics(
          label: 'Loading your streak',
          child: const LoadingIndicator(),
        ),
        error: (error, _) => Center(
          child: Semantics(
            label: 'Your streak could not be loaded',
            child: Text('$error'),
          ),
        ),
        data: (value) => _StreakBody(
          scrollPadding: scrollPadding,
          status: value,
          weekDays: ref.watch(weekStripDaysProvider).asData?.value ?? const [],
          onShare: _share,
        ),
      ),
    );
  }
}

/// The celebration half of a milestone day: Roasty, the count, one button.
class _MilestoneBeat extends StatelessWidget {
  const _MilestoneBeat({required this.streak, required this.onContinue});

  final int streak;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CompanionCelebration(
                      reaction: CompanionReaction.streakMilestone,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('STREAK', style: AppText.label(mood: mood)),
                    const SizedBox(height: AppSpacing.xs),
                    Semantics(
                      header: true,
                      child: Text(
                        '$streak days in a row.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: mood.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: PrimaryButton(label: 'Continue', onPressed: onContinue),
          ),
        ],
      ),
    );
  }
}

class _StreakBody extends StatelessWidget {
  const _StreakBody({
    required this.scrollPadding,
    required this.status,
    required this.weekDays,
    required this.onShare,
  });

  /// The room the bar floating over this scroll leaves at the top.
  final EdgeInsets scrollPadding;

  final StreakStatus status;
  final List<StreakDay> weekDays;
  final Future<void> Function() onShare;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final statusLine = freezeStatusLine(status: status, today: DateTime.now());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg) + scrollPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // One spoken phrase for the whole hero: the ring is decorative, and
          // the week it fills over is already spoken by the strip below.
          Semantics(
            label: '${status.streak} day streak',
            excludeSemantics: true,
            child: StreakRing(
              fraction: weekRingFraction(status.streak),
              trackColor: mood.rule,
              fillColor: mood.accent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${status.streak}', style: AppText.hero(mood: mood)),
                  const SizedBox(height: AppSpacing.xxs),
                  Text('DAY STREAK', style: AppText.label(mood: mood)),
                ],
              ),
            ),
          ),
          // Nothing under the ring: the fill and the strip already say where
          // the week stands, and a sentence restating them is noise. The strip
          // takes the gap the caption used to sit in — the design's
          // `padding-top: 30`, at the nearest stop on the scale.
          if (weekDays.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            WeekStrip(days: weekDays),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text(
            statusLine,
            textAlign: TextAlign.center,
            style: AppText.support(mood: mood),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: onShare,
            child: const Text('Share your streak'),
          ),
        ],
      ),
    );
  }
}
