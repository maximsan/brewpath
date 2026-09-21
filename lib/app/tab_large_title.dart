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

/// Where a tab root's large title sits against the entries floating over it.
///
/// One value rather than a gap and an inset passed separately: which of the
/// three a tab wants is a fact about its title, and no call site can now ask
/// for a combination the design does not draw.
enum TabTitlePlacement {
  /// The whole width to itself, at the design's 24. Cards.
  atTop(),

  /// Level with the entries at the design's 24, reserving their width on the
  /// right so a long title wraps into what is left rather than under them.
  besideEntries(reservesEntries: true),

  /// Below the entries, for a title whose width is not the app's to predict:
  /// Learn's date and Profile's typed name.
  belowEntries(gap: OffTokens.tabTitleClearOfEntries);

  const TabTitlePlacement({
    OffToken<double>? gap,
    this.reservesEntries = false,
  }) : _gap = gap;

  final OffToken<double>? _gap;

  /// Whether the title stops short of the entries and wraps balanced.
  final bool reservesEntries;

  /// How far below the status bar the title opens.
  double get topGap => _gap?.value ?? AppSpacing.lg;

  /// How much room the title leaves on its right.
  double get endInset =>
      reservesEntries ? OffTokens.tabTitleBesideEntries.value : 0;
}

/// The large title a tab root carries at the top of its own scroll.
///
/// It reads the heading the shared header reads, so the two halves of the
/// design's pair cannot disagree about what a screen is called (#396), and it
/// carries the status-bar inset, because the bar floats over the tab now and
/// nothing else in a tab root is above the content to make room (#441).
class TabLargeTitle extends ConsumerWidget {
  /// Creates the large title for the tab root at [route], laid out where
  /// [placement] puts it against the header's entries.
  const TabLargeTitle(
    this.route, {
    this.placement = TabTitlePlacement.atTop,
    super.key,
  });

  /// The tab root this titles. A route rather than a path string, so a tab can
  /// only be named by the catalogue that defines it.
  final AppRoute route;

  /// Where this tab's title sits against the floating entries.
  final TabTitlePlacement placement;

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
        top: MediaQuery.paddingOf(context).top + placement.topGap,
        end: placement.endInset,
      ),
      child: Semantics(
        header: true,
        child: placement.reservesEntries
            ? BalancedText(tab.title, style: style)
            : Text(tab.title, style: style),
      ),
    );
  }
}
