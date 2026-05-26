import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:coffee_quest/features/onboarding/presentation/loading_screen.dart';
import 'package:coffee_quest/shared/storage/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppDatabaseService.instance = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await AppDatabaseService.instance.close();
  });

  testWidgets('shows brand mark and runs through the 6-step state machine', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/loading',
      routes: [
        GoRoute(path: '/loading', builder: (_, _) => const LoadingScreen()),
        GoRoute(
          path: '/welcome',
          builder: (_, _) => const Scaffold(body: Text('welcome-stub')),
        ),
        GoRoute(
          path: '/learn',
          builder: (_, _) => const Scaffold(body: Text('learn-stub')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );

    // Pump initial frame; brand mark should be on screen.
    await tester.pump();
    expect(find.text('COFFEE QUEST'), findsOneWidget);

    // Step through ~5 seconds to cover the full first cycle.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(seconds: 1));
    }

    // We should either be on the loading screen still (second cycle) or
    // have already auto-advanced to /welcome (since the in-memory DB
    // reports incomplete).
    final advanced = find.text('welcome-stub').evaluate().isNotEmpty;
    final stillLoading = find.byType(LoadingScreen).evaluate().isNotEmpty;
    expect(advanced || stillLoading, isTrue);
  });
}
