import 'package:isar_community/isar.dart';

part 'pedido.g.dart';

@collection
class Pedido {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;
  String? createdByInitials;

  late DateTime createdAt;

  DateTime? finishedAt;

  /// Set at finalize time.
  String? numero;

  /// Optional — set only if the user chooses to fill it in.
  String? supplier;

  /// Optional expected-arrival date. Left null unless the user sets it.
  DateTime? expectedDate;

  bool get isFinalized => finishedAt != null;

  bool get isOverdue {
    if (isFinalized || expectedDate == null) return false;
    final today = DateTime.now();
    final endOfExpectedDay = DateTime(
      expectedDate!.year,
      expectedDate!.month,
      expectedDate!.day,
    ).add(const Duration(days: 1));
    return today.isAfter(endOfExpectedDay);
  }
}
