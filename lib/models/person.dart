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

  String? role;
  DateTime? dateOfBirth;
  DateTime? hireDate;
  String? photoPath;
  String? phoneNumber;

  /// Legacy single-manager field, superseded by [managerUuids]. Kept only
  /// so [PersonService.migrateManagerUuids] can read pre-upgrade data on
  /// existing on-device databases — nothing else reads or writes it.
  String? managerUuid;

  /// syncUuids of this person's managers (zero, one, or many — no
  /// primary/secondary ordering). Empty means they're at the top of the
  /// hierarchy. Self-referencing rather than Isar Links, same rationale as
  /// the old [managerUuid]: a manager whose row gets soft-deleted just
  /// leaves a dangling uuid here, which readers treat as "not a manager
  /// anymore" rather than as an error.
  List<String> managerUuids = [];
}
