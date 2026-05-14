import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/product.dart';
import 'shift_service.dart';
import 'sync_meta.dart';

class ProductService extends ChangeNotifier {
  ProductService._();
  static final ProductService instance = ProductService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<int> save(Product p) async {
    p.updatedAt = DateTime.now();
    SyncMeta.stamp(p);
    late int id;
    await _isar.writeTxn(() async {
      id = await _isar.products.put(p);
    });
    notifyListeners();
    return id;
  }

  Future<void> delete(int id) async {
    final row = await _isar.products.get(id);
    if (row == null || row.syncDeletedAt != null) return;
    SyncMeta.softDelete(row);
    await _isar.writeTxn(() async {
      await _isar.products.put(row);
    });
    notifyListeners();
  }

  Future<Product?> findByEan(String ean) {
    return _isar.products
        .filter()
        .syncDeletedAtIsNull()
        .eanEqualTo(ean)
        .findFirst();
  }

  Future<Product?> findById(int id) async {
    final row = await _isar.products.get(id);
    if (row == null || row.syncDeletedAt != null) return null;
    return row;
  }

  Future<List<Product>> all({String query = ''}) async {
    final base = _isar.products
        .filter()
        .syncDeletedAtIsNull()
        .sortByName();
    if (query.isEmpty) {
      return base.findAll();
    }
    final q = query.trim().toLowerCase();
    final all = await base.findAll();
    return all
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.ean.contains(q) ||
            p.sapCode.contains(q))
        .toList();
  }
}
