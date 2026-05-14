import 'package:isar_community/isar.dart';

part 'inventory.g.dart';

@collection
class Inventory {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;

  late String name;

  /// Value in cents (positive or negative).
  late int valueCents;

  late DateTime createdAt;
}
