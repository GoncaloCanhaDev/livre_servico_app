import 'local_row.dart';

class OpeningList with SyncFields {
  OpeningList();

  factory OpeningList.fromJson(Map<String, dynamic> j) {
    final l = OpeningList()
      ..createdByInitials = stringOrNull(j['createdByInitials'])
      ..createdByNames = stringsFromJson(j['createdByNames'])
      ..serviceDay = dateFromJsonOr(j['serviceDay'], noDate)
      ..congelados = intFromJson(j['congelados'])
      ..opls = intFromJson(j['opls'])
      ..naoPereciveis = intFromJson(j['naoPereciveis'])
      ..congeladosDoneAt = dateFromJson(j['congeladosDoneAt'])
      ..congeladosByNames = stringsFromJson(j['congeladosByNames'])
      ..oplsDoneAt = dateFromJson(j['oplsDoneAt'])
      ..oplsByNames = stringsFromJson(j['oplsByNames'])
      ..naoPereciveisDoneAt = dateFromJson(j['naoPereciveisDoneAt'])
      ..naoPereciveisByNames = stringsFromJson(j['naoPereciveisByNames'])
      ..backdated = boolFromJson(j['backdated'])
      ..finalizedAt = dateFromJson(j['finalizedAt']);
    syncFieldsFromJson(l, j);
    return l;
  }

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'createdByInitials': createdByInitials,
    'createdByNames': createdByNames,
    'serviceDay': dateToJson(serviceDay),
    'congelados': congelados,
    'opls': opls,
    'naoPereciveis': naoPereciveis,
    'congeladosDoneAt': dateToJson(congeladosDoneAt),
    'congeladosByNames': congeladosByNames,
    'oplsDoneAt': dateToJson(oplsDoneAt),
    'oplsByNames': oplsByNames,
    'naoPereciveisDoneAt': dateToJson(naoPereciveisDoneAt),
    'naoPereciveisByNames': naoPereciveisByNames,
    'backdated': backdated,
    'finalizedAt': dateToJson(finalizedAt),
  };

  /// Legacy — kept for historical read fallback only, do not write.
  String? createdByInitials;
  List<String> createdByNames = [];

  late DateTime serviceDay;

  int congelados = 0;
  int opls = 0;
  int naoPereciveis = 0;

  /// When each section was sent and by whom (see [markSectionDone]); null /
  /// empty on lists finalized before sections existed.
  DateTime? congeladosDoneAt;
  List<String> congeladosByNames = [];
  DateTime? oplsDoneAt;
  List<String> oplsByNames = [];
  DateTime? naoPereciveisDoneAt;
  List<String> naoPereciveisByNames = [];

  /// True when this row was finalized via the backdate flow instead of on its own day.
  bool backdated = false;

  /// Set once every section is done.
  DateTime? finalizedAt;

  bool get isFinalized => finalizedAt != null;
  int get total => congelados + opls + naoPereciveis;

  int valueOf(ListSection s) => switch (s) {
    ListSection.congelados => congelados,
    ListSection.opls => opls,
    ListSection.naoPereciveis => naoPereciveis,
  };

  void setValue(ListSection s, int value) {
    switch (s) {
      case ListSection.congelados:
        congelados = value;
      case ListSection.opls:
        opls = value;
      case ListSection.naoPereciveis:
        naoPereciveis = value;
    }
  }

  DateTime? _doneAt(ListSection s) => switch (s) {
    ListSection.congelados => congeladosDoneAt,
    ListSection.opls => oplsDoneAt,
    ListSection.naoPereciveis => naoPereciveisDoneAt,
  };

  /// A finalized list counts every section done, whenever it was finalized.
  bool isSectionDone(ListSection s) => isFinalized || _doneAt(s) != null;

  List<String> namesOf(ListSection s) => switch (s) {
    ListSection.congelados => congeladosByNames,
    ListSection.opls => oplsByNames,
    ListSection.naoPereciveis => naoPereciveisByNames,
  };

  /// Marks [s] done by [names] at [at]. Once all three sections are done the
  /// list is finalized, crediting everyone who did a section; returns whether
  /// this call finalized it.
  bool markSectionDone(ListSection s, List<String> names, DateTime at) {
    switch (s) {
      case ListSection.congelados:
        congeladosDoneAt = at;
        congeladosByNames = names;
      case ListSection.opls:
        oplsDoneAt = at;
        oplsByNames = names;
      case ListSection.naoPereciveis:
        naoPereciveisDoneAt = at;
        naoPereciveisByNames = names;
    }
    if (isFinalized || !ListSection.values.every((s) => _doneAt(s) != null)) {
      return false;
    }
    finalizedAt = at;
    createdByNames = {
      for (final s in ListSection.values) ...namesOf(s),
    }.toList();
    return true;
  }
}

/// The three parts of the opening and automatic lists, each sent on its own.
enum ListSection {
  congelados('Congelados'),
  opls('OPLS'),
  naoPereciveis('Não Perecíveis');

  const ListSection(this.label);
  final String label;
}

DateTime currentServiceDay([DateTime? now]) {
  final n = now ?? DateTime.now();
  // The day before from the date, not by taking 24 hours: on the night
  // the clocks go forward, 00:30 minus 24 hours is two dates back.
  return DateTime(n.year, n.month, n.day - (n.hour < 5 ? 1 : 0), 5);
}

/// A test for "falls in the service day starting at [day] (05:00)": the same
/// as `currentServiceDay(t).isAtSameMomentAs(day)`, but it builds the day's
/// end once instead of a local date per row (each one costs a time zone
/// lookup, which adds up over a long history).
bool Function(DateTime t) inServiceDay(DateTime day) {
  final start = DateTime(day.year, day.month, day.day, 5);
  // By date, not by adding 24 hours: the day the clocks change is 23 or 25.
  final end = DateTime(day.year, day.month, day.day + 1, 5);
  return (t) => !t.isBefore(start) && t.isBefore(end);
}

/// [items] grouped by the service day of [timeOf], newest day first and
/// each day's items newest first. Walks them sorted, so it works out a
/// service day once per day instead of once per item.
Map<DateTime, List<T>> groupByServiceDay<T>(
  Iterable<T> items,
  DateTime Function(T item) timeOf,
) {
  final sorted = items.toList()..sort((a, b) => timeOf(b).compareTo(timeOf(a)));
  final grouped = <DateTime, List<T>>{};
  List<T>? current;
  DateTime? start, end;
  for (final item in sorted) {
    final t = timeOf(item);
    if (current == null || t.isBefore(start!) || !t.isBefore(end!)) {
      final day = currentServiceDay(t);
      start = day;
      end = DateTime(day.year, day.month, day.day + 1, 5);
      current = grouped[day] ??= [];
    }
    current.add(item);
  }
  return grouped;
}
