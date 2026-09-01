import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/cards/presentation/card_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the `cardDetail` route resolves to: nothing drawn, one sheet raised.
///
/// The design has no card screen, but #171 scopes the app's universal links to
/// the card route, so the path has to keep resolving. It resolves to a page
/// that paints nothing and sits transparently over the collection — so the
/// grid the learner lands on is the tab's own, not a second copy of it — and
/// then opens the card over it.
///
/// The page pops itself once the sheet closes, which puts the location back on
/// `/cards` and leaves the learner on the grid rather than on an empty route
/// they would have to press back through.
///
/// **A card the learner has not earned opens nothing.** The grid deliberately
/// masks an unearned card, so honouring a link to one would hand out through
/// the URL exactly what the tile withholds — its title, its summary and its
/// keepsake line.
class CardDeepLink extends ConsumerStatefulWidget {
  /// Creates a [CardDeepLink] for [cardId].
  const CardDeepLink({required this.cardId, super.key});

  /// The card the link names.
  final String cardId;

  @override
  ConsumerState<CardDeepLink> createState() => _CardDeepLinkState();
}

class _CardDeepLinkState extends ConsumerState<CardDeepLink> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    final collection = ref.watch(cardsWithCollectionProvider).asData?.value;

    // The collection arrives asynchronously, so this waits for it rather than
    // resolving the link against a list that is not there yet.
    if (collection != null && !_handled) {
      _handled = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _openThenLeave(collection),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _openThenLeave(List<CardWithCollection> collection) async {
    if (!mounted) return;
    final navigator = Navigator.of(context);

    final earned = collection.where(
      (item) => item.card.id == widget.cardId && item.isCollected,
    );
    if (earned.isNotEmpty) {
      await showCardSheet(context, earned.first);
    }

    if (navigator.canPop()) navigator.pop();
  }
}
