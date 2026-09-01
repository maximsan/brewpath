// The three ways into the drill, and what each promises before it is tapped.
import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_quick_chips.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_copy.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_mark.dart';
import 'package:brew_path/features/learn/presentation/practice_drills_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Pumps [child] under a router whose vocab route only records that it was
/// reached — the drill itself is tested elsewhere.
Future<String?> _pumpEntry(WidgetTester tester, Widget child) async {
  String? reached;

  final router = GoRouter(
    initialLocation: '/learn',
    routes: [
      GoRoute(
        path: '/learn',
        name: AppRoutes.learn.name,
        builder: (_, _) => Scaffold(body: child),
        routes: [
          GoRoute(
            path: AppRoutes.vocabGame.path,
            name: AppRoutes.vocabGame.name,
            builder: (_, _) {
              reached = AppRoutes.vocabGame.name;
              return const Scaffold(body: Text('the drill'));
            },
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MaterialApp.router(theme: AppTheme.cupping, routerConfig: router),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text(VocabCopy.title));
  await tester.pumpAndSettle();

  return reached;
}

void main() {
  group("the dictionary's quick chip", () {
    testWidgets('names the drill and opens it', (tester) async {
      expect(
        await _pumpEntry(tester, const DictionaryQuickChips()),
        AppRoutes.vocabGame.name,
      );
    });

    testWidgets('wears the drill mark', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DictionaryQuickChips())),
      );

      expect(find.byType(VocabMark), findsOneWidget);
    });

    testWidgets('is announced as a button, with what it drills', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DictionaryQuickChips())),
      );

      expect(find.bySemanticsLabel(VocabCopy.title), findsOneWidget);
      semantics.dispose();
    });
  });

  group("the Learn tab's practice row", () {
    testWidgets('opens the drill', (tester) async {
      expect(
        await _pumpEntry(tester, const PracticeDrillsWidget()),
        AppRoutes.vocabGame.name,
      );
    });

    testWidgets('is free, and says so, with no lock', (tester) async {
      // ADR-0004: the drills are content-scoped, never feature-gated. A lock
      // mark here would say the opposite of what is true.
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PracticeDrillsWidget())),
      );

      expect(find.text('FREE'), findsOneWidget);
      expect(find.text(VocabCopy.rowSubtitle.toUpperCase()), findsOneWidget);
    });
  });
}
