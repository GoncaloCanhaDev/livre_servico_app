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
}
