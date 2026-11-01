import 'local_row.dart';
import 'not_done.dart';

/// Stored by index, so never reorder it.
enum CustomTaskFrequency { daily, weekly, oneOff }

/// Stored by index, so never reorder it.
enum CustomTaskInputType { simple, count }

class CustomTask with SyncFields {
  CustomTask();

  factory CustomTask.fromJson(Map<String, dynamic> j) {
    final t = CustomTask()
      ..title = stringFromJson(j['title'])
      ..frequency =
          enumFromJson(CustomTaskFrequency.values, j['frequency']) ??
          CustomTaskFrequency.daily
      ..inputType =
          enumFromJson(CustomTaskInputType.values, j['inputType']) ??
          CustomTaskInputType.simple
      ..createdAt = dateFromJsonOr(j['createdAt'], DateTime(2000));
    syncFieldsFromJson(t, j);
    return t;
  }

  late String title;

  CustomTaskFrequency frequency = CustomTaskFrequency.daily;

  CustomTaskInputType inputType = CustomTaskInputType.simple;

  late DateTime createdAt;

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'title': title,
    'frequency': frequency.index,
    'inputType': inputType.index,
    'createdAt': dateToJson(createdAt),
  };
}

class CustomTaskEntry with SyncFields {
  CustomTaskEntry();

  factory CustomTaskEntry.fromJson(Map<String, dynamic> j) {
    final e = CustomTaskEntry()
      ..taskUuid = stringFromJson(j['taskUuid'])
      ..periodKey = dateFromJsonOr(j['periodKey'], oneOffPeriodKey)
      ..done = boolFromJson(j['done'])
      ..doneBy = stringOrNull(j['doneBy'])
      ..doneByNames = stringsFromJson(j['doneByNames'])
      ..count = intOrNull(j['count'])
      ..doneAt = dateFromJson(j['doneAt'])
      ..backdated = boolFromJson(j['backdated'])
      ..notDone = notDoneFromJson(j['notDone']);
    syncFieldsFromJson(e, j);
    return e;
  }

  /// The [CustomTask.syncUuid] this entry records a completion for.
  late String taskUuid;

  /// The service day (daily tasks), the service week's Monday (weekly
  /// tasks), or [oneOffPeriodKey] (one-off tasks — they never reset, so
  /// they only ever have a single entry, always keyed to that constant).
  late DateTime periodKey;

  bool done = false;

  /// Legacy — kept for historical read fallback only, do not write.
  String? doneBy;
  List<String> doneByNames = [];

  /// Only meaningful when the task's [CustomTask.inputType] is `count`.
  int? count;
  DateTime? doneAt;

  /// True when this entry was completed via the backdate flow rather than
  /// on its own period.
  bool backdated = false;

  /// Set when the task was marked "Não feita" for this period ([done] is
  /// then false).
  NotDone? notDone;

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'taskUuid': taskUuid,
    'periodKey': dateToJson(periodKey),
    'done': done,
    'doneBy': doneBy,
    'doneByNames': doneByNames,
    'count': count,
    'doneAt': dateToJson(doneAt),
    'backdated': backdated,
    'notDone': notDone?.toJson(),
  };
}

/// Fixed period key for one-off custom tasks — see [CustomTaskEntry.periodKey].
final DateTime oneOffPeriodKey = DateTime.fromMillisecondsSinceEpoch(0);
