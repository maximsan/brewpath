import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/features/profile/domain/reminder_sync.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/services/reminders/reminder_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reminder_refresher.g.dart';

/// Runs the reminder refreshes one at a time.
///
/// The settings rows and the watcher both refresh, and they overlap: one that
/// read the old preference would post its plan on top of the clear that
/// followed it, and the learner would keep getting a reminder they had just
/// switched off. Each run re-reads, so the last queued one stands.
class ReminderRefresher {
  /// Creates a refresher that reads through `ref`.
  ReminderRefresher(this._ref);

  final Ref _ref;

  Future<void> _queue = Future<void>.value();

  /// Queues a refresh, and resolves with what it found.
  Future<ReminderSyncOutcome> refresh() {
    final next = _queue.then((_) => _run());
    // A failed run must not leave the queue broken for the next one.
    _queue = next.then((_) {}, onError: (_) {});
    return next;
  }

  Future<ReminderSyncOutcome> _run() async {
    if (!_ref.mounted) return ReminderSyncOutcome.gone;

    final settings = await _ref.read(settingsControllerProvider.future);
    if (!_ref.mounted) return ReminderSyncOutcome.gone;

    final outcome = await syncReminders(
      _ref.read(reminderSchedulerProvider),
      setting: (
        enabled: settings.notificationsEnabled,
        time: settings.dailyReminderTime,
      ),
      activeDays: await _ref.read(activeDaySetProvider.future),
      now: _ref.read(appClockProvider)(),
    );

    if (outcome == ReminderSyncOutcome.permissionLost && _ref.mounted) {
      await _ref
          .read(settingsControllerProvider.notifier)
          .setNotificationsEnabled(enabled: false);
    }

    return outcome;
  }
}

/// The app's one refresher.
///
/// Kept alive because the queue is what makes two refreshes safe; a refresher
/// that came and went would be no queue at all.
@Riverpod(keepAlive: true)
ReminderRefresher reminderRefresher(Ref ref) => ReminderRefresher(ref);
