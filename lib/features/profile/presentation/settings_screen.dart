import 'dart:async';

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/onboarding/presentation/onboarding_providers.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/profile/presentation/widgets/appearance_selector.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Dedicated Settings screen reached via the gear icon on Profile. Hosts the
/// app-wide preferences (haptics, sound), the destructive reset action, and
/// the version footer.
class SettingsScreen extends ConsumerWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final version = ref.watch(appVersionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const IconMark(AppIcon.back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const _SectionLabel('Preferences'),
          settings.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) =>
                Padding(padding: const EdgeInsets.all(16), child: Text('$e')),
            data: (s) => Column(
              children: [
                SwitchListTile(
                  title: const Text('Haptics'),
                  subtitle: const Text('Subtle vibrations on taps and answers'),
                  value: s.hapticsEnabled,
                  onChanged: (_) => ref
                      .read(settingsControllerProvider.notifier)
                      .toggleHaptics(),
                ),
                SwitchListTile(
                  title: const Text('Sound'),
                  subtitle: const Text(
                    'Audio feedback for lessons and mini-games',
                  ),
                  value: s.soundEnabled,
                  onChanged: (_) => ref
                      .read(settingsControllerProvider.notifier)
                      .toggleSound(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Appearance'),
          const AppearanceSelector(),
          const SizedBox(height: 24),
          const _SectionLabel('Onboarding'),
          const _ResetOnboardingTile(),
          const SizedBox(height: 24),
          const _SectionLabel('Danger zone'),
          const _ResetProgressTile(),
          const SizedBox(height: 24),
          const _SectionLabel('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            trailing: Text(version.asData?.value ?? '—'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  static const double _letterSpacing = 1.2;

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: context.mood.inkMute,
          letterSpacing: _letterSpacing,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ResetProgressTile extends ConsumerWidget {
  const _ResetProgressTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = context.mood;
    return ListTile(
      leading: IconMark(AppIcon.rematch, color: mood.berry),
      title: Text(
        'Reset Progress',
        style: TextStyle(color: mood.berry, fontWeight: FontWeight.w600),
      ),
      subtitle: const Text(
        'Clear completed lessons, points, streak, and unlocked cards.',
      ),
      trailing: IconMark(AppIcon.chevron, color: mood.berry),
      onTap: () => _confirmAndReset(context, ref),
    );
  }

  Future<void> _confirmAndReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset all progress?'),
        content: const Text(
          'This will remove your completed lessons, points, streak, '
          'unlocked cards, and all local progress. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: ctx.mood.berry,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final mood = context.mood;
    await resetProgress(ref);
    messenger
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          content: const Text('Progress reset.'),
          leading: IconMark(AppIcon.check, color: mood.accent),
          backgroundColor: mood.surface,
          actions: [
            TextButton(
              onPressed: messenger.hideCurrentMaterialBanner,
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
    Timer(const Duration(seconds: 2), messenger.hideCurrentMaterialBanner);
  }
}

/// Clears the onboarding gate and returns the user to the Welcome screen so
/// they can pick a different goal/brewer. Lesson XP, streak, and collected
/// cards are not affected — use the "Reset Progress" action below for that.
class _ResetOnboardingTile extends ConsumerWidget {
  const _ResetOnboardingTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const IconMark(AppIcon.rematch),
      title: const Text('Restart onboarding'),
      subtitle: const Text('Take the Welcome tour again. Your progress stays.'),
      trailing: const IconMark(AppIcon.chevron),
      onTap: () => _confirmAndReset(context, ref),
    );
  }

  Future<void> _confirmAndReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restart onboarding?'),
        content: const Text(
          "You'll go back through the Welcome screen and pick your goal and "
          'brewer again. Your points, streak, and collected cards stay as they '
          'are.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restart'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await ref.read(onboardingRepositoryProvider).resetOnboarding();
    ref.invalidate(onboardingCompletedProvider);
    if (!context.mounted) return;
    context.goNamed(AppRoutes.welcome.name);
  }
}
