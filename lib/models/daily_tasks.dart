import 'package:isar_community/isar.dart';

part 'daily_tasks.g.dart';

@collection
class DailyTasks {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: false)
  late DateTime serviceDay;

  bool kiwiAbertura = false;
  bool alteracoesPreco = false;
  int alteracoesPrecoCount = 0;
  bool preenchimentoQuadro = false;
  bool verificacaoValidades = false;
  int verificacaoValidadesCount = 0;
  bool kiwiFecho = false;
  bool limpezaMaquinaVoltas = false;
}
