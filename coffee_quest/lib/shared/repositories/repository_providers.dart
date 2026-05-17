import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:coffee_quest/shared/repositories/card_repository.dart';
import 'package:coffee_quest/shared/repositories/progress_repository.dart';
import 'package:coffee_quest/shared/repositories/settings_repository.dart';

part 'repository_providers.g.dart';

@riverpod
ProgressRepository progressRepository(ProgressRepositoryRef ref) =>
    ProgressRepository();

@riverpod
CardRepository cardRepository(CardRepositoryRef ref) => CardRepository();

@riverpod
SettingsRepository settingsRepository(SettingsRepositoryRef ref) =>
    SettingsRepository();
