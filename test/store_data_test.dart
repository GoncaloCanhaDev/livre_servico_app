import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/services/local_db.dart';
import 'package:livre_servico_app/services/store_data.dart';
import 'package:livre_servico_app/services/sync_meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalDb db;
  late SharedPreferences prefs;

  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = await LocalDb.open(executor: NativeDatabase.memory());
  });
  tearDown(() => db.close());

  Future<Person> ana({bool synced = true}) async {
    final p = Person()
      ..fullName = 'Ana'
      ..createdAt = DateTime(2026);
    SyncMeta.stamp(p);
    p.synced = synced;
    await db.persons.put(p);
    return p;
  }

  test("data from before any store joins the first store", () async {
    await ana(synced: false);
    expect(replacesLocalDataOf(prefs, 's1'), isFalse);
    await prepareLocalDataFor(db, prefs, 's1');
    expect(await db.persons.all(), hasLength(1));
    expect(prefs.getString(localDataStoreKey), 's1');
  });

  test('the same store keeps its data', () async {
    await prepareLocalDataFor(db, prefs, 's1');
    await ana();
    expect(replacesLocalDataOf(prefs, 's1'), isFalse);
    await prepareLocalDataFor(db, prefs, 's1');
    expect(await db.persons.all(), hasLength(1));
  });

  test("another store's data leaves the phone, not the server", () async {
    await prepareLocalDataFor(db, prefs, 's1');
    await ana();
    await prefs.setString('syncCursor:s2', '2026-10-30T12:00:00Z');
    expect(replacesLocalDataOf(prefs, 's2'), isTrue);

    await prepareLocalDataFor(db, prefs, 's2');

    expect(await db.persons.all(includeDeleted: true), isEmpty);
    expect(await db.persons.toPush(all: true), isEmpty);
    expect(prefs.getString('syncCursor:s2'), isNull);
    expect(prefs.getString(localDataStoreKey), 's2');
  });

  test('changes not yet sent stop the switch', () async {
    await prepareLocalDataFor(db, prefs, 's1');
    await ana(synced: false);
    await expectLater(
      prepareLocalDataFor(db, prefs, 's2'),
      throwsA(isA<PendingChangesException>()),
    );
    expect(await db.persons.all(), hasLength(1));
    expect(prefs.getString(localDataStoreKey), 's1');
  });

  test(
    'a move clears even unsent changes, which the old store would refuse',
    () async {
      await prepareLocalDataFor(db, prefs, 's1');
      await ana(synced: false);
      await prepareLocalDataFor(db, prefs, 's2', force: true);
      expect(await db.persons.all(includeDeleted: true), isEmpty);
      expect(prefs.getString(localDataStoreKey), 's2');
    },
  );
}
