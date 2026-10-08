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
  /// Legacy — kept for historical read fallback only, do not write.
  String? createdByInitials;
  List<String> createdByNames = [];

  @Index(unique: true, replace: true)
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
    createdByNames = {for (final s in ListSection.values) ...namesOf(s)}
        .toList();
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
  if (n.hour < 5) {
    final y = n.subtract(const Duration(days: 1));
    return DateTime(y.year, y.month, y.day, 5);
  }
  return DateTime(n.year, n.month, n.day, 5);
}
