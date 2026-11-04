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

/// One send of an item of Listas 2.0 → Automáticas: its number, who did
/// it and when. Each send is its own row, kept in Histórico, like 1.0's
/// `AutoList`; an item can be sent any number of times a day.
class Auto2Entry with SyncFields {
  Auto2Entry();

  factory Auto2Entry.fromJson(Map<String, dynamic> j) {
    final e = Auto2Entry()
      ..createdAt = dateFromJsonOr(j['createdAt'], DateTime(2000))
      ..item = stringOrNull(j['item']) ?? ''
      ..value = intFromJson(j['value'])
      ..byNames = stringsFromJson(j['byNames'])
      ..backdated = boolFromJson(j['backdated']);
    syncFieldsFromJson(e, j);
    return e;
  }

  /// When it was sent; noon of the day chosen for one sent [backdated].
  late DateTime createdAt;

  /// An [Auto2Item.name].
  String item = '';

  int value = 0;
  List<String> byNames = [];

  /// Sent from a later day, for an earlier one.
  bool backdated = false;

  /// The item's name, or what was stored for an item no longer listed.
  String get label => Auto2Item.byName(item)?.label ?? item;

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'createdAt': dateToJson(createdAt),
    'item': item,
    'value': value,
    'byNames': byNames,
    'backdated': backdated,
  };
}
