import 'package:shared_preferences/shared_preferences.dart';

import '../models/local_row.dart';
import 'local_db.dart';

/// One row as the online database keeps it (`records` in `supabase/`).
class SyncRecord {
  const SyncRecord({
    required this.collection,
    required this.id,
    required this.data,
    required this.updatedAt,
    this.deletedAt,
    this.serverUpdatedAt,
  });

  factory SyncRecord.fromServerJson(Map<String, dynamic> j) => SyncRecord(
    collection: j['collection'] as String,
    id: j['id'] as String,
    data: Map<String, dynamic>.from(j['data'] as Map),
    updatedAt: DateTime.parse(j['updated_at'] as String),
    deletedAt: switch (j['deleted_at']) {
      final String d => DateTime.parse(d),
      _ => null,
    },
    serverUpdatedAt: switch (j['server_updated_at']) {
      final String d => DateTime.parse(d),
      _ => null,
    },
  );

  /// The model name ("Person").
  final String collection;

  /// The row's key: `LocalCollection.syncKeyOf`.
  final String id;

  /// The row's JSON: `LocalCollection.syncData`.
  final Map<String, dynamic> data;

  /// When the row was last saved, by the device that saved it.
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// When the server last wrote the row, by its clock; null on rows being
  /// pushed.
  final DateTime? serverUpdatedAt;

  /// The row as `push_records` takes it.
  Map<String, dynamic> toPushJson() => {
    'collection': collection,
    'id': id,
    'data': data,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
  };
}

/// The online side of sync, for one store: `SupabaseSyncRemote`, or an
/// in-memory one in tests.
abstract interface class SyncRemote {
  /// Saves [rows] where each is newer than the server's copy; returns the
  /// server's copy of those where it was newer (last write wins).
  Future<List<SyncRecord>> push(List<SyncRecord> rows);

  /// Up to [limit] rows the server wrote at [since] or later (all with
  /// null), oldest write first.
  Future<List<SyncRecord>> pull({DateTime? since, required int limit});
}

/// What one [SyncEngine.run] did.
typedef SyncReport = ({int pushed, int pulled});

/// Brings [db] and a store's online rows ([remote]) up to date with each
/// other: pushes the rows saved here since the last sync, then pulls what
/// the server got since the last pull. Last write wins, by each row's
/// `syncUpdatedAt`.
class SyncEngine {
  SyncEngine({
    required this.db,
    required this.remote,
    required this.storeId,
    required this.prefs,
    this.canPush = true,
  });

  final LocalDb db;
  final SyncRemote remote;
  final String storeId;
  final SharedPreferences prefs;

  /// False for a viewer, who can't change the store's rows: pull only, and
  /// what they save stays on this device.
  final bool canPush;

  static const _pushBatch = 500;
  static const _pullPage = 1000;

  /// Each pull starts this long before the last one ended: a write still
  /// committing then can carry an earlier server time. Rows seen twice
  /// change nothing.
  static const _overlap = Duration(minutes: 1);

  static const _cursorPrefix = 'syncCursor:';
  String get _cursorKey => '$_cursorPrefix$storeId';

  /// Forgets where every store's pulls got to, so the next sync pushes
  /// every row and pulls everything again: after a backup import, which
  /// replaces rows here without going through the server.
  static Future<void> forgetCursors(SharedPreferences prefs) async {
    for (final k in prefs.getKeys().toList()) {
      if (k.startsWith(_cursorPrefix)) await prefs.remove(k);
    }
  }

  Future<SyncReport> run() async {
    final cursor = switch (prefs.getString(_cursorKey)) {
      final String c => DateTime.tryParse(c),
      _ => null,
    };
    final changed = <String>{};
    var pushed = 0;
    if (canPush) {
      for (final c in db.collections) {
        pushed += await _push(c, all: cursor == null, changed: changed);
      }
    }
    final pulled = await _pull(cursor, changed);
    LocalDb.notifyRemoteChanges(changed);
    return (pushed: pushed, pulled: pulled);
  }

  Future<int> _push(
    LocalCollection<SyncedRow> c, {
    required bool all,
    required Set<String> changed,
  }) async {
    final rows = await c.toPush(all: all);
    // One row per key, the last saved (no key may be pushed twice in one
    // call): two rows can share a period's key from before keys existed.
    final byKey = <String, List<SyncedRow>>{};
    for (final r in rows) {
      final key = c.syncKeyOf(r);
      if (key.isEmpty) continue;
      (byKey[key] ??= []).add(r);
    }
    final keys = byKey.keys.toList();
    for (var i = 0; i < keys.length; i += _pushBatch) {
      final batch = keys.skip(i).take(_pushBatch).toList();
      final records = [
        for (final k in batch)
          _record(
            c,
            k,
            byKey[k]!.reduce(
              (a, b) => b.syncUpdatedAt.isAfter(a.syncUpdatedAt) ? b : a,
            ),
          ),
      ];
      final newer = await remote.push(records);
      // Every row of a key: the older ones were replaced by the pushed one.
      await c.markSynced([for (final k in batch) ...byKey[k]!]);
      if (await c.applyRemote([for (final r in newer) _incoming(r)]) > 0) {
        changed.add(c.name);
      }
    }
    return keys.length;
  }

  Future<int> _pull(DateTime? cursor, Set<String> changed) async {
    final byName = {for (final c in db.collections) c.name: c};
    var since = cursor?.subtract(_overlap);
    var newest = cursor;
    var pulled = 0;
    while (true) {
      final page = await remote.pull(since: since, limit: _pullPage);
      pulled += page.length;
      final byCollection = <String, List<SyncRecord>>{};
      for (final r in page) {
        // A collection this version doesn't know: left for a newer one.
        if (!byName.containsKey(r.collection)) continue;
        (byCollection[r.collection] ??= []).add(r);
      }
      for (final e in byCollection.entries) {
        final rows = [for (final r in e.value) _incoming(r)];
        if (await byName[e.key]!.applyRemote(rows) > 0) changed.add(e.key);
      }
      final last = page.isEmpty ? null : page.last.serverUpdatedAt;
      if (last != null && (newest == null || last.isAfter(newest))) {
        newest = last;
        await prefs.setString(_cursorKey, last.toUtc().toIso8601String());
      }
      // A short page is the end; so is one that didn't move on (a full page
      // of rows written at the very same time, which can't really happen).
      if (page.length < _pullPage || last == null || last == since) break;
      since = last;
    }
    if (newest == null) {
      // Nothing online yet: still remember that the first push happened.
      await prefs.setString(
        _cursorKey,
        DateTime.fromMillisecondsSinceEpoch(0).toUtc().toIso8601String(),
      );
    }
    return pulled;
  }

  SyncRecord _record(LocalCollection<SyncedRow> c, String key, SyncedRow r) =>
      SyncRecord(
        collection: c.name,
        id: key,
        data: c.syncData(r),
        updatedAt: r.syncUpdatedAt,
        deletedAt: r.syncDeletedAt,
      );

  ({String key, Map<String, dynamic> data, DateTime updatedAt}) _incoming(
    SyncRecord r,
  ) => (key: r.id, data: r.data, updatedAt: r.updatedAt.toLocal());
}
