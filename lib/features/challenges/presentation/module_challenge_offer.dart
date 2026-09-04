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
  /// Whether the learner accepted the offer while this screen was open.
  ///
  /// Set before the write rather than after it, which is both the design's
  /// optimistic morph and the guard against a second tap starting the same
  /// challenge twice while the first write is still in flight.
  bool _accepted = false;

  Future<void> _start(BrewChallenge challenge) async {
    if (_accepted) return;
    setState(() => _accepted = true);

    await startChallenge(
      ref.read(snapshotRepositoryProvider),
      id: challenge.id,
      now: DateTime.now(),
    );
    if (!mounted) return;
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

/// The gap between the offer and the action under it.
///
/// Carried here rather than by the footer, which adds no spacer of its own: an
/// offer that renders nothing must leave nothing behind, and a gap the bar
/// contributed would show as a phantom band on every ending without one.
class _Slot extends StatelessWidget {
  const _Slot({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    // The design's 16 px between the offer and the exit CTA.
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: child,
  );
}
