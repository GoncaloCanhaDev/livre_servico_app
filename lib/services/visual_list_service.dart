import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/opening_list.dart';
import '../models/visual_list.dart';
import 'shift_service.dart';
import 'sync_meta.dart';
import 'task_notification_service.dart';

class VisualListService extends ChangeNotifier {
  VisualListService._();
  static final VisualListService instance = VisualListService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<void> add({
    required int itensPicados,
    required int quebraCents,
    required int beneficioCents,
  }) async {
    final now = DateTime.now();
    final entry = VisualList()
      ..createdAt = now
      ..serviceDay = currentServiceDay(now)
      ..itensPicados = itensPicados
      ..quebraCents = quebraCents
      ..beneficioCents = beneficioCents;
    SyncMeta.stamp(entry);
    await _isar.writeTxn(() async {
      await _isar.visualLists.put(entry);
    });
    await TaskNotificationService.instance.rescheduleAll();
    await TaskNotificationService.instance.checkVisualGoal();
    notifyListeners();
  }

  Future<void> addForDay({
    required DateTime serviceDay,
    required int itensPicados,
    required int quebraCents,
    required int beneficioCents,
  }) async {
    final entry = VisualList()
      ..createdAt = DateTime(serviceDay.year, serviceDay.month, serviceDay.day, 12)
      ..serviceDay = serviceDay
      ..itensPicados = itensPicados
      ..quebraCents = quebraCents
      ..beneficioCents = beneficioCents;
    SyncMeta.stamp(entry);
    await _isar.writeTxn(() => _isar.visualLists.put(entry));
    notifyListeners();
  }

  Future<List<VisualList>> entriesForServiceDay(DateTime day,
      {bool includeDeleted = false}) {
    if (includeDeleted) {
      return _isar.visualLists
          .filter()
          .serviceDayEqualTo(day)
          .sortByCreatedAtDesc()
          .findAll();
    }
    return _isar.visualLists
        .filter()
        .syncDeletedAtIsNull()
        .serviceDayEqualTo(day)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<void> deleteAll() async {
    final rows =
        await _isar.visualLists.filter().syncDeletedAtIsNull().findAll();
    if (rows.isEmpty) return;
    for (final r in rows) {
      SyncMeta.softDelete(r);
    }
    await _isar.writeTxn(() async {
      await _isar.visualLists.putAll(rows);
    });
    await TaskNotificationService.instance.rescheduleAll();
    notifyListeners();
  }

  Future<void> delete(int id) async {
    final row = await _isar.visualLists.get(id);
    if (row == null || row.syncDeletedAt != null) return;
    SyncMeta.softDelete(row);
    await _isar.writeTxn(() async {
      await _isar.visualLists.put(row);
    });
    await TaskNotificationService.instance.rescheduleAll();
    notifyListeners();
  }

  Future<List<VisualList>> all({bool includeDeleted = false}) {
    if (includeDeleted) {
      return _isar.visualLists.where().sortByCreatedAtDesc().findAll();
    }
    return _isar.visualLists
        .filter()
        .syncDeletedAtIsNull()
        .sortByCreatedAtDesc()
        .findAll();
  }
}
