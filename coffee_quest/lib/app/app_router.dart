import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/learn',
    routes: [
      GoRoute(
        path: '/learn',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Learn — coming soon')),
        ),
      ),
      GoRoute(
        path: '/path',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Path — coming soon')),
        ),
      ),
      GoRoute(
        path: '/cards',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Cards — coming soon')),
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Profile — coming soon')),
        ),
      ),
    ],
  );
}
