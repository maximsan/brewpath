import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/app/header_tier.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/chrome_marks.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/header_chrome.dart';
import 'package:brew_path/core/widgets/header_compact_title.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_home_screen.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:brew_path/features/saved/presentation/saved_badge_dot.dart';
import 'package:brew_path/features/tour/domain/tour_step.dart';
import 'package:brew_path/features/tour/presentation/tour_anchor.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The one header the four tabs share, owned by the shell.
///
/// Rendered once above the branch navigators: the shell decides whether it
/// draws at all, this decides what it says. At rest it floats over the tab
/// showing only its entries; scrolled, its compact title replaces the large
/// one that has gone under it, so a tab is titled exactly once (#441).
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
            TourAnchor(
              step: TourStep.header,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (index, action) in tab.actions.indexed) ...[
                    if (index > 0) const SizedBox(width: _entryGap),
                    _ActionButton(action: action),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The design's `gap: 10` between the entries.
const double _entryGap = 10;

/// An entry is a 44-px circle — `borderRadius: 999; background:
/// var(--surface); border: 1px solid var(--rule)` — with its glyph centred.
const double _entrySize = 44;

/// The count dot sits on the circle's edge: `top: -1; right: -1`, ringed by
/// `2px solid var(--bg)` so it reads over the glyph and the border alike.
const double _dotOverhang = 1;
const double _dotRing = 2;

/// The gear's `size = 18`.
const double _gearSize = 18;

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
        glyph: OpenBookMark(color: context.mood.accent),
        tooltip: DictionaryHomeScreen.title,
        routeName: AppRoutes.dictionary.name,
      ),
      HeaderAction.settings => _RouteButton(
        glyph: IconMark(AppIcon.gear, size: _gearSize, color: context.mood.ink),
        tooltip: 'Settings',
        routeName: AppRoutes.profileSettings.name,
      ),
    };
  }
}

/// The circle every entry sits in.
class _EntryRing extends StatelessWidget {
  const _EntryRing({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Container(
      width: _entrySize,
      height: _entrySize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: mood.surface,
        shape: BoxShape.circle,
        border: Border.all(color: mood.rule),
      ),
      child: child,
    );
  }
}

/// A header entry that does nothing but open a route.
class _RouteButton extends StatelessWidget {
  const _RouteButton({
    required this.glyph,
    required this.tooltip,
    required this.routeName,
  });

  /// The mark in the ring, already in its own ink.
  final Widget glyph;
  final String tooltip;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _EntryRing(child: glyph),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: _entrySize,
        height: _entrySize,
      ),
      tooltip: tooltip,
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
    final strings = context.strings;
    final label = count == 0
        ? strings.savedScreenTitle
        : '${strings.savedScreenTitle}, '
              '${savedItemCount(strings, count)}';

    final mood = context.mood;

    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          _EntryRing(child: SavedBookmarkMark(color: mood.accent)),
          if (count > 0)
            Positioned(
              top: -_dotOverhang,
              right: -_dotOverhang,
              child: Container(
                padding: const EdgeInsets.all(_dotRing),
                decoration: BoxDecoration(
                  color: mood.bg,
                  shape: BoxShape.circle,
                ),
                child: const SavedBadgeDot(),
              ),
            ),
        ],
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: _entrySize,
        height: _entrySize,
      ),
      // The tooltip is the button's accessible name, so this is what carries
      // the count to a screen reader.
      tooltip: label,
      onPressed: () => context.pushNamed(AppRoutes.saved.name),
    );
  }
}
