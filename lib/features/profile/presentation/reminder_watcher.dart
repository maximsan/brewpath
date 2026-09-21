import 'dart:async';

import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/features/profile/domain/reminder_actions.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keeps the OS's pending reminders in step with the app.
///
/// Five moments reach it: a cold start, a resume, the day turning over, a
/// completed activity, and either settings row changing. The cold start and
/// the resume are what a reboot, an upgrade and a timezone change come back
/// through. A widget, not a provider: a read that writes is a side effect.
class ReminderWatcher extends ConsumerStatefulWidget {
  /// Creates a [ReminderWatcher].
  const ReminderWatcher({required this.child, super.key});

  /// The app this wraps.
  final Widget child;

  @override
  ConsumerState<ReminderWatcher> createState() => _ReminderWatcherState();
}

class _ReminderWatcherState extends ConsumerState<ReminderWatcher> {
  AppLifecycleListener? _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _refresh);
    _refresh();
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }

  /// Queues a refresh. The refresher runs them one at a time, so nothing here
  /// has to wait for the one before it.
  void _refresh() => unawaited(refreshRemindersQuietly(ref));

  @override
  Widget build(BuildContext context) {
    // The reminder skips a day the learner has already practised on, so a
    // completed activity and a day turning over both move what is pending.
    ref
      ..listen(currentDayProvider, (_, _) => _refresh())
      ..listen(activeDaySetProvider, (_, _) => _refresh())
      ..listen(settingsControllerProvider, (_, _) => _refresh());
    return widget.child;
  }
}
