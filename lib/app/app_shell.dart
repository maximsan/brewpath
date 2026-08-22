import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/presentation/tour_runner.dart';
import 'package:brew_path/features/tour/presentation/tour_stop.dart';
import 'package:brew_path/features/tour/presentation/tour_stops.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom-nav scaffold wrapping the four `StatefulShellRoute` branches. Each
/// branch keeps its own navigator stack, so tab state and scroll position
/// survive switching tabs.
class AppShell extends StatelessWidget {
  /// Creates an [AppShell] around [navigationShell].
  const AppShell(this.navigationShell, {super.key});

  /// The shell that manages the four bottom-nav branches.
  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      // Re-tapping the active tab pops it back to that branch's root.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // The Tour's engine is owned here, not on Learn: the last stop is the tab
    // bar below, which lives outside every branch.
    return TourHost(
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: TourStop(
          stopKey: TourStops.tabs,
          title: TourCopy.tabsTitle,
          description: TourCopy.tabsBody,
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
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
        ),
      ),
    );
  }
}
