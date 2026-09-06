import 'dart:async';

import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/core/widgets/sub_screen_scaffold.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree.dart';
import 'package:brew_path/features/studio/domain/grove_draft.dart';
import 'package:brew_path/features/studio/domain/grove_swatch.dart';
import 'package:brew_path/features/studio/domain/plant_grove.dart';
import 'package:brew_path/features/studio/domain/studio_providers.dart';
import 'package:brew_path/features/studio/presentation/widgets/light_pill.dart';
import 'package:brew_path/features/studio/presentation/widgets/plant_row.dart';
import 'package:brew_path/features/studio/presentation/widgets/spec_strip.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The loading placeholder's footprint, so the screen does not jump when
/// the banks arrive.
const double _spinnerSize = 48;

/// Height the previewed plant is drawn at, full-grown.
const double _previewSize = 176;

/// The stage the preview shows: harvest, so a learner is choosing the plant
/// they will end up with rather than the seedling they start as.
const int _previewStage = 10;

/// The promise under the confirm, which is the answer to "does picking a
/// slower-looking plant cost me anything".
const String _promise =
    'Every plant grows through all ten stages, seed to harvest.';

/// Copy on the confirm, which names the state rather than only the action.
const String _plantLabel = 'Plant in my grove';
const String _plantedLabel = 'Already planted';

/// Where the design opens this page, measured from the top of the screen.
///
/// 100 rather than 108, for the same reason it carries no large title: the
/// preview of the plant is what is at the top.
const double _designScrollPad = 100;

/// Your grove: the plant, the light it stands in, and one confirm.
///
/// The draft is local until confirmed, so backing out changes nothing —
/// `plantGrove` is the feature's only write.
class StudioScreen extends ConsumerStatefulWidget {
  /// Creates a [StudioScreen].
  const StudioScreen({super.key});

  @override
  ConsumerState<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends ConsumerState<StudioScreen> {
  GroveDraft? _draft;

  @override
  Widget build(BuildContext context) {
    final grove = ref.watch(studioGroveProvider);

    // No `PageLargeTitle`: the design opens this screen on the live preview of
    // the plant being chosen and names it at the title step under that, so
    // there is no display-size heading for the bar to take over from.
    return SubScreenScaffold(
      title: 'Your grove',
      designScrollPad: _designScrollPad,
      body: (context, scrollPadding) => grove.when(
        loading: () => const Center(
          child: _Loading(),
        ),
        error: (_, _) => Center(
          child: Semantics(
            label: 'Your grove could not be loaded',
            child: Text(
              'Your grove could not be loaded.',
              style: AppText.body(mood: context.mood),
            ),
          ),
        ),
        data: (bank) => _Chooser(
          scrollPadding: scrollPadding,
          bank: bank,
          draft: _draft ??= GroveDraft.of(bank.planted),
          onDraft: (next) => setState(() => _draft = next),
          onPlant: () => _plant(bank.planted),
        ),
      ),
    );
  }

  Future<void> _plant(Grove planted) async {
    final draft = _draft;
    if (draft == null || !draft.isDirtyAgainst(planted)) return;

    await plantGrove(
      ref.read(snapshotRepositoryProvider),
      grove: draft.grove,
      now: DateTime.now(),
    );
    // The hero on Profile reads the treatment, so it has to be re-derived —
    // the write went to storage, not to a provider anything is watching.
    ref
      ..invalidate(studioGroveProvider)
      ..invalidate(groveTreatmentProvider);
    if (mounted) unawaited(Navigator.of(context).maybePop());
  }
}

/// The grove while its banks are still arriving.
///
/// A labelled, fixed-size hole rather than a spinner: the screen is a single
/// read that resolves in a frame or two, and a spinner that flashes is worse
/// than a gap that does not move. The label is what a screen reader needs.
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading your grove',
    child: const SizedBox.square(dimension: _spinnerSize),
  );
}

class _Chooser extends StatelessWidget {
  const _Chooser({
    required this.scrollPadding,
    required this.bank,
    required this.draft,
    required this.onDraft,
    required this.onPlant,
  });

  /// The room the bar floating over this list leaves at the top.
  final EdgeInsets scrollPadding;

  final StudioGrove bank;
  final GroveDraft draft;
  final ValueChanged<GroveDraft> onDraft;
  final VoidCallback onPlant;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final variety = bank.varietyOf(draft.variety);
    final dirty = draft.isDirtyAgainst(bank.planted);

    return ListView(
      padding: scrollPadding.copyWith(bottom: AppSpacing.xl),
      children: [
        SizedBox(
          height: _previewSize,
          child: Center(
            child: CoffeeTree(
              stage: _previewStage,
              treatment: bank.treatmentFor(draft.variety, draft.light),
              // Frozen, as the Profile hero is: this is a picture of what the
              // learner is choosing, and a permanent sway on a chooser reads
              // as the screen still working rather than as the plant living.
              animate: false,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(variety.name, style: AppText.title(mood: mood)),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                variety.latin,
                style: AppText.support(mood: mood, face: AppFace.mono),
              ),
              const SizedBox(height: AppSpacing.md),
              SpecRow(label: 'Share of cups', value: variety.share),
              SpecRow(label: 'Home', value: variety.origin),
              SpecRow(label: 'Grows', value: variety.grows),
              SpecRow(label: 'Tastes like', value: variety.cup, last: true),
              const SizedBox(height: AppSpacing.base),
              Text(
                variety.tell,
                style: AppText.body(mood: mood, color: mood.inkMute),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SmallcapsLabel('PLANT'),
              const SizedBox(height: AppSpacing.sm),
              for (final option in bank.varieties) ...[
                PlantRow(
                  variety: option,
                  treatment: bank.treatmentFor(option.id, draft.light),
                  selected: option.id == draft.variety,
                  onSelect: () => onDraft(draft.withVariety(option.id)),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              const SizedBox(height: AppSpacing.base),
              const SmallcapsLabel('LIGHT'),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final light in bank.lights)
                    LightPill(
                      light: light,
                      swatch: swatchColor(light.swatch) ?? mood.rule,
                      selected: light.id == draft.light,
                      onSelect: () => onDraft(draft.withLight(light.id)),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: dirty ? _plantLabel : _plantedLabel,
                onPressed: dirty ? onPlant : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _promise,
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
