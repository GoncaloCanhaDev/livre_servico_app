import 'local_row.dart';

class VisualList with SyncFields {
  VisualList();

  factory VisualList.fromJson(Map<String, dynamic> j) {
    final v = VisualList()
      ..createdByInitials = stringOrNull(j['createdByInitials'])
      ..createdByNames = stringsFromJson(j['createdByNames'])
      ..createdAt = dateFromJsonOr(j['createdAt'], DateTime(2000))
      ..serviceDay = dateFromJsonOr(j['serviceDay'], DateTime(2000))
      ..itensPicados = intFromJson(j['itensPicados'])
      ..quebraCents = intFromJson(j['quebraCents'])
      ..beneficioCents = intFromJson(j['beneficioCents'])
      ..backdated = boolFromJson(j['backdated']);
    syncFieldsFromJson(v, j);
    return v;
  }

  /// Legacy — kept for historical read fallback only, do not write.
  String? createdByInitials;
  List<String> createdByNames = [];

  late DateTime createdAt;

  late DateTime serviceDay;

  int itensPicados = 0;
  int quebraCents = 0;
  int beneficioCents = 0;

  /// True when this entry was added via the backdate flow instead of on its own day.
  bool backdated = false;

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'createdByInitials': createdByInitials,
    'createdByNames': createdByNames,
    'createdAt': dateToJson(createdAt),
    'serviceDay': dateToJson(serviceDay),
    'itensPicados': itensPicados,
    'quebraCents': quebraCents,
    'beneficioCents': beneficioCents,
    'backdated': backdated,
  };
}

int parseEurosToCents(String input) {
  if (input.trim().isEmpty) return 0;
  final normalized = input.trim().replaceAll(',', '.');
  final v = double.tryParse(normalized);
  if (v == null) return 0;
  return (v * 100).round();
}

String formatCents(int cents) {
  final v = cents / 100.0;
  return v.toStringAsFixed(2).replaceAll('.', ',');
}
