import 'package:brew_path/features/profile/domain/learner_name.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a typed name is kept, trimmed', () {
    expect(LearnerName.normalize('  Maya  '), 'Maya');
  });

  test('blank and empty are the one answer: no name', () {
    // The same collapse the onboarding step makes, so a name cleared in
    // Settings and a name never given are indistinguishable to the greeting.
    expect(LearnerName.normalize('   '), isNull);
    expect(LearnerName.normalize(''), isNull);
  });

  test('the row reads the name, or Not set', () {
    expect(LearnerName.rowValue('Maya'), 'Maya');
    expect(LearnerName.rowValue(null), LearnerName.notSet);
  });
}
