import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/disclosure_mark.dart';
import 'package:brew_path/core/widgets/disclosure.dart';
import 'package:brew_path/shared/theme/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Harness extends StatefulWidget {
  const _Harness({
    this.glyph = DisclosureGlyph.caret,
    this.collapsible = true,
    this.startOpen = false,
    this.semanticsLabel,
    this.disableAnimations = false,
  });

  final DisclosureGlyph glyph;
  final bool collapsible;
  final bool startOpen;
  final String? semanticsLabel;
  final bool disableAnimations;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late bool _open = widget.startOpen;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.darkRoast,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: widget.disableAnimations),
      child: Scaffold(
        body: Disclosure(
          isOpen: _open,
          collapsible: widget.collapsible,
          glyph: widget.glyph,
          label: 'Question',
          semanticsLabel: widget.semanticsLabel,
          onToggle: widget.collapsible
              ? () => setState(() => _open = !_open)
              : null,
          child: const Text('Answer'),
        ),
      ),
    ),
  );
}

Future<void> _toggle(WidgetTester tester) async {
  await tester.tap(find.text('Question'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a shut panel builds nothing at all', (tester) async {
    await tester.pumpWidget(const _Harness());

    expect(find.text('Question'), findsOneWidget);
    expect(find.text('Answer'), findsNothing);
  });

  testWidgets('opens on a tap and shuts on another', (tester) async {
    await tester.pumpWidget(const _Harness());

    await _toggle(tester);
    expect(find.text('Answer'), findsOneWidget);

    await _toggle(tester);
    expect(find.text('Answer'), findsNothing);
  });

  testWidgets('the panel grows over the design 240ms', (tester) async {
    await tester.pumpWidget(const _Harness());

    await tester.tap(find.text('Question'));
    await tester.pump();
    final opening = tester.getSize(find.text('Answer')).height;

    await tester.pump(const Duration(milliseconds: 120));
    final midway = tester.getSize(find.byType(ClipRect)).height;
    expect(midway, greaterThan(0));
    expect(midway, lessThan(opening));

    await tester.pump(AppMotion.disclosure);
    expect(tester.getSize(find.byType(ClipRect)).height, opening);
  });

  testWidgets('reduced motion cuts the move rather than dropping it', (
    tester,
  ) async {
    await tester.pumpWidget(const _Harness(disableAnimations: true));

    await tester.tap(find.text('Question'));
    await tester.pump();

    expect(
      tester.getSize(find.byType(ClipRect)).height,
      tester.getSize(find.text('Answer')).height,
    );
  });

  testWidgets('the caret turns half a turn as it opens', (tester) async {
    await tester.pumpWidget(const _Harness(disableAnimations: true));
    expect(
      tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns,
      0,
    );

    await _toggle(tester);
    expect(
      tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns,
      0.5,
    );
  });

  testWidgets('the plus turns an eighth as it opens', (tester) async {
    await tester.pumpWidget(
      const _Harness(glyph: DisclosureGlyph.plus, disableAnimations: true),
    );

    await _toggle(tester);
    expect(
      tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns,
      0.125,
    );
  });

  testWidgets('a fixed header is a heading with no glyph', (tester) async {
    await tester.pumpWidget(
      const _Harness(collapsible: false, startOpen: true),
    );

    expect(find.byType(DisclosureMark), findsNothing);
    expect(find.byType(InkWell), findsNothing);
    expect(find.text('Answer'), findsOneWidget);
  });

  testWidgets('is announced as a button that expands', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const _Harness(semanticsLabel: 'Question, 3'));

    final header = find.bySemanticsLabel('Question, 3');
    expect(
      tester.getSemantics(header),
      isSemantics(isButton: true, hasExpandedState: true, isExpanded: false),
    );

    await _toggle(tester);
    expect(tester.getSemantics(header), isSemantics(isExpanded: true));
    handle.dispose();
  });

  testWidgets('a shut panel is out of the semantics tree', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const _Harness());

    expect(find.bySemanticsLabel('Answer'), findsNothing);

    await _toggle(tester);
    expect(find.bySemanticsLabel('Answer'), findsOneWidget);
    handle.dispose();
  });
}
