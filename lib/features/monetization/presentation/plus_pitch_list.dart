import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The ranked pitch, or its space while the banks are still being counted.
///
/// **Each bullet is one semantic node.** A title and a body read as two
/// unrelated fragments to a screen reader, and the ranking is the point — so
/// the pair is merged and heard as the sentence it is.
class PlusPitchList extends StatelessWidget {
  /// Creates a [PlusPitchList] for [pitch], or its placeholder when null.
  const PlusPitchList({required this.pitch, super.key});

  /// Roughly the height the three bullets occupy, so the sheet does not jump
  /// when they arrive.
  static const double _placeholderHeight = 132;

  /// The counted pitch, or null while it is being read.
  final PlusPitch? pitch;

  @override
  Widget build(BuildContext context) {
    if (pitch case final counted?) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final bullet in PlusCopy.bulletsFor(counted))
            _Bullet(bullet: bullet),
        ],
      );
    }

    return SizedBox(
      height: _placeholderHeight,
      child: Center(
        child: Semantics(
          label: 'Loading what Plus includes',
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.bullet});

  final PlusPitchBullet bullet;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      label: '${bullet.title}. ${bullet.body}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bullet.title,
              style: AppText.body(mood: mood, face: AppFace.control),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(bullet.body, style: AppText.support(mood: mood)),
          ],
        ),
      ),
    );
  }
}
