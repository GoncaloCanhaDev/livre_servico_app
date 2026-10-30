import 'package:flutter/foundation.dart';

import '../models/pedido.dart';
import 'local_db.dart';
import 'sync_meta.dart';

class PedidoService extends ChangeNotifier {
  PedidoService._();
  static final PedidoService instance = PedidoService._();

  LocalDb get _db => LocalDb.instance;

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
    await _db.pedidos.put(p);
    notifyListeners();
    return p;
  }

  Future<Pedido?> getById(int id) => _db.pedidos.get(id);

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
    await _db.pedidos.put(p);
    notifyListeners();
  }

  Future<void> finalize(Pedido p) async {
    if (p.isFinalized) return;
    p.finishedAt = DateTime.now();
    SyncMeta.stamp(p);
    await _db.pedidos.put(p);
    notifyListeners();
  }

  static String? _blankToNull(String? s) =>
      (s == null || s.trim().isEmpty) ? null : s.trim();

  Future<void> deleteAll() async {
    if (await _db.pedidos.softDeleteAll()) notifyListeners();
  }

  Future<void> delete(int id) async {
    if (await _db.pedidos.softDelete(id)) notifyListeners();
  }

  /// The pedidos not finalized yet that have an expected date.
  Future<List<Pedido>> openWithDate() => _db.pedidos.where(
    (p) => p.finishedAt == null && p.expectedDate != null,
  );

  Future<List<Pedido>> history({bool includeDeleted = false}) async =>
      (await _db.pedidos.all(includeDeleted: includeDeleted))
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}
