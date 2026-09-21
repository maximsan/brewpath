import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/app/header_tier.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/balanced_text.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The large title a tab root carries at the top of its own scroll.
///
/// It reads the heading the shared header reads, so the two halves of the
/// design's pair cannot disagree about what a screen is called (#396), and it
/// carries the status-bar inset, because the bar floats over the tab now and
/// nothing else in a tab root is above the content to make room (#441).
class TabLargeTitle extends ConsumerWidget {
  /// Creates the large title for the tab root at [route], opening [topGap]
  /// below the status bar and, where [besideEntries], inset clear of them.
  const TabLargeTitle(
    this.route, {
    this.topGap = AppSpacing.lg,
    this.besideEntries = false,
    super.key,
  });

  /// The tab root this titles. A route rather than a path string, so a tab can
  /// only be named by the catalogue that defines it.
  final AppRoute route;

  /// How far below the status bar the title sits. Path and Cards open at the
  /// design's 24; Learn and Profile, whose titles are a date and a name the
  /// learner typed, open below the entries instead
  /// (`OffTokens.tabTitleClearOfEntries`).
  final double topGap;

  /// Whether the title sits *beside* the floating entries rather than below
  /// them: its right edge stops short of the cluster and it wraps balanced
  /// into what is left. Path's treatment, and the design draws it there only.
  final bool besideEntries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = tabHeaderFor(
      route.path,
      today: ref.watch(currentDayProvider),
      learnerName: ref.watch(learnerNameProvider).asData?.value,
    );
    if (tab == null) return const SizedBox.shrink();

    final style = AppText.display(mood: context.mood);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: MediaQuery.paddingOf(context).top + topGap,
        end: besideEntries ? OffTokens.tabTitleBesideEntries.value : 0,
      ),
      child: Semantics(
        header: true,
        child: besideEntries
            ? BalancedText(tab.title, style: style)
            : Text(tab.title, style: style),
      ),
    );
  }
}
