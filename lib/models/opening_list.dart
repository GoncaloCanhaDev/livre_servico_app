import 'package:isar_community/isar.dart';

part 'opening_list.g.dart';

@collection
class OpeningList {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;
  String? createdByInitials;

  @Index(unique: true, replace: true)
  late DateTime serviceDay;

  int congelados = 0;
  int opls = 0;
  int naoPereciveis = 0;

  DateTime? finalizedAt;

  bool get isFinalized => finalizedAt != null;
  int get total => congelados + opls + naoPereciveis;
}

DateTime currentServiceDay([DateTime? now]) {
  final n = now ?? DateTime.now();
  if (n.hour < 5) {
    final y = n.subtract(const Duration(days: 1));
    return DateTime(y.year, y.month, y.day, 5);
  }
  return DateTime(n.year, n.month, n.day, 5);
}
