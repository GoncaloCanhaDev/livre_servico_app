import 'package:flutter/foundation.dart';

import '../models/custom_task.dart';
import 'local_db.dart';
import 'sync_meta.dart';

class CustomTaskService extends ChangeNotifier {
  CustomTaskService._() {
    LocalDb.listenRemote(const {
      'CustomTask',
      'CustomTaskEntry',
    }, notifyListeners);
  }
  static final CustomTaskService instance = CustomTaskService._();

  LocalDb get _db => LocalDb.instance;

  Future<List<CustomTask>> tasks() async =>
      (await _db.customTasks.all())
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

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
    await _db.customTasks.put(task);
    notifyListeners();
    return task;
  }

  Future<void> deleteTask(String taskUuid) async {
    final task = await _db.customTasks.firstWhere(
      (t) => t.syncUuid == taskUuid,
      includeDeleted: true,
    );
    if (task == null || task.syncDeletedAt != null) return;
    SyncMeta.softDelete(task);
    await _db.customTasks.put(task);
    notifyListeners();
  }

  Future<CustomTaskEntry?> entryFor(String taskUuid, DateTime periodKey) =>
      _db.customTaskEntries.firstWhere(
        (e) =>
            e.taskUuid == taskUuid && e.periodKey.isAtSameMomentAs(periodKey),
      );

  /// Marks the entry for `(taskUuid, periodKey)` as done by [who]. Finds the
  /// existing entry for that period, or creates one if this is the first
  /// completion.
  Future<void> complete({
    required String taskUuid,
    required DateTime periodKey,
    required List<String> who,
    int? count,
    bool backdated = false,
  }) async {
    var entry = await entryFor(taskUuid, periodKey);
    entry ??= CustomTaskEntry()
      ..taskUuid = taskUuid
      ..periodKey = periodKey;
    entry.done = true;
    entry.doneByNames = who;
    entry.doneAt = DateTime.now();
    entry.count = count;
    entry.backdated = backdated;
    SyncMeta.stamp(entry);
    await _db.customTaskEntries.put(entry);
    notifyListeners();
  }
}
