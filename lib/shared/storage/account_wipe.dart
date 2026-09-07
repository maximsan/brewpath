import 'package:brew_path/shared/repositories/install_repository.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/snapshot/wipe_snapshot.dart';

/// Reset Progress and Delete Account, as the app performs them.
///
/// **One home for what a wipe clears**, so no store is left out the way the
/// prototype's hand-written reset left one out. *What* each wipe clears is not
/// here: that is the snapshot's two scopes and `wipe_snapshot.dart`, which are
/// pure and testable without a database. This class only sequences them.
class AccountWipe {
  /// Creates an [AccountWipe]. [clock] is injected so the published tombstone's
  /// stamp is a test input rather than the wall clock.
  AccountWipe({this.deviceId = unidentifiedDevice, int Function()? clock})
    : _clock = clock ?? _systemClock;

  /// The stamp a tombstone carries when the device has no identity yet.
  ///
  /// Nothing publishes the snapshot off-device: the sync transport is
  /// deliberately absent, and the identity that would name this device arrives
  /// with it. Until then the field is inert — it exists only to break
  /// same-millisecond ties between two devices, and there is only one.
  static const unidentifiedDevice = '';

  /// Identifies this device on the tombstones it publishes.
  final String deviceId;

  final int Function() _clock;

  final SnapshotRepository _snapshots = SnapshotRepository();
  final SettingsRepository _settings = SettingsRepository();
  final InstallRepository _install = InstallRepository();

  /// Clears everything the learner earned, and keeps everything they chose.
  ///
  /// The published snapshot is the whole mechanism: an empty progress scope at
  /// generation + 1, which a second device adopts in place of its own progress
  /// rather than merging with it.
  Future<void> resetProgress() async {
    final stored = await _snapshots.read();
    await _snapshots.write(
      resetTombstone(stored, at: _clock(), deviceId: deviceId),
    );

    // The settings row is deliberately untouched. Everything a reset used to
    // zero there derives from what this wipe has just emptied, so what is left
    // is what the learner *chose*, which a reset keeps.

    // `onboardingCompleted`, `tourSeen` and `tipsSeen` fate-share by being
    // left alone — none of them is progress. Nor is the install stamp:
    // starting the course over does not change the day you joined.
  }

  /// The same mechanism at full scope, plus the device-local table.
  ///
  /// Device-local state is not synced *and* not wiped by reset, so Delete is
  /// where it goes. Dropping the whole row is what keeps the appearance, the
  /// onboarding answers, `tourSeen` and `tipsSeen` fate-sharing. The install
  /// stamp is restamped, not kept and not cleared (ADR-0013).
  Future<void> deleteAccount() async {
    final stored = await _snapshots.read();
    await _snapshots.write(
      deleteTombstone(stored, at: _clock(), deviceId: deviceId),
    );

    await _settings.deleteAll();
    await _install.recordInstall(DateTime.fromMillisecondsSinceEpoch(_clock()));
  }

  static int _systemClock() => DateTime.now().millisecondsSinceEpoch;
}
