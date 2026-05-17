import 'package:isar/isar.dart';
import 'package:coffee_quest/shared/storage/card_record.dart';
import 'package:coffee_quest/shared/storage/progress_record.dart';
import 'package:coffee_quest/shared/storage/settings_record.dart';

class IsarService {
  IsarService._();

  static late Isar instance;

  static List<CollectionSchema<dynamic>> get schemas => [
        ProgressRecordSchema,
        CardRecordSchema,
        UserSettingsRecordSchema,
      ];
}
