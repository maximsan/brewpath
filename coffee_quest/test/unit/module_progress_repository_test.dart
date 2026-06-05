import 'package:coffee_quest/shared/repositories/module_progress_repository.dart';
import 'package:coffee_quest/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ModuleProgressRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    repo = ModuleProgressRepository();
  });

  tearDown(() async {
    await db.close();
  });

  group('ModuleProgressRepository', () {
    test('isModuleXpAwarded is false for an unknown module', () async {
      expect(await repo.isModuleXpAwarded('module_beans'), isFalse);
    });

    test('markModuleXpAwarded flips the flag', () async {
      await repo.markModuleXpAwarded('module_beans');
      expect(await repo.isModuleXpAwarded('module_beans'), isTrue);
    });

    test('markModuleXpAwarded is idempotent', () async {
      await repo.markModuleXpAwarded('module_beans');
      await repo.markModuleXpAwarded('module_beans');
      expect(await repo.isModuleXpAwarded('module_beans'), isTrue);
    });

    test('the flag is tracked per module', () async {
      await repo.markModuleXpAwarded('module_beans');
      expect(await repo.isModuleXpAwarded('module_beans'), isTrue);
      expect(await repo.isModuleXpAwarded('module_processing'), isFalse);
    });
  });
}
