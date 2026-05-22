import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:coffee_quest/shared/repositories/card_repository.dart';
import 'package:coffee_quest/shared/repositories/module_progress_repository.dart';
import 'package:coffee_quest/shared/repositories/progress_repository.dart';
import 'package:coffee_quest/shared/repositories/settings_repository.dart';

part 'repository_providers.g.dart';

@riverpod
ProgressRepository progressRepository(Ref ref) => ProgressRepository();

@riverpod
CardRepository cardRepository(Ref ref) => CardRepository();

@riverpod
SettingsRepository settingsRepository(Ref ref) => SettingsRepository();

@riverpod
ModuleProgressRepository moduleProgressRepository(Ref ref) =>
    ModuleProgressRepository();
