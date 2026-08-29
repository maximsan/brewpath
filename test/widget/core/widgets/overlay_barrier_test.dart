import 'dart:ui' show ImageFilter;

import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/app_sheet.dart';
import 'package:brew_path/core/widgets/overlay_barrier.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/overlay_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// What a modal barrier actually renders — the half of an overlay that was
/// missing (#379).
///
/// The tokens' own tests pin the radii against the design; these pin that the
/// radius reaches the screen. A blur that exists only in the token is the same
/// bug in a new place.
void main() {
  /// The filter of the barrier's backdrop, or null if nothing blurs.
  ///
  /// The sheet's own content sits above the barrier and never blurs, so the
  /// first `BackdropFilter` in the tree is the barrier's.
  ImageFilter? barrierFilter(WidgetTester tester) {
    final backdrops = tester.widgetList<BackdropFilter>(
      find.byType(BackdropFilter),
    );
    return backdrops.isEmpty ? null : backdrops.first.filter;
  }

  /// Pumps a screen with one button that opens [open], and taps it.
  Future<void> pumpAndOpen(
    WidgetTester tester,
    void Function(BuildContext context) open, {
    bool reduceMotion = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkRoast,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reduceMotion),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => open(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('the sheet barrier', () {
    testWidgets('blurs what is behind it at the modal dim radius', (
      tester,
    ) async {
      await pumpAndOpen(
        tester,
        (context) => showAppSheet<void>(
          context: context,
          title: 'Sheet title',
          builder: (_) => const Text('body'),
        ),
      );

      expect(barrierFilter(tester), OverlayColors.dimModal.backdropFilter);
    });

    testWidgets('still blurs when the platform asks for reduced motion', (
      tester,
    ) async {
      // Blur is not motion: a learner who turned animations off still gets the
      // overlay the design specifies, it simply arrives at rest.
      await pumpAndOpen(
        tester,
        (context) => showAppSheet<void>(
          context: context,
          title: 'Sheet title',
          builder: (_) => const Text('body'),
        ),
        reduceMotion: true,
      );

      expect(barrierFilter(tester), OverlayColors.dimModal.backdropFilter);
    });

    testWidgets('carries the dim colour too, and keeps the mood', (
      tester,
    ) async {
      await pumpAndOpen(
        tester,
        (context) => showAppSheet<void>(
          context: context,
          title: 'Sheet title',
          builder: (_) => const Text('body'),
        ),
      );

      final route = ModalRoute.of(
        tester.element(find.text('body')),
      )!;
      expect(route.barrierColor, OverlayColors.dimModal.color);

      // The route is built from the navigator's context, so the theme has to
      // be captured for the sheet to keep the mood.
      expect(tester.element(find.text('body')).mood, MoodColors.darkRoast);
    });
  });

  group('an overlay dialog', () {
    testWidgets('blurs behind its barrier and returns what it pops', (
      tester,
    ) async {
      Object? answer;

      await pumpAndOpen(tester, (context) async {
        answer = await showOverlayDialog<String>(
          context: context,
          overlay: OverlayColors.dimModal,
          barrierDismissible: false,
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).pop('yes'),
            child: const Text('answer'),
          ),
        );
      });

      expect(barrierFilter(tester), OverlayColors.dimModal.backdropFilter);

      await tester.tap(find.text('answer'));
      await tester.pumpAndSettle();

      expect(answer, 'yes');
    });

    testWidgets('takes no saveLayer for an overlay the design does not blur', (
      tester,
    ) async {
      final unblurred = MoodColors.darkRoast.veil;
      expect(unblurred.isBlurred, isFalse);

      await pumpAndOpen(
        tester,
        (context) => showOverlayDialog<void>(
          context: context,
          overlay: unblurred,
          builder: (_) => const Text('body'),
        ),
      );

      expect(barrierFilter(tester), isNull);
    });
  });
}
