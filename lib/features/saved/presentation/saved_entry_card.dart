import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/profile/presentation/widgets/profile_entry_card.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The way onto the Saved shelf from Profile.
///
/// The design closes Profile with this card beside the Studio's. Until now the
/// shelf was reachable only from the shared header's bookmark, which is chrome
/// — a learner looking for the things they kept had nowhere on the page to
/// look.
///
/// **Never gated.** The design's own gate says so: `featureUnlocked('saved')`
/// returns true unconditionally, because what Plus lifts is the cap on saving
/// past five, and the bookmark raises that gate where it is actually hit. The
/// `lock('saved')` branch beside this card in the design can therefore never
/// fire, so there is no Plus pill here to port.
class SavedEntryCard extends ConsumerWidget {
  /// Creates a [SavedEntryCard].
  const SavedEntryCard({super.key});

  /// The bookmark inside the well, at the size the design draws it there.
  static const double _markSize = 26;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Counted off the shelf itself rather than off the stored keys, exactly as
    // the header's badge is: the card must not promise a row the shelf would
    // skip.
    //
    // **Unresolved says nothing rather than zero.** The header's badge can hide
    // while it waits; a sentence cannot, and "0 saved to revisit" under a
    // learner's full shelf is a wrong count rather than an absent one. The row
    // holds its height, so nothing jumps when the number arrives. A shelf that
    // fails to load lands here too, and the screen this card opens is where
    // that is reported.
    final shelf = ref.watch(savedShelfProvider).asData?.value;

    return ProfileEntryCard(
      art: IconMark(
        AppIcon.bookmark,
        active: true,
        size: _markSize,
        color: context.mood.accent,
      ),
      kicker: 'Saved',
      title: 'Your favorites',
      // The design's line, which counts plainly. The shelf's own header adds
      // the free cap ("3 of 5 saved") because that is where the cap is acted
      // on; repeating it here would put the paywall on a page that has no slot
      // for one.
      support: shelf == null
          ? ''
          : '${savedShelfCount(shelf)} saved to revisit',
      onTap: () => context.pushNamed(AppRoutes.saved.name),
    );
  }
}
