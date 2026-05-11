import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/inventory.dart';
import 'shift_service.dart';

class InventoryService extends ChangeNotifier {
  InventoryService._();
  static final InventoryService instance = InventoryService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<int> save(Inventory inv) async {
    late int id;
    await _isar.writeTxn(() async {
      id = await _isar.inventorys.put(inv);
    });
    notifyListeners();
    return id;
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.inventorys.delete(id);
    });
    notifyListeners();
  }

  Future<void> deleteAll() async {
    await _isar.writeTxn(() async {
      await _isar.inventorys.clear();
    });
    notifyListeners();
  }

  Future<List<Inventory>> history() {
    return _isar.inventorys.where().sortByCreatedAtDesc().findAll();
  }
}
