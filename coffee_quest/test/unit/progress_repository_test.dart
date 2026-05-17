import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:coffee_quest/shared/repositories/card_repository.dart';
import 'package:coffee_quest/shared/repositories/progress_repository.dart';
import 'package:coffee_quest/shared/repositories/settings_repository.dart';
import 'package:coffee_quest/shared/storage/card_record.dart';
import 'package:coffee_quest/shared/storage/isar_service.dart';
import 'package:coffee_quest/shared/storage/progress_record.dart';
import 'package:coffee_quest/shared/storage/settings_record.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('isar_test_');
    isar = await Isar.open(
      [ProgressRecordSchema, CardRecordSchema, UserSettingsRecordSchema],
      directory: dir.path,
    );
    IsarService.instance = isar;
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  group('ProgressRepository', () {
    late ProgressRepository repo;
    setUp(() => repo = ProgressRepository());

    test('saveCompletion stores a record', () async {
      await repo.saveCompletion(lessonId: 'lesson_a', xpEarned: 10);
      final record = await repo.getByLessonId('lesson_a');
      expect(record, isNotNull);
      expect(record!.isCompleted, isTrue);
      expect(record.xpEarned, 10);
    });

    test('saveCompletion is idempotent', () async {
      await repo.saveCompletion(lessonId: 'lesson_a', xpEarned: 10);
      await repo.saveCompletion(lessonId: 'lesson_a', xpEarned: 10);
      final all = await repo.getAllCompleted();
      expect(all.length, 1);
    });

    test('getAllCompleted returns only completed records', () async {
      await repo.saveCompletion(lessonId: 'lesson_a', xpEarned: 10);
      await repo.saveCompletion(lessonId: 'lesson_b', xpEarned: 20);
      final all = await repo.getAllCompleted();
      expect(all.length, 2);
      expect(all.every((r) => r.isCompleted), isTrue);
    });
  });

  group('CardRepository', () {
    late CardRepository repo;
    setUp(() => repo = CardRepository());

    test('collectCard stores a card', () async {
      await repo.collectCard('card_beans');
      expect(await repo.isCardCollected('card_beans'), isTrue);
    });

    test('collectCard is idempotent', () async {
      await repo.collectCard('card_beans');
      await repo.collectCard('card_beans');
      final ids = await repo.getAllCollectedCardIds();
      expect(ids.length, 1);
    });

    test('isCardCollected returns false for unknown card', () async {
      expect(await repo.isCardCollected('card_unknown'), isFalse);
    });
  });

  group('SettingsRepository', () {
    late SettingsRepository repo;
    setUp(() => repo = SettingsRepository());

    test('getSettings returns defaults on first call', () async {
      final settings = await repo.getSettings();
      expect(settings.totalXp, 0);
      expect(settings.streakDays, 0);
      expect(settings.hapticsEnabled, isTrue);
      expect(settings.soundEnabled, isTrue);
      expect(settings.lastActivityDate, isNull);
    });

    test('addXp accumulates correctly', () async {
      await repo.addXp(10);
      await repo.addXp(20);
      final settings = await repo.getSettings();
      expect(settings.totalXp, 30);
    });

    test('saveSettings persists changes', () async {
      final settings = await repo.getSettings();
      settings.hapticsEnabled = false;
      await repo.saveSettings(settings);
      final updated = await repo.getSettings();
      expect(updated.hapticsEnabled, isFalse);
    });
  });
}
