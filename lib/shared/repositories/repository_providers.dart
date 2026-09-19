import 'package:brew_path/shared/repositories/install_repository.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/account_wipe.dart';
import 'package:brew_path/shared/storage/snapshot/progress_snapshot.dart';
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

/// The stored progress, and every later version of it.
///
/// The one place the app listens to the database (ADR-0030). It opens on a
/// one-shot read, so a caller that only wants the value now is not left
/// waiting on a subscription, and goes with its last watcher, so no
/// subscription outlives the database it reads.
@riverpod
class ProgressSnapshotState extends _$ProgressSnapshotState {
  @override
  Future<ProgressSnapshot> build() async {
    final repository = ref.watch(snapshotRepositoryProvider);
    // Read first, and only then listen: a value pushed into `state` before the
    // build it belongs to has resolved rebuilds this provider from inside its
    // own construction.
    final stored = await repository.read();
    final changes = repository.watch().skip(1).listen((snapshot) {
      state = AsyncData(snapshot);
    });
    ref.onDispose(changes.cancel);
    return stored;
  }
}

/// Provides the [InstallRepository].
@riverpod
InstallRepository installRepository(Ref ref) => InstallRepository();
