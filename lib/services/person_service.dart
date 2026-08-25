import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/person.dart';
import 'shift_service.dart';
import 'sync_meta.dart';

class PersonService extends ChangeNotifier {
  PersonService._();
  static final PersonService instance = PersonService._();

  Isar get _isar => ShiftService.instance.isar;
  Isar get isar => _isar;

  /// Same as [all], but without the negative-points migration write — used by
  /// snapshot code that needs a plain read.
  Future<List<Person>> allRaw() =>
      _isar.persons.filter().syncDeletedAtIsNull().sortByFullName().findAll();

  /// Lets external services (e.g. month rollover) tell listeners the person
  /// data changed after they mutated it directly.
  void notifyExternal() => notifyListeners();

  Future<int> save(Person p) async {
    SyncMeta.stamp(p);
    late int id;
    await _isar.writeTxn(() async {
      id = await _isar.persons.put(p);
    });
    notifyListeners();
    return id;
  }

  Future<void> delete(int id) async {
    final row = await _isar.persons.get(id);
    if (row == null || row.syncDeletedAt != null) return;
    SyncMeta.softDelete(row);
    // Anyone reporting directly to the removed person moves to the top of
    // the hierarchy rather than being left pointing at a dangling uuid.
    final reports = await _isar.persons
        .filter()
        .syncDeletedAtIsNull()
        .managerUuidEqualTo(row.syncUuid)
        .findAll();
    for (final r in reports) {
      r.managerUuid = null;
      SyncMeta.stamp(r);
    }
    await _isar.writeTxn(() async {
      await _isar.persons.put(row);
      await _isar.persons.putAll(reports);
    });
    notifyListeners();
  }

  /// Groups [all] by manager syncUuid; the `null` key holds the roots —
  /// people with no manager, or whose manager no longer exists among [all]
  /// (e.g. it was soft-deleted without going through [delete]).
  Map<String?, List<Person>> groupByManager(List<Person> all) {
    final uuids = all.map((p) => p.syncUuid).toSet();
    final map = <String?, List<Person>>{};
    for (final p in all) {
      final key = (p.managerUuid != null && uuids.contains(p.managerUuid))
          ? p.managerUuid
          : null;
      (map[key] ??= []).add(p);
    }
    return map;
  }

  /// [rootUuid] plus every person under them (direct or indirect reports),
  /// computed from [all]. Used to stop the manager picker from letting a
  /// person be assigned as their own descendant's manager (a cycle).
  Set<String> subtreeUuids(List<Person> all, String rootUuid) {
    final childrenOf = <String, List<Person>>{};
    for (final p in all) {
      final m = p.managerUuid;
      if (m != null) (childrenOf[m] ??= []).add(p);
    }
    final result = <String>{rootUuid};
    final queue = <String>[rootUuid];
    while (queue.isNotEmpty) {
      final uuid = queue.removeLast();
      for (final child in childrenOf[uuid] ?? const <Person>[]) {
        if (result.add(child.syncUuid)) queue.add(child.syncUuid);
      }
    }
    return result;
  }

  Future<List<Person>> all() async {
    final list = await _isar.persons
        .filter()
        .syncDeletedAtIsNull()
        .sortByFullName()
        .findAll();
    final broken = list.where((p) => p.points < 0).toList();
    if (broken.isNotEmpty) {
      await _isar.writeTxn(() async {
        for (final p in broken) {
          p.points = 0;
          SyncMeta.stamp(p);
          await _isar.persons.put(p);
        }
      });
    }
    return list;
  }

  Future<void> deleteAll() async {
    final rows = await _isar.persons.filter().syncDeletedAtIsNull().findAll();
    if (rows.isEmpty) return;
    for (final r in rows) {
      SyncMeta.softDelete(r);
    }
    await _isar.writeTxn(() => _isar.persons.putAll(rows));
    notifyListeners();
  }

  Future<Person?> resetPoints(int id) async {
    final row = await _isar.persons.get(id);
    if (row == null || row.syncDeletedAt != null) return null;
    row.points = 0;
    row.pointHistory = [];
    SyncMeta.stamp(row);
    await _isar.writeTxn(() async {
      await _isar.persons.put(row);
    });
    notifyListeners();
    return row;
  }

  Future<Person?> adjustPoints(int id, int delta, {String? reason}) async {
    final row = await _isar.persons.get(id);
    if (row == null || row.syncDeletedAt != null) return null;
    final current = row.points < 0 ? 0 : row.points;
    row.points = current + delta;
    row.pointHistory = [
      ...row.pointHistory,
      PointEvent()
        ..at = DateTime.now()
        ..delta = delta
        ..reason = (reason == null || reason.trim().isEmpty)
            ? null
            : reason.trim(),
    ];
    SyncMeta.stamp(row);
    await _isar.writeTxn(() async {
      await _isar.persons.put(row);
    });
    notifyListeners();
    return row;
  }
}
