import 'local_row.dart';

class AutoList with SyncFields {
  AutoList();

  factory AutoList.fromJson(Map<String, dynamic> j) {
    final a = AutoList()
      ..createdByInitials = stringOrNull(j['createdByInitials'])
      ..createdByNames = stringsFromJson(j['createdByNames'])
      ..createdAt = dateFromJsonOr(j['createdAt'], DateTime(2000))
      ..congelados = intFromJson(j['congelados'])
      ..opls = intFromJson(j['opls'])
      ..naoPereciveis = intFromJson(j['naoPereciveis'])
      ..backdated = boolFromJson(j['backdated']);
    syncFieldsFromJson(a, j);
    return a;
  }

  /// Legacy — kept for historical read fallback only, do not write.
  String? createdByInitials;
  List<String> createdByNames = [];

  late DateTime createdAt;

  int congelados = 0;
  int opls = 0;
  int naoPereciveis = 0;

  /// True when this entry was added via the backdate flow instead of on its own day.
  bool backdated = false;

  int get total => congelados + opls + naoPereciveis;

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'createdByInitials': createdByInitials,
    'createdByNames': createdByNames,
    'createdAt': dateToJson(createdAt),
    'congelados': congelados,
    'opls': opls,
    'naoPereciveis': naoPereciveis,
    'backdated': backdated,
  };
}
