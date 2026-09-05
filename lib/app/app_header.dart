import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/app/header_chrome.dart';
import 'package:brew_path/app/header_compact_title.dart';
import 'package:brew_path/app/header_tier.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_home_screen.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:brew_path/features/saved/presentation/saved_badge_dot.dart';
import 'package:brew_path/features/saved/presentation/saved_screen.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/presentation/tour_stop.dart';
import 'package:brew_path/features/tour/presentation/tour_stops.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The one header the four tabs share, owned by the shell.
///
/// Rendered **once**, above the branch navigators, exactly as the design
/// renders it once at app level beside the tab bar. The shell decides whether
/// it draws at all; this decides what it says.
///
/// **It floats over the tab rather than standing above it**, and at rest it
/// draws nothing but its entries: the tab's own `TabLargeTitle` is what titles
/// the screen there. Scrolled, the bar materialises and the compact title
/// slides in to replace the large one that has just gone under it — so the
/// screen is titled exactly once at every point of the scroll, which is the
/// pairing the design is built on and the reason the Cards tab had no title of
/// its own until now (#441).
///
/// The entries stay put the whole way through. They are the only part of the
/// bar that was ever meant to be visible at the top of a tab.
///
/// It consumes the status-bar inset itself, because the bar has to reach up
/// under the status bar to blur what passes beneath it. A tab root's content
/// starts under that inset and scrolls up through it; a page pushed inside a
/// branch brings its own `AppBar`, which handles its own.
class AppHeader extends ConsumerWidget {
  /// Creates an [AppHeader].
  const AppHeader({
    required this.location,
    this.isCollapsed = false,
    super.key,
  });

  /// The tab root the shell is showing.
  final String location;

  /// Whether the tab beneath it has been scrolled. Owned by the shell, which
  /// keeps one flag per branch — the header itself holds no state, so it
  /// cannot disagree with the tab it is sitting over.
  final bool isCollapsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = tabHeaderFor(
      location,
      today: ref.watch(currentDayProvider),
      learnerName: ref.watch(learnerNameProvider).asData?.value,
    );
    if (tab == null) return const SizedBox.shrink();

    return HeaderChrome(
      height: HeaderChrome.tabHeight,
      isScrolled: isCollapsed,
      child: Padding(
        // The design closes the bar 14 above its bottom edge, which is the
        // one of the three it and the app agree on: the design sets the sides
        // to 18 either way, and the bar keeps the app's own gutter on the left
        // and its standard inset on the right, so the compact title lines up
        // with the tab content it stands in for and the entries sit where
        // every other screen's do.
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.md,
          AppSpacing.base,
        ),
        child: Row(
          children: [
            Expanded(
              child: HeaderCompactTitle(
                eyebrow: tab.eyebrow,
                title: tab.title,
                isVisible: isCollapsed,
              ),
            ),
            // Tour stop 3 frames the pair rather than either entry: the design
            // introduces Saved and the Dictionary as one place things you keep
            // end up, and a frame around one button would name half of it.
            TourStop(
              stopKey: TourStops.header,
              title: TourCopy.headerTitle,
              description: TourCopy.headerBody,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final action in tab.actions)
                    _ActionButton(action: action),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// How far the dot is inset from the button's top-right corner.
const double _badgeInset = 6;

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});

  final HeaderAction action;

  @override
  Widget build(BuildContext context) {
    // One exhaustive dispatch: a new action is a compile error here rather
    // than a runtime one somewhere else.
    return switch (action) {
      HeaderAction.saved => const _SavedButton(),
      HeaderAction.dictionary => _RouteButton(
        glyph: const Icon(Icons.menu_book_outlined),
        tooltip: DictionaryHomeScreen.title,
        routeName: AppRoutes.dictionary.name,
      ),
      HeaderAction.settings => _RouteButton(
        glyph: const IconMark(AppIcon.gear),
        tooltip: 'Settings',
        routeName: AppRoutes.profileSettings.name,
      ),
    };
  }
}

/// A header entry that does nothing but open a route.
class _RouteButton extends StatelessWidget {
  const _RouteButton({
    required this.glyph,
    required this.tooltip,
    required this.routeName,
  });

  /// Either kind of glyph: `IconButton` colours whatever it is given through
  /// an `IconTheme`, and both `Icon` and `IconMark` read one. The Dictionary
  /// entry stays stock because the design draws no mark for it.
  final Widget glyph;
  final String tooltip;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: glyph,
      tooltip: tooltip,
      color: context.mood.ink,
      onPressed: () => context.pushNamed(routeName),
    );
  }
}

/// The way onto the Saved shelf, carrying a dot when the shelf holds anything.
///
/// The count reaches the **semantic label** rather than being drawn as a
/// number: a screen reader should not have to infer "some" from a dot it
/// cannot see.
class _SavedButton extends ConsumerWidget {
  const _SavedButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Counted off the shelf itself rather than through a provider of its own:
    // the badge must not promise a row the shelf would skip, and one hop fewer
    // keeps the chain from flushing mid-build when Reset invalidates its root.
    //
    // An unresolved shelf draws no dot rather than a spinner in the chrome.
    final count = savedShelfCount(
      ref.watch(savedShelfProvider).value ?? const [],
    );
    final label = count == 0
        ? SavedScreen.title
        : '${SavedScreen.title}, ${savedItemCount(count)}';

    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const IconMark(AppIcon.bookmark),
          if (count > 0)
            const Positioned(
              top: -_badgeInset,
              right: -_badgeInset,
              child: SavedBadgeDot(),
            ),
        ],
      ),
      // The tooltip is the button's accessible name, so this is what carries
      // the count to a screen reader.
      tooltip: label,
      color: context.mood.ink,
      onPressed: () => context.pushNamed(AppRoutes.saved.name),
    );
  }
}
