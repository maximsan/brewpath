import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/app/header_tier.dart';
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
  /// Creates the large title for the tab root at [location].
  const TabLargeTitle(this.location, {super.key});

  /// The tab root this titles — one of the four branch paths.
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = tabHeaderFor(
      location,
      today: ref.watch(currentDayProvider),
      learnerName: ref.watch(learnerNameProvider).asData?.value,
    );
    if (tab == null) return const SizedBox.shrink();

    return Padding(
      // The design opens a tab 24 below the status bar.
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + AppSpacing.lg,
      ),
      child: Semantics(
        header: true,
        child: Text(tab.title, style: AppText.display(mood: context.mood)),
      ),
    );
  }
}
