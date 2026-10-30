import 'package:flutter/foundation.dart';

import '../models/opening_list.dart';
import 'local_db.dart';
import 'sync_meta.dart';

class OpeningListService extends ChangeNotifier {
  OpeningListService._();
  static final OpeningListService instance = OpeningListService._();

  LocalDb get _db => LocalDb.instance;

  Future<OpeningList?> _forDay(DateTime day) =>
      _db.openingLists.firstWhere((l) => l.serviceDay.isAtSameMomentAs(day));

  Future<OpeningList> currentOrCreate() async {
    final day = currentServiceDay();
    final existing = await _forDay(day);
    if (existing != null) return existing;
    final created = OpeningList()..serviceDay = day;
    SyncMeta.stamp(created);
    await _db.openingLists.put(created);
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
    await _db.openingLists.put(list);
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
    await _db.openingLists.put(list);
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
    final existing = await _forDay(serviceDay);
    final row = existing ?? (OpeningList()..serviceDay = serviceDay);
    if (row.isSectionDone(section)) return null;
    row.setValue(section, value);
    row.markSectionDone(section, names, DateTime.now());
    row.backdated = true;
    SyncMeta.stamp(row);
    await _db.openingLists.put(row);
    notifyListeners();
    return row;
  }

  Future<List<OpeningList>> entriesForServiceDay(
    DateTime day, {
    bool includeDeleted = false,
  }) => _db.openingLists.where(
    (l) => l.serviceDay.isAtSameMomentAs(day),
    includeDeleted: includeDeleted,
  );

  Future<void> deleteAll() async {
    if (await _db.openingLists.softDeleteAll()) notifyListeners();
  }

  Future<void> delete(int id) async {
    if (await _db.openingLists.softDelete(id)) notifyListeners();
  }

  Future<List<OpeningList>> history({bool includeDeleted = false}) async =>
      (await _db.openingLists.all(includeDeleted: includeDeleted))
        ..sort((a, b) => b.serviceDay.compareTo(a.serviceDay));
}
