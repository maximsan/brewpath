import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:coffee_quest/app/analytics_navigator_observer.dart';
import 'package:coffee_quest/app/app_shell.dart';
import 'package:coffee_quest/features/cards/presentation/card_detail_screen.dart';
import 'package:coffee_quest/features/cards/presentation/cards_screen.dart';
import 'package:coffee_quest/features/learn/presentation/learn_screen.dart';
import 'package:coffee_quest/features/learn/presentation/module_detail_screen.dart';
import 'package:coffee_quest/features/path/presentation/path_screen.dart';
import 'package:coffee_quest/features/profile/presentation/profile_screen.dart';
import 'package:coffee_quest/services/analytics/analytics_provider.dart';

part 'app_router.g.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Phase 7 replaces this with the real lesson runner; until then the lesson
/// route renders a placeholder so navigation from Learn/Module is testable.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen(this.title, {this.detail});

  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(detail == null ? '$title — coming soon' : '$title: $detail'),
      ),
    );
  }
}

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/learn',
    observers: [
      AnalyticsNavigatorObserver(ref.watch(analyticsServiceProvider)),
    ],
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                name: 'learn',
                builder: (context, state) => const LearnScreen(),
                routes: [
                  GoRoute(
                    path: 'module/:moduleId',
                    name: 'moduleDetail',
                    builder: (context, state) => ModuleDetailScreen(
                      moduleId: state.pathParameters['moduleId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'lesson/:lessonId',
                        name: 'lesson',
                        builder: (context, state) => _PlaceholderScreen(
                          'Lesson',
                          detail: state.pathParameters['lessonId'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/path',
                name: 'path',
                builder: (context, state) => const PathScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cards',
                name: 'cards',
                builder: (context, state) => const CardsScreen(),
                routes: [
                  GoRoute(
                    path: ':cardId',
                    name: 'cardDetail',
                    builder: (context, state) => CardDetailScreen(
                      cardId: state.pathParameters['cardId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
