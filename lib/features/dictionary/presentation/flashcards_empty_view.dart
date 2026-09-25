import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// What the drill shows when the deck is empty — one state for all four ways
/// in, and the screen still opens, because tapping Flashcards with nothing
/// saved asks *what is this?*.
///
/// The body is chosen: a free learner who saved a term out of reach
/// (ADR-0014) lands here too, and the design never had that state (#20).
class FlashcardsEmptyView extends StatelessWidget {
  /// Creates a [FlashcardsEmptyView].
  const FlashcardsEmptyView({required this.isOutOfReach, super.key});

  /// Whether they saved terms and none of them can be drilled.
  ///
  /// Required, so a second entry point cannot pick a body by forgetting to.
  final bool isOutOfReach;

  /// The body this state actually owes the learner.
  String _body(BuildContext context) => isOutOfReach
      ? context.strings.flashcardsEmptyOutOfReachBody
      : context.strings.flashcardsEmptyBody;

  /// The design's `size={44}` bookmark, at half opacity.
  static const double _markSize = 44;
  static const double _markOpacity = 0.5;

  /// The design's `maxWidth: 280` on the copy and the action.
  static const double _columnWidth = 280;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Semantics(
      // One announcement: the mark carries no meaning a reader can use, and
      // the heading, the copy and the button are one thought.
      label: '${context.strings.flashcardsTitle}. ${_body(context)}',
      // Excluded, or the heading and the copy are read once as this label and
      // again as its children.
      excludeSemantics: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.strings.flashcardsTitle,
              style: AppText.display(mood: mood),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: Column(
                children: [
                  Opacity(
                    opacity: _markOpacity,
                    child: IconMark(
                      AppIcon.bookmark,
                      size: _markSize,
                      color: mood.inkMute,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _columnWidth),
                    child: Column(
                      children: [
                        Text(
                          _body(context),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: mood.inkMute,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          label: context.strings.flashcardsBrowse,
                          // `go`, not `push`: the learner asked to browse, and
                          // stacking the dictionary on top of a drill they
                          // cannot run would put an empty screen behind their
                          // back button.
                          onPressed: () =>
                              context.goNamed(AppRoutes.dictionary.name),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
