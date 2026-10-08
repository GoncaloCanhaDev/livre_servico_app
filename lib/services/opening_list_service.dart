import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/opening_list.dart';
import 'shift_service.dart';
import 'sync_meta.dart';

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

  /// Marks [section] of [list] (today's, with its current values) done by
  /// [names]; the list finalizes itself once all three sections are done.
  Future<void> finishSection(
    OpeningList list,
    ListSection section,
    List<String> names,
  ) async {
    if (list.isSectionDone(section)) return;
    list.markSectionDone(section, names, DateTime.now());
    SyncMeta.stamp(list);
    await _isar.writeTxn(() async {
      await _isar.openingLists.put(list);
    });
    notifyListeners();
  }

  /// Records [section] as [value], done by [names], on the list of an earlier
  /// [serviceDay] (created if missing) and flags it backdated. Returns that
  /// list, or null when the section was already done there.
  Future<OpeningList?> finishSectionOnDay({
    required DateTime serviceDay,
    required ListSection section,
    required int value,
    required List<String> names,
  }) async {
    final existing = await _isar.openingLists
        .filter()
        .syncDeletedAtIsNull()
        .serviceDayEqualTo(serviceDay)
        .findFirst();
    final row = existing ?? (OpeningList()..serviceDay = serviceDay);
    if (row.isSectionDone(section)) return null;
    row.setValue(section, value);
    row.markSectionDone(section, names, DateTime.now());
    row.backdated = true;
    SyncMeta.stamp(row);
    await _isar.writeTxn(() => _isar.openingLists.put(row));
    notifyListeners();
    return row;
  }

  Future<List<OpeningList>> entriesForServiceDay(
    DateTime day, {
    bool includeDeleted = false,
  }) {
    if (includeDeleted) {
      return _isar.openingLists.filter().serviceDayEqualTo(day).findAll();
    }
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
    notifyListeners();
  }

  Future<void> delete(int id) async {
    final row = await _isar.openingLists.get(id);
    if (row == null || row.syncDeletedAt != null) return;
    SyncMeta.softDelete(row);
    await _isar.writeTxn(() async {
      await _isar.openingLists.put(row);
    });
    notifyListeners();
  }

  Future<List<OpeningList>> history({bool includeDeleted = false}) {
    if (includeDeleted) {
      return _isar.openingLists.where().sortByServiceDayDesc().findAll();
    }
    return _isar.openingLists
        .filter()
        .syncDeletedAtIsNull()
        .sortByServiceDayDesc()
        .findAll();
  }
}
