import 'package:brew_path/shared/models/content/visual_guide.dart';
import 'package:brew_path/shared/repositories/bank_loader.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'visual_guide_repository.g.dart';

/// The eight visual guides, loaded off the bundled bank and cached.
///
/// Its own repository rather than another method on `ContentRepository`,
/// which sits at the method budget the metrics gate enforces — the same
/// reason the dictionary has one. Loading goes through the same [loadBank]
/// helper every other bank uses, so nothing about how this content reaches
/// the app is special.
///
/// **Separate from the collectibles accessor on purpose.** "A guide is never
/// listed beside a collectible" is a rule that only survives if the two lists
/// never meet in a variable.
class VisualGuideRepository {
  List<VisualGuide>? _guides;

  /// Loads and caches every guide, in bank order.
  Future<List<VisualGuide>> getGuides() async {
    _guides ??= await loadBank(
      'assets/content/generated/visual_guides.json',
      VisualGuide.fromJson,
    );
    return _guides!;
  }
}

/// The app-wide [VisualGuideRepository].
@riverpod
VisualGuideRepository visualGuideRepository(Ref ref) => VisualGuideRepository();
