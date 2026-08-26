import 'package:isar_community/isar.dart';

part 'custom_task.g.dart';

enum CustomTaskFrequency { daily, weekly, oneOff }

enum CustomTaskInputType { simple, count }

@collection
class CustomTask {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;

  late String title;

  @enumerated
  CustomTaskFrequency frequency = CustomTaskFrequency.daily;

  @enumerated
  CustomTaskInputType inputType = CustomTaskInputType.simple;

  late DateTime createdAt;
}

@collection
class CustomTaskEntry {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;

  /// The [CustomTask.syncUuid] this entry records a completion for.
  @Index()
  late String taskUuid;

  /// The service day (daily tasks), the service week's Monday (weekly
  /// tasks), or [oneOffPeriodKey] (one-off tasks — they never reset, so
  /// they only ever have a single entry, always keyed to that constant).
  @Index()
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
}

/// Fixed period key for one-off custom tasks — see [CustomTaskEntry.periodKey].
final DateTime oneOffPeriodKey = DateTime.fromMillisecondsSinceEpoch(0);
