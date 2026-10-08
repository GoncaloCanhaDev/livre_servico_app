import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/pedido.dart';
import 'shift_service.dart';
import 'sync_meta.dart';

class PedidoService extends ChangeNotifier {
  PedidoService._();
  static final PedidoService instance = PedidoService._();

  Isar get _isar => ShiftService.instance.isar;

  /// Creates an in-progress pedido from the Novo form.
  Future<Pedido> create({
    required String numero,
    String? supplier,
    DateTime? expectedDate,
  }) async {
    final p = Pedido()
      ..createdAt = DateTime.now()
      ..numero = numero
      ..supplier = _blankToNull(supplier)
      ..expectedDate = expectedDate;
    SyncMeta.stamp(p);
    await _isar.writeTxn(() async {
      p.id = await _isar.pedidos.put(p);
    });
    notifyListeners();
    return p;
  }

  Future<Pedido?> getById(int id) => _isar.pedidos.get(id);

  /// Saves the form's current values on an in-progress pedido; blank text
  /// clears a field.
  Future<void> updateDetails(
    Pedido p, {
    String? numero,
    String? supplier,
    DateTime? expectedDate,
  }) async {
    if (p.isFinalized) return;
    p.numero = _blankToNull(numero);
    p.supplier = _blankToNull(supplier);
    p.expectedDate = expectedDate;
    SyncMeta.stamp(p);
    await _isar.writeTxn(() => _isar.pedidos.put(p));
    notifyListeners();
  }

  Future<void> finalize(Pedido p) async {
    if (p.isFinalized) return;
    p.finishedAt = DateTime.now();
    SyncMeta.stamp(p);
    await _isar.writeTxn(() => _isar.pedidos.put(p));
    notifyListeners();
  }

  static String? _blankToNull(String? s) =>
      (s == null || s.trim().isEmpty) ? null : s.trim();

  Future<void> deleteAll() async {
    final rows = await _isar.pedidos.filter().syncDeletedAtIsNull().findAll();
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

  /// The pedidos not finalized yet that have an expected date.
  Future<List<Pedido>> openWithDate() => _isar.pedidos
      .filter()
      .syncDeletedAtIsNull()
      .finishedAtIsNull()
      .expectedDateIsNotNull()
      .findAll();

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
