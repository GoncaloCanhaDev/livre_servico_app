import 'local_row.dart';
import 'opening_list.dart';

class WeeklyTasks with SyncFields {
  WeeklyTasks();

  factory WeeklyTasks.fromJson(Map<String, dynamic> j) {
    final w = WeeklyTasks()
      ..serviceWeek = dateFromJsonOr(j['serviceWeek'], DateTime(2000))
      ..limpezaMaquinaVoltas = boolFromJson(j['limpezaMaquinaVoltas'])
      ..limpezaMaquinaVoltasBy = stringOrNull(j['limpezaMaquinaVoltasBy'])
      ..limpezaMaquinaVoltasByNames = stringsFromJson(
        j['limpezaMaquinaVoltasByNames'],
      )
      ..verificar1a = boolFromJson(j['verificar1a'])
      ..verificar1aBy = stringOrNull(j['verificar1aBy'])
      ..verificar1aByNames = stringsFromJson(j['verificar1aByNames'])
      ..verificar1aCount = intFromJson(j['verificar1aCount'])
      ..verificar4a = boolFromJson(j['verificar4a'])
      ..verificar4aBy = stringOrNull(j['verificar4aBy'])
      ..verificar4aByNames = stringsFromJson(j['verificar4aByNames'])
      ..verificar4aCount = intFromJson(j['verificar4aCount'])
      ..backdatedTaskKeys = stringsFromJson(j['backdatedTaskKeys'])
      ..lastUpdatedAt = dateFromJson(j['lastUpdatedAt']);
    syncFieldsFromJson(w, j);
    return w;
  }

  /// Monday (5am cutoff) of the service week this row covers.
  late DateTime serviceWeek;

  bool limpezaMaquinaVoltas = false;
  /// Legacy — kept for historical read fallback only, do not write.
  String? limpezaMaquinaVoltasBy;
  List<String> limpezaMaquinaVoltasByNames = [];

  /// Itens no Mural — mínimo 10, recomendado 20. Due Tuesday.
  bool verificar1a = false;
  /// Legacy — kept for historical read fallback only, do not write.
  String? verificar1aBy;
  List<String> verificar1aByNames = [];
  int verificar1aCount = 0;

  /// Itens por colocar preço. Due Tuesday.
  bool verificar4a = false;
  /// Legacy — kept for historical read fallback only, do not write.
  String? verificar4aBy;
  List<String> verificar4aByNames = [];
  int verificar4aCount = 0;

  /// Task keys (see the `timerKey` passed to `_completeTask`) that were marked done via the
  /// backdate flow rather than on this row's own service week.
  List<String> backdatedTaskKeys = [];

  DateTime? lastUpdatedAt;

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'serviceWeek': dateToJson(serviceWeek),
    'limpezaMaquinaVoltas': limpezaMaquinaVoltas,
    'limpezaMaquinaVoltasBy': limpezaMaquinaVoltasBy,
    'limpezaMaquinaVoltasByNames': limpezaMaquinaVoltasByNames,
    'verificar1a': verificar1a,
    'verificar1aBy': verificar1aBy,
    'verificar1aByNames': verificar1aByNames,
    'verificar1aCount': verificar1aCount,
    'verificar4a': verificar4a,
    'verificar4aBy': verificar4aBy,
    'verificar4aByNames': verificar4aByNames,
    'verificar4aCount': verificar4aCount,
    'backdatedTaskKeys': backdatedTaskKeys,
    'lastUpdatedAt': dateToJson(lastUpdatedAt),
  };
}

/// Monday (5am cutoff) of the service week containing [now].
DateTime currentServiceWeek([DateTime? now]) {
  final day = currentServiceDay(now);
  final monday = day.subtract(Duration(days: day.weekday - 1));
  return DateTime(monday.year, monday.month, monday.day, 5);
}
