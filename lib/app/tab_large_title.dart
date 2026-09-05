import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/app/header_tier.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The large title a tab root carries at the top of its own scroll.
///
/// The design pairs it with a header that is invisible at rest: the screen is
/// titled by the page while the page is at the top, and by the bar once the
/// page has scrolled under it. The two halves are the same pair, so this reads
/// the tab heading the shared header reads rather than restating the words —
/// which is how the Cards tab can say `Collection` again without saying it
/// twice (#396 dropped it when the bar drew a title at rest).
///
/// **It carries the status-bar inset**, because the header no longer can: the
/// bar floats over the tab now instead of standing above it, so nothing else
/// in a tab root is above the content to make room. Every tab root opens with
/// this, which is what keeps the rule in one place.
class TabLargeTitle extends ConsumerWidget {
  /// Creates the large title for the tab root at [route], opening [topGap]
  /// below the status bar.
  const TabLargeTitle(this.route, {this.topGap = AppSpacing.lg, super.key});

  /// The tab root this titles. A route rather than a path string, so a tab can
  /// only be named by the catalogue that defines it.
  final AppRoute route;

  /// How far below the status bar the title sits. The design opens three of
  /// the four tabs at 24 and Path a good deal lower, so the tab states its
  /// own rather than this widget assuming they agree.
  final double topGap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = tabHeaderFor(
      route.path,
      today: ref.watch(currentDayProvider),
      learnerName: ref.watch(learnerNameProvider).asData?.value,
    );
    if (tab == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + topGap,
      ),
      child: Semantics(
        header: true,
        child: Text(tab.title, style: AppText.display(mood: context.mood)),
      ),
    );
  }
}
