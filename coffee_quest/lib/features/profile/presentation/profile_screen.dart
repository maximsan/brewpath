import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:coffee_quest/core/constants/app_strings.dart';
import 'package:coffee_quest/core/widgets/section_header.dart';
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
          const SectionHeader('Your stats'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.bolt,
                  label: 'Total XP',
                  value: '${xp.asData?.value ?? 0}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '${streak.asData?.value ?? 0} days',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  label: 'Lessons',
                  value: '${lessons.asData?.value.length ?? 0}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.style,
                  label: 'Cards',
                  value: '${cards.asData?.value.length ?? 0}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader('Settings'),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: settings.when(
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
          ),
          const SizedBox(height: 24),
          const SectionHeader('About'),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Version'),
              trailing: Text(version.asData?.value ?? '—'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact stat card: icon badge + label + bold value, used in the 2×2 grid
/// at the top of the Profile screen.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: colors.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
