import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/auto_list.dart';
import '../models/daily_tasks.dart';
import '../models/info_entry.dart';
import '../models/inventory.dart';
import '../models/justification.dart';
import '../models/notification_log.dart';
import '../models/opening_list.dart';
import '../models/product.dart';
import '../models/report_list.dart';
import '../models/shift_event.dart';
import '../models/truck_reception.dart';
import '../models/visual_list.dart';
import 'notification_service.dart';
import 'sync_meta.dart';
import 'task_notification_service.dart';

enum WorkStatus { idle, working, paused }

class ShiftService extends ChangeNotifier {
  ShiftService._(this._isar);

  static late ShiftService instance;

  final Isar _isar;
  Isar get isar => _isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [
        ShiftEventSchema,
        TruckReceptionSchema,
        ProductSchema,
        OpeningListSchema,
        AutoListSchema,
        ReportListSchema,
        VisualListSchema,
        DailyTasksSchema,
        InventorySchema,
        InfoEntrySchema,
        NotificationLogSchema,
        JustificationSchema,
      ],
      directory: dir.path,
      name: 'livre_servico',
    );
    instance = ShiftService._(isar);
    await instance._backfillSync();
    await instance._refresh();
  }

  Future<void> _backfillSync() async {
    Future<void> backfill<T>(IsarCollection<T> col) async {
      final rows = await col.where().findAll();
      final needsFix =
          rows.where((r) => SyncMeta.backfillIfNeeded(r)).toList();
      if (needsFix.isEmpty) return;
      await _isar.writeTxn(() => col.putAll(needsFix));
    }

    await backfill(_isar.shiftEvents);
    await backfill(_isar.truckReceptions);
    await backfill(_isar.products);
    await backfill(_isar.openingLists);
    await backfill(_isar.autoLists);
    await backfill(_isar.reportLists);
    await backfill(_isar.visualLists);
    await backfill(_isar.dailyTasks);
    await backfill(_isar.inventorys);
    await backfill(_isar.infoEntrys);
    await backfill(_isar.notificationLogs);
    await backfill(_isar.justifications);
  }

  WorkStatus _status = WorkStatus.idle;
  WorkStatus get status => _status;

  int? _currentShiftId;
  int? get currentShiftId => _currentShiftId;

  ShiftEvent? _lastEvent;
  ShiftEvent? get lastEvent => _lastEvent;

  Future<void> refresh() => _refresh();

  Future<void> _refresh() async {
    final last = await _isar.shiftEvents
        .filter()
        .syncDeletedAtIsNull()
        .sortByTimestampDesc()
        .findFirst();
    _lastEvent = last;
    if (last == null || last.type == ShiftEventType.clockOut) {
      _status = WorkStatus.idle;
      _currentShiftId = null;
    } else {
      _currentShiftId = last.shiftId;
      _status = (last.type == ShiftEventType.pause || last.type == ShiftEventType.lunch)
          ? WorkStatus.paused
          : WorkStatus.working;
    }
    notifyListeners();
  }

  Future<void> clockIn() async {
    if (_status != WorkStatus.idle) return;
    final now = DateTime.now();
    final shiftId = now.millisecondsSinceEpoch;
    final event = ShiftEvent.create(
      timestamp: now,
      type: ShiftEventType.clockIn,
      shiftId: shiftId,
    );
    SyncMeta.stamp(event);
    await _isar.writeTxn(() async {
      await _isar.shiftEvents.put(event);
    });
    await NotificationService.instance.scheduleStraightWorkReminders(Duration.zero);
    await NotificationService.instance.scheduleTotalWorkReminders(now);
    await TaskNotificationService.instance.rescheduleAll();
    
    await _refresh();
  }

  Future<void> pause({bool isLunch = false}) async {
    if (_status != WorkStatus.working || _currentShiftId == null) return;
    
    final pauseTime = DateTime.now();
    final event = ShiftEvent.create(
      timestamp: pauseTime,
      type: isLunch ? ShiftEventType.lunch : ShiftEventType.pause,
      shiftId: _currentShiftId!,
    );
    SyncMeta.stamp(event);
    await _isar.writeTxn(() async {
      await _isar.shiftEvents.put(event);
    });
    
    await NotificationService.instance.schedulePauseReminders(
      isLunch: isLunch,
      pauseTime: pauseTime,
    );
    await NotificationService.instance.cancelStraightWorkReminders();
    
    await _refresh();
  }

  Future<void> resume() async {
    if (_status != WorkStatus.paused || _currentShiftId == null) return;
    final event = ShiftEvent.create(
      timestamp: DateTime.now(),
      type: ShiftEventType.resume,
      shiftId: _currentShiftId!,
    );
    SyncMeta.stamp(event);
    await _isar.writeTxn(() async {
      await _isar.shiftEvents.put(event);
    });
    
    await NotificationService.instance.cancelPauseReminders();
    final events = await eventsForShift(_currentShiftId!);
    final worked = computeWorked(events);
    await NotificationService.instance.scheduleStraightWorkReminders(worked);
    
    await _refresh();
  }

  Future<void> clockOut() async {
    if (_status == WorkStatus.idle || _currentShiftId == null) return;
    final event = ShiftEvent.create(
      timestamp: DateTime.now(),
      type: ShiftEventType.clockOut,
      shiftId: _currentShiftId!,
    );
    SyncMeta.stamp(event);
    await _isar.writeTxn(() async {
      await _isar.shiftEvents.put(event);
    });
    await NotificationService.instance.cancelPauseReminders();
    await NotificationService.instance.cancelStraightWorkReminders();
    await NotificationService.instance.cancelTotalWorkReminders();
    await TaskNotificationService.instance.cancelAll();
    
    await _refresh();
  }

  Future<List<ShiftEvent>> eventsForShift(int shiftId,
      {bool includeDeleted = false}) {
    if (includeDeleted) {
      return _isar.shiftEvents
          .filter()
          .shiftIdEqualTo(shiftId)
          .sortByTimestamp()
          .findAll();
    }
    return _isar.shiftEvents
        .filter()
        .syncDeletedAtIsNull()
        .shiftIdEqualTo(shiftId)
        .sortByTimestamp()
        .findAll();
  }

  Future<void> deleteAllShifts() async {
    final rows = await _isar.shiftEvents
        .filter()
        .syncDeletedAtIsNull()
        .findAll();
    if (rows.isEmpty) return;
    for (final r in rows) {
      SyncMeta.softDelete(r);
    }
    await _isar.writeTxn(() async {
      await _isar.shiftEvents.putAll(rows);
    });
    await _refresh();
  }

  Future<void> deleteShift(int shiftId) async {
    final rows = await _isar.shiftEvents
        .filter()
        .syncDeletedAtIsNull()
        .shiftIdEqualTo(shiftId)
        .findAll();
    if (rows.isEmpty) return;
    for (final r in rows) {
      SyncMeta.softDelete(r);
    }
    await _isar.writeTxn(() async {
      await _isar.shiftEvents.putAll(rows);
    });
    await _refresh();
  }

  Future<List<int>> allShiftIdsDesc({bool includeDeleted = false}) async {
    final all = includeDeleted
        ? await _isar.shiftEvents.where().sortByTimestampDesc().findAll()
        : await _isar.shiftEvents
            .filter()
            .syncDeletedAtIsNull()
            .sortByTimestampDesc()
            .findAll();
    final seen = <int>{};
    final result = <int>[];
    for (final e in all) {
      if (seen.add(e.shiftId)) result.add(e.shiftId);
    }
    return result;
  }
}

