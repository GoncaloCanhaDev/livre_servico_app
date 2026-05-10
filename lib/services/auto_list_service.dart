import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/auto_list.dart';
import 'shift_service.dart';

class AutoListService extends ChangeNotifier {
  AutoListService._();
  static final AutoListService instance = AutoListService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<void> add({
    required int congelados,
    required int opls,
    required int naoPereciveis,
  }) async {
    final entry = AutoList()
      ..createdAt = DateTime.now()
      ..congelados = congelados
      ..opls = opls
      ..naoPereciveis = naoPereciveis;
    await _isar.writeTxn(() async {
      await _isar.autoLists.put(entry);
    });
    notifyListeners();
  }

  Future<void> deleteAll() async {
    await _isar.writeTxn(() async {
      await _isar.autoLists.clear();
    });
    notifyListeners();
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.autoLists.delete(id);
    });
    notifyListeners();
  }

  Future<List<AutoList>> history() {
    return _isar.autoLists.where().sortByCreatedAtDesc().findAll();
  }
}
