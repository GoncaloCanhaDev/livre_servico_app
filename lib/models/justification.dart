import 'package:isar_community/isar.dart';

part 'justification.g.dart';

/// Type tags for justifications. Stored as plain strings to keep migration easy.
class JustificationKind {
  static const opening = 'opening';
  static const report = 'report';
  static const auto = 'auto';
  static const visual = 'visual';
  static const tasks = 'tasks';
}

@collection
class Justification {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;
  String? createdByInitials;

  @Index(composite: [CompositeIndex('kind')])
  late DateTime serviceDay;

  late String kind;

  late String reason;
}
