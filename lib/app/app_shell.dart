import 'package:brew_path/app/app_header.dart';
import 'package:brew_path/app/header_tier.dart';
import 'package:brew_path/core/constants/app_labels.dart';
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
    // The header is the shell's, not a tab's: one instance above the four
    // branch navigators, which is why it survives a tab switch and does not
    // survive a push inside a branch — the push replaces the content beneath
    // it, and the tier rule keeps it from drawing over a page that brought its
    // own bar.
    // `uri`, not `matchedLocation`: the latter reports the *shell's* own
    // match, so it still says `/learn` while a term detail is pushed on top of
    // it, and the header would draw over a page that brought its own bar.
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: Column(
        children: [
          if (headerTierFor(location).showsSharedHeader)
            AppHeader(location: location),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
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
    );
  }
}
