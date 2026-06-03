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

  bool get isFinalized => finishedAt != null;
}
