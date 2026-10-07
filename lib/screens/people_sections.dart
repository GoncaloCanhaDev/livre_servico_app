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

bool _matches(Person p, String foldedQuery) =>
    foldText(p.fullName).contains(foldedQuery) ||
    foldText(teamById(p.team)?.name ?? '').contains(foldedQuery) ||
    foldText(p.collaboratorNumber).contains(foldedQuery);

/// Filters [people] by [query] (name, team name or nº de colaborador,
/// ignoring case and accents) and groups them by team in [teams] order,
/// with people without a (known) team in a final "Sem equipa" section.
/// Within a team, chefes come first in the team's slot order, then members
/// A–Z. Empty sections are left out.
List<PeopleSection> buildPeopleSections(
  List<Person> people, {
  String query = '',
}) {
  final q = foldText(query.trim());
  final byTeam = <String?, List<Person>>{};
  for (final p in people) {
    if (q.isNotEmpty && !_matches(p, q)) continue;
    (byTeam[teamById(p.team)?.id] ??= []).add(p);
  }

  int byRank(Team team, Person a, Person b) {
    int rank(Person p) {
      final slot = chefeSlotOf(p);
      return slot == null
          ? team.chefeSlots.length
          : team.chefeSlots.indexOf(slot);
    }

    final r = rank(a).compareTo(rank(b));
    return r != 0 ? r : _byName(a, b);
  }

  return [
    for (final t in teams)
      if (byTeam[t.id] case final members?)
        PeopleSection(t.name, members..sort((a, b) => byRank(t, a, b))),
    if (byTeam[null] case final rest?)
      PeopleSection('Sem equipa', rest..sort(_byName)),
  ];
}
