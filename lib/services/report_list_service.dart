import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/opening_list.dart';
import '../models/report_list.dart';
import 'shift_service.dart';
import 'sync_meta.dart';
import 'task_notification_service.dart';

class ReportListService extends ChangeNotifier {
  ReportListService._();
  static final ReportListService instance = ReportListService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<ReportList> currentOrCreate() async {
    final day = currentServiceDay();
    final existing = await _isar.reportLists
        .filter()
        .syncDeletedAtIsNull()
        .serviceDayEqualTo(day)
        .findFirst();
    if (existing != null) return existing;
    final created = ReportList()..serviceDay = day;
    SyncMeta.stamp(created);
    await _isar.writeTxn(() async {
      created.id = await _isar.reportLists.put(created);
    });
    return created;
  }

  Future<void> updateValues(
    ReportList list, {
    int? diasSemVendas,
    int? regularizacoes,
    int? massiva,
    int? repetidos,
  }) async {
    if (list.isFinalized) return;
    if (diasSemVendas != null) list.diasSemVendas = diasSemVendas;
    if (regularizacoes != null) list.regularizacoes = regularizacoes;
    if (massiva != null) list.massiva = massiva;
    if (repetidos != null) list.repetidos = repetidos;
    SyncMeta.stamp(list);
    await _isar.writeTxn(() async {
      await _isar.reportLists.put(list);
    });
    notifyListeners();
  }

  Future<void> backfillFinalized({
    required DateTime serviceDay,
    required int diasSemVendas,
    required int regularizacoes,
    required int massiva,
    required int repetidos,
  }) async {
    final existing = await _isar.reportLists
        .filter()
        .syncDeletedAtIsNull()
        .serviceDayEqualTo(serviceDay)
        .findFirst();
    final row = existing ?? (ReportList()..serviceDay = serviceDay);
    row.diasSemVendas = diasSemVendas;
    row.regularizacoes = regularizacoes;
    row.massiva = massiva;
    row.repetidos = repetidos;
    row.finalizedAt = DateTime.now();
    SyncMeta.stamp(row);
    await _isar.writeTxn(() => _isar.reportLists.put(row));
    notifyListeners();
  }

  Future<void> finalize(ReportList list) async {
    if (list.isFinalized) return;
    list.finalizedAt = DateTime.now();
    SyncMeta.stamp(list);
    await _isar.writeTxn(() async {
      await _isar.reportLists.put(list);
    });
    await TaskNotificationService.instance.rescheduleAll();
    notifyListeners();
  }

  Future<List<ReportList>> entriesForServiceDay(DateTime day,
      {bool includeDeleted = false}) {
    if (includeDeleted) {
      return _isar.reportLists
          .filter()
          .serviceDayEqualTo(day)
          .findAll();
    }
    return _isar.reportLists
        .filter()
        .syncDeletedAtIsNull()
        .serviceDayEqualTo(day)
        .findAll();
  }

  Future<void> deleteAll() async {
    final rows =
        await _isar.reportLists.filter().syncDeletedAtIsNull().findAll();
    if (rows.isEmpty) return;
    for (final r in rows) {
      SyncMeta.softDelete(r);
    }
    await _isar.writeTxn(() async {
      await _isar.reportLists.putAll(rows);
    });
    await TaskNotificationService.instance.rescheduleAll();
    notifyListeners();
  }

  Future<void> delete(int id) async {
    final row = await _isar.reportLists.get(id);
    if (row == null || row.syncDeletedAt != null) return;
    SyncMeta.softDelete(row);
    await _isar.writeTxn(() async {
      await _isar.reportLists.put(row);
    });
    await TaskNotificationService.instance.rescheduleAll();
    notifyListeners();
  }

  Future<List<ReportList>> history({bool includeDeleted = false}) {
    if (includeDeleted) {
      return _isar.reportLists.where().sortByServiceDayDesc().findAll();
    }
    return _isar.reportLists
        .filter()
        .syncDeletedAtIsNull()
        .sortByServiceDayDesc()
        .findAll();
  }
}
