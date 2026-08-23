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

  test('nothing typed is a skip, not an empty name', () async {
    await make().submit();

    expect(submitted, [null]);
  });

  test('whitespace alone is a skip too', () async {
    final controller = make()..type('   ');

    await controller.submit();

    expect(submitted, [null]);
  });

  test('the step can always be finished — it is optional', () {
    expect(make().canSubmit, isTrue);
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
