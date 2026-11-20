import 'package:flutter/foundation.dart';

import '../models/opening_list.dart';
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
  /// Compared by service day, not by adding 24 hours, so the day the clocks
  /// change keeps its own camiões.
  Future<List<TruckReception>> forServiceDay(DateTime day) => _db
      .truckReceptions
      .where((t) => currentServiceDay(t.arrivalTime).isAtSameMomentAs(day));

  Future<List<TruckReception>> all({bool includeDeleted = false}) async =>
      (await _db.truckReceptions.all(includeDeleted: includeDeleted))
        ..sort((a, b) => b.arrivalTime.compareTo(a.arrivalTime));
}
