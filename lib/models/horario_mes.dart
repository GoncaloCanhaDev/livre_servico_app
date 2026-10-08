import 'package:isar_community/isar.dart';

part 'horario_mes.g.dart';

/// One month of the Livre Serviço horário ([mes] like "2026-10"), as read
/// from a horários file: one line of codes per name, day 1 first. Codes and
/// absence names live in `HorarioService`.
@collection
class HorarioMes {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String mes;

  List<HorarioLinha> linhas = [];
}

@embedded
class HorarioLinha {
  String nome = '';
  List<String> codigos = [];
}
