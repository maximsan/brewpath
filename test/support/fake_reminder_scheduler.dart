import 'package:brew_path/services/reminders/reminder_scheduler.dart';

/// A [ReminderScheduler] that records what it was asked to hold.
class FakeReminderScheduler implements ReminderScheduler {
  FakeReminderScheduler({this.answer = ReminderPermission.granted});

  /// What both permission calls report.
  ReminderPermission answer;

  /// The instants of the most recent `replaceAll`.
  List<DateTime> pending = [];

  /// The words the most recent `replaceAll` carried.
  String? title;
  String? body;

  /// How many times the learner was asked, and sent to iOS Settings.
  int requests = 0;
  int settingsOpened = 0;

  /// Every `replaceAll` in order, so a test can see a clear-then-post.
  final List<List<DateTime>> writes = [];

  /// Parks every permission read until it completes, so a test can hold one
  /// refresh open and start another.
  Future<void>? pause;

  /// Thrown instead of answering, so a failed run can be exercised.
  Error? failure;

  @override
  Future<ReminderPermission> permission() async {
    await pause;
    if (failure case final thrown?) throw thrown;
    return answer;
  }

  @override
  Future<ReminderPermission> request() async {
    requests++;
    return answer;
  }

  @override
  Future<void> replaceAll(
    List<DateTime> at, {
    required String title,
    required String body,
  }) async {
    pending = at;
    this.title = title;
    this.body = body;
    writes.add(at);
  }

  @override
  Future<void> openSystemSettings() async => settingsOpened++;
}
