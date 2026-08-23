import 'package:flutter_test/flutter_test.dart';

import '../support/dart_sources.dart';

/// `AnimatedSize` cannot be told to finish instantly.
///
/// Given `Duration.zero` it re-dirties itself inside its own `performLayout`,
/// which the framework asserts on — so a reduced-motion learner hits a crash
/// rather than a snappier animation. The honest reading of "no animation" is
/// **no animator**: branch on the setting and render the child directly.
///
/// A sweep is a one-off; this is the guard that keeps it swept. The pattern
/// was written twice — the dictionary's self-check shipped with it, and the
/// app header nearly did — which is one time more than a convention survives.
void main() {
  test('no file pairs AnimatedSize with a zero duration', () {
    final offenders = <String>[];
    for (final file in dartSourcesUnder('lib')) {
      // Comments stripped first: this guard fired on the doc comment
      // explaining the very bug it forbids, and a guard that cries wolf
      // on prose is one somebody eventually deletes.
      final source = withoutComments(file.readAsStringSync());
      if (source.contains('AnimatedSize') && source.contains('Duration.zero')) {
        offenders.add(file.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'AnimatedSize asserts when given Duration.zero. Branch on '
          'MediaQuery.disableAnimationsOf and render the child without the '
          'animator instead.',
    );
  });
}
