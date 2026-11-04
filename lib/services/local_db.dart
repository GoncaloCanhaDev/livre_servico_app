import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auto2_entry.dart';
import '../models/auto_list.dart';
import '../models/aviso.dart';
import '../models/custom_task.dart';
import '../models/daily_tasks.dart';
import '../models/info_entry.dart';
import '../models/inventory.dart';
import '../models/local_row.dart';
import '../models/opening_list.dart';
import '../models/pedido.dart';
import '../models/person.dart';
import '../models/report_list.dart';
import '../models/truck_reception.dart';
import '../models/visual_list.dart';
import '../models/weekly_tasks.dart';
import 'sync_meta.dart';

/// The app's local database: SQLite through Drift, on the phone and (with
/// sqlite3.wasm and drift_worker.js in `web/`) in the browser.
///
/// Every row is one JSON document in a single table, `local_rows`, keyed by
/// (collection, id), the way the online database keeps them (`records`).
/// Each collection is read into memory when the app starts and queried in
/// Dart; writes go to SQLite first, then to memory.
///
/// For sync (see `SyncEngine`), a row saved by the app is pending until
/// pushed ([SyncedRow.synced] false); rows from the server are written with
/// [LocalCollection.applyRemote], which tells listeners of [remoteChanges].
class LocalDb {
  LocalDb._(this._db);

  static late LocalDb instance;

  final _Database _db;

  final truckReceptions = LocalCollection<TruckReception>._(
    'TruckReception',
    TruckReception.fromJson,
  );
  final openingLists = LocalCollection<OpeningList>._(
    'OpeningList',
    OpeningList.fromJson,
    syncKey: (l) => dayKey(l.serviceDay),
  );
  final autoLists = LocalCollection<AutoList>._('AutoList', AutoList.fromJson);
  final auto2Entries = LocalCollection<Auto2Entry>._(
    'Auto2Entry',
    Auto2Entry.fromJson,
  );
  final reportLists = LocalCollection<ReportList>._(
    'ReportList',
    ReportList.fromJson,
    syncKey: (l) => dayKey(l.serviceDay),
  );
  final visualLists = LocalCollection<VisualList>._(
    'VisualList',
    VisualList.fromJson,
  );
  final dailyTasks = LocalCollection<DailyTasks>._(
    'DailyTasks',
    DailyTasks.fromJson,
    syncKey: (t) => dayKey(t.serviceDay),
  );
  final weeklyTasks = LocalCollection<WeeklyTasks>._(
    'WeeklyTasks',
    WeeklyTasks.fromJson,
    syncKey: (t) => dayKey(t.serviceWeek),
  );
  final inventories = LocalCollection<Inventory>._(
    'Inventory',
    Inventory.fromJson,
  );
  final infoEntries = LocalCollection<InfoEntry>._(
    'InfoEntry',
    InfoEntry.fromJson,
  );
  final pedidos = LocalCollection<Pedido>._('Pedido', Pedido.fromJson);
  final persons = LocalCollection<Person>._('Person', Person.fromJson);
  final customTasks = LocalCollection<CustomTask>._(
    'CustomTask',
    CustomTask.fromJson,
  );
  final customTaskEntries = LocalCollection<CustomTaskEntry>._(
    'CustomTaskEntry',
    CustomTaskEntry.fromJson,
    syncKey: (e) => '${e.taskUuid}/${dayKey(e.periodKey)}',
  );

  final avisos = LocalCollection<Aviso>._('Aviso', Aviso.fromJson);
  final avisoVistos = LocalCollection<AvisoVisto>._(
    'AvisoVisto',
    AvisoVisto.fromJson,
    syncKey: (v) => '${v.avisoId}/${v.personId}',
  );

  late final List<LocalCollection<SyncedRow>> collections = [
    truckReceptions,
    openingLists,
    autoLists,
    auto2Entries,
    reportLists,
    visualLists,
    dailyTasks,
    weeklyTasks,
    inventories,
    infoEntries,
    pedidos,
    persons,
    customTasks,
    customTaskEntries,
    avisos,
    avisoVistos,
  ];

  /// Set once [backfillSync] has run at startup: rows saved since are
  /// stamped when written, so it isn't needed again.
  static const _backfilledKey = 'syncBackfilled';

  static final _localWrites = StreamController<String>.broadcast(sync: true);
  static final _remoteChanges = StreamController<Set<String>>.broadcast(
    sync: true,
  );

  /// The name of a collection each time the app saves rows in it that are
  /// then pending a push.
  static Stream<String> get localWrites => _localWrites.stream;

  /// The names of the collections that rows from the server changed, once
  /// per sync that changed any.
  static Stream<Set<String>> get remoteChanges => _remoteChanges.stream;