Duration computeWorked(List<ShiftEvent> events, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  Duration total = Duration.zero;
  DateTime? activeSince;
  for (final e in events) {
    switch (e.type) {
      case ShiftEventType.clockIn:
      case ShiftEventType.resume:
        activeSince = e.timestamp;
        break;
      case ShiftEventType.pause:
      case ShiftEventType.lunch:
      case ShiftEventType.clockOut:
        if (activeSince != null) {
          total += e.timestamp.difference(activeSince);
          activeSince = null;
        }
        break;
    }
  }
  if (activeSince != null) {
    total += reference.difference(activeSince);
  }
  return total;
}

Duration computePaused(List<ShiftEvent> events, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  Duration total = Duration.zero;
  DateTime? pausedSince;
  for (final e in events) {
    switch (e.type) {
      case ShiftEventType.pause:
      case ShiftEventType.lunch:
        pausedSince = e.timestamp;
        break;
      case ShiftEventType.resume:
        if (pausedSince != null) {
          total += e.timestamp.difference(pausedSince);
          pausedSince = null;
        }
        break;
      case ShiftEventType.clockIn:
        pausedSince = null;
        break;
      case ShiftEventType.clockOut:
        if (pausedSince != null) {
          total += e.timestamp.difference(pausedSince);
          pausedSince = null;
        }
        break;
    }
  }
  if (pausedSince != null) {
    total += reference.difference(pausedSince);
  }
  return total;
}
