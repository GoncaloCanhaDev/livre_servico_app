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

  /// Plans an inventory to do ("Por fazer"), by [dueDate] if given.
  Future<Inventory> plan({
    required String name,
    required String code,
    DateTime? dueDate,
    String? plannedBy,
  }) async {
    final now = DateTime.now();
    final inv = Inventory()
      ..name = name
      ..code = code
      ..valueCents = 0
      ..createdAt = now
      ..plannedAt = now
      ..plannedBy = plannedBy
      ..dueDate = dueDate;
    await save(inv);
    return inv;
  }

  /// Marks the planned [inv] done now by [names], with its value.
  Future<void> markDone(
    Inventory inv, {
    required List<String> names,
    required int finalValueCents,
  }) async {
    if (!inv.isToDo) return;
    final now = DateTime.now();
    inv
      ..createdAt = now
      ..startedAt = now
      ..finishedAt = now
      ..createdByNames = names
      ..valueCents = finalValueCents
      ..finalValueCents = finalValueCents;
    await save(inv);
  }

  /// The planned inventories not done yet: those due first, then those
  /// with no date, each in the order planned.
  Future<List<Inventory>> toDo() async =>
      (await _db.inventories.where((i) => i.isToDo))..sort((a, b) {
        final ad = a.dueDate, bd = b.dueDate;
        if (ad != null && bd != null && ad != bd) return ad.compareTo(bd);
        if ((ad == null) != (bd == null)) return ad == null ? 1 : -1;
        return a.plannedAt!.compareTo(b.plannedAt!);
      });

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

  /// The inventories done (and older ones), newest first; not those still
  /// to do.
  Future<List<Inventory>> history({bool includeDeleted = false}) async =>
      (await _db.inventories.where(
        (i) => !i.isToDo,
        includeDeleted: includeDeleted,
      ))..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}