  /// Calls [onChange] whenever rows from the server change one of
  /// [collections]: services refresh their screens with it.
  static StreamSubscription<Set<String>> listenRemote(
    Set<String> collections,
    void Function() onChange,
  ) => remoteChanges.listen((changed) {
    if (changed.any(collections.contains)) onChange();
  });

  static void notifyRemoteChanges(Set<String> collections) {
    if (collections.isNotEmpty) _remoteChanges.add(collections);
  }

  /// Opens the database (on the device, or [executor] in tests, e.g.
  /// `NativeDatabase.memory()`) and reads every collection into memory.
  static Future<void> init({QueryExecutor? executor}) async {
    final local = await open(executor: executor);
    instance = local;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_backfilledKey) != true) {
      await local.backfillSync();
      await prefs.setBool(_backfilledKey, true);
    }
  }

  /// Opens a database without making it [instance]: [init] for the app, or
  /// a second device in sync tests.
  static Future<LocalDb> open({QueryExecutor? executor}) async {
    final db = _Database(
      executor ??
          driftDatabase(
            name: 'livre_servico',
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            ),
          ),
    );
    final local = LocalDb._(db);
    for (final c in local.collections) {
      c._db = db;
    }
    await local._load();
    return local;
  }

  Future<void> close() => _db.close();

  /// Runs [action] in one SQLite transaction: either every write in it is
  /// saved or none is.
  Future<T> transaction<T>(Future<T> Function() action) async {
    try {
      return await _db.transaction(action);
    } catch (_) {
      // Memory may hold writes SQLite rolled back: read it all again.
      await _load();
      rethrow;
    }
  }

  Future<void> _load() async {
    final byName = {for (final c in collections) c.name: c};
    for (final c in collections) {
      c._clearMemory();
    }
    final rows = await _db
        .customSelect('SELECT collection, id, data FROM local_rows')
        .get();
    for (final r in rows) {
      final c = byName[r.read<String>('collection')];
      if (c == null) continue;
      final data = jsonDecode(r.read<String>('data'));
      if (data is! Map<String, dynamic>) continue;
      c._remember(r.read<int>('id'), data);
    }
  }

  // ---- Photos (see PhotoStore) ----
  // Kept in their own table, read one at a time, never all at startup.

  Future<Uint8List?> photo(String name) async {
    final row = await _db
        .customSelect(
          'SELECT bytes FROM local_photos WHERE name = ?',
          variables: [Variable.withString(name)],
        )
        .getSingleOrNull();
    return row?.read<Uint8List>('bytes');
  }

  Future<void> putPhoto(
    String name,
    Uint8List bytes, {
    required bool uploaded,
  }) => _db.customStatement(
    'INSERT OR REPLACE INTO local_photos (name, bytes, uploaded) '
    'VALUES (?, ?, ?)',
    [name, bytes, uploaded ? 1 : 0],
  );

  /// The photos saved here that aren't online yet.
  Future<List<String>> photosToUpload() async => [
    for (final r
        in await _db
            .customSelect('SELECT name FROM local_photos WHERE uploaded = 0')
            .get())
      r.read<String>('name'),
  ];

  Future<void> markPhotoUploaded(String name) => _db.customStatement(
    'UPDATE local_photos SET uploaded = 1 WHERE name = ?',
    [name],
  );

  Future<void> deletePhoto(String name) =>
      _db.customStatement('DELETE FROM local_photos WHERE name = ?', [name]);

  // ---- Files (see DocumentService) ----
  // Downloaded PDFs of the Documentos, by name; never synced.

  Future<Uint8List?> file(String name) async {
    final row = await _db
        .customSelect(
          'SELECT bytes FROM local_files WHERE name = ?',
          variables: [Variable.withString(name)],
        )
        .getSingleOrNull();
    return row?.read<Uint8List>('bytes');
  }

  Future<void> putFile(String name, Uint8List bytes) => _db.customStatement(
    'INSERT OR REPLACE INTO local_files (name, bytes) VALUES (?, ?)',
    [name, bytes],
  );

  /// Removes the files whose names aren't in [keep].
  Future<void> keepOnlyFiles(Set<String> keep) async {
    final rows = await _db.customSelect('SELECT name FROM local_files').get();
    for (final r in rows) {
      final name = r.read<String>('name');
      if (!keep.contains(name)) {
        await _db.customStatement('DELETE FROM local_files WHERE name = ?', [
          name,
        ]);
      }
    }
  }

  /// Fills in missing sync fields (UUIDs) on rows from before they existed:
  /// once at the first startup, and after importing a backup, which may be
  /// that old.
  Future<void> backfillSync() async {
    for (final c in collections) {
      final rows = await c.all(includeDeleted: true);
      final needsFix = rows.where(SyncMeta.backfillIfNeeded).toList();
      if (needsFix.isNotEmpty) await c.putAll(needsFix);
    }
  }
}

