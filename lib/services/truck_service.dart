import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/truck_reception.dart';
import 'shift_service.dart';
import 'sync_meta.dart';

class TruckService extends ChangeNotifier {
  TruckService._();
  static final TruckService instance = TruckService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<int> save(TruckReception truck) async {
    SyncMeta.stamp(truck);
    late int id;
    await _isar.writeTxn(() async {
      id = await _isar.truckReceptions.put(truck);
    });
    notifyListeners();
    return id;
  }

  Future<void> delete(int id) async {
    final row = await _isar.truckReceptions.get(id);
    if (row == null || row.syncDeletedAt != null) return;
    SyncMeta.softDelete(row);
    await _isar.writeTxn(() async {
      await _isar.truckReceptions.put(row);
    });
    notifyListeners();
  }

  Future<void> deleteAll() async {
    final rows = await _isar.truckReceptions
        .filter()
        .syncDeletedAtIsNull()
        .findAll();
    if (rows.isEmpty) return;
    for (final r in rows) {
      SyncMeta.softDelete(r);
    }
    await _isar.writeTxn(() async {
      await _isar.truckReceptions.putAll(rows);
    });
    notifyListeners();
  }

  Future<List<TruckReception>> all({bool includeDeleted = false}) {
    if (includeDeleted) {
      return _isar.truckReceptions
          .where()
          .sortByArrivalTimeDesc()
          .findAll();
    }
    return _isar.truckReceptions
        .filter()
        .syncDeletedAtIsNull()
        .sortByArrivalTimeDesc()
        .findAll();
  }
}
