import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/monetization/domain/locked_row_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/features/path/domain/path_density.dart';
import 'package:brew_path/features/path/domain/path_module_view.dart';
import 'package:brew_path/features/path/presentation/path_module_section.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

const _pitch = PlusPitch(
  remainingLessons: 29,
  lockedGames: 4,
  referenceTerms: 8,
  savedFreeCap: 5,
);

/// A locked module — the only density that carries a sub-line at all.
PathModule _lockedModule({required bool isPurchaseLocked}) {
  const lessonIds = ['m2l1', 'm2l2'];
  final item = ModuleWithProgress(
    module: testModule(
      id: 'm2',
      n: 2,
      title: 'Processing',
      lessonIds: lessonIds,
    ),
    completedCount: 0,
    totalCount: lessonIds.length,
    isLocked: true,
  );

  return PathModule(
    item: item,
    density: pathModuleDensity(item),
    isPurchaseLocked: isPurchaseLocked,
    lessons: const [],
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required bool isPurchaseLocked,
  String? previousTitle = 'Beans',
}) => tester.pumpWidget(
  ProviderScope(
    overrides: [plusPitchProvider.overrideWith((ref) async => _pitch)],
    child: MaterialApp(
      theme: AppTheme.darkRoast,
      home: Scaffold(
        body: ListView(
          children: [
            PathModuleSection(
              module: _lockedModule(isPurchaseLocked: isPurchaseLocked),
              isExpanded: false,
              onToggle: () {},
              previousTitle: previousTitle,
            ),
          ],
        ),
      ),
    ),
  ),
);

Finder get _lock => find.byWidgetPredicate(
  (widget) => widget is IconMark && widget.icon == AppIcon.lock,
);

/// A locked module row says which lock it is — and the two locks are not the
/// same sentence. Progression opens by learning; the purchase does not.
void main() {
  group('locked by progress', () {
    testWidgets('names the module that opens it', (tester) async {
      await _pump(tester, isPurchaseLocked: false);

      expect(
        find.text(LockedRowCopy.finishToUnlock('Beans').toUpperCase()),
        findsOneWidget,
      );
    });

    testWidgets('states its size when nothing precedes it', (tester) async {
      await _pump(tester, isPurchaseLocked: false, previousTitle: null);

      expect(
        find.text(LockedRowCopy.moduleSize(2).toUpperCase()),
        findsOneWidget,
      );
    });

    testWidgets('draws a muted lock, and nothing happens on tap', (
      tester,
    ) async {
      await _pump(tester, isPurchaseLocked: false);

      expect(
        tester.widget<IconMark>(_lock).color,
        MoodColors.darkRoast.inkMute,
      );

      await tester.tap(find.text('Processing'));
      await tester.pumpAndSettle();

      expect(find.text(PlusCopy.title), findsNothing);
    });
  });

  group('locked by the purchase', () {
    testWidgets('names the purchase instead of the prerequisite', (
      tester,
    ) async {
      await _pump(tester, isPurchaseLocked: true);

      expect(
        find.text(LockedRowCopy.purchasedModule(2).toUpperCase()),
        findsOneWidget,
      );
      expect(
        find.text(LockedRowCopy.finishToUnlock('Beans').toUpperCase()),
        findsNothing,
        reason:
            'someone who cannot buy the course will never finish Beans either',
      );
    });

    testWidgets('draws one lock, in accent', (tester) async {
      await _pump(tester, isPurchaseLocked: true);

      expect(_lock, findsOneWidget);
      expect(tester.widget<IconMark>(_lock).color, MoodColors.darkRoast.accent);
    });

    testWidgets('raises the offer on tap', (tester) async {
      await _pump(tester, isPurchaseLocked: true);

      await tester.tap(find.text('Processing'));
      await tester.pumpAndSettle();

      expect(find.text(PlusCopy.title), findsOneWidget);
    });

    testWidgets('announces the state and its reason', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, isPurchaseLocked: true);

      expect(
        find.bySemanticsLabel(
          LockedRowCopy.purchaseLockedSemantics('Processing'),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
