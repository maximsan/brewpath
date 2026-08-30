import 'dart:async';

import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:flutter/material.dart';

/// What a free learner is told when they try the Studio door.
///
/// **One call site's worth of policy, deliberately.** The refusal is the Plus
/// gate, so this raises the same sheet every other lock does, carrying the
/// Studio as the trigger. A new gated surface adds a trigger case, never a
/// second sheet.
///
/// This was a snackbar until #89 landed, and the placeholder said the sheet
/// would replace its body and nothing else — which is what happened.
///
/// Fire-and-forget: the sheet resolves when it is dismissed, and dismissal
/// writes nothing, so no caller has anything to await.
void showStudioLocked(BuildContext context) {
  unawaited(showPlusGate(context, const LockedStudio()));
}
