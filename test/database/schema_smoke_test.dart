import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../generated/schema.dart';
import '../generated/schema_v1.dart' show DatabaseAtV1;
import '../generated/schema_v10.dart' show DatabaseAtV10;
import '../generated/schema_v11.dart' show DatabaseAtV11;
import '../generated/schema_v12.dart' show DatabaseAtV12;
import '../generated/schema_v2.dart' show DatabaseAtV2;
import '../generated/schema_v3.dart' show DatabaseAtV3;
import '../generated/schema_v4.dart' show DatabaseAtV4;
import '../generated/schema_v5.dart' show DatabaseAtV5;
import '../generated/schema_v6.dart' show DatabaseAtV6;
import '../generated/schema_v7.dart' show DatabaseAtV7;
import '../generated/schema_v8.dart' show DatabaseAtV8;
import '../generated/schema_v9.dart' show DatabaseAtV9;

/// The newest schema dumped to `drift_schemas/`. Read from the generated
/// helper rather than written as a literal: every data-integrity case below
/// upgrades *to the current version*, and a literal there means a schema bump
/// silently keeps testing the old target — a bump editing a file that never
/// mentions it. The first test keeps this honest against the app's own
/// `schemaVersion`.
final int _currentVersion = GeneratedHelper.versions.last;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('the dumped schemas keep pace with the database', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final declared = db.schemaVersion;
    await db.close();

    expect(
      declared,
      _currentVersion,
      reason:
          'AppDatabase.schemaVersion and the newest file in drift_schemas/ '
          'disagree. Either the version was bumped without dumping the schema '
          '(`dart run drift_dev schema dump …`, then `schema generate …`), or '
          'a schema was dumped without bumping the version. Until they agree, '
          'every migration test below validates against the wrong target.',
    );
  });

  test('schema v1 database opens with the expected tables', () async {
    final connection = await verifier.startAt(1);
    final db = DatabaseAtV1(connection);
    await db.customSelect('SELECT 1').get();

    expect(db.schemaVersion, 1);
    expect(db.allTables.map((t) => t.actualTableName).toSet(), {
      'progress_records',
      'card_records',
      'user_settings',
    });

    await db.close();
  });

  test('schema v2 database opens with the module-progress table', () async {
    final connection = await verifier.startAt(2);
    final db = DatabaseAtV2(connection);
    await db.customSelect('SELECT 1').get();

    expect(db.schemaVersion, 2);
    expect(db.allTables.map((t) => t.actualTableName).toSet(), {
      'progress_records',
      'card_records',
      'user_settings',
      'module_progress_records',
    });

    await db.close();
  });

  test('AppDatabase migrates a v1 database to the current schema', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);

    // The chained onUpgrade brings a v1 file all the way up in one open.
    // Targeting `db.schemaVersion` rather than a literal keeps this honest
    // across bumps: it asserts the migrated database matches the committed
    // snapshot for whatever the current version is, instead of going stale
    // the way a hardcoded 3 just did.
    await verifier.migrateAndValidate(db, db.schemaVersion);

    await db.close();
  });

  test(
    'schema v3 database has the onboarding columns on user_settings',
    () async {
      final connection = await verifier.startAt(3);
      final db = DatabaseAtV3(connection);
      await db.customSelect('SELECT 1').get();

      expect(db.schemaVersion, 3);

      // Confirm the three new columns exist by selecting them.
      final columns = await db
          .customSelect('PRAGMA table_info(user_settings)')
          .get();
      final names = columns.map((r) => r.read<String>('name')).toSet();
      expect(
        names,
        containsAll(<String>[
          'onboarding_completed',
          'onboarding_goal',
          'onboarding_brewer',
        ]),
      );

      await db.close();
    },
  );

  test('AppDatabase migrates a v2 database to the current schema', () async {
    final connection = await verifier.startAt(2);
    final db = AppDatabase(connection);

    await verifier.migrateAndValidate(db, db.schemaVersion);

    await db.close();
  });

  test('schema v4 database has theme_mode on user_settings', () async {
    final connection = await verifier.startAt(4);
    final db = DatabaseAtV4(connection);
    await db.customSelect('SELECT 1').get();

    expect(db.schemaVersion, 4);

    final columns = await db
        .customSelect('PRAGMA table_info(user_settings)')
        .get();
    expect(
      columns.map((r) => r.read<String>('name')),
      contains('theme_mode'),
    );

    await db.close();
  });

  test(
    'AppDatabase migrates a v3 database to v4 and defaults to dark',
    () async {
      final connection = await verifier.startAt(3);
      final db = AppDatabase(connection);

      await verifier.migrateAndValidate(db, db.schemaVersion);

      // The column is added with a default rather than as nullable, so a row
      // written before v4 reads back as the default mood instead of null.
      final rows = await db
          .customSelect(
            "SELECT dflt_value FROM pragma_table_info('user_settings') "
            "WHERE name = 'theme_mode'",
          )
          .get();
      expect(rows.single.read<String>('dflt_value'), "'dark'");

      await db.close();
    },
  );

  test(
    'schema v5 database replaces best_score with the mastery pair',
    () async {
      final connection = await verifier.startAt(5);
      final db = DatabaseAtV5(connection);
      final cols = await db
          .customSelect('PRAGMA table_info(progress_records)')
          .get();
      final names = cols.map((r) => r.read<String>('name')).toSet();

      expect(names, containsAll(<String>['correct_count', 'graded_total']));
      expect(names, isNot(contains('best_score')));

      await db.close();
    },
  );

  test('a v4 row carrying a best_score goes with its table', () async {
    // The oldest shape of the completions table, seeded so the chain is
    // exercised on a populated database rather than an empty one. Nothing
    // converts the old percentage: the table it is on is dropped at v13, and
    // what a learner scored has been on the snapshot since #115.
    await verifier.testWithDataIntegrity(
      oldVersion: 4,
      newVersion: _currentVersion,
      createOld: DatabaseAtV4.new,
      createNew: (executor) =>
          GeneratedHelper().databaseForVersion(executor, _currentVersion),
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(
        oldDb.progressRecords,
        RawValuesInsertable<dynamic>({
          'lesson_id': const Variable<String>('lesson_legacy'),
          'is_completed': const Variable<bool>(true),
          'xp_earned': const Variable<int>(50),
          'completed_at': Variable<DateTime>(DateTime(2026)),
          'full_xp_awarded': const Variable<bool>(true),
          'best_score': const Variable<int>(80),
        }),
      ),
      validateItems: (newDb) async {
        // The row is gone with its table, and the point of the case is that a
        // v4 database carrying one still arrives at v13 rather than failing on
        // a step that no longer has a table to work on.
        expect(await _tableNames(newDb), isNot(contains('progress_records')));
      },
    );
  });

  test('schema v6 database adds the progress-snapshot table', () async {
    final connection = await verifier.startAt(6);
    final db = DatabaseAtV6(connection);
    await db.customSelect('SELECT 1').get();

    expect(db.schemaVersion, 6);
    expect(
      db.allTables.map((t) => t.actualTableName).toSet(),
      contains('progress_snapshots'),
    );

    await db.close();
  });

  test(
    'a v5 database upgrades keeping the row it is allowed to keep',
    () async {
      // A populated older database carrying both kinds of row: one on a table
      // v13 drops, one on the table it keeps. A migration only ever exercised
      // on an empty database proves nothing about either.
      await verifier.testWithDataIntegrity(
        oldVersion: 5,
        newVersion: _currentVersion,
        createOld: DatabaseAtV5.new,
        createNew: (executor) =>
            GeneratedHelper().databaseForVersion(executor, _currentVersion),
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) {
          batch.insert(
            oldDb.progressRecords,
            RawValuesInsertable<dynamic>({
              'lesson_id': const Variable<String>('lesson_before_v6'),
              'is_completed': const Variable<bool>(true),
              'xp_earned': const Variable<int>(10),
              'completed_at': Variable<DateTime>(DateTime(2026)),
              'correct_count': const Variable<int>(4),
              'graded_total': const Variable<int>(5),
            }),
          );
          batch.insert(
            oldDb.userSettings,
            const RawValuesInsertable<dynamic>({
              'id': Variable<int>(1),
              'haptics_enabled': Variable<bool>(false),
              'sound_enabled': Variable<bool>(true),
              'total_xp': Variable<int>(70),
              'streak_days': Variable<int>(0),
              'onboarding_completed': Variable<bool>(true),
              'theme_mode': Variable<String>('light'),
            }),
          );
        },
        validateItems: (newDb) async {
          // The table the completion was on is gone by v13; the table it was
          // replaced by exists and is empty.
          expect(await _tableNames(newDb), isNot(contains('progress_records')));
          final snapshots = await newDb
              .customSelect('SELECT COUNT(*) AS n FROM progress_snapshots')
              .get();
          expect(snapshots.single.read<int>('n'), 0);

          // What the learner chose crosses eight versions untouched.
          final settings = await newDb
              .customSelect(
                'SELECT theme_mode, haptics_enabled, onboarding_completed '
                'FROM user_settings',
              )
              .get();
          expect(settings.single.read<String>('theme_mode'), 'light');
          expect(settings.single.read<bool>('haptics_enabled'), false);
          expect(settings.single.read<bool>('onboarding_completed'), true);
        },
      );
    },
  );

  test('schema v7 database has dropped the dead streak columns', () async {
    final connection = await verifier.startAt(7);
    final db = DatabaseAtV7(connection);
    await db.customSelect('SELECT 1').get();

    expect(db.schemaVersion, 7);

    final columns = await db
        .customSelect('PRAGMA table_info(user_settings)')
        .get();
    final names = columns.map((r) => r.read<String>('name')).toSet();
    expect(names, isNot(contains('streak_days')));
    expect(names, isNot(contains('last_activity_date')));
    // The row still holds what the learner chose.
    expect(
      names,
      containsAll(<String>['theme_mode', 'haptics_enabled', 'total_xp']),
    );

    await db.close();
  });

  test('a v6 database upgrades keeping what the learner chose', () async {
    // The one case that can lose data. Dropping a column means recreating the
    // table, and a recreate that copied the wrong set would silently reset a
    // learner's appearance and onboarding answers — which survive a reset by
    // design, so nothing else would catch it.
    await verifier.testWithDataIntegrity(
      oldVersion: 6,
      newVersion: _currentVersion,
      createOld: DatabaseAtV6.new,
      createNew: (executor) =>
          GeneratedHelper().databaseForVersion(executor, _currentVersion),
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(
        oldDb.userSettings,
        const RawValuesInsertable<dynamic>({
          'id': Variable<int>(1),
          'haptics_enabled': Variable<bool>(false),
          'sound_enabled': Variable<bool>(false),
          'total_xp': Variable<int>(120),
          // The two being dropped, carrying the values a real device holds:
          // zero and null, because nothing has advanced them since the streak
          // moved onto the day set.
          'streak_days': Variable<int>(0),
          'last_activity_date': Variable<DateTime>(null),
          'onboarding_completed': Variable<bool>(true),
          'onboarding_goal': Variable<String>('brew_better'),
          'onboarding_brewer': Variable<String>('v60'),
          'theme_mode': Variable<String>('light'),
        }),
      ),
      validateItems: (newDb) async {
        final rows = await newDb
            .customSelect(
              'SELECT haptics_enabled, sound_enabled, onboarding_completed, '
              'onboarding_goal, onboarding_brewer, theme_mode '
              'FROM user_settings',
            )
            .get();

        expect(rows, hasLength(1));
        final row = rows.single;
        expect(row.read<String>('theme_mode'), 'light');
        expect(row.read<String>('onboarding_goal'), 'brew_better');
        expect(row.read<String>('onboarding_brewer'), 'v60');
        expect(row.read<bool>('onboarding_completed'), true);
        expect(row.read<bool>('haptics_enabled'), false);
        expect(row.read<bool>('sound_enabled'), false);
      },
    );
  });
  test('schema v8 database has tour_seen on user_settings', () async {
    final connection = await verifier.startAt(8);
    final db = DatabaseAtV8(connection);
    await db.customSelect('SELECT 1').get();

    expect(db.schemaVersion, 8);

    final columns = await db
        .customSelect('PRAGMA table_info(user_settings)')
        .get();
    expect(
      columns.map((r) => r.read<String>('name')),
      contains('tour_seen'),
    );

    await db.close();
  });

  test('a v7 database upgrades with the Tour unseen', () async {
    // The added column defaults rather than backfills, and this is what says
    // so: a device that has been through onboarding but predates the Tour must
    // arrive at v8 offered the Tour, not skipped past it. Everything else on
    // the row is asserted alongside, because an additive step that silently
    // rewrote a preference would look identical from the column's side.
    await verifier.testWithDataIntegrity(
      oldVersion: 7,
      newVersion: _currentVersion,
      createOld: DatabaseAtV7.new,
      createNew: (executor) =>
          GeneratedHelper().databaseForVersion(executor, _currentVersion),
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(
        oldDb.userSettings,
        const RawValuesInsertable<dynamic>({
          'id': Variable<int>(1),
          'haptics_enabled': Variable<bool>(true),
          'sound_enabled': Variable<bool>(false),
          'total_xp': Variable<int>(240),
          'onboarding_completed': Variable<bool>(true),
          'onboarding_goal': Variable<String>('understand_tasting'),
          'onboarding_brewer': Variable<String>('aeropress'),
          'theme_mode': Variable<String>('light'),
        }),
      ),
      validateItems: (newDb) async {
        final rows = await newDb
            .customSelect(
              'SELECT tour_seen, onboarding_completed, onboarding_goal, '
              'theme_mode FROM user_settings',
            )
            .get();

        expect(rows, hasLength(1));
        final row = rows.single;
        expect(row.read<bool>('tour_seen'), false);
        // The gate it fate-shares with is untouched by the migration: the two
        // only move together when a *wipe* moves them.
        expect(row.read<bool>('onboarding_completed'), true);
        expect(row.read<String>('onboarding_goal'), 'understand_tasting');
        expect(row.read<String>('theme_mode'), 'light');
      },
    );
  });

  test('a v8 database upgrades with no name given', () async {
    // The one start point the chain had no case for. The name arrives at v9
    // nullable rather than backfilled, so a device upgrading from here reads
    // as "no name given" — which is the truth for it, and what the greeting
    // already falls back to.
    await verifier.testWithDataIntegrity(
      oldVersion: 8,
      newVersion: _currentVersion,
      createOld: DatabaseAtV8.new,
      createNew: (executor) =>
          GeneratedHelper().databaseForVersion(executor, _currentVersion),
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(
        oldDb.userSettings,
        const RawValuesInsertable<dynamic>({
          'id': Variable<int>(1),
          'haptics_enabled': Variable<bool>(false),
          'sound_enabled': Variable<bool>(true),
          'total_xp': Variable<int>(90),
          'onboarding_completed': Variable<bool>(true),
          'theme_mode': Variable<String>('system'),
          'tour_seen': Variable<bool>(true),
        }),
      ),
      validateItems: (newDb) async {
        final rows = await newDb
            .customSelect(
              'SELECT learner_name, tour_seen, theme_mode, sound_enabled '
              'FROM user_settings',
            )
            .get();

        expect(rows, hasLength(1));
        final row = rows.single;
        expect(row.readNullable<String>('learner_name'), null);
        // What the learner chose crosses five versions untouched.
        expect(row.read<bool>('tour_seen'), true);
        expect(row.read<String>('theme_mode'), 'system');
        expect(row.read<bool>('sound_enabled'), true);
      },
    );
  });

  test('schema v9 database has neither reminder column yet', () async {
    final connection = await verifier.startAt(9);
    final db = DatabaseAtV9(connection);

    await expectLater(
      db.customSelect('SELECT notifications_enabled FROM user_settings').get(),
      throwsA(isA<Exception>()),
    );

    await db.close();
  });

  test('a v9 database upgrades with no reminder asked for', () async {
    // Both columns default rather than backfill: a device upgrading into the
    // reminder has never been asked about it, so "off, with no time" is the
    // truth for it — and the row must read *Off* rather than a time that will
    // never arrive. The learner's name is asserted alongside, because an
    // additive step that quietly rewrote the row it touched would look the
    // same from the new columns' side.
    await verifier.testWithDataIntegrity(
      oldVersion: 9,
      newVersion: _currentVersion,
      createOld: DatabaseAtV9.new,
      createNew: (executor) =>
          GeneratedHelper().databaseForVersion(executor, _currentVersion),
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(
        oldDb.userSettings,
        const RawValuesInsertable<dynamic>({
          'id': Variable<int>(1),
          'haptics_enabled': Variable<bool>(true),
          'sound_enabled': Variable<bool>(true),
          'total_xp': Variable<int>(0),
          'onboarding_completed': Variable<bool>(true),
          'theme_mode': Variable<String>('dark'),
          'tour_seen': Variable<bool>(true),
          'learner_name': Variable<String>('Sam'),
        }),
      ),
      validateItems: (newDb) async {
        final rows = await newDb
            .customSelect(
              'SELECT notifications_enabled, daily_reminder_time, '
              'learner_name FROM user_settings',
            )
            .get();

        expect(rows, hasLength(1));
        final row = rows.single;
        expect(row.read<bool>('notifications_enabled'), false);
        expect(row.readNullable<String>('daily_reminder_time'), null);
        expect(row.read<String>('learner_name'), 'Sam');
      },
    );
  });

  test('schema v10 database has no install table yet', () async {
    final connection = await verifier.startAt(10);
    final db = DatabaseAtV10(connection);

    // Named against the catalogue rather than by selecting from the table and
    // expecting a throw: any failure at all satisfies that, including one that
    // has nothing to do with the table being absent.
    final tables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    expect(
      tables.map((row) => row.read<String>('name')),
      isNot(contains('app_installs')),
    );

    await db.close();
  });

  test('a v10 database upgrades without inventing an install date', () async {
    // The whole point of the step. This device installed the app before
    // anything recorded when, and the only instant the migration could write
    // is now — the one answer that is certainly wrong. The table therefore
    // arrives empty, and Profile's closing line falls back to the earliest day
    // the learner was active, which is what it read before v11 (#447).
    await verifier.testWithDataIntegrity(
      oldVersion: 10,
      newVersion: _currentVersion,
      createOld: DatabaseAtV10.new,
      createNew: (executor) =>
          GeneratedHelper().databaseForVersion(executor, _currentVersion),
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(
        oldDb.userSettings,
        const RawValuesInsertable<dynamic>({
          'id': Variable<int>(1),
          'haptics_enabled': Variable<bool>(true),
          'sound_enabled': Variable<bool>(true),
          'total_xp': Variable<int>(0),
          'onboarding_completed': Variable<bool>(true),
          'theme_mode': Variable<String>('dark'),
          'tour_seen': Variable<bool>(true),
          'learner_name': Variable<String>('Sam'),
        }),
      ),
      validateItems: (newDb) async {
        final installs = await newDb
            .customSelect('SELECT COUNT(*) AS n FROM app_installs')
            .get();
        expect(installs.single.read<int>('n'), 0);

        // The row the step does not touch is asserted alongside, because a
        // step that quietly rewrote what the learner chose would look the same
        // from the new table's side.
        final settings = await newDb
            .customSelect('SELECT learner_name, tour_seen FROM user_settings')
            .get();
        expect(settings.single.read<String>('learner_name'), 'Sam');
        expect(settings.single.read<bool>('tour_seen'), true);
      },
    );
  });

  test('schema v11 database has no micro-tips column yet', () async {
    final connection = await verifier.startAt(11);
    final db = DatabaseAtV11(connection);

    final columns = await db
        .customSelect('PRAGMA table_info(user_settings)')
        .get();
    expect(
      columns.map((r) => r.read<String>('name')),
      isNot(contains('tips_seen')),
    );

    await db.close();
  });

  test('a v11 database upgrades having been shown no tip', () async {
    // The added column defaults rather than backfills, and this is what says
    // so: a device that has been through onboarding and the Tour but predates
    // the tips must arrive at v12 owed all seven, not skipped past them.
    // Everything else on the row is asserted alongside, because an additive
    // step that silently rewrote a preference would look identical from the
    // column's side.
    await verifier.testWithDataIntegrity(
      oldVersion: 11,
      newVersion: _currentVersion,
      createOld: DatabaseAtV11.new,
      createNew: (executor) =>
          GeneratedHelper().databaseForVersion(executor, _currentVersion),
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(
        oldDb.userSettings,
        const RawValuesInsertable<dynamic>({
          'id': Variable<int>(1),
          'haptics_enabled': Variable<bool>(true),
          'sound_enabled': Variable<bool>(true),
          'total_xp': Variable<int>(0),
          'onboarding_completed': Variable<bool>(true),
          'theme_mode': Variable<String>('light'),
          'tour_seen': Variable<bool>(true),
          'learner_name': Variable<String>('Sam'),
        }),
      ),
      validateItems: (newDb) async {
        final settings = await newDb
            .customSelect(
              'SELECT tips_seen, tour_seen, learner_name, theme_mode '
              'FROM user_settings',
            )
            .get();

        expect(settings, hasLength(1));
        final row = settings.single;
        expect(row.read<String>('tips_seen'), '');
        // The bits it sits beside are untouched by the migration: they only
        // move together when a *wipe* moves them.
        expect(row.read<bool>('tour_seen'), true);
        expect(row.read<String>('learner_name'), 'Sam');
        expect(row.read<String>('theme_mode'), 'light');
      },
    );
  });

  test('schema v12 database still holds the store v13 drops', () async {
    final connection = await verifier.startAt(12);
    final db = DatabaseAtV12(connection);
    await db.customSelect('SELECT 1').get();

    expect(db.schemaVersion, 12);
    // Off SQLite, not off the generated `allTables`: what the next test needs
    // is that the tables are really on disk at v12, which a static list of
    // what v12 declared cannot say.
    expect(
      await _tableNames(db),
      containsAll(<String>[
        'progress_records',
        'module_progress_records',
        'card_records',
      ]),
    );

    final columns = await db
        .customSelect('PRAGMA table_info(user_settings)')
        .get();
    expect(columns.map((r) => r.read<String>('name')), contains('total_xp'));

    await db.close();
  });

  test('a v12 database upgrades with the old store gone', () async {
    // The shipped version, carrying a row in every table the step drops and a
    // full settings row beside them. Destructive by ruling (#116): the rows go
    // and nothing is owed for them, but device-local state is not progress and
    // must cross the step untouched.
    await verifier.testWithDataIntegrity(
      oldVersion: 12,
      newVersion: _currentVersion,
      createOld: DatabaseAtV12.new,
      createNew: (executor) =>
          GeneratedHelper().databaseForVersion(executor, _currentVersion),
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch
          ..insert(
            oldDb.progressRecords,
            RawValuesInsertable<dynamic>({
              'lesson_id': const Variable<String>('m1l1'),
              'is_completed': const Variable<bool>(true),
              'xp_earned': const Variable<int>(10),
              'completed_at': Variable<DateTime>(DateTime(2026, 8, 23)),
              'full_xp_awarded': const Variable<bool>(true),
              'correct_count': const Variable<int>(4),
              'graded_total': const Variable<int>(5),
            }),
          )
          ..insert(
            oldDb.moduleProgressRecords,
            const RawValuesInsertable<dynamic>({
              'module_id': Variable<String>('m1'),
              'module_xp_awarded': Variable<bool>(true),
            }),
          )
          ..insert(
            oldDb.cardRecords,
            RawValuesInsertable<dynamic>({
              'card_id': const Variable<String>('c1'),
              'unlocked_at': Variable<DateTime>(DateTime(2026, 8, 23)),
            }),
          )
          ..insert(
            oldDb.userSettings,
            const RawValuesInsertable<dynamic>({
              'id': Variable<int>(1),
              'haptics_enabled': Variable<bool>(false),
              'sound_enabled': Variable<bool>(true),
              'total_xp': Variable<int>(120),
              'onboarding_completed': Variable<bool>(true),
              'onboarding_goal': Variable<String>('brew_better'),
              'onboarding_brewer': Variable<String>('v60'),
              'theme_mode': Variable<String>('light'),
              'tour_seen': Variable<bool>(true),
              'tips_seen': Variable<String>('path,saved'),
              'learner_name': Variable<String>('Maya'),
              'notifications_enabled': Variable<bool>(true),
              'daily_reminder_time': Variable<String>('08:00'),
            }),
          );
      },
      validateItems: (newDb) async {
        expect(
          await _tableNames(newDb),
          isNot(
            anyElement(
              isIn(<String>[
                'progress_records',
                'module_progress_records',
                'card_records',
              ]),
            ),
          ),
        );

        final columns = await newDb
            .customSelect('PRAGMA table_info(user_settings)')
            .get();
        expect(
          columns.map((r) => r.read<String>('name')),
          isNot(contains('total_xp')),
        );

        // Everything left on the row is device-local, and a reset keeps it —
        // so a drop that quietly rewrote any of it would go unnoticed until a
        // learner opened the app on the wrong appearance.
        final settings = await newDb
            .customSelect(
              'SELECT haptics_enabled, sound_enabled, onboarding_completed, '
              'onboarding_goal, onboarding_brewer, theme_mode, tour_seen, '
              'tips_seen, learner_name, notifications_enabled, '
              'daily_reminder_time FROM user_settings',
            )
            .get();
        expect(settings, hasLength(1));
        final row = settings.single;
        expect(row.read<bool>('haptics_enabled'), false);
        expect(row.read<bool>('sound_enabled'), true);
        expect(row.read<bool>('onboarding_completed'), true);
        expect(row.read<String>('onboarding_goal'), 'brew_better');
        expect(row.read<String>('onboarding_brewer'), 'v60');
        expect(row.read<String>('theme_mode'), 'light');
        expect(row.read<bool>('tour_seen'), true);
        expect(row.read<String>('tips_seen'), 'path,saved');
        expect(row.read<String>('learner_name'), 'Maya');
        expect(row.read<bool>('notifications_enabled'), true);
        expect(row.read<String>('daily_reminder_time'), '08:00');
      },
    );
  });
}

/// The tables a migrated database actually has, read off SQLite rather than
/// off a generated definition, which would only say what was declared.
Future<Set<String>> _tableNames(GeneratedDatabase db) async {
  final rows = await db
      .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
      .get();
  return rows.map((row) => row.read<String>('name')).toSet();
}
