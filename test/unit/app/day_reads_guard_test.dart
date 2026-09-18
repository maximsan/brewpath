import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../support/dart_sources.dart';

/// Source with comments removed, so prose about `DateTime.now()` does not read
/// as a call to it.
String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
    .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), '');

List<File> _dartFilesUnder(String directory) =>
    dartSourcesUnder(directory).toList();

/// The index just past the `)` closing the parameter list that starts at
/// [open], so a signature's own parentheses cannot end it early.
int _closingParen(String code, int open) {
  var depth = 0;
  for (var index = open; index < code.length; index++) {
    if (code[index] == '(') depth++;
    if (code[index] == ')') {
      depth--;
      if (depth == 0) return index + 1;
    }
  }
  return code.length;
}

/// The body that follows a signature ending at [start] — brace-matched for a
/// block body, read to the terminating `;` for an arrow one.
String _bodyAfter(String code, int start) {
  final brace = code.indexOf('{', start);
  final semicolon = code.indexOf(';', start);
  final isArrow = brace == -1 || (semicolon != -1 && semicolon < brace);
  if (isArrow) {
    return semicolon == -1 ? '' : code.substring(start, semicolon);
  }

  var depth = 0;
  for (var index = brace; index < code.length; index++) {
    if (code[index] == '{') depth++;
    if (code[index] == '}') {
      depth--;
      if (depth == 0) return code.substring(brace, index + 1);
    }
  }
  return code.substring(brace);
}

/// Every `build(...)` body in [code] — a widget's own, and any `.build(` call
/// site, which over-collects rather than under-collects.
Iterable<String> _buildBodies(String code) sync* {
  for (final match in RegExp(r'\bbuild\s*\(').allMatches(code)) {
    yield _bodyAfter(code, _closingParen(code, match.end - 1));
  }
}

void main() {
  group('a calendar-day decision never reads the clock at build time', () {
    test('no build() method under lib/features/ calls DateTime.now()', () {
      final offenders = <String>[];
      for (final file in _dartFilesUnder('lib/features')) {
        final bodies = _buildBodies(_code(file.path));
        if (bodies.any((body) => body.contains('DateTime.now()'))) {
          offenders.add(file.path);
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'a build() that reads the clock is only as fresh as its last '
            'build, and shows yesterday to an app left open across midnight. '
            'Watch currentDayProvider, or take the day as a parameter — #202',
      );
    });

    test('no provider or watcher under lib/features/ reads the clock', () {
      final offenders = _dartFilesUnder('lib/features')
          .where(
            (file) =>
                file.path.endsWith('_providers.dart') ||
                file.path.endsWith('_watcher.dart'),
          )
          .where((file) => _code(file.path).contains('DateTime.now()'))
          .map((file) => file.path)
          .toList();

      expect(
        offenders,
        isEmpty,
        reason:
            'these decide what is true *now* away from any tap — a provider '
            'as it rebuilds, a watcher on resume or at midnight. Reading the '
            'clock directly puts a second opinion beside appClockProvider, '
            'and no test can pin it — #202',
      );
    });
  });

  test('nothing in lib/app reads the clock but the clock itself', () {
    final offenders = _dartFilesUnder('lib/app')
        .where((file) => _code(file.path).contains('DateTime.now()'))
        .map((file) => file.path)
        .toList();

    // `DateTime.now` as a tear-off is the seam being handed on, not a read:
    // `appClock` returns it, and `DayRolloverWatcher` defaults to it.
    expect(
      offenders,
      isEmpty,
      reason: 'the app layer hands the clock on; it does not call it',
    );
  });
}
