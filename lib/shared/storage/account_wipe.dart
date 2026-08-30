import 'package:brew_path/shared/repositories/card_repository.dart';
import 'package:brew_path/shared/repositories/install_repository.dart';
import 'package:brew_path/shared/repositories/module_progress_repository.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/snapshot/wipe_snapshot.dart';

/// Reset Progress and Delete Account, as the app performs them.
///
/// **One home for what a wipe clears.** The prototype's reset was hand-written
/// per store and shipped a defect by omitting exactly one of them; naming every
/// store once, here, is what stops the same omission. The decision of *what*
/// each wipe clears is not here at all — that lives in the snapshot's two
/// scopes and in `wipe_snapshot.dart`, which are pure and testable without a
/// database. This class only sequences them.
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
    // zero there is gone: the streak derives from the day set this wipe just
    // emptied, and the points total derives from the completions it cleared.
    // What is left on that row is what the learner *chose*, which a progress
    // reset keeps.
    //
    // That includes `onboardingCompleted` and `tourSeen` together — the two
    // "already introduced" bits fate-share, and here they share by being left
    // alone. Neither is progress: replaying the welcome flow or the Tour is not
    // what someone asks for when they ask to start the course over.
    //
    // The install stamp is left alone for the same reason, and it is the more
    // obviously right of the two: starting the course over does not change the
    // day you joined.
    await _clearLegacyTables();
  }

  /// The same mechanism at full scope, plus the device-local table.
  ///
  /// Device-local state is *not synced* and *not wiped by reset* — two separate
  /// properties, and it has both. Delete is where it goes, because after it
  /// there is no account for the appearance preference, the onboarding answers
  /// or the Tour's `tourSeen` bit to belong to. Dropping the whole row is also
  /// what keeps `onboardingCompleted` and `tourSeen` fate-sharing here: they go
  /// together because nothing gets the chance to clear one of them alone.
  ///
  /// The install stamp is **restamped, not kept and not cleared**. What is left
  /// behind is a fresh install in every other respect — no progress, no
  /// preferences, onboarding replayed — so the account this line dates is the
  /// one beginning now. Keeping the old stamp would tell someone who just
  /// erased everything that they joined months ago; clearing it would send the
  /// line to a fallback meant for devices that never recorded anything.
  Future<void> deleteAccount() async {
    final stored = await _snapshots.read();
    await _snapshots.write(
      deleteTombstone(stored, at: _clock(), deviceId: deviceId),
    );

    await _clearLegacyTables();
    await _settings.deleteAll();
    await _install.recordInstall(DateTime.fromMillisecondsSinceEpoch(_clock()));
  }

  /// The normalised tables the snapshot replaces but has not yet displaced.
  ///
  /// They are still the live store for XP, the streak and cards, so a wipe that
  /// published only the tombstone would leave the app showing progress the
  /// snapshot says is gone. This method dies with the tables themselves.
  Future<void> _clearLegacyTables() async {
    await ProgressRepository().deleteAll();
    await ModuleProgressRepository().deleteAll();
    await CardRepository().deleteAll();
  }

  static int _systemClock() => DateTime.now().millisecondsSinceEpoch;
}
