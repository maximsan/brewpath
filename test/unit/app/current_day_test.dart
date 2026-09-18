import 'package:brew_path/app/current_day.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// One seam, two appetites: the calendar day settles on an answer and holds it
// until the rollover, while a caller that wants the moment calls the clock
// itself. Both come from appClockProvider, so a test moves them together.
void main() {
  ProviderContainer containerAt(DateTime Function() clock) {
    final container = ProviderContainer(
      overrides: [appClockProvider.overrideWithValue(clock)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('the day is the clock with its time of day dropped', () {
    final container = containerAt(() => DateTime(2026, 8, 20, 23, 55, 12));

    expect(container.read(currentDayProvider), DateTime(2026, 8, 20));
  });

  test('the day holds its answer until it is refreshed', () {
    var now = DateTime(2026, 8, 20, 23, 55);
    final container = containerAt(() => now);
    expect(container.read(currentDayProvider), DateTime(2026, 8, 20));

    now = DateTime(2026, 8, 21, 0, 5);

    // What every surface derived against today relies on: they agree, because
    // the day does not move under them between rollovers.
    expect(container.read(currentDayProvider), DateTime(2026, 8, 20));
  });

  test('refreshing it across midnight moves the day', () {
    var now = DateTime(2026, 8, 20, 23, 55);
    final container = containerAt(() => now);
    container.read(currentDayProvider);

    now = DateTime(2026, 8, 21, 0, 5);
    container.invalidate(currentDayProvider);

    expect(container.read(currentDayProvider), DateTime(2026, 8, 21));
  });

  test('a refresh inside one day notifies nobody', () {
    var now = DateTime(2026, 8, 20, 9);
    final container = containerAt(() => now);
    var notifications = 0;
    container.listen(currentDayProvider, (_, _) => notifications++);
    container.read(currentDayProvider);

    now = DateTime(2026, 8, 20, 17, 30);
    container.invalidate(currentDayProvider);
    container.read(currentDayProvider);

    // What keeps a resume cheap: the day recomputes to an equal value, and
    // Riverpod does not wake the surfaces derived against it.
    expect(notifications, 0);
  });

  test('a refresh that crosses midnight does notify', () {
    var now = DateTime(2026, 8, 20, 23, 55);
    final container = containerAt(() => now);
    var notifications = 0;
    container.listen(currentDayProvider, (_, _) => notifications++);
    container.read(currentDayProvider);

    now = DateTime(2026, 8, 21, 0, 5);
    container.invalidate(currentDayProvider);
    container.read(currentDayProvider);

    expect(notifications, 1);
  });

  test('the clock itself answers the moment, every time it is called', () {
    var now = DateTime(2026, 8, 20, 9);
    final container = containerAt(() => now);
    final clock = container.read(appClockProvider);
    expect(clock(), DateTime(2026, 8, 20, 9));

    now = DateTime(2026, 8, 20, 17, 30);

    // No invalidation: a window measured in elapsed hours must not be able to
    // read an instant the app settled on earlier.
    expect(clock(), DateTime(2026, 8, 20, 17, 30));
  });
}
