import 'package:brew_path/services/reminders/reminder_scheduler.dart';
import 'package:collection/collection.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// The shipping scheduler: iOS local notifications via
/// `flutter_local_notifications`.
///
/// Every reminder it posts is a one-shot at an absolute local time, so a day
/// already practised on can be left out — which a repeating request cannot do.
class LocalNotificationsReminderScheduler implements ReminderScheduler {
  /// Creates a scheduler over [plugin], or over a plugin of its own.
  LocalNotificationsReminderScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// The first id the reminders own. Ids outside the band are somebody else's
  /// and are never cancelled here.
  static const idBase = 443000;

  /// How many ids the band holds — iOS's own pending limit, and more than the
  /// horizon ever plans, so a shortened plan still clears what a longer one
  /// left behind.
  static const idCount = 64;

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void>? _ready;

  /// What this process last put in front of the OS.
  ///
  /// Only an optimisation, and deliberately per-process: a cold start starts
  /// with no memory, which is what makes the launch re-assertion real after a
  /// reboot, an upgrade or anything else that could have lost the schedule.
  List<DateTime>? _posted;

  ReminderPermission? _lastAnswer;

  @override
  Future<ReminderPermission> permission() async {
    await _ensureReady();
    final ios = _ios;
    if (ios == null) return ReminderPermission.unsupported;

    final options = await ios.checkPermissions();
    final answer = (options?.isEnabled ?? false)
        ? ReminderPermission.granted
        : ReminderPermission.denied;

    // An answer that moved means the learner has been in iOS Settings, where
    // what the OS still holds is not ours to assume. Forget what we posted, so
    // the next plan is posted afresh rather than skipped as unchanged.
    if (_lastAnswer != null && answer != _lastAnswer) _posted = null;
    _lastAnswer = answer;

    return answer;
  }

  @override
  Future<ReminderPermission> request() async {
    await _ensureReady();
    final ios = _ios;
    if (ios == null) return ReminderPermission.unsupported;

    final granted = await ios.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return (granted ?? false)
        ? ReminderPermission.granted
        : ReminderPermission.denied;
  }

  @override
  Future<void> replaceAll(
    List<DateTime> at, {
    required String title,
    required String body,
  }) async {
    await _ensureReady();

    // Re-checked against the clock rather than trusted from the plan: the plan
    // was computed before the awaits above, and the plugin rejects an instant
    // already gone.
    final now = DateTime.now();
    final upcoming = at.where(now.isBefore).take(idCount).toList();
    if (const ListEquality<DateTime>().equals(_posted, upcoming)) return;

    await _cancelOurs();
    if (upcoming.isEmpty) {
      _posted = upcoming;
      return;
    }

    // Read per call, never cached: the zone the trigger is built in is the
    // zone it fires in, so a learner who has flown has to be re-posted in the
    // one they are now.
    final zone = tz.getLocation(
      (await FlutterTimezone.getLocalTimezone()).identifier,
    );

    for (var index = 0; index < upcoming.length; index++) {
      await _plugin.zonedSchedule(
        id: idBase + index,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(upcoming[index], zone),
        notificationDetails: const NotificationDetails(
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
    // Last, so a posting that threw part-way leaves a memory that does not
    // match the plan — and the next refresh posts it again.
    _posted = upcoming;
  }

  @override
  Future<void> openSystemSettings() async {
    await _ensureReady();
    await _ios?.openAppNotificationSettings();
  }

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  /// Loads the timezone database and initialises the plugin, once.
  Future<void> _ensureReady() => _ready ??= _initialize();

  Future<void> _initialize() async {
    tz_data.initializeTimeZones();

    // Every `request*` off: initialising must not put a permission prompt in
    // front of a learner who has not asked for a reminder.
    await _plugin.initialize(
      settings: const InitializationSettings(
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  Future<void> _cancelOurs() async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      if (request.id >= idBase && request.id < idBase + idCount) {
        await _plugin.cancel(id: request.id);
      }
    }
  }
}
