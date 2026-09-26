import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/profile/presentation/widgets/profile_entry_card.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The way onto the Saved shelf from Profile, beside the Studio's card.
///
/// Never gated: the design's `featureUnlocked('saved')` returns true
/// unconditionally, because what Plus lifts is the cap on saving past five and
/// the bookmark raises that gate where it is hit. Its `lock('saved')` branch
/// can never fire, so there is no Plus pill to port.
class SavedEntryCard extends ConsumerWidget {
  /// Creates a [SavedEntryCard].
  const SavedEntryCard({super.key});

  /// The bookmark inside the well, at the size the design draws it there.
  static const double _markSize = 26;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Counted off the shelf rather than the stored keys, as the header's
    // badge is: the card must not promise a row the shelf would skip.
    // Unresolved says nothing rather than zero, because "0 saved to revisit"
    // under a full shelf is a wrong count rather than an absent one; the row
    // holds its height, so nothing jumps when the number arrives.
    final shelf = ref.watch(savedShelfProvider).asData?.value;

    return ProfileEntryCard(
      art: IconMark(
        AppIcon.bookmark,
        active: true,
        size: _markSize,
        color: context.mood.accent,
      ),
      kicker: context.strings.savedEntryTitle,
      title: context.strings.savedEntrySubtitle,
      // The design's line, which counts plainly. The shelf's own header adds
      // the free cap ("3 of 5 saved") because that is where the cap is acted
      // on; repeating it here would put the paywall on a page that has no slot
      // for one.
      support: shelf == null
          ? ''
          : context.strings.savedEntryCount(savedShelfCount(shelf)),
      onTap: () => context.pushNamed(AppRoutes.saved.name),
    );
  }
}
