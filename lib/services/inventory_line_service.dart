import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/inventory_line.dart';
import '../models/product.dart';
import 'product_service.dart';
import 'shift_service.dart';
import 'sync_meta.dart';

class InventoryLineService extends ChangeNotifier {
  InventoryLineService._();
  static final InventoryLineService instance = InventoryLineService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<List<InventoryLine>> linesFor(String parentUuid,
      {bool includeDeleted = false}) {
    if (includeDeleted) {
      return _isar.inventoryLines
          .filter()
          .parentUuidEqualTo(parentUuid)
          .sortByUpdatedAtDesc()
          .findAll();
    }
    return _isar.inventoryLines
        .filter()
        .parentUuidEqualTo(parentUuid)
        .syncDeletedAtIsNull()
        .sortByUpdatedAtDesc()
        .findAll();
  }

  Future<InventoryLine?> findByEan(String parentUuid, String ean) {
    return _isar.inventoryLines
        .filter()
        .parentUuidEqualTo(parentUuid)
        .eanEqualTo(ean)
        .syncDeletedAtIsNull()
        .findFirst();
  }

  /// Adds [count] units of [ean] to the inventory. If a line for this EAN
  /// already exists, accumulates instead of creating a new line. Returns the
  /// stored line so callers can react (e.g. flag "produto desconhecido").
  Future<InventoryLine> addScan({
    required String parentUuid,
    required String ean,
    required int count,
  }) async {
    final now = DateTime.now();
    final existing = await findByEan(parentUuid, ean);
    Product? product;
    if (existing == null || existing.productName == null) {
      product = await ProductService.instance.findByEan(ean);
    }
    final line = existing ??
        (InventoryLine()
          ..parentUuid = parentUuid
          ..ean = ean
          ..createdAt = now);
    line.count += count;
    line.updatedAt = now;
    if (line.productName == null && product != null) {
      line.productName = product.name;
    }
    SyncMeta.stamp(line);
    await _isar.writeTxn(() async {
      line.id = await _isar.inventoryLines.put(line);
    });
    notifyListeners();
    return line;
  }

  /// Replaces the absolute count on an existing line.
  Future<void> setCount(InventoryLine line, int count) async {
    if (count < 0) count = 0;
    line.count = count;
    line.updatedAt = DateTime.now();
    SyncMeta.stamp(line);
    await _isar.writeTxn(() => _isar.inventoryLines.put(line));
    notifyListeners();
  }

  /// Attaches a product name to a previously-unmatched line.
  Future<void> setProductName(InventoryLine line, String name) async {
    line.productName = name;
    line.updatedAt = DateTime.now();
    SyncMeta.stamp(line);
    await _isar.writeTxn(() => _isar.inventoryLines.put(line));
    notifyListeners();
  }

  Future<void> delete(int id) async {
    final row = await _isar.inventoryLines.get(id);
    if (row == null || row.syncDeletedAt != null) return;
    SyncMeta.softDelete(row);
    await _isar.writeTxn(() => _isar.inventoryLines.put(row));
    notifyListeners();
  }
}
