import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// What the drill shows when the deck is empty.
///
/// **The screen still opens.** A learner who taps Flashcards with nothing
/// bookmarked has asked a question — *what is this?* — and an entry point that
/// refused to open, or a snackbar in its place, would leave it unanswered.
/// This is the answer: what a deck is made of, and one way to go and make one.
///
/// The same state for all four ways in, which is why it is a view rather than
/// something the dictionary's own screen draws.
///
/// **It answers one question, and there are two.** This copy is the design's,
/// written for *nothing saved*. A free learner who bookmarked a term their
/// lessons have not taught yet also lands here, and for them "bookmark terms
/// and they become a deck" is untrue — they did, and it did not. The design
/// never had that state, because its dictionary is gated where the app's is
/// open; the copy that state is owed is
/// [#468](https://github.com/maximsan/brewpath/issues/468).
class FlashcardsEmptyView extends StatelessWidget {
  /// Creates a [FlashcardsEmptyView].
  const FlashcardsEmptyView({super.key});

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
      label: '${FlashcardsCopy.title}. ${FlashcardsCopy.emptyBody}',
      // Excluded, or the heading and the copy are read once as this label and
      // again as its children.
      excludeSemantics: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(FlashcardsCopy.title, style: AppText.display(mood: mood)),
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
                          FlashcardsCopy.emptyBody,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: mood.inkMute,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          label: FlashcardsCopy.browse,
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
