import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/pedido_line.dart';
import 'product_service.dart';
import 'shift_service.dart';
import 'sync_meta.dart';

class PedidoLineService extends ChangeNotifier {
  PedidoLineService._();
  static final PedidoLineService instance = PedidoLineService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<List<PedidoLine>> linesFor(String parentUuid,
      {bool includeDeleted = false}) {
    if (includeDeleted) {
      return _isar.pedidoLines
          .filter()
          .parentUuidEqualTo(parentUuid)
          .sortByUpdatedAtDesc()
          .findAll();
    }
    return _isar.pedidoLines
        .filter()
        .parentUuidEqualTo(parentUuid)
        .syncDeletedAtIsNull()
        .sortByUpdatedAtDesc()
        .findAll();
  }

  Future<PedidoLine?> findByEan(String parentUuid, String ean) {
    return _isar.pedidoLines
        .filter()
        .parentUuidEqualTo(parentUuid)
        .eanEqualTo(ean)
        .syncDeletedAtIsNull()
        .findFirst();
  }

  Future<PedidoLine> addScan({
    required String parentUuid,
    required String ean,
    required int caixas,
  }) async {
    final now = DateTime.now();
    final existing = await findByEan(parentUuid, ean);
    String? productName = existing?.productName;
    if (productName == null) {
      final p = await ProductService.instance.findByEan(ean);
      productName = p?.name;
    }
    final line = existing ??
        (PedidoLine()
          ..parentUuid = parentUuid
          ..ean = ean
          ..createdAt = now);
    line.caixas += caixas;
    line.updatedAt = now;
    if (line.productName == null && productName != null) {
      line.productName = productName;
    }
    SyncMeta.stamp(line);
    await _isar.writeTxn(() async {
      line.id = await _isar.pedidoLines.put(line);
    });
    notifyListeners();
    return line;
  }

  Future<void> setCaixas(PedidoLine line, int caixas) async {
    if (caixas < 0) caixas = 0;
    line.caixas = caixas;
    line.updatedAt = DateTime.now();
    SyncMeta.stamp(line);
    await _isar.writeTxn(() => _isar.pedidoLines.put(line));
    notifyListeners();
  }

  Future<void> setProductName(PedidoLine line, String name) async {
    line.productName = name;
    line.updatedAt = DateTime.now();
    SyncMeta.stamp(line);
    await _isar.writeTxn(() => _isar.pedidoLines.put(line));
    notifyListeners();
  }

  Future<void> delete(int id) async {
    final row = await _isar.pedidoLines.get(id);
    if (row == null || row.syncDeletedAt != null) return;
    SyncMeta.softDelete(row);
    await _isar.writeTxn(() => _isar.pedidoLines.put(row));
    notifyListeners();
  }
}
