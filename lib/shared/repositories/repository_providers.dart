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
/// The one place the app listens for progress (ADR-0030). It opens on a
/// one-shot read, so a caller that only wants the value now is not left
/// waiting on an announcement, and outlives every screen, because a write
/// nobody is listening for is an announcement lost.
@Riverpod(keepAlive: true)
class ProgressSnapshotState extends _$ProgressSnapshotState {
  @override
  Future<ProgressSnapshot> build() {
    final repository = ref.watch(snapshotRepositoryProvider);
    // Listening first leaves no gap for a write to fall through, and costs
    // nothing: the stream carries later versions only, so nothing arrives
    // before the read below resolves.
    final changes = repository.changes.listen((snapshot) {
      state = AsyncData(snapshot);
    });
    ref.onDispose(changes.cancel);
    return repository.read();
  }
}

/// Provides the [InstallRepository].
@riverpod
InstallRepository installRepository(Ref ref) => InstallRepository();
