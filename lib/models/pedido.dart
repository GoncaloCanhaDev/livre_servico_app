import 'local_row.dart';

class Pedido with SyncFields {
  Pedido();

  factory Pedido.fromJson(Map<String, dynamic> j) {
    final p = Pedido()
      ..createdByInitials = stringOrNull(j['createdByInitials'])
      ..createdAt = dateFromJsonOr(j['createdAt'], DateTime(2000))
      ..finishedAt = dateFromJson(j['finishedAt'])
      ..numero = stringOrNull(j['numero'])
      ..supplier = stringOrNull(j['supplier'])
      ..expectedDate = dateFromJson(j['expectedDate']);
    syncFieldsFromJson(p, j);
    return p;
  }

  String? createdByInitials;

  late DateTime createdAt;

  DateTime? finishedAt;

  /// Entered when the pedido is created (older ones got it at finalize time).
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

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'createdByInitials': createdByInitials,
    'createdAt': dateToJson(createdAt),
    'finishedAt': dateToJson(finishedAt),
    'numero': numero,
    'supplier': supplier,
    'expectedDate': dateToJson(expectedDate),
  };
}
