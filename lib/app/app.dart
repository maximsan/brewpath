import 'package:brew_path/app/app_router.dart';
import 'package:brew_path/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root application widget — wires the router and theme into MaterialApp.
class BrewPathApp extends ConsumerWidget {
  /// Creates a [BrewPathApp].
  const BrewPathApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'BrewPath',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
