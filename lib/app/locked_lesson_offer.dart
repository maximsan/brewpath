import 'dart:async';

import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Raises the Plus offer for a lesson the router's course wall turned away.
///
/// The bounce alone would move the learner somewhere they did not ask for with
/// no word about why, which is the one thing a wall must never do. This says
/// what it would cost.
///
/// **After the frame, not during.** The redirect that refused the lesson is
/// still resolving a location when it hands the id over, and a sheet pushed
/// inside a redirect has no route to sit on.
///
/// [navigator] is the root navigator; the sheet opens from its *overlay*,
/// which is a context under it rather than its own — `Navigator.of` looks for
/// an ancestor and would find the wrong one, or none.
void raiseLockedLessonOffer({
  required Ref ref,
  required String lessonId,
  required GlobalKey<NavigatorState> navigator,
}) {
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => unawaited(_open(ref, lessonId, navigator)),
  );
}

Future<void> _open(
  Ref ref,
  String lessonId,
  GlobalKey<NavigatorState> navigator,
) async {
  final lesson = await ref
      .read(contentRepositoryProvider)
      .getLessonById(lessonId);
  final context = navigator.currentState?.overlay?.context;
  // An id no bank carries keeps the silent bounce it already got: a stranger's
  // mistyped link is not a moment to sell into.
  if (lesson == null || context == null || !context.mounted) return;
  await showPlusGate(context, LockedLesson(title: lesson.title));
}
