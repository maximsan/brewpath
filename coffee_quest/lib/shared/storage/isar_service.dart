import 'package:isar/isar.dart';

class IsarService {
  IsarService._();

  static late Isar instance;

  // Schemas are registered here as @collection classes are added in Phase 3.
  static List<CollectionSchema<dynamic>> get schemas => [];
}
