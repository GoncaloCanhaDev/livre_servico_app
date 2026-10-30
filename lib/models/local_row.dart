/// What every model saved in `LocalDb` has: a local [id] (0 until first
/// saved) and the sync fields (see `SyncMeta`), and how to write itself as
/// JSON. Each model also has a `fromJson` factory reading that JSON back.
///
/// The JSON is the format Isar's `exportJson` wrote before the move to
/// Drift, so older backup files still import: dates as microseconds since
/// the epoch, enums by index or by name as each model says, embedded
/// objects nested, null fields written as null. The readers below also
/// accept ISO dates and either enum form.
abstract interface class SyncedRow {
  int get id;
  set id(int value);

  String get syncUuid;
  set syncUuid(String value);

  DateTime get syncUpdatedAt;
  set syncUpdatedAt(DateTime value);

  DateTime? get syncDeletedAt;
  set syncDeletedAt(DateTime? value);

  bool get synced;
  set synced(bool value);

  Map<String, dynamic> toJson();
}

/// The fields of [SyncedRow], for a model to mix in.
mixin SyncFields implements SyncedRow {
  @override
  int id = 0;

  @override
  String syncUuid = '';

  @override
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  DateTime? syncDeletedAt;

  @override
  bool synced = true;
}

/// The sync fields of [row], for the start of a model's `toJson`.
Map<String, dynamic> syncFieldsToJson(SyncedRow row) => {
  'id': row.id,
  'syncUuid': row.syncUuid,
  'syncUpdatedAt': dateToJson(row.syncUpdatedAt),
  'syncDeletedAt': dateToJson(row.syncDeletedAt),
  'synced': row.synced,
};

/// Reads the sync fields written by [syncFieldsToJson] into [row].
void syncFieldsFromJson(SyncedRow row, Map<String, dynamic> j) {
  row.id = intFromJson(j['id']);
  row.syncUuid = stringOrNull(j['syncUuid']) ?? '';
  row.syncUpdatedAt = dateFromJson(j['syncUpdatedAt']) ?? _epoch;
  row.syncDeletedAt = dateFromJson(j['syncDeletedAt']);
  row.synced = boolFromJson(j['synced'], fallback: true);
}

final _epoch = DateTime.fromMillisecondsSinceEpoch(0);

/// Below this, a number is Isar's null marker for a 64-bit value (the
/// smallest one), not a date. Not the exact marker, which JavaScript (the
/// web build) can't represent.
const _isarNullBelow = -4000000000000000000;

int? dateToJson(DateTime? d) => d?.toUtc().microsecondsSinceEpoch;

/// A local [DateTime] from microseconds since the epoch or an ISO string;
/// null for anything else.
DateTime? dateFromJson(Object? v) {
  if (v is num) {
    final n = v.toInt();
    if (n < _isarNullBelow) return null;
    return DateTime.fromMicrosecondsSinceEpoch(n);
  }
  if (v is String) return DateTime.tryParse(v)?.toLocal();
  return null;
}

/// [dateFromJson], or [fallback] when [v] holds no date.
DateTime dateFromJsonOr(Object? v, DateTime fallback) =>
    dateFromJson(v) ?? fallback;

String? stringOrNull(Object? v) => v is String ? v : null;

String stringFromJson(Object? v) => v is String ? v : '';

int intFromJson(Object? v, {int fallback = 0}) =>
    v is num ? v.toInt() : fallback;

int? intOrNull(Object? v) => v is num ? v.toInt() : null;

bool boolFromJson(Object? v, {bool fallback = false}) => switch (v) {
  bool b => b,
  num n => n != 0,
  _ => fallback,
};

List<String> stringsFromJson(Object? v) => [
  if (v is List)
    for (final e in v)
      if (e is String) e,
];

List<int> intsFromJson(Object? v) => [
  if (v is List)
    for (final e in v)
      if (e is num) e.toInt(),
];

/// The maps in the list [v], for embedded objects.
List<Map<String, dynamic>> mapsFromJson(Object? v) => [
  if (v is List)
    for (final e in v)
      if (e is Map) Map<String, dynamic>.from(e),
];

/// The value of [values] that [v] names, by name or by index; null when it
/// names none.
T? enumFromJson<T extends Enum>(List<T> values, Object? v) {
  if (v is String) {
    for (final e in values) {
      if (e.name == v) return e;
    }
    return null;
  }
  if (v is num) {
    final i = v.toInt();
    return i >= 0 && i < values.length ? values[i] : null;
  }
  return null;
}
