import 'package:isar_community/isar.dart';

part 'pedido_line.g.dart';

@collection
class PedidoLine {
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

  String? productName;

  int caixas = 0;

  late DateTime createdAt;
  late DateTime updatedAt;
}
