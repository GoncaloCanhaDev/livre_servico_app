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
  /// Legacy — kept for historical read fallback only, do not write.
  String? createdByInitials;
  List<String> createdByNames = [];

  @Index()
  late DateTime createdAt;

  int congelados = 0;
  int opls = 0;
  int naoPereciveis = 0;

  /// True when this entry was added via the backdate flow instead of on its own day.
  bool backdated = false;

  int get total => congelados + opls + naoPereciveis;
}
