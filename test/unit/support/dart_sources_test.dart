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

  group('commentBlocksIn', () {
    test('groups line comments on consecutive lines into one block', () {
      const source = '/// a\n/// b\n  /// c\nclass A {}\n\n// d\n// e\n';

      expect(commentBlocksIn(source), [
        (line: 1, lines: 3),
        (line: 6, lines: 2),
      ]);
    });

    test('a blank line or code between comments starts a new block', () {
      const source = '// a\n\n// b\nfinal x = 1; // c\n// d\n';

      expect(commentBlocksIn(source), [
        (line: 1, lines: 1),
        (line: 3, lines: 1),
        (line: 4, lines: 2),
      ]);
    });

    test('a block comment spans the lines it covers', () {
      const source = 'final x = 1;\n/* one\ntwo\nthree */\nfinal y = 2;\n';

      expect(commentBlocksIn(source), [(line: 2, lines: 3)]);
    });
  });

  group('testDocCommentsIn', () {
    test('finds a doc comment on main and on a test body', () {
      const source =
          "import 'x.dart';\n\n/// Why this file exists.\n"
          "void main() {\n  /// Says what the name says.\n  test('a', () {});\n"
          "  group('b', () {});\n}\n";

      expect(testDocCommentsIn(source), [3, 5]);
    });

    test('a doc comment on a helper, or a plain comment, is not one', () {
      const source =
          '/// A fixture.\nfinal fixture = 1;\n// setup\n'
          "void main() {\n  // arrange\n  test('a', () {});\n}\n";

      expect(testDocCommentsIn(source), isEmpty);
    });
  });
}
