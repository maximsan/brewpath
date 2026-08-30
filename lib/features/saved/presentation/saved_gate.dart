import 'dart:async';

import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:brew_path/features/saved/domain/saved_cap.dart';
import 'package:flutter/material.dart';

/// What a free learner is told when their shelf is full.
///
/// **One call site's worth of policy, deliberately.** The refusal is the Plus
/// gate — the shelf is the app's one concrete paywall hook — so this raises the
/// same sheet every other lock will, carrying the shelf as the trigger. A new
/// gated surface adds a trigger case, never a second sheet.
///
/// Fire-and-forget: the sheet resolves when it is dismissed, and dismissal
/// writes nothing, so no caller has anything to await.
void showSavedCapReached(BuildContext context) {
  unawaited(showPlusGate(context, const SavedShelfFull(cap: savedFreeMax)));
}
