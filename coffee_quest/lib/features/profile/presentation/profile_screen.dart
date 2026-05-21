import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:coffee_quest/core/constants/app_strings.dart';
import 'package:coffee_quest/features/profile/domain/settings_providers.dart';
import 'package:coffee_quest/features/progress/domain/progress_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(totalXpProvider);
    final streak = ref.watch(streakProvider);
    final lessons = ref.watch(completedLessonsProvider);
    final cards = ref.watch(collectedCardsProvider);
    final settings = ref.watch(settingsControllerProvider);
    final version = ref.watch(appVersionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tabProfile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatTile(
            icon: Icons.bolt,
            label: 'Total XP',
            value: '${xp.asData?.value ?? 0}',
          ),
          _StatTile(
            icon: Icons.local_fire_department,
            label: 'Streak',
            value: '${streak.asData?.value ?? 0} days',
          ),
          _StatTile(
            icon: Icons.check_circle,
            label: 'Lessons completed',
            value: '${lessons.asData?.value.length ?? 0}',
          ),
          _StatTile(
            icon: Icons.style,
            label: 'Cards collected',
            value: '${cards.asData?.value.length ?? 0}',
          ),
          const Divider(height: 32),
          Text('Settings', style: Theme.of(context).textTheme.titleMedium),
          settings.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('$e'),
            data: (s) => Column(
              children: [
                SwitchListTile(
                  title: const Text('Haptics'),
                  value: s.hapticsEnabled,
                  onChanged: (_) => ref
                      .read(settingsControllerProvider.notifier)
                      .toggleHaptics(),
                ),
                SwitchListTile(
                  title: const Text('Sound'),
                  value: s.soundEnabled,
                  onChanged: (_) => ref
                      .read(settingsControllerProvider.notifier)
                      .toggleSound(),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
