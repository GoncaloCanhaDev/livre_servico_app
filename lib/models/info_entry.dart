import 'package:isar_community/isar.dart';

part 'info_entry.g.dart';

@collection
class InfoEntry {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;
  String? createdByInitials;

  @Index()
  late String bucket;

  late String title;
  late String description;
  String? contact;
  late DateTime createdAt;
}
