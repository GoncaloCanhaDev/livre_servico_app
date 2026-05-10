import 'package:isar_community/isar.dart';

part 'report_list.g.dart';

@collection
class ReportList {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late DateTime serviceDay;

  int diasSemVendas = 0;
  int regularizacoes = 0;
  int massiva = 0;
  int repetidos = 0;

  DateTime? finalizedAt;

  bool get isFinalized => finalizedAt != null;
  int get total => diasSemVendas + regularizacoes + massiva + repetidos;
}
