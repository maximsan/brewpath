/// What the OS will let the app deliver.
enum ReminderPermission {
  /// The OS will deliver what is scheduled.
  granted,

  /// It will not — refused, revoked, or never asked on a platform that asks.
  denied,

  /// There is nothing to ask: this build has no notifications to schedule.
  unsupported,
}

/// Posts the daily reminder to the platform, and answers for the permission it
/// needs.
///
/// The one seam in front of `flutter_local_notifications` — feature code hands
/// it instants and never touches the plugin, the way payments, ads and the
/// share sheet are seamed.
abstract interface class ReminderScheduler {
  /// What the OS allows right now, asking the learner for nothing.
  Future<ReminderPermission> permission();

  /// Asks the learner for permission, and answers with what they decided.
  Future<ReminderPermission> request();

  /// Replaces everything this app has pending with one reminder at each of
  /// [at], each titled [title] and reading [body].
  ///
  /// An empty [at] leaves nothing pending, which is how the reminder is turned
  /// off.
  Future<void> replaceAll(
    List<DateTime> at, {
    required String title,
    required String body,
  });

  /// Opens the OS's notification settings for this app, so a refusal has a way
  /// back.
  Future<void> openSystemSettings();
}

/// A scheduler that schedules nothing — every platform but iOS, and the tests.
class NoOpReminderScheduler implements ReminderScheduler {
  /// Creates a [NoOpReminderScheduler].
  const NoOpReminderScheduler();

  @override
  Future<ReminderPermission> permission() async =>
      ReminderPermission.unsupported;

  @override
  Future<ReminderPermission> request() async => ReminderPermission.unsupported;

  @override
  Future<void> replaceAll(
    List<DateTime> at, {
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> openSystemSettings() async {}
}
