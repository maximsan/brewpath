import 'package:brew_path/core/widgets/app_sheet.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/features/mini_games/domain/teaching_module.dart';
import 'package:brew_path/shared/models/content/mini_game_format.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What a locked mini-game offers instead of refusing.
///
/// A learner who reached for this game by name, on a topic they wanted, is at
/// the highest intent the app ever sees. The sheet answers the question they
/// actually have — *why can't I play this, and what would open it* — by naming
/// the module that teaches the game's topic and pitching **that module**, not
/// the game. Nobody buys a two-minute quiz.
///
/// The pitch is the module's own reward summary, which is where the course
/// already says what the module is for; writing a second sentence here is how
/// two descriptions of one module start disagreeing.
Future<void> showMiniGameGateSheet({
  required BuildContext context,
  required MiniGameFormat format,
}) => showAppSheet<void>(
  context: context,
  // The game is what the learner reached for, so it is the sheet's name. The
  // design prints the module attribution *above* the title; the shared sheet
  // primitive owns the heading slot and the rule that every sheet opens on its
  // title, so the attribution leads the body instead.
  title: format.title,
  builder: (context) => _GateBody(moduleId: format.moduleId),
);

class _GateBody extends ConsumerWidget {
  const _GateBody({required this.moduleId});

  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final module = ref.watch(teachingModuleProvider(moduleId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.sm),
        switch (module) {
          AsyncData(:final value?) => _Pitch(module: value),
          AsyncError() => const _FallbackPitch(),
          // The bank is bundled, so this resolves within a frame; a spinner
          // would flash rather than inform.
          _ => const _FallbackPitch(),
        },
        const SizedBox(height: AppSpacing.lg),
        // A ghost, not a text button. The design system is explicit that a
        // dismiss of this kind — it names *Not now* among its examples — is
        // *"a ghost, never a bare link"*; a link is reserved for tertiary
        // actions inline in running content.
        GhostButton(
          label: 'Not now',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// The module attribution and the module's own words.
class _Pitch extends StatelessWidget {
  const _Pitch({required this.module});

  final ModuleModel module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'TAUGHT IN MODULE ${module.n} · ${module.label}',
          // A meta line rather than a kicker — it names where the game is
          // taught and carries a figure — so it takes the design's 0.08em
          // instead of the rung's smallcaps 0.14em.
          style: AppText.label(
            color: mood.accentText,
            face: AppFace.mono,
            tracking: AppTracking.meta,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          module.reward.summary,
          style: theme.textTheme.bodyMedium?.copyWith(color: mood.inkMute),
        ),
      ],
    );
  }
}

/// Shown when the catalog names a module the bank does not carry — the sheet
/// still has to say something true rather than open empty.
class _FallbackPitch extends StatelessWidget {
  const _FallbackPitch();

  @override
  Widget build(BuildContext context) => Text(
    'This game comes with the full course.',
    style: Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: context.mood.inkMute),
  );
}
