import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:coffee_quest/app/analytics_navigator_observer.dart';
import 'package:coffee_quest/app/app_shell.dart';
import 'package:coffee_quest/services/analytics/analytics_provider.dart';

part 'app_router.g.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Phase 5 placeholder. Phase 6 replaces these with the real feature screens
/// under `features/**/presentation`; kept private so it isn't reused.
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
                builder: (context, state) =>
                    const _PlaceholderScreen('Learn'),
                routes: [
                  GoRoute(
                    path: 'module/:moduleId',
                    name: 'moduleDetail',
                    builder: (context, state) => _PlaceholderScreen(
                      'Module',
                      detail: state.pathParameters['moduleId'],
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
                builder: (context, state) => const _PlaceholderScreen('Path'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cards',
                name: 'cards',
                builder: (context, state) => const _PlaceholderScreen('Cards'),
                routes: [
                  GoRoute(
                    path: ':cardId',
                    name: 'cardDetail',
                    builder: (context, state) => _PlaceholderScreen(
                      'Card',
                      detail: state.pathParameters['cardId'],
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
                builder: (context, state) =>
                    const _PlaceholderScreen('Profile'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
