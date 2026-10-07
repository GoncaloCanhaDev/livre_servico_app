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
}
