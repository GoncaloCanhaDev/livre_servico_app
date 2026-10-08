import 'package:isar_community/isar.dart';

part 'person.g.dart';

@collection
class Person {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;

  late String fullName;
  String collaboratorNumber = '';
  late DateTime createdAt;

  DateTime? dateOfBirth;
  DateTime? hireDate;
  String? photoPath;
  String? phoneNumber;

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
  @Enumerated(EnumType.name)
  Genero? genero;
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
@embedded
class Ausencia {
  @Enumerated(EnumType.name)
  AusenciaTipo tipo = AusenciaTipo.ferias;
  DateTime start = DateTime(2000);
  DateTime end = DateTime(2000);
}
