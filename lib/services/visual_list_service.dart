import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/opening_list.dart';
import '../models/visual_list.dart';
import 'shift_service.dart';

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
    await _isar.writeTxn(() async {
      await _isar.visualLists.put(entry);
    });
    notifyListeners();
  }

  Future<List<VisualList>> entriesForServiceDay(DateTime day) {
    return _isar.visualLists
        .filter()
        .serviceDayEqualTo(day)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<VisualList>> all() {
    return _isar.visualLists.where().sortByCreatedAtDesc().findAll();
  }
}
