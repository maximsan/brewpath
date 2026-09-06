import 'package:brew_path/app/app_router.dart';
import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/app/day_rollover_watcher.dart';
import 'package:brew_path/features/challenges/presentation/challenge_expiry_watcher.dart';
import 'package:brew_path/features/tour/presentation/micro_tip_host.dart';
import 'package:brew_path/shared/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root application widget — wires the router and theme into MaterialApp.
class BrewPathApp extends ConsumerWidget {
  /// Creates a [BrewPathApp].
  const BrewPathApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    return DayRolloverWatcher(
      child: ChallengeExpiryWatcher(
        child: MaterialApp.router(
          title: 'BrewPath',
          // `theme` must be the light mood and `darkTheme` the dark one: under
          // ThemeMode.system Flutter picks between them by platform brightness,
          // and it follows a live OS change on its own.
          theme: AppTheme.cupping,
          darkTheme: AppTheme.darkRoast,
          themeMode: themeMode.materialThemeMode,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          // The guide layer's micro-tips draw over the whole app: two of the
          // screens they appear on are pushed over the tab bar, so no shell or
          // screen can host them all. See `MicroTipHost`.
          builder: (context, child) => MicroTipHost(child: child!),
        ),
      ),
    );
  }
}
