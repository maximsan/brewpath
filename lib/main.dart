import 'dart:async';
import 'dart:ui';

import 'package:brew_path/app/app.dart';
import 'package:brew_path/app/app_bootstrap.dart';
import 'package:brew_path/core/config/firebase_flags.dart';
import 'package:brew_path/shared/theme/theme_mode_controller.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialThemeMode = await AppBootstrap.initialize();

  // Crashlytics global handlers — installed only once Firebase is active so
  // the app keeps Flutter's default error reporting until then.
  if (kUseFirebase) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
      );
      return true;
    };
  }

  runApp(
    ProviderScope(
      // Seeds the theme synchronously, so the first frame is already correct.
      overrides: [
        initialThemeModeProvider.overrideWithValue(initialThemeMode),
      ],
      child: const BrewPathApp(),
    ),
  );
}
