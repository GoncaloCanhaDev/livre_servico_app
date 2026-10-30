import 'package:flutter/foundation.dart';

import '../models/truck_reception.dart';
import 'local_db.dart';
import 'sync_meta.dart';

class TruckService extends ChangeNotifier {
  TruckService._() {
    LocalDb.listenRemote(const {'TruckReception'}, notifyListeners);
  }
  static final TruckService instance = TruckService._();

  LocalDb get _db => LocalDb.instance;

  Future<int> save(TruckReception truck) async {
    SyncMeta.stamp(truck);
    final id = await _db.truckReceptions.put(truck);
    notifyListeners();
    return id;
  }

  Future<void> delete(int id) async {
    if (await _db.truckReceptions.softDelete(id)) notifyListeners();
  }

  Future<void> deleteAll() async {
    if (await _db.truckReceptions.softDeleteAll()) notifyListeners();
  }

  /// The camiões that arrived during the service day starting at [day]
  /// (05:00 to 05:00).
  Future<List<TruckReception>> forServiceDay(DateTime day) {
    final end = day.add(const Duration(days: 1));
    return _db.truckReceptions.where(
      (t) => !t.arrivalTime.isBefore(day) && t.arrivalTime.isBefore(end),
    );
  }

  Future<List<TruckReception>> all({bool includeDeleted = false}) async =>
      (await _db.truckReceptions.all(includeDeleted: includeDeleted))
        ..sort((a, b) => b.arrivalTime.compareTo(a.arrivalTime));
}
