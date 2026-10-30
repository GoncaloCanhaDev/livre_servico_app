import 'local_row.dart';

class Person with SyncFields {
  Person();

  factory Person.fromJson(Map<String, dynamic> j) {
    // Before 0.67.0 a whole date of birth: only its day and month are kept.
    final born = dateFromJson(j['dateOfBirth']);
    final p = Person()
      ..fullName = stringFromJson(j['fullName'])
      ..collaboratorNumber = stringFromJson(j['collaboratorNumber'])
      ..createdAt = dateFromJsonOr(j['createdAt'], DateTime(2000))
      ..birthDay = intOrNull(j['birthDay']) ?? born?.day
      ..birthMonth = intOrNull(j['birthMonth']) ?? born?.month
      ..hireDate = dateFromJson(j['hireDate'])
      ..photoPath = stringOrNull(j['photoPath'])
      ..team = stringOrNull(j['team'])
      ..chefe = stringOrNull(j['chefe'])
      ..turno = stringOrNull(j['turno'])
      ..permanencia = boolFromJson(j['permanencia'])
      ..partTime = boolFromJson(j['partTime'])
      ..supervisor = boolFromJson(j['supervisor'])
      ..segundaLinha = boolFromJson(j['segundaLinha'])
      ..folgas = intsFromJson(j['folgas'])
      ..weeklyHours = intOrNull(j['weeklyHours'])
      ..shiftStart = intOrNull(j['shiftStart'])
      ..shiftEnd = intOrNull(j['shiftEnd'])
      ..ausencias = [
        for (final a in mapsFromJson(j['ausencias'])) Ausencia.fromJson(a),
      ]
      ..storeStartDate = dateFromJson(j['storeStartDate'])
      ..notes = stringsFromJson(j['notes'])
      ..genero = enumFromJson(Genero.values, j['genero'])
      ..profileUpdateRequestedAt = dateFromJson(j['profileUpdateRequestedAt'])
      ..profileUpdateRequestedBy = stringOrNull(j['profileUpdateRequestedBy']);
    syncFieldsFromJson(p, j);
    return p;
  }

  late String fullName;
  String collaboratorNumber = '';
  late DateTime createdAt;

  /// The birthday's day (1–31) and month (1–12); no year is kept.
  int? birthDay;
  int? birthMonth;

  DateTime? hireDate;
  String? photoPath;

  /// [Team.id] of the person's team (see `teams.dart`); null = Sem equipa.
  String? team;

  /// [ChefeSlot.name] if the person is a chefe of their team, else null.
  /// Only meaningful when it is one of the team's slots — read it through
  /// `chefeSlotOf`.
  String? chefe;

  /// [Turno.name] for Livre Serviço members; ignored for other teams. A
  /// Livre Serviço chefe's turno comes from their slot — read it through
  /// `turnoOf`.
  String? turno;

  /// Tagged "Permanência": can stand in for management when no chefia is
  /// present. Independent of team and chefe role.
  bool permanencia = false;

  /// Part-time ("Tempo parcial") rather than the default full time
  /// ("Tempo inteiro").
  bool partTime = false;

  /// Supervisor in a team that has them (only Frente de Loja): between chefe
  /// and member, any number per team. Read it through `isSupervisor`.
  bool supervisor = false;

  /// Segunda Linha (second in line after the chefe) in a team that has it.
  /// Read it through `isSegundaLinha`.
  bool segundaLinha = false;

  /// Fixed weekly days off, as [DateTime.weekday] values (1 = Monday).
  List<int> folgas = [];

  /// Contracted hours per week, if recorded.
  int? weeklyHours;

  /// Usual working hours, in minutes after midnight. The end can be earlier
  /// than the start for a shift that crosses midnight.
  int? shiftStart;
  int? shiftEnd;

  /// Férias, baixas and other absences, past and future.
  List<Ausencia> ausencias = [];

  /// When the person started at this store (the company start is
  /// [hireDate]).
  DateTime? storeStartDate;

  /// Short free-text notes, one per entry.
  List<String> notes = [];

  /// Only used to agree words with the person ("Novo" / "Nova"); null when
  /// not set.
  Genero? genero;

  /// When a chefe or Gerência asked this person to update their profile;
  /// null when nobody did or once they saved it.
  DateTime? profileUpdateRequestedAt;

  /// Who asked ([profileUpdateRequestedAt]), by name.
  String? profileUpdateRequestedBy;

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'fullName': fullName,
    'collaboratorNumber': collaboratorNumber,
    'createdAt': dateToJson(createdAt),
    'birthDay': birthDay,
    'birthMonth': birthMonth,
    'hireDate': dateToJson(hireDate),
    'photoPath': photoPath,
    'team': team,
    'chefe': chefe,
    'turno': turno,
    'permanencia': permanencia,
    'partTime': partTime,
    'supervisor': supervisor,
    'segundaLinha': segundaLinha,
    'folgas': folgas,
    'weeklyHours': weeklyHours,
    'shiftStart': shiftStart,
    'shiftEnd': shiftEnd,
    'ausencias': [for (final a in ausencias) a.toJson()],
    'storeStartDate': dateToJson(storeStartDate),
    'notes': notes,
    'genero': genero?.name,
    'profileUpdateRequestedAt': dateToJson(profileUpdateRequestedAt),
    'profileUpdateRequestedBy': profileUpdateRequestedBy,
  };
}

enum Genero {
  masculino('Masculino'),
  feminino('Feminino');

  const Genero(this.label);
  final String label;
}

enum AusenciaTipo {
  ferias('Férias'),
  baixa('Baixa'),
  formacao('Formação'),
  outra('Ausência');

  const AusenciaTipo(this.label);
  final String label;
}

/// A period away from work, from [start] to [end] (both whole days,
/// inclusive). Baixas are recorded without a reason.
class Ausencia {
  Ausencia();

  factory Ausencia.fromJson(Map<String, dynamic> j) => Ausencia()
    ..tipo = enumFromJson(AusenciaTipo.values, j['tipo']) ?? AusenciaTipo.outra
    ..start = dateFromJsonOr(j['start'], DateTime(2000))
    ..end = dateFromJsonOr(j['end'], DateTime(2000));

  Map<String, dynamic> toJson() => {
    'tipo': tipo.name,
    'start': dateToJson(start),
    'end': dateToJson(end),
  };

  AusenciaTipo tipo = AusenciaTipo.ferias;
  DateTime start = DateTime(2000);
  DateTime end = DateTime(2000);
}
