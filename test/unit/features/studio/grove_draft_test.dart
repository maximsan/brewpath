import 'package:brew_path/features/studio/domain/grove_draft.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:flutter_test/flutter_test.dart';

/// The chooser holds a draft until the learner confirms it. Everything the
/// screen decides — what is previewed, whether confirm is live — is this
/// value, so it is settled here rather than by pumping a widget.
void main() {
  const planted = Grove.initial;

  test('a fresh draft is the planted grove, and is not dirty', () {
    final draft = GroveDraft.of(planted);

    expect(draft.variety, 'arabica');
    expect(draft.light, 'daylight');
    expect(draft.isDirtyAgainst(planted), isFalse);
  });

  test('changing either axis makes it dirty', () {
    final draft = GroveDraft.of(planted);

    expect(draft.withVariety('robusta').isDirtyAgainst(planted), isTrue);
    expect(draft.withLight('moonlit').isDirtyAgainst(planted), isTrue);
  });

  test('changing back to what is planted is not dirty', () {
    // Confirm must go dead again, or a learner who reconsiders is invited to
    // write a value identical to the one already stored — and that write would
    // move the last-writer-wins stamp for nothing.
    final draft = GroveDraft.of(
      planted,
    ).withVariety('robusta').withVariety('arabica');

    expect(draft.isDirtyAgainst(planted), isFalse);
  });

  test('both axes move independently', () {
    final draft = GroveDraft.of(
      planted,
    ).withVariety('liberica').withLight('frost');

    expect(draft.variety, 'liberica');
    expect(draft.light, 'frost');
    expect(draft.grove, const Grove(variety: 'liberica', light: 'frost'));
  });
}
