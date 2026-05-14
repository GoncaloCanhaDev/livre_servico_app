import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/opening_list.dart';
import 'shift_service.dart';
import 'sync_meta.dart';
import 'task_notification_service.dart';

class OpeningListService extends ChangeNotifier {
  OpeningListService._();
  static final OpeningListService instance = OpeningListService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<OpeningList> currentOrCreate() async {
    final day = currentServiceDay();
    final existing = await _isar.openingLists
        .filter()
        .syncDeletedAtIsNull()
        .serviceDayEqualTo(day)
        .findFirst();
    if (existing != null) return existing;
    final created = OpeningList()..serviceDay = day;
    SyncMeta.stamp(created);
    await _isar.writeTxn(() async {
      created.id = await _isar.openingLists.put(created);
    });
    return created;
  }

  Future<void> updateValues(
    OpeningList list, {
    int? congelados,
    int? opls,
    int? naoPereciveis,
  }) async {
    if (list.isFinalized) return;
    if (congelados != null) list.congelados = congelados;
    if (opls != null) list.opls = opls;
    if (naoPereciveis != null) list.naoPereciveis = naoPereciveis;
    SyncMeta.stamp(list);
    await _isar.writeTxn(() async {
      await _isar.openingLists.put(list);
    });
    notifyListeners();
  }

  Future<void> finalize(OpeningList list) async {
    if (list.isFinalized) return;
    list.finalizedAt = DateTime.now();
    SyncMeta.stamp(list);
    await _isar.writeTxn(() async {
      await _isar.openingLists.put(list);
    });
    await TaskNotificationService.instance.rescheduleAll();
    notifyListeners();
  }

  Future<List<OpeningList>> entriesForServiceDay(DateTime day) {
    return _isar.openingLists
        .filter()
        .syncDeletedAtIsNull()
        .serviceDayEqualTo(day)
        .findAll();
  }

  Future<void> deleteAll() async {
    final rows = await _isar.openingLists
        .filter()
        .syncDeletedAtIsNull()
        .findAll();
    if (rows.isEmpty) return;
    for (final r in rows) {
      SyncMeta.softDelete(r);
    }
    await _isar.writeTxn(() async {
      await _isar.openingLists.putAll(rows);
    });
    await TaskNotificationService.instance.rescheduleAll();
    notifyListeners();
  }

  Future<void> delete(int id) async {
    final row = await _isar.openingLists.get(id);
    if (row == null || row.syncDeletedAt != null) return;
    SyncMeta.softDelete(row);
    await _isar.writeTxn(() async {
      await _isar.openingLists.put(row);
    });
    await TaskNotificationService.instance.rescheduleAll();
    notifyListeners();
  }

  Future<List<OpeningList>> history() {
    return _isar.openingLists
        .filter()
        .syncDeletedAtIsNull()
        .sortByServiceDayDesc()
        .findAll();
  }
}
