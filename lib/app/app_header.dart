import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/app/header_tier.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_home_screen.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/presentation/saved_badge_dot.dart';
import 'package:brew_path/features/saved/presentation/saved_screen.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// How long the collapse takes when motion is allowed.
const _collapseDuration = Duration(milliseconds: 180);

/// The one header the four tabs share, owned by the shell.
///
/// Rendered **once**, above the branch navigators, exactly as the design
/// renders it once at app level beside the tab bar. The shell decides whether
/// it draws at all; this decides what it says.
///
/// It consumes the status-bar inset itself, because it is the only thing here
/// that needs to: a page pushed inside a branch brings its own `AppBar`, which
/// handles its own.
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
    final tab = tabHeaderFor(location, today: ref.watch(currentDayProvider));
    if (tab == null) return const SizedBox.shrink();

    final heading = Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.md,
        isCollapsed ? AppSpacing.xs : AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _Heading(tab: tab, isCollapsed: isCollapsed),
          ),
          for (final action in tab.actions) _ActionButton(action: action),
        ],
      ),
    );

    return SafeArea(
      bottom: false,
      // Sized by its content, not to a pair of constants: collapsing drops the
      // eyebrow and the box follows. A fixed height overflows for the few
      // frames after a restore, when the eyebrow is back but the box has not
      // grown yet.
      //
      // ⚠️ **Reduced motion drops the animator, rather than giving it a zero
      // duration.** `AnimatedSize` re-dirties itself inside its own
      // `performLayout` when asked to finish instantly, which the framework
      // asserts on — so the honest reading of "no animation" is no animator.
      child: MediaQuery.disableAnimationsOf(context)
          ? heading
          : AnimatedSize(
              duration: _collapseDuration,
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: heading,
            ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.tab, required this.isCollapsed});

  final TabHeader tab;
  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!isCollapsed) ...[
          SmallcapsLabel(tab.eyebrow),
          const SizedBox(height: AppSpacing.xxs),
        ],
        Semantics(
          header: true,
          child: Text(
            tab.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: context.mood.ink),
          ),
        ),
      ],
    );
  }
}

/// How far the dot is inset from the button's top-right corner.
const double _badgeInset = 6;

class _ActionButton extends ConsumerWidget {
  const _ActionButton({required this.action});

  final HeaderAction action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (action == HeaderAction.saved) return const _SavedButton();

    final (icon, tooltip, routeName) = switch (action) {
      HeaderAction.saved => throw StateError('handled above'),
      HeaderAction.dictionary => (
        Icons.menu_book_outlined,
        DictionaryHomeScreen.title,
        AppRoutes.dictionary.name,
      ),
      HeaderAction.settings => (
        Icons.settings_outlined,
        'Settings',
        AppRoutes.profileSettings.name,
      ),
    };

    return IconButton(
      icon: Icon(icon),
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
    // An unresolved count draws no dot rather than a spinner in the chrome.
    final count = ref.watch(savedCountProvider).value ?? 0;
    final label = count == 0
        ? SavedScreen.title
        : '${SavedScreen.title}, $count ${count == 1 ? 'item' : 'items'}';

    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.bookmark_outline),
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
