import 'package:isar_community/isar.dart';

import 'opening_list.dart';

part 'weekly_tasks.g.dart';

@collection
class WeeklyTasks {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;

  /// Monday (5am cutoff) of the service week this row covers.
  @Index(unique: true, replace: true)
  late DateTime serviceWeek;

  bool limpezaMaquinaVoltas = false;
  /// Legacy — kept for historical read fallback only, do not write.
  String? limpezaMaquinaVoltasBy;
  List<String> limpezaMaquinaVoltasByNames = [];

  /// Itens no Mural — mínimo 10, recomendado 20. Due Monday.
  bool verificar1a = false;
  /// Legacy — kept for historical read fallback only, do not write.
  String? verificar1aBy;
  List<String> verificar1aByNames = [];
  int verificar1aCount = 0;

  /// Itens por colocar preço. Due Monday.
  bool verificar4a = false;
  /// Legacy — kept for historical read fallback only, do not write.
  String? verificar4aBy;
  List<String> verificar4aByNames = [];
  int verificar4aCount = 0;

  /// Task keys (see the `timerKey` passed to `_completeTask`) that were marked done via the
  /// backdate flow rather than on this row's own service week.
  List<String> backdatedTaskKeys = [];

  DateTime? lastUpdatedAt;
}

/// Monday (5am cutoff) of the service week containing [now].
DateTime currentServiceWeek([DateTime? now]) {
  final day = currentServiceDay(now);
  final monday = day.subtract(Duration(days: day.weekday - 1));
  return DateTime(monday.year, monday.month, monday.day, 5);
}
