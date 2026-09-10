import 'dart:async';

import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/sub_screen_scaffold.dart';
import 'package:brew_path/features/companion/application/companion_outfit.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/studio/domain/companion_draft.dart';
import 'package:brew_path/features/studio/domain/dress_companion.dart';
import 'package:brew_path/features/studio/domain/roasty_studio_providers.dart';
import 'package:brew_path/features/studio/presentation/widgets/companion_option_row.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The loading placeholder's footprint, so the screen does not jump when the
/// banks arrive.
const double _spinnerSize = 48;

/// The preview's height, at the design's 128 with room for the sprout above.
const double _previewSize = 128;

/// Copy on the confirm, which names the state rather than only the action.
const String _applyLabel = 'Apply look';
const String _appliedLabel = 'Looking sharp';

/// Where the design opens this page, measured from the top of the screen.
///
/// 100 rather than 108, for the same reason the grove carries no large title:
/// the live preview of the mascot is what is at the top.
const double _designScrollPad = 100;

/// Dress up Roasty: four axes, a live preview, and one confirm.
///
/// The grove chooser's sibling, and built the same way — the draft is local
/// until confirmed, so backing out changes nothing and `dressCompanion` is the
/// feature's only write.
class RoastyStudioScreen extends ConsumerStatefulWidget {
  /// Creates a [RoastyStudioScreen].
  const RoastyStudioScreen({super.key});

  @override
  ConsumerState<RoastyStudioScreen> createState() => _RoastyStudioScreenState();
}

class _RoastyStudioScreenState extends ConsumerState<RoastyStudioScreen> {
  CompanionDraft? _draft;

  @override
  Widget build(BuildContext context) {
    final studio = ref.watch(roastyStudioProvider);

    return SubScreenScaffold(
      title: 'Dress up Roasty',
      designScrollPad: _designScrollPad,
      body: (context, scrollPadding) => studio.when(
        loading: () => const Center(child: _Loading()),
        error: (_, _) => Center(
          child: Semantics(
            label: 'The wardrobe could not be loaded',
            child: Text(
              'The wardrobe could not be loaded.',
              style: AppText.body(mood: context.mood),
            ),
          ),
        ),
        data: (bank) => _Wardrobe(
          scrollPadding: scrollPadding,
          bank: bank,
          draft: _draft ??= CompanionDraft.of(bank.worn),
          onDraft: (next) => setState(() => _draft = next),
          onApply: () => _apply(bank.worn),
        ),
      ),
    );
  }

  Future<void> _apply(CompanionConfig worn) async {
    final draft = _draft;
    if (draft == null || !draft.isDirtyAgainst(worn)) return;

    await dressCompanion(
      ref.read(snapshotRepositoryProvider),
      outfit: draft.outfit,
      now: DateTime.now(),
    );
    // Every Roasty in the app reads the scope the app root feeds from this,
    // so the write only reaches the screens once it is re-derived.
    ref
      ..invalidate(roastyStudioProvider)
      ..invalidate(companionOutfitProvider);
    if (mounted) unawaited(Navigator.of(context).maybePop());
  }
}

/// The wardrobe while its banks are still arriving — a labelled, fixed-size
/// hole rather than a spinner, as the grove chooser uses.
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading the wardrobe',
    child: const SizedBox.square(dimension: _spinnerSize),
  );
}

class _Wardrobe extends StatelessWidget {
  const _Wardrobe({
    required this.scrollPadding,
    required this.bank,
    required this.draft,
    required this.onDraft,
    required this.onApply,
  });

  /// The room the bar floating over this list leaves at the top.
  final EdgeInsets scrollPadding;

  final RoastyStudio bank;
  final CompanionDraft draft;
  final ValueChanged<CompanionDraft> onDraft;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final dirty = draft.isDirtyAgainst(bank.worn);

    return ListView(
      padding: scrollPadding.copyWith(bottom: AppSpacing.xl),
      children: [
        SizedBox(
          height: _previewSize * roastyAspect,
          child: Center(
            child: Roasty(
              state: RoastyState.idle,
              size: _previewSize,
              // The one Roasty in the app that is told what to wear: it shows
              // the draft, which is not what anything else should be drawing.
              outfit: draft.outfit,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompanionOptionRow(
                label: 'Roast',
                options: bank.options.roasts,
                value: draft.roast,
                onSelect: (id) => onDraft(draft.withRoast(id)),
              ),
              CompanionOptionRow(
                label: 'Hat',
                options: bank.options.hats,
                value: draft.hat,
                onSelect: (id) => onDraft(draft.withHat(id)),
              ),
              CompanionOptionRow(
                label: 'Accessory',
                options: bank.options.gear,
                value: draft.gear,
                onSelect: (id) => onDraft(draft.withGear(id)),
              ),
              CompanionOptionRow(
                label: 'Sprout',
                options: bank.options.sprouts,
                value: draft.sprout,
                onSelect: (id) => onDraft(draft.withSprout(id)),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: dirty ? _applyLabel : _appliedLabel,
                onPressed: dirty ? onApply : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Roasty wears this everywhere in the app.',
                textAlign: TextAlign.center,
                style: AppText.support(mood: mood, color: mood.inkMute),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
