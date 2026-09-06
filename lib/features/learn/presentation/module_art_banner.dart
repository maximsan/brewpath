import 'package:brew_path/core/utils/object_position.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// A module's picture as a banner under a title — the design's
/// `width: 100%; height: 120; borderRadius: 10; objectFit: cover`.
///
/// Full-width under the title rather than a thumbnail beside it: the design
/// settled that in review, because long lesson names were being squeezed into
/// a narrow column next to the art. Every element on the card hangs off the
/// same left rail, and the picture is one of them.
///
/// Draws nothing at all for a module without a picture; the card closes up
/// around the gap rather than framing an absence. A picture the bundle cannot
/// decode leaves the frame filled with the raised surface, so a broken asset
/// never shows as a broken image.
class ModuleArtBanner extends StatelessWidget {
  /// Creates a [ModuleArtBanner] for [module].
  const ModuleArtBanner({required this.module, super.key});

  /// The module whose picture this is.
  final ModuleModel module;

  /// The design's banner height.
  static const double height = 120;

  @override
  Widget build(BuildContext context) {
    final art = module.art;
    if (art == null) return const SizedBox.shrink();

    final mood = context.mood;
    // Decoration, not content: the title above already names the module.
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.inner),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Image.asset(
            art,
            fit: BoxFit.cover,
            alignment: alignmentFromObjectPosition(module.artPos),
            errorBuilder: (context, error, stackTrace) =>
                ColoredBox(color: mood.surface2),
          ),
        ),
      ),
    );
  }
}
