import 'dart:async';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/daily_tasks.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/services/local_db.dart';
import 'package:livre_servico_app/services/sync_engine.dart';
import 'package:livre_servico_app/services/sync_meta.dart';
import 'package:livre_servico_app/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The online database in memory, following the rules of `push_records`
/// and the pull in `supabase/migrations`: last write wins on updated_at,
/// server_updated_at from the server's own clock.
class FakeRemote implements SyncRemote {
  final rows = <String, SyncRecord>{};
  var _clock = DateTime.utc(2026, 10, 30, 12);

  /// Runs while a push is on the network, before the server answers.
  Future<void> Function()? duringPush;

  final _changes = StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<List<SyncRecord>> push(List<SyncRecord> incoming) async {
    await duringPush?.call();
    final newer = <SyncRecord>[];
    for (final r in incoming) {
      final key = '${r.collection}/${r.id}';
      final server = rows[key];
      if (server == null || server.updatedAt.isBefore(r.updatedAt)) {
        _clock = _clock.add(const Duration(milliseconds: 1));
        rows[key] = SyncRecord(
          collection: r.collection,
          id: r.id,
          data: r.data,
          updatedAt: r.updatedAt,
          deletedAt: r.deletedAt,
          serverUpdatedAt: _clock,
        );
        _changes.add(null);
      } else if (server.updatedAt.isAfter(r.updatedAt)) {
        newer.add(server);
      }
    }
    return newer;
  }

  /// What the server gives out of each row it pulls, like `pull_records`
  /// redacting people; the row as it is when null.
  Map<String, dynamic> Function(SyncRecord)? redact;

  @override
  Future<List<SyncRecord>> pull({DateTime? since, required int limit}) async {
    final found = [
      for (final r in rows.values)
        if (since == null || !r.serverUpdatedAt!.isBefore(since)) r,
    ]..sort((a, b) => a.serverUpdatedAt!.compareTo(b.serverUpdatedAt!));
    return [
      for (final r in found.take(limit))
        switch (redact) {
          null => r,
          final f => SyncRecord(
            collection: r.collection,
            id: r.id,
            data: f(r),
            updatedAt: r.updatedAt,
            deletedAt: r.deletedAt,
            serverUpdatedAt: r.serverUpdatedAt,
          ),
        },
    ];
  }

  List<SyncRecord> of(String collection) => [
    for (final r in rows.values)
      if (r.collection == collection) r,
  ];
}

/// One device: its own database, syncing with [remote]. Each device keeps
/// its cursor under its own store id, as the test devices share one set of
/// mock preferences.
class Device {
  Device._(this.db, this.engine);

  static var _count = 0;

  static Future<Device> open(FakeRemote remote) async {
    final db = await LocalDb.open(executor: NativeDatabase.memory());
    final prefs = await SharedPreferences.getInstance();
    return Device._(
      db,
      SyncEngine(
        db: db,
        remote: remote,
        storeId: 'device${_count++}',
        prefs: prefs,
      ),
    );
  }

  final LocalDb db;
  final SyncEngine engine;

  Future<SyncReport> sync() => engine.run();
}

Person person(String name, {DateTime? at}) {
  final p = Person()
    ..fullName = name
    ..createdAt = DateTime(2026, 1, 1);
  SyncMeta.stamp(p);
  if (at != null) p.syncUpdatedAt = at;
  return p;
}

