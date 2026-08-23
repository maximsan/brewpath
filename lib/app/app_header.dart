import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/app/header_tier.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_home_screen.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The header's height, below the status bar.
const double _headerHeight = 96;

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
  const AppHeader({required this.location, super.key});

  /// The tab root the shell is showing.
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = tabHeaderFor(location, today: ref.watch(currentDayProvider));
    if (tab == null) return const SizedBox.shrink();

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: _headerHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _Heading(tab: tab)),
              // The design pairs the Dictionary with a Saved button carrying a
              // count badge. The Saved shelf has no screen yet and its build
              // comes after this one, so nothing is offered here rather than a
              // button that opens nothing.
              _ActionButton(action: tab.action),
            ],
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.tab});

  final TabHeader tab;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SmallcapsLabel(tab.eyebrow),
        const SizedBox(height: AppSpacing.xxs),
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
