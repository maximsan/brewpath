import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:coffee_quest/features/onboarding/presentation/onboarding_providers.dart';
import 'package:coffee_quest/features/profile/domain/settings_providers.dart';

/// Dedicated Settings screen reached via the gear icon on Profile. Hosts the
/// app-wide preferences (haptics, sound), the destructive reset action, and
/// the version footer.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final version = ref.watch(appVersionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
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
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(Icons.restart_alt, color: colors.error),
      title: Text(
        'Reset Progress',
        style: TextStyle(color: colors.error, fontWeight: FontWeight.w600),
      ),
      subtitle: const Text(
        'Clear completed lessons, XP, streak, and unlocked cards.',
      ),
      trailing: Icon(Icons.chevron_right, color: colors.error),
      onTap: () => _confirmAndReset(context, ref),
    );
  }

  Future<void> _confirmAndReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset all progress?'),
        content: const Text(
          'This will remove your completed lessons, XP, streak, '
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
              foregroundColor: Theme.of(ctx).colorScheme.error,
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
    final colors = Theme.of(context).colorScheme;
    await resetProgress(ref);
    messenger
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          content: const Text('Progress reset.'),
          leading: Icon(Icons.check_circle, color: colors.primary),
          backgroundColor: colors.surfaceContainerHigh,
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
      leading: const Icon(Icons.replay_outlined),
      title: const Text('Restart onboarding'),
      subtitle: const Text('Take the Welcome tour again. Your progress stays.'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _confirmAndReset(context, ref),
    );
  }

  Future<void> _confirmAndReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Restart onboarding?'),
        content: const Text(
          'You\'ll go back through the Welcome screen and pick your goal and '
          'brewer again. Your XP, streak, and collected cards stay as they '
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
    context.go('/welcome');
  }
}