/// One collection of [LocalDb]: the rows of one model, kept in memory as
/// decoded JSON. Every read builds new objects from it, so changing a row
/// changes nothing until it is [put].
class LocalCollection<T extends SyncedRow> {
  LocalCollection._(
    this.name,
    this._fromJson, {
    String Function(T row)? syncKey,
  }) : _syncKey = syncKey;

  /// The model's name, as stored in `local_rows` and in backups ("Person").
  final String name;
  final T Function(Map<String, dynamic>) _fromJson;

  /// The row's id online: its syncUuid, or for a row there is one of per
  /// day, week or month, that period, so two devices that each made one
  /// share it instead of having two.
  final String Function(T row)? _syncKey;
  late _Database _db;

  final _rows = <int, Map<String, dynamic>>{};
  int _lastId = 0;

  void _clearMemory() {
    _rows.clear();
    _lastId = 0;
  }

  void _remember(int id, Map<String, dynamic> data) {
    _rows[id] = data;
    if (id > _lastId) _lastId = id;
  }

  T _read(int id, Map<String, dynamic> data) => _fromJson(data)..id = id;

  Future<T?> get(int id) async {
    final data = _rows[id];
    return data == null ? null : _read(id, data);
  }

  /// Every row, in no particular order; tombstoned ones only with
  /// [includeDeleted].
  Future<List<T>> all({bool includeDeleted = false}) async => [
    for (final e in _rows.entries)
      if (includeDeleted || e.value['syncDeletedAt'] == null)
        _read(e.key, e.value),
  ];

  /// The rows [test] accepts, in no particular order.
  Future<List<T>> where(
    bool Function(T row) test, {
    bool includeDeleted = false,
  }) async => [
    for (final r in await all(includeDeleted: includeDeleted))
      if (test(r)) r,
  ];

  /// The first row [test] accepts (the oldest saved), or null.
  Future<T?> firstWhere(
    bool Function(T row) test, {
    bool includeDeleted = false,
  }) async {
    final rows = await where(test, includeDeleted: includeDeleted);
    if (rows.isEmpty) return null;
    return rows.reduce((a, b) => a.id <= b.id ? a : b);
  }

  /// Saves [row], giving it an id if it has none (0); returns the id.
  Future<int> put(T row) async {
    await putAll([row]);
    return row.id;
  }

  Future<void> putAll(List<T> rows) async {
    if (rows.isEmpty) return;
    await _write(_encode(rows));
    if (rows.any((r) => !r.synced)) LocalDb._localWrites.add(name);
  }

  /// [rows] as stored, giving each an id if it has none.
  Map<int, Map<String, dynamic>> _encode(List<T> rows) {
    final encoded = <int, Map<String, dynamic>>{};
    for (final row in rows) {
      if (row.id <= 0) row.id = ++_lastId;
      if (row.id > _lastId) _lastId = row.id;
      // Encoded and decoded, so memory never shares a list with [row].
      final json = jsonEncode(row.toJson()..['id'] = row.id);
      encoded[row.id] = jsonDecode(json) as Map<String, dynamic>;
    }
    return encoded;
  }

  Future<void> _write(Map<int, Map<String, dynamic>> pending) async {
    if (pending.isEmpty) return;
    await _db.transaction(() async {
      for (final e in pending.entries) {
        await _db.customStatement(
          'INSERT OR REPLACE INTO local_rows (collection, id, data) '
          'VALUES (?, ?, ?)',
          [name, e.key, jsonEncode(e.value)],
        );
      }
    });
    _rows.addAll(pending);
  }

  /// Tombstones the row with [id] (see [SyncMeta.softDelete]); false when
  /// there is none or it already is one.
  Future<bool> softDelete(int id) async {
    final row = await get(id);
    if (row == null || row.syncDeletedAt != null) return false;
    SyncMeta.softDelete(row);
    await put(row);
    return true;
  }

  /// Tombstones every row; false when there was none.
  Future<bool> softDeleteAll() async {
    final rows = await all();
    if (rows.isEmpty) return false;
    rows.forEach(SyncMeta.softDelete);
    await putAll(rows);
    return true;
  }

  /// Removes every row for good, tombstones included.
  Future<void> clear() async {
    await _db.customStatement('DELETE FROM local_rows WHERE collection = ?', [
      name,
    ]);
    _clearMemory();
  }

