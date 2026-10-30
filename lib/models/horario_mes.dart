import 'local_row.dart';

/// One month of the Livre Serviço horário ([mes] like "2026-10"), as read
/// from a horários file: one line of codes per name, day 1 first. Codes and
/// absence names live in `HorarioService`.
class HorarioMes with SyncFields {
  HorarioMes();

  factory HorarioMes.fromJson(Map<String, dynamic> j) {
    final m = HorarioMes()
      ..mes = stringFromJson(j['mes'])
      ..linhas = [for (final l in mapsFromJson(j['linhas'])) HorarioLinha.fromJson(l)];
    syncFieldsFromJson(m, j);
    return m;
  }

  late String mes;

  List<HorarioLinha> linhas = [];

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'mes': mes,
    'linhas': [for (final l in linhas) l.toJson()],
  };
}

class HorarioLinha {
  HorarioLinha();

  factory HorarioLinha.fromJson(Map<String, dynamic> j) => HorarioLinha()
    ..nome = stringFromJson(j['nome'])
    ..codigos = stringsFromJson(j['codigos']);

  String nome = '';
  List<String> codigos = [];

  Map<String, dynamic> toJson() => {'nome': nome, 'codigos': codigos};
}
