import 'package:isar_community/isar.dart';

part 'auto_list.g.dart';

@collection
class AutoList {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;

  @Index()
  late DateTime createdAt;

  int congelados = 0;
  int opls = 0;
  int naoPereciveis = 0;

  int get total => congelados + opls + naoPereciveis;
}
