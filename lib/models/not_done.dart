import 'local_row.dart';

/// A task marked "Não feita": who marked it, why, and when. Kept on the
/// Diárias and Semanais rows by task key (the keys of `backdatedTaskKeys`)
/// and on a `CustomTaskEntry`. A task has either this or its done flag,
/// never both.
class NotDone {
  NotDone({required this.byNames, required this.reason, this.at});

  factory NotDone.fromJson(Map<String, dynamic> j) => NotDone(
    byNames: stringsFromJson(j['byNames']),
    reason: stringFromJson(j['reason']),
    at: dateFromJson(j['at']),
  );

  List<String> byNames;
  String reason;
  DateTime? at;

  Map<String, dynamic> toJson() => {
    'byNames': byNames,
    'reason': reason,
    'at': dateToJson(at),
  };
}

/// The `notDone` map of a Diárias or Semanais row, from its JSON.
Map<String, NotDone> notDoneMapFromJson(Object? v) => {
  if (v is Map)
    for (final e in v.entries)
      if (e.key is String && e.value is Map)
        e.key as String: NotDone.fromJson(
          Map<String, dynamic>.from(e.value as Map),
        ),
};

Map<String, dynamic> notDoneMapToJson(Map<String, NotDone> m) => {
  for (final e in m.entries) e.key: e.value.toJson(),
};

/// A single [NotDone] from JSON, or null.
NotDone? notDoneFromJson(Object? v) =>
    v is Map ? NotDone.fromJson(Map<String, dynamic>.from(v)) : null;
