import 'package:flutter/foundation.dart';

import '../models/task_window.dart';
import 'local_db.dart';
import 'sync_meta.dart';

/// The tasks' windows (see [TaskWindow]), kept in memory so the screens and
/// `AutoMarkService` read them at once. Loaded at startup, after saves,
/// remote changes, a backup import and a wipe.
class TaskWindowService extends ChangeNotifier {
  TaskWindowService._() {
    LocalDb.listenRemote(const {'TaskWindow'}, load);
  }
  static final TaskWindowService instance = TaskWindowService._();

  LocalDb get _db => LocalDb.instance;

  Map<String, TaskWindow> _rows = {};

  Future<void> load() async {
    _rows = {for (final w in await _db.taskWindows.all()) w.taskKey: w};
    notifyListeners();
  }

  /// [key]'s window: the one a Chefe saved, or [defaultTaskWindow].
  TaskWindow windowFor(String key) =>
      _rows[key]?.copy() ?? defaultTaskWindow(key);

  /// Whether [key] has a window saved (not the default).
  bool isCustom(String key) => _rows.containsKey(key);

  Future<void> save(TaskWindow w) async {
    final row = await _db.taskWindows.firstWhere((r) => r.taskKey == w.taskKey);
    final target = row ?? (TaskWindow(taskKey: w.taskKey));
    target
      ..opensAt = w.opensAt
      ..closesAt = w.closesAt
      ..auto = w.auto;
    SyncMeta.stamp(target);
    await _db.taskWindows.put(target);
    await load();
  }

  /// Back to [defaultTaskWindow].
  Future<void> reset(String key) async {
    final row = await _db.taskWindows.firstWhere((r) => r.taskKey == key);
    if (row == null) return;
    await _db.taskWindows.softDelete(row.id);
    await load();
  }
}
