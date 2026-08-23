import 'package:brew_path/app/app_header.dart';
import 'package:brew_path/app/header_tier.dart';
import 'package:brew_path/core/constants/app_labels.dart';
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

    return Scaffold(
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
            // scrolls under its own bar, and letting it collapse a header it
            // cannot see would leave the tab wrong when the learner pops back.
            child: showsHeader
                ? NotificationListener<ScrollNotification>(
                    onNotification: _onScroll,
                    child: widget.navigationShell,
                  )
                : widget.navigationShell,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: AppLabels.tabLearn,
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: AppLabels.tabPath,
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style),
            label: AppLabels.tabCards,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: AppLabels.tabProfile,
          ),
        ],
      ),
    );
  }
}
