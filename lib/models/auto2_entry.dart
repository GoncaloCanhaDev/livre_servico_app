import 'local_row.dart';

/// The items of Listas 2.0 → Automáticas, in the order shown. Rows store
/// the item's [name], so never rename one; reordering is fine.
enum Auto2Item {
  mercearia('Mercearia'),
  petFood('Pet Food'),
  bebidas('Bebidas'),
  vinhosDestilados('Vinhos e Destilados'),
  detergentes('Detergentes'),
  produtosPessoais('Produtos Pessoais'),
  bazar('Bazar'),
  leiteOvos('Leite e Ovos'),
  congelados('Congelados'),
  opls('OPLS'),
  fv('F&V (NÃO USAR)'),
  naoSortido('Não Sortido');

  const Auto2Item(this.label);
  final String label;

  static Auto2Item? byName(String name) {
    for (final i in values) {
      if (i.name == name) return i;
    }
    return null;
  }
}

/// One item of Listas 2.0 → Automáticas on one service day: its number and,
/// once ticked, who did it and when. One row per item and day (keyed online
/// by both), so two phones ticking different items never overwrite each
/// other. Unticking clears [doneAt] and keeps the row.
class Auto2Entry with SyncFields {
  Auto2Entry();

  factory Auto2Entry.fromJson(Map<String, dynamic> j) {
    final e = Auto2Entry()
      ..serviceDay = dateFromJsonOr(j['serviceDay'], DateTime(2000))
      ..item = stringOrNull(j['item']) ?? ''
      ..value = intFromJson(j['value'])
      ..doneAt = dateFromJson(j['doneAt'])
      ..byNames = stringsFromJson(j['byNames'])
      ..backdated = boolFromJson(j['backdated']);
    syncFieldsFromJson(e, j);
    return e;
  }

  late DateTime serviceDay;

  /// An [Auto2Item.name].
  String item = '';

  int value = 0;
  DateTime? doneAt;
  List<String> byNames = [];

  /// Ticked from a later day, for this one.
  bool backdated = false;

  bool get isDone => doneAt != null;

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'serviceDay': dateToJson(serviceDay),
    'item': item,
    'value': value,
    'doneAt': dateToJson(doneAt),
    'byNames': byNames,
    'backdated': backdated,
  };
}
