import 'package:coffee_quest/shared/storage/app_database.dart';

class AppBootstrap {
  static Future<void> initialize() async {
    AppDatabaseService.instance = AppDatabase();
  }
}
