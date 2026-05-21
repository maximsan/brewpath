import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:coffee_quest/app/app.dart';
import 'package:coffee_quest/app/app_bootstrap.dart';
import 'package:coffee_quest/core/config/firebase_flags.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.initialize();

  // Crashlytics global handlers — installed only once Firebase is active so
  // the app keeps Flutter's default error reporting until then.
  if (kUseFirebase) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(const ProviderScope(child: CoffeeQuestApp()));
}
