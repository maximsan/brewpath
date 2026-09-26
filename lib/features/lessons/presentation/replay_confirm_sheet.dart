/// Opening a lesson that has already been finished, with the confirm sheet
/// the design draws in front of it (#573).
library;

import 'package:brew_path/core/widgets/confirm_sheet.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/lessons/domain/replay_confirm.dart';
import 'package:brew_path/features/lessons/domain/replay_confirm_providers.dart';
import 'package:brew_path/features/monetization/presentation/activity_start.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Opening a lesson from a list that can reach a finished one.
///
/// On [BuildContext] rather than `WidgetRef` for the reason `StartActivity`
/// is: the rows that open a lesson are plain widgets deep in a tree, and this
/// is a one-shot read on a tap.
extension ReviewBeforeReplay on BuildContext {
  /// Goes to [lessonId], asking first when the lesson is already finished.
  ///
  /// The router is taken before the asking: the allowance check refreshes
  /// the store, and a list rebuilt under the sheet can unmount the row that
  /// was tapped — the run it was tapped for must still start.
  Future<void> goToLessonAskingReview(String lessonId) async {
    final router = GoRouter.maybeOf(this);
    if (await _mayReplay(lessonId)) {
      (router ?? GoRouter.of(this)).goToAfterAllowance(lessonRun(lessonId));
    }
  }

  /// Pushes [lessonId] under the same rule, for a list whose close has to
  /// return the learner to it.
  Future<void> pushLessonAskingReview(String lessonId) async {
    final router = GoRouter.maybeOf(this);
    if (await _mayReplay(lessonId)) {
      await (router ?? GoRouter.of(this)).pushAfterAllowance(
        lessonRun(lessonId),
      );
    }
  }

  /// Whether the run may start: the free day's allowance first, then — for a
  /// finished lesson — the sheet.
  ///
  /// The gate comes **before** the question, as the design's own course gate
  /// does: a learner who cannot play today is told so, not asked whether they
  /// meant to and then refused.
  Future<bool> _mayReplay(String lessonId) async =>
      await mayStartAnotherActivity() &&
      mounted &&
      await _confirmedReplay(lessonId);

  /// Whether a finished lesson's sheet was confirmed; true outright for an
  /// unfinished one, which has nothing to ask.
  Future<bool> _confirmedReplay(String lessonId) async {
    final view = await ProviderScope.containerOf(
      this,
      listen: false,
    ).read(replayConfirmProvider(lessonId).future);
    if (view == null) return true;
    if (!mounted) return false;

    return showConfirmSheet(
      context: this,
      title: strings.replayConfirmTitle(view.lessonTitle),
      actions: ConfirmActions(
        confirm: strings.replayConfirmConfirm,
        cancel: strings.replayConfirmCancel,
      ),
      stakes: ConfirmStakes(
        lines: [
          for (final line in replayConfirmLines(strings, view))
            ConfirmLine(label: line.label, value: line.value),
        ],
      ),
    );
  }
}
