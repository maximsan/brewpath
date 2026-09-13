import 'package:brew_path/shared/models/content/visual_guide.dart';
import 'package:brew_path/shared/repositories/bank_loader.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'visual_guide_repository.g.dart';

/// The eight visual guides, loaded off the bundled bank and cached.
///
/// Its own repository because `ContentRepository` sits at the method budget
/// the metrics gate enforces — the same reason the dictionary has one. It is
/// **separate from the collectibles accessor on purpose**: "a guide is never
/// listed beside a collectible" only survives if the two never meet.
class VisualGuideRepository {
  List<VisualGuide>? _guides;

  /// Loads and caches every guide, in bank order.
  Future<List<VisualGuide>> getGuides() async {
    _guides ??= await loadBank(
      'visual_guides',
      VisualGuide.fromJson,
    );
    return _guides!;
  }

  /// The guide covering [subject], or null when the bank carries none.
  ///
  /// **Earned-ness is not consulted here.** A lesson teaching a guide renders
  /// it *before* the completion that unlocks it, so filtering by progress
  /// would leave the card that teaches roast unable to name the roast guide.
  /// Whether a learner owns one is the shelf's question.
  Future<VisualGuide?> getBySubject(String subject) async {
    final guides = await getGuides();
    return guides.where((guide) => guide.subject == subject).firstOrNull;
  }
}

/// The app-wide [VisualGuideRepository].
@riverpod
VisualGuideRepository visualGuideRepository(Ref ref) => VisualGuideRepository();

/// The guide covering [subject], earned or not.
///
/// Beside the repository rather than in either feature that reads it: the
/// Reference section and the lesson card both ask this question, and it is a
/// content lookup rather than a decision either of them owns.
@riverpod
Future<VisualGuide?> visualGuideForSubject(Ref ref, String subject) =>
    ref.watch(visualGuideRepositoryProvider).getBySubject(subject);
