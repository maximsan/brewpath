import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_scroll.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const double _viewportHeight = 800;
const double _inset = 24;
const double _buttonGap = 32;
final Key _content = UniqueKey();

Widget _host({required double contentHeight}) => MaterialApp(
  home: Scaffold(
    body: CardScroll(
      padding: const EdgeInsets.all(_inset),
      child: CardShell(
        latched: true,
        onContinue: () {},
        children: [SizedBox(key: _content, height: contentHeight)],
      ),
    ),
  ),
);

void main() {
  setUp(() {});

  Future<void> pump(WidgetTester tester, {required double contentHeight}) {
    tester.view.physicalSize = const Size(400, _viewportHeight);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    return tester.pumpWidget(_host(contentHeight: contentHeight));
  }

  testWidgets('a short card puts its way on at the foot of the screen', (
    tester,
  ) async {
    await pump(tester, contentHeight: 100);

    final button = tester.getRect(find.byType(PrimaryButton));
    expect(button.bottom, closeTo(_viewportHeight - _inset, 1));
  });

  testWidgets('a tall card scrolls, with its way on after the content', (
    tester,
  ) async {
    await pump(tester, contentHeight: 2000);

    final content = tester.getRect(find.byKey(_content));
    final button = tester.getRect(find.byType(PrimaryButton));
    expect(button.top, closeTo(content.bottom + _buttonGap, 1));
    expect(button.top, greaterThan(_viewportHeight));
  });
}
