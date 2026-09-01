import 'package:brew_path/shared/repositories/install_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The install stamp: written once, when the database is created.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final firstRun = DateTime(2026, 3, 14, 9, 30);

  late AppDatabase db;
  late InstallRepository install;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), () => firstRun);
    AppDatabaseService.instance = db;
    install = InstallRepository();
  });

  tearDown(() async {
    await db.close();
  });

  test('creating the database records the instant it happened', () async {
    expect(await install.installedAt(), firstRun);
  });

  test('the stamp is one row, so a reopen cannot add a second', () async {
    // The row is keyed, not appended: two rows would make "when did this
    // account begin" a question with two answers and no rule for choosing.
    expect(await db.select(db.appInstalls).get(), hasLength(1));
  });

  test('the recorded instant survives being read back', () async {
    // A stamp that lost its time to a date-only column would still pass every
    // month-level assertion above it and be wrong the moment anything else
    // needed the instant.
    expect((await install.installedAt())?.hour, firstRun.hour);
  });

  test('restamping replaces the row rather than adding one', () async {
    final later = DateTime(2026, 8, 20);

    await install.recordInstall(later);

    expect(await install.installedAt(), later);
    expect(await db.select(db.appInstalls).get(), hasLength(1));
  });
}
