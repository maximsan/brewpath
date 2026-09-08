import 'package:brew_path/shared/repositories/install_repository.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/account_wipe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repository_providers.g.dart';

/// Provides the [SettingsRepository].
@riverpod
SettingsRepository settingsRepository(Ref ref) => SettingsRepository();

/// Provides the [AccountWipe] — Reset Progress and Delete Account.
@riverpod
AccountWipe accountWipe(Ref ref) => AccountWipe();

/// Provides the [SnapshotRepository].
@riverpod
SnapshotRepository snapshotRepository(Ref ref) => SnapshotRepository();

/// Provides the [InstallRepository].
@riverpod
InstallRepository installRepository(Ref ref) => InstallRepository();