  /// Removes the rows [test] accepts for good, tombstones included.
  Future<void> deleteWhere(bool Function(T row) test) async {
    final ids = [
      for (final r in await all(includeDeleted: true))
        if (test(r)) r.id,
    ];
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      for (final id in ids) {
        await _db.customStatement(
          'DELETE FROM local_rows WHERE collection = ? AND id = ?',
          [name, id],
        );
      }
    });
    ids.forEach(_rows.remove);
  }

  /// Every row (tombstones included) as JSON, for a backup, as its model
  /// writes it: a field the model dropped (a phone number, a whole date of
  /// birth) stays out, even from rows an older version stored.
  List<Map<String, dynamic>> exportJson() => [
    for (final e in _rows.entries) _read(e.key, e.value).toJson(),
  ];

  /// Replaces every row with [rows] from a backup (see [exportJson]). They
  /// are pending, so the next sync pushes them (and keeps whichever copy of
  /// each row was saved last).
  Future<void> importJson(List<Map<String, dynamic>> rows) async {
    await clear();
    await putAll([for (final j in rows) _fromJson(j)..synced = false]);
  }

  // ---- Sync (see SyncEngine) ----

  String syncKeyOf(T row) => _syncKey?.call(row) ?? row.syncUuid;

  /// What is stored online for [row]: its JSON without the local fields.
  Map<String, dynamic> syncData(T row) => row.toJson()
    ..remove('id')
    ..remove('synced');

  /// The rows to push, tombstones included: those pending, or with [all]
  /// every row (the first sync with a store).
  Future<List<T>> toPush({bool all = false}) async => [
    for (final r in await this.all(includeDeleted: true))
      if (all || !r.synced) r,
  ];

  /// Marks [pushed] as synced, unless a row was saved again since it was
  /// read for the push.
  Future<void> markSynced(Iterable<SyncedRow> pushed) async {
    final done = <int, Map<String, dynamic>>{};
    for (final row in pushed) {
      final current = _rows[row.id];
      if (current == null || current['synced'] != false) continue;
      final savedAt = dateFromJson(current['syncUpdatedAt']);
      if (savedAt == null || !savedAt.isAtSameMomentAs(row.syncUpdatedAt)) {
        continue;
      }
      done[row.id] = {...current, 'synced': true};
    }
    await _write(done);
  }

  /// Saves rows from the server ([data] as [syncData] wrote it, under their
  /// [syncKeyOf] key), each over the local row with the same key unless the
  /// local one was saved at the same time or later. With [replaceSynced], a
  /// local row with nothing pending takes the server's copy saved at the
  /// same time too: the server gives out people redacted, and a copy kept
  /// from before must not stay whole. Returns how many changed.
  Future<int> applyRemote(
    List<({String key, Map<String, dynamic> data, DateTime updatedAt})> rows, {
    bool replaceSynced = false,
  }) async {
    if (rows.isEmpty) return 0;
    final byKey = <String, int>{
      for (final e in _rows.entries) syncKeyOf(_read(e.key, e.value)): e.key,
    };
    final staged = <int, Map<String, dynamic>>{};
    for (final r in rows) {
      final id = byKey[r.key];
      if (id != null) {
        final current = staged[id] ?? _rows[id]!;
        final savedAt = dateFromJson(current['syncUpdatedAt']);
        final replace =
            replaceSynced &&
            current['synced'] != false &&
            (savedAt == null || !r.updatedAt.isBefore(savedAt));
        if (!replace && savedAt != null && !r.updatedAt.isAfter(savedAt)) {
          continue;
        }
      }
      final row = _fromJson(r.data)
        ..id = id ?? 0
        ..syncUpdatedAt = r.updatedAt
        ..synced = true;
      final encoded = _encode([row]);
      // The same row again (every pull overlaps the last): nothing changed.
      if (id != null &&
          jsonEncode(encoded[id]) == jsonEncode(staged[id] ?? _rows[id])) {
        byKey[r.key] = id;
        continue;
      }
      staged.addAll(encoded);
      // Later rows in [rows] with the same key compare with this one.
      byKey[r.key] = row.id;
    }
    await _write(staged);
    return staged.length;
  }
}

/// [d]'s local date as "2026-10-30", the online key of a row there is one
/// of per day or week.
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// The SQLite database: one table, made with plain SQL, so there is no
/// Drift code to generate.
class _Database extends GeneratedDatabase {
  _Database(super.executor);

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];

  @override
  Iterable<DatabaseSchemaEntity> get allSchemaEntities => const [];

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {},
    beforeOpen: (details) async {
      await customStatement(
        'CREATE TABLE IF NOT EXISTS local_rows ('
        'collection TEXT NOT NULL, '
        'id INTEGER NOT NULL, '
        'data TEXT NOT NULL, '
        'PRIMARY KEY (collection, id))',
      );
      await customStatement(
        'CREATE TABLE IF NOT EXISTS local_photos ('
        'name TEXT NOT NULL PRIMARY KEY, '
        'bytes BLOB NOT NULL, '
        'uploaded INTEGER NOT NULL DEFAULT 0)',
      );
      await customStatement(
        'CREATE TABLE IF NOT EXISTS local_files ('
        'name TEXT NOT NULL PRIMARY KEY, '
        'bytes BLOB NOT NULL)',
      );
    },
  );
}