void main() {
  late FakeRemote remote;
  late Device a;
  late Device b;

  // SyncService watches the app coming back to the foreground.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Two devices: two databases on purpose.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    remote = FakeRemote();
    a = await Device.open(remote);
    b = await Device.open(remote);
  });
  tearDown(() async {
    await a.db.close();
    await b.db.close();
  });

  group('people redacted by the server', () {
    Map<String, dynamic> withoutPhone(SyncRecord r) => r.collection == 'Person'
        ? (Map.of(r.data)..remove('phoneNumber'))
        : r.data;

    test('stale full copies are replaced by redacted ones', () async {
      await a.db.persons.put(person('Ana')..phoneNumber = '900');
      await a.sync();
      remote.redact = withoutPhone;

      await SyncEngine.forgetCursor(
        await SharedPreferences.getInstance(),
        a.engine.storeId,
      );
      await a.sync();

      final ana = (await a.db.persons.all()).single;
      expect(ana.phoneNumber, isNull);
      expect(ana.fullName, 'Ana');
      expect(remote.of('Person').single.data['phoneNumber'], '900');
    });

    test('pending local edit survives a redacted copy', () async {
      final ana = person('Ana')..phoneNumber = '900';
      await a.db.persons.put(ana);
      final redacted = Map.of(a.db.persons.syncData(ana))
        ..remove('phoneNumber');
      expect(
        await a.db.persons.applyRemote([
          (key: ana.syncUuid, data: redacted, updatedAt: ana.syncUpdatedAt),
        ], replaceSynced: true),
        0,
      );
      expect((await a.db.persons.all()).single.phoneNumber, '900');
    });

    test('forgetCursor forgets one store only', () async {
      SharedPreferences.setMockInitialValues({
        'syncCursor:s1': '2026-10-30T12:00:00Z',
        'syncCursor:s2': '2026-10-30T12:00:00Z',
      });
      final prefs = await SharedPreferences.getInstance();
      await SyncEngine.forgetCursor(prefs, 's1');
      expect(prefs.getString('syncCursor:s1'), isNull);
      expect(prefs.getString('syncCursor:s2'), isNotNull);
    });
  });

  test('a saved row is pending until pushed', () async {
    await a.db.persons.put(person('Ana'));
    expect((await a.db.persons.all()).single.synced, isFalse);

    final report = await a.sync();

    expect(report.pushed, 1);
    expect((await a.db.persons.all()).single.synced, isTrue);
    expect(remote.of('Person').single.data['fullName'], 'Ana');
    expect((await a.sync()).pushed, 0);
  });

  test('the first sync pushes rows saved before sync existed', () async {
    // As rows from an older version are: never stamped as pending.
    await a.db.persons.put(person('Ana')..synced = true);

    expect((await a.sync()).pushed, 1);
    expect(remote.of('Person'), hasLength(1));
  });

  test(
    'a row saved on one device reaches the other, then its changes',
    () async {
      final ana = person('Ana');
      await a.db.persons.put(ana);
      await a.sync();
      await b.sync();

      final onB = (await b.db.persons.all()).single;
      expect(onB.fullName, 'Ana');
      expect(onB.syncUuid, ana.syncUuid);
      expect(onB.synced, isTrue);

      ana.fullName = 'Ana Silva';
      SyncMeta.stamp(ana);
      await a.db.persons.put(ana);
      await a.sync();
      await b.sync();
      expect((await b.db.persons.all()).single.fullName, 'Ana Silva');

      await a.db.persons.softDelete(ana.id);
      await a.sync();
      await b.sync();
      expect(await b.db.persons.all(), isEmpty);
      expect(await b.db.persons.all(includeDeleted: true), hasLength(1));
    },
  );

  test('the row saved last wins on both devices', () async {
    final ana = person('Ana', at: DateTime(2026, 10, 30, 10));
    await a.db.persons.put(ana);
    await a.sync();
    await b.sync();

    final t = DateTime(2026, 10, 30, 15);
    final onA = (await a.db.persons.all()).single
      ..fullName = 'Ana (A)'
      ..syncUpdatedAt = t
      ..synced = false;
    await a.db.persons.put(onA);
    final onB = (await b.db.persons.all()).single
      ..fullName = 'Ana (B)'
      ..syncUpdatedAt = t.add(const Duration(minutes: 1))
      ..synced = false;
    await b.db.persons.put(onB);

    // B pushes first; A's push then loses and A takes B's copy.
    await b.sync();
    await a.sync();
    await b.sync();

    expect((await a.db.persons.all()).single.fullName, 'Ana (B)');
    expect((await b.db.persons.all()).single.fullName, 'Ana (B)');
    expect((await a.db.persons.all()).single.synced, isTrue);
  });

  test(
    'a pulled row older than a pending local one does not replace it',
    () async {
      final ana = person('Ana', at: DateTime(2026, 10, 30, 10));
      await a.db.persons.put(ana);
      await a.sync();
      await b.sync();

      // A saves again after B, but syncs before B pushes.
      final onB = (await b.db.persons.all()).single
        ..fullName = 'Ana (B)'
        ..syncUpdatedAt = DateTime(2026, 10, 30, 11)
        ..synced = false;
      await b.db.persons.put(onB);
      ana
        ..fullName = 'Ana (A)'
        ..syncUpdatedAt = DateTime(2026, 10, 30, 12)
        ..synced = false;
      await a.db.persons.put(ana);
      await a.sync();
      await b.sync();

      expect((await b.db.persons.all()).single.fullName, 'Ana (A)');
      expect(remote.of('Person').single.data['fullName'], 'Ana (A)');
    },
  );

  test('one row per service day: two devices share it', () async {
    final day = DateTime(2026, 10, 30, 5);
    final onA = DailyTasks()
      ..serviceDay = day
      ..alteracoesPrecoCount = 3;
    SyncMeta.stamp(onA);
    onA.syncUpdatedAt = DateTime(2026, 10, 30, 8);
    await a.db.dailyTasks.put(onA);
    final onB = DailyTasks()
      ..serviceDay = day
      ..alteracoesPrecoCount = 5;
    SyncMeta.stamp(onB);
    onB.syncUpdatedAt = DateTime(2026, 10, 30, 9);
    await b.db.dailyTasks.put(onB);

    await a.sync();
    await b.sync();
    await a.sync();

    expect(remote.of('DailyTasks').single.id, '2026-10-30');
    for (final d in [a, b]) {
      final rows = await d.db.dailyTasks.all();
      expect(rows, hasLength(1));
      expect(rows.single.alteracoesPrecoCount, 5);
    }
  });

  test('a row saved again during its push stays pending', () async {
    final ana = person('Ana');
    await a.db.persons.put(ana);
    remote.duringPush = () async {
      remote.duringPush = null;
      ana.fullName = 'Ana Silva';
      SyncMeta.stamp(ana);
      await a.db.persons.put(ana);
    };

    await a.sync();
    expect((await a.db.persons.all()).single.synced, isFalse);

    await a.sync();
    expect((await a.db.persons.all()).single.synced, isTrue);
    expect(remote.of('Person').single.data['fullName'], 'Ana Silva');
  });

  test('tells listeners which collections a sync changed', () async {
    await a.db.persons.put(person('Ana'));
    await a.sync();

    final changes = <Set<String>>[];
    final sub = LocalDb.remoteChanges.listen(changes.add);
    await b.sync();
    await b.sync();
    await sub.cancel();

    expect(changes, [
      {'Person'},
    ]);
  });

  test('saving tells sync there is something to push', () async {
    final writes = <String>[];
    final sub = LocalDb.localWrites.listen(writes.add);
    await a.db.persons.put(person('Ana'));
    await a.sync();
    await sub.cancel();

    // The sync's own writes (marking rows synced) don't count.
    expect(writes, ['Person']);
  });

  test('a viewer only pulls', () async {
    await a.db.persons.put(person('Ana'));
    await a.sync();
    final viewer = SyncEngine(
      db: b.db,
      remote: remote,
      storeId: 'viewer',
      prefs: await SharedPreferences.getInstance(),
      canPush: false,
    );
    await b.db.persons.put(person('Rui'));

    final report = await viewer.run();

    expect(report.pushed, 0);
    expect(remote.of('Person'), hasLength(1));
    expect(await b.db.persons.all(), hasLength(2));
  });

  test('after forgetCursors every row is pushed again', () async {
    await a.db.persons.put(person('Ana'));
    await a.sync();
    expect((await a.sync()).pushed, 0);

    await SyncEngine.forgetCursors(await SharedPreferences.getInstance());

    expect((await a.sync()).pushed, 1);
  });

  test('server rows round-trip through the push and pull JSON', () {
    final r = SyncRecord.fromServerJson({
      'collection': 'Person',
      'id': 'abc',
      'data': {'fullName': 'Ana'},
      'updated_at': '2026-10-30T12:00:00.123456+00:00',
      'deleted_at': null,
      'server_updated_at': '2026-10-30T12:00:01+00:00',
    });
    expect(r.updatedAt, DateTime.utc(2026, 10, 30, 12, 0, 0, 123, 456));
    expect(r.toPushJson(), {
      'collection': 'Person',
      'id': 'abc',
      'data': {'fullName': 'Ana'},
      'updated_at': '2026-10-30T12:00:00.123456Z',
      'deleted_at': null,
    });
  });

  group('SyncService', () {
    tearDown(SyncService.instance.stop);

    test('a save on another device arrives without waiting a minute', () async {
      final service = SyncService.instance;
      await service.start(remote, 'serviceB', db: b.db);
      expect(service.lastSyncedAt, isNotNull);

      await a.db.persons.put(person('Ana'));
      await a.sync();
      // Realtime's event, then the short wait before syncing.
      await Future<void>.delayed(const Duration(milliseconds: 1600));

      expect((await b.db.persons.all()).single.fullName, 'Ana');
    });

    test('a save here is pushed a few seconds later', () async {
      await SyncService.instance.start(remote, 'serviceA', db: a.db);
      await a.db.persons.put(person('Ana'));
      expect(remote.of('Person'), isEmpty);

      await Future<void>.delayed(const Duration(milliseconds: 3600));

      expect(remote.of('Person'), hasLength(1));
    });

    test('nothing syncs after stop', () async {
      await SyncService.instance.start(remote, 'serviceA', db: a.db);
      SyncService.instance.stop();
      await a.db.persons.put(person('Ana'));

      await Future<void>.delayed(const Duration(milliseconds: 3600));

      expect(remote.of('Person'), isEmpty);
    });
  });
}
