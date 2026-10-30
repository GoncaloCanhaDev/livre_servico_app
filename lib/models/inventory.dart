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
      ..finalValueCents = intOrNull(j['finalValueCents']);
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

  bool get isLegacy => startedAt == null;
  bool get isFinalized => finishedAt != null;

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
  };
}
