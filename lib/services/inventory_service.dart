import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/inventory.dart';
import 'shift_service.dart';
import 'sync_meta.dart';

class InventoryService extends ChangeNotifier {
  InventoryService._();
  static final InventoryService instance = InventoryService._();

  Isar get _isar => ShiftService.instance.isar;

  /// Legacy save (used by the old name+value flow + sync engine).
  Future<int> save(Inventory inv) async {
    SyncMeta.stamp(inv);
    late int id;
    await _isar.writeTxn(() async {
      id = await _isar.inventorys.put(inv);
    });
    notifyListeners();
    return id;
  }

  Future<Inventory> startSession({
    required String name,
    required String code,
  }) async {
    final now = DateTime.now();
    final inv = Inventory()
      ..name = name
      ..code = code
      ..createdAt = now
      ..startedAt = now
      ..runningSince = now
      ..accumulatedSeconds = 0
      ..valueCents = 0;
    SyncMeta.stamp(inv);
    await _isar.writeTxn(() async {
      inv.id = await _isar.inventorys.put(inv);
    });
    notifyListeners();
    return inv;
  }

  Future<void> pause(Inventory inv) async {
    if (!inv.isRunning) return;
    final now = DateTime.now();
    inv.accumulatedSeconds +=
        now.difference(inv.runningSince!).inSeconds.clamp(0, 1 << 31);
    inv.runningSince = null;
    SyncMeta.stamp(inv);
    await _isar.writeTxn(() => _isar.inventorys.put(inv));
    notifyListeners();
  }

  Future<void> resume(Inventory inv) async {
    if (inv.isFinalized || inv.isRunning) return;
    inv.runningSince = DateTime.now();
    SyncMeta.stamp(inv);
    await _isar.writeTxn(() => _isar.inventorys.put(inv));
    notifyListeners();
  }

  Future<void> finalize(Inventory inv, {required int finalValueCents}) async {
    if (inv.isFinalized) return;
    final now = DateTime.now();
    if (inv.runningSince != null) {
      inv.accumulatedSeconds +=
          now.difference(inv.runningSince!).inSeconds.clamp(0, 1 << 31);
    }
    inv.runningSince = null;
    inv.finishedAt = now;
    inv.finalValueCents = finalValueCents;
    inv.valueCents = finalValueCents;
    SyncMeta.stamp(inv);
    await _isar.writeTxn(() => _isar.inventorys.put(inv));
    notifyListeners();
  }

  Future<Inventory?> getByUuid(String uuid) =>
      _isar.inventorys.filter().syncUuidEqualTo(uuid).findFirst();

  Future<Inventory?> getById(int id) => _isar.inventorys.get(id);

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

  Future<List<Inventory>> history({bool includeDeleted = false}) {
    if (includeDeleted) {
      return _isar.inventorys.where().sortByCreatedAtDesc().findAll();
    }
    return _isar.inventorys
        .filter()
        .syncDeletedAtIsNull()
        .sortByCreatedAtDesc()
        .findAll();
  }
}
