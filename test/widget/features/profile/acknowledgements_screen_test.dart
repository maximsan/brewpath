import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/outward_mark.dart';
import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/features/profile/domain/acknowledgements.dart';
import 'package:brew_path/features/profile/domain/acknowledgements_provider.dart';
import 'package:brew_path/features/profile/presentation/settings/acknowledgements_screen.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/services/links/link_opener.dart';
import 'package:brew_path/services/links/link_provider.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/settings_finders.dart';
import '../../../support/widget_harness.dart';

/// Records what a row asked the platform to open.
class _RecordingOpener implements LinkOpener {
  final List<Uri> opened = [];

  @override
  Future<bool> open(Uri target) async {
    opened.add(target);
    return true;
  }
}

const _hosted = DictionarySource(
  label: 'SCA — Research and resources',
  url: 'https://sca.coffee/research',
);
const _print = DictionarySource(label: 'A book with no address');

void main() {
  setUp(useInMemoryDatabase);

  late _RecordingOpener opener;

  setUp(() => opener = _RecordingOpener());

  /// Pumps the page. [sources] stands in for the bank; [fails] makes reading
  /// it throw, which is the only way the bundled bank can go missing.
  Future<void> pump(
    WidgetTester tester, {
    List<DictionarySource>? sources,
    bool fails = false,
  }) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          linkOpenerProvider.overrideWithValue(opener),
          if (fails)
            acknowledgementsProvider.overrideWith(
              (ref) async => throw Exception('the bank could not be read'),
            )
          else if (sources != null)
            acknowledgementsProvider.overrideWith((ref) async => sources),
        ],
        child: MaterialApp(
          theme: AppTheme.cupping,
          home: const AcknowledgementsScreen(),
        ),
      ),
    );
    // The bank is read off the real bundle, which only advances in `runAsync`.
    await tester.pump();
    for (var attempt = 0; attempt < 20; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
      if (find.byType(SettingsNavRow).evaluate().isNotEmpty) break;
    }
  }

  testWidgets('lists the works the bundled dictionary cites, each once', (
    tester,
  ) async {
    final expected = (await tester.runAsync(
      () async => acknowledgedSources(await DictionaryRepository().getTerms()),
    ))!;

    await pump(tester);

    expect(
      expected.length,
      greaterThan(1),
      reason: 'the shipped bank cites more than one work',
    );
    expect(find.byType(SettingsNavRow), findsNWidgets(expected.length));
    for (final source in expected.take(3)) {
      expect(settingsRow(source.label), findsOneWidget);
    }
  });

  testWidgets('opens a source that has an address, and marks it as leaving', (
    tester,
  ) async {
    await pump(tester, sources: const [_hosted]);
    await tester.pumpAndSettle();

    expect(find.byType(OutwardMark), findsOneWidget);

    await tester.tap(settingsRow(_hosted.label));
    expect(opener.opened, [Uri.parse(_hosted.url!)]);
  });

  testWidgets('a source with no address is named, not made tappable', (
    tester,
  ) async {
    await pump(tester, sources: const [_print]);
    await tester.pumpAndSettle();

    expect(
      tester.widget<SettingsNavRow>(settingsRow(_print.label)).onTap,
      isNull,
    );
    expect(find.byType(OutwardMark), findsNothing);
  });

  testWidgets('a bank that cites nothing stops gathering, and says nothing', (
    tester,
  ) async {
    await pump(tester, sources: const []);
    await tester.pumpAndSettle();

    expect(find.text(SettingsCopy.acknowledgementsGathering), findsNothing);
    expect(find.byType(SettingsNavRow), findsNothing);
  });

  testWidgets('says the sources could not be read rather than showing none', (
    tester,
  ) async {
    await pump(tester, fails: true);
    await tester.pumpAndSettle();

    expect(
      find.text(SettingsCopy.acknowledgementsUnavailable),
      findsOneWidget,
    );
    expect(find.byType(SettingsNavRow), findsNothing);
  });
}
