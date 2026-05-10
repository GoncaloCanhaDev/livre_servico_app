import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/truck_reception.dart';
import 'shift_service.dart';

class TruckService extends ChangeNotifier {
  TruckService._();
  static final TruckService instance = TruckService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<int> save(TruckReception truck) async {
    late int id;
    await _isar.writeTxn(() async {
      id = await _isar.truckReceptions.put(truck);
    });
    notifyListeners();
    return id;
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.truckReceptions.delete(id);
    });
    notifyListeners();
  }

  Future<void> deleteAll() async {
    await _isar.writeTxn(() async {
      await _isar.truckReceptions.clear();
    });
    notifyListeners();
  }

  Future<List<TruckReception>> all() {
    return _isar.truckReceptions
        .where()
        .sortByArrivalTimeDesc()
        .findAll();
  }
}
