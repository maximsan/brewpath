import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/progress/domain/freeze_save_notice.dart';
import 'package:brew_path/features/progress/domain/freeze_save_notice_providers.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/presentation/freeze_mark.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The save beat on the Learn tab: shown once after a freeze covered a day,
/// dismissible, never repeated for the same save (#233).
///
/// Renders nothing while its state loads or when nothing is due — a notice
/// must never block or shift the tab it reassures.
class FreezeSaveNoticeCard extends ConsumerWidget {
  /// Creates a [FreezeSaveNoticeCard].
  const FreezeSaveNoticeCard({super.key});

  Future<void> _dismiss(WidgetRef ref, int coveredDay) async {
    await ackFreezeSave(
      ref.read(snapshotRepositoryProvider),
      coveredDay,
      DateTime.now(),
    );
    ref.invalidate(freezeSaveNoticeDayProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coveredDay = ref.watch(freezeSaveNoticeDayProvider).asData?.value;
    final status = ref.watch(streakStatusProvider).asData?.value;
    if (coveredDay == null || status == null) return const SizedBox.shrink();

    final mood = context.mood;
    final body = freezeSaveNoticeBody(
      coveredDay: coveredDay,
      status: status,
      today: DateTime.now(),
    );
    return Semantics(
      label: '$freezeSaveNoticeTitle $body',
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: mood.surface,
          borderRadius: BorderRadius.circular(AppRadii.chrome),
          border: Border.all(color: mood.rule),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The design draws its own freeze mark — "one dash, one meaning: a
            // day held rather than earned" — and the app already ships it for
            // the week strip. A snowflake was never the design's idea of it.
            ExcludeSemantics(child: FreezeMark(color: mood.accent)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      freezeSaveNoticeTitle,
                      style: AppText.body(mood: mood),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(body, style: AppText.support(mood: mood)),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const IconMark(AppIcon.close),
              iconSize: AppSpacing.md,
              color: mood.inkMute,
              tooltip: 'Dismiss',
              onPressed: () => _dismiss(ref, coveredDay),
            ),
          ],
        ),
      ),
    );
  }
}
