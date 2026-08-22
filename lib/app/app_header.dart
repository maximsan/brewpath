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

/// The header's fixed height, and the padding a tab's content owes it.
///
/// Exported as one constant so a scroll container cannot drift out of
/// agreement with the bar above it — the class of bug the design's own chrome
/// notes call out.
const double kAppHeaderHeight = 96;

/// The one header the four tabs share, owned by the shell.
///
/// Rendered **once**, above the branch navigators, exactly as the design
/// renders it once at app level beside the tab bar. It reads the current
/// location to title itself and to decide whether it draws at all: a page
/// pushed on top of a tab brings its own bar, and this must stay out of its
/// way.
class AppHeader extends ConsumerWidget {
  /// Creates an [AppHeader].
  const AppHeader({required this.location, super.key});

  /// The location the shell is currently showing.
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = headerTitleFor(
      location,
      today: ref.watch(currentDayProvider),
    );
    if (title == null) return const SizedBox.shrink();

    final mood = context.mood;
    final isProfile = location == AppRoutes.profile.path;

    return SizedBox(
      height: kAppHeaderHeight,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SmallcapsLabel(title.eyebrow),
                  const SizedBox(height: AppSpacing.xxs),
                  Semantics(
                    header: true,
                    child: Text(
                      title.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: mood.ink),
                    ),
                  ),
                ],
              ),
            ),
            // The design pairs Dictionary with a Saved button carrying a count
            // badge. The Saved shelf has no screen yet and its build comes
            // after this one, so the slot is declared and left empty rather
            // than shipping a button that opens nothing.
            if (isProfile)
              _HeaderAction(
                icon: Icons.settings_outlined,
                tooltip: 'Settings',
                onPressed: () =>
                    context.pushNamed(AppRoutes.profileSettings.name),
              )
            else
              _HeaderAction(
                icon: Icons.menu_book_outlined,
                tooltip: DictionaryHomeScreen.title,
                onPressed: () => context.pushNamed(AppRoutes.dictionary.name),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
      color: context.mood.ink,
    );
  }
}
