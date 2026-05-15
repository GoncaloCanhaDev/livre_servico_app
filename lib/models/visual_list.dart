import 'package:isar_community/isar.dart';

part 'visual_list.g.dart';

@collection
class VisualList {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;
  String? createdByInitials;

  @Index()
  late DateTime createdAt;

  @Index()
  late DateTime serviceDay;

  int itensPicados = 0;
  int quebraCents = 0;
  int beneficioCents = 0;
}

int parseEurosToCents(String input) {
  if (input.trim().isEmpty) return 0;
  final normalized = input.trim().replaceAll(',', '.');
  final v = double.tryParse(normalized);
  if (v == null) return 0;
  return (v * 100).round();
}

String formatCents(int cents) {
  final v = cents / 100.0;
  return v.toStringAsFixed(2).replaceAll('.', ',');
}
