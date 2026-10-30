import 'package:flutter/foundation.dart';

import '../models/opening_list.dart';
import '../models/visual_list.dart';
import 'local_db.dart';
import 'sync_meta.dart';

class VisualListService extends ChangeNotifier {
  VisualListService._() {
    LocalDb.listenRemote(const {'VisualList'}, notifyListeners);
  }
  static final VisualListService instance = VisualListService._();

  LocalDb get _db => LocalDb.instance;

  Future<void> add({
    String? syncUuid,
    required int itensPicados,
    required int quebraCents,
    required int beneficioCents,
    List<String>? by,
  }) async {
    final now = DateTime.now();
    final entry = VisualList()
      ..createdAt = now
      ..serviceDay = currentServiceDay(now)
      ..itensPicados = itensPicados
      ..quebraCents = quebraCents
      ..beneficioCents = beneficioCents
      ..createdByNames = by ?? [];
    if (syncUuid != null) entry.syncUuid = syncUuid;
    SyncMeta.stamp(entry);
    await _db.visualLists.put(entry);
    notifyListeners();
  }

  Future<void> addForDay({
    required DateTime serviceDay,
    required int itensPicados,
    required int quebraCents,
    required int beneficioCents,
    List<String>? by,
  }) async {
    final entry = VisualList()
      ..createdAt = DateTime(
        serviceDay.year,
        serviceDay.month,
        serviceDay.day,
        12,
      )
      ..serviceDay = serviceDay
      ..itensPicados = itensPicados
      ..quebraCents = quebraCents
      ..beneficioCents = beneficioCents
      ..createdByNames = by ?? []
      ..backdated = true;
    SyncMeta.stamp(entry);
    await _db.visualLists.put(entry);
    notifyListeners();
  }

  Future<List<VisualList>> entriesForServiceDay(
    DateTime day, {
    bool includeDeleted = false,
  }) async => (await _db.visualLists.where(
    (v) => v.serviceDay.isAtSameMomentAs(day),
    includeDeleted: includeDeleted,
  ))..sort(_newestFirst);

  Future<void> deleteAll() async {
    if (await _db.visualLists.softDeleteAll()) notifyListeners();
  }

  Future<void> delete(int id) async {
    if (await _db.visualLists.softDelete(id)) notifyListeners();
  }

  Future<List<VisualList>> all({bool includeDeleted = false}) async =>
      (await _db.visualLists.all(includeDeleted: includeDeleted))
        ..sort(_newestFirst);

  static int _newestFirst(VisualList a, VisualList b) =>
      b.createdAt.compareTo(a.createdAt);
}
