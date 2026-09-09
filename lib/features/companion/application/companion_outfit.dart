/// The one place that decides what Roasty is wearing.
library;

import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'companion_outfit.g.dart';

/// What every Roasty in the app draws itself in.
///
/// **Hidden, not wiped.** A free learner reads the plain bean while the
/// snapshot keeps whatever they once picked, so a lapsed entitlement hides the
/// wardrobe and a returning one brings it back. Awaited rather than read as an
/// `AsyncValue`, so this emits once (#89's rule for value providers).
@riverpod
Future<CompanionConfig> companionOutfit(Ref ref) async {
  // Watches before awaits: a rebuild mid-flight must not reach a watch across
  // an async gap on a disposed ref.
  final entitledFuture = ref.watch(courseEntitlementProvider.future);
  final snapshots = ref.watch(snapshotRepositoryProvider);

  final snapshot = await snapshots.read();
  if (!await entitledFuture) return CompanionConfig.initial;
  return snapshot.clearedByDeleteOnly.companion.value;
}
