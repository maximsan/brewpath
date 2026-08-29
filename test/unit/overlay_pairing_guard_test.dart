import 'package:flutter_test/flutter_test.dart';

import '../support/dart_sources.dart';

/// An overlay is a colour **and** a blur, and this is what makes that
/// structural rather than merely documented.
///
/// The first port kept every overlay colour and dropped every blur radius
/// (#379). `AppOverlay` holds the pair now, but a pair is only unbreakable if
/// nothing can take half of it — and two things could: opening a modal with a
/// raw barrier colour, and reading `.color` off a token. Both are guarded here,
/// the same crude way the sheet primitive is: by reading the sources.
///
/// The sheet's own door has its own guard (`sheet_primitive_test.dart`); this
/// is the dialog's, plus the register of who may split a pair and why.
void main() {
  /// The one file allowed to open a dialog route: the primitive itself.
  const primitive = 'lib/core/widgets/overlay_barrier.dart';

  /// The two files that render an overlay's colour and *cannot* render its
  /// blur, each saying so where it does it:
  ///
  /// - `app_theme.dart` — `BottomSheetThemeData` has a barrier colour field and
  ///   no filter field. It is the safety net under `showAppSheet`, which is the
  ///   door that carries both halves.
  /// - `tour_stop.dart` — `showcaseview` takes a colour and paints a hole in
  ///   it. A backdrop blur there would blur the cut-out, which is the one thing
  ///   on a coach mark that has to stay sharp.
  ///
  /// A third entry is not a formality: it means an overlay is rendering at half
  /// strength somewhere, and the reason belongs here before the code lands.
  const mayTakeColourAlone = <String>{
    'lib/app/app_theme.dart',
    'lib/features/tour/presentation/tour_stop.dart',
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
            r'\b(dimModal|scrim|veil|veilStrong)\.color\b',
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
