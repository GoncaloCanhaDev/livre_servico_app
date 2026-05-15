import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/auto_list.dart';
import 'shift_service.dart';
import 'sync_meta.dart';
import 'task_notification_service.dart';

class AutoListService extends ChangeNotifier {
  AutoListService._();
  static final AutoListService instance = AutoListService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<void> add({
    required int congelados,
    required int opls,
    required int naoPereciveis,
  }) async {
    final entry = AutoList()
      ..createdAt = DateTime.now()
      ..congelados = congelados
      ..opls = opls
      ..naoPereciveis = naoPereciveis;
    SyncMeta.stamp(entry);
    await _isar.writeTxn(() async {
      await _isar.autoLists.put(entry);
    });
    await TaskNotificationService.instance.rescheduleAll();
    notifyListeners();
  }

  Future<List<AutoList>> entriesForServiceDay(DateTime day,
      {bool includeDeleted = false}) async {
    final start = DateTime(day.year, day.month, day.day, 5);
    final end = start.add(const Duration(days: 1));
    if (includeDeleted) {
      return _isar.autoLists
          .filter()
          .createdAtGreaterThan(start)
          .and()
          .createdAtLessThan(end)
          .findAll();
    }
    return _isar.autoLists
        .filter()
        .syncDeletedAtIsNull()
        .createdAtGreaterThan(start)
        .and()
        .createdAtLessThan(end)
        .findAll();
  }

  Future<void> deleteAll() async {
    final rows =
        await _isar.autoLists.filter().syncDeletedAtIsNull().findAll();
    if (rows.isEmpty) return;
    for (final r in rows) {
      SyncMeta.softDelete(r);
    }
    await _isar.writeTxn(() async {
      await _isar.autoLists.putAll(rows);
    });
    await TaskNotificationService.instance.rescheduleAll();
    notifyListeners();
  }

  Future<void> delete(int id) async {
    final row = await _isar.autoLists.get(id);
    if (row == null || row.syncDeletedAt != null) return;
    SyncMeta.softDelete(row);
    await _isar.writeTxn(() async {
      await _isar.autoLists.put(row);
    });
    await TaskNotificationService.instance.rescheduleAll();
    notifyListeners();
  }

  Future<List<AutoList>> history({bool includeDeleted = false}) {
    if (includeDeleted) {
      return _isar.autoLists.where().sortByCreatedAtDesc().findAll();
    }
    return _isar.autoLists
        .filter()
        .syncDeletedAtIsNull()
        .sortByCreatedAtDesc()
        .findAll();
  }
}
