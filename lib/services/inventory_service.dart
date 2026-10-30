import 'package:flutter/foundation.dart';

import '../models/inventory.dart';
import 'local_db.dart';
import 'sync_meta.dart';

class InventoryService extends ChangeNotifier {
  InventoryService._() {
    LocalDb.listenRemote(const {'Inventory'}, notifyListeners);
  }
  static final InventoryService instance = InventoryService._();

  LocalDb get _db => LocalDb.instance;

  Future<int> save(Inventory inv) async {
    SyncMeta.stamp(inv);
    final id = await _db.inventories.put(inv);
    notifyListeners();
    return id;
  }

  Future<void> finalize(Inventory inv, {required int finalValueCents}) async {
    if (inv.isFinalized) return;
    inv.finishedAt = DateTime.now();
    inv.finalValueCents = finalValueCents;
    inv.valueCents = finalValueCents;
    SyncMeta.stamp(inv);
    await _db.inventories.put(inv);
    notifyListeners();
  }

  Future<Inventory?> getByUuid(String uuid) => _db.inventories.firstWhere(
    (i) => i.syncUuid == uuid,
    includeDeleted: true,
  );

  Future<Inventory?> getById(int id) => _db.inventories.get(id);

  Future<void> delete(int id) async {
    if (await _db.inventories.softDelete(id)) notifyListeners();
  }

  Future<void> deleteAll() async {
    if (await _db.inventories.softDeleteAll()) notifyListeners();
  }

  Future<List<Inventory>> history({bool includeDeleted = false}) async =>
      (await _db.inventories.all(includeDeleted: includeDeleted))
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}
