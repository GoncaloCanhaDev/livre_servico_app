import 'package:flutter/foundation.dart';

import '../models/weekly_tasks.dart';
import 'local_db.dart';
import 'sync_meta.dart';

class WeeklyTasksService extends ChangeNotifier {
  WeeklyTasksService._();
  static final WeeklyTasksService instance = WeeklyTasksService._();

  LocalDb get _db => LocalDb.instance;

  Future<WeeklyTasks?> _find(DateTime serviceWeek) => _db.weeklyTasks
      .firstWhere((t) => t.serviceWeek.isAtSameMomentAs(serviceWeek));

  Future<WeeklyTasks> currentOrCreate() async {
    final week = currentServiceWeek();
    final existing = await _find(week);
    if (existing != null) {
      if (_sanitize(existing)) {
        SyncMeta.stamp(existing);
        await _db.weeklyTasks.put(existing);
      }
      return existing;
    }
    return forWeek(week);
  }

  bool _sanitize(WeeklyTasks t) {
    var changed = false;
    if (t.verificar1aCount < 0) {
      t.verificar1aCount = 0;
      changed = true;
    }
    if (t.verificar4aCount < 0) {
      t.verificar4aCount = 0;
      changed = true;
    }
    return changed;
  }

  Future<WeeklyTasks> forWeek(DateTime serviceWeek) async {
    final existing = await _find(serviceWeek);
    if (existing != null) return existing;
    final created = WeeklyTasks()..serviceWeek = serviceWeek;
    SyncMeta.stamp(created);
    await _db.weeklyTasks.put(created);
    return created;
  }

  Future<void> save(WeeklyTasks t) async {
    t.lastUpdatedAt = DateTime.now();
    SyncMeta.stamp(t);
    await _db.weeklyTasks.put(t);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    if (await _db.weeklyTasks.softDeleteAll()) notifyListeners();
  }

  Future<void> delete(int id) async {
    if (await _db.weeklyTasks.softDelete(id)) notifyListeners();
  }

  Future<List<WeeklyTasks>> history({bool includeDeleted = false}) async =>
      (await _db.weeklyTasks.all(includeDeleted: includeDeleted))
        ..sort((a, b) => b.serviceWeek.compareTo(a.serviceWeek));
}
