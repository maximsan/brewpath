import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/saved/domain/saved_cap.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:brew_path/features/saved/presentation/saved_gate.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Puts [savedKey] on the shelf or takes it off, explaining a refusal.
///
/// The one path both ways in take — the bookmark and the dictionary's
/// swipe-to-save — so the cap, the entitlement and the re-read cannot drift
/// between them.
Future<void> toggleSavedKey(
  BuildContext context,
  WidgetRef ref,
  String savedKey,
) async {
  // **Awaited, not read for its current value.** Nothing watches the
  // entitlement here, so a synchronous read is still unresolved on the first
  // tap and would report `false` — refusing a paying learner at five items.
  final isPlus = await ref.read(courseEntitlementProvider.future);
  // The cap is judged on what the shelf would show, so the number the learner
  // is refused at is the number they were told they had.
  final visible = savedShelfCount(await ref.read(savedShelfProvider.future));

  final outcome = await toggleSaved(
    ref.read(snapshotRepositoryProvider),
    key: savedKey,
    now: DateTime.now(),
    isPlus: isPlus,
    visible: visible,
  );

  if (outcome is SaveGateRaised && context.mounted) {
    showSavedCapReached(context);
  }
}
