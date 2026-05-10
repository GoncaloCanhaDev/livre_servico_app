import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/daily_tasks.dart';
import '../models/opening_list.dart';
import 'shift_service.dart';

class DailyTasksService extends ChangeNotifier {
  DailyTasksService._();
  static final DailyTasksService instance = DailyTasksService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<DailyTasks> currentOrCreate() async {
    final day = currentServiceDay();
    final existing = await _isar.dailyTasks
        .filter()
        .serviceDayEqualTo(day)
        .findFirst();
    if (existing != null) {
      if (_sanitize(existing)) {
        await _isar.writeTxn(() async {
          await _isar.dailyTasks.put(existing);
        });
      }
      return existing;
    }
    final created = DailyTasks()..serviceDay = day;
    await _isar.writeTxn(() async {
      created.id = await _isar.dailyTasks.put(created);
    });
    return created;
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
    return changed;
  }

  Future<void> save(DailyTasks t) async {
    await _isar.writeTxn(() async {
      await _isar.dailyTasks.put(t);
    });
    notifyListeners();
  }

  Future<List<DailyTasks>> history() {
    return _isar.dailyTasks.where().sortByServiceDayDesc().findAll();
  }
}
