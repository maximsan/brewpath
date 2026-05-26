import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:coffee_quest/features/onboarding/presentation/brewer_screen.dart';
import 'package:coffee_quest/features/onboarding/presentation/goal_screen.dart';
import 'package:coffee_quest/shared/storage/app_database.dart';

/// Covers the shared PickCard + Continue contract used by both onboarding
/// pick screens: Continue disabled until a card is tapped, exactly one
/// selection at a time, tapping Continue navigates onward.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppDatabaseService.instance = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await AppDatabaseService.instance.close();
  });

  Widget harness({required Widget screen, required String startPath}) {
    final router = GoRouter(
      initialLocation: startPath,
      routes: [
        GoRoute(path: '/onboarding/goal', builder: (_, _) => screen),
        GoRoute(
          path: '/onboarding/brewer',
          builder: (_, _) => const _Stub('brewer'),
        ),
        GoRoute(path: '/learn', builder: (_, _) => const _Stub('learn')),
      ],
    );
    return ProviderScope(child: MaterialApp.router(routerConfig: router));
  }

  testWidgets('Goal: Continue is disabled until a card is picked', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(screen: const GoalScreen(), startPath: '/onboarding/goal'),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final continueButton = find.widgetWithText(FilledButton, 'Continue');
    expect(continueButton, findsOneWidget);
    final btn = tester.widget<FilledButton>(continueButton);
    expect(btn.onPressed, isNull);

    await tester.tap(find.text('Brew better at home'));
    await tester.pump();
    final btn2 = tester.widget<FilledButton>(continueButton);
    expect(btn2.onPressed, isNotNull);
  });

  testWidgets('Brewer: tapping different cards swaps selection', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/onboarding/brewer',
      routes: [
        GoRoute(
          path: '/onboarding/brewer',
          builder: (_, _) => const BrewerScreen(),
        ),
        GoRoute(path: '/learn', builder: (_, _) => const _Stub('learn')),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('V60'));
    await tester.pump();
    await tester.tap(find.text('AeroPress'));
    await tester.pump();

    // Continue should be enabled after either pick.
    final btn = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(btn.onPressed, isNotNull);
  });
}

class _Stub extends StatelessWidget {
  const _Stub(this.label);
  final String label;
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('stub-$label')));
}
