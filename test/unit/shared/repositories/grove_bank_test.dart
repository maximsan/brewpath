import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final content = ContentRepository();

  test('the three species load with their copy intact', () async {
    final varieties = await content.getGroveVarieties();

    expect(varieties.map((variety) => variety.id), [
      'arabica',
      'robusta',
      'liberica',
    ]);

    final arabica = varieties.first;
    expect(arabica.latin, 'Coffea arabica');
    expect(arabica.tell, isNotEmpty);
    expect(arabica.cup, isNotEmpty);
    // The species drawn as-is: no silhouette, no leaf tone.
    expect(arabica.leaf, isEmpty);
  });

  test('the four lights load in picker order', () async {
    final lights = await content.getGroveLights();

    expect(lights.map((light) => light.id), [
      'daylight',
      'goldenhour',
      'moonlit',
      'frost',
    ]);
    expect(lights.first.filter, isEmpty, reason: 'Daylight is unfiltered');
    expect(lights.every((light) => light.swatch.startsWith('#')), isTrue);
  });

  // The snapshot's defaults are ids, and ids that name nothing in the bank
  // would leave a stored grove resolving to a plant that does not exist.
  test('the snapshot defaults name entries the bank carries', () async {
    final varieties = await content.getGroveVarieties();
    final lights = await content.getGroveLights();

    expect(
      varieties.map((variety) => variety.id),
      contains(Grove.defaultVariety),
    );
    expect(lights.map((light) => light.id), contains(Grove.defaultLight));
  });
}
