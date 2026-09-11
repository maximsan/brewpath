import 'package:brew_path/app/app_header.dart';
import 'package:brew_path/app/header_tier.dart';
import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/tour/domain/tour_step.dart';
import 'package:brew_path/features/tour/presentation/tour_anchor.dart';
import 'package:brew_path/features/tour/presentation/tour_runner.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
    if (_collapsedByBranch[index] == collapsed) {
      return false;
    }
    // A scroll can end while the list is still being laid out (the viewport
    // learns its content shrank and stops the fling), and a setState from
    // inside layout is "Build scheduled during frame". Apply it after the
    // frame in that case; every other notification arrives between frames.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _collapsedByBranch[index] = collapsed);
        }
      });
    } else {
      setState(() => _collapsedByBranch[index] = collapsed);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // The header is the shell's, not a tab's: one instance above the four
    // branch navigators, so it survives a tab switch but not a push inside a
    // branch, where the tier rule keeps it off a page with its own bar.
    //
    // `uri`, not `matchedLocation`: the latter reports the *shell's* own
    // match, so it still says `/learn` while a term detail is pushed on top.
    final location = GoRouterState.of(context).uri.path;
    final showsHeader = headerTierFor(location).showsSharedHeader;

    // The Tour is drawn *around* the scaffold rather than inside its body: its
    // last stop is the tab bar, which the body does not contain.
    return Stack(
      fit: StackFit.expand,
      children: [
        Scaffold(
          // A stack, not a column: the design's header floats **over** the
          // tab and is invisible until the tab scrolls under it, so it takes
          // no room of its own. The tab root leaves the room instead, in the
          // one place that always opens one — `TabLargeTitle`.
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Only a tab root's scrolling moves this header. A pushed page
              // scrolls under its own bar, and letting it collapse a header
              // it cannot see would leave the tab wrong when the learner pops
              // back.
              if (showsHeader)
                NotificationListener<ScrollNotification>(
                  onNotification: _onScroll,
                  child: widget.navigationShell,
                )
              else
                widget.navigationShell,
              if (showsHeader)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppHeader(
                    location: location,
                    isCollapsed:
                        _collapsedByBranch[widget
                            .navigationShell
                            .currentIndex] ??
                        false,
                  ),
                ),
            ],
          ),
          bottomNavigationBar: _tabBar(context),
        ),
        // On the Learn tab's own root and nowhere else, which is both the
        // design's rule and what keeps a card from surviving onto another tab.
        TourLayerHost(isOnLearn: location == AppRoutes.learn.path),
      ],
    );
  }

  /// The shared tab bar, plus the hairline `tabBarTheme` cannot express.
  ///
  /// The rule is painted in the *foreground* because `NavigationBar` fills its
  /// box with an opaque `Material` that would bury a background decoration.
  /// The labels are uppercased here rather than in [AppLabels] because the
  /// case is this bar's type rule, not part of what the tabs are called.
  Widget _tabBar(BuildContext context) {
    final mood = context.mood;
    return TourAnchor(
      step: TourStep.tabs,
      // The Tour frames the row of tabs. The design pads the bar `8px 0 28px`
      // and rings what is left; the app reads the device's own indicator strip
      // where the design writes 28, because a phone without one has none.
      inset: EdgeInsets.only(
        top: OffTokens.tabBarTopPad.value,
        bottom: MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: mood.rule)),
        ),
        child: NavigationBar(
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          // Two drawings per tab, not one recoloured: selected fills the shape
          // with the accent and knocks its interior lines out. Their ink comes
          // from the theme's `iconTheme`, not from here.
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
}
