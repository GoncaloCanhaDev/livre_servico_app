import 'package:isar_community/isar.dart';

part 'daily_tasks.g.dart';

@collection
class DailyTasks {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;

  @Index(unique: true, replace: true)
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

  DateTime? lastUpdatedAt;
}
