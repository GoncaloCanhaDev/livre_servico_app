import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/inventory.dart';
import 'shift_service.dart';
import 'sync_meta.dart';

class InventoryService extends ChangeNotifier {
  InventoryService._();
  static final InventoryService instance = InventoryService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<int> save(Inventory inv) async {
    SyncMeta.stamp(inv);
    late int id;
    await _isar.writeTxn(() async {
      id = await _isar.inventorys.put(inv);
    });
    notifyListeners();
    return id;
  }

  Future<void> delete(int id) async {
    final row = await _isar.inventorys.get(id);
    if (row == null || row.syncDeletedAt != null) return;
    SyncMeta.softDelete(row);
    await _isar.writeTxn(() async {
      await _isar.inventorys.put(row);
    });
    notifyListeners();
  }

  Future<void> deleteAll() async {
    final rows =
        await _isar.inventorys.filter().syncDeletedAtIsNull().findAll();
    if (rows.isEmpty) return;
    for (final r in rows) {
      SyncMeta.softDelete(r);
    }
    await _isar.writeTxn(() async {
      await _isar.inventorys.putAll(rows);
    });
    notifyListeners();
  }

  Future<List<Inventory>> history() {
    return _isar.inventorys
        .filter()
        .syncDeletedAtIsNull()
        .sortByCreatedAtDesc()
        .findAll();
  }
}
