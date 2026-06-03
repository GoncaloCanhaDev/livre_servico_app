import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/pedido.dart';
import 'shift_service.dart';
import 'sync_meta.dart';

class PedidoService extends ChangeNotifier {
  PedidoService._();
  static final PedidoService instance = PedidoService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<Pedido> startSession() async {
    final p = Pedido()..createdAt = DateTime.now();
    SyncMeta.stamp(p);
    await _isar.writeTxn(() async {
      p.id = await _isar.pedidos.put(p);
    });
    notifyListeners();
    return p;
  }

  Future<Pedido?> getById(int id) => _isar.pedidos.get(id);

  Future<void> finalize(Pedido p, {required String numero}) async {
    if (p.isFinalized) return;
    p.numero = numero;
    p.finishedAt = DateTime.now();
    SyncMeta.stamp(p);
    await _isar.writeTxn(() => _isar.pedidos.put(p));
    notifyListeners();
  }

  Future<void> deleteAll() async {
    final rows =
        await _isar.pedidos.filter().syncDeletedAtIsNull().findAll();
    if (rows.isEmpty) return;
    for (final r in rows) {
      SyncMeta.softDelete(r);
    }
    await _isar.writeTxn(() => _isar.pedidos.putAll(rows));
    notifyListeners();
  }

  Future<void> delete(int id) async {
    final row = await _isar.pedidos.get(id);
    if (row == null || row.syncDeletedAt != null) return;
    SyncMeta.softDelete(row);
    await _isar.writeTxn(() => _isar.pedidos.put(row));
    notifyListeners();
  }

  Future<List<Pedido>> history({bool includeDeleted = false}) {
    if (includeDeleted) {
      return _isar.pedidos.where().sortByCreatedAtDesc().findAll();
    }
    return _isar.pedidos
        .filter()
        .syncDeletedAtIsNull()
        .sortByCreatedAtDesc()
        .findAll();
  }
}
