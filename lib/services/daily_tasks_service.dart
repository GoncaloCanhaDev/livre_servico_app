import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/daily_tasks.dart';
import '../models/opening_list.dart';
import 'shift_service.dart';
import 'sync_meta.dart';
import 'task_notification_service.dart';

class DailyTasksService extends ChangeNotifier {
  DailyTasksService._();
  static final DailyTasksService instance = DailyTasksService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<DailyTasks> currentOrCreate() async {
    final day = currentServiceDay();
    final existing = await _isar.dailyTasks
        .filter()
        .syncDeletedAtIsNull()
        .serviceDayEqualTo(day)
        .findFirst();
    if (existing != null) {
      if (_sanitize(existing)) {
        SyncMeta.stamp(existing);
        await _isar.writeTxn(() async {
          await _isar.dailyTasks.put(existing);
        });
      }
      return existing;
    }
    final created = DailyTasks()..serviceDay = day;
    SyncMeta.stamp(created);
    await _isar.writeTxn(() async {
      created.id = await _isar.dailyTasks.put(created);
    });
    return created;
  }

  bool _sanitize(DailyTasks t) {
    var changed = false;
    if (t.alteracoesPrecoCount < 0) {
      t.alteracoesPrecoCount = 0;
      changed = true;
    }
    if (t.verificacaoValidadesCount < 0) {
      t.verificacaoValidadesCount = 0;
      changed = true;
    }
    return changed;
  }

  Future<DailyTasks> forDay(DateTime serviceDay) async {
    final existing = await _isar.dailyTasks
        .filter()
        .syncDeletedAtIsNull()
        .serviceDayEqualTo(serviceDay)
        .findFirst();
    if (existing != null) return existing;
    final created = DailyTasks()..serviceDay = serviceDay;
    SyncMeta.stamp(created);
    await _isar.writeTxn(() async {
      created.id = await _isar.dailyTasks.put(created);
    });
    return created;
  }

  Future<void> save(DailyTasks t) async {
    t.lastUpdatedAt = DateTime.now();
    SyncMeta.stamp(t);
    await _isar.writeTxn(() async {
      await _isar.dailyTasks.put(t);
    });
    await TaskNotificationService.instance.rescheduleAll();
    notifyListeners();
  }

  Future<void> deleteAll() async {
    final rows =
        await _isar.dailyTasks.filter().syncDeletedAtIsNull().findAll();
    if (rows.isEmpty) return;
    for (final r in rows) {
      SyncMeta.softDelete(r);
    }
    await _isar.writeTxn(() async {
      await _isar.dailyTasks.putAll(rows);
    });
    notifyListeners();
  }

  Future<void> delete(int id) async {
    final row = await _isar.dailyTasks.get(id);
    if (row == null || row.syncDeletedAt != null) return;
    SyncMeta.softDelete(row);
    await _isar.writeTxn(() async {
      await _isar.dailyTasks.put(row);
    });
    notifyListeners();
  }

  Future<List<DailyTasks>> history({bool includeDeleted = false}) {
    if (includeDeleted) {
      return _isar.dailyTasks.where().sortByServiceDayDesc().findAll();
    }
    return _isar.dailyTasks
        .filter()
        .syncDeletedAtIsNull()
        .sortByServiceDayDesc()
        .findAll();
  }
}
