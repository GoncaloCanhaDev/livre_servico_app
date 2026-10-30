import 'local_row.dart';

class ReportList with SyncFields {
  ReportList();

  factory ReportList.fromJson(Map<String, dynamic> j) {
    final r = ReportList()
      ..createdByInitials = stringOrNull(j['createdByInitials'])
      ..createdByNames = stringsFromJson(j['createdByNames'])
      ..serviceDay = dateFromJsonOr(j['serviceDay'], DateTime(2000))
      ..diasSemVendas = intFromJson(j['diasSemVendas'])
      ..regularizacoes = intFromJson(j['regularizacoes'])
      ..massiva = intFromJson(j['massiva'])
      ..repetidos = intFromJson(j['repetidos'])
      ..backdated = boolFromJson(j['backdated'])
      ..finalizedAt = dateFromJson(j['finalizedAt']);
    syncFieldsFromJson(r, j);
    return r;
  }

  /// Legacy — kept for historical read fallback only, do not write.
  String? createdByInitials;
  List<String> createdByNames = [];

  late DateTime serviceDay;

  int diasSemVendas = 0;
  int regularizacoes = 0;
  int massiva = 0;
  int repetidos = 0;

  /// True when this row was finalized via the backdate flow instead of on its own day.
  bool backdated = false;

  DateTime? finalizedAt;

  bool get isFinalized => finalizedAt != null;
  int get total => diasSemVendas + regularizacoes + massiva + repetidos;

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'createdByInitials': createdByInitials,
    'createdByNames': createdByNames,
    'serviceDay': dateToJson(serviceDay),
    'diasSemVendas': diasSemVendas,
    'regularizacoes': regularizacoes,
    'massiva': massiva,
    'repetidos': repetidos,
    'backdated': backdated,
    'finalizedAt': dateToJson(finalizedAt),
  };
}
