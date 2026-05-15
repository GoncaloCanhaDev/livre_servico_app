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
  String? kiwiAberturaBy;
  bool alteracoesPreco = false;
  String? alteracoesPrecoBy;
  int alteracoesPrecoCount = 0;
  bool verificacaoTemperaturas = false;
  String? verificacaoTemperaturasBy;
  bool preenchimentoQuadro = false;
  String? preenchimentoQuadroBy;
  bool verificacaoValidades = false;
  String? verificacaoValidadesBy;
  int verificacaoValidadesCount = 0;
  bool kiwiFecho = false;
  String? kiwiFechoBy;
  bool limpezaMaquinaVoltas = false;
  String? limpezaMaquinaVoltasBy;

  DateTime? lastUpdatedAt;
}
