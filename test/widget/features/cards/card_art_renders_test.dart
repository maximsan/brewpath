import 'package:brew_path/features/cards/domain/card_art.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every art, actually compiled.
///
/// **Deliberately not a widget test.** `SvgPicture` catches a load failure and
/// renders an empty box — `errorBuilder` is null by default — and the parser
/// discards an element it cannot read with a `print` rather than a throw. So
/// pumping the art and checking `takeException()` passes whatever happens, and
/// a corrupt asset would reach a learner as a blank tile with the suite green.
/// Loading the bytes runs the same compile without the widget swallowing it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the check can fail: malformed SVG is refused', () {
    // The control. Without it the thirty-seven assertions below prove only
    // that nothing threw, which is what the test they replaced proved.
    expect(
      () => const SvgStringLoader(
        '<svg viewBox="0 0 1 1"><path d=',
      ).loadBytes(null),
      throwsA(anything),
    );
  });

  for (final kind in cardArtKinds) {
    test('$kind compiles', () async {
      final bytes = await SvgAssetLoader(cardArtAsset(kind)!).loadBytes(null);

      expect(bytes.lengthInBytes, greaterThan(0), reason: '$kind drew nothing');
    });
  }
}
