import '../models/person.dart';
import '../models/teams.dart';

/// A team's people in the Pessoas list view.
class PeopleSection {
  const PeopleSection(
    this.title,
    this.people, {
    this.openByDefault = false,
    this.turno,
  });

  final String title;
  final List<Person> people;

  /// Whether the section starts expanded (the rest start collapsed).
  final bool openByDefault;

  /// The turno this section is for (Livre Serviço · Dia / · Noite), else
  /// null.
  final Turno? turno;
}

const _accents = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', //
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', //
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', //
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', //
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', //
  'ç': 'c', 'ñ': 'n',
};

/// Lowercases [s] and strips Portuguese accents, for search and grouping.
String foldText(String s) =>
    s.toLowerCase().split('').map((c) => _accents[c] ?? c).join();

int _byName(Person a, Person b) =>
    foldText(a.fullName).compareTo(foldText(b.fullName));

/// The list section [p] belongs in: their team's name ("Livre Serviço · Dia",
/// "Livre Serviço · Noite" or "Livre Serviço · Sem turno" for a team split
/// by turno), or "Sem equipa".
String _sectionTitle(Person p) {
  final team = teamById(p.team);
  if (team == null) return 'Sem equipa';
  if (!team.hasTurnos) return team.name;
  return '${team.name} · ${turnoOf(p)?.label ?? 'Sem turno'}';
}

/// Every section title in list order, with its team and turno.
final List<(String, Team?, Turno?)> _sectionOrder = [
  for (final t in teams)
    if (t.hasTurnos) ...[
      for (final turno in Turno.values)
        ('${t.name} · ${turno.label}', t, turno),
      ('${t.name} · Sem turno', t, null),
    ] else
      (t.name, t, null),
  ('Sem equipa', null, null),
];

bool _matches(Person p, String foldedQuery) =>
    foldText(p.fullName).contains(foldedQuery) ||
    foldText(_sectionTitle(p)).contains(foldedQuery) ||
    foldText(p.collaboratorNumber).contains(foldedQuery) ||
    (p.permanencia && 'permanencia'.contains(foldedQuery)) ||
    (p.partTime && 'tempo parcial'.contains(foldedQuery)) ||
    (isSupervisor(p) && 'supervisor'.contains(foldedQuery)) ||
    (isSegundaLinha(p) && 'segunda linha'.contains(foldedQuery));

/// Filters [people] by [query] (name, section title — team and turno —, nº
/// de colaborador, a tag — Permanência, Supervisor, Segunda Linha — or
/// "tempo parcial", ignoring case and accents) and groups them into sections
/// in [teams] order (Livre Serviço split into Dia, Noite and Sem turno), with
/// people without a (known) team in a final "Sem equipa" section. Within a
/// section, chefes come first in the team's slot order, then Supervisores,
/// then Segunda Linha, then members, each A–Z. Empty sections are left
/// out.
List<PeopleSection> buildPeopleSections(
  List<Person> people, {
  String query = '',
}) {
  final q = foldText(query.trim());
  final bySection = <String, List<Person>>{};
  for (final p in people) {
    if (q.isNotEmpty && !_matches(p, q)) continue;
    (bySection[_sectionTitle(p)] ??= []).add(p);
  }

  int byRank(Team? team, Person a, Person b) {
    int rank(Person p) {
      final slot = chefeSlotOf(p);
      if (team != null && slot != null) return team.chefeSlots.indexOf(slot);
      if (isSupervisor(p)) return 100;
      if (isSegundaLinha(p)) return 101;
      return 102;
    }

    final r = rank(a).compareTo(rank(b));
    return r != 0 ? r : _byName(a, b);
  }

  return [
    for (final (title, team, turno) in _sectionOrder)
      if (bySection[title] case final members?)
        PeopleSection(
          title,
          members..sort((a, b) => byRank(team, a, b)),
          openByDefault: team?.openByDefault ?? false,
          turno: turno,
        ),
  ];
}

/// The Pessoas count line: "42 pessoas · 35 tempo inteiro · 7 tempo
/// parcial", or "5 de 42 pessoas" while [query] (as in [buildPeopleSections])
/// filters the list.
String peopleCountText(List<Person> people, {String query = ''}) {
  final total = people.length;
  final noun = total == 1 ? 'pessoa' : 'pessoas';
  final q = foldText(query.trim());
  if (q.isNotEmpty) {
    final shown = people.where((p) => _matches(p, q)).length;
    return '$shown de $total $noun';
  }
  final partTime = people.where((p) => p.partTime).length;
  return '$total $noun · ${total - partTime} tempo inteiro · '
      '$partTime tempo parcial';
}
