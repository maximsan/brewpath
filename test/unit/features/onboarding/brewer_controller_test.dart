import 'package:brew_path/features/onboarding/presentation/brewer/brewer_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrewerController', () {
    test('no selection initially → cannot submit', () {
      final controller = BrewerController(
        onSubmit: (_) async {},
        onFinished: () {},
      );
      expect(controller.selectedIndex, isNull);
      expect(controller.canSubmit, isFalse);
      controller.dispose();
    });

    test('pick selects an option and enables submit', () {
      var notifications = 0;
      final controller = BrewerController(
        onSubmit: (_) async {},
        onFinished: () {},
      )..addListener(() => notifications++);

      controller.pick(1);

      expect(controller.selectedIndex, 1);
      expect(controller.canSubmit, isTrue);
      expect(notifications, 1);
      controller.dispose();
    });

    test(
      'submit persists the selected index then finishes, in order',
      () async {
        final calls = <String>[];
        final controller = BrewerController(
          onSubmit: (index) async => calls.add('submit:$index'),
          onFinished: () => calls.add('finished'),
        )..pick(2);

        await controller.submit();

        expect(calls, ['submit:2', 'finished']);
        controller.dispose();
      },
    );

    test(
      'submitting is true and canSubmit false while onSubmit runs',
      () async {
        late final BrewerController controller;
        bool? submittingInFlight;
        bool? canSubmitInFlight;
        controller = BrewerController(
          onSubmit: (_) async {
            submittingInFlight = controller.submitting;
            canSubmitInFlight = controller.canSubmit;
          },
          onFinished: () {},
        )..pick(0);

        await controller.submit();

        expect(submittingInFlight, isTrue);
        expect(canSubmitInFlight, isFalse, reason: 'guarded while in flight');
        expect(controller.submitting, isTrue);
        controller.dispose();
      },
    );

    test('submit is a no-op with no selection', () async {
      var submitted = false;
      var finished = false;
      final controller = BrewerController(
        onSubmit: (_) async => submitted = true,
        onFinished: () => finished = true,
      );

      await controller.submit();

      expect(submitted, isFalse);
      expect(finished, isFalse);
      controller.dispose();
    });

    test('pick is ignored once submission is in flight', () async {
      final controller = BrewerController(
        onSubmit: (_) async {},
        onFinished: () {},
      )..pick(0);

      final future = controller.submit(); // sets submitting=true synchronously
      controller.pick(1); // should be ignored

      expect(controller.selectedIndex, 0);
      await future;
      controller.dispose();
    });
  });
}
