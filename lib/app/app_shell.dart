import 'package:brew_path/app/app_header.dart';
import 'package:brew_path/app/header_tier.dart';
import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/presentation/tour_runner.dart';
import 'package:brew_path/features/tour/presentation/tour_stop.dart';
import 'package:brew_path/features/tour/presentation/tour_stops.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom-nav scaffold wrapping the four `StatefulShellRoute` branches. Each
/// branch keeps its own navigator stack, so tab state and scroll position
/// survive switching tabs.
class AppShell extends StatefulWidget {
  /// Creates an [AppShell] around [navigationShell].
  const AppShell(this.navigationShell, {super.key});

  /// The shell that manages the four bottom-nav branches.
  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  /// Whether each branch's header is collapsed, keyed by branch index.
  ///
  /// Per branch for the same reason each branch keeps its own navigator stack:
  /// scrolling Learn, switching to Path and switching back should find Learn
  /// exactly as it was left. One shared flag would make every tab wear the
  /// last one's scroll position.
  final Map<int, bool> _collapsedByBranch = {};

  void _onDestinationSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      // Re-tapping the active tab pops it back to that branch's root.
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  /// Records whether the visible tab has been scrolled past the threshold.
  ///
  /// Returns false so the notification keeps bubbling — this observes, it does
  /// not consume. What counts as scrolled is [shouldCollapseHeader]'s to
  /// decide, so the rule is testable without a widget.
  bool _onScroll(ScrollNotification notification) {
    final metrics = notification.metrics;
    final index = widget.navigationShell.currentIndex;
    final collapsed = shouldCollapseHeader(
      pixels: metrics.pixels,
      maxScrollExtent: metrics.maxScrollExtent,
      axis: metrics.axis,
    );
    if (_collapsedByBranch[index] != collapsed) {
      setState(() => _collapsedByBranch[index] = collapsed);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // The header is the shell's, not a tab's: one instance above the four
    // branch navigators, which is why it survives a tab switch and does not
    // survive a push inside a branch — the push replaces the content beneath
    // it, and the tier rule keeps it from drawing over a page that brought its
    // own bar.
    //
    // `uri`, not `matchedLocation`: the latter reports the *shell's* own
    // match, so it still says `/learn` while a term detail is pushed on top.
    final location = GoRouterState.of(context).uri.path;
    final showsHeader = headerTierFor(location).showsSharedHeader;

    // The Tour's engine is owned here, not on Learn: the last stop is the tab
    // bar below, which lives outside every branch.
    return TourHost(
      child: Scaffold(
        body: Column(
          children: [
            if (showsHeader)
              AppHeader(
                location: location,
                isCollapsed:
                    _collapsedByBranch[widget.navigationShell.currentIndex] ??
                    false,
              ),
            Expanded(
              // Only a tab root's scrolling moves this header. A pushed page
              // scrolls under its own bar, and letting it collapse a header
              // it cannot see would leave the tab wrong when the learner
              // pops back.
              child: showsHeader
                  ? NotificationListener<ScrollNotification>(
                      onNotification: _onScroll,
                      child: widget.navigationShell,
                    )
                  : widget.navigationShell,
            ),
          ],
        ),
        bottomNavigationBar: _tabBar(context.mood),
      ),
    );
  }

  /// Colours and type come from the theme (`tabBarTheme`); the hairline the
  /// design separates the bar from the page with is what a theme cannot
  /// express.
  ///
  /// **Painted in the foreground on purpose.** `NavigationBar` fills its whole
  /// box with an opaque `Material`, and `DecoratedBox` paints a background
  /// decoration *behind* its child without insetting it — so the default
  /// position would draw the rule and then bury it.
  ///
  /// **The marks are the design's own**, and each tab carries two drawings:
  /// selected fills the shape with the accent and knocks its interior lines
  /// out, which is not the same drawing recoloured. The theme's `iconTheme`
  /// gives them their ink, so the selected/unselected colours are declared
  /// once in `tabBarTheme` rather than at each destination.
  ///
  /// The labels are uppercased here rather than in [AppLabels], the way
  /// `SmallcapsLabel` does it: `TextStyle` has no text-transform, and the case
  /// is this bar's type rule, not part of what the tabs are called. Changing
  /// it back is then a change to the bar, not a rewrite of four constants and
  /// everything else that reads them.
  Widget _tabBar(MoodColors mood) => TourStop(
    stopKey: TourStops.tabs,
    title: TourCopy.tabsTitle,
    description: TourCopy.tabsBody,
    child: DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: mood.rule)),
      ),
      child: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: const IconMark(AppIcon.cup),
            selectedIcon: const IconMark(AppIcon.cup, active: true),
            label: AppLabels.tabToday.toUpperCase(),
          ),
          NavigationDestination(
            icon: const IconMark(AppIcon.route),
            selectedIcon: const IconMark(AppIcon.route, active: true),
            label: AppLabels.tabPath.toUpperCase(),
          ),
          NavigationDestination(
            icon: const IconMark(AppIcon.cards),
            selectedIcon: const IconMark(AppIcon.cards, active: true),
            label: AppLabels.tabCards.toUpperCase(),
          ),
          NavigationDestination(
            icon: const IconMark(AppIcon.leaf),
            selectedIcon: const IconMark(AppIcon.leaf, active: true),
            label: AppLabels.tabProfile.toUpperCase(),
          ),
        ],
      ),
    ),
  );
}
