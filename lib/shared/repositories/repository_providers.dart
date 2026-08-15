import 'package:brew_path/shared/repositories/card_repository.dart';
import 'package:brew_path/shared/repositories/module_progress_repository.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/storage/account_wipe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repository_providers.g.dart';

/// Provides the [ProgressRepository].
@riverpod
ProgressRepository progressRepository(Ref ref) => ProgressRepository();

/// Provides the [CardRepository].
@riverpod
CardRepository cardRepository(Ref ref) => CardRepository();

/// Provides the [SettingsRepository].
@riverpod
SettingsRepository settingsRepository(Ref ref) => SettingsRepository();

/// Provides the [ModuleProgressRepository].
@riverpod
ModuleProgressRepository moduleProgressRepository(Ref ref) =>
    ModuleProgressRepository();

/// Provides the [AccountWipe] — Reset Progress and Delete Account.
@riverpod
AccountWipe accountWipe(Ref ref) => AccountWipe();
