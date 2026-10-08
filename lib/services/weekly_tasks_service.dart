import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/weekly_tasks.dart';
import 'shift_service.dart';
import 'sync_meta.dart';

class WeeklyTasksService extends ChangeNotifier {
  WeeklyTasksService._();
  static final WeeklyTasksService instance = WeeklyTasksService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<WeeklyTasks> currentOrCreate() async {
    final week = currentServiceWeek();
    final existing = await _isar.weeklyTasks
        .where()
        .serviceWeekEqualTo(week)
        .filter()
        .syncDeletedAtIsNull()
        .findFirst();
    if (existing != null) {
      if (_sanitize(existing)) {
        SyncMeta.stamp(existing);
        await _isar.writeTxn(() async {
          await _isar.weeklyTasks.put(existing);
        });
      }
      return existing;
    }
    final created = WeeklyTasks()..serviceWeek = week;
    SyncMeta.stamp(created);
    await _isar.writeTxn(() async {
      created.id = await _isar.weeklyTasks.put(created);
    });
    return created;
  }

  bool _sanitize(WeeklyTasks t) {
    var changed = false;
    if (t.verificar1aCount < 0) {
      t.verificar1aCount = 0;
      changed = true;
    }
    if (t.verificar4aCount < 0) {
      t.verificar4aCount = 0;
      changed = true;
    }
    return changed;
  }

  Future<WeeklyTasks> forWeek(DateTime serviceWeek) async {
    final existing = await _isar.weeklyTasks
        .where()
        .serviceWeekEqualTo(serviceWeek)
        .filter()
        .syncDeletedAtIsNull()
        .findFirst();
    if (existing != null) return existing;
    final created = WeeklyTasks()..serviceWeek = serviceWeek;
    SyncMeta.stamp(created);
    await _isar.writeTxn(() async {
      created.id = await _isar.weeklyTasks.put(created);
    });
    return created;
  }

  Future<void> save(WeeklyTasks t) async {
    t.lastUpdatedAt = DateTime.now();
    SyncMeta.stamp(t);
    await _isar.writeTxn(() async {
      await _isar.weeklyTasks.put(t);
    });
    notifyListeners();
  }

  Future<void> deleteAll() async {
    final rows = await _isar.weeklyTasks
        .filter()
        .syncDeletedAtIsNull()
        .findAll();
    if (rows.isEmpty) return;
    for (final r in rows) {
      SyncMeta.softDelete(r);
    }
    await _isar.writeTxn(() async {
      await _isar.weeklyTasks.putAll(rows);
    });
    notifyListeners();
  }

  Future<void> delete(int id) async {
    final row = await _isar.weeklyTasks.get(id);
    if (row == null || row.syncDeletedAt != null) return;
    SyncMeta.softDelete(row);
    await _isar.writeTxn(() async {
      await _isar.weeklyTasks.put(row);
    });
    notifyListeners();
  }

  Future<List<WeeklyTasks>> history({bool includeDeleted = false}) {
    if (includeDeleted) {
      return _isar.weeklyTasks.where().sortByServiceWeekDesc().findAll();
    }
    return _isar.weeklyTasks
        .filter()
        .syncDeletedAtIsNull()
        .sortByServiceWeekDesc()
        .findAll();
  }
}
