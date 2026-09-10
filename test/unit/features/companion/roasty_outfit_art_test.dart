// The banks name the outfit; the art draws it, keyed by the same ids. Nothing
// holds the two in step at compile time, so this does — a bank id with no
// drawing is a pick that silently changes nothing on screen.
import 'package:brew_path/features/companion/presentation/roasty_gear.dart';
import 'package:brew_path/features/companion/presentation/roasty_hats.dart';
import 'package:brew_path/features/companion/presentation/roasty_sprouts.dart';
import 'package:brew_path/shared/models/content/companion_option.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:brew_path/shared/theme/roasty_outfit_colors.dart';
import 'package:flutter_test/flutter_test.dart';

/// The id every axis uses for "wearing nothing on this one".
const _bare = 'none';

Set<String> _ids(List<CompanionOption> axis) =>
    axis.map((option) => option.id).toSet();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CompanionOptions options;

  setUpAll(() async {
    options = await ContentRepository().getCompanionOptions();
  });

  group('the roast axis', () {
    test('every id the bank ships has its own gradient', () {
      expect(_ids(options.roasts), RoastyOutfitColors.byRoast.keys.toSet());
    });

    test('each gradient is the three stops the body paint takes', () {
      for (final stops in RoastyOutfitColors.byRoast.values) {
        expect(stops, hasLength(3));
      }
    });

    test('an unknown roast falls back rather than failing to paint', () {
      expect(
        RoastyOutfitColors.roastGradient('charcoal'),
        RoastyOutfitColors.roastMedium,
      );
    });
  });

  group('the hat axis', () {
    test('every id the bank ships is drawn, bar the bare one', () {
      expect(_ids(options.hats), {_bare, ...roastyHatIds});
    });

    test('only the bare one reads as bare', () {
      expect(hatIsBare(_bare), isTrue);
      for (final id in roastyHatIds) {
        expect(hatIsBare(id), isFalse, reason: '$id draws nothing');
      }
    });
  });

  group('the sprout axis', () {
    test('every id the bank ships is drawn, bar the bare one', () {
      expect(_ids(options.sprouts), {_bare, ...roastySproutIds});
    });

    test('only the bare one reads as bare', () {
      expect(sproutIsBare(_bare), isTrue);
      for (final id in roastySproutIds) {
        expect(sproutIsBare(id), isFalse, reason: '$id draws nothing');
      }
    });
  });

  group('the gear axis', () {
    test('every id the bank ships is drawn, bar the bare one', () {
      expect(_ids(options.gear), {_bare, ...roastyGearIds});
    });
  });

  test('the plain outfit names an id the bank actually ships', () {
    const plain = CompanionConfig.initial;

    expect(_ids(options.roasts), contains(plain.roast));
    expect(_ids(options.hats), contains(plain.hat));
    expect(_ids(options.gear), contains(plain.gear));
    expect(_ids(options.sprouts), contains(plain.sprout));
  });
}
