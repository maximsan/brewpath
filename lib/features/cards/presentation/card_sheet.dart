import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/app_sheet.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/cards/presentation/card_locked_face.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/card_stamp_section.dart';
import 'package:brew_path/features/challenges/presentation/tried_seal.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The mark's size where the design has its per-kind drawing — see
/// [CardSheetBody] for why this is still a mark.
const double _markSize = 96;

/// Opens [item] over the collection.
///
/// A sheet, not a push: the design never takes the learner off the grid to
/// read a card (`CardSheet`, `screens.jsx:2458`), so closing puts them back
/// exactly where they were, on the tile they tapped.
/// Returns what the learner asked for on the way out, when they asked for
/// anything — the sheet cannot navigate for itself, because the route it sits
/// on belongs to whoever opened it.
Future<CardSheetIntent?> showCardSheet(
  BuildContext context,
  CardWithCollection item,
) => showAppSheet<CardSheetIntent>(
  context: context,
  title: item.card.title,
  builder: (_) => CardSheetBody(item: item),
);

/// One collectible, as the sheet reads it: what it is, what it says, and the
/// line worth keeping.
///
/// **The title is the sheet primitive's**, at the step every sheet shares.
/// The design sets this one card a step larger than its sibling sheets —
/// `--t-display` here against `--t-title` on the gate, the challenge and the
/// duel — and the app keeps one sheet dressing rather than forking the
/// primitive for a single caller. A deliberate divergence, recorded on #385.
///
/// **The artwork is not here.** The design fills a tinted 150px well with a
/// per-kind drawing, and `CARD_ART` is thirty-seven of them
/// (`screens.jsx:2312`) with no counterpart in `lib/`. The tile needs the same
/// family, and #434 holds the question open beside the one #87 asks of the
/// grove — so the module's mark stands in, as it did on the screen this
/// replaced, rather than half the set landing here.
class CardSheetBody extends ConsumerWidget {
  /// Creates a [CardSheetBody].
  const CardSheetBody({required this.item, super.key});

  /// The card being read, with whether the learner holds it.
  final CardWithCollection item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = context.mood;
    final text = Theme.of(context).textTheme;
    final card = item.card;

    // An unheld card shows its face and stops there (ADR-0015): no summary,
    // no keepsake line, and no stamp block — a challenge cannot be logged
    // against a card the learner has not got.
    if (!item.isCollected) return CardLockedFace(card: card);

    final tried =
        ref.watch(cardChallengeTriedProvider(card.id)).asData?.value ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tried)
          // The design stamps this beside the title; the title belongs to the
          // primitive, so the seal sits under it — where the guide sheet puts
          // its bookmark, for the same reason.
          const Align(alignment: Alignment.centerRight, child: TriedSeal()),
        Center(
          child: IconMark(
            moduleMark(card.iconName),
            size: _markSize,
            color: mood.accent,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          card.description,
          style: text.bodyLarge?.copyWith(color: mood.inkMute),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Keepsake(fact: card.fact),
        const SizedBox(height: AppSpacing.lg),
        CardStampSection(cardId: card.id, isCollected: item.isCollected),
      ],
    );
  }
}

/// The line the card is kept for.
///
/// Set in the display face at the heading step (`screens.jsx:2524`) — the
/// summary above it says what the card is about, and this is the thing worth
/// carrying away, so it is not more body copy.
class _Keepsake extends StatelessWidget {
  const _Keepsake({required this.fact});

  final String fact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SmallcapsLabel('Fact', isHeader: true),
        const SizedBox(height: AppSpacing.xs),
        Text(fact, style: AppText.heading(mood: context.mood)),
      ],
    );
  }
}
