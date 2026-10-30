import 'package:flutter/foundation.dart';

import '../models/auto_list.dart';
import 'local_db.dart';
import 'sync_meta.dart';

class AutoListService extends ChangeNotifier {
  AutoListService._();
  static final AutoListService instance = AutoListService._();

  LocalDb get _db => LocalDb.instance;

  Future<void> add({
    String? syncUuid,
    required int congelados,
    required int opls,
    required int naoPereciveis,
    List<String>? by,
  }) async {
    final entry = AutoList()
      ..createdAt = DateTime.now()
      ..congelados = congelados
      ..opls = opls
      ..naoPereciveis = naoPereciveis
      ..createdByNames = by ?? [];
    if (syncUuid != null) entry.syncUuid = syncUuid;
    SyncMeta.stamp(entry);
    await _db.autoLists.put(entry);
    notifyListeners();
  }

  Future<void> addForDay({
    required DateTime serviceDay,
    required int congelados,
    required int opls,
    required int naoPereciveis,
    List<String>? by,
  }) async {
    final entry = AutoList()
      ..createdAt = DateTime(
        serviceDay.year,
        serviceDay.month,
        serviceDay.day,
        12,
      )
      ..congelados = congelados
      ..opls = opls
      ..naoPereciveis = naoPereciveis
      ..createdByNames = by ?? []
      ..backdated = true;
    SyncMeta.stamp(entry);
    await _db.autoLists.put(entry);
    notifyListeners();
  }

  Future<List<AutoList>> entriesForServiceDay(
    DateTime day, {
    bool includeDeleted = false,
  }) {
    final start = DateTime(day.year, day.month, day.day, 5);
    final end = start.add(const Duration(days: 1));
    return _db.autoLists.where(
      (a) => a.createdAt.isAfter(start) && a.createdAt.isBefore(end),
      includeDeleted: includeDeleted,
    );
  }

  Future<void> deleteAll() async {
    if (await _db.autoLists.softDeleteAll()) notifyListeners();
  }

  Future<void> delete(int id) async {
    if (await _db.autoLists.softDelete(id)) notifyListeners();
  }

  Future<List<AutoList>> history({bool includeDeleted = false}) async =>
      (await _db.autoLists.all(includeDeleted: includeDeleted))
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}
