import '../models/person.dart';

/// How the Pessoas list view is ordered and grouped.
enum PeopleSort { name, role, number, seniority }

/// A run of people in the list view, under an optional header.
class PeopleSection {
  const PeopleSection(this.title, this.people);

  /// Header text, or null for a headerless section.
  final String? title;
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
/// case and accents) and orders/groups them for [sort]. Sections that end
/// up empty are left out.
List<PeopleSection> buildPeopleSections(
  List<Person> people, {
  required PeopleSort sort,
  String query = '',
}) {
  final q = foldText(query.trim());
  final list = [
    for (final p in people)
      if (q.isEmpty || _matches(p, q)) p,
  ];
  if (list.isEmpty) return const [];

  switch (sort) {
    case PeopleSort.name:
      return _grouped(
        list,
        keyOf: (p) {
          final name = foldText(p.fullName.trim());
          return name.isNotEmpty && RegExp('[a-z]').hasMatch(name[0])
              ? name[0]
              : null;
        },
        titleOf: (key, _) => key.toUpperCase(),
        noKeyTitle: '#',
      );
    case PeopleSort.role:
      return _grouped(
        list,
        keyOf: (p) {
          final role = foldText(p.role?.trim() ?? '');
          return role.isEmpty ? null : role;
        },
        titleOf: (_, first) {
          final role = first.role!.trim();
          return role[0].toUpperCase() + role.substring(1);
        },
        noKeyTitle: 'Sem cargo',
      );
    case PeopleSort.number:
      int rank(Person p) {
        final n = p.collaboratorNumber.trim();
        if (n.isEmpty) return 2;
        return int.tryParse(n) == null ? 1 : 0;
      }
      list.sort((a, b) {
        final r = rank(a).compareTo(rank(b));
        if (r != 0) return r;
        if (rank(a) == 0) {
          return int.parse(
            a.collaboratorNumber.trim(),
          ).compareTo(int.parse(b.collaboratorNumber.trim()));
        }
        final c = foldText(
          a.collaboratorNumber,
        ).compareTo(foldText(b.collaboratorNumber));
        return c != 0 ? c : _byName(a, b);
      });
      return [PeopleSection(null, list)];
    case PeopleSort.seniority:
      list.sort((a, b) {
        final ha = a.hireDate, hb = b.hireDate;
        if (ha == null || hb == null) {
          if (ha != hb) return ha == null ? 1 : -1;
          return _byName(a, b);
        }
        final c = ha.compareTo(hb);
        return c != 0 ? c : _byName(a, b);
      });
      return [PeopleSection(null, list)];
  }
}

/// Buckets [list] by [keyOf] (sections A–Z by key, people A–Z inside), with
/// people whose key is null in a final [noKeyTitle] section. [titleOf] gets
/// the key and the first person in input order who has it.
List<PeopleSection> _grouped(
  List<Person> list, {
  required String? Function(Person) keyOf,
  required String Function(String key, Person first) titleOf,
  required String noKeyTitle,
}) {
  final buckets = <String, List<Person>>{};
  final rest = <Person>[];
  for (final p in list) {
    final key = keyOf(p);
    if (key == null) {
      rest.add(p);
    } else {
      (buckets[key] ??= []).add(p);
    }
  }
  final keys = buckets.keys.toList()..sort();
  return [
    for (final k in keys)
      PeopleSection(titleOf(k, buckets[k]!.first), buckets[k]!..sort(_byName)),
    if (rest.isNotEmpty) PeopleSection(noKeyTitle, rest..sort(_byName)),
  ];
}
