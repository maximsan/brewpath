/// Opening a lesson that has already been finished, with the confirm sheet
/// the design draws in front of it (#573).
library;

import 'package:brew_path/core/widgets/confirm_sheet.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/lessons/domain/replay_confirm.dart';
import 'package:brew_path/features/lessons/domain/replay_confirm_providers.dart';
import 'package:brew_path/features/monetization/presentation/activity_start.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opening a lesson from a list that can reach a finished one.
///
/// On [BuildContext] rather than `WidgetRef` for the reason `StartActivity`
/// is: the rows that open a lesson are plain widgets deep in a tree, and this
/// is a one-shot read on a tap.
extension ReviewBeforeReplay on BuildContext {
  /// Goes to [lessonId], asking first when the lesson is already finished.
  Future<void> goToLessonAskingReview(String lessonId) async {
    if (await _confirmedReplay(lessonId) && mounted) {
      await goToActivity(lessonRun(lessonId));
    }
  }

  /// Pushes [lessonId] under the same rule, for a list whose close has to
  /// return the learner to it.
  Future<void> pushLessonAskingReview(String lessonId) async {
    if (await _confirmedReplay(lessonId) && mounted) {
      await pushActivity(lessonRun(lessonId));
    }
  }

  /// Whether the run may start: always for an unfinished lesson, and for a
  /// finished one only once the sheet has been confirmed.
  ///
  /// The sheet comes **before** the free day's allowance, so a learner who
  /// tapped by accident backs out without meeting a paywall they never asked
  /// for.
  Future<bool> _confirmedReplay(String lessonId) async {
    final view = await ProviderScope.containerOf(
      this,
      listen: false,
    ).read(replayConfirmProvider(lessonId).future);
    if (view == null) return true;
    if (!mounted) return false;

    return showConfirmSheet(
      context: this,
      title: view.title,
      actions: const ConfirmActions(
        confirm: ReplayConfirmCopy.confirm,
        cancel: ReplayConfirmCopy.cancel,
      ),
      stakes: ConfirmStakes(
        lines: [
          for (final line in view.lines)
            ConfirmLine(label: line.label, value: line.value),
        ],
      ),
    );
  }
}
