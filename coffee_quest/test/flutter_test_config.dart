import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Auto-loaded by `flutter test` before any test in this directory tree.
/// Disables `google_fonts`' runtime network fetch so tests don't crash
/// trying to hit `fonts.gstatic.com` (which is blocked in CI).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
