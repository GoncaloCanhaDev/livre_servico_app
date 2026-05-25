import 'package:isar_community/isar.dart';

part 'inventory_line.g.dart';

/// A single counted line inside an [Inventory] session.
///
/// Linked to its parent via [parentUuid] (the parent Inventory's `syncUuid`)
/// so the relation survives sync round-trips by uuid rather than autoincrement
/// id.
@collection
class InventoryLine {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;
  String? createdByInitials;

  @Index()
  late String parentUuid;

  @Index()
  late String ean;

  /// Snapshot of the product name at scan time, or null if the EAN wasn't in
  /// the Products collection. Can be filled in later from history.
  String? productName;

  int count = 0;

  late DateTime createdAt;
  late DateTime updatedAt;
}
