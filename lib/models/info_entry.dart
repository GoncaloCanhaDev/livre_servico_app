import 'package:isar_community/isar.dart';

part 'info_entry.g.dart';

@collection
class InfoEntry {
  Id id = Isar.autoIncrement;

  @Index()
  late String bucket;

  late String title;
  late String description;
  String? contact;
  late DateTime createdAt;
}
