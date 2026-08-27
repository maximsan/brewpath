import 'dart:convert';
import 'dart:io';

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// The design's marks live in three places at once — the drawing in
/// `prototype/`, the written asset, and the [AppIcon] value naming it — and
/// only the middle one is generated. These are the checks that keep the three
/// agreeing: a mark added to the design and extracted but never named is as
/// invisible to the app as one that was never drawn.
const _assets = 'assets/icons';
const _prototype = 'prototype';

ProcessResult _extract(String out) => Process.runSync('node', [
  'tool/extract_icons.js',
  '--source',
  _prototype,
  '--out',
  out,
]);

Set<String> _svgsIn(String directory) => Directory(directory)
    .listSync()
    .map((entity) => p.basename(entity.path))
    .where((name) => name.endsWith('.svg'))
    .toSet();

void main() {
  group('the catalogue and the assets', () {
    test('every mark the app names has been written', () {
      for (final icon in AppIcon.values) {
        expect(
          File(icon.asset).existsSync(),
          isTrue,
          reason:
              '${icon.name} names ${icon.asset}, which no run of '
              'tool/extract_icons.js has produced',
        );
      }
    });

    test('every written mark is named', () {
      final named = {
        for (final icon in AppIcon.values) p.basename(icon.asset),
        for (final icon in AppIcon.values.where((icon) => icon.hasActive))
          p.basename(icon.activeAsset),
      };

      expect(
        _svgsIn(_assets).difference(named),
        isEmpty,
        reason:
            'the design drew these and the extractor wrote them, but no '
            'AppIcon value reaches them — an unnamed mark is one the app '
            'cannot draw, which is the quiet half of this divergence',
      );
    });

    test('an active state exists exactly where one is claimed', () {
      for (final icon in AppIcon.values) {
        expect(
          File(icon.activeAsset).existsSync(),
          isTrue,
          reason: '${icon.name}.activeAsset points at nothing',
        );
        expect(
          icon.activeAsset == icon.asset,
          !icon.hasActive,
          reason:
              'a mark with no active state falls back to its resting one, and '
              'a mark with one must not',
        );
      }
    });

    test('only the nav set is drawn with a state', () {
      expect(
        AppIcon.values
            .where((icon) => icon.hasActive)
            .map((icon) => icon.set)
            .toSet(),
        {AppIconSet.nav},
        reason:
            'the running prototype draws an active state for the tabs alone; '
            'a second set gaining one is a design change to read before it is '
            'transcribed',
      );
    });
  });

  group('the concept rules the family exists to keep', () {
    test('no two knowledge topics share a mark', () {
      final topics = AppIcon.values.where(
        (icon) => icon.set == AppIconSet.dict,
      );
      final drawings = topics.map(
        (icon) => File(icon.asset).readAsStringSync(),
      );

      expect(
        drawings.toSet(),
        hasLength(topics.length),
        reason:
            'the app drew four topics with one Icons.menu_book; the design '
            'rule is one literal line mark per topic',
      );
    });

    test('the duel types reuse the nav set rather than redrawing it', () {
      expect(
        AppIcon.values.where((icon) => icon.set == AppIconSet.duel),
        hasLength(2),
        reason:
            'five duel types are catalogued, and three of them are the nav '
            "set's Cup, Globe and Route — one drawing, one stroke, named once",
      );
    });
  });

  group('the written marks', () {
    test('carry no colour of their own beyond the mapped sentinels', () {
      const mapped = {'#FF00FF', '#FF00EE', '#FF00DD'};

      for (final name in _svgsIn(_assets)) {
        final svg = File(p.join(_assets, name)).readAsStringSync();
        final colours = RegExp('(?:stroke|fill)="([^"]*)"')
            .allMatches(svg)
            .map((match) => match.group(1)!)
            .where((colour) => colour != 'currentColor' && colour != 'none')
            .toSet();

        expect(
          colours.difference(mapped),
          isEmpty,
          reason:
              '$name paints in a colour IconMark cannot map onto the mood, so '
              'it would render the same in both',
        );
      }
    });

    test('the concept family is drawn on the 24x24 grid, and only it', () {
      const concepts = {AppIconSet.nav, AppIconSet.duel, AppIconSet.dict};

      for (final icon in AppIcon.values.where(
        (icon) => concepts.contains(icon.set),
      )) {
        expect(
          File(icon.asset).readAsStringSync(),
          contains('viewBox="0 0 24 24"'),
          reason:
              '${icon.name} is off the 24×24 grid the concept family shares',
        );
      }

      // The chrome sets are drawn smaller on purpose — "not part of the 24×24
      // concept family", in the design's own words — so this asserts the
      // distinction exists rather than that every mark is the same size.
      final chrome = AppIcon.values
          .where((icon) => !concepts.contains(icon.set))
          .map((icon) => File(icon.asset).readAsStringSync())
          .where((svg) => !svg.contains('viewBox="0 0 24 24"'));

      expect(
        chrome,
        isNotEmpty,
        reason:
            'the chrome marks all matching the concept grid would mean the '
            'sizes were normalised somewhere between the design and here',
      );
    });

    test('each mark is drawn at the size of its own box', () {
      for (final name in _svgsIn(_assets)) {
        final svg = File(p.join(_assets, name)).readAsStringSync();
        final box = RegExp(r'viewBox="0 0 ([\d.]+) ([\d.]+)"').firstMatch(svg);

        expect(box, isNotNull, reason: '$name has no 0-origin viewBox');
        expect(
          svg,
          contains('width="${box!.group(1)}" height="${box.group(2)}"'),
          reason:
              '$name would render at a size its drawing does not have, so a '
              'call site that asks for no size would get the wrong one',
        );
      }
    });
  });

  // The three checks above read the committed assets, so the committed assets
  // are what they keep agreeing with. This is the one that asks whether those
  // are still what the design draws.
  test('the committed marks match a fresh extraction', () {
    final scratch = Directory.systemTemp.createTempSync('extract_icons');
    addTearDown(() => scratch.deleteSync(recursive: true));

    final result = _extract(scratch.path);
    expect(result.exitCode, 0, reason: '${result.stderr}');

    expect(_svgsIn(scratch.path), _svgsIn(_assets));
    for (final name in _svgsIn(scratch.path)) {
      expect(
        File(p.join(scratch.path, name)).readAsStringSync(),
        File(p.join(_assets, name)).readAsStringSync(),
        reason:
            '$name has moved in the design since it was extracted. Re-run '
            'tool/extract_icons.js rather than editing the asset: an asset '
            'edited by hand is a mark the design no longer owns.',
      );
    }

    expect(
      jsonDecode(File(p.join(scratch.path, 'index.json')).readAsStringSync()),
      jsonDecode(File(p.join(_assets, 'index.json')).readAsStringSync()),
    );
  });
}
