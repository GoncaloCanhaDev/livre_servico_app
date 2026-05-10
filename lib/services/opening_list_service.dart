import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/opening_list.dart';
import 'shift_service.dart';

class OpeningListService extends ChangeNotifier {
  OpeningListService._();
  static final OpeningListService instance = OpeningListService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<OpeningList> currentOrCreate() async {
    final day = currentServiceDay();
    final existing = await _isar.openingLists
        .filter()
        .serviceDayEqualTo(day)
        .findFirst();
    if (existing != null) return existing;
    final created = OpeningList()..serviceDay = day;
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
    await _isar.writeTxn(() async {
      await _isar.openingLists.put(list);
    });
    notifyListeners();
  }

  Future<void> finalize(OpeningList list) async {
    if (list.isFinalized) return;
    list.finalizedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.openingLists.put(list);
    });
    notifyListeners();
  }

  Future<void> deleteAll() async {
    await _isar.writeTxn(() async {
      await _isar.openingLists.clear();
    });
    notifyListeners();
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.openingLists.delete(id);
    });
    notifyListeners();
  }

  Future<List<OpeningList>> history() {
    return _isar.openingLists.where().sortByServiceDayDesc().findAll();
  }
}
