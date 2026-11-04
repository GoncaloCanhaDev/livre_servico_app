import 'local_row.dart';

/// One Listas 2.0 → Visível: the products picked by hand going round the
/// store, and who did it. Meant once a day after a round of Automáticas,
/// but never locked: a day can have several.
class Visivel2Entry with SyncFields {
  Visivel2Entry();

  factory Visivel2Entry.fromJson(Map<String, dynamic> j) {
    final v = Visivel2Entry()
      ..createdAt = dateFromJsonOr(j['createdAt'], DateTime(2000))
      ..serviceDay = dateFromJsonOr(j['serviceDay'], DateTime(2000))
      ..itens = intFromJson(j['itens'])
      ..byNames = stringsFromJson(j['byNames'])
      ..backdated = boolFromJson(j['backdated']);
    syncFieldsFromJson(v, j);
    return v;
  }

  /// When it was saved; noon of [serviceDay] for one saved [backdated].
  late DateTime createdAt;
  late DateTime serviceDay;

  /// Itens picados.
  int itens = 0;
  List<String> byNames = [];

  /// Saved from a later day, for an earlier one.
  bool backdated = false;

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'createdAt': dateToJson(createdAt),
    'serviceDay': dateToJson(serviceDay),
    'itens': itens,
    'byNames': byNames,
    'backdated': backdated,
  };
}
