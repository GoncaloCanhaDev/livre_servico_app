import 'package:isar_community/isar.dart';

part 'report_list.g.dart';

@collection
class ReportList {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;
  /// Legacy — kept for historical read fallback only, do not write.
  String? createdByInitials;
  List<String> createdByNames = [];

  @Index(unique: true, replace: true)
  late DateTime serviceDay;

  int diasSemVendas = 0;
  int regularizacoes = 0;
  int massiva = 0;
  int repetidos = 0;

  /// True when this row was finalized via the backdate flow instead of on its own day.
  bool backdated = false;

  DateTime? finalizedAt;

  bool get isFinalized => finalizedAt != null;
  int get total => diasSemVendas + regularizacoes + massiva + repetidos;
}
