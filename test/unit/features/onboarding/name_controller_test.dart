import 'package:brew_path/features/onboarding/presentation/name/name_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<String?> submitted;
  late int finished;

  NameController make() => NameController(
    onSubmit: (name) async => submitted.add(name),
    onFinished: () => finished++,
  );

  setUp(() {
    submitted = [];
    finished = 0;
  });

  test('a typed name is kept, trimmed', () async {
    final controller = make()..type('  Maya  ');

    await controller.submit();

    expect(submitted, ['Maya']);
    expect(finished, 1);
  });

  test('Continue does nothing without a name to keep', () async {
    // Guarded as well as greyed out: the button is not the only caller — the
    // keyboard's done key submits too.
    await make().submit();

    expect(submitted, isEmpty);
    expect(finished, 0);
  });

  test('whitespace alone cannot be submitted either', () async {
    final controller = make()..type('   ');

    await controller.submit();

    expect(submitted, isEmpty);
  });

  test('Continue is dead until a name is typed', () {
    final controller = make();
    expect(controller.canContinue, isFalse);

    controller.type('Maya');
    expect(controller.canContinue, isTrue);

    controller.type('   ');
    expect(controller.canContinue, isFalse, reason: 'blank is not a name');
  });

  test('skip keeps nothing, even with something in the field', () async {
    final controller = make()..type('Maya');

    await controller.skip();

    expect(submitted, [null]);
    expect(finished, 1);
  });

  test('a second submit while the first is in flight is ignored', () async {
    final controller = make()..type('Maya');

    await Future.wait([controller.submit(), controller.submit()]);

    expect(submitted, hasLength(1));
  });

  test('typing is ignored once submission is in flight', () async {
    final controller = make()..type('Maya');
    final inFlight = controller.submit();
    controller.type('Someone else');
    await inFlight;

    expect(submitted, ['Maya']);
  });
}
