import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/shared/models/content/grove_light.dart';
import 'package:brew_path/shared/models/content/grove_variety.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'studio_providers.g.dart';

/// Everything the chooser needs, resolved once.
///
/// The two banks and the planted grove arrive together because the screen
/// cannot draw a single row without all three — loading them separately would
/// give it three states to render instead of one.
@immutable
class StudioGrove {
  /// Creates a [StudioGrove].
  const StudioGrove({
    required this.varieties,
    required this.lights,
    required this.planted,
  });

  /// The species on offer, in the bank's order.
  final List<GroveVariety> varieties;

  /// The lights on offer, in the bank's order.
  final List<GroveLight> lights;

  /// What is in the ground right now — what the confirm is compared against.
  final Grove planted;

  /// The species with [id], falling back to the first the bank ships.
  ///
  /// A snapshot can name a species this build does not carry — an older write,
  /// or a bank edit — and the chooser must still open. Falling back shows the
  /// learner a plant they can then re-pick, where throwing would leave them a
  /// screen they cannot use.
  GroveVariety varietyOf(String id) =>
      varieties.firstWhere((v) => v.id == id, orElse: () => varieties.first);

  /// How [variety] looks under [light].
  GroveTreatment treatmentFor(String variety, String light) =>
      groveTreatmentFor(
        varieties: varieties,
        lights: lights,
        variety: variety,
        light: light,
      );
}

/// The chooser's data: both banks and the planted grove.
@riverpod
Future<StudioGrove> studioGrove(Ref ref) async {
  final content = ref.watch(contentRepositoryProvider);
  final snapshot = await ref.watch(snapshotRepositoryProvider).read();

  return StudioGrove(
    varieties: await content.getGroveVarieties(),
    lights: await content.getGroveLights(),
    planted: snapshot.clearedByDeleteOnly.grove.value,
  );
}
