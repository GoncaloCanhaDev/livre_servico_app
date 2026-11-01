import 'local_row.dart';
import 'not_done.dart';

class DailyTasks with SyncFields {
  DailyTasks();

  factory DailyTasks.fromJson(Map<String, dynamic> j) {
    final t = DailyTasks()
      ..serviceDay = dateFromJsonOr(j['serviceDay'], DateTime(2000))
      ..kiwiAbertura = boolFromJson(j['kiwiAbertura'])
      ..kiwiAberturaBy = stringOrNull(j['kiwiAberturaBy'])
      ..kiwiAberturaByNames = stringsFromJson(j['kiwiAberturaByNames'])
      ..alteracoesPreco = boolFromJson(j['alteracoesPreco'])
      ..alteracoesPrecoBy = stringOrNull(j['alteracoesPrecoBy'])
      ..alteracoesPrecoByNames = stringsFromJson(j['alteracoesPrecoByNames'])
      ..alteracoesPrecoCount = intFromJson(j['alteracoesPrecoCount'])
      ..verificacaoTemperaturas = boolFromJson(j['verificacaoTemperaturas'])
      ..verificacaoTemperaturasBy = stringOrNull(j['verificacaoTemperaturasBy'])
      ..verificacaoTemperaturasByNames = stringsFromJson(
        j['verificacaoTemperaturasByNames'],
      )
      ..preenchimentoQuadro = boolFromJson(j['preenchimentoQuadro'])
      ..preenchimentoQuadroBy = stringOrNull(j['preenchimentoQuadroBy'])
      ..preenchimentoQuadroByNames = stringsFromJson(
        j['preenchimentoQuadroByNames'],
      )
      ..verificacaoValidades = boolFromJson(j['verificacaoValidades'])
      ..verificacaoValidadesBy = stringOrNull(j['verificacaoValidadesBy'])
      ..verificacaoValidadesByNames = stringsFromJson(
        j['verificacaoValidadesByNames'],
      )
      ..verificacaoValidadesCount = intFromJson(j['verificacaoValidadesCount'])
      ..validadesNoite = boolFromJson(j['validadesNoite'])
      ..validadesNoiteByNames = stringsFromJson(j['validadesNoiteByNames'])
      ..validadesNoiteCount = intFromJson(j['validadesNoiteCount'])
      ..kiwiFecho = boolFromJson(j['kiwiFecho'])
      ..kiwiFechoBy = stringOrNull(j['kiwiFechoBy'])
      ..kiwiFechoByNames = stringsFromJson(j['kiwiFechoByNames'])
      ..backdatedTaskKeys = stringsFromJson(j['backdatedTaskKeys'])
      ..notDone = notDoneMapFromJson(j['notDone'])
      ..lastUpdatedAt = dateFromJson(j['lastUpdatedAt']);
    syncFieldsFromJson(t, j);
    return t;
  }

  late DateTime serviceDay;

  bool kiwiAbertura = false;

  /// Legacy — kept for historical read fallback only, do not write.
  String? kiwiAberturaBy;
  List<String> kiwiAberturaByNames = [];
  bool alteracoesPreco = false;

  /// Legacy — kept for historical read fallback only, do not write.
  String? alteracoesPrecoBy;
  List<String> alteracoesPrecoByNames = [];
  int alteracoesPrecoCount = 0;
  bool verificacaoTemperaturas = false;

  /// Legacy — kept for historical read fallback only, do not write.
  String? verificacaoTemperaturasBy;
  List<String> verificacaoTemperaturasByNames = [];
  bool preenchimentoQuadro = false;

  /// Legacy — kept for historical read fallback only, do not write.
  String? preenchimentoQuadroBy;
  List<String> preenchimentoQuadroByNames = [];

  /// Validades · Manhã (05–14, see `ValidadesTurno`); before the split, the
  /// single Verificação de Validades.
  bool verificacaoValidades = false;

  /// Legacy — kept for historical read fallback only, do not write.
  String? verificacaoValidadesBy;
  List<String> verificacaoValidadesByNames = [];
  int verificacaoValidadesCount = 0;

  /// Validades · Noite (19–05).
  bool validadesNoite = false;
  List<String> validadesNoiteByNames = [];
  int validadesNoiteCount = 0;
  bool kiwiFecho = false;

  /// Legacy — kept for historical read fallback only, do not write.
  String? kiwiFechoBy;
  List<String> kiwiFechoByNames = [];

  /// Task keys (see the `timerKey` passed to `_completeTask`) that were marked done via the
  /// backdate flow rather than on this row's own service day.
  List<String> backdatedTaskKeys = [];

  /// Tasks marked "Não feita", by the same keys as [backdatedTaskKeys].
  Map<String, NotDone> notDone = {};

  DateTime? lastUpdatedAt;

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'serviceDay': dateToJson(serviceDay),
    'kiwiAbertura': kiwiAbertura,
    'kiwiAberturaBy': kiwiAberturaBy,
    'kiwiAberturaByNames': kiwiAberturaByNames,
    'alteracoesPreco': alteracoesPreco,
    'alteracoesPrecoBy': alteracoesPrecoBy,
    'alteracoesPrecoByNames': alteracoesPrecoByNames,
    'alteracoesPrecoCount': alteracoesPrecoCount,
    'verificacaoTemperaturas': verificacaoTemperaturas,
    'verificacaoTemperaturasBy': verificacaoTemperaturasBy,
    'verificacaoTemperaturasByNames': verificacaoTemperaturasByNames,
    'preenchimentoQuadro': preenchimentoQuadro,
    'preenchimentoQuadroBy': preenchimentoQuadroBy,
    'preenchimentoQuadroByNames': preenchimentoQuadroByNames,
    'verificacaoValidades': verificacaoValidades,
    'verificacaoValidadesBy': verificacaoValidadesBy,
    'verificacaoValidadesByNames': verificacaoValidadesByNames,
    'verificacaoValidadesCount': verificacaoValidadesCount,
    'validadesNoite': validadesNoite,
    'validadesNoiteByNames': validadesNoiteByNames,
    'validadesNoiteCount': validadesNoiteCount,
    'kiwiFecho': kiwiFecho,
    'kiwiFechoBy': kiwiFechoBy,
    'kiwiFechoByNames': kiwiFechoByNames,
    'backdatedTaskKeys': backdatedTaskKeys,
    'notDone': notDoneMapToJson(notDone),
    'lastUpdatedAt': dateToJson(lastUpdatedAt),
  };
}
