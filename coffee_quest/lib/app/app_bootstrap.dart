import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:coffee_quest/shared/storage/isar_service.dart';

class AppBootstrap {
  static Future<void> initialize() async {
    // Skip Isar open until Phase 3 registers @collection schemas.
    if (IsarService.schemas.isEmpty) return;
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      IsarService.schemas,
      directory: dir.path,
    );
    IsarService.instance = isar;
  }
}
