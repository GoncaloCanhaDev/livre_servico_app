import 'package:flutter/foundation.dart';

import '../models/daily_tasks.dart';
import '../models/opening_list.dart';
import 'local_db.dart';
import 'sync_meta.dart';

class DailyTasksService extends ChangeNotifier {
  DailyTasksService._();
  static final DailyTasksService instance = DailyTasksService._();

  LocalDb get _db => LocalDb.instance;

  Future<DailyTasks> currentOrCreate() async {
    final existing = await find(currentServiceDay());
    if (existing != null) {
      if (_sanitize(existing)) {
        SyncMeta.stamp(existing);
        await _db.dailyTasks.put(existing);
      }
      return existing;
    }
    return forDay(currentServiceDay());
  }

  bool _sanitize(DailyTasks t) {
    var changed = false;
    if (t.alteracoesPrecoCount < 0) {
      t.alteracoesPrecoCount = 0;
      changed = true;
    }
    if (t.verificacaoValidadesCount < 0) {
      t.verificacaoValidadesCount = 0;
      changed = true;
    }
    if (t.validadesNoiteCount < 0) {
      t.validadesNoiteCount = 0;
      changed = true;
    }
    return changed;
  }

  /// The row for [serviceDay], without creating one; null when none.
  Future<DailyTasks?> find(DateTime serviceDay) => _db.dailyTasks.firstWhere(
    (t) => t.serviceDay.isAtSameMomentAs(serviceDay),
  );

  Future<DailyTasks> forDay(DateTime serviceDay) async {
    final existing = await find(serviceDay);
    if (existing != null) return existing;
    final created = DailyTasks()..serviceDay = serviceDay;
    SyncMeta.stamp(created);
    await _db.dailyTasks.put(created);
    return created;
  }

  Future<void> save(DailyTasks t) async {
    t.lastUpdatedAt = DateTime.now();
    SyncMeta.stamp(t);
    await _db.dailyTasks.put(t);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    if (await _db.dailyTasks.softDeleteAll()) notifyListeners();
  }

  Future<void> delete(int id) async {
    if (await _db.dailyTasks.softDelete(id)) notifyListeners();
  }

  Future<List<DailyTasks>> history({bool includeDeleted = false}) async =>
      (await _db.dailyTasks.all(includeDeleted: includeDeleted))
        ..sort((a, b) => b.serviceDay.compareTo(a.serviceDay));
}
