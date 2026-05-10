import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/auto_list.dart';
import '../models/daily_tasks.dart';
import '../models/opening_list.dart';
import '../models/report_list.dart';
import '../models/visual_list.dart';
import '../models/product.dart';
import '../models/shift_event.dart';
import '../models/truck_reception.dart';

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
      ],
      directory: dir.path,
      name: 'livre_servico',
    );
    instance = ShiftService._(isar);
    await instance._refresh();
  }

  WorkStatus _status = WorkStatus.idle;
  WorkStatus get status => _status;

  int? _currentShiftId;
  int? get currentShiftId => _currentShiftId;

  ShiftEvent? _lastEvent;
  ShiftEvent? get lastEvent => _lastEvent;

  Future<void> _refresh() async {
    final last = await _isar.shiftEvents
        .where()
        .sortByTimestampDesc()
        .findFirst();
    _lastEvent = last;
    if (last == null || last.type == ShiftEventType.clockOut) {
      _status = WorkStatus.idle;
      _currentShiftId = null;
    } else {
      _currentShiftId = last.shiftId;
      _status = last.type == ShiftEventType.pause
          ? WorkStatus.paused
          : WorkStatus.working;
    }
    notifyListeners();
  }

  Future<void> clockIn() async {
    if (_status != WorkStatus.idle) return;
    final now = DateTime.now();
    final shiftId = now.millisecondsSinceEpoch;
    await _isar.writeTxn(() async {
      await _isar.shiftEvents.put(ShiftEvent.create(
        timestamp: now,
        type: ShiftEventType.clockIn,
        shiftId: shiftId,
      ));
    });
    await _refresh();
  }

  Future<void> pause() async {
    if (_status != WorkStatus.working || _currentShiftId == null) return;
    await _isar.writeTxn(() async {
      await _isar.shiftEvents.put(ShiftEvent.create(
        timestamp: DateTime.now(),
        type: ShiftEventType.pause,
        shiftId: _currentShiftId!,
      ));
    });
    await _refresh();
  }

  Future<void> resume() async {
    if (_status != WorkStatus.paused || _currentShiftId == null) return;
    await _isar.writeTxn(() async {
      await _isar.shiftEvents.put(ShiftEvent.create(
        timestamp: DateTime.now(),
        type: ShiftEventType.resume,
        shiftId: _currentShiftId!,
      ));
    });
    await _refresh();
  }

  Future<void> clockOut() async {
    if (_status == WorkStatus.idle || _currentShiftId == null) return;
    await _isar.writeTxn(() async {
      await _isar.shiftEvents.put(ShiftEvent.create(
        timestamp: DateTime.now(),
        type: ShiftEventType.clockOut,
        shiftId: _currentShiftId!,
      ));
    });
    await _refresh();
  }

  Future<List<ShiftEvent>> eventsForShift(int shiftId) {
    return _isar.shiftEvents
        .filter()
        .shiftIdEqualTo(shiftId)
        .sortByTimestamp()
        .findAll();
  }

  Future<List<int>> allShiftIdsDesc() async {
    final all = await _isar.shiftEvents
        .where()
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
