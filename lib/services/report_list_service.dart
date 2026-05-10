import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/opening_list.dart';
import '../models/report_list.dart';
import 'shift_service.dart';

class ReportListService extends ChangeNotifier {
  ReportListService._();
  static final ReportListService instance = ReportListService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<ReportList> currentOrCreate() async {
    final day = currentServiceDay();
    final existing = await _isar.reportLists
        .filter()
        .serviceDayEqualTo(day)
        .findFirst();
    if (existing != null) return existing;
    final created = ReportList()..serviceDay = day;
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
    await _isar.writeTxn(() async {
      await _isar.reportLists.put(list);
    });
    notifyListeners();
  }

  Future<void> finalize(ReportList list) async {
    if (list.isFinalized) return;
    list.finalizedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.reportLists.put(list);
    });
    notifyListeners();
  }

  Future<void> deleteAll() async {
    await _isar.writeTxn(() async {
      await _isar.reportLists.clear();
    });
    notifyListeners();
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.reportLists.delete(id);
    });
    notifyListeners();
  }

  Future<List<ReportList>> history() {
    return _isar.reportLists.where().sortByServiceDayDesc().findAll();
  }
}
