import 'package:isar_community/isar.dart';

part 'person.g.dart';

/// One points adjustment, kept for accountability — so a past total can be
/// explained later, not just shown as a running number.
@embedded
class PointEvent {
  DateTime at = DateTime.now();
  int delta = 0;

  /// Optional — the person adjusting points isn't required to give a reason.
  String? reason;
}

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

  /// syncUuid of this person's manager, or null if they're at the top of
  /// the hierarchy. Self-referencing rather than an Isar Link so it can be
  /// resolved the same way every other cross-model reference in this app
  /// is (see CLAUDE.md's SyncMeta/soft-delete notes) — a manager whose row
  /// gets soft-deleted simply leaves this dangling, which readers treat as
  /// "no manager" rather than as an error.
  String? managerUuid;

  int points = 0;
  List<PointEvent> pointHistory = [];
}
