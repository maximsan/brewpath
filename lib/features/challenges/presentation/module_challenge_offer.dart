import 'package:brew_path/core/widgets/sticky_action_bar.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/challenge_offer_row.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The module's optional Coffee Challenge, offered where the module ends.
///
/// Renders **nothing at all** — no gap, no divider, no placeholder — when the
/// module has no capstone, when its lessons are not all finished, or when the
/// challenge is already in play or brewed. Most endings are one of those, so
/// the absent case is the common one and must leave no trace.
///
/// **The started state is checked before the offer is read**, deliberately.
/// Starting the challenge is exactly what stops it being live, so a row that
/// re-read the provider first would delete itself at the moment it finally has
/// something to say.
class ModuleChallengeOffer extends ConsumerStatefulWidget {
  /// Creates a [ModuleChallengeOffer].
  const ModuleChallengeOffer({required this.moduleId, super.key});

  /// The module whose capstone this offers.
  final String moduleId;

  @override
  ConsumerState<ModuleChallengeOffer> createState() =>
      _ModuleChallengeOfferState();
}

class _ModuleChallengeOfferState extends ConsumerState<ModuleChallengeOffer> {
  /// Whether the challenge is now on Today, put there from this row.
  ///
  /// Set **after** the write lands: the row says *Added to Today*, so a write
  /// that threw must leave the offer standing rather than a sentence claiming
  /// something that did not happen.
  bool _accepted = false;

  /// Whether a write is in flight — the guard that stops a second tap starting
  /// the same challenge twice before the first has landed.
  bool _starting = false;

  Future<void> _start(BrewChallenge challenge) async {
    if (_starting || _accepted) return;
    _starting = true;
    try {
      await startChallenge(
        ref.read(snapshotRepositoryProvider),
        id: challenge.id,
        now: DateTime.now(),
      );
    } finally {
      _starting = false;
    }
    if (!mounted) return;

    // Confirmed before the providers are invalidated, not after: accepting is
    // exactly what stops the offer being live, so a rebuild in between would
    // blank the row at the moment it has something to say.
    setState(() => _accepted = true);
    ref
      ..invalidate(activeChallengeProvider)
      ..invalidate(savedChallengesProvider);
  }

  @override
  Widget build(BuildContext context) {
    if (_accepted) return const _Slot(child: ChallengeStartedRow());

    final offer = ref
        .watch(liveModuleChallengeOfferProvider(widget.moduleId))
        .asData
        ?.value;
    if (offer == null) return const SizedBox.shrink();

    return _Slot(
      child: ChallengeOfferRow(
        challenge: offer,
        onStart: () => _start(offer),
      ),
    );
  }
}

/// The design's 16 px between the offer and the exit CTA, carried by the offer
/// because [StickyActionBar.preface] contributes none.
class _Slot extends StatelessWidget {
  const _Slot({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: child,
  );
}
