import 'package:flutter/foundation.dart';

import '../models/opening_list.dart';
import '../models/report_list.dart';
import 'local_db.dart';
import 'sync_meta.dart';

class ReportListService extends ChangeNotifier {
  ReportListService._();
  static final ReportListService instance = ReportListService._();

  LocalDb get _db => LocalDb.instance;

  Future<ReportList?> _forDay(DateTime day) =>
      _db.reportLists.firstWhere((l) => l.serviceDay.isAtSameMomentAs(day));

  Future<ReportList> currentOrCreate() async {
    final day = currentServiceDay();
    final existing = await _forDay(day);
    if (existing != null) return existing;
    final created = ReportList()..serviceDay = day;
    SyncMeta.stamp(created);
    await _db.reportLists.put(created);
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
    await _db.reportLists.put(list);
    notifyListeners();
  }

  Future<void> backfillFinalized({
    required DateTime serviceDay,
    required int diasSemVendas,
    required int regularizacoes,
    required int massiva,
    required int repetidos,
  }) async {
    final existing = await _forDay(serviceDay);
    final row = existing ?? (ReportList()..serviceDay = serviceDay);
    row.diasSemVendas = diasSemVendas;
    row.regularizacoes = regularizacoes;
    row.massiva = massiva;
    row.repetidos = repetidos;
    row.finalizedAt = DateTime.now();
    row.backdated = true;
    SyncMeta.stamp(row);
    await _db.reportLists.put(row);
    notifyListeners();
  }

  Future<void> finalize(ReportList list) async {
    if (list.isFinalized) return;
    list.finalizedAt = DateTime.now();
    SyncMeta.stamp(list);
    await _db.reportLists.put(list);
    notifyListeners();
  }

  Future<List<ReportList>> entriesForServiceDay(
    DateTime day, {
    bool includeDeleted = false,
  }) => _db.reportLists.where(
    (l) => l.serviceDay.isAtSameMomentAs(day),
    includeDeleted: includeDeleted,
  );

  Future<void> deleteAll() async {
    if (await _db.reportLists.softDeleteAll()) notifyListeners();
  }

  Future<void> delete(int id) async {
    if (await _db.reportLists.softDelete(id)) notifyListeners();
  }

  Future<List<ReportList>> history({bool includeDeleted = false}) async =>
      (await _db.reportLists.all(includeDeleted: includeDeleted))
        ..sort((a, b) => b.serviceDay.compareTo(a.serviceDay));
}
