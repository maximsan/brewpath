import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/bordered_tap_row.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

const _label = 'Open the beans category';

Widget _host(VoidCallback onTap) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  theme: AppTheme.darkRoast,
  home: Scaffold(
    body: BorderedTapRow(
      semanticsLabel: _label,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: const Text('Beans'),
    ),
  ),
);

void main() {
  group('the shared frame', () {
    testWidgets('announces a button a screen reader can press', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(_host(() => taps++));

      final node = tester.getSemantics(find.byType(BorderedTapRow));
      expect(
        node.getSemanticsData().hasAction(SemanticsAction.tap),
        isTrue,
        reason:
            'excludeSemantics drops the InkWell tap along with the text, so '
            'the flag alone announces a button that cannot be pressed',
      );

      tester.semantics.tap(find.semantics.byLabel(_label));
      await tester.pump();

      expect(taps, 1, reason: 'and the announced action runs the handler');
      handle.dispose();
    });

    testWidgets('reads its label once, not the lines inside it', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(() {}));

      expect(
        tester
            .getSemantics(find.byType(BorderedTapRow))
            .getSemanticsData()
            .label,
        _label,
        reason:
            'the children stay excluded — carrying the tap is what fixes the '
            'button, not letting the contents announce themselves as well',
      );
      handle.dispose();
    });
  });
}
