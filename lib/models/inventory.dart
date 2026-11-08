import 'local_row.dart';

class Inventory with SyncFields {
  Inventory();

  factory Inventory.fromJson(Map<String, dynamic> j) {
    final i = Inventory()
      ..createdByInitials = stringOrNull(j['createdByInitials'])
      ..createdByNames = stringsFromJson(j['createdByNames'])
      ..name = stringFromJson(j['name'])
      ..valueCents = intFromJson(j['valueCents'])
      ..createdAt = dateFromJsonOr(j['createdAt'], DateTime(2000))
      ..code = stringOrNull(j['code'])
      ..startedAt = dateFromJson(j['startedAt'])
      ..finishedAt = dateFromJson(j['finishedAt'])
      ..finalValueCents = intOrNull(j['finalValueCents'])
      ..plannedAt = dateFromJson(j['plannedAt'])
      ..plannedBy = stringOrNull(j['plannedBy'])
      ..dueDate = dateFromJson(j['dueDate']);
    syncFieldsFromJson(i, j);
    return i;
  }

  /// Legacy — kept for historical read fallback only, do not write.
  String? createdByInitials;
  List<String> createdByNames = [];

  late String name;

  /// Value in cents (positive or negative).
  ///
  /// Legacy field: rows created before the session-based redesign store the
  /// total euro value here. New rows leave it at 0 until [finalValueCents] is
  /// set on finalize and mirrored here.
  late int valueCents;

  late DateTime createdAt;

  // --- Session fields (added in v0.3) ------------------------------------

  String? code;

  DateTime? startedAt;

  DateTime? finishedAt;

  int? finalValueCents;

  // --- Planned ("Por fazer", added in 0.87.0) ---------------------------

  /// When it was planned, by level 3 and up; null for one recorded as done
  /// straight away. A planned one is [isToDo] until marked done.
  DateTime? plannedAt;

  /// Who planned it (the planner's person), if known.
  String? plannedBy;

  /// The day it should be done by, if one was given.
  DateTime? dueDate;

  bool get isLegacy => startedAt == null && plannedAt == null;
  bool get isFinalized => finishedAt != null;

  /// Planned and not done yet: listed in "Por fazer", not in the history.
  bool get isToDo => plannedAt != null && finishedAt == null;

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'createdByInitials': createdByInitials,
    'createdByNames': createdByNames,
    'name': name,
    'valueCents': valueCents,
    'createdAt': dateToJson(createdAt),
    'code': code,
    'startedAt': dateToJson(startedAt),
    'finishedAt': dateToJson(finishedAt),
    'finalValueCents': finalValueCents,
    'plannedAt': dateToJson(plannedAt),
    'plannedBy': plannedBy,
    'dueDate': dateToJson(dueDate),
  };
}
