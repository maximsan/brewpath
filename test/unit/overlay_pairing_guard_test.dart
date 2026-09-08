import 'package:flutter_test/flutter_test.dart';

import '../support/dart_sources.dart';

// An overlay is a colour *and* a blur: the first port kept every colour and
// dropped every radius (#379). `AppOverlay` holds the pair now, but a pair is
// only unbreakable if nothing can take half of it — so the two ways one could,
// a raw barrier colour and a bare `.color` read, are guarded here by reading
// the sources. The sheet's own door is guarded in `sheet_primitive_test.dart`;
// this is the dialog's, plus the register of who may split a pair and why.
void main() {
  /// The one file allowed to open a dialog route: the primitive itself.
  const primitive = 'lib/core/widgets/overlay_barrier.dart';

  /// The two files that render an overlay's colour and *cannot* render its
  /// blur: `app_theme.dart`, whose `BottomSheetThemeData` has a barrier colour
  /// field and no filter field, and `tour_frame.dart`, where a backdrop blur
  /// would blur the coach mark's cut-out. A third entry means an overlay is
  /// rendering at half strength somewhere, and the reason belongs here before
  /// the code lands.
  const mayTakeColourAlone = <String>{
    'lib/app/app_theme.dart',
    'lib/features/tour/presentation/tour_frame.dart',
  };

  test('no source outside the primitive opens a dialog directly', () {
    final offenders = dartSourcesUnder('lib')
        .where((file) => file.path != primitive)
        .where(
          (file) => const [
            'showDialog',
            'DialogRoute',
          ].any(withoutComments(file.readAsStringSync()).contains),
        )
        .map((file) => file.path)
        .toList();

    expect(
      offenders,
      isEmpty,
      reason:
          'dialogs open through showOverlayDialog ($primitive), which carries '
          "the blur as well as the dim. A raw showDialog gets Material's own "
          'black barrier and no blur at all. Found:\n'
          '${offenders.join('\n')}',
    );
  });

  test('a file that takes an overlay colour renders its blur too', () {
    // Reading `.color` is not itself the sin — a control that sits *on* media
    // has to fill its own shape and clip its own blur, so it needs both halves
    // by hand. Taking the colour and rendering no blur at all is the sin.
    final offenders = dartSourcesUnder('lib')
        .where((file) => !mayTakeColourAlone.contains(file.path))
        .where((file) => file.path != 'lib/shared/theme/app_overlay.dart')
        .map((file) => (file.path, withoutComments(file.readAsStringSync())))
        .where(
          (source) => RegExp(
            r'\b(dimModal|scrim|veil|veilStrong|headerFill)\.color\b',
          ).hasMatch(source.$2),
        )
        .where(
          (source) => !const [
            'backdropFilter',
            'BackdropFilter',
          ].any(source.$2.contains),
        )
        .map((source) => source.$1)
        .toList();

    expect(
      offenders,
      isEmpty,
      reason:
          'taking .color and drawing no blur leaves half the overlay behind — '
          'the exact half-port this guard exists to stop. Render the blur, or '
          'if it genuinely has nowhere to go, add the file to '
          'mayTakeColourAlone with the reason. Found:\n'
          '${offenders.join('\n')}',
    );
  });
}
