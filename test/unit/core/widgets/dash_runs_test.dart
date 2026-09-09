import 'package:brew_path/core/widgets/dash_runs.dart';
import 'package:flutter_test/flutter_test.dart';

// The geometry behind every dashed line in the app. A pure function so the
// pattern can be checked at its edges without painting anything: the walk used
// to live inside a painter, where a run past the end of the line was invisible.
void main() {
  test('walks a line as dash, gap, dash', () {
    expect(dashRuns(14, dash: 5, gap: 4), [
      (from: 0.0, to: 5.0),
      (from: 9.0, to: 14.0),
    ]);
  });

  test('clips the last dash to the end of the line', () {
    final runs = dashRuns(12, dash: 5, gap: 4);

    expect(runs.last.to, 12.0, reason: 'a dash never overshoots the line');
    expect(runs.last.to - runs.last.from, lessThan(5.0));
  });

  test('a line shorter than one dash is a single run', () {
    expect(dashRuns(3, dash: 5, gap: 4), [(from: 0.0, to: 3.0)]);
  });

  test('a line with no length draws nothing', () {
    expect(dashRuns(0, dash: 5, gap: 4), isEmpty);
    expect(dashRuns(-1, dash: 5, gap: 4), isEmpty);
  });

  test('every gap between runs is the gap it was given', () {
    final runs = dashRuns(40, dash: 5, gap: 4);

    for (var index = 1; index < runs.length; index++) {
      expect(runs[index].from - runs[index - 1].to, 4.0);
    }
  });

  test('no run is longer than a dash, and none is empty', () {
    for (final run in dashRuns(37.5, dash: 5, gap: 4)) {
      expect(run.to - run.from, greaterThan(0));
      expect(run.to - run.from, lessThanOrEqualTo(5.0));
    }
  });

  test('a gap that would land exactly on the end draws no stub', () {
    // 5 dash, 4 gap, then the line ends: the walk must stop rather than emit a
    // zero-length run the painter would stroke as a dot.
    expect(dashRuns(9, dash: 5, gap: 4), [(from: 0.0, to: 5.0)]);
  });
}
