import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/learn/domain/lesson_module_groups.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

LessonWithModule _lesson(String id, ModuleModel module) => LessonWithModule(
  lesson: testLesson(id: id, moduleId: module.id),
  module: module,
);

void main() {
  final beans = testModule();
  final processing = testModule(id: 'm2', n: 2, title: 'Processing');

  test('one group per module, in the order the modules are met', () {
    final groups = groupLessonsByModule([
      _lesson('m1l1', beans),
      _lesson('m1l2', beans),
      _lesson('m2l1', processing),
    ]);

    expect(groups.map((group) => group.module.id), ['m1', 'm2']);
    expect(groups.first.lessons.map((entry) => entry.lesson.id), [
      'm1l1',
      'm1l2',
    ]);
    expect(groups.last.lessons.map((entry) => entry.lesson.id), ['m2l1']);
  });

  test("a group's label is the eyebrow its lessons carry", () {
    final groups = groupLessonsByModule([_lesson('m1l1', beans)]);

    expect(groups.single.label, 'MODULE 1 · BEANS');
  });

  test('nothing finished is no groups at all', () {
    expect(groupLessonsByModule(const []), isEmpty);
  });
}
