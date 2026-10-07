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
    // Anyone reporting to the removed person loses just that reporting
    // line — they keep any other manager they still have, and only drop
    // to the top of the hierarchy if this was their last one.
    final all = await _isar.persons.filter().syncDeletedAtIsNull().findAll();
    final reports = all
        .where((p) => p.managerUuids.contains(row.syncUuid))
        .toList();
    for (final r in reports) {
      r.managerUuids = r.managerUuids
          .where((u) => u != row.syncUuid)
          .toList();
      SyncMeta.stamp(r);
    }
    await _isar.writeTxn(() async {
      await _isar.persons.put(row);
      await _isar.persons.putAll(reports);
    });
    notifyListeners();
  }

  /// One-time upgrade path: pre-multi-manager rows only have the legacy
  /// [Person.managerUuid] populated. Copies it into [Person.managerUuids]
  /// so existing org-chart assignments survive the upgrade. Safe to call
  /// every startup — a person already migrated (or created after the
  /// upgrade) has a non-empty managerUuids and is left alone. Runs over
  /// every row (not just non-deleted ones), mirroring
  /// `ShiftService._backfillSync`.
  Future<void> migrateManagerUuids() async {
    final rows = await _isar.persons.where().findAll();
    final needsFix = rows.where((p) {
      final legacy = p.managerUuid;
      return p.managerUuids.isEmpty && legacy != null && legacy.isNotEmpty;
    }).toList();
    if (needsFix.isEmpty) return;
    for (final p in needsFix) {
      p.managerUuids = [p.managerUuid!];
      p.managerUuid = null; // consumed — never migrate this row again
      SyncMeta.stamp(p);
    }
    await _isar.writeTxn(() => _isar.persons.putAll(needsFix));
  }

  /// Groups [all] by manager syncUuid; a person with multiple managers is
  /// added under each one (the teams view shows them in every manager's
  /// section).
  /// The `null` key holds the roots — people with no manager, or whose
  /// only manager(s) no longer exist among [all] (e.g. soft-deleted
  /// without going through [delete]).
  Map<String?, List<Person>> groupByManager(List<Person> all) {
    final uuids = all.map((p) => p.syncUuid).toSet();
    final map = <String?, List<Person>>{};
    for (final p in all) {
      final validManagers = p.managerUuids.where(uuids.contains).toList();
      if (validManagers.isEmpty) {
        (map[null] ??= []).add(p);
      } else {
        for (final m in validManagers) {
          (map[m] ??= []).add(p);
        }
      }
    }
    return map;
  }

  /// [rootUuid] plus every person under them (direct or indirect reports,
  /// through any of their managers), computed from [all]. Used to stop the
  /// manager picker from letting a person be assigned as manager of one of
  /// their own descendants (a cycle).
  Set<String> subtreeUuids(List<Person> all, String rootUuid) {
    final childrenOf = <String, List<Person>>{};
    for (final p in all) {
      for (final m in p.managerUuids) {
        (childrenOf[m] ??= []).add(p);
      }
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

  Future<List<Person>> all() => _isar.persons
      .filter()
      .syncDeletedAtIsNull()
      .sortByFullName()
      .findAll();

  Future<void> deleteAll() async {
    final rows = await _isar.persons.filter().syncDeletedAtIsNull().findAll();
    if (rows.isEmpty) return;
    for (final r in rows) {
      SyncMeta.softDelete(r);
    }
    await _isar.writeTxn(() => _isar.persons.putAll(rows));
    notifyListeners();
  }
}

