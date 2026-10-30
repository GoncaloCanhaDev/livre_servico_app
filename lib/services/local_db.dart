import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auto_list.dart';
import '../models/custom_task.dart';
import '../models/daily_tasks.dart';
import '../models/horario_mes.dart';
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
  );
  final autoLists = LocalCollection<AutoList>._('AutoList', AutoList.fromJson);
  final reportLists = LocalCollection<ReportList>._(
    'ReportList',
    ReportList.fromJson,
  );
  final visualLists = LocalCollection<VisualList>._(
    'VisualList',
    VisualList.fromJson,
  );
  final dailyTasks = LocalCollection<DailyTasks>._(
    'DailyTasks',
    DailyTasks.fromJson,
  );
  final weeklyTasks = LocalCollection<WeeklyTasks>._(
    'WeeklyTasks',
    WeeklyTasks.fromJson,
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
  );
  final horarioMeses = LocalCollection<HorarioMes>._(
    'HorarioMes',
    HorarioMes.fromJson,
  );

  late final List<LocalCollection<SyncedRow>> collections = [
    truckReceptions,
    openingLists,
    autoLists,
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
    horarioMeses,
  ];

  /// Set once [backfillSync] has run at startup: rows saved since are
  /// stamped when written, so it isn't needed again.
  static const _backfilledKey = 'syncBackfilled';

  /// Opens the database (on the device, or [executor] in tests, e.g.
  /// `NativeDatabase.memory()`) and reads every collection into memory.
  static Future<void> init({QueryExecutor? executor}) async {
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
    instance = local;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_backfilledKey) != true) {
      await local.backfillSync();
      await prefs.setBool(_backfilledKey, true);
    }
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
  LocalCollection._(this.name, this._fromJson);

  /// The model's name, as stored in `local_rows` and in backups ("Person").
  final String name;
  final T Function(Map<String, dynamic>) _fromJson;
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
    final pending = <int, Map<String, dynamic>>{};
    for (final row in rows) {
      if (row.id <= 0) row.id = ++_lastId;
      if (row.id > _lastId) _lastId = row.id;
      // Encoded and decoded, so memory never shares a list with [row].
      final json = jsonEncode(row.toJson()..['id'] = row.id);
      pending[row.id] = jsonDecode(json) as Map<String, dynamic>;
    }
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

  /// Every row (tombstones included) as JSON, for a backup.
  List<Map<String, dynamic>> exportJson() => [
    for (final e in _rows.entries) {...e.value, 'id': e.key},
  ];

  /// Replaces every row with [rows] from a backup (see [exportJson]).
  Future<void> importJson(List<Map<String, dynamic>> rows) async {
    await clear();
    await putAll([for (final j in rows) _fromJson(j)]);
  }
}

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
    },
  );
}
