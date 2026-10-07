import '../models/person.dart';
import '../models/teams.dart';

/// A team's people in the Pessoas list view.
class PeopleSection {
  const PeopleSection(this.title, this.people);

  final String title;
  final List<Person> people;
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

/// Every section title in list order, with the team each one belongs to.
final List<(String, Team?)> _sectionOrder = [
  for (final t in teams)
    if (t.hasTurnos) ...[
      for (final turno in Turno.values) ('${t.name} · ${turno.label}', t),
      ('${t.name} · Sem turno', t),
    ] else
      (t.name, t),
  ('Sem equipa', null),
];

bool _matches(Person p, String foldedQuery) =>
    foldText(p.fullName).contains(foldedQuery) ||
    foldText(_sectionTitle(p)).contains(foldedQuery) ||
    foldText(p.collaboratorNumber).contains(foldedQuery) ||
    (p.permanencia && 'permanencia'.contains(foldedQuery)) ||
    (p.partTime && 'tempo parcial'.contains(foldedQuery)) ||
    (isSupervisor(p) && 'supervisor'.contains(foldedQuery));

/// Filters [people] by [query] (name, section title — team and turno —, nº
/// de colaborador, the Permanência tag, "tempo parcial" or "supervisor",
/// ignoring case and accents) and groups them into sections in [teams] order
/// (Livre Serviço split into Dia, Noite and Sem turno), with people without a
/// (known) team in a final "Sem equipa" section. Within a section, chefes
/// come first in the team's slot order, then supervisors A–Z, then members
/// A–Z. Empty sections are left out.
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
      return isSupervisor(p) ? 1 << 9 : 1 << 10;
    }

    final r = rank(a).compareTo(rank(b));
    return r != 0 ? r : _byName(a, b);
  }

  return [
    for (final (title, team) in _sectionOrder)
      if (bySection[title] case final members?)
        PeopleSection(title, members..sort((a, b) => byRank(team, a, b))),
  ];
}
