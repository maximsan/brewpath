import 'package:brew_path/features/lessons/presentation/cards/card_cue.dart';
import 'package:brew_path/shared/repositories/card_kind_help_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'reads the bundled bank, so the ? is never drawn over nothing',
    () async {
      final help = await CardKindHelpRepository().getByKind();

      for (final cue in CardCue.values) {
        final entry = help[cue.helpKey];
        expect(entry, isNotNull, reason: '${cue.name} has no bundled help');
        expect(entry!.title, isNotEmpty);
        expect(entry.blurb, isNotEmpty);
        expect(entry.steps, hasLength(3));
      }
    },
  );

  test('caches, so a card opening twice reads the bundle once', () async {
    final repository = CardKindHelpRepository();

    expect(
      identical(await repository.getByKind(), await repository.getByKind()),
      isTrue,
    );
  });
}
