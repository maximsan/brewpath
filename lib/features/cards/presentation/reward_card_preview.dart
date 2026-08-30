import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/overlay_barrier.dart';
import 'package:brew_path/features/cards/presentation/reward_card.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Shows [card] full-screen behind the covering wash, and returns when it is
/// dismissed.
///
/// **The wash is `veilStrong`, and that is the token's own job.** It was
/// written for exactly this — *"the earned-card preview at the end of a
/// lesson"* — and had no call site until now. Opened through
/// [showOverlayDialog] so the blur travels with the tint; a modal opened any
/// other way fails the overlay pairing guard.
Future<void> showRewardCardPreview(
  BuildContext context,
  CoffeeCardModel card,
) => showOverlayDialog<void>(
  context: context,
  overlay: context.mood.veilStrong,
  builder: (context) => RewardCardPreview(card: card),
);

/// The preview's contents: the card, a close control, and a tap anywhere else
/// to dismiss.
class RewardCardPreview extends StatelessWidget {
  /// Creates a [RewardCardPreview].
  const RewardCardPreview({required this.card, super.key});

  /// The collectible on show.
  final CoffeeCardModel card;

  /// The close control's edge.
  static const double _closeSize = 40;

  /// Its mark's size inside that.
  static const double _closeMark = 16;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Semantics(
      label: 'Card preview',
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned.fill(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutter,
                    vertical: AppSpacing.xxl,
                  ),
                  child: Center(
                    // Its own tap target, so a tap on the card itself does not
                    // fall through to the dismissing barrier behind it.
                    child: GestureDetector(
                      onTap: () {},
                      child: RewardCard(card: card),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: SafeArea(child: _close(context, mood)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _close(BuildContext context, MoodColors mood) => Material(
    color: mood.surface,
    shape: CircleBorder(side: BorderSide(color: mood.rule)),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: () => Navigator.of(context).pop(),
      child: SizedBox(
        width: _closeSize,
        height: _closeSize,
        child: Center(
          child: IconMark(
            AppIcon.close,
            size: _closeMark,
            color: mood.ink,
            semanticLabel: 'Close preview',
          ),
        ),
      ),
    ),
  );
}
