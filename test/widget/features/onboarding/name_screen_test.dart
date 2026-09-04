import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/app_text_field.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/core/widgets/link_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/onboarding/presentation/name/name_copy.dart';
import 'package:brew_path/features/onboarding/presentation/name/name_screen.dart';
import 'package:brew_path/features/onboarding/presentation/onboarding_providers.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/fake_onboarding_repository.dart';

/// The last onboarding step, and the only one that asks for anything. Since
/// ADR-0010 cut the goal and brewer questions, it is also the only question in
/// v1 — and it is optional.
void main() {
  late FakeOnboardingRepository fake;

  setUp(() => fake = FakeOnboardingRepository());

  Future<void> pump(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.onboardingName.path,
      routes: [
        GoRoute(
          path: AppRoutes.onboardingName.path,
          name: AppRoutes.onboardingName.name,
          builder: (_, _) => const NameScreen(),
        ),
        GoRoute(
          path: AppRoutes.learn.path,
          name: AppRoutes.learn.name,
          builder: (_, _) => const Scaffold(body: Text('stub-learn')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        // ignore: scoped_providers_should_specify_dependencies — test-only root override
        overrides: [onboardingRepositoryProvider.overrideWithValue(fake)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
  }

  /// Read off the widget rather than the rendered button: `find.byType`
  /// matches an exact runtime type, so it never sees the `FilledButton`
  /// underneath.
  PrimaryButton continueButton(WidgetTester tester) =>
      tester.widget<PrimaryButton>(find.byType(PrimaryButton));

  /// The actions sit below a 148-px mascot, so on a test-sized surface they
  /// start off-screen and a tap would land on the scroll view.
  Future<void> tapAction(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('asks the design question, not a step number', (tester) async {
    await pump(tester);

    expect(find.text(NameCopy.title), findsOneWidget);
    expect(find.text(NameCopy.support), findsOneWidget);
    // The flow is no longer three steps, and the design counts none of them.
    expect(find.textContaining('OF 3'), findsNothing);
    expect(find.textContaining('ONBOARDING'), findsNothing);
  });

  testWidgets('Continue stays dead until a name is typed', (tester) async {
    await pump(tester);

    expect(continueButton(tester).onPressed, isNull);

    await tester.enterText(find.byType(AppTextField), 'Maya');
    await tester.pump();

    expect(continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('whitespace alone is not a name', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(AppTextField), '   ');
    await tester.pump();

    expect(continueButton(tester).onPressed, isNull);
  });

  testWidgets('a typed name finishes onboarding carrying it', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(AppTextField), '  Maya  ');
    await tester.pump();
    await tapAction(tester, NameCopy.continueLabel);

    expect(fake.completeCalls, ['Maya']);
    expect(find.text('stub-learn'), findsOneWidget);
  });

  testWidgets('skipping finishes onboarding with no name', (tester) async {
    await pump(tester);

    await tapAction(tester, NameCopy.skip);

    expect(fake.completeCalls, [null]);
    expect(find.text('stub-learn'), findsOneWidget);
  });

  testWidgets('the field and both actions span the intro gutter', (
    tester,
  ) async {
    // The screen hands its children to `IntroPage`, whose column aligns to
    // the start — so a child that does not claim the width shrink-wraps. The
    // design draws all three at `width: 100%` inside the 24-px gutter.
    await pump(tester);

    final gutter =
        tester.getSize(find.byType(NameScreen)).width - AppSpacing.gutter * 2;
    for (final target in [
      find.byType(AppTextField),
      find.byType(PrimaryButton),
      find.byType(GhostButton),
    ]) {
      expect(tester.getSize(target).width, gutter);
    }
  });

  testWidgets('with the keyboard up, the actions stay on screen', (
    tester,
  ) async {
    // The regression this pins: the mascot is 148 tall, and a raised keyboard
    // takes about a third of the screen. With both, Continue and the skip
    // sat below the fold and the learner had to scroll to finish the step.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 336);
    addTearDown(tester.view.reset);

    await pump(tester);

    expect(
      find.byType(Roasty),
      findsNothing,
      reason: 'the drawing is the one thing here that says nothing',
    );
    for (final target in [
      find.byType(AppTextField),
      find.widgetWithText(PrimaryButton, NameCopy.continueLabel),
      find.widgetWithText(GhostButton, NameCopy.skip),
    ]) {
      expect(target.hitTestable(), findsOneWidget);
    }
  });

  testWidgets('the mascot is there when the keyboard is not', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pump(tester);

    expect(find.byType(Roasty), findsOneWidget);
    expect(
      find.widgetWithText(PrimaryButton, NameCopy.continueLabel).hitTestable(),
      findsOneWidget,
      reason: 'the designed screen fits a phone without scrolling',
    );
  });

  testWidgets('the skip is a ghost, not a bare link', (tester) async {
    // The design is explicit that a dismiss under a primary is a ghost —
    // `LinkButton` here would be the documented mistake.
    await pump(tester);

    expect(find.widgetWithText(GhostButton, NameCopy.skip), findsOneWidget);
    expect(find.byType(LinkButton), findsNothing);
  });

  testWidgets('skipping works even after typing, and keeps nothing', (
    tester,
  ) async {
    await pump(tester);

    await tester.enterText(find.byType(AppTextField), 'Maya');
    await tester.pump();
    await tapAction(tester, NameCopy.skip);

    expect(
      fake.completeCalls,
      [null],
      reason: 'skip is a decision, not a shortcut past what is in the field',
    );
  });
}
