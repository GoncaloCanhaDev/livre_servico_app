import '../models/person.dart';

/// A cargo's people in the Pessoas list view.
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
    foldText(p.role ?? '').contains(foldedQuery) ||
    foldText(p.collaboratorNumber).contains(foldedQuery);

/// Filters [people] by [query] (name, cargo or nº de colaborador, ignoring
/// case and accents) and groups them by cargo: sections A–Z, people A–Z
/// inside, people without a cargo in a final "Sem cargo" section. Cargos
/// that differ only in case/accents/spacing share a section, titled with
/// the first one seen (first letter capitalized). Empty sections are left
/// out.
List<PeopleSection> buildPeopleSections(
  List<Person> people, {
  String query = '',
}) {
  final q = foldText(query.trim());
  final buckets = <String, List<Person>>{};
  final titles = <String, String>{};
  final noRole = <Person>[];
  for (final p in people) {
    if (q.isNotEmpty && !_matches(p, q)) continue;
    final role = p.role?.trim() ?? '';
    if (role.isEmpty) {
      noRole.add(p);
      continue;
    }
    final key = foldText(role);
    titles.putIfAbsent(key, () => role[0].toUpperCase() + role.substring(1));
    (buckets[key] ??= []).add(p);
  }
  final keys = buckets.keys.toList()..sort();
  return [
    for (final k in keys) PeopleSection(titles[k]!, buckets[k]!..sort(_byName)),
    if (noRole.isNotEmpty) PeopleSection('Sem cargo', noRole..sort(_byName)),
  ];
}
