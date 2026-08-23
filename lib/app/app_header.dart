import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/app/header_tier.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_home_screen.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
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
    final tab = tabHeaderFor(
      location,
      today: ref.watch(currentDayProvider),
      learnerName: ref.watch(learnerNameProvider).asData?.value,
    );
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
          // The design pairs the Dictionary with a Saved button and its count
          // badge. The Saved shelf has no screen yet and its build comes after
          // this one, so nothing is offered here rather than a button that
          // opens nothing.
          _ActionButton(action: tab.action),
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});

  final HeaderAction action;

  @override
  Widget build(BuildContext context) {
    final (icon, tooltip, routeName) = switch (action) {
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
