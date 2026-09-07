import 'package:flutter_test/flutter_test.dart';

import '../../support/dart_sources.dart';

void main() {
  group('commentsIn', () {
    test('collects line and block comments whole, in order', () {
      const source =
          '// first\nfinal x = 1; /* second\nspans */ final y;\n'
          '/// third\n';

      expect(commentsIn(source), [
        '// first',
        '/* second\nspans */',
        '/// third',
      ]);
    });

    test('nests block comments the way Dart does', () {
      const source = '/* outer /* inner */ still outer */ code';

      expect(commentsIn(source), ['/* outer /* inner */ still outer */']);
    });

    test('does not read a // inside a string literal as a comment', () {
      const source =
          "final url = 'https://example.test/page.html'; // trailing";

      expect(commentsIn(source), ['// trailing']);
    });

    test('skips raw, triple-quoted and interpolated strings whole', () {
      const source = r'''
final raw = r'// not \ a comment';
final triple = """
// not a comment either
""";
final nested = '${"//" + '/*'}';
// real
''';

      expect(commentsIn(source), ['// real']);
    });

    test('an escaped quote does not end the string', () {
      const source = r"final s = 'it\'s // fine'; // yes";

      expect(commentsIn(source), ['// yes']);
    });
  });

  group('withoutComments', () {
    test('drops comments and keeps every string literal', () {
      const source = "final url = 'http://a.b'; // gone\n/* gone */ final n;";

      expect(withoutComments(source), "final url = 'http://a.b'; \n final n;");
    });
  });
}
