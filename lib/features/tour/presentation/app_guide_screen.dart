import 'package:brew_path/core/widgets/page_large_title.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/core/widgets/sub_screen_scaffold.dart';
import 'package:brew_path/features/tour/domain/app_guide_copy.dart';
import 'package:brew_path/features/tour/presentation/replay_intro_row.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The written guide, reached from Settings → Help & Support → App Guide.
///
/// The Tour's counterpart and its way back in: the Tour is four stops on Learn
/// and is offered once, this is every part of the app in a line or two and is
/// always here. [ReplayIntroRow] at the foot is what makes the Tour repeatable
/// now that it can be skipped.
///
/// **Chrome diverges from the design on purpose.** `guide.jsx` gives the screen
/// a sub-screen header *and* a large display heading under it; this wears the
/// app's current sub-screen `AppBar`, the same as Settings and Streak, so the
/// title is said once. The design's frame arrives with the rest of the guide
/// layer's rebuild — [#341](https://github.com/maximsan/brewpath/issues/341).
class AppGuideScreen extends StatelessWidget {
  /// Creates an [AppGuideScreen].
  const AppGuideScreen({super.key});

  /// Gap above a section label that opens a new block.
  static const double _blockGap = AppSpacing.lg;

  static const _pagePadding = EdgeInsets.symmetric(vertical: AppSpacing.md);
  static const _gutter = EdgeInsets.symmetric(horizontal: AppSpacing.md);

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return SubScreenScaffold(
      title: AppGuideCopy.title,
      onBack: () => context.pop(),
      body: (context, scrollPadding) => ListView(
        padding: _pagePadding + scrollPadding,
        children: [
          const Padding(
            padding: _gutter,
            child: PageLargeTitle(AppGuideCopy.title),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: _gutter,
            child: Text(AppGuideCopy.lead, style: AppText.support(mood: mood)),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final section in AppGuideCopy.sections)
            _GuideSection(section: section),
          const SizedBox(height: _blockGap),
          const Padding(
            padding: _gutter,
            child: SmallcapsLabel(AppGuideCopy.introSectionLabel),
          ),
          const ReplayIntroRow(),
        ],
      ),
    );
  }
}

/// One part of the app: what it is called, and what it does.
class _GuideSection extends StatelessWidget {
  const _GuideSection({required this.section});

  static const _padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm,
  );

  final AppGuideSection section;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: AppText.body(mood: mood, face: AppFace.control),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(section.body, style: AppText.support(mood: mood)),
        ],
      ),
    );
  }
}
