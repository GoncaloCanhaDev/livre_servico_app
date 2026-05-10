import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/product.dart';
import 'shift_service.dart';

class ProductService extends ChangeNotifier {
  ProductService._();
  static final ProductService instance = ProductService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<int> save(Product p) async {
    p.updatedAt = DateTime.now();
    late int id;
    await _isar.writeTxn(() async {
      id = await _isar.products.put(p);
    });
    notifyListeners();
    return id;
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.products.delete(id);
    });
    notifyListeners();
  }

  Future<Product?> findByEan(String ean) {
    return _isar.products.filter().eanEqualTo(ean).findFirst();
  }

  Future<Product?> findById(int id) {
    return _isar.products.get(id);
  }

  Future<List<Product>> all({String query = ''}) async {
    if (query.isEmpty) {
      return _isar.products.where().sortByName().findAll();
    }
    final q = query.trim().toLowerCase();
    final all = await _isar.products.where().sortByName().findAll();
    return all
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.ean.contains(q) ||
            p.sapCode.contains(q))
        .toList();
  }
}
