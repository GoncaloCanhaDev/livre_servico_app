import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/custom_task.dart';
import 'shift_service.dart';
import 'sync_meta.dart';

class CustomTaskService extends ChangeNotifier {
  CustomTaskService._();
  static final CustomTaskService instance = CustomTaskService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<List<CustomTask>> tasks() => _isar.customTasks
      .filter()
      .syncDeletedAtIsNull()
      .sortByCreatedAt()
      .findAll();

  Future<CustomTask> addTask({
    required String title,
    required CustomTaskFrequency frequency,
    required CustomTaskInputType inputType,
  }) async {
    final task = CustomTask()
      ..title = title
      ..frequency = frequency
      ..inputType = inputType
      ..createdAt = DateTime.now();
    SyncMeta.stamp(task);
    await _isar.writeTxn(() => _isar.customTasks.put(task));
    notifyListeners();
    return task;
  }

  Future<void> deleteTask(String taskUuid) async {
    final task = await _isar.customTasks
        .filter()
        .syncUuidEqualTo(taskUuid)
        .findFirst();
    if (task == null || task.syncDeletedAt != null) return;
    SyncMeta.softDelete(task);
    await _isar.writeTxn(() => _isar.customTasks.put(task));
    notifyListeners();
  }

  Future<CustomTaskEntry?> entryFor(String taskUuid, DateTime periodKey) {
    return _isar.customTaskEntrys
        .filter()
        .taskUuidEqualTo(taskUuid)
        .periodKeyEqualTo(periodKey)
        .syncDeletedAtIsNull()
        .findFirst();
  }

  /// Marks the entry for `(taskUuid, periodKey)` as done by [who]. Finds the
  /// existing entry for that period, or creates one if this is the first
  /// completion.
  Future<void> complete({
    required String taskUuid,
    required DateTime periodKey,
    required String who,
    int? count,
    bool backdated = false,
  }) async {
    var entry = await entryFor(taskUuid, periodKey);
    entry ??= CustomTaskEntry()
      ..taskUuid = taskUuid
      ..periodKey = periodKey;
    entry.done = true;
    entry.doneBy = who;
    entry.doneAt = DateTime.now();
    entry.count = count;
    entry.backdated = backdated;
    SyncMeta.stamp(entry);
    final toSave = entry;
    await _isar.writeTxn(() => _isar.customTaskEntrys.put(toSave));
    notifyListeners();
  }
}
